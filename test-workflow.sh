#!/bin/bash

# Test script to simulate the CHANGELOG workflow locally

# Reset CHANGELOG to initial state
cat > CHANGELOG.md << 'EOF'
# Changelog

## Latest Release
EOF

echo "=== Testing CHANGELOG Update Workflow ==="
echo ""

# Test case 1: Normal PR
echo "Test 1: Normal PR"
export PR_TITLE="Add new feature to improve performance"
export PR_NUMBER="123"
export PR_URL="https://github.com/test/repo/pull/123"
export GITHUB_REPOSITORY="test/repo"

echo "PR Title: $PR_TITLE"
echo "PR Number: $PR_NUMBER"

# Check if PR should be ignored (starts with "internal" - case insensitive)
if [[ "$PR_TITLE" =~ ^[Ii][Nn][Tt][Ee][Rr][Nn][Aa][Ll] ]]; then
  echo "✓ Should skip: true"
  SHOULD_SKIP=true
else
  echo "✓ Should skip: false"
  SHOULD_SKIP=false
fi

# Check if PR is a release (starts with "release" - case insensitive)
if [[ "$PR_TITLE" =~ ^[Rr][Ee][Ll][Ee][Aa][Ss][Ee] ]]; then
  echo "✓ Is release: true"
  IS_RELEASE=true
  VERSION=$(echo "$PR_TITLE" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+')
  echo "✓ Version: $VERSION"
else
  echo "✓ Is release: false"
  IS_RELEASE=false
fi

if [ "$SHOULD_SKIP" = "false" ]; then
  echo "✓ Processing PR..."
  
  # Backup original CHANGELOG
  cp CHANGELOG.md CHANGELOG.md.backup
  
  if [ "$IS_RELEASE" = "false" ]; then
    # Normal PR - add to Latest Release section
    python3 << 'PYTHON_SCRIPT'
import re
import os

title = os.environ.get('PR_TITLE')
pr_number = os.environ.get('PR_NUMBER')
pr_url = os.environ.get('PR_URL')
repo = os.environ.get('GITHUB_REPOSITORY')

with open('CHANGELOG.md', 'r') as f:
    content = f.read()

# Create the PR entry
pr_entry = f"- [{repo}#{pr_number}]({pr_url}) {title}"

# Find the "Latest Release" section and add the entry after it
pattern = r'(## Latest Release\s*\n)'

if re.search(pattern, content):
    content = re.sub(
        pattern,
        r'\1' + pr_entry + '\n',
        content,
        count=1
    )
else:
    content = "# Changelog\n\n## Latest Release\n" + pr_entry + "\n\n" + content

with open('CHANGELOG.md', 'w') as f:
    f.write(content)

print("✓ Updated CHANGELOG.md")
PYTHON_SCRIPT
  fi
  
  echo ""
  echo "=== Updated CHANGELOG.md ==="
  cat CHANGELOG.md
  echo ""
fi

echo ""
echo "==========================="
echo ""

# Test case 2: Internal PR (should be skipped)
echo "Test 2: Internal PR (should be skipped)"
export PR_TITLE="Internal Release Build 2.3210.012+3487"
export PR_NUMBER="124"

echo "PR Title: $PR_TITLE"

if [[ "$PR_TITLE" =~ ^[Ii][Nn][Tt][Ee][Rr][Nn][Aa][Ll] ]]; then
  echo "✓ Should skip: true (SKIPPED)"
else
  echo "✗ Should skip: false (ERROR - should have been skipped)"
fi

echo ""
echo "==========================="
echo ""

# Restore backup for next test
cp CHANGELOG.md.backup CHANGELOG.md

# Test case 3: Release PR
echo "Test 3: Release PR"
export PR_TITLE="Release Build 2.2154.009+3467"
export PR_NUMBER="125"
export PR_URL="https://github.com/test/repo/pull/125"

echo "PR Title: $PR_TITLE"

if [[ "$PR_TITLE" =~ ^[Rr][Ee][Ll][Ee][Aa][Ss][Ee] ]]; then
  echo "✓ Is release: true"
  export VERSION=$(echo "$PR_TITLE" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+')
  echo "✓ Version: $VERSION"
  
  python3 << 'PYTHON_SCRIPT'
import re
import os

version = os.environ.get('VERSION')
pr_number = os.environ.get('PR_NUMBER')
pr_url = os.environ.get('PR_URL')

with open('CHANGELOG.md', 'r') as f:
    content = f.read()

# Create new version section
new_section = f"### [{version}]({pr_url})"
content = re.sub(
    r'## Latest Release',
    f'## Latest Release\n\n{new_section}',
    content,
    count=1
)

with open('CHANGELOG.md', 'w') as f:
    f.write(content)

print("✓ Updated CHANGELOG.md with release version")
PYTHON_SCRIPT
  
  echo ""
  echo "=== Updated CHANGELOG.md ==="
  cat CHANGELOG.md
  echo ""
fi

echo ""
echo "==========================="
echo "All tests completed!"

# Clean up
rm CHANGELOG.md.backup
