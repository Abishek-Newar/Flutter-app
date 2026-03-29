# نقْدي (CircleCash) — Production Deployment Guide
## App Identity
- **App Name:** CircleCash / نقْدي
- **Package ID:** `app.naqde.user`
- **Version:** 2.0.0+4
- **Flutter SDK:** ^3.8.1
- **Min Android SDK:** 21 (Android 5.0)
- **Target Android SDK:** 34 (Android 14)

---

## Step 1 — Set Your Backend URL
In `lib/util/app_constants.dart`, replace:
```dart
static const String baseUrl = 'YOUR_BASE_URL_HERE';
```
With your actual Laravel backend URL, e.g.:
```dart
static const String baseUrl = 'https://api.naqde.app';
```

---

## Step 2 — Firebase Setup
1. Create a Firebase project at https://console.firebase.google.com
2. Add Android app with package `app.naqde.user`
3. Add iOS app with bundle ID `app.naqde.user`
4. Download and place:
   - `google-services.json` → `android/app/google-services.json`
   - `GoogleService-Info.plist` → `ios/Runner/GoogleService-Info.plist`
5. Add to `android/app/build.gradle`:
   ```groovy
   apply plugin: 'com.google.gms.google-services'
   ```

---

## Step 3 — Android Keystore (Release Signing)
```bash
keytool -genkey -v -keystore naqdi.keystore \
  -alias naqdi -keyalg RSA -keysize 2048 -validity 10000
```
Add to `android/local.properties`:
```
storeFile=../naqdi.keystore
storePassword=YOUR_STORE_PASSWORD
keyAlias=naqdi
keyPassword=YOUR_KEY_PASSWORD
```
Then uncomment the signing block in `android/app/build.gradle`.

---

## Step 4 — Build Commands

### Android APK (for direct install / testing)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (requires macOS + Xcode)
```bash
flutter build ipa --release
# Output: build/ios/ipa/CircleCash.ipa
```

---

## Step 5 — Play Store Upload
1. Go to https://play.google.com/console
2. Create app → Package name: `app.naqde.user`
3. Upload `app-release.aab`
4. Fill in:
   - Title: **نقْدي - CircleCash**
   - Short description (Arabic + English)
   - Screenshots (phone + 7-inch tablet)
   - Feature graphic (1024×500)
5. Set Content Rating: Finance
6. Set Target Audience: 18+
7. Declare: Financial App / E-Money

---

## Step 6 — App Store Upload
1. Open Xcode → `ios/Runner.xcworkspace`
2. Set Bundle Identifier: `app.naqde.user`
3. Set Version: `2.0.0`, Build: `4`
4. Product → Archive
5. Upload via Xcode Organizer or Transporter
6. In App Store Connect:
   - Category: Finance
   - Age Rating: 17+
   - Privacy URL required for Sudan market

---

## Features Checklist
| Feature | Status | Backend Route |
|---------|--------|---------------|
| Add Money (Bankak) | ✅ | POST /api/v1/manual-transfer/submit |
| Withdraw Money | ✅ | POST /api/v1/withdrawal/request |
| Send Money | ✅ | POST /api/v1/customer/send-money |
| Cash Out | ✅ | POST /api/v1/customer/cash-out |
| Request Money | ✅ | POST /api/v1/customer/request-money |
| OTP Verification | ✅ | POST /api/v1/otp/verify |
| Remittance | ✅ | POST /api/v1/remittance/send |
| Offline Wallet | ✅ | POST /api/v1/offline/sync |
| Referral Program | ✅ | POST /api/v1/referral/apply |
| Trust & Settlement | ✅ Admin Only | GET /admin/trust/balances |
| Biometric Login | ✅ | Local |
| KYC Verification | ✅ | POST /api/v1/customer/update-kyc-information |

---

## Currency
- **SDG (Sudanese Pound)** only — no $ symbol anywhere
- English format: `SDG 1,234.00`
- Arabic format: `ج.س 1,234.00`

## Languages
- English (default fallback)
- Arabic / عربي (RTL, fully translated — 516 keys)

---

## Admin Panel
Trust & Settlement, Withdrawal Requests, Add Money Requests, and Remittances 
are all visible in the Laravel admin panel at `/admin`.

Default admin credentials (change immediately):
- Email: admin@naqde.app
- Password: set during seeder

---

## Codemagic CI/CD (Optional)
Add `codemagic.yaml` to repo root and connect at https://codemagic.io
for automated APK/AAB builds on every push.
