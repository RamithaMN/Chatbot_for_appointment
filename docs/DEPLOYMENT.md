# Deployment Guide

This guide covers various deployment options for the Dental Chatbot Application.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Environment Configuration](#environment-configuration)
- [Local Development](#local-development)
- [Docker Deployment](#docker-deployment)
- [Cloud Deployment](#cloud-deployment)
- [Production Considerations](#production-considerations)
- [Monitoring & Maintenance](#monitoring--maintenance)

## Prerequisites

### Required Software

- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 2.0 or higher
- **Node.js**: Version 18.x (for local development)
- **Python**: Version 3.11+ (for local development)
- **PostgreSQL**: Version 15+ (for local development)

### Required API Keys

- **OpenAI API Key** (if using OpenAI)
- **Anthropic API Key** (if using Claude)
- Or configure for local LLM models

## Environment Configuration

### 1. Create Environment File

```bash
cp .env.example .env
```

### 2. Configure Required Variables

Edit `.env` and set at minimum:

```env
# LLM Provider
LLM_PROVIDER=openai
OPENAI_API_KEY=your-api-key-here

# Security
SECRET_KEY=your-secure-secret-key-change-this

# Database
DB_PASSWORD=your-secure-database-password
```

### 3. Generate Secure Secrets

```bash
# Generate SECRET_KEY
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Or using Python
python3 -c "import secrets; print(secrets.token_hex(32))"

# Or using OpenSSL
openssl rand -hex 32
```

## Local Development

### Option 1: Using Docker Compose (Recommended)

```bash
# Start all services
docker-compose up --build

# Run in background
docker-compose up -d --build

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### Option 2: Running Services Manually

#### Backend

```bash
cd backend
npm install
npm run dev  # Development mode with hot reload
# or
npm start    # Production mode
```

#### Frontend

```bash
cd frontend
npm install
npm run dev  # Development server on port 3000
```

#### Chatbot Service

```bash
cd chatbot-service
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app:app --reload --port 8001
```

#### Database

```bash
# Start PostgreSQL (if installed locally)
pg_ctl -D /usr/local/var/postgres start

# Create database
createdb dental_chatbot

# Run migrations
psql -d dental_chatbot -f database/schema.sql
psql -d dental_chatbot -f database/seed.sql
```

## Docker Deployment

### Single Server Deployment

#### 1. Prepare Server

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
sudo usermod -aG docker $USER
```

#### 2. Clone and Configure

```bash
# Clone repository
git clone https://github.com/yourusername/Chatbot_for_appointment.git
cd Chatbot_for_appointment

# Configure environment
cp .env.example .env
nano .env  # Edit with your settings
```

#### 3. Start Services

```bash
# Pull images and start
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

#### 4. Setup Nginx Reverse Proxy (Optional but Recommended)

```bash
# Install Nginx
sudo apt install nginx -y

# Create Nginx configuration
sudo nano /etc/nginx/sites-available/dental-chatbot
```

Add the following configuration:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    # Frontend
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/dental-chatbot /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### 5. Setup SSL with Let's Encrypt

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obtain certificate
sudo certbot --nginx -d your-domain.com

# Test automatic renewal
sudo certbot renew --dry-run
```

## Cloud Deployment

### AWS Deployment

#### Option 1: EC2 Instance

1. **Launch EC2 Instance**
   - AMI: Ubuntu 22.04 LTS
   - Instance Type: t3.medium or larger
   - Storage: 30GB minimum
   - Security Group: Open ports 80, 443, 22

2. **Connect and Deploy**
   ```bash
   ssh -i your-key.pem ubuntu@your-ec2-ip
   # Follow "Single Server Deployment" steps above
   ```

#### Option 2: ECS (Elastic Container Service)

1. **Push Images to ECR**
   ```bash
   # Authenticate
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin your-account.dkr.ecr.us-east-1.amazonaws.com

   # Build and push
   docker-compose build
   docker tag dental-chatbot-backend:latest your-account.dkr.ecr.us-east-1.amazonaws.com/dental-backend:latest
   docker push your-account.dkr.ecr.us-east-1.amazonaws.com/dental-backend:latest
   # Repeat for other services
   ```

2. **Create ECS Task Definitions**
   - Define tasks for each service
   - Configure environment variables
   - Set resource limits

3. **Create ECS Service**
   - Use Application Load Balancer
   - Configure health checks
   - Set auto-scaling policies

#### Option 3: AWS App Runner

Simplified deployment for each service:

```bash
# Deploy each service separately
aws apprunner create-service \
    --service-name dental-backend \
    --source-configuration file://apprunner-backend.json
```

### Google Cloud Platform

#### Option 1: Compute Engine

Similar to AWS EC2 deployment.

#### Option 2: Cloud Run

```bash
# Build and push to Container Registry
gcloud builds submit --tag gcr.io/your-project/dental-backend backend/

# Deploy to Cloud Run
gcloud run deploy dental-backend \
    --image gcr.io/your-project/dental-backend \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated
```

### Azure Deployment

#### Option 1: Azure VM

Similar to AWS EC2 deployment.

#### Option 2: Azure Container Instances

```bash
# Create container group
az container create \
    --resource-group dental-chatbot \
    --name dental-backend \
    --image your-registry.azurecr.io/dental-backend:latest \
    --dns-name-label dental-chatbot \
    --ports 8000
```

### DigitalOcean Deployment

#### App Platform

1. Connect GitHub repository
2. Configure build settings for each component
3. Set environment variables
4. Deploy

#### Droplet

Similar to AWS EC2 deployment.

## Production Considerations

### Security Hardening

1. **Firewall Configuration**
   ```bash
   sudo ufw enable
   sudo ufw allow 22    # SSH
   sudo ufw allow 80    # HTTP
   sudo ufw allow 443   # HTTPS
   sudo ufw status
   ```

2. **Fail2Ban for SSH Protection**
   ```bash
   sudo apt install fail2ban -y
   sudo systemctl enable fail2ban
   sudo systemctl start fail2ban
   ```

3. **Regular Security Updates**
   ```bash
   # Setup automatic updates
   sudo apt install unattended-upgrades -y
   sudo dpkg-reconfigure --priority=low unattended-upgrades
   ```

4. **Secret Management**
   - Use cloud provider secret managers (AWS Secrets Manager, GCP Secret Manager)
   - Never commit secrets to version control
   - Rotate secrets regularly

5. **Database Security**
   - Use strong passwords
   - Enable SSL connections
   - Restrict access by IP
   - Regular backups

### Performance Optimization

1. **Docker Image Optimization**
   - Use multi-stage builds
   - Minimize image layers
   - Use .dockerignore

2. **Database Optimization**
   - Configure connection pooling
   - Add appropriate indexes
   - Regular VACUUM and ANALYZE
   - Consider read replicas for scaling

3. **Caching**
   - Add Redis for session storage
   - Cache frequently accessed data
   - Use CDN for static assets

4. **Load Balancing**
   - Multiple instances of each service
   - Load balancer in front
   - Session persistence

### Backup Strategy

1. **Database Backups**
   ```bash
   # Automated daily backup script
   #!/bin/bash
   BACKUP_DIR="/backups/postgres"
   TIMESTAMP=$(date +%Y%m%d_%H%M%S)
   
   docker exec dental-postgres pg_dump -U dental_user dental_chatbot | gzip > "$BACKUP_DIR/backup_$TIMESTAMP.sql.gz"
   
   # Keep only last 7 days
   find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +7 -delete
   ```

2. **Application Data Backups**
   - Backup docker volumes
   - Store in cloud storage (S3, GCS, Azure Blob)

3. **Disaster Recovery Plan**
   - Document recovery procedures
   - Test restore process regularly
   - Maintain off-site backups

### Monitoring

1. **Health Checks**
   - Configure monitoring for `/health` endpoints
   - Set up alerts for downtime

2. **Log Management**
   - Centralized logging (ELK Stack, CloudWatch)
   - Log rotation
   - Log analysis and alerting

3. **Metrics**
   - Resource usage (CPU, memory, disk)
   - Application metrics (response time, error rate)
   - Business metrics (users, appointments, conversations)

4. **Alerting**
   - Setup alerts for critical issues
   - Define escalation procedures
   - Monitor LLM API usage and costs

## Monitoring & Maintenance

### Docker Container Management

```bash
# View logs
docker-compose logs -f [service_name]

# Restart a service
docker-compose restart [service_name]

# Update images
docker-compose pull
docker-compose up -d

# Clean up
docker system prune -a
```

### Database Maintenance

```bash
# Backup
docker exec dental-postgres pg_dump -U dental_user dental_chatbot > backup.sql

# Restore
docker exec -i dental-postgres psql -U dental_user dental_chatbot < backup.sql

# Access database
docker exec -it dental-postgres psql -U dental_user -d dental_chatbot
```

### Updating the Application

```bash
# Pull latest changes
git pull origin main

# Rebuild and restart
docker-compose up -d --build

# Or with zero downtime (blue-green deployment)
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build --no-deps [service_name]
```

### Troubleshooting

1. **Services won't start**
   ```bash
   docker-compose logs
   docker-compose ps
   ```

2. **Database connection issues**
   ```bash
   docker exec dental-postgres pg_isready -U dental_user
   ```

3. **High resource usage**
   ```bash
   docker stats
   ```

4. **Check disk space**
   ```bash
   df -h
   docker system df
   ```

## Rollback Procedure

If deployment fails:

```bash
# Rollback to previous version
git checkout [previous_commit_hash]
docker-compose up -d --build

# Or restore from backup
docker-compose down
docker volume rm chatbot_for_appointment_postgres-data
docker volume create chatbot_for_appointment_postgres-data
# Restore database from backup
docker-compose up -d
```

## Cost Optimization

1. **LLM Costs**
   - Use GPT-3.5-turbo instead of GPT-4 for lower costs
   - Implement response caching
   - Set token limits

2. **Infrastructure**
   - Use auto-scaling to match demand
   - Reserved instances for predictable workloads
   - Shutdown dev environments when not in use

3. **Monitoring**
   - Track API usage
   - Set budget alerts
   - Regular cost analysis

## Support

For deployment issues:
- Check troubleshooting section in README.md
- Review logs for error messages
- Open GitHub issue with details
- Contact support team

---

**Remember**: Always test deployments in a staging environment before production!

