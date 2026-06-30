class ProfileName {
  static String getInitials(String? username) {
    if (username == null || username.trim().isEmpty) {
      return '?';
    }

    final parts = username.trim().split(RegExp(r'\s+'));

    if (parts.length >= 2) {
      final first = parts[0][0].toUpperCase();
      final second = parts[1][0].toUpperCase();
      return '$first$second';
    } else {
      return parts[0][0].toUpperCase();
    }
  }
}