#!/bin/bash
# UserPromptSubmit hook that forces explicit skill evaluation
#
# This hook requires Claude to explicitly evaluate each available skill
# before proceeding with implementation.
#
# Source: https://scottspence.com/posts/how-to-make-claude-code-skills-activate-reliably#how-to-use-the-forced-eval-hook

cat <<'EOF'
INSTRUCTION: MANDATORY SKILL ACTIVATION SEQUENCE

Step 1 - EVALUATE (do this in your response):
For each skill in <available_skills>, state: [skill-name] - YES/NO - [reason]

Step 2 - ACTIVATE (do this immediately after Step 1):
IF any skills are YES → Use Skill(skill-name) tool for EACH relevant skill NOW
IF no skills are YES → State "No skills needed" and proceed

Step 3 - IMPLEMENT:
Only after Step 2 is complete, proceed with implementation.

CRITICAL RULES:
1. You MUST call Skill() tool in Step 2. Do NOT skip to implementation.
2. If you evaluated YES for a skill, you are FORBIDDEN from doing that task manually.
3. Skills contain institutional knowledge you don't have. Manual implementation will miss context.

COMMON FAILURE (DO NOT DO THIS):
❌ Evaluate "linear:create-ticket: YES" then manually call Linear MCP tools
❌ Evaluate "graphql: YES" then manually write .gql files without the skill
✅ Evaluate YES → Call Skill() → Let skill guide implementation

Example of correct sequence:
- graphql: YES - working with .gql files
- skill-creator: NO - not creating a new skill

[Then IMMEDIATELY use Skill() tool:]
> Skill(graphql)

[THEN and ONLY THEN start implementation]
EOF
