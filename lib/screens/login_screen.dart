import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/localization.dart'; // Tambahkan import ini

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  bool _isLogin = true;
  bool _isLoading = false;
  String _errorMessage = '';

  void _submit() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        final user = await _authService.signInWithEmailPassword(
            email: _email, password: _password);

        if (user != null) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        final user = await _authService.registerWithEmailPassword(
            email: _email, password: _password);

        if (user != null) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1200;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: isWideScreen ? 400 : double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isWideScreen ? 32 : 16,
                vertical: 32,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Center(
                      child: Image.asset(
                        'assets/logoweather.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                    SizedBox(height: 16),

                    Center(
                      child: Text(
                        _isLogin
                            ? context.translate('welcome_back')
                            : context.translate('create_account'),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Error Message
                    if (_errorMessage.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            color: colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Email TextField
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: context.translate('email'),
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return context.translate('invalid_email');
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _email = value ?? '';
                      },
                    ),
                    SizedBox(height: 16),

                    // Password TextField
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: context.translate('password'),
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return context.translate('password_too_short');
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _password = value ?? '';
                      },
                    ),
                    SizedBox(height: 24),

                    // Login/Register Button
                    _isLoading
                        ? Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    )
                        : FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _submit();
                        }
                      },
                      child: Text(
                        _isLogin
                            ? context.translate('login')
                            : context.translate('register'),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Toggle Login/Register
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _errorMessage = '';
                        });
                      },
                      child: Text(
                        _isLogin
                            ? context.translate('create_account')
                            : context.translate('already_have_account'),
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
}