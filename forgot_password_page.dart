import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // 页面状态：1-输入邮箱 2-输入验证码 3-设置新密码 4-完成
  int _currentStep = 1;
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _resetToken;
  int _countdown = 0;
  bool _canResend = true;

  // 倒计时
  void _startCountdown() {
    _countdown = 60;
    _canResend = false;

    const oneSec = Duration(seconds: 1);
    Timer.periodic(oneSec, (timer) {
      if (_countdown == 0) {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  // 发送验证码
  Future<void> _sendVerificationCode() async {
    if (_emailController.text.isEmpty) {
      _showError('请输入邮箱地址');
      return;
    }

    if (!_emailController.text.contains('@')) {
      _showError('请输入有效的邮箱地址');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/auth/forgot-password/send-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim(),
        }),
      );

      print('发送验证码响应: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 开发环境显示验证码提示
        if (data['debugCode'] != null) {
          _showSuccess('验证码已发送！开发环境验证码: ${data['debugCode']}');
        } else {
          _showSuccess('验证码已发送到您的邮箱');
        }

        _startCountdown();
        setState(() {
          _currentStep = 2;
        });
      } else {
        final errorData = json.decode(response.body);
        _showError('发送失败: ${errorData['error']}');
      }
    } catch (e) {
      _showError('网络错误: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 验证验证码
  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty) {
      _showError('请输入验证码');
      return;
    }

    if (_codeController.text.length != 6) {
      _showError('验证码必须是6位数字');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/auth/forgot-password/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim(),
          'code': _codeController.text,
        }),
      );

      print('验证验证码响应: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _resetToken = data['resetToken'];

        _showSuccess('验证成功');
        setState(() {
          _currentStep = 3;
        });
      } else {
        final errorData = json.decode(response.body);
        _showError('验证失败: ${errorData['error']}');
      }
    } catch (e) {
      _showError('网络错误: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 重置密码
  Future<void> _resetPassword() async {
    if (_newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      _showError('请输入新密码和确认密码');
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showError('密码至少6个字符');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError('两次输入的密码不一致');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/auth/forgot-password/reset'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'resetToken': _resetToken,
          'newPassword': _newPasswordController.text,
        }),
      );

      print('重置密码响应: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        _showSuccess('密码重置成功！');
        setState(() {
          _currentStep = 4;
        });
      } else {
        final errorData = json.decode(response.body);
        _showError('重置失败: ${errorData['error']}');
      }
    } catch (e) {
      _showError('网络错误: $e');
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
              _buildHeader(),
              SizedBox(height: 40),

              // 进度指示器
              _buildProgressIndicator(),
              SizedBox(height: 40),

              // 动态内容
              _buildCurrentStepContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titles = {
      1: '找回密码',
      2: '输入验证码',
      3: '设置新密码',
      4: '重置成功',
    };

    final subtitles = {
      1: '请输入您注册时使用的邮箱地址',
      2: '我们已向您的邮箱发送了验证码',
      3: '请设置您的新密码',
      4: '密码重置成功，请使用新密码登录',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titles[_currentStep]!,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        Text(
          subtitles[_currentStep]!,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [1, 2, 3, 4].map((step) {
        return Expanded(
          child: Column(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: step <= _currentStep ? Colors.orangeAccent : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: 8),
              Text(
                ['邮箱', '验证', '新密码', '完成'][step - 1],
                style: TextStyle(
                  fontSize: 12,
                  color: step <= _currentStep ? Colors.orangeAccent : Colors.grey[500],
                  fontWeight: step == _currentStep ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Email();
      case 2:
        return _buildStep2Verification();
      case 3:
        return _buildStep3NewPassword();
      case 4:
        return _buildStep4Success();
      default:
        return _buildStep1Email();
    }
  }

  Widget _buildStep1Email() {
    return Column(
      children: [
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
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: '请输入注册邮箱',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
            ),
          ),
        ),
        SizedBox(height: 32),
        _buildActionButton(
          text: '发送验证码',
          onPressed: _sendVerificationCode,
        ),
      ],
    );
  }

  Widget _buildStep2Verification() {
    return Column(
      children: [
        Text(
          '验证码已发送至：${_emailController.text}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        SizedBox(height: 20),
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
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: '请输入6位验证码',
              border: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(Icons.sms_outlined, color: Colors.grey[600]),
            ),
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _canResend ? _sendVerificationCode : null,
              child: Text(
                _canResend ? '重新发送' : '${_countdown}秒后重试',
                style: TextStyle(
                  color: _canResend ? Colors.orangeAccent : Colors.grey[400],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentStep = 1;
                });
              },
              child: Text(
                '更换邮箱',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        SizedBox(height: 32),
        _buildActionButton(
          text: '验证',
          onPressed: _verifyCode,
        ),
      ],
    );
  }

  Widget _buildStep3NewPassword() {
    return Column(
      children: [
        // 新密码
        _buildPasswordField(
          controller: _newPasswordController,
          label: '新密码',
          obscureText: _obscureNewPassword,
          onToggleVisibility: () {
            setState(() {
              _obscureNewPassword = !_obscureNewPassword;
            });
          },
        ),
        SizedBox(height: 20),
        // 确认密码
        _buildPasswordField(
          controller: _confirmPasswordController,
          label: '确认密码',
          obscureText: _obscureConfirmPassword,
          onToggleVisibility: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        SizedBox(height: 32),
        _buildActionButton(
          text: '重置密码',
          onPressed: _resetPassword,
        ),
      ],
    );
  }

  Widget _buildStep4Success() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            size: 60,
            color: Colors.green,
          ),
        ),
        SizedBox(height: 32),
        Text(
          '密码重置成功！',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 16),
        Text(
          '您的密码已成功重置，请使用新密码登录。',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 40),
        _buildActionButton(
          text: '返回登录',
          onPressed: _navigateToLogin,
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
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
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: '请输入$label',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.grey[600]),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.grey[600],
                ),
                onPressed: onToggleVisibility,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orangeAccent.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
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
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}