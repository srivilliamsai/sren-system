String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required.';
  }
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!emailRegex.hasMatch(value)) {
    return 'Enter a valid email address.';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required.';
  }
  if (value.length < 6) {
    return 'Use at least 6 characters.';
  }
  return null;
}

String? validateName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Name is required.';
  }
  return null;
}
