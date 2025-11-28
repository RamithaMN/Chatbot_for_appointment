# Contributing

Thanks for wanting to contribute! This guide will help you get started.

## Code of Conduct

Be respectful to everyone. We want this to be a welcoming place for all contributors. See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for details.

## How Can I Contribute?

### Reporting Bugs

Found a bug? Please check if someone else already reported it first. If not, open an issue with:

* A clear title
* Steps to reproduce
* What you expected vs what actually happened
* Screenshots if helpful
* Your environment (OS, Docker version, etc.)

### Suggesting Features

Got an idea? Open an issue and describe:

* What problem it solves
* How it would work
* Why it would be useful

Feel free to discuss it before spending time on implementation.

### Pull Requests

* Follow the PR template
* Keep the same coding style as the existing code
* Add tests if you're adding features
* Document new functionality
* Make sure your code works locally before submitting

## Development Process

### Setting Up Your Development Environment

1. **Fork the repository** and clone your fork:
   ```bash
   git clone https://github.com/your-username/Chatbot_for_appointment.git
   cd Chatbot_for_appointment
   ```

2. **Create a new branch** for your feature or bug fix:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

3. **Set up environment variables**:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Install dependencies**:
   ```bash
   # Backend
   cd backend && npm install && cd ..
   
   # Frontend
   cd frontend && npm install && cd ..
   
   # Chatbot service
   cd chatbot-service && pip install -r requirements.txt && cd ..
   ```

5. **Run the application**:
   ```bash
   # Using Docker (recommended)
   docker-compose up --build
   
   # Or manually start each service
   ```

### Coding Guidelines

**JavaScript/Node.js:**
* Use ES6+ features
* Meaningful variable names please
* Use async/await instead of callbacks
* Handle errors properly
* Add comments when things get complex

```javascript
// Good
async function fetchUserAppointments(userId) {
  try {
    const appointments = await db.query(
      'SELECT * FROM appointments WHERE user_id = $1',
      [userId]
    );
    return appointments.rows;
  } catch (error) {
    logger.error('Error fetching appointments:', error);
    throw error;
  }
}
```

**Python:**
* Follow PEP 8 (the linter will catch most issues)
* Add type hints when it makes sense
* Write docstrings for public functions
* Handle exceptions

```python
async def process_user_message(message: str, session_id: str) -> dict:
    """Process a user message and return the chatbot response."""
    try:
        response = await llm_chain.agenerate(message)
        return {
            "response": response.text,
            "session_id": session_id,
            "timestamp": datetime.now()
        }
    except Exception as e:
        logger.error(f"Error processing message: {e}")
        raise
```

#### React/TypeScript (Frontend)

* Use functional components with hooks
* Use TypeScript for type safety
* Follow the existing component structure
* Use meaningful component and variable names
* Extract reusable components
* Write PropTypes or TypeScript interfaces

Example:
```typescript
// Good
interface AppointmentCardProps {
  appointment: Appointment;
  onCancel: (id: string) => void;
  onReschedule: (id: string) => void;
}

export const AppointmentCard: React.FC<AppointmentCardProps> = ({
  appointment,
  onCancel,
  onReschedule
}) => {
  const handleCancel = useCallback(() => {
    onCancel(appointment.id);
  }, [appointment.id, onCancel]);

  return (
    <div className="appointment-card">
      {/* Component JSX */}
    </div>
  );
};
```

### Testing

* Write unit tests for new features
* Ensure all tests pass before submitting PR
* Aim for at least 80% code coverage
* Include both positive and negative test cases

```bash
# Run backend tests
cd backend && npm test

# Run frontend tests
cd frontend && npm test

# Run Python tests
cd chatbot-service && pytest
```

### Commit Messages

Keep them simple and clear:
```
Add appointment cancellation

- Added cancel button
- API endpoint for cancellation
- Confirmation dialog

Fixes #123
```

No need to be too formal, just make it clear what changed.

### Documentation

* Update the README.md with details of changes to the interface
* Update the API documentation if you change endpoints
* Add JSDoc/docstrings to new functions
* Update the CHANGELOG.md following the Keep a Changelog format

## Project Structure

```
Chatbot_for_appointment/
├── backend/              # Node.js Express API
├── frontend/             # Next.js frontend
├── chatbot-service/      # Python LangChain service
├── database/             # Database schemas and migrations
├── nginx/                # Nginx configuration
├── .github/              # GitHub workflows and templates
├── docs/                 # Additional documentation
└── tests/                # Integration tests
```

## Style Guides

### Git Branch Naming

* `feature/` - New features
* `fix/` - Bug fixes
* `docs/` - Documentation changes
* `refactor/` - Code refactoring
* `test/` - Adding or updating tests
* `chore/` - Maintenance tasks

Examples:
* `feature/appointment-reminders`
* `fix/chat-message-sanitization`
* `docs/api-endpoints-guide`

### Pull Request Process

1. Update the README.md or relevant documentation with details of changes
2. Update the .env.example if you add new environment variables
3. Increase version numbers in package.json files following [SemVer](http://semver.org/)
4. The PR will be merged once you have the sign-off of at least one maintainer

### PR Title Format

* `feat: Add appointment reminder feature`
* `fix: Resolve chat message duplication issue`
* `docs: Update API documentation`
* `refactor: Improve chatbot response handling`
* `test: Add integration tests for auth flow`
* `chore: Update dependencies`

## Questions?

Just open an issue if you're unsure about something. We're happy to help!

---

Thanks for contributing! 🙏

