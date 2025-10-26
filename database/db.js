const mysql = require('mysql2');
require('dotenv').config();

const connection = mysql.createConnection({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '123456',
  database: process.env.DB_NAME || 'shike_app'
});

connection.connect((err) => {
  if (err) {
    console.error('数据库连接失败: ', err);
    return;
  }
  console.log('成功连接到MySQL数据库');
});

module.exports = connection;