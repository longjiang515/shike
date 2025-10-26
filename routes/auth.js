const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../database/db');
const router = express.Router();
const emailService = require('../utils/emailService').default;

router.post('/login', async (req, res) => {
  const { username, password } = req.body;

  console.log('🚀 === 登录请求开始 ===');
  console.log('用户名:', username);
  console.log('输入密码:', password);

  try {
    // 查询用户
    const [users] = await db.promise().query(
      'SELECT * FROM users WHERE username = ?',
      [username]
    );

    if (users.length === 0) {
      console.log('❌ 用户不存在');
      return res.status(401).json({ error: '用户不存在' });
    }

    const user = users[0];
    
    console.log('🔍 数据库用户信息:', {
      username: user.username,
      storedPassword: user.password
    });

    // 使用 bcrypt 验证加密密码
    const isPasswordValid = await bcrypt.compare(password, user.password);
    console.log('🔐 密码验证结果:', isPasswordValid);

    if (isPasswordValid) {
      console.log('✅ 密码验证成功');
      
      // 生成JWT token
      const token = jwt.sign(
        { userId: user.id, username: user.username },
        process.env.JWT_SECRET || 'shike_secret_key',
        { expiresIn: '24h' }
      );

      res.json({
        message: '登录成功',
        token,
        user: {
          id: user.id,
          username: user.username,
          nickname: user.nickname,
          email: user.email
        }
      });
    } else {
      console.log('❌ 密码验证失败');
      return res.status(401).json({ error: '密码错误' });
    }

  } catch (error) {
    console.error('💥 登录过程错误:', error);
    res.status(500).json({ error: '服务器内部错误' });
  }
  console.log('=== 登录请求结束 ===\n');
});

// 注册接口
router.post('/register', async (req, res) => {
  const { username, password, email, nickname } = req.body;

  console.log('🚀 === 注册请求开始 ===');
  console.log('注册数据:', { username, email, nickname, passwordLength: password ? password.length : 0 });

  // 数据验证
  if (!username || !password) {
    return res.status(400).json({ error: '用户名和密码不能为空' });
  }

  if (username.length < 3) {
    return res.status(400).json({ error: '用户名至少3个字符' });
  }

  if (password.length < 6) {
    return res.status(400).json({ error: '密码至少6个字符' });
  }

  try {
    // 检查用户是否已存在
    const [existingUsers] = await db.promise().query(
      'SELECT id FROM users WHERE username = ?',
      [username]
    );

    if (existingUsers.length > 0) {
      console.log('❌ 用户名已存在:', username);
      return res.status(409).json({ error: '用户名已存在' });
    }

    // 检查邮箱是否已存在（如果提供了邮箱）
    if (email) {
      const [existingEmails] = await db.promise().query(
        'SELECT id FROM users WHERE email = ?',
        [email]
      );

      if (existingEmails.length > 0) {
        console.log('❌ 邮箱已存在:', email);
        return res.status(409).json({ error: '邮箱已存在' });
      }
    }

    console.log('✅ 用户名校验通过');

    // 加密密码
    const hashedPassword = await bcrypt.hash(password, 10);
    console.log('🔐 密码加密完成');

    // 插入新用户
    const [result] = await db.promise().query(
      'INSERT INTO users (username, password, email, nickname) VALUES (?, ?, ?, ?)',
      [username, hashedPassword, email || null, nickname || null]
    );

    console.log('✅ 用户创建成功，ID:', result.insertId);

    // 生成JWT token（自动登录）
    const token = jwt.sign(
      { userId: result.insertId, username: username },
      process.env.JWT_SECRET || 'shike_secret_key',
      { expiresIn: '24h' }
    );

    // 返回用户信息和token
    res.status(201).json({
      message: '注册成功',
      token,
      user: {
        id: result.insertId,
        username: username,
        nickname: nickname || username,
        email: email || ''
      }
    });

    console.log('🎉 注册完成，返回用户数据');

  } catch (error) {
    console.error('💥 注册过程错误:', error);
    res.status(500).json({ error: '注册失败，请稍后重试' });
  }
  
  console.log('=== 注册请求结束 ===\n');
});

