import { createTransport } from 'nodemailer';

// 创建邮件传输器 - 修正方法名
const transporter = createTransport({
  host: 'smtp.qq.com',
  port: 587,
  secure: false,
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

// 发送验证码邮件
const sendVerificationCode = async (email, code) => {
  try {
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: email,
      subject: '食刻 - 密码重置验证码',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #FF6B35;">食刻烹饪助手</h2>
          <p>您好！</p>
          <p>您正在申请重置密码，验证码为：</p>
          <div style="text-align: center; margin: 30px 0;">
            <span style="font-size: 32px; font-weight: bold; color: #FF6B35; letter-spacing: 8px;">
              ${code}
            </span>
          </div>
          <p>验证码有效期15分钟，请尽快使用。</p>
          <p>如果这不是您本人的操作，请忽略此邮件。</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
          <p style="color: #666; font-size: 12px;">食刻团队</p>
        </div>
      `,
    };

    await transporter.sendMail(mailOptions);
    console.log('验证码邮件发送成功:', email);
    return true;
  } catch (error) {
    console.error('发送邮件失败:', error);
    return false;
  }
};

export default { sendVerificationCode };