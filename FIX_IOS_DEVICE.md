# Fix iOS Device Build Issue

## Problem
App runs on simulator but shows white screen and crashes on real device with "No such module 'Flutter'" error.

## Solution Steps

### 1. Clean and Rebuild
```bash
cd ios
rm -rf Pods Podfile.lock
cd ..
flutter clean
flutter pub get
cd ios
pod install
cd ..
```

### 2. Open Correct File in Xcode
**IMPORTANT:** Always open `Runner.xcworkspace`, NOT `Runner.xcodeproj`

```bash
open ios/Runner.xcworkspace
```

### 3. In Xcode - Check These Settings

#### A. Select the Runner Target
1. Click on "Runner" in the left sidebar (blue icon)
2. Select the "Runner" target (not the project)

#### B. General Tab
- **Bundle Identifier:** Make sure it's set (e.g., `com.example.voiceTransscript`)
- **Signing:** 
  - Check "Automatically manage signing"
  - Select your Team
  - If you see errors, fix the provisioning profile

#### C. Build Settings Tab
1. Search for "Framework Search Paths"
2. Make sure it includes:
   - `$(inherited)`
   - `$(PROJECT_DIR)/Flutter`
   - `$(PROJECT_DIR)/../Flutter`

3. Search for "Other Linker Flags"
   - Should include `$(inherited)`
   - Should include `-framework Flutter`

4. Search for "Header Search Paths"
   - Should include `$(inherited)`
   - Should include `$(PROJECT_DIR)/Flutter`

#### D. Build Phases Tab
1. Check "Embed Frameworks"
   - Should include Flutter.framework

2. Check "Link Binary With Libraries"
   - Should include Flutter.framework

### 4. Clean Build Folder
In Xcode:
- Product → Clean Build Folder (Shift + Cmd + K)

### 5. Select Your Device
- In Xcode toolbar, select your connected iPhone (not simulator)

### 6. Build and Run
- Product → Run (Cmd + R)

### 7. If Still Having Issues

#### Check Info.plist
Make sure these permissions are set:
- NSMicrophoneUsageDescription
- NSSpeechRecognitionUsageDescription

#### Check Deployment Target
- Minimum iOS version should match Podfile (15.5)

#### Try Archive Build
1. Product → Archive
2. If archive succeeds, the issue is likely code signing

### 8. Common Issues

#### Code Signing Error
- Go to Signing & Capabilities
- Select your development team
- Xcode will automatically create provisioning profile

#### "No such module 'Flutter'"
- Make sure you opened `.xcworkspace` not `.xcodeproj`
- Clean build folder
- Reinstall pods: `cd ios && pod install`

#### White Screen
- Check console logs in Xcode
- Look for crash reports
- Check if all permissions are granted

## Quick Fix Script
Run this in terminal:
```bash
cd /Users/ibrahimelgendy/Mobile_Develop/voice_transcript/voice_transscript
flutter clean
flutter pub get
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
open ios/Runner.xcworkspace
```

Then in Xcode:
1. Select your device (not simulator)
2. Product → Clean Build Folder
3. Product → Run

