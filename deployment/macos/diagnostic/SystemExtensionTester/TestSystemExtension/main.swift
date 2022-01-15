/*
See LICENSE folder for this project's licensing information.

Abstract:
This file contains initialization code for the system extension.
*/

import Foundation
import NetworkExtension

autoreleasepool {
    NEProvider.startSystemExtensionMode()
    IPCConnection.shared.startListener()
}

dispatchMain()
