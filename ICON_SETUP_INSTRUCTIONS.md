# Flutter Icon Setup Instructions

## Step 1: Download Flutter Icon

You need to download the official Flutter icon (1024x1024 PNG format).

**Option 1: Download from Flutter website**
- Visit: https://flutter.dev/brand
- Download the Flutter logo in PNG format (1024x1024 recommended)

**Option 2: Use this direct link**
- Flutter logo: https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59b1a48dca87.png

**Option 3: Create from Flutter SDK**
- The Flutter icon is located in your Flutter SDK at:
  `flutter/packages/flutter_tools/templates/app_shared/android.tmpl/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

## Step 2: Save the Icon

1. Save the downloaded Flutter icon as `flutter_icon.png`
2. Place it in: `gen_confi/assets/images/flutter_icon.png`
3. Make sure it's a square image (1024x1024 pixels recommended)

## Step 3: Generate Icons

Run the following command to generate all app icons:

```bash
flutter pub run flutter_launcher_icons
```

Or if you have it globally installed:

```bash
flutter_launcher_icons
```

## Step 4: Clean and Rebuild

After generating icons, clean and rebuild your project:

```bash
flutter clean
flutter pub get
flutter run
```

## Step 5: Verify

- **Android**: Check `android/app/src/main/res/mipmap-*/ic_app_icon.png`
- **iOS**: Check `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

The app icon should now show the Flutter logo!

## Troubleshooting

If icons don't update:
1. Delete the `build` folder: `flutter clean`
2. Delete app from device/emulator and reinstall
3. For Android, check `android/app/src/main/res/mipmap-anydpi-v26/ic_app_icon.xml`
4. For iOS, clean build folder in Xcode: Product > Clean Build Folder


