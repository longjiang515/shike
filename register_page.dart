import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // 表单验证状态
  bool _isUsernameValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;

  @override
  void initState() {
    super.initState();
    // 添加实时验证监听
    _usernameController.addListener(_validateUsername);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  void _validateUsername() {
    final username = _usernameController.text;
    setState(() {
      _isUsernameValid = username.length >= 3;
    });
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _isPasswordValid = password.length >= 6;
    });
    _validateConfirmPassword();
  }

  void _validateConfirmPassword() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    setState(() {
      _isConfirmPasswordValid = password == confirmPassword && password.isNotEmpty;
    });
  }

  Future<void> _register() async {
    // 表单验证
    if (!_isUsernameValid) {
      _showError('用户名至少3个字符');
      return;
    }

    if (!_isPasswordValid) {
      _showError('密码至少6个字符');
      return;
    }

    if (!_isConfirmPasswordValid) {
      _showError('两次输入的密码不一致');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('发送注册请求...');
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text.trim(),
          'password': _passwordController.text,
          'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          'nickname': _nicknameController.text.trim().isEmpty ? null : _nicknameController.text.trim(),
        }),
      );

      print('响应状态码: ${response.statusCode}');
      print('响应体: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('注册成功: $data');

        // 保存登录信息
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user', json.encode(data['user']));

        _showSuccess('注册成功！欢迎加入食刻！');

        // 延迟一下让用户看到成功消息
        await Future.delayed(Duration(milliseconds: 2000));

        // 跳转到登录页
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        final errorData = json.decode(response.body);
        _showError('注册失败: ${errorData['error']}');
      }
    } catch (e) {
      print('网络错误: $e');
      _showError('网络错误，请检查连接');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.grey[700]),
          onPressed: _navigateToLogin,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部标题
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '创建账号',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '加入食刻，开启美食之旅',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40),

              // 用户名
              _buildTextFieldWithValidation(
                controller: _usernameController,
                label: '用户名',
                icon: Icons.person_outline_rounded,
                hintText: '请输入用户名（至少3位）',
                isValid: _isUsernameValid,
                errorText: '用户名至少3个字符',
              ),

              SizedBox(height: 20),

              // 密码
              _buildPasswordFieldWithValidation(
                controller: _passwordController,
                label: '密码',
                hintText: '请输入密码（至少6位）',
                obscureText: _obscurePassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                isValid: _isPasswordValid,
                errorText: '密码至少6个字符',
              ),

              SizedBox(height: 20),

              // 确认密码
              _buildPasswordFieldWithValidation(
                controller: _confirmPasswordController,
                label: '确认密码',
                hintText: '请再次输入密码',
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                isValid: _isConfirmPasswordValid,
                errorText: '两次密码不一致',
              ),

              SizedBox(height: 20),

              // 邮箱
              _buildTextField(
                controller: _emailController,
                label: '邮箱（选填）',
                icon: Icons.email_outlined,
                hintText: '请输入邮箱地址',
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: 20),

              // 昵称
              _buildTextField(
                controller: _nicknameController,
                label: '昵称（选填）',
                icon: Icons.badge_outlined,
                hintText: '请输入昵称',
              ),

              SizedBox(height: 40),

              // 注册按钮
              _buildRegisterButton(),

              SizedBox(height: 30),

              // 登录引导
              _buildLoginSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(icon, color: Colors.grey[600]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldWithValidation({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
    required bool isValid,
    required String errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: controller.text.isEmpty
                  ? Colors.transparent
                  : (isValid ? Colors.green : Colors.redAccent),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  prefixIcon: Icon(icon, color: Colors.grey[600]),
                ),
              ),
              if (controller.text.isNotEmpty)
                Positioned(
                  right: 12,
                  top: 0,
                  bottom: 0,
                  child: Icon(
                    isValid ? Icons.check_circle : Icons.error,
                    color: isValid ? Colors.green : Colors.redAccent,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
        if (controller.text.isNotEmpty && !isValid)
          Padding(
            padding: EdgeInsets.only(top: 4, left: 8),
            child: Text(
              errorText,
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordFieldWithValidation({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required bool isValid,
    required String errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: controller.text.isEmpty
                  ? Colors.transparent
                  : (isValid ? Colors.green : Colors.redAccent),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              TextField(
                controller: controller,
                obscureText: obscureText,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.grey[600]),
                ),
              ),
              Positioned(
                right: 40,
                top: 0,
                bottom: 0,
                child: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                ),
              ),
              if (controller.text.isNotEmpty)
                Positioned(
                  right: 12,
                  top: 0,
                  bottom: 0,
                  child: Icon(
                    isValid ? Icons.check_circle : Icons.error,
                    color: isValid ? Colors.green : Colors.redAccent,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
        if (controller.text.isNotEmpty && !isValid)
          Padding(
            padding: EdgeInsets.only(top: 4, left: 8),
            child: Text(
              errorText,
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    final isFormValid = _isUsernameValid && _isPasswordValid && _isConfirmPasswordValid;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: isFormValid && !_isLoading
            ? LinearGradient(
          colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        )
            : LinearGradient(
          colors: [Colors.grey[400]!, Colors.grey[500]!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isFormValid && !_isLoading
            ? [
          BoxShadow(
            color: Colors.orangeAccent.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: (isFormValid && !_isLoading) ? _register : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? LoadingAnimationWidget.threeRotatingDots(
          color: Colors.white,
          size: 32,
        )
            : Text(
          '注册账号',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginSection() {
    return Column(
      children: [
        Divider(color: Colors.grey[300]),
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '已有账号？',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(width: 4),
            GestureDetector(
              onTap: _navigateToLogin,
              child: Text(
                '立即登录',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}