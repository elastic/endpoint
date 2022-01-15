/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This file contains the implementation of the primary NSViewController class.
*/

import Cocoa
import NetworkExtension
import SystemExtensions
import os.log

/**
    The ViewController class implements the UI functions of the app, including:
      - Activating the system extension and enabling the content filter configuration when the user clicks on the Start button
      - Disabling the content filter configuration when the user clicks on the Stop button
      - Prompting the user to allow or deny connections at the behest of the system extension
      - Logging connections in a NSTextView
 */
class ViewController: NSViewController {

    enum Status {
        case stopped
        case indeterminate
        case running
    }

    // MARK: Properties

    @IBOutlet var statusIndicator: NSImageView!
    @IBOutlet var statusSpinner: NSProgressIndicator!
    @IBOutlet var startButton: NSButton!
    @IBOutlet var stopButton: NSButton!
    @IBOutlet var fullDiskAccessButton: NSButton!
    @IBOutlet var fullDiskAccessStatusIndicator: NSImageView!

    var observer: Any?

    var status: Status = .stopped {
        didSet {
            // Update the UI to reflect the new status
            switch status {
                case .stopped:
                    statusIndicator.image = #imageLiteral(resourceName: "dot_red")
                    statusSpinner.stopAnimation(self)
                    statusSpinner.isHidden = true
                    stopButton.isHidden = true
                    startButton.isHidden = false
                    fullDiskAccessButton.isEnabled = false
                    fullDiskAccessStatus = .stopped
                case .indeterminate:
                    statusIndicator.image = #imageLiteral(resourceName: "dot_yellow")
                    statusSpinner.startAnimation(self)
                    statusSpinner.isHidden = false
                    stopButton.isHidden = true
                    startButton.isHidden = true
                case .running:
                    statusIndicator.image = #imageLiteral(resourceName: "dot_green")
                    statusSpinner.stopAnimation(self)
                    statusSpinner.isHidden = true
                    stopButton.isHidden = false
                    startButton.isHidden = true
                    fullDiskAccessButton.isEnabled = true
            }

            if !statusSpinner.isHidden {
                statusSpinner.startAnimation(self)
            } else {
                statusSpinner.stopAnimation(self)
            }
        }
    }
    
    var fullDiskAccessStatus: Status = .stopped {
        didSet {
            // Update the UI to reflect the new status
            switch fullDiskAccessStatus {
                case .stopped:
                    fullDiskAccessStatusIndicator.image = #imageLiteral(resourceName: "dot_red")
                    fullDiskAccessButton.isHidden = false
                case .indeterminate:
                    fullDiskAccessStatusIndicator.image = #imageLiteral(resourceName: "dot_yellow")
                case .running:
                    fullDiskAccessStatusIndicator.image = #imageLiteral(resourceName: "dot_green")
            }
        }
    }

    // Get the Bundle of the system extension.
    lazy var extensionBundle: Bundle = {

        let extensionsDirectoryURL = URL(fileURLWithPath: "Contents/Library/SystemExtensions", relativeTo: Bundle.main.bundleURL)
        let extensionURLs: [URL]
        do {
            extensionURLs = try FileManager.default.contentsOfDirectory(at: extensionsDirectoryURL,
                                                                        includingPropertiesForKeys: nil,
                                                                        options: .skipsHiddenFiles)
        } catch let error {
            fatalError("Failed to get the contents of \(extensionsDirectoryURL.absoluteString): \(error.localizedDescription)")
        }

        guard let extensionURL = extensionURLs.first else {
            fatalError("Failed to find any system extensions")
        }

        guard let extensionBundle = Bundle(url: extensionURL) else {
            fatalError("Failed to create a bundle with URL \(extensionURL.absoluteString)")
        }

        return extensionBundle
    }()

    // MARK: NSViewController

    override func viewWillAppear() {

        super.viewWillAppear()

        status = .indeterminate
        fullDiskAccessStatus = .stopped

        loadFilterConfiguration { success in
            guard success else {
                self.status = .stopped
                return
            }

            self.updateStatus()

            self.observer = NotificationCenter.default.addObserver(forName: .NEFilterConfigurationDidChange,
                                                                   object: NEFilterManager.shared(),
                                                                   queue: .main) { [weak self] _ in
                self?.updateStatus()
            }
        }
    }

    override func viewWillDisappear() {

        super.viewWillDisappear()

        guard let changeObserver = observer else {
            return
        }

        NotificationCenter.default.removeObserver(changeObserver, name: .NEFilterConfigurationDidChange, object: NEFilterManager.shared())
    }

