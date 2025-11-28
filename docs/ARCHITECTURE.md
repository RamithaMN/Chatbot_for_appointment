# Architecture Documentation

## System Overview

The Dental Chatbot Application is a microservices-based system designed for scalability, maintainability, and ease of deployment.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         User Interface                          │
│                       (Next.js Frontend)                        │
│                         Port: 3000                              │
└───────────────────────────┬─────────────────────────────────────┘
                            │ HTTPS/WSS
                            │
┌───────────────────────────┴─────────────────────────────────────┐
│                      API Gateway Layer                          │
│                    (Express.js Backend)                         │
│                         Port: 8000                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │     Auth     │  │   Rate       │  │    CORS      │        │
│  │  Middleware  │  │  Limiting    │  │  & Security  │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
└───────────────────────────┬─────────────────────────────────────┘
                            │
            ┌───────────────┴───────────────┐
            │                               │
┌───────────┴────────────┐     ┌───────────┴─────────────┐
│   Chatbot Service      │     │   Database Service      │
│   (Python/LangChain)   │     │   (PostgreSQL 15)       │
│      Port: 8001        │     │      Port: 5432         │
│                        │     │                         │
│  ┌──────────────────┐ │     │  ┌──────────────────┐  │
│  │  LLM Provider    │ │     │  │     Users        │  │
│  │  (OpenAI/        │ │     │  │   Appointments   │  │
│  │   Anthropic/     │ │     │  │  Chat Sessions   │  │
│  │   Local)         │ │     │  │    Messages      │  │
│  └──────────────────┘ │     │  └──────────────────┘  │
│                        │     │                         │
│  ┌──────────────────┐ │     │  ┌──────────────────┐  │
│  │  Conversation    │ │     │  │    Indexes       │  │
│  │    Manager       │ │     │  │     Views        │  │
│  └──────────────────┘ │     │  └──────────────────┘  │
└────────────────────────┘     └─────────────────────────┘
```

## Component Details

### 1. Frontend (Next.js)

**Purpose**: User interface for interacting with the chatbot and managing appointments.

**Technology Stack**:
- Next.js 14 (React framework)
- TypeScript
- Tailwind CSS
- React Context for state management
- Axios for API calls

**Key Features**:
- Server-side rendering (SSR)
- Client-side routing
- Responsive design
- Real-time chat interface
- Appointment management UI
- User authentication UI

**Directory Structure**:
```
frontend/
├── src/
│   ├── components/        # Reusable React components
│   ├── contexts/          # React Context providers
│   ├── pages/             # Next.js pages
│   ├── styles/            # CSS and styling
│   ├── utils/             # Utility functions
│   └── types/             # TypeScript type definitions
├── public/                # Static assets
└── package.json
```

### 2. Backend API (Express.js)

**Purpose**: API gateway that handles authentication, routing, and business logic.

**Technology Stack**:
- Node.js 18
- Express.js
- JWT for authentication
- bcrypt for password hashing
- pg (node-postgres) for database access
- Helmet for security headers
- Morgan for logging

**Key Responsibilities**:
- User authentication and authorization
- Request validation and sanitization
- Rate limiting
- API routing
- Database operations
- Forwarding chat requests to chatbot service
- Session management

**API Endpoints**:
```
Authentication:
POST   /api/chatbot/login          - User login
POST   /api/chatbot/register       - User registration
POST   /api/chatbot/refresh        - Token refresh

Chat:
POST   /api/chatbot/chat           - Send message
GET    /api/chatbot/history        - Get chat history
DELETE /api/chatbot/session/:id    - Clear session

Appointments:
GET    /api/appointments           - List appointments
POST   /api/appointments           - Create appointment
PUT    /api/appointments/:id       - Update appointment
DELETE /api/appointments/:id       - Cancel appointment

Health:
GET    /health                     - Health check
```

### 3. Chatbot Service (Python/LangChain)

**Purpose**: AI-powered conversational interface using LangChain.

**Technology Stack**:
- Python 3.11
- FastAPI
- LangChain
- OpenAI / Anthropic / HuggingFace
- Pydantic for validation

**Key Components**:

#### LLM Provider (`llm_provider.py`)
- Manages connections to different LLM providers
- Supports OpenAI, Anthropic, and local models
- Handles API key management and error handling

#### Conversation Manager (`conversation_manager.py`)
- Manages conversation state and context
- Implements different memory strategies:
  - Buffer memory (keeps last N messages)
  - Summary memory (summarizes old conversations)
  - Token-based memory (manages token limits)
- Session timeout handling

#### Chatbot Chain (`chatbot_chain.py`)
- Defines the conversation flow
- Implements prompt templates
- Handles context injection
- Response generation and formatting

**Architecture Pattern**:
```
Request → FastAPI → Conversation Manager → LangChain → LLM Provider
                          ↓
                   Session Storage
```

### 4. Database (PostgreSQL)

**Purpose**: Persistent storage for users, appointments, chat history, and analytics.

**Schema Overview**:

```sql
-- Core tables
users                   # User accounts and profiles
appointments            # Appointment scheduling
chat_sessions          # Conversation sessions
chat_messages          # Individual messages
audit_log              # Security and compliance audit trail

