# ✅ Setup Verification Checklist

## Before You Run

Make sure these files are updated:

### Dart Files
- [ ] `lib/student/screens/student_opportunities.dart` - Updated with fallback logic
- [ ] `lib/student/screens/student_home.dart` - Updated with fallback logic

### Android Files  
- [ ] `android/app/src/main/kotlin/com/aast/connect/aast_connect/MainActivity.kt` - Added MethodChannel
- [ ] `android/app/src/main/AndroidManifest.xml` - Added browser intent queries

### Dependencies
- [ ] `pubspec.yaml` contains `url_launcher: ^6.2.5` ✓ (Already present)
- [ ] `pubspec.yaml` contains `flutter/services.dart` ✓ (Flutter built-in)

---

## Step-by-Step Setup

### 1. Clean Previous Build
```bash
flutter clean
rm -rf build/
rm -rf .dart_tool/
```

### 2. Get Dependencies
```bash
flutter pub get
flutter pub upgrade
```

### 3. Build for Android
```bash
flutter build apk --debug
```
Or for testing on emulator:
```bash
flutter run -v
```

### 4. Test on Emulator
```bash
flutter emulators --launch <emulator_name>
flutter run
```

### 5. Verify in App
- Navigate to **Opportunities** tab
- Find a program with "Apply on Website" button
- Click it
- Should open URL (in browser or in-app)

---

## Debug Commands

### View Console Logs
```bash
flutter run -v
```

### View Android Logs
```bash
adb logcat | grep -i flutter
adb logcat | grep -i "url\|intent"
```

### Check Emulator Browser
```bash
adb shell pm list packages | grep -i "chrome\|browser\|firefox"
```

### Test URL Intent on Emulator
```bash
adb shell am start -a android.intent.action.VIEW -d "https://example.com"
```

---

## Expected Console Output

When you click apply button:

```
=== DEBUG: _showApplyModal ===
applicationMethod: EXTERNAL
externalApplyUrl: https://example.com

=== DEBUG: _launchExternalUrl ===
Input URL: "https://example.com"
Parsed URI: https://example.com
Trying LaunchMode.platformDefault...
URL launched successfully with platformDefault!
```

---

## Troubleshooting

### Issue: "Could not open the URL"
**Solution**: Check if:
- URL in database is valid (not null, has https://)
- Emulator has a browser app installed
- Try installing Chrome: `adb install chrome.apk`

### Issue: App crashes when clicking apply
**Solution**:
- Check Logcat: `adb logcat | grep crash`
- Ensure MainActivity.kt imports are correct
- Run `flutter clean` and rebuild

### Issue: MethodChannel error
**Solution**:
- Check channel name matches: `com.aastconnect.app/url_launcher`
- Check MainActivity.kt class path matches your package
- Package should be: `com.aast.connect.aast_connect`

### Issue: Works on phone but not emulator  
**Solution**:
- This is expected! The fallback strategy handles it
- In-app browser view will be used as fallback
- No action needed

---

## Files Checklist

Run these commands to verify changes:

```bash
# Check Dart imports
grep -n "import 'package:flutter/services.dart'" lib/student/screens/student_opportunities.dart
grep -n "import 'package:flutter/services.dart'" lib/student/screens/student_home.dart

# Check MethodChannel definition
grep -n "MethodChannel" lib/student/screens/student_opportunities.dart
grep -n "MethodChannel" lib/student/screens/student_home.dart

# Check Android file
grep -n "configureFlutterEngine" android/app/src/main/kotlin/com/aast/connect/aast_connect/MainActivity.kt

# Check manifest
grep -n "android.intent.action.VIEW" android/app/src/main/AndroidManifest.xml
```

All grep commands should return results!

---

## Success Indicators ✅

- [ ] `flutter clean` runs without errors
- [ ] `flutter pub get` completes successfully  
- [ ] `flutter run` builds and deploys to emulator
- [ ] App loads without crashes
- [ ] External URLs open in browser/in-app
- [ ] Console shows `URL launched successfully!`

---

## After Successful Test

1. Test on real device to ensure no regressions
2. Test with different URLs (http, https, with/without www)
3. Test with invalid URLs (should show error gracefully)
4. Clear app cache and test again

---

**Ready to test!** 🚀

If you encounter any issues, check:
1. Console output for debug logs
2. Logcat for native errors
3. This checklist for solutions

