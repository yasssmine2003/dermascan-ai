# TODO: Remove Biometric Functionality

## Plan Breakdown
1. [x] Update `lib/features/auth/auth_provider.dart` - Remove `_biometricEnabled` field, getter, `toggleBiometric()`.
2. [x] Update `lib/features/auth/login_screen.dart` - Remove `_BiometricButton` widget and call.
3. [x] Update `lib/features/profile/profile_provider.dart` - Remove `_biometricEnabled`, getter, `toggleBiometric()`.
4. [ ] Update `lib/features/profile/profile_screen.dart` - Remove biometric _ToggleRow.
5. [ ] Run `flutter analyze` and test login/profile screens.

**Progress**: Step 1-3 done.

