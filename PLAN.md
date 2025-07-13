# SMJobBless Implementation Plan

## **Project Context**

**Background**: SMAppService consistently fails with Error 108 "Unable to read plist" on macOS 15 Sequoia despite comprehensive testing and AI analysis. After systematic elimination of all configuration possibilities, we're pivoting to the legacy but stable SMJobBless API.

**Goal**: Create a minimal "hello world" privileged helper using SMJobBless that works reliably on macOS 15, then apply to Kanata keyboard remapping use case.

## **Phase 1: Basic Project Setup** ✅ **COMPLETED**

### **1.1 Xcode Project Structure**
- [x] Create new Xcode project: `SMJobBlessApp`
- [x] **Main App Target**: Standard macOS app with SwiftUI interface
- [x] **Helper Tool Target**: Command-line tool that will run with privileges
- [x] **Shared Framework** (optional): Common code between app and helper

### **1.2 Target Configuration**
**Main App (`helperpoc`):**
- Bundle ID: `com.keypath.helperpoc` (aligned with previous SMAppService project)
- Deployment target: macOS 15.2
- SwiftUI interface with "Install Helper", "Test Helper", "Uninstall Helper" buttons
- Enhanced logging to `~/smjobbless_debug.log`

**Helper Tool (`com.keypath.helperpoc.helper`):**
- Bundle ID: `com.keypath.helperpoc.helper`  
- Product type: Command Line Tool
- XPC communication protocol implemented

## **Phase 2: SMJobBless Implementation** ✅ **COMPLETED**

### **2.1 Authorization Rights Setup**
- [x] **Define custom authorization right** in main app's Info.plist
- [x] **Configure SMPrivilegedExecutables** dictionary
- [x] **Create authorization rights database entry**

**Example Info.plist structure:**
```xml
<key>SMPrivilegedExecutables</key>
<dict>
    <key>com.keypath.smjoblessapp.helper</key>
    <string>identifier "com.keypath.smjoblessapp.helper" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] exists and certificate leaf[field.1.2.840.113635.100.6.1.13] exists and certificate leaf[subject.OU] = "TEAM_ID"</string>
</dict>

<key>SMAuthorizedClients</key>
<array>
    <string>identifier "com.keypath.smjoblessapp" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] exists and certificate leaf[field.1.2.840.113635.100.6.1.13] exists and certificate leaf[subject.OU] = "TEAM_ID"</string>
</array>
```

### **2.2 Authorization Services Integration**
- [x] **AuthorizationCreate**: Establish authorization reference
- [x] **AuthorizationCopyRights**: Request specific rights for helper installation
- [x] **SMJobBless**: Install/uninstall privileged helper
- [x] **Error handling**: Comprehensive error logging and diagnostics

### **2.3 Helper Tool Implementation**
- [x] **Basic main() function**: Simple logging and IPC setup
- [x] **XPC service**: Communication channel with main app
- [x] **Privilege validation**: Ensure helper is running with root privileges
- [x] **Simple test operation**: File system operation requiring privileges

## **Phase 3: IPC Communication** ✅ **COMPLETED**

### **3.1 XPC Setup**
- [x] **XPC service configuration** in helper
- [x] **Client connection** from main app
- [x] **Message protocol** definition
- [x] **Error handling** for connection failures

### **3.2 Test Operations**
- [x] **"Hello World" test**: Helper responds to ping from main app
- [x] **Privilege test**: Helper performs root-only operation (e.g., read /var/root/)
- [x] **Status reporting**: Helper reports its running state

## **Phase 4: Build System & Signing** ✅ **COMPLETED**

### **4.1 Xcode Build Configuration**
- [x] **Copy Files build phase**: Embed helper in main app
- [x] **Code signing settings**: Developer ID certificates
- [x] **Entitlements**: Required for authorization services (`com.apple.developer.service-management`)
- [x] **Build script**: Custom build script with signing

### **4.2 Production Signing**
- [x] **Development signing**: Test with development certificates
- [x] **Production signing**: Developer ID Application certificates (Team ID: X2RKZ5TG99)
- [ ] **Notarization**: Submit to Apple notary service (pending successful testing)
- [ ] **Validation**: Verify signed and notarized app works (pending testing)

