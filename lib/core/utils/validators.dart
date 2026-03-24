class Validators {

  static String? validatePhone(String? value) {
    if (value == null || value.length < 10) {
      return "Enter valid phone";
    }
    return null;
  }

  static String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return "Required field";
    }
    return null;
  }

}