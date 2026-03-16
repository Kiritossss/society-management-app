class ApiConstants {
  ApiConstants._();

  // Change to your server IP when testing on a physical device
  // static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  static const String baseUrl = 'http://localhost:8000'; // macOS / iOS simulator / web

  static const String apiVersion = '/api/v1';

  // Auth
  static const String societyRegister = '$apiVersion/auth/society/register';
  static const String userRegister = '$apiVersion/auth/register';
  static const String login = '$apiVersion/auth/login';

  // Units
  static const String units = '$apiVersion/units';
  static const String unitsBulk = '$apiVersion/units/bulk';

  // Members
  static const String members = '$apiVersion/members';

  // Timeouts
  static const int connectTimeout = 10000; // ms
  static const int receiveTimeout = 15000;
}
