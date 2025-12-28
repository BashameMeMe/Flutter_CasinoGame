import 'package:flutter/material.dart';
import '../core/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final AuthService auth = AuthService();

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide =
        Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(_controller);
    _controller.forward();
  }

  Future<void> register() async {
    setState(() => loading = true);
    String? res = await auth.registerUser(
      emailCtrl.text.trim(),
      passCtrl.text.trim(),
      userCtrl.text.trim(),
    );
    setState(() => loading = false);

    if (res != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res)));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '📝 REGISTER',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: userCtrl,
                      decoration: const InputDecoration(labelText: 'Username'),
                    ),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: passCtrl,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: loading ? null : register,
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('REGISTER'),
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
