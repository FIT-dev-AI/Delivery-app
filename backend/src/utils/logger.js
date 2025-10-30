const fs = require('fs');
const path = require('path');

/**
 * Simple logger utility
 * In production, consider using Winston or Pino
 */
class Logger {
  constructor() {
    this.logsDir = path.join(__dirname, '../../logs');
    this.ensureLogDirectory();
  }

  ensureLogDirectory() {
    if (!fs.existsSync(this.logsDir)) {
      fs.mkdirSync(this.logsDir, { recursive: true });
    }
  }

  formatMessage(level, message) {
    const timestamp = new Date().toISOString();
    const formattedMessage = typeof message === 'object' 
      ? JSON.stringify(message) 
      : message;
    return `[${timestamp}] [${level.toUpperCase()}] ${formattedMessage}`;
  }

  writeToFile(level, message) {
    if (process.env.NODE_ENV === 'production') {
      const logFile = path.join(this.logsDir, `${level}.log`);
      const formattedMessage = this.formatMessage(level, message);
      fs.appendFileSync(logFile, formattedMessage + '\n');
    }
  }

  info(message) {
    console.log('\x1b[36m%s\x1b[0m', this.formatMessage('info', message));
    this.writeToFile('info', message);
  }

  error(message) {
    console.error('\x1b[31m%s\x1b[0m', this.formatMessage('error', message));
    this.writeToFile('error', message);
  }

  warn(message) {
    console.warn('\x1b[33m%s\x1b[0m', this.formatMessage('warn', message));
    this.writeToFile('warn', message);
  }

  debug(message) {
    if (process.env.NODE_ENV === 'development') {
      console.log('\x1b[35m%s\x1b[0m', this.formatMessage('debug', message));
    }
  }

  success(message) {
    console.log('\x1b[32m%s\x1b[0m', this.formatMessage('success', message));
  }
}

module.exports = new Logger();