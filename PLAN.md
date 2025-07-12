# SMJobBless Implementation Plan

## **Project Context**

**Background**: SMAppService consistently fails with Error 108 "Unable to read plist" on macOS 15 Sequoia despite comprehensive testing and AI analysis. After systematic elimination of all configuration possibilities, we're pivoting to the legacy but stable SMJobBless API.

**Goal**: Create a minimal "hello world" privileged helper using SMJobBless that works reliably on macOS 15, then apply to Kanata keyboard remapping use case.

## **Phase 1: Basic Project Setup**

### **1.1 Xcode Project Structure**
- [ ] Create new Xcode project: `SMJobBlessApp`
- [ ] **Main App Target**: Standard macOS app with SwiftUI interface
- [ ] **Helper Tool Target**: Command-line tool that will run with privileges
- [ ] **Shared Framework** (optional): Common code between app and helper

### **1.2 Target Configuration**
**Main App (`SMJobBlessApp`):**
- Bundle ID: `com.keypath.smjoblessapp`
- Deployment target: macOS 15.2
- SwiftUI interface with "Install Helper" and "Test Helper" buttons

**Helper Tool (`SMJobBlessHelper`):**
- Bundle ID: `com.keypath.smjoblessapp.helper`  
- Product type: Command Line Tool
- Embedded in main app bundle

## **Phase 2: SMJobBless Implementation**

### **2.1 Authorization Rights Setup**
- [ ] **Define custom authorization right** in main app's Info.plist
- [ ] **Configure SMPrivilegedExecutables** dictionary
- [ ] **Create authorization rights database entry**

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
- [ ] **AuthorizationCreate**: Establish authorization reference
- [ ] **AuthorizationCopyRights**: Request specific rights for helper installation
- [ ] **SMJobBless**: Install/uninstall privileged helper
- [ ] **Error handling**: Proper authorization failure handling

### **2.3 Helper Tool Implementation**
- [ ] **Basic main() function**: Simple logging and IPC setup
- [ ] **XPC service**: Communication channel with main app
- [ ] **Privilege validation**: Ensure helper is running with root privileges
- [ ] **Simple test operation**: File system operation requiring privileges

## **Phase 3: IPC Communication**

### **3.1 XPC Setup**
- [ ] **XPC service configuration** in helper
- [ ] **Client connection** from main app
- [ ] **Message protocol** definition
- [ ] **Error handling** for connection failures

### **3.2 Test Operations**
- [ ] **"Hello World" test**: Helper responds to ping from main app
- [ ] **Privilege test**: Helper performs root-only operation (e.g., read /var/root/)
- [ ] **Status reporting**: Helper reports its running state

## **Phase 4: Build System & Signing**

### **4.1 Xcode Build Configuration**
- [ ] **Copy Files build phase**: Embed helper in main app
- [ ] **Code signing settings**: Developer ID certificates
- [ ] **Entitlements**: Required for authorization services
- [ ] **Build script**: Automate helper embedding

### **4.2 Production Signing**
- [ ] **Development signing**: Test with development certificates
- [ ] **Production signing**: Developer ID Application certificates
- [ ] **Notarization**: Submit to Apple notary service
- [ ] **Validation**: Verify signed and notarized app works

## **Phase 5: Testing & Validation**

### **5.1 Functional Testing**
- [ ] **Installation test**: Helper installs successfully
- [ ] **Communication test**: App can communicate with helper
- [ ] **Privilege test**: Helper can perform privileged operations
- [ ] **Uninstallation test**: Helper can be removed cleanly

### **5.2 macOS 15 Compatibility**
- [ ] **Sequoia testing**: Validate on macOS 15.x
- [ ] **Security policy compliance**: Ensure works with System Integrity Protection
- [ ] **Gatekeeper compliance**: Signed/notarized app acceptance
- [ ] **Performance testing**: Helper startup and response times

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

1. **✅ Helper installs successfully** on macOS 15 without Error 108
2. **✅ Helper communicates** with main app via XPC
3. **✅ Helper performs privileged operations** (file system access)
4. **✅ Full signing/notarization** workflow works
5. **✅ Clean uninstallation** process
6. **✅ Documented approach** for future Kanata integration

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