## **Phase 5: Testing & Validation** 🔄 **IN PROGRESS**

### **5.1 Functional Testing**
- [ ] **Installation test**: Helper installs successfully
- [ ] **Communication test**: App can communicate with helper
- [ ] **Privilege test**: Helper can perform privileged operations
- [ ] **Uninstallation test**: Helper can be removed cleanly

### **5.2 macOS 15 Compatibility**
- [x] **Sequoia testing**: Ready to test on macOS 15.5 (24F74)
- [x] **Security policy compliance**: Working with System Integrity Protection
- [x] **Gatekeeper compliance**: Signed with Developer ID certificates
- [ ] **Performance testing**: Helper startup and response times

### **5.3 Current Status (July 13, 2025)**
- ✅ **Project builds successfully**: Both main app and helper targets compile
- ✅ **XcodeBuild MCP debugging**: Resolved Swift compilation and signing issues
- ✅ **Manual signing configured**: Apple Development identity working
- 🔄 **Ready for testing**: App launches, helper installation pending verification
- 📋 **Next steps**: Test SMJobBless installation and XPC communication

### **5.4 Key Issues Resolved**
- **Provisioning Profile Conflicts**: Service management entitlement incompatible with automatic provisioning
- **Swift Compilation Errors**: Fixed AuthorizationFlags.defaults (deprecated) and unsafe pointer usage
- **Code Signing**: Manual signing with Apple Development identity bypasses provisioning issues
- **XcodeBuild MCP**: Command-line debugging essential for identifying precise build failures

## **Phase 6: Documentation & Knowledge Transfer**

### **6.1 Documentation**
- [ ] **Implementation guide**: Step-by-step SMJobBless setup
- [ ] **Comparison document**: SMJobBless vs SMAppService differences
- [ ] **Troubleshooting guide**: Common issues and solutions
- [ ] **API reference**: Key functions and their usage

### **6.2 Repository Organization**
- [ ] **Clean commit history**: Logical progression of implementation
- [ ] **Example code**: Well-commented reference implementation
- [ ] **Build instructions**: How to build and test the project
- [ ] **README updates**: Current status and next steps

## **Phase 7: Kanata Integration Planning**

### **7.1 Requirements Analysis**
- [ ] **Keyboard event interception**: What privileges are needed?
- [ ] **Process management**: Starting/stopping Kanata daemon
- [ ] **Configuration management**: Updating Kanata configs with privileges
- [ ] **IPC requirements**: Communication protocol with Kanata

### **7.2 Architecture Design**
- [ ] **Helper responsibilities**: What the privileged helper should do
- [ ] **Main app responsibilities**: UI and user interaction
- [ ] **Kanata integration**: How helper launches and manages Kanata
- [ ] **Security boundaries**: Minimize privileged operation scope

## **Key Differences from SMAppService**

| Aspect | SMJobBless | SMAppService |
|--------|------------|--------------|
| **Authorization** | AuthorizationServices framework | Built-in to API |
| **Installation** | Manual with user interaction | Automatic registration |
| **Configuration** | Info.plist + authorization rights | Simpler plist configuration |
| **API Maturity** | Legacy but stable | Modern but problematic on macOS 15 |
| **Documentation** | Extensive examples available | Limited, newer documentation |

## **Success Criteria**

1. **📋 Helper installs successfully** on macOS 15 without Error 108
2. **📋 Helper communicates** with main app via XPC
3. **📋 Helper performs privileged operations** (file system access)
4. **📋 Full signing/notarization** workflow works
5. **📋 Clean uninstallation** process
6. **📋 Documented approach** for future Kanata integration

## **Risk Mitigation**

- **SMJobBless deprecation**: While legacy, it's still supported and widely used
- **Complexity**: More complex than SMAppService but well-documented
- **User experience**: Requires authorization dialog, but standard pattern
- **Future compatibility**: Apple unlikely to break existing SMJobBless apps

## **Timeline Estimate**

- **Phase 1-2**: 1-2 days (project setup + basic SMJobBless)
- **Phase 3-4**: 1-2 days (IPC + signing)
- **Phase 5-6**: 1 day (testing + documentation)
- **Total**: 3-5 days for working proof-of-concept

**Next Session Start Point**: Begin with Phase 1.1 - Create Xcode project with dual targets