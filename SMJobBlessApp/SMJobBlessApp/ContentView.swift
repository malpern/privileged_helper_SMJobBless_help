//
//  ContentView.swift
//  SMJobBlessApp
//
//  Created by Micah Alpern on 7/12/25.
//

import SwiftUI
import ServiceManagement
import Security

struct ContentView: View {
    @State private var statusMessage = "SMJobBless Helper Test"
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("SMJobBless Helper Test")
                .font(.title)
                .padding()
            
            Text(statusMessage)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
            
            VStack(spacing: 15) {
                Button("Install Helper") {
                    installHelper()
                }
                .disabled(isLoading)
                
                Button("Test Helper") {
                    testHelper()
                }
                .disabled(isLoading)
                
                Button("Uninstall Helper") {
                    uninstallHelper()
                }
                .disabled(isLoading)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
    
    private func installHelper() {
        isLoading = true
        statusMessage = "Installing helper..."
        
        Task {
            do {
                let success = try await installPrivilegedHelper()
                await MainActor.run {
                    statusMessage = success ? "Helper installed successfully!" : "Failed to install helper"
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    statusMessage = "Error installing helper: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    private func testHelper() {
        isLoading = true
        statusMessage = "Testing helper communication..."
        
        Task {
            do {
                let result = try await communicateWithHelper()
                await MainActor.run {
                    statusMessage = "Helper response: \(result)"
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    statusMessage = "Error communicating with helper: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    private func uninstallHelper() {
        isLoading = true
        statusMessage = "Uninstalling helper..."
        
        Task {
            do {
                let success = try await uninstallPrivilegedHelper()
                await MainActor.run {
                    statusMessage = success ? "Helper uninstalled successfully!" : "Failed to uninstall helper"
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    statusMessage = "Error uninstalling helper: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - SMJobBless Implementation
extension ContentView {
    private func installPrivilegedHelper() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            var authRef: AuthorizationRef?
            
            kSMRightBlessPrivilegedHelper.withCString { namePtr in
                var authItem = AuthorizationItem(name: namePtr, valueLength: 0, value: nil, flags: 0)
                withUnsafeMutablePointer(to: &authItem) { itemPtr in
                    var authRights = AuthorizationRights(count: 1, items: itemPtr)
                    
                    let authFlags: AuthorizationFlags = [.interactionAllowed, .preAuthorize, .extendRights]
                    
                    let authStatus = AuthorizationCreate(&authRights, nil, authFlags, &authRef)
                    
                    guard authStatus == errAuthorizationSuccess else {
                        continuation.resume(throwing: NSError(domain: "AuthorizationError", code: Int(authStatus), userInfo: [NSLocalizedDescriptionKey: "Authorization failed with status: \(authStatus)"]))
                        return
                    }
                    
                    defer {
                        if let authRef = authRef {
                            AuthorizationFree(authRef, [])
                        }
                    }
                    
                    var error: Unmanaged<CFError>?
                    let success = SMJobBless(kSMDomainSystemLaunchd, "com.keypath.helperpoc.helper" as CFString, authRef, &error)
                    
                    if let error = error?.takeRetainedValue() {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: success)
                    }
                }
            }
        }
    }
    
    private func uninstallPrivilegedHelper() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            var authRef: AuthorizationRef?
            
            kSMRightBlessPrivilegedHelper.withCString { namePtr in
                var authItem = AuthorizationItem(name: namePtr, valueLength: 0, value: nil, flags: 0)
                withUnsafeMutablePointer(to: &authItem) { itemPtr in
                    var authRights = AuthorizationRights(count: 1, items: itemPtr)
                    
                    let authFlags: AuthorizationFlags = [.interactionAllowed, .preAuthorize, .extendRights]
                    
                    let authStatus = AuthorizationCreate(&authRights, nil, authFlags, &authRef)
                    
                    guard authStatus == errAuthorizationSuccess else {
                        continuation.resume(throwing: NSError(domain: "AuthorizationError", code: Int(authStatus), userInfo: [NSLocalizedDescriptionKey: "Authorization failed with status: \(authStatus)"]))
                        return
                    }
                    
                    defer {
                        if let authRef = authRef {
                            AuthorizationFree(authRef, [])
                        }
                    }
                    
                    var error: Unmanaged<CFError>?
                    let success = SMJobRemove(kSMDomainSystemLaunchd, "com.keypath.helperpoc.helper" as CFString, authRef, true, &error)
                    
                    if let error = error?.takeRetainedValue() {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: success)
                    }
                }
            }
        }
    }
    
    private func communicateWithHelper() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let connection = NSXPCConnection(machServiceName: "com.keypath.helperpoc.helper", options: .privileged)
            connection.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
            
            connection.invalidationHandler = {
                continuation.resume(throwing: NSError(domain: "XPCError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Connection invalidated"]))
            }
            
            connection.interruptionHandler = {
                continuation.resume(throwing: NSError(domain: "XPCError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Connection interrupted"]))
            }
            
            connection.resume()
            
            let helper = connection.remoteObjectProxyWithErrorHandler { error in
                continuation.resume(throwing: error)
            } as? HelperProtocol
            
            helper?.getVersion { version in
                connection.invalidate()
                continuation.resume(returning: version)
            }
        }
    }
}

// MARK: - Helper Protocol
@objc protocol HelperProtocol {
    func getVersion(withReply reply: @escaping (String) -> Void)
}

#Preview {
    ContentView()
}
