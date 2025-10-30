# DeliveryFlow API Documentation

## Base Configuration
- **Base URL**: `http://localhost:3000/api`
- **Authentication**: Bearer JWT Token
- **Content-Type**: `application/json`

## Authentication Endpoints

### POST /auth/register
Register a new user account.

**Request Body:**
```json
{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "securePassword123",
    "role": "customer",
    "phone": "+1234567890"
}
```

**Response (201):**
```json
{
    "success": true,
    "message": "User registered successfully",
    "data": {
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "role": "customer"
        },
        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
}
```

### POST /auth/login
Authenticate user and get JWT token.

**Request Body:**
```json
{
    "email": "john@example.com",
    "password": "securePassword123"
}
```

**Response (200):**
```json
{
    "success": true,
    "message": "Login successful",
    "data": {
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "role": "customer"
        },
        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
}
```

## Order Management Endpoints

### GET /orders
Get list of orders with optional filtering.

**Headers:** `Authorization: Bearer {token}`

**Query Parameters:**
- `status` (optional): Filter by order status
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 10)

### POST /orders
Create a new delivery order.

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
    "pickup_address": "123 Main St, City",
    "pickup_latitude": 40.7128,
    "pickup_longitude": -74.0060,
    "delivery_address": "456 Oak Ave, City",
    "delivery_latitude": 40.7589,
    "delivery_longitude": -73.9851,
    "notes": "Handle with care",
    "total_amount": 25.50
}
```

### GET /orders/:id
Get detailed information about a specific order.

### PUT /orders/:id/status
Update order status (shipper/admin only).

### PUT /orders/:id/assign
Assign order to a shipper (admin only).

## Real-time Tracking Endpoints

### POST /tracking/update
Update shipper's current location.

### GET /tracking/:shipper_id
Get current location of a shipper.

## Statistics Endpoints

### GET /stats/dashboard
Get dashboard statistics and KPIs.

## Error Responses

All endpoints return standardized error responses:

```json
{
    "success": false,
    "message": "Detailed error message",
    "error_code": "VALIDATION_ERROR",
    "timestamp": "2024-01-01T00:00:00Z"
}
```

## Status Codes
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `422` - Validation Error
- `500` - Internal Server Error
