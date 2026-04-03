class ApiEndpoint {
  static const String authMe = "/auth/profile";
  static const String profileUpdate = "/auth/profile";
  static const String profilePassword = "/auth/profile/password";
  static const String profileAvatar = "/auth/profile/avatar";
  static const String authLogin = "/auth/login";
  static const String authGoogle = "/auth/google";
  static const String authRefresh = "/auth/refresh-access-token";

  static const String notificationList = "/notifications";
  static const String notificationDetail = "/notifications/{id}";
  static const String overview = "/overview";
  static const String whatsappMessageList = "/whatsapp-messages";
  static const String prayerLogList = "/prayer-logs";
  static const String prayerLogSummary = "/prayer-logs/summary";
  static const String userDevice = "/user-devices";
  static const String userDeviceStatus = "/user-devices/status";
  
  static const String apiKeyList = "/api-keys";
  static const String apiKeyDetail = "/api-keys/{id}";
  static const String apiKeyRevoke = "/api-keys/{id}/revoke";
  static const String apiKeyRotate = "/api-keys/{id}/rotate";
  static const String financeOverview = "/finances/overview";
  static const String financeAccountTypes = "/finances/account-types";
  static const String financeAccountSnapshots = "/finances/account-snapshots";
  static const String financeAccounts = "/finances/accounts";
}
