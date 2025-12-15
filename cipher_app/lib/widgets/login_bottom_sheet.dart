import 'package:cipher_app/l10n/app_localizations.dart';
import 'package:cipher_app/providers/auth_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginBottomSheet extends StatefulWidget {
  const LoginBottomSheet({super.key});

  @override
  State<LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends State<LoginBottomSheet>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animationController;

  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);

    // Listen for authentication changes after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authProvider = context.read<AuthProvider>();
      _authProvider.addListener(_authListener);
    });
  }

  void _authListener() {
    if (_authProvider.isAuthenticated) {
      // Close the bottom sheet upon successful login
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authProvider.removeListener(_authListener);
    super.dispose();
  }

  void _toggleObscure() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o e-mail';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe a senha';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BottomSheet(
      animationController: _animationController,
      onClosing: () {
        // If not authenticated, sign in anonymously TODO - fix this
        if (!context.read<AuthProvider>().isAuthenticated) {
          context.read<AuthProvider>().signInAnonymously();
        }
      },
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Login Title section
                SizedBox(
                  width:
                      MediaQuery.of(context).size.width *
                      0.6, // 70% of screen width
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.loginOrSignUp,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.loginDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Login Method Section
                SizedBox(
                  child: Column(
                    children: [
                      // Email Login
                      TextButton(
                        onPressed: () {}, // TODO Implement Email Login
                        child: Text(AppLocalizations.of(context)!.emailLogin),
                      ),
                      // Phone Login
                      TextButton(
                        onPressed: () {}, // TODO Implement Phone Login
                        child: Text(AppLocalizations.of(context)!.phoneLogin),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Google Login
                          IconButton(
                            onPressed: () {}, // TODO Implement Google Login
                            icon: Icon(Icons.g_mobiledata),
                          ),

                          // Facebook Login
                          IconButton(
                            onPressed: () {}, // TODO Implement Facebook Login
                            icon: Icon(Icons.facebook),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Terms and Privacy Section
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: AppLocalizations.of(
                            context,
                          )!.accountCreationPrefix,
                        ),
                        TextSpan(
                          text: AppLocalizations.of(
                            context,
                          )!.termsAndConditions,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // TODO Navigate to Terms & Conditions
                            },
                        ),
                        TextSpan(
                          text: AppLocalizations.of(
                            context,
                          )!.accountCreationMiddle,
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context)!.privacyPolicy,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // TODO Navigate to Privacy Policy
                            },
                        ),
                        TextSpan(
                          text: AppLocalizations.of(
                            context,
                          )!.accountCreationSuffix,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
