/// Shared form validators, used by the TextFormField `validator:` parameters
/// on every auth screen. Defined once so all screens enforce the same rules -
/// if a rule changes (e.g. minimum password length), it changes everywhere.
class Validators {
  /// Email must not be blank and must look like an email address.
  /// [field] customises the message (e.g. 'Student ID' on the login screen).
  static String? email(String? value, {String field = 'email'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $field';
    }
    if (!value.trim().contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Password must not be blank and must be at least 6 characters
  /// (Firebase's minimum). [label] customises the "please enter" message.
  static String? password(String? value, {String label = 'your password'}) {
    if (value == null || value.isEmpty) {
      return 'Please enter $label';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
