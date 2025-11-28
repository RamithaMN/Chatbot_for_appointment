# Testing Guide

## Overview

This guide covers testing strategies and best practices for the Dental Chatbot Application.

## Test Structure

```
project/
├── backend/
│   ├── tests/
│   │   ├── unit/
│   │   ├── integration/
│   │   └── e2e/
├── frontend/
│   ├── __tests__/
│   │   ├── components/
│   │   ├── pages/
│   │   └── utils/
├── chatbot-service/
│   ├── tests/
│   │   ├── test_chatbot_chain.py
│   │   ├── test_llm_provider.py
│   │   └── test_conversation_manager.py
```

## Running Tests

### Backend Tests (Node.js)

```bash
cd backend

# Run all tests
npm test

# Run with coverage
npm test -- --coverage

# Run specific test file
npm test -- tests/unit/auth.test.js

# Run in watch mode
npm test -- --watch
```

### Frontend Tests (React/Next.js)

```bash
cd frontend

# Run all tests
npm test

# Run with coverage
npm test -- --coverage

# Run specific test
npm test -- __tests__/components/ChatBox.test.tsx

# Run in watch mode
npm test -- --watch

# Run E2E tests with Playwright
npm run test:e2e
```

### Chatbot Service Tests (Python)

```bash
cd chatbot-service

# Activate virtual environment
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Run all tests
pytest

# Run with coverage
pytest --cov=. --cov-report=html

# Run specific test file
pytest tests/test_chatbot_chain.py

# Run specific test function
pytest tests/test_chatbot_chain.py::test_process_message

# Run tests by marker
pytest -m unit
pytest -m integration

# Verbose output
pytest -v

# Show print statements
pytest -s
```

## Writing Tests

### Backend Unit Tests (Jest)

```javascript
// tests/unit/auth.test.js
const { hashPassword, verifyPassword } = require('../../auth');

describe('Authentication', () => {
  describe('hashPassword', () => {
    it('should hash password correctly', async () => {
      const password = 'testpassword123';
      const hashed = await hashPassword(password);
      
      expect(hashed).toBeDefined();
      expect(hashed).not.toBe(password);
      expect(hashed.length).toBeGreaterThan(0);
    });
  });

  describe('verifyPassword', () => {
    it('should verify correct password', async () => {
      const password = 'testpassword123';
      const hashed = await hashPassword(password);
      const isValid = await verifyPassword(password, hashed);
      
      expect(isValid).toBe(true);
    });

    it('should reject incorrect password', async () => {
      const password = 'testpassword123';
      const hashed = await hashPassword(password);
      const isValid = await verifyPassword('wrongpassword', hashed);
      
      expect(isValid).toBe(false);
    });
  });
});
```

### Frontend Component Tests (React Testing Library)

```typescript
// __tests__/components/ChatBox.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { ChatBox } from '@/components/ChatBox';

describe('ChatBox Component', () => {
  it('renders chat input', () => {
    render(<ChatBox />);
    const input = screen.getByPlaceholderText(/type a message/i);
    expect(input).toBeInTheDocument();
  });

  it('sends message on submit', async () => {
    const onSendMessage = jest.fn();
    render(<ChatBox onSendMessage={onSendMessage} />);
    
    const input = screen.getByPlaceholderText(/type a message/i);
    const button = screen.getByRole('button', { name: /send/i });
    
    fireEvent.change(input, { target: { value: 'Hello' } });
    fireEvent.click(button);
    
    await waitFor(() => {
      expect(onSendMessage).toHaveBeenCalledWith('Hello');
    });
  });

  it('clears input after sending', async () => {
    render(<ChatBox onSendMessage={jest.fn()} />);
    
    const input = screen.getByPlaceholderText(/type a message/i) as HTMLInputElement;
    const button = screen.getByRole('button', { name: /send/i });
    
    fireEvent.change(input, { target: { value: 'Hello' } });
    fireEvent.click(button);
    
    await waitFor(() => {
      expect(input.value).toBe('');
    });
  });
});
```

### Python Tests (pytest)

```python
# tests/test_chatbot_chain.py
import pytest
from unittest.mock import Mock, patch
from chatbot_chain import ChatbotChain

@pytest.fixture
def chatbot_chain():
    """Fixture to create a ChatbotChain instance"""
    return ChatbotChain(llm_provider="mock")

class TestChatbotChain:
    def test_process_message(self, chatbot_chain):
        """Test basic message processing"""
        response = chatbot_chain.process_message(
            message="Hello",
            session_id="test-session"
        )
        
        assert response is not None
        assert "response" in response
        assert isinstance(response["response"], str)
    
    @pytest.mark.asyncio
    async def test_async_process_message(self, chatbot_chain):
        """Test async message processing"""
        response = await chatbot_chain.aprocess_message(
            message="Book an appointment",
            session_id="test-session"
        )
        
        assert response is not None
        assert "appointment" in response["response"].lower()
    
    def test_conversation_history(self, chatbot_chain):
        """Test conversation history is maintained"""
        session_id = "test-session-history"
        
        chatbot_chain.process_message("Hello", session_id)
        chatbot_chain.process_message("How are you?", session_id)
        
        history = chatbot_chain.get_conversation_history(session_id)
        
        assert len(history) >= 2
        assert any("Hello" in msg for msg in history)
```

