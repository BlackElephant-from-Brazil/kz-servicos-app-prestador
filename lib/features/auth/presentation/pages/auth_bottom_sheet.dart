import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kz_servicos_prestador/core/constants/app_colors.dart';
import 'package:kz_servicos_prestador/core/utils/phone_input_formatter.dart';
import 'package:kz_servicos_prestador/features/auth/presentation/pages/login_page.dart';
import 'package:kz_servicos_prestador/features/auth/presentation/pages/registration_page.dart';
import 'package:kz_servicos_prestador/features/profile/data/models/mock_provider.dart';

class AuthBottomSheet extends StatefulWidget {
  final AuthMode initialMode;
  final ValueChanged<ProviderType> onLoginSuccess;

  const AuthBottomSheet({
    super.key,
    required this.initialMode,
    required this.onLoginSuccess,
  });

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet> {
  late AuthMode _mode;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  String? _loginError;
  ProviderType _selectedType = ProviderType.driver;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'QuasimodoSemiBold',
        color: AppColors.textSecondary,
      ),
      prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
      filled: true,
      fillColor: const Color(0xFFF7F7F8),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: AppColors.highlight, width: 1.5),
      ),
    );
  }

  void _submit() {
    if (_mode == AuthMode.login) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final accounts = [
        MockProvider.driverSample,
        MockProvider.providerSample,
      ];
      final match = accounts
          .where((a) => a.email == email && a.password == password)
          .toList();
      setState(() => _loginError = null);
      Navigator.of(context).pop();
      if (match.isNotEmpty) {
        widget.onLoginSuccess(match.first.providerType);
      } else {
        widget.onLoginSuccess(ProviderType.driver);
      }
    } else if (_mode == AuthMode.register) {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RegistrationPage(
            onComplete: widget.onLoginSuccess,
            providerType: _selectedType,
          ),
        ),
      );
    }
  }

  String get _title => switch (_mode) {
        AuthMode.login => 'Login',
        AuthMode.register => 'Cadastre-se',
        AuthMode.forgotPassword => 'Recuperar senha',
      };

  String get _subtitle => switch (_mode) {
        AuthMode.login => 'Acesse sua conta',
        AuthMode.register => 'Crie sua conta',
        AuthMode.forgotPassword => 'Informe seu e-mail',
      };

  String get _primaryLabel => switch (_mode) {
        AuthMode.login => 'Login',
        AuthMode.register => 'Registrar-se',
        AuthMode.forgotPassword => 'Enviar e-mail',
      };

  Widget _buildProviderTypeToggle() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _toggleButton('Motorista', ProviderType.driver),
          const SizedBox(width: 4),
          _toggleButton('Prestador de Serviço', ProviderType.serviceProvider),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, ProviderType type) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.highlight : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'OutfitBlack',
                fontSize: 13,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 36),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Column(
                  key: ValueKey(_mode),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: const TextStyle(
                        fontFamily: 'OutfitBlack',
                        fontSize: 24,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle,
                      style: const TextStyle(
                        fontFamily: 'QuasimodoSemiBold',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_mode == AuthMode.register) _buildProviderTypeToggle(),
              if (_mode == AuthMode.register) ...[
                TextField(
                  controller: _nameController,
                  decoration: _inputDecoration(
                      'Nome completo', Icons.person_outline),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _cpfController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration:
                      _inputDecoration('CPF', Icons.badge_outlined),
                ),
                const SizedBox(height: 14),
              ],
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    _inputDecoration('E-mail', Icons.email_outlined),
              ),
              if (_mode == AuthMode.register) ...[
                const SizedBox(height: 14),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [PhoneInputFormatter()],
                  decoration: _inputDecoration(
                      'Telefone', Icons.phone_outlined),
                ),
              ],
              if (_mode != AuthMode.forgotPassword) ...[
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration(
                          'Senha', Icons.lock_outlined)
                      .copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
              ],
              if (_loginError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _loginError!,
                  style: TextStyle(
                    fontFamily: 'QuasimodoSemiBold',
                    fontSize: 13,
                    color: Colors.red.shade400,
                  ),
                ),
              ],
              if (_mode == AuthMode.login) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => setState(
                        () => _mode = AuthMode.forgotPassword),
                    child: const Text(
                      'Esqueceu a senha?',
                      style: TextStyle(
                        fontFamily: 'QuasimodoSemiBold',
                        fontSize: 13,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.highlight,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                        fontFamily: 'OutfitBlack', fontSize: 16),
                  ),
                  child: Text(_primaryLabel),
                ),
              ),
              if (_mode != AuthMode.forgotPassword) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'ou',
                        style: TextStyle(
                          fontFamily: 'QuasimodoSemiBold',
                          fontSize: 13,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              if (_mode == AuthMode.forgotPassword)
                const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _loginError = null;
                    _mode = switch (_mode) {
                      AuthMode.login => AuthMode.register,
                      AuthMode.register => AuthMode.login,
                      AuthMode.forgotPassword => AuthMode.login,
                    };
                  }),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                        fontFamily: 'OutfitBlack', fontSize: 16),
                  ),
                  child: Text(switch (_mode) {
                    AuthMode.login => 'Registrar-se',
                    AuthMode.register => 'Já tenho conta',
                    AuthMode.forgotPassword => 'Fazer login',
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
