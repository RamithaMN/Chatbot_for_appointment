# API Documentation

## Base URLs

- **Backend API**: `http://localhost:8000`
- **Chatbot Service**: `http://localhost:8001`
- **Frontend**: `http://localhost:3000`

## Authentication

All authenticated endpoints require a JWT token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

### Getting a Token

Use the login endpoint to obtain a JWT token:

```bash
POST /api/chatbot/login
```

## API Endpoints

### Authentication Endpoints

#### 1. Login

Authenticate a user and receive JWT tokens.

**Endpoint**: `POST /api/chatbot/login`

**Request Body**:
```json
{
  "username": "string",
  "password": "string"
}
```

**Response** (200 OK):
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 1800,
  "user": {
    "id": "uuid",
    "username": "demo",
    "email": "demo@example.com",
    "full_name": "Demo User"
  }
}
```

**Error Responses**:
- `400 Bad Request`: Missing username or password
- `401 Unauthorized`: Invalid credentials
- `429 Too Many Requests`: Rate limit exceeded

**Example**:
```bash
curl -X POST http://localhost:8000/api/chatbot/login \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","password":"demo123"}'
```

---

#### 2. Register

Create a new user account.

**Endpoint**: `POST /api/chatbot/register`

**Request Body**:
```json
{
  "username": "string",
  "password": "string",
  "email": "string",
  "full_name": "string"
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "username": "newuser",
  "email": "newuser@example.com",
  "full_name": "New User",
  "created_at": "2025-11-28T10:00:00Z"
}
```

**Error Responses**:
- `400 Bad Request`: Invalid input data
- `409 Conflict`: Username or email already exists

---

### Chat Endpoints

#### 3. Send Message

Send a message to the chatbot and receive a response.

**Endpoint**: `POST /api/chatbot/chat`

**Authentication**: Required

**Request Body**:
```json
{
  "message": "string",
  "session_id": "string (optional)"
}
```

**Response** (200 OK):
```json
{
  "response": "string",
  "session_id": "uuid",
  "message_id": "uuid",
  "timestamp": "2025-11-28T10:00:00Z",
  "metadata": {
    "tokens_used": 150,
    "response_time_ms": 1234
  }
}
```

**Example**:
```bash
TOKEN="your_jwt_token_here"

curl -X POST http://localhost:8000/api/chatbot/chat \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"message":"I need a dental checkup appointment"}'
```

---

#### 4. Get Chat History

Retrieve chat history for the authenticated user.

**Endpoint**: `GET /api/chatbot/history`

**Authentication**: Required

**Query Parameters**:
- `session_id` (optional): Filter by session ID
- `limit` (optional, default: 50): Number of messages to return
- `offset` (optional, default: 0): Pagination offset

**Response** (200 OK):
```json
{
  "messages": [
    {
      "id": "uuid",
      "session_id": "uuid",
      "role": "user",
      "content": "I need a dental checkup",
      "timestamp": "2025-11-28T10:00:00Z"
    },
    {
      "id": "uuid",
      "session_id": "uuid",
      "role": "assistant",
      "content": "I'd be happy to help you schedule a dental checkup...",
      "timestamp": "2025-11-28T10:00:05Z"
    }
  ],
  "total": 10,
  "has_more": false
}
```

**Example**:
```bash
curl -X GET "http://localhost:8000/api/chatbot/history?limit=10" \
  -H "Authorization: Bearer $TOKEN"
