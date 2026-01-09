// DEPRECATED: Use ApiConfig from 'package:gen_confi/core/config/api_config.dart' instead
// This file is kept for backward compatibility but will be removed in future versions

import 'package:gen_confi/core/config/api_config.dart';

/// Legacy API Endpoints - Use [ApiConfig] instead
/// 
/// This class is deprecated. Please use [ApiConfig] for all API endpoints.
@Deprecated('Use ApiConfig from core/config/api_config.dart instead')
class ApiEndpoints {
  // Auth endpoints - delegates to ApiConfig
  @Deprecated('Use ApiConfig.login instead')
  static const String login = ApiConfig.login;
  
  @Deprecated('Use ApiConfig.signup instead')
  static const String signup = ApiConfig.signup;
  
  @Deprecated('Use ApiConfig.forgotPassword instead')
  static const String forgotPassword = ApiConfig.forgotPassword;
  
  @Deprecated('Use ApiConfig.resetPassword instead')
  static const String resetPassword = ApiConfig.resetPassword;
  
  @Deprecated('Use ApiConfig.me instead')
  static const String me = ApiConfig.me;

  // User endpoints - delegates to ApiConfig
  @Deprecated('Use ApiConfig.users instead')
  static const String users = ApiConfig.users;
  
  @Deprecated('Use ApiConfig.updateMe instead')
  static const String updateMe = ApiConfig.updateMe;
  
  @Deprecated('Use ApiConfig.uploadAvatar instead')
  static const String uploadAvatar = ApiConfig.uploadAvatar;
  
  @Deprecated('Use ApiConfig.userById() instead')
  static String userById(int id) => ApiConfig.userById(id);

  // Static files - delegates to ApiConfig
  @Deprecated('Use ApiConfig.uploads instead')
  static const String uploads = ApiConfig.uploads;
}
