# Contributing to {COMPONENT_NAME}

Thank you for your interest in contributing to {COMPONENT_NAME} and the O.A.S.I.S. ecosystem!

## Getting Started

1. **Fork** the repository to your GitHub account
2. **Clone** your fork locally
3. **Set up** the development environment (see [GETTING_STARTED.md](GETTING_STARTED.md))
4. **Create a branch** for your changes

## Development Workflow

### Branch Naming

Use descriptive branch names with prefixes:

- `feat/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code refactoring
- `test/description` - Test additions or fixes

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): brief description

Longer description if needed.

Closes #123
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

### Pull Request Process

1. **Update documentation** if your changes affect usage
2. **Add tests** for new functionality
3. **Run all tests** locally before submitting
4. **Create PR** with clear description of changes
5. **Link related issues** using "Closes #123" or "Fixes #123"
6. **Request review** from maintainers

## Code Standards

### {Language} Style

{Language-specific style guidelines}

### Testing

- Write tests for all new features
- Maintain or improve code coverage
- Test on multiple platforms if possible

### Documentation

- Update README.md for user-facing changes
- Update CLAUDE.md for development-related changes
- Add inline comments for complex logic

## Types of Contributions

### Bug Reports

- Use the issue template
- Include hardware platform details
- Provide steps to reproduce
- Include relevant logs

### Feature Requests

- Check existing issues first
- Describe the use case
- Consider impact on other components

### Code Contributions

- Start with smaller issues labeled `good first issue`
- Discuss larger changes in an issue first
- Follow existing patterns in the codebase

### Documentation

- Fix typos and clarify confusing sections
- Add examples and tutorials
- Improve setup instructions

### Hardware Testing

- Test on different platforms (Pi, Jetson)
- Report compatibility findings
- Share hardware configurations that work well

## Communication

- **GitHub Issues** - Bug reports and feature requests
- **Pull Requests** - Code discussions
- **O.A.S.I.S. Discord** - Community chat (if available)

## Code of Conduct

Be respectful and inclusive. We're all here to build something awesome together.

## Recognition

Contributors will be acknowledged in release notes and the project README.

## Questions?

If you're unsure about anything, open an issue and ask! We're happy to help.

## Related Resources

- [S.C.O.P.E. Coordination](https://github.com/malcolmhoward/the-oasis-project-meta-repo) - Project-wide guidelines
- [Docker Development](https://github.com/malcolmhoward/the-oasis-project-meta-repo/blob/main/templates/docker/DOCKER_README.md) - Container patterns
