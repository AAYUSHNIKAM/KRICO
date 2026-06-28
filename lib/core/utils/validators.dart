abstract class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    if (value.length > 50) return 'Password is too long';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    if (value.length < 2) return 'Name must be at least 2 characters';
    if (value.length > 50) return 'Name is too long';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final regex = RegExp(r'^[0-9]{10,15}$');
    if (!regex.hasMatch(value)) return 'Enter a valid phone number';
    return null;
  }

  static String? notEmpty(String? value, [String field = 'This field']) {
    if (value == null || value.isEmpty) return '$field is required';
    return null;
  }

  static String? number(String? value, [String field = 'Value']) {
    if (value == null || value.isEmpty) return '$field is required';
    if (double.tryParse(value) == null) return 'Enter a valid number';
    return null;
  }

  static String? positiveNumber(String? value, [String field = 'Value']) {
    if (value == null || value.isEmpty) return '$field is required';
    final num = double.tryParse(value);
    if (num == null) return 'Enter a valid number';
    if (num <= 0) return '$field must be positive';
    return null;
  }

  static String? integer(String? value, [String field = 'Value']) {
    if (value == null || value.isEmpty) return '$field is required';
    if (int.tryParse(value) == null) return 'Enter a valid whole number';
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.isEmpty) return 'URL is required';
    final regex = RegExp(r'^https?:\/\/[\w\-]+(\.[\w\-]+)+[/#?]?.*$');
    if (!regex.hasMatch(value)) return 'Enter a valid URL';
    return null;
  }
}
