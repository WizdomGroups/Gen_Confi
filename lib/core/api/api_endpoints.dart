class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String me = '/auth/me';

  // Users
  static const String users = '/users';
  static const String updateMe = '/users/me';
  static const String uploadAvatar = '/users/me/avatar';
  static String userById(int id) => '/users/$id';

  // Static files
  static const String uploads = '/uploads';
}
