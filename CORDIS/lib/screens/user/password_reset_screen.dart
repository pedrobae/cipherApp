// ignore_for_file: unused_import, unused_field, unused_local_variable, prefer_final_fields

import 'package:cordis/l10n/app_localizations.dart';
import 'package:cordis/providers/my_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PasswordResetScreen extends StatefulWidget {
  final String? loginEmail;

  const PasswordResetScreen({super.key, this.loginEmail});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  late TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _sentResetMail = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.loginEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container();

    // Consumer<MyAuthProvider>(
    //   builder: (context, authProvider, child) {
    //     return Scaffold(
    //       appBar: AppBar(
    //         title: Text(AppLocalizations.of(context)!.passwordReset),
    //       ),
    //       body: Padding(
    //         padding: const EdgeInsets.all(16.0),
    //         child: Column(
    //           spacing: 24,
    //           children: [
    //             Column(
    //               spacing: 8,
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Text(
    //                   AppLocalizations.of(context)!.email,
    //                   style: theme.textTheme.bodyMedium?.copyWith(
    //                     fontWeight: FontWeight.w500,
    //                   ),
    //                 ),
    //                 TextFormField(
    //                   controller: _emailController,
    //                   keyboardType: TextInputType.emailAddress,
    //                   textInputAction: TextInputAction.next,
    //                   autofocus: true,
    //                   maxLines: 1,
    //                   decoration: InputDecoration(
    //                     label: Text(AppLocalizations.of(context)!.email),
    //                     floatingLabelBehavior: FloatingLabelBehavior.never,
    //                     prefixIcon: Icon(
    //                       Icons.email,
    //                       color: colorScheme.primary,
    //                     ),
    //                     border: OutlineInputBorder(
    //                       borderRadius: BorderRadius.circular(0),
    //                     ),
    //                     focusedBorder: OutlineInputBorder(
    //                       borderRadius: BorderRadius.circular(0),
    //                       borderSide: BorderSide(
    //                         color: colorScheme.primary,
    //                         width: 2,
    //                       ),
    //                     ),
    //                     visualDensity: VisualDensity.compact,
    //                   ),
    //                   validator: _validateEmail,
    //                 ),
    //               ],
    //             ),
    //             Column(
    //               spacing: 8,
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Text(
    //                   AppLocalizations.of(context)!.password,
    //                   style: theme.textTheme.bodyMedium?.copyWith(
    //                     fontWeight: FontWeight.w500,
    //                   ),
    //                 ),
    //                 TextFormField(
    //                   controller: _passwordController,
    //                   obscureText: _obscurePassword,
    //                   textInputAction: TextInputAction.done,
    //                   maxLines: 1,
    //                   decoration: InputDecoration(
    //                     label: Text(AppLocalizations.of(context)!.password),
    //                     floatingLabelBehavior: FloatingLabelBehavior.never,
    //                     prefixIcon: Icon(
    //                       Icons.lock,
    //                       color: colorScheme.primary,
    //                     ),
    //                     suffixIcon: IconButton(
    //                       icon: Icon(
    //                         _obscurePassword
    //                             ? Icons.visibility_off
    //                             : Icons.visibility,
    //                         color: colorScheme.primary,
    //                       ),
    //                       onPressed: _toggleObscure,
    //                     ),
    //                     border: OutlineInputBorder(
    //                       borderRadius: BorderRadius.circular(0),
    //                     ),
    //                     focusedBorder: OutlineInputBorder(
    //                       borderRadius: BorderRadius.circular(0),
    //                       borderSide: BorderSide(
    //                         color: colorScheme.primary,
    //                         width: 2,
    //                       ),
    //                     ),
    //                     visualDensity: VisualDensity.compact,
    //                   ),
    //                   validator: _validatePassword,
    //                 ),
    //                 Center(
    //                   child: Column(
    //                     crossAxisAlignment: CrossAxisAlignment.center,
    //                     spacing: 0,
    //                     children: [
    //                       GestureDetector(
    //                         onTap: () {
    //                           Navigator.of(context).push(
    //                             MaterialPageRoute(
    //                               builder: (context) {
    //                                 return PasswordResetScreen(
    //                                   loginEmail: _emailController.text,
    //                                 );
    //                               },
    //                             ),
    //                           );
    //                         },
    //                         child: Text(
    //                           AppLocalizations.of(context)!.forgotPassword,
    //                           style: TextStyle(
    //                             color: colorScheme.primary,
    //                             fontWeight: FontWeight.bold,
    //                           ),
    //                         ),
    //                       ),
    //                       Text(
    //                         AppLocalizations.of(context)!.forgotPasswordSuffix,
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             if (authProvider.isLoading)
    //               const Padding(
    //                 padding: EdgeInsets.symmetric(vertical: 8),
    //                 child: CircularProgressIndicator(),
    //               ),
    //             if (authProvider.error != null)
    //               Padding(
    //                 padding: const EdgeInsets.only(bottom: 8),
    //                 child: Text(
    //                   authProvider.error!,
    //                   style: TextStyle(
    //                     color: colorScheme.error,
    //                     fontWeight: FontWeight.w600,
    //                   ),
    //                   textAlign: TextAlign.center,
    //                 ),
    //               ),
    //             SizedBox(
    //               width: double.infinity,
    //               child: ElevatedButton.icon(
    //                 icon: const Icon(Icons.login),
    //                 label: Text(
    //                   AppLocalizations.of(context)!.login,
    //                   style: theme.textTheme.labelLarge!.copyWith(
    //                     color: colorScheme.surface,
    //                   ),
    //                 ),
    //                 style: ElevatedButton.styleFrom(
    //                   backgroundColor: colorScheme.onSurface,
    //                   foregroundColor: colorScheme.surface,
    //                   shape: RoundedRectangleBorder(
    //                     borderRadius: BorderRadius.circular(0),
    //                   ),
    //                   elevation: 2,
    //                 ),
    //                 onPressed: authProvider.isLoading
    //                     ? null
    //                     : () {
    //                         if (_formKey.currentState?.validate() ?? false) {
    //                           authProvider.signInWithEmail(
    //                             _emailController.text,
    //                             _passwordController.text,
    //                           );
    //                         }
    //                       },
    //               ),
    //             ),
    //             // Sign Up Link
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 Text(
    //                   AppLocalizations.of(context)!.accountCreationPrefix,
    //                   style: TextStyle(color: colorScheme.onSurfaceVariant),
    //                 ),
    //                 GestureDetector(
    //                   onTap: () => Navigator.of(context).pushNamed('/signup'),
    //                   child: Text(
    //                     AppLocalizations.of(context)!.accountCreationSuffix,
    //                     style: TextStyle(
    //                       color: colorScheme.primary,
    //                       fontWeight: FontWeight.bold,
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             // Google Sign-In Button
    //             SizedBox(
    //               width: double.infinity,
    //               child: ElevatedButton.icon(
    //                 icon: const Icon(Icons.g_mobiledata, size: 24),
    //                 label: Text(
    //                   'Entrar com Google',
    //                   style: theme.textTheme.labelLarge!.copyWith(
    //                     color: colorScheme.onSecondaryContainer,
    //                     fontWeight: FontWeight.bold,
    //                   ),
    //                 ),
    //                 style: ElevatedButton.styleFrom(
    //                   backgroundColor: colorScheme.secondaryContainer,
    //                   foregroundColor: colorScheme.onSecondaryContainer,
    //                   shape: RoundedRectangleBorder(
    //                     borderRadius: BorderRadius.circular(16),
    //                   ),
    //                   elevation: 2,
    //                 ),
    //                 onPressed: authProvider.isLoading
    //                     ? null
    //                     : () => authProvider.signInWithGoogle(),
    //               ),
    //             ),
    //             // SizedBox(
    //             //   width: double.infinity,
    //             //   child: ElevatedButton.icon(
    //             //     icon: const Icon(Icons.person_outline),
    //             //     label: Text(
    //             //       'Entrar Anonimamente',
    //             //       style: theme.textTheme.labelLarge!.copyWith(
    //             //         color: colorScheme.onPrimary,
    //             //         fontWeight: FontWeight.bold,
    //             //       ),
    //             //     ),
    //             //     style: ElevatedButton.styleFrom(
    //             //       backgroundColor: colorScheme.primary,
    //             //       foregroundColor: colorScheme.onPrimary,
    //             //       shape: RoundedRectangleBorder(
    //             //         borderRadius: BorderRadius.circular(16),
    //             //       ),
    //             //       elevation: 2,
    //             //     ),
    //             //     onPressed: authProvider.isLoading
    //             //         ? null
    //             //         : () => authProvider.signInAnonymously(),
    //             //   ),
    //             // ),
    //           ],
    //         ),
    //       ),
    //     );
    //   },
    // );
  }
}
