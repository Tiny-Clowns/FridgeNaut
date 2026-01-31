# flutter_fridge_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### Android Permissions
`POST_NOTIFICATIONS` - Required to send Notifications (Android 13+, before v13 this permission is auto-accepted)
`RECEIVE_BOOT_COMPLETED` - Optional but used. Needed to reschedule notifications after device reboot. (Any Android version)