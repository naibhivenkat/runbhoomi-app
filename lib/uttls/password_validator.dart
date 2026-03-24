class PasswordValidator {

  static String? validate(String password) {

    if (password.length < 8) {
      return "Password must be 8 characters";
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return "Add uppercase letter";
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return "Add lowercase letter";
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return "Add number";
    }

    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return "Add special character";
    }

    return null;
  }
}