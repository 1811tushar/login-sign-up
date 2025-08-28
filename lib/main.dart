
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // 🔥 Initialize Firebase
  runApp(const MyApp());
}

/// Brand colors
class AppColors {
  static const Color darkNavyBlue = Color(0xFF202336);
  static const Color lightGray = Color(0xFFF2F4FB);
  static const Color vividPurple = Color(0xFF5750D6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color midBlack = Color(0xFF111111);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gym Login & Signup UI',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.lightGray,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.vividPurple,
          primary: AppColors.vividPurple,
          secondary: AppColors.darkNavyBlue,
          surface: AppColors.white,
          onSurface: AppColors.midBlack,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: AppColors.darkNavyBlue,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
          bodyMedium: TextStyle(color: AppColors.midBlack, fontSize: 14),
        ),
      ),
      home: const AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  bool obscurePass = true;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController gymIdCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  String? userType;
  String? staffRole;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _handleAuth() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (isLogin) {
          // 🔹 Login
          await _auth.signInWithEmailAndPassword(
            email: emailCtrl.text.trim(),
            password: passCtrl.text.trim(),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login successful!")),
          );
        } else {
          // 🔹 Sign Up
          UserCredential userCred = await _auth.createUserWithEmailAndPassword(
            email: emailCtrl.text.trim(),
            password: passCtrl.text.trim(),
          );

          // Send email verification
          await userCred.user?.sendEmailVerification();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Signup successful! Please verify email.")),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.message}")),
        );
      }
    }
  }

  Future<void> _resetPassword() async {
    if (emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter your email to reset password")),
      );
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: emailCtrl.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    /// Form Card
    Widget formCard = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavyBlue.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLogin ? 'Welcome Our GYM' : 'Create Account',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: gymIdCtrl,
              decoration: const InputDecoration(labelText: 'Gym ID *'),
              validator: (val) => val == null || val.isEmpty ? 'Gym ID is required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email *'),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Email is required';
                final emailRegex = RegExp(r'^.+@.+\..+$');
                if (!emailRegex.hasMatch(val)) return 'Enter valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: passCtrl,
              obscureText: obscurePass,
              decoration: InputDecoration(
                labelText: 'Password *',
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePass ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.darkNavyBlue,
                  ),
                  onPressed: () => setState(() => obscurePass = !obscurePass),
                ),
              ),
              validator: (val) => val != null && val.length >= 6
                  ? null
                  : 'Password must be at least 6 characters',
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: userType,
              decoration: const InputDecoration(labelText: 'Account Type *'),
              items: const [
                DropdownMenuItem(value: 'Member', child: Text('Member')),
                DropdownMenuItem(value: 'Staff', child: Text('Staff')),
              ],
              onChanged: (val) => setState(() {
                userType = val;
                staffRole = null;
              }),
              validator: (val) => val == null ? 'Select account type' : null,
            ),
            if (userType == 'Staff') ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: staffRole,
                decoration: const InputDecoration(labelText: 'Staff Role *'),
                items: const [
                  DropdownMenuItem(value: 'Trainer', child: Text('Trainer')),
                  DropdownMenuItem(value: 'Owner', child: Text('Owner')),
                ],
                onChanged: (val) => setState(() => staffRole = val),
                validator: (val) => val == null ? 'Select staff role' : null,
              ),
            ],
            const SizedBox(height: 18),

            ElevatedButton(
              onPressed: _handleAuth,
              child: Text(isLogin ? 'Sign In' : 'Sign Up'),
            ),
            const SizedBox(height: 8),

            if (isLogin)
              TextButton(
                onPressed: _resetPassword,
                child: const Text("Forgot Password?"),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(isLogin
                    ? "Don't have an account? "
                    : 'Already have an account? '),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(isLogin ? 'Sign Up' : 'Login'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    /// Background
    Widget photoBlock = Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/gym.png'), // ✅ fixed asset path
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkNavyBlue.withOpacity(0.7),
              AppColors.darkNavyBlue.withOpacity(0.9),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (!isWide) {
              return Column(
                children: [
                  Expanded(flex: 45, child: photoBlock),
                  Expanded(
                    flex: 55,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: formCard,
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(flex: 5, child: photoBlock),
                Expanded(
                  flex: 5,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: formCard,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
