/// Stub Platform class for web
/// This file is used when dart:io is not available (on web)
class Platform {
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static bool get isWindows => false;
  static bool get isLinux => false;
  static bool get isMacOS => false;
}
