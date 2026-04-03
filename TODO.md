# TODO: Add Date of Birth Field to Register Screen

## Plan Breakdown
1. [x] Update `lib/core/models/user_model.dart` - Add `dateOfBirth` field, constructor, getters (formatted date, age).
2. [x] Update `lib/features/auth/auth_provider.dart` - Add `dateOfBirth` param to `register()`, pass to UserModel.
3. [x] Update `lib/features/auth/register_screen.dart` - Add DOB picker field after phone, pass to register().
4. [ ] Test form validation, date picker, registration flow.
5. [ ] Run `flutter analyze` and hot reload to verify.

**Progress**: Core edits complete. Testing next.

