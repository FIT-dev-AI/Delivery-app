# DeliveryFlow Backend

Node.js + Express.js backend for the DeliveryFlow delivery management system.

## Features

- **Authentication**: JWT-based authentication with bcrypt password hashing
- **Order Management**: CRUD operations for delivery orders
- **Real-time Tracking**: Socket.io integration for live location updates
- **Database**: MySQL with connection pooling
- **Security**: CORS, helmet, rate limiting, input validation

## Tech Stack

- Node.js
- Express.js
- MySQL
- Socket.io
- JWT Authentication
- bcrypt

## Getting Started

1. Install dependencies:
```bash
npm install
```

2. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your database credentials
```

3. Create database and run migrations:
```bash
# Import database/schema.sql to your MySQL server
```

4. Start development server:
```bash
npm run dev
```

## API Endpoints

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `GET /api/orders` - Get orders (authenticated)
- `POST /api/orders` - Create new order
- `GET /api/orders/:id` - Get order details
- `PUT /api/orders/:id/status` - Update order status
- `POST /api/tracking/update` - Update location
- `GET /api/stats/dashboard` - Get dashboard statistics

## Project Structure

```
src/
├── config/         # Database and app configuration
├── controllers/    # Route handlers
├── middleware/     # Authentication and error handling
├── models/         # Database models
├── routes/         # API routes
├── utils/          # Helper functions
└── server.js       # Application entry point
```
