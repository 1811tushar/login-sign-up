import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Brand colors from your spec
class AppColors {
  static const Color darkNavyBlue = Color(0xFF202336); // Dark navy
  static const Color lightGray = Color(0xFFF2F4FB); // Light gray background
  static const Color vividPurple = Color(0xFF5750D6); // Accent
  static const Color white = Color(0xFFFFFFFF); // White
  static const Color midBlack = Color(0xFF111111); // Almost black
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
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.vividPurple,
            foregroundColor: AppColors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.vividPurple,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          labelStyle: const TextStyle(color: AppColors.midBlack),
          hintStyle: TextStyle(color: Colors.grey.shade600),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.vividPurple, width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
          ),
          errorStyle: const TextStyle(
              color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600),
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

  String? userType; // Member or Staff
  String? staffRole; // Dropdown if staff selected

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    /// The form (white card)
    Widget formCard = Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
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

            // Gym ID
            TextFormField(
              controller: gymIdCtrl,
              decoration: const InputDecoration(
                labelText: 'Gym ID *',
              ),
              validator: (val) => val == null || val.isEmpty ? 'Gym ID is required' : null,
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email *',
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Email is required';
                final emailRegex = RegExp(r'^.+@.+\..+$');
                if (!emailRegex.hasMatch(val)) return 'Enter valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password with show/hide
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
              validator: (val) =>
                  val != null && val.length >= 6 ? null : 'Password must be at least 6 characters',
            ),
            const SizedBox(height: 16),

            // Dropdown 1: Member or Staff
            DropdownButtonFormField<String>(
              value: userType,
              decoration: const InputDecoration(
                labelText: 'Account Type *',
              ),
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
                decoration: const InputDecoration(
                  labelText: 'Staff Role *',
                ),
                items: const [
                  DropdownMenuItem(value: 'Trainer', child: Text('Trainer')),
                  DropdownMenuItem(value: 'Owner', child: Text('Owner')),
                ],
                onChanged: (val) => setState(() => staffRole = val),
                validator: (val) => val == null ? 'Select staff role' : null,
              ),
            ],
            const SizedBox(height: 18),

            // Submit button
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isLogin ? 'Logging in...' : 'Signing up...')),
                  );
                }
              },
              child: Text(isLogin ? 'Sign In' : 'Sign Up'),
            ),
            const SizedBox(height: 8),

            // Toggle login/signup
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(isLogin ? "Don't have an account? " : 'Already have an account? ',
                    style: const TextStyle(color: AppColors.midBlack)),
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

    /// Photo block with gradient for readability
    Widget photoBlock = Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/gym .png'), // ✅ removed space in file name
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkNavyBlue.withOpacity(0.7), // stronger navy overlay
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
              // MOBILE: image on top, form below
              return Column(
                children: [
                  Expanded(flex: 45, child: photoBlock),
                  Expanded(
                    flex: 55,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: formCard,
                    ),
                  ),
                ],
              );
            }
            // WIDE: side-by-side
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