//忘记密码
// 忘记密码 - 发送验证码
const verificationCodes = new Map();

// 发送验证码接口
router.post('/forgot-password/send-code', async (req, res) => {
  const { email } = req.body;

  console.log('📧 请求发送验证码到:', email);

  if (!email) {
    return res.status(400).json({ error: '邮箱不能为空' });
  }

  try {
    // 检查邮箱是否注册
    const [users] = await db.promise().query(
      'SELECT id FROM users WHERE email = ?',
      [email]
    );

    if (users.length === 0) {
      console.log('❌ 邮箱未注册:', email);
      return res.status(404).json({ error: '该邮箱未注册' });
    }

    // 生成6位数字验证码
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = Date.now() + 15 * 60 * 1000; // 15分钟过期

    // 存储验证码
    verificationCodes.set(email, { code, expiresAt });
    console.log('✅ 生成验证码:', { email, code, expiresAt: new Date(expiresAt) });

    // 发送邮件（暂时注释，先用模拟发送）
    // const emailSent = await sendVerificationCode(email, code);
    
    // 模拟发送成功（开发阶段）
    console.log('📤 模拟发送验证码:', code);
    const emailSent = true;

    if (emailSent) {
      res.json({ 
        message: '验证码发送成功',
        // 开发阶段返回验证码方便测试
        debugCode: process.env.NODE_ENV === 'development' ? code : undefined
      });
    } else {
      res.status(500).json({ error: '验证码发送失败，请重试' });
    }

  } catch (error) {
    console.error('💥 发送验证码错误:', error);
    res.status(500).json({ error: '服务器错误，请重试' });
  }
});

// 验证验证码接口
router.post('/forgot-password/verify-code', async (req, res) => {
  const { email, code } = req.body;

  console.log('🔍 验证验证码:', { email, code });

  if (!email || !code) {
    return res.status(400).json({ error: '邮箱和验证码不能为空' });
  }

  try {
    const storedData = verificationCodes.get(email);
    
    if (!storedData) {
      return res.status(400).json({ error: '验证码已过期或未发送' });
    }

    if (Date.now() > storedData.expiresAt) {
      verificationCodes.delete(email);
      return res.status(400).json({ error: '验证码已过期' });
    }

    if (storedData.code !== code) {
      return res.status(400).json({ error: '验证码错误' });
    }

    // 验证成功，生成重置令牌
    const resetToken = jwt.sign(
      { email, type: 'password_reset' },
      process.env.JWT_SECRET || 'shike_secret_key',
      { expiresIn: '30m' }
    );

    // 删除已使用的验证码
    verificationCodes.delete(email);

    console.log('✅ 验证码验证成功，生成重置令牌');
    res.json({ 
      message: '验证码验证成功',
      resetToken 
    });

  } catch (error) {
    console.error('💥 验证验证码错误:', error);
    res.status(500).json({ error: '验证失败，请重试' });
  }
});

// 重置密码接口
router.post('/forgot-password/reset', async (req, res) => {
  const { resetToken, newPassword } = req.body;

  console.log('🔄 请求重置密码');

  if (!resetToken || !newPassword) {
    return res.status(400).json({ error: '令牌和新密码不能为空' });
  }

  if (newPassword.length < 6) {
    return res.status(400).json({ error: '密码至少6个字符' });
  }

  try {
    // 验证重置令牌
    const decoded = jwt.verify(resetToken, process.env.JWT_SECRET || 'shike_secret_key');
    
    if (decoded.type !== 'password_reset') {
      return res.status(400).json({ error: '无效的重置令牌' });
    }

    const { email } = decoded;

    // 加密新密码
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // 更新密码
    await db.promise().query(
      'UPDATE users SET password = ? WHERE email = ?',
      [hashedPassword, email]
    );

    console.log('✅ 密码重置成功:', email);
    res.json({ message: '密码重置成功' });

  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(400).json({ error: '重置链接已过期' });
    }
    if (error.name === 'JsonWebTokenError') {
      return res.status(400).json({ error: '无效的重置令牌' });
    }
    console.error('💥 重置密码错误:', error);
    res.status(500).json({ error: '重置密码失败，请重试' });
  }
});

module.exports = router;