# Issue Template: Docker Configuration
# Creates issues for adding Docker configurations to applicable component repos

TITLE="Add Docker development configuration"
LABELS="docker,enhancement"
META_ISSUE="23"
# Only repos that need Docker (excludes genesis and beacon)
REPOS="mirage dawn spark aura"

read -r -d '' BODY << 'EOF'
## Summary
Add Docker configurations to enable containerized development and testing.

## Tasks
- [ ] Add Dockerfile.dev (development container with mock hardware)
- [ ] Add .dockerignore
- [ ] Document Docker usage in README.md
- [ ] Implement mock hardware patterns for development

## Platform-Specific (if applicable)
- [ ] Dockerfile.rpi (Raspberry Pi deployment)
- [ ] Dockerfile.jetson (NVIDIA Jetson deployment)

## Template Source
Patterns documented in S.C.O.P.E.:
- https://github.com/malcolmhoward/the-oasis-project-meta-repo/tree/main/docker

## Acceptance Criteria
- [ ] `docker build -f Dockerfile.dev .` succeeds
- [ ] Container runs with mock hardware
- [ ] HARDWARE_MODE environment variable documented
- [ ] Changes ready for PR to upstream (The-OASIS-Project)
EOF