// Simple SQL runner for executing a .sql file
// Usage: node scripts/run-sql-file.js path/to/file.sql

const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });

async function main() {
  const sqlFile = process.argv[2];
  if (!sqlFile) {
    console.error('Usage: node scripts/run-sql-file.js <sql_file_path>');
    process.exit(1);
  }

  const absolutePath = path.resolve(__dirname, '..', sqlFile.startsWith('..') ? sqlFile : path.relative(path.resolve(__dirname, '..'), path.resolve(sqlFile)));
  if (!fs.existsSync(absolutePath)) {
    console.error(`SQL file not found: ${absolutePath}`);
    process.exit(1);
  }

  const sqlRaw = fs.readFileSync(absolutePath, 'utf8');

  // Try to detect explicit USE <db> in the file (optional)
  const useMatch = sqlRaw.match(/USE\s+([`\"]?)([\w\-]+)\1\s*;/i);
  const explicitDb = useMatch ? useMatch[2] : undefined;

  const config = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    port: Number(process.env.DB_PORT || 3306),
    database: process.env.DB_NAME || explicitDb || 'delivery_db',
    multipleStatements: true,
    charset: 'utf8mb4',
  };

  console.log('Connecting to MySQL...', config.host);
  const conn = await mysql.createConnection(config);
  try {
    // Execute entire file in one go (supports multiple statements)
    if (explicitDb) await conn.query('USE `' + explicitDb + '`');
    console.log(`Executing SQL file: ${path.basename(absolutePath)}...`);
    await conn.query(sqlRaw);
    console.log('✅ SQL file executed successfully');
  } catch (e) {
    console.error('❌ Error executing SQL:', e.message);
    process.exitCode = 1;
  } finally {
    await conn.end();
  }
}

main().catch((e) => {
  console.error('Unexpected error:', e);
  process.exit(1);
});


