#!/bin/bash
# UserPromptSubmit hook that forces skill activation when one applies.
#
# Original (verbose) version asked Claude to enumerate every available skill
# with YES/NO + reason on every turn. That bloats every response with a
# checklist that's mostly NOs. This version keeps the enforcement (use the
# skill if one applies; never reimplement what a skill covers) but drops the
# per-skill recital.

cat <<'EOF'
SKILL CHECK:
- If a skill in <available_skills> applies, name it and call Skill(name) BEFORE doing any work. Do not reimplement what the skill covers.
- If none apply, say "No skills needed" and proceed.
- Do not enumerate skills that don't apply.
EOF
