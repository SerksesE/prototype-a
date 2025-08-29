# prototype_a

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Android emulator:
~/Library/Android/sdk/emulator/emulator
~/Library/Android/sdk/emulator/emulator -list-avds
~/Library/Android/sdk/emulator/emulator -avd Pixel_2_API_34 *emulator_name*

# Code generation:
dart run build_runner watch -d
dart run build_runner watch -d --delete-conflicting-outputs 

# Custom lint:
dart run custom_lint

# Fix
* Where:
Settings file '/Users/*username*/Development/riverpod_demo/android/settings.gradle.kts' line: 19

* What went wrong:
Error resolving plugin [id: 'dev.flutter.flutter-plugin-loader', version: '1.0.0']
> A problem occurred configuring project ':gradle'.
   > Could not read workspace metadata from /Users/*username*/.gradle/caches/8.12/kotlin-dsl/accessors/66a4afc4ecce242057c438fda138d2fe/metadata.bin

./gradlew clean build --refresh-dependencies

# Firebase CLI:
   - https://firebase.google.com/docs/flutter/setup?platform=ios

`dart pub global activate flutterfire_cli`

# Netlify build command
   - https://odeabreu.medium.com/thank-you-for-the-tutorial-c645c1f2b875

`if cd flutter; then git pull && cd ..; else git clone https://github.com/flutter/flutter.git; fi && flutter/bin/flutter config --enable-web && flutter/bin/flutter build web --release`


rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // Helper: check if current user has a doc in /admins
    function isAdmin() {
      return request.auth != null &&
             exists(/databases/$(database)/documents/admins/$(request.auth.uid));
    }

    // Users collection
    match /users/{userId} {
      allow read, write, update, delete: if
        // The user owns the document
        request.auth != null && request.auth.uid == userId
        // OR the user is an admin
        || isAdmin();
    }

    // Admins collection
    match /admins/{adminId} {
      // A user can read their own admin doc to check if it's there
      allow read: if request.auth != null && request.auth.uid == adminId;

      // Admins can create/update/delete any admin doc
      allow create, update, delete: if isAdmin();
    }
  }
}

#TODO:
- setup Google payment (pay-as-you-go) for cloudfunction