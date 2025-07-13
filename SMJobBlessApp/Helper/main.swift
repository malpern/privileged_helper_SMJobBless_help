//
//  main.swift
//  Helper
//
//  Created by Micah Alpern on 7/12/25.
//

import Foundation

// MARK: - Helper Protocol
@objc protocol HelperProtocol {
    func getVersion(withReply reply: @escaping (String) -> Void)
}

// MARK: - Helper Implementation
class Helper: NSObject, HelperProtocol {
    func getVersion(withReply reply: @escaping (String) -> Void) {
        let version = "SMJobBless Helper v1.0 - Running as \(getuid() == 0 ? "root" : "user")"
        NSLog("Helper: getVersion called, returning: \(version)")
        reply(version)
    }
}

// MARK: - XPC Listener Delegate
class HelperListener: NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        NSLog("Helper: New XPC connection received")
        
        newConnection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
        newConnection.exportedObject = Helper()
        
        newConnection.invalidationHandler = {
            NSLog("Helper: XPC connection invalidated")
        }
        
        newConnection.interruptionHandler = {
            NSLog("Helper: XPC connection interrupted")
        }
        
        newConnection.resume()
        NSLog("Helper: XPC connection resumed")
        
        return true
    }
}

// MARK: - Main Entry Point
func main() {
    NSLog("Helper: Starting SMJobBless Helper (PID: \(getpid()), UID: \(getuid()))")
    
    let listener = NSXPCListener(machServiceName: "com.keypath.helperpoc.helper")
    let delegate = HelperListener()
    
    listener.delegate = delegate
    listener.resume()
    
    NSLog("Helper: XPC listener started, entering run loop")
    
    // Keep the helper running
    RunLoop.main.run()
}

// Start the helper
main()

