# 🦷 Dental Chatbot Application

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)
[![Node.js](https://img.shields.io/badge/Node.js-18.x-green.svg)](https://nodejs.org/)
[![Python](https://img.shields.io/badge/Python-3.11-blue.svg)](https://www.python.org/)

A full-stack dental appointment chatbot built with Node.js/Express backend, Python/LangChain for AI conversations, and Next.js frontend. The chatbot can help patients book appointments, answer common questions, and provide dental information.

---

## Features

**AI Chatbot:**
- Supports multiple LLM providers (OpenAI, Anthropic, or local models)
- Remembers conversation context
- Natural language appointment booking
- Built with LangChain for better conversation management

**Security:**
- JWT authentication
- Password hashing with bcrypt
- Rate limiting to prevent abuse
- CORS and security headers

**Tech Stack:**
- Backend: Node.js + Express
- Frontend: Next.js (React)
- Chatbot: Python + LangChain + FastAPI
- Database: PostgreSQL

**Other stuff:**
- Docker setup for easy deployment
- Appointment management system
- Chat history tracking
- Multi-tenant ready

## 🚀 Quick Start (Docker - Recommended)

### Prerequisites
- Docker and Docker Compose installed
- OpenAI API key (or Anthropic/Local model)

### 1. Configure Environment

```bash
# Copy example environment file
cp .env.example .env

# Edit .env and add your API key
nano .env  # or use any editor
```

Minimum required in `.env`:
```env
LLM_PROVIDER=openai
OPENAI_API_KEY=your-api-key-here
```

### 2. Start All Services

```bash
# Build and start all services
docker-compose up --build

# Or run in background
docker-compose up -d --build
```

### 3. Access the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **Chatbot Service**: http://localhost:8001
- **API Docs**: http://localhost:8001/docs

### 4. Login

Use these demo credentials:
- Username: `demo` / Password: `demo123`
- Username: `admin` / Password: `admin123`

## 🛠️ Docker Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f chatbot-service

# Restart a service
docker-compose restart backend

# Rebuild after code changes
docker-compose up -d --build

# Check status
docker-compose ps

# Stop and remove everything (including volumes)
docker-compose down -v
```

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Dental Chatbot System                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────┐         ┌──────────┐         ┌───────────┐  │
│  │ Frontend │ ──JWT──>│  Node.js │ ──HTTP─>│  Python   │  │
│  │ Next.js  │ <──────│  Express │ <──────│ LangChain │  │
│  └──────────┘         └──────────┘         └───────────┘  │
│   Port 3000            Port 8000            Port 8001     │
│                                                             │
│                                             ┌─────────────┐│
│                                             │  LLM API    ││
│                                             │ (OpenAI/    ││
│                                             │  Anthropic) ││
│                                             └─────────────┘│
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Services

### 1. Frontend (Next.js)
- **Port**: 3000
- **Container**: `dental-frontend`
- **Features**: 
  - Chat interface
  - Appointment booking
  - User authentication
  - Responsive design

### 2. Backend (Node.js/Express)
- **Port**: 8000
- **Container**: `dental-backend`
- **Features**:
  - JWT authentication
  - API gateway
  - Request forwarding to chatbot
  - Rate limiting

### 3. Chatbot Service (Python/LangChain)
- **Port**: 8001
- **Container**: `dental-chatbot`
- **Features**:
  - LangChain-powered conversations
  - Multi-provider LLM support
  - Session management
  - Context-aware responses

## 🔧 Configuration

### LLM Provider Options

#### Option 1: OpenAI (Recommended)
```env
LLM_PROVIDER=openai
OPENAI_API_KEY=sk-...
OPENAI_MODEL=gpt-3.5-turbo  # or gpt-4
```

#### Option 2: Anthropic Claude
```env
LLM_PROVIDER=anthropic
ANTHROPIC_API_KEY=sk-ant-...
ANTHROPIC_MODEL=claude-3-opus-20240229
```

#### Option 3: Local/Open Source
```env
LLM_PROVIDER=local
LOCAL_MODEL_NAME=mistralai/Mistral-7B-Instruct-v0.2
```

### Advanced Configuration

See `.env.example` for all available options including:
- Conversation history length
- Memory type (buffer/summary/token)
- Session timeout
- Model parameters (temperature, max tokens)

## 📦 Project Structure

```
ChatBot_Dental/
├── backend/                    # Node.js Express API
│   ├── app.js
│   ├── auth.js
│   ├── config.js
│   ├── middleware.js
│   ├── package.json
│   └── Dockerfile
├── chatbot-service/            # Python LangChain service
│   ├── app.py
│   ├── chatbot_chain.py
│   ├── conversation_manager.py
│   ├── llm_provider.py
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/                   # Next.js frontend
│   ├── src/
│   ├── package.json
│   └── Dockerfile
├── docker-compose.yml          # Main Docker configuration
├── .env.example                # Environment template
└── README.md                   # This file
```

## 🗄️ Database Setup

### Run DB Scripts

The application uses PostgreSQL with a comprehensive schema for user management, appointments, and chat analytics.

**Database files:**
- `database/schema.sql` - Complete database schema with tables, indexes, and views
- `database/seed.sql` - Demo data including users, appointments, and chat sessions

**Required tables:**
- `users` - User profiles and authentication
- `appointments` - Appointment scheduling with tenant support
- `chat_sessions` - Conversation tracking and analytics
- `chat_messages` - Individual message storage
- `audit_log` - Security and compliance logging

**Key indexes:**
- `appointments(tenant_id, start_at)` - Multi-tenant appointment queries
- `chat_messages(session_id, created_at)` - Message history optimization

**Initialize database:**
```bash
# Connect to PostgreSQL
psql -U postgres -d dental_chatbot

# Run schema
\i database/schema.sql

# Run seed data
\i database/seed.sql
```

**Demo data includes:**
- 6 users (2 patients, 2 dentists, 1 admin, 1 staff)
- 5 sample appointments
- 2 chat sessions with 13 messages
- 4 audit log entries

## 🐛 Troubleshooting

### Services Won't Start

**Check logs:**
```bash
docker-compose logs
```

**Common issues:**
- Missing `.env` file → Copy from `.env.example`
- Invalid API key → Check your LLM provider credentials
- Port conflicts → Stop services on ports 3000, 8000, 8001

### Chatbot Not Responding

**Check chatbot service health:**
```bash
curl http://localhost:8001/health
```

**View chatbot logs:**
```bash
docker-compose logs chatbot-service
```

**Common issues:**
- Missing or invalid API key
- LLM provider rate limits
- Network connectivity

### Container Keeps Restarting

**Check specific container:**
```bash
docker-compose ps
docker logs dental-chatbot
```

**Restart specific service:**
```bash
docker-compose restart chatbot-service
```

## 🧪 Testing

### Test Backend
```bash
curl http://localhost:8000/health
```

### Test Chatbot Service
```bash
curl http://localhost:8001/health
```

### Test Login
```bash
curl -X POST http://localhost:8000/api/chatbot/login \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","password":"demo123"}'
```

### Test Chat (requires token)
```bash
# Get token
TOKEN=$(curl -s -X POST http://localhost:8000/api/chatbot/login \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","password":"demo123"}' \
  | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

# Send message
curl -X POST http://localhost:8000/api/chatbot/chat \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"message":"I need a dental checkup"}'
```

## 🚀 Development Mode

To run services locally without Docker:

### Backend
```bash
cd backend
npm install
node app.js
```

### Chatbot Service
```bash
cd chatbot-service
pip install -r requirements.txt
python app.py
```

### Frontend
```bash
cd frontend
npm install
npm run dev
```

## 📊 Monitoring

### View All Services
```bash
docker-compose ps
```

### Health Checks
```bash
# Backend
curl http://localhost:8000/health

# Chatbot
curl http://localhost:8001/health

# Frontend
curl -I http://localhost:3000
```

### Resource Usage
```bash
docker stats
```

## 🔐 Security Notes

1. **Never commit `.env`** - It contains your API keys
2. **Change default SECRET_KEY** in production
3. **Use HTTPS** in production
4. **Enable firewall** rules for production deployment
5. **Regularly update** dependencies

## 💰 Cost Considerations

### OpenAI Pricing (Approximate)
- **GPT-3.5-Turbo**: ~$0.002 per 1K tokens (~$0.01 per conversation)
- **GPT-4**: ~$0.03 per 1K tokens (~$0.15 per conversation)

### Free Alternative
Use `LLM_PROVIDER=local` for free open-source models (requires more resources)

## 📚 Documentation

- **LangChain Guide**: `CHATBOT_SERVICE_GUIDE.md`
- **Docker Setup**: `DOCKER_SETUP_COMPLETE.md`
- **LangChain Summary**: `LANGCHAIN_CHATBOT_SUMMARY.md`
- **API Examples**: Check `/docs` endpoint when services are running

## 🤝 Support

For issues:
1. Check logs: `docker-compose logs`
2. Verify `.env` configuration
3. Ensure API key is valid
4. Check health endpoints

## Contributing

Want to help improve this? Pull requests are welcome! Check out [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Quick steps:
1. Fork the repo
2. Create your branch (`git checkout -b feature/cool-stuff`)
3. Commit changes (`git commit -m 'Add cool stuff'`)
4. Push and open a PR

## Documentation

- [Architecture Overview](docs/ARCHITECTURE.md) - How everything fits together
- [API Reference](docs/API.md) - All the endpoints
- [Deployment Guide](docs/DEPLOYMENT.md) - Getting this running in production
- [Testing Guide](docs/TESTING.md) - How to test your changes

## Security

Found a security issue? Please don't open a public issue. Check [SECURITY.md](SECURITY.md) for how to report it.

## Support

Having trouble? 
- Check the troubleshooting section above
- Look through [existing issues](https://github.com/yourusername/Chatbot_for_appointment/issues)
- Open a new issue if you can't find a solution

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Quick start:**
```bash
cp .env.example .env          # Add your API key here
docker-compose up --build     # Start everything
# Open http://localhost:3000
```
