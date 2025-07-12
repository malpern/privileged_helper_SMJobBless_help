import Foundation

// Helper tool version
let helperVersion = "1.0.0"

// Protocol must match the one in the main app
@objc protocol HelperProtocol {
    func getVersion(reply: @escaping (String) -> Void)
    func performPrivilegedOperation(reply: @escaping (Bool, String) -> Void)
}

// Helper service implementation
class Helper: NSObject, HelperProtocol, NSXPCListenerDelegate {
    
    func getVersion(reply: @escaping (String) -> Void) {
        reply(helperVersion)
    }
    
    func performPrivilegedOperation(reply: @escaping (Bool, String) -> Void) {
        // Example privileged operation - read a protected file
        let protectedPath = "/var/root/.bashrc"
        
        do {
            // Check if we're running as root
            let uid = getuid()
            if uid != 0 {
                reply(false, "Helper not running as root (uid: \(uid))")
                return
            }
            
            // Try to read a protected file
            if FileManager.default.fileExists(atPath: protectedPath) {
                let contents = try String(contentsOfFile: protectedPath, encoding: .utf8)
                reply(true, "Successfully read protected file. First 50 chars: \(String(contents.prefix(50)))")
            } else {
                // Create a test file in a privileged location
                let testPath = "/var/root/smjobbless_test.txt"
                let testContent = "SMJobBless helper successfully created this file at \(Date())"
                try testContent.write(toFile: testPath, atomically: true, encoding: .utf8)
                reply(true, "Created test file at: \(testPath)")
            }
        } catch {
            reply(false, "Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - NSXPCListenerDelegate
    
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        // Configure the connection
        newConnection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
        newConnection.exportedObject = self
        
        // Set up invalidation handler
        newConnection.invalidationHandler = {
            NSLog("SMJobBless Helper: Client disconnected")
        }
        
        // Set up interruption handler
        newConnection.interruptionHandler = {
            NSLog("SMJobBless Helper: Client connection interrupted")
        }
        
        // Resume the connection
        newConnection.resume()
        
        return true
    }
}

// Main entry point
autoreleasepool {
    // Log startup
    NSLog("SMJobBless Helper: Starting (version \(helperVersion))")
    NSLog("SMJobBless Helper: Running as uid: \(getuid())")
    
    // Create the helper instance
    let helper = Helper()
    
    // Create XPC listener
    let listener = NSXPCListener(machServiceName: "com.keypath.smjoblessapp.helper")
    listener.delegate = helper
    
    // Start listening
    listener.resume()
    
    // Run the run loop
    RunLoop.current.run()
}