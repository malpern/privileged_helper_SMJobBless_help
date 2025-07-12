# SMJobBless Implementation

This is a working implementation of a privileged helper using the SMJobBless API for macOS 15 Sequoia.

## Project Structure

- **SMJobBlessApp**: Main application with SwiftUI interface
- **com.keypath.smjoblessapp.helper**: Privileged helper tool that runs as root

## Key Components

### 1. Authorization
- Uses `AuthorizationServices` framework
- Requests `kSMRightBlessPrivilegedHelper` right
- Shows system authorization dialog

### 2. Helper Installation
- Helper is installed to `/Library/PrivilegedHelperTools/`
- Launch daemon plist created at `/Library/LaunchDaemons/`
- Helper runs with root privileges

### 3. XPC Communication
- Uses `NSXPCConnection` with Mach services
- Protocol-based communication between app and helper
- Helper validates authorized clients

## Building & Testing

### Prerequisites
1. Valid Apple Developer account
2. Code signing certificate (Developer ID Application)
3. Update "YOUR_TEAM_ID" in both Info.plist files

### Build Steps
1. Open `SMJobBlessApp.xcodeproj` in Xcode
2. Update Team ID in both Info.plist files
3. Select your signing team in project settings
4. Build and run

### Testing
1. Click "Install Helper" - system will prompt for authorization
2. Click "Test Helper" - verifies helper is running with root privileges
3. Check logs in the app window for status

## Important Notes

- Helper binary must be properly code signed
- Info.plist must contain correct SMPrivilegedExecutables/SMAuthorizedClients
- Authorization requirements are defined in both app and helper plists
- Helper runs as a system-wide daemon with root privileges

## Security Considerations

- Helper validates client authorization using code signing requirements
- All IPC communication is authenticated
- Helper should only perform necessary privileged operations
- Follow principle of least privilege

## Differences from SMAppService

- Requires manual authorization flow
- More complex setup but more reliable
- Works consistently on macOS 15 Sequoia
- Legacy API but still fully supported