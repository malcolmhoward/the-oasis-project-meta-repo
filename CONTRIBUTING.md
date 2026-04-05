# Contributing to S.C.O.P.E.

<!--
TEMPLATE NOTICE: This is a comprehensive contribution guide template.
Customize sections marked with [CUSTOMIZE] for your project's specific needs.
-->

Thank you for your interest in contributing to S.C.O.P.E.!

This guide explains our contribution workflow, conventions, and review process.

---

## Before You Start

### Understanding Our Workflow

We use a **fork-first workflow**. This means:
- You work on your own copy (fork) of the repository
- Changes are proposed via Pull Requests from your fork
- This keeps the main repository clean and secure

### Why Fork-First?

1. **Security**: Only maintainers have write access to the main repo
2. **Experimentation**: You can freely experiment in your fork
3. **Learning**: Great practice for contributing to any open source project
4. **Backup**: Your fork serves as a backup of your work

---

## Fork-First Workflow

### Step 1: Fork the Repository

1. Click the "Fork" button on the repository page
2. This creates your personal copy at `github.com/YOUR-USERNAME/s.c.o.p.e.`

### Step 2: Clone Your Fork

```bash
# Clone your fork locally
git clone https://github.com/YOUR-USERNAME/s.c.o.p.e..git
cd s.c.o.p.e.

# Add the original repo as "upstream" for syncing
git remote add upstream https://github.com/ORIGINAL-OWNER/s.c.o.p.e..git
```

### Step 3: Keep Your Fork Updated

```bash
# Fetch upstream changes
git fetch upstream

# Merge upstream main into your local main
git checkout main
git merge upstream/main

# Push updates to your fork
git push origin main
```

### Step 4: Create a Feature Branch

**Never work directly on `main`**. Always create a branch:

```bash
git checkout -b type/description
```

---

## Branch Naming Conventions

Use descriptive branch names following this pattern:

```
type/short-description
```

### Branch Types

| Type | Purpose | Example |
|------|---------|---------|
| `feat/` | New feature | `feat/user-authentication` |
| `fix/` | Bug fix | `fix/login-validation` |
| `docs/` | Documentation only | `docs/api-examples` |
| `refactor/` | Code restructuring | `refactor/database-layer` |
| `test/` | Adding/updating tests | `test/auth-unit-tests` |
| `chore/` | Maintenance tasks | `chore/update-dependencies` |

### Good Branch Names
- `feat/add-dark-mode`
- `fix/memory-leak-on-upload`
- `docs/installation-guide`

### Avoid
- `my-changes` (not descriptive)
- `fix` (too vague)
- `john-branch` (personal names)

---

## Conventional Commits

We follow [Conventional Commits](https://www.conventionalcommits.org/) for clear, consistent history.

### Format

```
type(scope): description

[optional body]

[optional footer]
```

### Commit Types

| Type | When to Use |
|------|-------------|
| `feat` | Adding new functionality |
| `fix` | Fixing a bug |
| `docs` | Documentation changes only |
| `style` | Formatting (no code logic change) |
| `refactor` | Restructuring without behavior change |
| `test` | Adding or updating tests |
| `chore` | Maintenance (dependencies, configs) |

### Examples

```bash
# Feature
git commit -m "feat(auth): add password reset flow"

# Bug fix
git commit -m "fix(api): handle null response from server"

# Documentation
git commit -m "docs(readme): add installation instructions"

# Breaking change (note the !)
git commit -m "feat(api)!: change authentication endpoint"
```

### Why Conventional Commits?

1. **Automatic changelogs**: Tools can generate release notes
2. **Clear history**: Easy to understand what changed and why
3. **Semantic versioning**: Commit types inform version bumps
4. **Better reviews**: Reviewers understand intent quickly

---

## Suggesting Features

### Before Proposing

1. **Search existing issues** - your idea may already be discussed
2. **Check the roadmap** - it might be planned already
3. **Consider scope** - does it fit the project's goals?

### Priority Assessment

When proposing features, consider these factors:

| Factor | Questions to Ask |
|--------|------------------|
| **Impact** | How many users benefit? How significant is the improvement? |
| **Effort** | How complex is implementation? What's the maintenance burden? |
| **Risk** | What could break? Are there security implications? |
| **Alignment** | Does it fit project goals and architecture? |

### Feature Request Template

```markdown
## Problem Statement
What problem does this solve?

## Proposed Solution
How should it work?

## Alternatives Considered
What other approaches exist?

## Priority Assessment
- Impact: [High/Medium/Low]
- Effort: [High/Medium/Low]
- Risk: [High/Medium/Low]
```

---

## Code Review Process

### What Reviewers Look For

1. **Correctness**: Does the code do what it claims?
2. **Tests**: Are changes covered by tests?
3. **Style**: Does it follow project conventions?
4. **Documentation**: Are changes documented?
5. **Security**: Are there any vulnerabilities?
6. **Performance**: Any performance implications?

### Educational Review Criteria

We review with education in mind:

| Criteria | What We Check |
|----------|---------------|
| **Clarity** | Is the code readable and self-documenting? |
| **Simplicity** | Is this the simplest solution that works? |
| **Maintainability** | Will future contributors understand this? |
| **Best Practices** | Does it follow established patterns? |

### Responding to Feedback

- **Be open**: Feedback improves code quality
- **Ask questions**: If something is unclear, ask
- **Iterate**: Multiple rounds of review are normal
- **Learn**: Each review is a learning opportunity

---

## Pull Request Process

### Before Submitting

- [ ] Code compiles/runs without errors
- [ ] Tests pass locally
- [ ] Branch is up-to-date with main
- [ ] Commit messages follow conventions
- [ ] Documentation updated if needed

### PR Description Template

```markdown
## Summary
Brief description of changes.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation
- [ ] Refactoring

## Testing
How were changes tested?

## Checklist
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
```

### After Submitting

1. **Respond to reviews** within a reasonable timeframe
2. **Push fixes** as new commits (easier to review)
3. **Request re-review** after addressing feedback
4. **Squash commits** will happen on merge (if configured)

---

## Coding Standards

[CUSTOMIZE: Add your project-specific coding standards here]

### General Guidelines

- Write clear, self-documenting code
- Include comments for complex logic
- Follow existing patterns in the codebase
- Keep functions focused and small

### Testing Requirements

[CUSTOMIZE: Specify your testing requirements]

- Unit tests for new functionality
- Integration tests for API changes
- All tests must pass before merge

---

## Code of Conduct

[CUSTOMIZE: Reference your CODE_OF_CONDUCT.md if you have one]

We are committed to providing a welcoming and inclusive environment.
Please be respectful and constructive in all interactions.

---

## Getting Help

- **Questions**: [CUSTOMIZE: Where should questions go?]
- **Bugs**: Open an issue with the bug report template
- **Features**: Open an issue with the feature request template

