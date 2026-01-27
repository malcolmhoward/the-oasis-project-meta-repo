# Issue Template: Foundation Files
# Creates issues for adding CLAUDE.md and CONTRIBUTING.md to component repos

TITLE="Add CLAUDE.md and CONTRIBUTING.md foundation files"
LABELS="documentation,enhancement"
META_ISSUE="22"
REPOS="mirage dawn spark aura beacon genesis"

read -r -d '' BODY << 'EOF'
## Summary
Add standard foundation files to this O.A.S.I.S. component repository.

## Tasks
- [ ] Add CLAUDE.md (LLM integration guidance)
- [ ] Add CONTRIBUTING.md (contribution guidelines)
- [ ] Review and update README.md if needed

## Template Source
Files should be based on S.C.O.P.E. templates:
- https://github.com/malcolmhoward/the-oasis-project-meta-repo/tree/main/templates/oasis-foundation

## Acceptance Criteria
- [ ] CLAUDE.md includes component-specific guidance
- [ ] CONTRIBUTING.md references O.A.S.I.S. community standards
- [ ] Changes ready for PR to upstream (The-OASIS-Project)
EOF