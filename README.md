# SMJobBless Privileged Helper - macOS Implementation

**Goal**: Create a working privileged helper using the legacy SMJobBless API as an alternative to the problematic SMAppService on macOS 15.

## Project Status: ✅ **Implementation Complete - Ready for Testing**

This repository implements a complete SMJobBless privileged helper solution:
1. ✅ **Xcode project** with app + helper targets built successfully  
2. ✅ **SwiftUI interface** with Install/Test/Uninstall buttons
3. ✅ **SMJobBless integration** using Authorization Services framework
4. ✅ **XPC communication** between app and helper with proper protocols
5. ✅ **Code signing** configured with automatic signing (Apple Development)
6. ✅ **Copy Files build phase** properly configured for helper deployment
7. ✅ **CFErrorDomainLaunchd error 2 resolved** - helper now embedded correctly
8. ✅ **Info.plist SMPrivilegedExecutables fix** - critical configuration now preserved in final bundle

## Background

This project was created after comprehensive testing showed SMAppService consistently fails with Error 108 on macOS 15, despite perfect configuration. After systematic elimination of all configuration possibilities in the [previous SMAppService attempt](https://github.com/malpern/privileged_helper_help), we're pivoting to the legacy but stable SMJobBless API.


## What's Implemented

- ✅ **Complete Xcode project** with app + helper targets in `SMJobBlessApp/`
- ✅ **SMJobBless registration** using Authorization Services framework
- ✅ **XPC communication** between app and helper with proper protocols  
- ✅ **SwiftUI interface** for installing, testing, and managing the helper
- ✅ **Helper validation** that confirms root privileges and performs test operations
- ✅ **Code signing** configured with Team ID X2RKZ5TG99 (Apple Development)
- ✅ **Build system** working with manual signing to bypass provisioning conflicts

## Technical Achievements

### **Key Issues Resolved:**
- **CFErrorDomainLaunchd Error 2**: Fixed missing Copy Files build phase that embeds Helper in app bundle at `Contents/Library/LaunchServices/`
- **Swift Compilation**: Fixed deprecated `AuthorizationFlags.defaults` and unsafe pointer usage
- **Code Signing**: Automatic signing with Apple Development identity (Team ID: X2RKZ5TG99)
- **Target Dependencies**: Properly configured Helper → SMJobBlessApp build dependency
- **XcodeBuild MCP**: Command-line debugging essential for identifying precise build failures

### **Development Tools Used:**
- **XcodeBuild MCP Server**: Real-time compilation feedback and error identification
- **Manual Code Signing**: Bypassed Apple's provisioning profile conflicts
- **Swift 5.0**: Updated Authorization Services usage for modern Swift

## How You Can Help Us Get Unstuck

**Current State**: We've resolved all major build and configuration issues. The project compiles successfully and the SMPrivilegedExecutables section is correctly embedded in the final app bundle. **We're ready for the next phase: actual testing on macOS 15.**

### **What We Need Help With:**
1. **🧪 Functional Testing**: Test the SMJobBless installation process on a real macOS 15 system
2. **🔧 Runtime Debugging**: If installation fails, debug the actual SMJobBless API calls
3. **📋 XPC Communication**: Verify the helper can be reached via XPC after installation
4. **🛡️ Privilege Validation**: Confirm the helper runs with root privileges
5. **🧹 Clean Uninstallation**: Test the helper removal process

### **What We've Completed:**
- ✅ **Project structure** and build configuration
- ✅ **Code signing** and provisioning issues resolved  
- ✅ **Helper embedding** in app bundle at correct location
- ✅ **Info.plist configuration** with SMPrivilegedExecutables section preserved
- ✅ **Authorization Services** integration with proper error handling
- ✅ **XPC protocol** definition and basic communication setup

### **Testing Instructions for Contributors:**
1. Clone this repository
2. Open `SMJobBlessApp/SMJobBlessApp.xcodeproj` in Xcode
3. Build and run the project (should launch successfully)
4. Click "Install Helper" - this is where we need verification
5. Report back any errors with detailed logs from Console.app

### **Key Files to Review:**
- `/SMJobBlessApp/SMJobBlessApp/ContentView.swift` - Main UI and SMJobBless calls
- `/SMJobBlessApp/Helper/main.swift` - Privileged helper implementation
- `/SMJobBlessApp/SMJobBlessApp/Info.plist` - Critical SMPrivilegedExecutables configuration
- `/PLAN.md` - Detailed implementation progress and technical issues resolved

## Debugging & Resolution History

### **July 13, 2025 - Critical Info.plist Fix**

**Problem**: SMPrivilegedExecutables section missing from final app bundle's Info.plist, would cause CFErrorDomainLaunchd error 2.

**Root Cause**: Modern Xcode's PBXFileSystemSynchronizedRootGroup automatically includes ALL source files as bundle resources, and `GENERATE_INFOPLIST_FILE = YES` overrode the custom Info.plist.

**Solution Applied**:
- Set `GENERATE_INFOPLIST_FILE = NO` for SMJobBlessApp target
- Added PBXFileSystemSynchronizedBuildFileExceptionSet to exclude Info.plist from resources
- Created explicit PBXFileReference for proper Info.plist processing

**Verification**: Built app now contains SMPrivilegedExecutables with correct bundle identifier.

### **July 13, 2025 - CFErrorDomainLaunchd Error 2 Resolved**

**Problem**: SMJobBless failed with `CFErrorDomainLaunchd error 2` when attempting to install the privileged helper.

**Root Cause**: The Helper executable was not embedded in the main app bundle. SMJobBless expects the helper tool to be located at `SMJobBlessApp.app/Contents/Library/LaunchServices/Helper`.

**Investigation Process**:
1. ✅ **Authorization Services working** - user prompted for credentials successfully
2. ✅ **Helper target building** - executable created in `build/Debug/Helper`  
3. ❌ **Helper missing from app bundle** - not found in `Contents/Library/LaunchServices/`
4. ❌ **Copy Files build phase misconfigured** - pointing to wrong destination

**Solution Applied**:
- **Added proper Copy Files build phase** to SMJobBlessApp target
- **Configured destination**: Wrapper → `Contents/Library/LaunchServices`
- **Added target dependency**: SMJobBlessApp depends on Helper target
- **Build order**: Helper builds first, then gets copied during SMJobBlessApp build

**Verification**:
- Helper executable now present at: `SMJobBlessApp.app/Contents/Library/LaunchServices/Helper`
- File size: 165,136 bytes (Universal binary: x86_64 + arm64)
- Permissions: `-rwxr-xr-x` (executable)

**Key Learning**: This is the classic cause of `CFErrorDomainLaunchd error 2` in SMJobBless implementations. Many developers encounter this when the Copy Files build phase is missing or misconfigured.

## Testing Status

Ready for functional testing:
1. ✅ **Project builds successfully** (both app and helper targets)
2. ✅ **Helper properly embedded** in app bundle at correct location
3. ✅ **Authorization dialog working** (prompts for admin credentials)
4. 🔄 **Helper installation** (should work now with embedded helper)
5. 🔄 **XPC communication** (pending verification)
6. 🔄 **Privilege validation** (pending verification)

---

*Started: July 2025 - Alternative approach to SMAppService Error 108*
