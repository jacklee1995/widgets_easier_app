import 'package:flutter/material.dart';
import 'package:widgets_easier/widgets_easier.dart';

import 'dialogs/failure_dialog.dart';
import 'dialogs/success_dialog.dart';
import 'login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginController loginManager = LoginController();

  Future<void> handleLogin(BuildContext context) async {
    final String username = usernameController.text;
    final String password = passwordController.text;
    final handle = WeLoading.service(context, text: '登录中');
    final Map<String, dynamic> result;
    try {
      result = await loginManager.simulateLogin(username, password);
    } finally {
      handle.close();
    }
    if (!context.mounted) return;
    final bool ok = result['status'] == true;
    await showDialog<void>(
      context: context,
      builder: (_) => ok
          ? SuccessDialog(result['data'] as String)
          : FailureDialog(result['data'] as String),
    );
    if (ok && context.mounted) {
      Navigator.pushReplacementNamed(context, '/login-success');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: '输入你的账号',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_circle),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: '输入你的密码',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            WeButton(
              text: '登录',
              type: SemanticEnum.primary,
              variant: WeButtonVariant.plain,
              round: true,
              block: true,
              onPressed: () => handleLogin(context),
            ),
          ],
        ),
      ),
    );
  }
}
