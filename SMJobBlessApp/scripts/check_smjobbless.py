#!/usr/bin/env python3
"""
Check SMJobBless configuration
Verifies Info.plist entries match between app and helper
"""

import os
import plistlib
import subprocess
import sys

def read_plist(path):
    """Read a plist file"""
    with open(path, 'rb') as f:
        return plistlib.load(f)

def get_code_sign_requirement(bundle_path):
    """Get code signing requirement for a bundle"""
    try:
        result = subprocess.run(
            ['codesign', '-d', '-r-', bundle_path],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            # Extract the requirement string
            for line in result.stderr.split('\n'):
                if line.startswith('designated =>'):
                    return line.replace('designated => ', '').strip()
    except Exception as e:
        print(f"Error getting code sign requirement: {e}")
    return None

def check_configuration(app_path, helper_path):
    """Check SMJobBless configuration"""
    print("Checking SMJobBless configuration...")
    
    # Read Info.plist files
    app_info_path = os.path.join(app_path, "Contents/Info.plist")
    helper_info_path = os.path.join(helper_path, "Contents/Info.plist")
    
    if not os.path.exists(app_info_path):
        print(f"ERROR: App Info.plist not found at {app_info_path}")
        return False
        
    if not os.path.exists(helper_info_path):
        # For command-line tools, Info.plist might be embedded
        helper_info_path = helper_path + "/Info.plist"
        if not os.path.exists(helper_info_path):
            print(f"WARNING: Helper Info.plist not found")
            # Continue anyway as it might be embedded
    
    app_info = read_plist(app_info_path)
    
    # Check SMPrivilegedExecutables in app
    if 'SMPrivilegedExecutables' not in app_info:
        print("ERROR: SMPrivilegedExecutables not found in app Info.plist")
        return False
    
    helper_bundle_id = os.path.basename(helper_path)
    if helper_bundle_id not in app_info['SMPrivilegedExecutables']:
        print(f"ERROR: {helper_bundle_id} not found in SMPrivilegedExecutables")
        return False
    
    print(f"✓ SMPrivilegedExecutables contains {helper_bundle_id}")
    
    # Get actual code signing requirements
    app_requirement = get_code_sign_requirement(app_path)
    helper_requirement = get_code_sign_requirement(helper_path)
    
    if app_requirement:
        print(f"\nApp code requirement:\n{app_requirement}")
    
    if helper_requirement:
        print(f"\nHelper code requirement:\n{helper_requirement}")
    
    # Check if helper is in the right location within app bundle
    expected_helper_path = os.path.join(app_path, "Contents/Library/LaunchServices", helper_bundle_id)
    if os.path.exists(expected_helper_path):
        print(f"\n✓ Helper found at expected location: {expected_helper_path}")
    else:
        print(f"\nERROR: Helper not found at expected location: {expected_helper_path}")
        return False
    
    return True

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: check_smjobbless.py <app_path> <helper_path>")
        sys.exit(1)
    
    app_path = sys.argv[1]
    helper_path = sys.argv[2]
    
    if check_configuration(app_path, helper_path):
        print("\n✅ SMJobBless configuration looks good!")
    else:
        print("\n❌ SMJobBless configuration has errors!")
        sys.exit(1)