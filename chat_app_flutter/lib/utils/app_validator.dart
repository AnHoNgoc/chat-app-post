class AppValidator {
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a username";
    }
    if (value.length < 6 || value.length > 30) {
      return "Username must be between 6 and 30 characters";
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter an email";
    }
    if (value.length < 6 || value.length > 30) {
      return "Email must be between 6 and 30 characters";
    }
    RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(value)) {
      return "Please enter a valid email";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a password";
    }
    if (value.length < 6 || value.length > 30) {
      return "Password must be between 6 and 30 characters";
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String newPassword) {
    if (value == null || value.isEmpty) {
      return "Please confirm your new password";
    }
    if (value.length < 6 || value.length > 30) {
      return "Password must be between 6 and 30 characters";
    }

    if (value != newPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? isEmptyCheck(String? value) {
    if (value == null || value.isEmpty) {
      return "Please fill in the details";
    }
    if (value.length < 6 || value.length > 30) {
      return "Input must be between 6 and 30 characters";
    }
    return null;
  }
}