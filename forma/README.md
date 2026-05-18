# Forma

A habit journal for the intentional.

## Release Build Setup

### Android

1. The release keystore has been generated at `android/app/keystore.jks`.
2. Open `android/key.properties` and replace the placeholder passwords with your own:
   ```properties
   storePassword=YOUR_STORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=forma
   storeFile=app/keystore.jks
   ```
3. If you prefer to use your own keystore, replace `android/app/keystore.jks` and update `android/key.properties` accordingly.
4. Build the release APK or AAB:
   ```bash
   flutter build apk --release
   flutter build appbundle --release
   ```

### iOS

1. Open `ios/ExportOptions.plist` and replace `YOUR_TEAM_ID` with your actual Apple Developer Team ID.
2. Ensure the bundle identifier in Xcode is set to `com.forma.forma`.
3. Build and archive via Xcode or command line:
   ```bash
   flutter build ipa --export-options-plist=ios/ExportOptions.plist
   ```

### Debug Flags

Release builds automatically disable debug flags. No additional configuration is required.
