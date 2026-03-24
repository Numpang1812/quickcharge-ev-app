import 'package:flutter/material.dart';

class AuthView extends StatefulWidget {
  final Function(Map<String, dynamic> user, String token) onAuthSuccess;

  const AuthView({super.key, required this.onAuthSuccess});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  bool isLogin = true;
  String email = '';
  String password = '';
  String name = '';
  String error = '';
  bool loading = false;

  final _formKey = GlobalKey<FormState>();

  // Theme colors (matched to React)
  static const Color primaryColor = Color(0xFF10B981);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textColor = Color(0xFF1E293B);
  static const Color textMutedColor = Color(0xFF64748B);

  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      error = '';
      loading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1)); // placeholder
      widget.onAuthSuccess({'email': email}, 'mock_token');
    } catch (e) {
      setState(() {
        error = 'Authentication failed';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Back Button Row
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: textColor,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // Logo + Title
                      Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.bolt,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "SmartCharge KH",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Powering your journey across Cambodia",
                            style: TextStyle(
                              color: textMutedColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Toggle
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  _buildToggleButton("Login", true),
                                  _buildToggleButton("Sign Up", false),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Form
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  if (!isLogin) _buildNameField(),
                                  _buildEmailField(),
                                  _buildPasswordField(),
                                  if (error.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        error,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 20),
                                  _buildSubmitButton(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text.rich(
                        TextSpan(
                          text: "By continuing, you agree to our ",
                          style: TextStyle(color: textMutedColor, fontSize: 12),
                          children: [
                            TextSpan(
                              text: "Terms of Service",
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: " and "),
                            TextSpan(
                              text: "Privacy Policy",
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, bool value) {
    final active = isLogin == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isLogin = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: active ? primaryColor : textMutedColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return _buildInput(
      label: "Full Name",
      icon: Icons.person,
      onChanged: (v) => name = v,
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }

  Widget _buildEmailField() {
    return _buildInput(
      label: "Email Address",
      icon: Icons.mail,
      onChanged: (v) => email = v,
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }

  Widget _buildPasswordField() {
    return _buildInput(
      label: "Password",
      icon: Icons.lock,
      obscure: true,
      onChanged: (v) => password = v,
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }

  Widget _buildInput({
    required String label,
    required IconData icon,
    bool obscure = false,
    required Function(String) onChanged,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textMutedColor,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            obscureText: obscure,
            validator: validator,
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: backgroundColor,
              prefixIcon: Icon(icon, color: textMutedColor),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: loading ? null : handleSubmit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              loading
                  ? "Processing..."
                  : (isLogin ? "Login" : "Create Account"),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!loading) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}
