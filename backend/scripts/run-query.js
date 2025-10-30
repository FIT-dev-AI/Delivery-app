// Run an arbitrary SQL query and print JSON results
// Usage: node scripts/run-query.js "SQL HERE"

const mysql = require('mysql2/promise');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });

async function main() {
  const sql = process.argv.slice(2).join(' ');
  if (!sql) {
    console.error('Usage: node scripts/run-query.js "SQL"');
    process.exit(1);
  }

  const conn = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    port: Number(process.env.DB_PORT || 3306),
    database: process.env.DB_NAME || 'delivery_db',
    charset: 'utf8mb4',
  });

  try {
    const [rows] = await conn.query(sql);
    console.log(JSON.stringify(rows, null, 2));
  } catch (e) {
    console.error('Query error:', e.message);
    process.exitCode = 1;
  } finally {
    await conn.end();
  }
}

main();


