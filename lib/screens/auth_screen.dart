import 'package:material_ui/material_ui.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.brandName});

  final String brandName;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _hidePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Authentication service will be connected in the next development step.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isLogin
              ? 'Form hazır. Giriş servisi henüz bağlanmadı.'
              : 'Form hazır. Kayıt servisi henüz bağlanmadı.',
        ),
        backgroundColor: const Color(0xFF242424),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF151515), Color(0xFF050505), Colors.black],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 430 : 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      widget.brandName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFF2F2F2),
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isLogin ? 'Tekrar hoş geldiniz' : 'Aramıza katılın',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFBDBDBD),
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 34),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF171717),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF303030)),
                      ),
                      child: Row(
                        children: [
                          _modeButton('Giriş yap', true),
                          _modeButton('Kayıt ol', false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!_isLogin) ...[
                            _fieldLabel('Ad soyad'),
                            const SizedBox(height: 9),
                            _input(
                              controller: _nameController,
                              hint: 'Adınızı ve soyadınızı girin',
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.trim().length < 3) {
                                  return 'Lütfen adınızı ve soyadınızı girin.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                          _fieldLabel('E-posta'),
                          const SizedBox(height: 9),
                          _input(
                            controller: _emailController,
                            hint: 'ornek@mail.com',
                            icon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                                  .hasMatch(email)) {
                                return 'Geçerli bir e-posta adresi girin.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _fieldLabel('Şifre'),
                          const SizedBox(height: 9),
                          _input(
                            controller: _passwordController,
                            hint: 'Şifrenizi girin',
                            icon: Icons.lock_outline,
                            obscureText: _hidePassword,
                            suffix: IconButton(
                              onPressed: () => setState(
                                () => _hidePassword = !_hidePassword,
                              ),
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF929292),
                                size: 20,
                              ),
                            ),
                            validator: (value) {
                              if ((value ?? '').length < 6) {
                                return 'Şifre en az 6 karakter olmalı.';
                              }
                              return null;
                            },
                          ),
                          if (!_isLogin) ...[
                            const SizedBox(height: 20),
                            _fieldLabel('Şifre tekrar'),
                            const SizedBox(height: 9),
                            _input(
                              controller: _confirmPasswordController,
                              hint: 'Şifrenizi tekrar girin',
                              icon: Icons.lock_outline,
                              obscureText: _hidePassword,
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'Şifreler eşleşmiyor.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            FormField<bool>(
                              validator: (value) {
                                if (value != true) {
                                  return 'Devam etmek için koşulları kabul edin.';
                                }
                                return null;
                              },
                              builder: (field) {
                                final accepted = field.value ?? false;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () => field.didChange(!accepted),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                            value: accepted,
                                            onChanged: field.didChange,
                                            activeColor: const Color(0xFFF1F1F1),
                                            checkColor: Colors.black,
                                            side: const BorderSide(
                                              color: Color(0xFF777777),
                                            ),
                                          ),
                                          const Expanded(
                                            child: Text(
                                              'Kullanım Koşulları ve Gizlilik Politikası’nı okudum ve kabul ediyorum.',
                                              style: TextStyle(
                                                color: Color(0xFFBDBDBD),
                                                fontSize: 12,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (field.hasError)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                          top: 2,
                                        ),
                                        child: Text(
                                          field.errorText!,
                                          style: const TextStyle(
                                            color: Color(0xFFCF7777),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                          if (_isLogin) ...[
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Şifre sıfırlama daha sonra eklenecek.',
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Şifremi unuttum',
                                  style: TextStyle(
                                    color: Color(0xFFBDBDBD),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ] else
                            const SizedBox(height: 28),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF1F1F1),
                                foregroundColor: const Color(0xFF090909),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                _isLogin ? 'GİRİŞ YAP' : 'HESAP OLUŞTUR',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Hesap güvenliğiniz için şifrenizi kimseyle paylaşmayın.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color.fromRGBO(255, 255, 255, 0.42),
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeButton(String label, bool loginMode) {
    final selected = _isLogin == loginMode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_isLogin != loginMode) {
            setState(() {
              _isLogin = loginMode;
              _formKey.currentState?.reset();
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEDEDED) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.black : const Color(0xFF999999),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFE4E4E4),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Color(0xFFF2F2F2), fontSize: 14),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF686868), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF999999), size: 19),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFF111111),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFF303030)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFBDBDBD), width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFB85C5C)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFB85C5C)),
        ),
      ),
    );
  }
}
