class Validators {
// reusable checks for form fields so every screen validates the same way

  static String? email(String? value, {String field = 'email'}) {
  // check an email box, returns an error message or null if its fine
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $field';
      // box is empty
    }
    if (!value.trim().contains('@')) {
      return 'Please enter a valid email';
      // no @ so its not an email
    }
    return null;
    // passed all checks
  }

  static String? password(String? value, {String label = 'your password'}) {
  // check a password box, returns an error message or null if its fine
    if (value == null || value.isEmpty) {
      return 'Please enter $label';
      // box is empty
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
      // too short
    }
    return null;
    // passed all checks
  }
}