### Integration Tests

```javascript
// tests/integration/api.test.js
const request = require('supertest');
const app = require('../../app');

describe('API Integration Tests', () => {
  let authToken;

  beforeAll(async () => {
    // Login to get auth token
    const response = await request(app)
      .post('/api/chatbot/login')
      .send({
        username: 'demo',
        password: 'demo123'
      });
    
    authToken = response.body.access_token;
  });

  describe('POST /api/chatbot/chat', () => {
    it('should send message and receive response', async () => {
      const response = await request(app)
        .post('/api/chatbot/chat')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          message: 'I need a dental checkup'
        });
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('response');
      expect(response.body).toHaveProperty('session_id');
    });

    it('should return 401 without auth token', async () => {
      const response = await request(app)
        .post('/api/chatbot/chat')
        .send({
          message: 'Hello'
        });
      
      expect(response.status).toBe(401);
    });
  });
});
```

## Test Coverage

### Check Coverage

```bash
# Backend
cd backend && npm test -- --coverage

# Frontend
cd frontend && npm test -- --coverage

# Python
cd chatbot-service && pytest --cov=. --cov-report=html
```

### Coverage Goals

- **Unit Tests**: 80% or higher
- **Integration Tests**: 70% or higher
- **E2E Tests**: Critical user flows

## Mocking

### Mock LLM Provider

```python
# tests/conftest.py
import pytest
from unittest.mock import Mock

@pytest.fixture
def mock_llm_provider():
    """Mock LLM provider for testing"""
    provider = Mock()
    provider.generate.return_value = {
        "text": "This is a mock response",
        "tokens_used": 50
    }
    return provider
```

### Mock API Calls

```typescript
// __tests__/utils/api.test.ts
import { sendMessage } from '@/utils/api';

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

describe('API Utils', () => {
  it('should send message successfully', async () => {
    mockedAxios.post.mockResolvedValue({
      data: { response: 'Hello!' }
    });

    const result = await sendMessage('Hi');
    expect(result.response).toBe('Hello!');
  });
});
```

## End-to-End Testing

### Playwright E2E Tests

```typescript
// e2e/chat.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Chat Flow', () => {
  test('complete chat conversation', async ({ page }) => {
    // Navigate to app
    await page.goto('http://localhost:3000');

    // Login
    await page.fill('[name="username"]', 'demo');
    await page.fill('[name="password"]', 'demo123');
    await page.click('button[type="submit"]');

    // Wait for chat interface
    await page.waitForSelector('[data-testid="chat-box"]');

    // Send message
    await page.fill('[data-testid="message-input"]', 'Hello');
    await page.click('[data-testid="send-button"]');

    // Check response
    await expect(page.locator('[data-testid="chat-messages"]'))
      .toContainText('Hello', { timeout: 10000 });
  });
});
```

## CI/CD Testing

Tests are automatically run in GitHub Actions on:
- Every push to main/develop
- Every pull request

See `.github/workflows/ci.yml` for configuration.

## Performance Testing

### Load Testing with Artillery

```yaml
# load-test.yml
config:
  target: 'http://localhost:8000'
  phases:
    - duration: 60
      arrivalRate: 10
scenarios:
  - name: 'Chat API'
    flow:
      - post:
          url: '/api/chatbot/login'
          json:
            username: 'demo'
            password: 'demo123'
          capture:
            - json: '$.access_token'
              as: 'token'
      - post:
          url: '/api/chatbot/chat'
          headers:
            Authorization: 'Bearer {{ token }}'
          json:
            message: 'Hello'
```

Run load test:
```bash
artillery run load-test.yml
```

## Best Practices

### 1. Test Naming

```javascript
// Good
test('should send message when button is clicked')

// Bad
test('test1')
```

### 2. Arrange-Act-Assert Pattern

```javascript
test('should validate email format', () => {
  // Arrange
  const email = 'invalid-email';
  
  // Act
  const result = validateEmail(email);
  
  // Assert
  expect(result).toBe(false);
});
```

### 3. Test Isolation

Each test should be independent and not rely on other tests.

### 4. Use Fixtures and Factories

```python
@pytest.fixture
def sample_user():
    return {
        "username": "testuser",
        "email": "test@example.com",
        "password": "secure123"
    }
```

### 5. Test Edge Cases

- Empty inputs
- Invalid data
- Boundary conditions
- Error scenarios

### 6. Keep Tests Fast

- Use mocks for external dependencies
- Avoid unnecessary database calls
- Run slow tests separately

## Debugging Tests

### Jest Debugging

```bash
# Run specific test with debugger
node --inspect-brk node_modules/.bin/jest --runInBand tests/unit/auth.test.js
```

### Pytest Debugging

```bash
# Run with pdb
pytest --pdb

# Drop into debugger on failure
pytest -x --pdb
```

## Test Maintenance

- Review and update tests with code changes
- Remove obsolete tests
- Refactor duplicated test code
- Keep test dependencies up to date

## Resources

- [Jest Documentation](https://jestjs.io/)
- [React Testing Library](https://testing-library.com/react)
- [Pytest Documentation](https://docs.pytest.org/)
- [Playwright Documentation](https://playwright.dev/)

---

**Remember**: Good tests are the foundation of maintainable code!

