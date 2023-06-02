class UserPreferences {
  UserPreferences({
    required this.userId,
    required this.fcmTokens,
  });

  final String userId;
  final List<String> fcmTokens;
}
