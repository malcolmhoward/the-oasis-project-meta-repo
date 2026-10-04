# Issue Summary Prompt

Use this prompt to get Claude to summarize open issues across O.A.S.I.S. repositories.

## Prompt

```
Please summarize the open issues in the O.A.S.I.S. project repositories.

For each repository, list:
1. Number of open issues
2. Key themes or categories
3. Any blockers or high-priority items

Repositories to check:
- malcolmhoward/the-oasis-project-meta-repo (S.C.O.P.E.)
- malcolmhoward/mirage
- malcolmhoward/dawn
- malcolmhoward/spark
- malcolmhoward/aura
- malcolmhoward/beacon
- malcolmhoward/genesis

Format the output as a table with columns:
| Repo | Open Issues | Key Themes | Priority Items |
```

## Usage

This prompt works best when Claude has access to:
- GitHub CLI (`gh issue list`)
- Repository access via submodules

## Example Output

| Repo | Open Issues | Key Themes | Priority Items |
|------|-------------|------------|----------------|
| S.C.O.P.E. | 21 | Setup, Docs, Docker | Foundation templates |
| MIRAGE | 5 | Display, Camera | HUD rendering |
| DAWN | 3 | TTS, LLM | Voice recognition |