    // MARK: Update the UI

    func updateStatus() {

        if NEFilterManager.shared().isEnabled {
            registerWithProvider()
        } else {
            status = .stopped
        }
    }

    // MARK: UI Event Handlers

    @IBAction func startFilter(_ sender: Any) {

        status = .indeterminate
        guard !NEFilterManager.shared().isEnabled else {
            registerWithProvider()
            return
        }

        guard let extensionIdentifier = extensionBundle.bundleIdentifier else {
            self.status = .stopped
            return
        }

        // Start by activating the system extension
        let activationRequest = OSSystemExtensionRequest.activationRequest(forExtensionWithIdentifier: extensionIdentifier, queue: .main)
        activationRequest.delegate = self
        OSSystemExtensionManager.shared.submitRequest(activationRequest)
    }

    @IBAction func stopFilter(_ sender: Any) {

        let filterManager = NEFilterManager.shared()

        status = .indeterminate

        guard filterManager.isEnabled else {
            status = .stopped
            return
        }

        loadFilterConfiguration { success in
            guard success else {
                self.status = .running
                return
            }

            // Disable the content filter configuration
            filterManager.isEnabled = false
            filterManager.saveToPreferences { saveError in
                DispatchQueue.main.async {
                    if let error = saveError {
                        os_log("Failed to disable the filter configuration: %@", error.localizedDescription)
                        self.status = .running
                        return
                    }

                    self.status = .stopped
                }
            }
        }
    }

    @IBAction func queryFullDiskAccess(_ sender: Any)
    {
        fullDiskAccessStatus = .indeterminate
        
        IPCConnection.shared.queryFullDiskAccessFromSystemExtension
        { success in
            DispatchQueue.main.async {
                self.fullDiskAccessStatus = (success ? .running : .stopped)
            }
        }
    }
    
    // MARK: Content Filter Configuration Management

    func loadFilterConfiguration(completionHandler: @escaping (Bool) -> Void) {

        NEFilterManager.shared().loadFromPreferences { loadError in
            DispatchQueue.main.async {
                var success = true
                if let error = loadError {
                    os_log("Failed to load the filter configuration: %@", error.localizedDescription)
                    success = false
                }
                completionHandler(success)
            }
        }
    }

    func enableFilterConfiguration() {

        let filterManager = NEFilterManager.shared()

        guard !filterManager.isEnabled else {
            registerWithProvider()
            return
        }

        loadFilterConfiguration { success in

            guard success else {
                self.status = .stopped
                return
            }

            if filterManager.providerConfiguration == nil {
                let providerConfiguration = NEFilterProviderConfiguration()
                providerConfiguration.filterSockets = true
                providerConfiguration.filterPackets = true
                filterManager.providerConfiguration = providerConfiguration
                if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
                    filterManager.localizedDescription = appName
                }
            }

            filterManager.isEnabled = true

            filterManager.saveToPreferences { saveError in
                DispatchQueue.main.async {
                    if let error = saveError {
                        os_log("Failed to save the filter configuration: %@", error.localizedDescription)
                        self.status = .stopped
                        return
                    }

                    self.registerWithProvider()
                }
            }
        }
    }

    // MARK: ProviderCommunication

    func registerWithProvider() {

        IPCConnection.shared.register(withExtension: extensionBundle) { success in
            DispatchQueue.main.async {
                self.status = (success ? .running : .stopped)
            }
        }
    }
}

extension ViewController: OSSystemExtensionRequestDelegate {

	// MARK: OSSystemExtensionActivationRequestDelegate

    func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {

        guard result == .completed else {
            os_log("Unexpected result %d for system extension request", result.rawValue)
            status = .stopped
            return
        }

        enableFilterConfiguration()
    }

    func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {

        os_log("System extension request failed: %@", error.localizedDescription)
        status = .stopped
    }

    func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {

        os_log("Extension %@ requires user approval", request.identifier)
    }

    func request(_ request: OSSystemExtensionRequest,
                 actionForReplacingExtension existing: OSSystemExtensionProperties,
                 withExtension extension: OSSystemExtensionProperties) -> OSSystemExtensionRequest.ReplacementAction {

        os_log("Replacing extension %@ version %@ with version %@", request.identifier, existing.bundleShortVersion, `extension`.bundleShortVersion)
        return .replace
    }
}
