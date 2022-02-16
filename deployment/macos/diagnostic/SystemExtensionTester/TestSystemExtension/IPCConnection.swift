/*
 See LICENSE folder for this project's licensing information.

Abstract:
This file contains the implementation of the app <-> provider IPC connection
*/

import Foundation
import os.log
import Network
import EndpointSecurity

/// App --> Provider IPC
@objc protocol ProviderCommunication {

    func register(_ completionHandler: @escaping (Bool) -> Void)
    func attemptFullDiskAccess(_ completionHandler: @escaping (Bool) -> Void)
}

/// The IPCConnection class is used by both the app and the system extension to communicate with each other
class IPCConnection: NSObject {

    // MARK: Properties

    var listener: NSXPCListener?
    var currentConnection: NSXPCConnection?
    static let shared = IPCConnection()

    // MARK: Methods

    /**
        The NetworkExtension framework registers a Mach service with the name in the system extension's NEMachServiceName Info.plist key.
        The Mach service name must be prefixed with one of the app groups in the system extension's com.apple.security.application-groups entitlement.
        Any process in the same app group can use the Mach service to communicate with the system extension.
     */
    private func extensionMachServiceName(from bundle: Bundle) -> String {

        guard let networkExtensionKeys = bundle.object(forInfoDictionaryKey: "NetworkExtension") as? [String: Any],
            let machServiceName = networkExtensionKeys["NEMachServiceName"] as? String else {
                fatalError("Mach service name is missing from the Info.plist")
        }

        return machServiceName
    }

    func startListener() {

        let machServiceName = extensionMachServiceName(from: Bundle.main)
        os_log("Starting XPC listener for mach service %@", machServiceName)

        let newListener = NSXPCListener(machServiceName: machServiceName)
        newListener.delegate = self
        newListener.resume()
        listener = newListener
    }

    /// This method is called by the app to register with the provider running in the system extension.
    func register(withExtension bundle: Bundle, completionHandler: @escaping (Bool) -> Void) {

        guard currentConnection == nil else {
            os_log("Already registered with the provider")
            completionHandler(true)
            return
        }

        let machServiceName = extensionMachServiceName(from: bundle)
        let newConnection = NSXPCConnection(machServiceName: machServiceName, options: [])

        // The remote object is the provider's IPCConnection instance.
        newConnection.remoteObjectInterface = NSXPCInterface(with: ProviderCommunication.self)

        currentConnection = newConnection
        newConnection.resume()

        guard let providerProxy = newConnection.remoteObjectProxyWithErrorHandler({ registerError in
            os_log("Failed to register with the provider: %@", registerError.localizedDescription)
            self.currentConnection?.invalidate()
            self.currentConnection = nil
            completionHandler(false)
        }) as? ProviderCommunication else {
            fatalError("Failed to create a remote object proxy for the provider")
        }

        providerProxy.register(completionHandler)
    }
    
    func queryFullDiskAccessFromSystemExtension(completionHandler: @escaping (Bool) -> Void) {
        
        // Guard nil connection
        guard self.currentConnection != nil else {
            completionHandler(false)
            return
        }
        
        guard let providerProxy = self.currentConnection?.remoteObjectProxyWithErrorHandler({
            error in
            os_log("Unable to communicate with system extension: %@", error.localizedDescription)
            self.currentConnection?.invalidate()
            self.currentConnection = nil
            completionHandler(false)
        }) as? ProviderCommunication else {
            os_log("Unable to communicate with system extension")
            completionHandler(false)
            return
        }
        
        providerProxy.attemptFullDiskAccess(completionHandler)
        
    }
}

extension IPCConnection: NSXPCListenerDelegate {

    // MARK: NSXPCListenerDelegate

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {

        // The exported object is this IPCConnection instance.
        newConnection.exportedInterface = NSXPCInterface(with: ProviderCommunication.self)
        newConnection.exportedObject = self

        newConnection.invalidationHandler = {
            self.currentConnection = nil
        }

        newConnection.interruptionHandler = {
            self.currentConnection = nil
        }

        currentConnection = newConnection
        newConnection.resume()

        return true
    }
}

extension IPCConnection: ProviderCommunication {
    // MARK: ProviderCommunication

    func register(_ completionHandler: @escaping (Bool) -> Void) {

        os_log("App registered")
        completionHandler(true)
    }
    
    func attemptFullDiskAccess(_ completionHandler: @escaping (Bool) -> Void) {
        
        var client: OpaquePointer?

        guard (es_new_client(&client) { (client, message) in
            
            os_log("ES Message received")
            
        }) == ES_NEW_CLIENT_RESULT_SUCCESS else {
            completionHandler(false)
            return
        }
        
        es_delete_client(client!)
        completionHandler(true)
    }
}
