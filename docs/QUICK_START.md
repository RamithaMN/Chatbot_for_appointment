# Quick Start Guide

Let's get this running in about 5 minutes.

## What You Need

- Docker Desktop installed
- An OpenAI API key (or you can use mock mode for testing)

## Setup

### 1. Clone the repo

```bash
git clone https://github.com/yourusername/Chatbot_for_appointment.git
cd Chatbot_for_appointment
```

### 2. Set up environment

```bash
cp .env.example .env
nano .env  # or use any editor you like
```

Edit `.env` and add your API key:

```env
OPENAI_API_KEY=your-actual-api-key-here
SECRET_KEY=your-secure-secret-key
DB_PASSWORD=your-secure-password
```

**Tip:** Generate a random secret key:
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### 3. Start everything

```bash
docker-compose up --build
```

Or run in background:
```bash
docker-compose up -d --build
```

### 4. Open your browser

- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- Chatbot Service: http://localhost:8001

### 5. Login

Demo accounts:
- Username: `demo`, Password: `demo123`
- Username: `admin`, Password: `admin123`

## What's Running

Four services should be up:
- **Frontend** (3000) - The web interface
- **Backend** (8000) - Handles auth and API requests
- **Chatbot** (8001) - The AI brain
- **Database** (5432) - PostgreSQL

## Quick Commands

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f chatbot-service
docker-compose logs -f backend
docker-compose logs -f frontend
```

### Stop Services
```bash
# Stop all services
docker-compose down

# Stop and remove volumes (fresh start)
docker-compose down -v
```

### Restart a Service
```bash
docker-compose restart backend
```

### Check Service Status
```bash
docker-compose ps
```

## Test the Chatbot

### Via Web Interface
1. Go to http://localhost:3000
2. Login with demo credentials
3. Start chatting!

### Via API (curl)
```bash
# Login
TOKEN=$(curl -s -X POST http://localhost:8000/api/chatbot/login \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","password":"demo123"}' \
  | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

# Send a message
curl -X POST http://localhost:8000/api/chatbot/chat \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"message":"I need a dental checkup appointment"}'
```

## Troubleshooting

**Services won't start?**
```bash
docker-compose logs  # Check what's wrong
```

Common problems:
- Missing `.env` file → copy from `.env.example`
- Port already in use → check if something else is using 3000/8000/8001
- Invalid API key → double-check your OpenAI key

**Chatbot not responding?**
```bash
curl http://localhost:8001/health
docker-compose logs chatbot-service
```

Usually it's an API key issue or rate limiting.

**Database issues?**
```bash
docker-compose ps postgres
```

Make sure postgres container is running.

## Next Steps

Now that your chatbot is running:

1. 📖 Read the [Architecture Documentation](ARCHITECTURE.md)
2. 🔧 Review [API Documentation](API.md)
3. 🚀 Learn about [Deployment Options](DEPLOYMENT.md)
4. 🧪 Set up [Testing](TESTING.md)
5. 🤝 Check [Contributing Guidelines](../CONTRIBUTING.md)

## Development Mode

Want to develop locally without Docker?

### Backend
```bash
cd backend
npm install
npm run dev
```

### Frontend
```bash
cd frontend
npm install
npm run dev
```

### Chatbot Service
```bash
cd chatbot-service
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn app:app --reload --port 8001
```

## Performance Tips

### For Development
- Use `mock` LLM provider to save API costs:
  ```env
  LLM_PROVIDER=mock
  ```

### For Production
- Use `gpt-3.5-turbo` instead of `gpt-4` (cheaper)
- Implement caching for common queries
- Set up read replicas for database

## Security Reminders

⚠️ **Never commit `.env` to version control!**

✅ Use strong, unique secrets
✅ Change default passwords
✅ Keep API keys secure
✅ Use HTTPS in production
✅ Regular security updates

## Getting Help

- 📖 [Full Documentation](../README.md)
- 🐛 [Report Issues](https://github.com/yourusername/Chatbot_for_appointment/issues)
- 💬 [Discussions](https://github.com/yourusername/Chatbot_for_appointment/discussions)
- 📧 Email: support@yourproject.com

---

**Congratulations! Your Dental Chatbot is ready! 🎉**

Start chatting at http://localhost:3000

