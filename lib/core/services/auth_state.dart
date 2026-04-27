import 'package:kz_servicos_prestador/features/profile/data/models/mock_provider.dart';

class AuthState {
  static bool _isAuthenticated = false;
  static ProviderType? _providerType;
  static String? _userId;
  static String? _userName;
  static String? _userEmail;
  static String? _providerProfileId;
  static String? _driverProfileId;

  static bool get isAuthenticated => _isAuthenticated;
  static ProviderType? get providerType => _providerType;
  static String? get userId => _userId;
  static String? get userName => _userName;
  static String? get userEmail => _userEmail;
  static String? get providerProfileId => _providerProfileId;
  static String? get driverProfileId => _driverProfileId;

  static void login({
    required ProviderType providerType,
    required String userId,
    required String name,
    required String email,
    required String providerProfileId,
    String? driverProfileId,
  }) {
    _isAuthenticated = true;
    _providerType = providerType;
    _userId = userId;
    _userName = name;
    _userEmail = email;
    _providerProfileId = providerProfileId;
    _driverProfileId = driverProfileId;
  }

  static void logout() {
    _isAuthenticated = false;
    _providerType = null;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _providerProfileId = null;
    _driverProfileId = null;
  }

  static bool get isDriver => _providerType == ProviderType.driver;
  static bool get isServiceProvider => _providerType == ProviderType.serviceProvider;
}