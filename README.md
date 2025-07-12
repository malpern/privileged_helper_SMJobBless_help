# SMJobBless Privileged Helper - macOS Implementation

**Goal**: Create a working privileged helper using the legacy SMJobBless API as an alternative to the problematic SMAppService on macOS 15.

## Project Status: 🚧 **Initial Setup**

This repository implements a simple "hello world" privileged helper using SMJobBless to:
1. **Validate SMJobBless works** on macOS 15 Sequoia
2. **Document working approach** for privileged helper registration  
3. **Provide foundation** for Kanata keyboard remapping integration

## Background

This project was created after comprehensive testing showed SMAppService consistently fails with Error 108 on macOS 15, despite perfect configuration. See: [SMAppService Analysis](https://github.com/malpern/privileged_helper_help)

## Implementation Plan

- [ ] **Basic Xcode project** with app + helper targets
- [ ] **SMJobBless registration** using Authorization Services
- [ ] **Simple IPC** between app and helper
- [ ] **Production signing** and notarization testing
- [ ] **Documentation** of working approach

## Next Steps

1. Create Xcode project with dual targets
2. Implement basic SMJobBless authorization
3. Test privileged helper registration
4. Validate on macOS 15 Sequoia

---

*Started: July 2025 - Alternative approach to SMAppService Error 108*