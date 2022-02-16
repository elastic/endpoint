//
//  FIlterPacketProvider.swift
//

import NetworkExtension
import os.log

/**
    The FilterDataProvider class handles connections that match the installed rules by prompting
    the user to allow or deny the connections.
 */
class FilterPacketProvider: NEFilterPacketProvider {
    
    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        
        self.packetHandler =  { (context:NEFilterPacketContext,
                                 interface:nw_interface_t,
                                 direction:NETrafficDirection,
                                 packetBytes:UnsafeRawPointer,
                                 packetLength:Int)
                                      in
                      return .allow
              }
        
        completionHandler(nil)
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
