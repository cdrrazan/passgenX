# Contributing to PassgenX

Thank you for your interest in contributing! Here are some guidelines to help you get started.

## How to Contribute

1. **Bug Reports**: If you find a bug, please create an issue describing the problem, steps to reproduce, and expected behavior.
2. **Feature Requests**: Open an issue to discuss new features before implementation.
3. **Pull Requests**:
   - Fork the repository.
   - Create a feature branch (`git checkout -b feature/cool-new-feature`).
   - Run tests (`bundle exec rspec`) and ensure they pass.
   - Run RuboCop (`bundle exec rubocop`) to check for style issues.
   - Commit your changes and push to your fork.
   - Open a Pull Request.

## Development Setup

1. Install dependencies:
   ```bash
   bundle install
   ```
2. Run tests:
   ```bash
   bundle exec rake spec
   ```
3. Run RuboCop:
   ```bash
   bundle exec rubocop
   ```
