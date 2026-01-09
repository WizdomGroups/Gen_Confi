// DEPRECATED: Use ApiConfig from 'package:gen_confi/core/config/api_config.dart' instead
// This file is kept for backward compatibility but will be removed in future versions

import 'package:gen_confi/core/config/api_config.dart';

/// Legacy API Constants - Use [ApiConfig] instead
/// 
/// This class is deprecated. Please use [ApiConfig] for all API configurations.
@Deprecated('Use ApiConfig from core/config/api_config.dart instead')
class ApiConstants {
  /// Base URL - delegates to ApiConfig
  @Deprecated('Use ApiConfig.baseUrl instead')
  static String get baseUrl {
    ApiConfig.printConfig();
    return ApiConfig.baseUrl;
  }

  // Auth endpoints - delegates to ApiConfig
  @Deprecated('Use ApiConfig.login instead')
  static const String login = ApiConfig.login;
  
  @Deprecated('Use ApiConfig.signup instead')
  static const String signup = ApiConfig.signup;
  
  @Deprecated('Use ApiConfig.me instead')
  static const String me = ApiConfig.me;

  // User endpoints - delegates to ApiConfig
  @Deprecated('Use ApiConfig.users instead')
  static const String users = ApiConfig.users;
  
  @Deprecated('Use ApiConfig.userById() instead')
  static String userById(int id) => ApiConfig.userById(id);

  // Timeouts - delegates to ApiConfig
  @Deprecated('Use ApiConfig.connectTimeout instead')
  static const Duration connectTimeout = ApiConfig.connectTimeout;
  
  @Deprecated('Use ApiConfig.receiveTimeout instead')
  static const Duration receiveTimeout = ApiConfig.receiveTimeout;
}
