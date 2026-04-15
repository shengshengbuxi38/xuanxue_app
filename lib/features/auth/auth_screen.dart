import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();
  bool _isRegister = false;
  String? _error;
  bool _loading = false;

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.length < 2) { setState(() => _error = '用户名至少2个字符'); return; }
    if (password.length < 6) { setState(() => _error = '密码至少6位'); return; }
    if (_isRegister && password != _password2Controller.text) {
      setState(() => _error = '两次密码不一致'); return;
    }

    setState(() { _error = null; _loading = true; });

    final auth = ref.read(authProvider.notifier);
    final ok = _isRegister
        ? await auth.register(username, password)
        : await auth.login(username, password);

    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) {
      setState(() => _error = _isRegister ? '用户名已存在' : '用户名或密码错误');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Text('☯', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 8),
                Text('玄学命理', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 32),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: '用户名', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '密码', border: OutlineInputBorder()),
                ),
                if (_isRegister) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _password2Controller,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: '确认密码', border: OutlineInputBorder()),
                  ),
                ],
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(_isRegister ? '注册' : '登录'),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() { _isRegister = !_isRegister; _error = null; }),
                  child: Text(_isRegister ? '已有账号？去登录' : '没有账号？去注册'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
