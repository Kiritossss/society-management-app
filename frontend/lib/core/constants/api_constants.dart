class ApiConstants {
  ApiConstants._();

  // Change to your server IP when testing on a physical device
  // static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  static const String baseUrl = 'http://localhost:8000'; // macOS / iOS simulator / web

  static const String apiVersion = '/api/v1';

  // Auth
  static const String login = '$apiVersion/auth/login';
  static const String activate = '$apiVersion/auth/activate';
  static const String lookup = '$apiVersion/auth/lookup';

  // Units
  static const String units = '$apiVersion/units';
  static const String unitsBulk = '$apiVersion/units/bulk';

  // Members
  static const String members = '$apiVersion/members';

  // Visitors
  static const String visitors = '$apiVersion/visitors';
  static const String visitorPreApprove = '$apiVersion/visitors/pre-approve';
  static const String visitorLogEntry = '$apiVersion/visitors/log-entry';
  static const String visitorPending = '$apiVersion/visitors/pending';
  static const String visitorPreApproved = '$apiVersion/visitors/pre-approved';

  // Notices
  static const String notices = '$apiVersion/notices';

  // Timeouts
  static const int connectTimeout = 10000; // ms
  static const int receiveTimeout = 15000;
}