```

---

#### 5. Clear Session

Clear a specific chat session.

**Endpoint**: `DELETE /api/chatbot/session/:session_id`

**Authentication**: Required

**Response** (200 OK):
```json
{
  "message": "Session cleared successfully",
  "session_id": "uuid"
}
```

---

### Appointment Endpoints

#### 6. List Appointments

Get all appointments for the authenticated user.

**Endpoint**: `GET /api/appointments`

**Authentication**: Required

**Query Parameters**:
- `status` (optional): Filter by status (scheduled, completed, cancelled)
- `from_date` (optional): Start date filter (ISO 8601)
- `to_date` (optional): End date filter (ISO 8601)

**Response** (200 OK):
```json
{
  "appointments": [
    {
      "id": "uuid",
      "patient_id": "uuid",
      "dentist_id": "uuid",
      "appointment_type": "checkup",
      "start_at": "2025-12-01T14:00:00Z",
      "end_at": "2025-12-01T15:00:00Z",
      "status": "scheduled",
      "notes": "Regular checkup",
      "created_at": "2025-11-28T10:00:00Z"
    }
  ],
  "total": 1
}
```

---

#### 7. Create Appointment

Book a new appointment.

**Endpoint**: `POST /api/appointments`

**Authentication**: Required

**Request Body**:
```json
{
  "dentist_id": "uuid",
  "appointment_type": "checkup|cleaning|emergency|consultation",
  "start_at": "2025-12-01T14:00:00Z",
  "notes": "string (optional)"
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "patient_id": "uuid",
  "dentist_id": "uuid",
  "appointment_type": "checkup",
  "start_at": "2025-12-01T14:00:00Z",
  "end_at": "2025-12-01T15:00:00Z",
  "status": "scheduled",
  "notes": "Regular checkup"
}
```

**Error Responses**:
- `400 Bad Request`: Invalid input
- `409 Conflict`: Time slot not available

---

#### 8. Update Appointment

Update an existing appointment.

**Endpoint**: `PUT /api/appointments/:id`

**Authentication**: Required

**Request Body**:
```json
{
  "start_at": "2025-12-02T14:00:00Z (optional)",
  "notes": "string (optional)",
  "status": "scheduled|completed|cancelled (optional)"
}
```

**Response** (200 OK):
```json
{
  "id": "uuid",
  "patient_id": "uuid",
  "dentist_id": "uuid",
  "appointment_type": "checkup",
  "start_at": "2025-12-02T14:00:00Z",
  "end_at": "2025-12-02T15:00:00Z",
  "status": "scheduled",
  "notes": "Rescheduled appointment"
}
```

---

#### 9. Cancel Appointment

Cancel an appointment.

**Endpoint**: `DELETE /api/appointments/:id`

**Authentication**: Required

**Response** (200 OK):
```json
{
  "message": "Appointment cancelled successfully",
  "id": "uuid"
}
```

---

### Health Check

#### 10. Backend Health Check

Check if the backend service is running.

**Endpoint**: `GET /health`

**Authentication**: Not required

**Response** (200 OK):
```json
{
  "status": "healthy",
  "service": "backend",
  "timestamp": "2025-11-28T10:00:00Z",
  "version": "1.0.0"
}
```

---

#### 11. Chatbot Service Health Check

Check if the chatbot service is running.

**Endpoint**: `GET /health` (Chatbot Service: http://localhost:8001)

**Authentication**: Not required

**Response** (200 OK):
```json
{
  "status": "healthy",
  "service": "chatbot-service",
  "llm_provider": "openai",
  "timestamp": "2025-11-28T10:00:00Z",
  "version": "1.0.0"
}
```

---

## Error Responses

All endpoints follow a consistent error response format:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {}
  }
}
```

### HTTP Status Codes

- `200 OK`: Request succeeded
- `201 Created`: Resource created successfully
- `400 Bad Request`: Invalid request data
- `401 Unauthorized`: Authentication required or failed
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource not found
- `409 Conflict`: Resource conflict (e.g., duplicate username)
- `422 Unprocessable Entity`: Validation error
- `429 Too Many Requests`: Rate limit exceeded
- `500 Internal Server Error`: Server error
- `503 Service Unavailable`: Service temporarily unavailable

## Rate Limiting

API endpoints are rate-limited to prevent abuse:

- **Default**: 100 requests per minute per IP
- **Authentication endpoints**: 10 requests per minute per IP
- **Chat endpoints**: 30 requests per minute per user

Rate limit headers are included in responses:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1638360000
```

## Pagination

List endpoints support pagination:

**Query Parameters**:
- `limit`: Number of items per page (default: 50, max: 100)
- `offset`: Number of items to skip (default: 0)

**Response includes pagination metadata**:
```json
{
  "data": [...],
  "pagination": {
    "total": 150,
    "limit": 50,
    "offset": 0,
    "has_more": true
  }
}
```

## Webhooks (Future Feature)

Webhooks will allow you to receive real-time notifications for events:

- Appointment created/updated/cancelled
- Chat session completed
- User registered

## SDK and Client Libraries (Future Feature)

Official client libraries will be available for:
- JavaScript/TypeScript
- Python
- Go
- Ruby

## API Versioning

The API uses URL versioning:
- Current version: v1 (implicit, no version in URL)
- Future versions will use: `/api/v2/...`

## Support

For API support:
- Documentation: This file
- Issues: GitHub Issues
- Email: [INSERT EMAIL]

