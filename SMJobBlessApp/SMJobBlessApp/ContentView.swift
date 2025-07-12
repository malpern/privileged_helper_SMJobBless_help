import SwiftUI
import ServiceManagement

struct ContentView: View {
    @State private var helperStatus = "Not Installed"
    @State private var logMessages: [String] = []
    
    let helperBundleID = "com.keypath.smjoblessapp.helper"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("SMJobBless Demo")
                .font(.largeTitle)
                .padding()
            
            Text("Helper Status: \(helperStatus)")
                .font(.headline)
                .padding()
            
            HStack(spacing: 20) {
                Button("Install Helper") {
                    installHelper()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Test Helper") {
                    testHelper()
                }
                .buttonStyle(.bordered)
                .disabled(helperStatus == "Not Installed")
                
                Button("Uninstall Helper") {
                    uninstallHelper()
                }
                .buttonStyle(.bordered)
                .disabled(helperStatus == "Not Installed")
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(logMessages, id: \.self) { message in
                        Text(message)
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .frame(maxHeight: 200)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding()
        }
        .frame(width: 600, height: 500)
        .padding()
        .onAppear {
            checkHelperStatus()
        }
    }
    
    func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        logMessages.append("[\(timestamp)] \(message)")
    }
    
    func checkHelperStatus() {
        log("Checking helper status...")
        
        // Check if helper is installed by looking for it in launch services
        let helperURL = URL(fileURLWithPath: "/Library/LaunchDaemons/\(helperBundleID).plist")
        
        if FileManager.default.fileExists(atPath: helperURL.path) {
            helperStatus = "Installed"
            log("Helper plist found at: \(helperURL.path)")
        } else {
            helperStatus = "Not Installed"
            log("Helper not found")
        }
    }
    
    func installHelper() {
        log("Installing helper...")
        
        var authRef: AuthorizationRef?
        var authStatus = AuthorizationCreate(nil, nil, [], &authRef)
        
        guard authStatus == errAuthorizationSuccess else {
            log("Failed to create authorization: \(authStatus)")
            return
        }
        
        var authItem = AuthorizationItem(
            name: kSMRightBlessPrivilegedHelper,
            valueLength: 0,
            value: nil,
            flags: 0
        )
        
        var authRights = AuthorizationRights(
            count: 1,
            items: &authItem
        )
        
        let authFlags: AuthorizationFlags = [.interactionAllowed, .preAuthorize, .extendRights]
        
        authStatus = AuthorizationCopyRights(
            authRef!,
            &authRights,
            nil,
            authFlags,
            nil
        )
        
        guard authStatus == errAuthorizationSuccess else {
            log("Failed to copy rights: \(authStatus)")
            return
        }
        
        var error: Unmanaged<CFError>?
        let result = SMJobBless(
            kSMDomainSystemLaunchd,
            helperBundleID as CFString,
            authRef,
            &error
        )
        
        if result {
            log("Helper installed successfully!")
            helperStatus = "Installed"
        } else {
            if let error = error?.takeRetainedValue() {
                log("Failed to install helper: \(error)")
            } else {
                log("Failed to install helper: Unknown error")
            }
        }
        
        AuthorizationFree(authRef!, [])
    }
    
    func testHelper() {
        log("Testing helper...")
        
        // Create XPC connection to helper
        let connection = NSXPCConnection(machServiceName: helperBundleID, options: .privileged)
        connection.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
        connection.resume()
        
        let helper = connection.remoteObjectProxyWithErrorHandler { error in
            self.log("Failed to connect to helper: \(error)")
        } as? HelperProtocol
        
        helper?.getVersion { version in
            self.log("Helper version: \(version)")
        }
        
        helper?.performPrivilegedOperation { success, message in
            if success {
                self.log("Privileged operation succeeded: \(message)")
            } else {
                self.log("Privileged operation failed: \(message)")
            }
        }
    }
    
    func uninstallHelper() {
        log("Uninstalling helper...")
        
        // For SMJobBless, we need to manually remove the helper
        let task = Process()
        task.launchPath = "/bin/launchctl"
        task.arguments = ["unload", "/Library/LaunchDaemons/\(helperBundleID).plist"]
        
        do {
            try task.run()
            task.waitUntilExit()
            
            if task.terminationStatus == 0 {
                // Remove the plist file
                try FileManager.default.removeItem(at: URL(fileURLWithPath: "/Library/LaunchDaemons/\(helperBundleID).plist"))
                
                // Remove the helper binary
                try FileManager.default.removeItem(at: URL(fileURLWithPath: "/Library/PrivilegedHelperTools/\(helperBundleID)"))
                
                log("Helper uninstalled successfully")
                helperStatus = "Not Installed"
            } else {
                log("Failed to unload helper")
            }
        } catch {
            log("Error uninstalling helper: \(error)")
        }
    }
}

// Protocol for XPC communication
@objc protocol HelperProtocol {
    func getVersion(reply: @escaping (String) -> Void)
    func performPrivilegedOperation(reply: @escaping (Bool, String) -> Void)
}