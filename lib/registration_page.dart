import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'user_info_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Контроллеры — хранят текст
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // FocusNode — какое поле сейчас активно
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  // Скрыт ли пароль 
  bool _hidePassword = true;
  bool _hideConfirm = true;

  // Идёт ли сейчас сохранение в Firebase (чтобы не нажали кнопку дважды)
  bool _isLoading = false;

  // Освобождаем память
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();

    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  // Перекидывает
  void _nextField(FocusNode next) {
    FocusScope.of(context).requestFocus(next);
  }

  // кнопка "Submit"
  Future<void> _submit() async {
    // validate() вызывает validator у каждого поля
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // ---------- 1. FIREBASE REALTIME DATABASE ----------
      // Берём "папку" users в базе
      final usersRef = FirebaseDatabase.instance.ref('users');

      // push() создаёт новую запись с уникальным ключом
      final newUserRef = usersRef.push();

      // set() сохраняет данные в эту запись
      // (пароль в базу НЕ сохраняем — хранить пароли открытым текстом нельзя)
      await newUserRef.set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      // ---------- 2. SHAREDPREFERENCES (локально, как в СРСП 5) ----------
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', _nameController.text);
      await prefs.setString('phone', _phoneController.text);
      await prefs.setString('email', _emailController.text);
      await prefs.setString('userId', newUserRef.key!); // запоминаем ключ из Firebase

      // ---------- 3. УВЕДОМЛЕНИЕ ----------
      await NotificationService.show(
        title: 'Регистрация успешна!',
        body: 'Добро пожаловать, ${_nameController.text.trim()}',
      );

      if (!mounted) return;

      // ---------- 4. ПЕРЕХОД НА СТРАНИЦУ ПРОФИЛЯ ----------
      // Передаём ключ пользователя, чтобы профиль прочитал данные из Firebase
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserInfoPage(userId: newUserRef.key!),
        ),
      );
    } catch (e) {
      // Если что-то пошло не так (нет интернета, закрыты правила базы)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Form'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---------- ИМЯ ----------
            TextFormField(
              controller: _nameController,
              focusNode: _nameFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _nextField(_phoneFocus),
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                hintText: 'What do people call you?',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // ---------- ТЕЛЕФОН ----------
            TextFormField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _nextField(_emailFocus),
              // Разрешаем вводить только цифры
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                hintText: 'Where can we reach you?',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone number is required';
                }
                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return 'Only digits are allowed';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // ---------- EMAIL ----------
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _nextField(_passwordFocus),
              decoration: const InputDecoration(
                labelText: 'Email Address *',
                hintText: 'Enter an email address',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                // Простой шаблон: текст@текст.домен
                if (!RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$')
                    .hasMatch(value)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // ---------- ПАРОЛЬ ----------
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              obscureText: _hidePassword,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _nextField(_confirmFocus),
              decoration: InputDecoration(
                labelText: 'Password *',
                hintText: 'Enter the password',
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
                // Кнопка "глаз" — показать / скрыть пароль
                suffixIcon: IconButton(
                  icon: Icon(
                    _hidePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _hidePassword = !_hidePassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // ---------- ПОДТВЕРЖДЕНИЕ ПАРОЛЯ ----------
            TextFormField(
              controller: _confirmController,
              focusNode: _confirmFocus,
              obscureText: _hideConfirm,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Confirm Password *',
                hintText: 'Confirm the password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _hideConfirm ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _hideConfirm = !_hideConfirm;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ---------- КНОПКА ----------
            ElevatedButton(
              // Пока идёт сохранение — кнопка неактивна
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit Form', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