-- Indexes for performance
idx_appointments_tenant_date
idx_chat_messages_session
idx_users_username
```

**Database Design Principles**:
- Normalization (3NF)
- Proper indexing for query performance
- Foreign key constraints for data integrity
- Audit logging for compliance
- Multi-tenant support

## Data Flow

### 1. User Authentication Flow

```
1. User submits credentials → Frontend
2. Frontend sends POST /api/chatbot/login → Backend
3. Backend validates credentials against database
4. Backend generates JWT token
5. Backend returns token to Frontend
6. Frontend stores token in localStorage/cookies
7. Frontend includes token in subsequent requests
```

### 2. Chat Message Flow

```
1. User types message → Frontend
2. Frontend sends POST /api/chatbot/chat with JWT → Backend
3. Backend validates JWT token
4. Backend checks rate limits
5. Backend forwards message to Chatbot Service
6. Chatbot Service:
   a. Loads conversation context
   b. Sends to LLM with system prompt
   c. Receives LLM response
   d. Updates conversation history
7. Chatbot Service returns response → Backend
8. Backend logs interaction to database
9. Backend returns response → Frontend
10. Frontend displays message in chat UI
```

### 3. Appointment Booking Flow

```
1. User expresses intent to book → Chat Interface
2. Chatbot extracts appointment details (date, time, type)
3. Chatbot confirms details with user
4. User confirms → Frontend sends appointment data → Backend
5. Backend validates appointment slot availability
6. Backend creates appointment record in database
7. Backend returns confirmation → Frontend
8. Frontend updates UI with appointment details
```

## Security Architecture

### Authentication & Authorization

- **JWT Tokens**: Stateless authentication
- **Token Expiration**: Short-lived access tokens (15-30 min)
- **Refresh Tokens**: Longer-lived tokens for renewal
- **Password Hashing**: bcrypt with salt rounds

### API Security

- **Rate Limiting**: Prevents abuse and DDoS
- **CORS**: Restricts cross-origin requests
- **Helmet.js**: Sets security HTTP headers
- **Input Validation**: Prevents injection attacks
- **SQL Parameterization**: Prevents SQL injection

### LLM Security

- **Prompt Injection Protection**: Input sanitization
- **API Key Management**: Environment variables only
- **Rate Limiting**: Per-user request limits
- **Content Filtering**: Inappropriate content detection

## Scalability Considerations

### Horizontal Scaling

1. **Frontend**: Multiple instances behind load balancer
2. **Backend**: Stateless design allows multiple instances
3. **Chatbot Service**: Can scale independently
4. **Database**: Read replicas for read-heavy operations

### Caching Strategy

- Redis for session storage (optional)
- Database query caching
- API response caching for static data
- LLM response caching for common queries

### Performance Optimization

- Connection pooling for database
- Asynchronous processing for non-critical tasks
- CDN for static assets
- Lazy loading in frontend
- Database indexes for frequent queries

## Deployment Architecture

### Docker Compose (Development/Small Scale)

```yaml
networks:
  - dental-network (bridge)

volumes:
  - postgres-data (persistent)
  - chatbot-data (persistent)

services:
  - frontend (3000)
  - backend (8000)
  - chatbot-service (8001)
  - postgres (5432)
```

### Production Deployment Options

1. **Cloud VMs** (AWS EC2, Google Compute, Azure VM)
   - Docker Compose with production configuration
   - Nginx reverse proxy
   - SSL/TLS certificates
   - Automated backups

2. **Container Orchestration** (Kubernetes)
   - Multiple replicas for high availability
   - Auto-scaling based on load
   - Load balancing
   - Rolling updates

3. **Serverless/PaaS**
   - Frontend: Vercel/Netlify
   - Backend: AWS Lambda/Cloud Run
   - Database: Managed PostgreSQL
   - Chatbot: Cloud Functions

## Monitoring & Observability

### Health Checks

- `/health` endpoints for all services
- Periodic health check pings
- Automated restart on failure

### Logging

- Structured logging (JSON format)
- Log levels: DEBUG, INFO, WARN, ERROR
- Centralized log aggregation
- Request/response logging

### Metrics

- Response times
- Error rates
- API usage statistics
- LLM token consumption
- Database query performance
- Active user sessions

### Alerting

- Service downtime
- High error rates
- Performance degradation
- Security events
- Cost threshold exceeded

## Technology Choices Rationale

### Why Next.js?
- Server-side rendering for SEO
- Built-in routing and optimization
- Great developer experience
- TypeScript support

### Why Express.js?
- Lightweight and flexible
- Large ecosystem
- Easy to understand
- Perfect for API gateway pattern

### Why FastAPI for Chatbot?
- High performance (async support)
- Automatic API documentation
- Type checking with Pydantic
- Python ecosystem for AI/ML

### Why LangChain?
- Abstracts LLM provider differences
- Built-in conversation memory
- Rich ecosystem of tools
- Extensible and customizable

### Why PostgreSQL?
- ACID compliance
- Rich feature set
- Excellent performance
- JSON support for flexible data
- Strong community

## Future Architecture Enhancements

1. **Message Queue** (RabbitMQ/Redis): Async processing
2. **Cache Layer** (Redis): Session and response caching
3. **API Gateway** (Kong/Traefik): Advanced routing and monitoring
4. **Service Mesh** (Istio): Inter-service communication
5. **Event Sourcing**: Audit trail and replay capability
6. **GraphQL API**: Alternative to REST for frontend
7. **WebSocket**: Real-time bidirectional communication
8. **ML Pipeline**: Training and fine-tuning custom models

## Conclusion

This architecture provides a solid foundation for a production-ready dental chatbot application with considerations for security, scalability, and maintainability. The microservices design allows independent scaling and deployment of components while maintaining clear separation of concerns.

