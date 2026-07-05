class Validators {
  static String? email(String? value, {String field = 'email'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $field';
    }
    if (!value.trim().contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

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
