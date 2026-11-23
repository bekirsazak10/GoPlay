import 'package:material_ui/material_ui.dart';

bool _isValidEmailAddress(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty || email.length > 254) return false;

  final parts = email.split('@');
  if (parts.length != 2) return false;

  final localPart = parts.first;
  if (localPart.length > 64 ||
      localPart.startsWith('.') ||
      localPart.endsWith('.') ||
      localPart.contains('..')) {
    return false;
  }

  return RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:[.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$",
  ).hasMatch(email);
}

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
  bool _hideConfirmPassword = true;

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
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                      style: const TextStyle(
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
                    AutofillGroup(
                      child: Form(
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
                                autofillHints: const [AutofillHints.name],
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  final nameParts = (value ?? '')
                                      .trim()
                                      .split(RegExp(r'\s+'))
                                      .where((part) => part.isNotEmpty);
                                  if (nameParts.length < 2) {
                                    return 'Adınızı ve soyadınızı ayrı ayrı girin.';
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
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              autofillHints: [
                                _isLogin
                                    ? AutofillHints.username
                                    : AutofillHints.newUsername,
                              ],
                              validator: (value) {
                                if (!_isValidEmailAddress(value)) {
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
                              textInputAction: _isLogin
                                  ? TextInputAction.done
                                  : TextInputAction.next,
                              autocorrect: false,
                              enableSuggestions: false,
                              autofillHints: [
                                _isLogin
                                    ? AutofillHints.password
                                    : AutofillHints.newPassword,
                              ],
                              onFieldSubmitted:
                                  _isLogin ? (_) => _submit() : null,
                              suffix: IconButton(
                                tooltip: _hidePassword
                                    ? 'Şifreyi göster'
                                    : 'Şifreyi gizle',
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
                              onChanged: _isLogin ? null : (_) => setState(() {}),
                              validator: (value) {
                                if ((value ?? '').length < 6) {
                                  return 'Şifre en az 6 karakter olmalı.';
                                }
                                return null;
                              },
                            ),
                            _passwordStrengthIndicator(),
                            if (!_isLogin) ...[
                              const SizedBox(height: 20),
                              _fieldLabel('Şifre tekrar'),
                              const SizedBox(height: 9),
                              _input(
                                controller: _confirmPasswordController,
                                hint: 'Şifrenizi tekrar girin',
                                icon: Icons.lock_outline,
                                obscureText: _hideConfirmPassword,
                                textInputAction: TextInputAction.done,
                                autocorrect: false,
                                enableSuggestions: false,
                                autofillHints: const [AutofillHints.newPassword],
                                onFieldSubmitted: (_) => _submit(),
                                suffix: IconButton(
                                  tooltip: _hideConfirmPassword
                                      ? 'Şifreyi göster'
                                      : 'Şifreyi gizle',
                                  onPressed: () => setState(
                                    () => _hideConfirmPassword =
                                        !_hideConfirmPassword,
                                  ),
                                  icon: Icon(
                                    _hideConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF929292),
                                    size: 20,
                                  ),
                                ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              activeColor:
                                                  const Color(0xFFF1F1F1),
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
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'Hesap güvenliğiniz için şifrenizi kimseyle paylaşmayın.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.42),
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

  int get _passwordStrength {
    final password = _passwordController.text;
    var score = 0;

    if (password.length >= 8) score++;
    if (RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[A-Z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;

    return score;
  }

  String get _passwordStrengthLabel {
    final score = _passwordStrength;
    if (score <= 1) return 'Zayıf';
    if (score <= 3) return 'Orta';
    return 'Güçlü';
  }

  Color get _passwordStrengthColor {
    final score = _passwordStrength;
    if (score <= 1) return const Color(0xFFB66C6C);
    if (score <= 3) return const Color(0xFFC2A46A);
    return const Color(0xFF8DAF94);
  }

  Widget _passwordStrengthIndicator() {
    final password = _passwordController.text;
    if (_isLogin || password.isEmpty) return const SizedBox.shrink();

    final score = _passwordStrength;
    final label = _passwordStrengthLabel;
    final color = _passwordStrengthColor;
    final requirements = <MapEntry<String, bool>>[
      MapEntry('En az 8 karakter', password.length >= 8),
      MapEntry(
        'Büyük ve küçük harf',
        RegExp(r'[a-z]').hasMatch(password) &&
            RegExp(r'[A-Z]').hasMatch(password),
      ),
      MapEntry('En az bir rakam', RegExp(r'\d').hasMatch(password)),
      MapEntry('Özel karakter', RegExp(r'[^A-Za-z0-9]').hasMatch(password)),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: 'Şifre gücü: $label',
            child: ExcludeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      4,
                      (index) => Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
                          decoration: BoxDecoration(
                            color: index < score
                                ? color
                                : const Color(0xFF303030),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Şifre gücü: $label',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: requirements
                .map(
                  (requirement) => _passwordRequirement(
                    requirement.key,
                    requirement.value,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _passwordRequirement(String label, bool isMet) {
    final color = isMet
        ? const Color(0xFF8DAF94)
        : const Color(0xFF777777);

    return SizedBox(
      width: 150,
      child: Semantics(
        label: '$label: ' + (isMet ? 'tamamlandı' : 'eksik'),
        child: ExcludeSemantics(
          child: Row(
            children: [
              Icon(
                isMet ? Icons.check_circle : Icons.radio_button_unchecked,
                color: color,
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeButton(String label, bool loginMode) {
    final selected = _isLogin == loginMode;
    return Expanded(
      child: Semantics(
        label: label,
        button: true,
        selected: selected,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            if (_isLogin != loginMode) {
              FocusScope.of(context).unfocus();
              // Do not keep passwords in the form when changing auth modes.
              _passwordController.clear();
              _confirmPasswordController.clear();
              setState(() {
                _isLogin = loginMode;
                _hidePassword = true;
                _hideConfirmPassword = true;
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
            child: ExcludeSemantics(
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
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction textInputAction = TextInputAction.next,
    bool autocorrect = true,
    bool enableSuggestions = true,
    Iterable<String>? autofillHints,
    bool obscureText = false,
    ValueChanged<String>? onFieldSubmitted,
    Widget? suffix,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      autofillHints: autofillHints,
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
