#!/bin/bash

# Full scenario test: simulates real PR workflow

echo "=== Full Scenario Test ==="
echo "Simulating multiple PRs being merged in sequence"
echo ""

# Initialize CHANGELOG
cat > CHANGELOG.md << 'EOF'
# Changelog

## Latest Release
EOF

echo "Initial CHANGELOG.md:"
cat CHANGELOG.md
echo ""
echo "================================"
echo ""

# Function to add normal PR
add_normal_pr() {
  local title="$1"
  local number="$2"
  local url="$3"
  
  echo "→ Merging PR #$number: $title"
  
  export PR_TITLE="$title"
  export PR_NUMBER="$number"
  export PR_URL="$url"
  export GITHUB_REPOSITORY="test/repo"
  
  python3 << 'PYTHON_SCRIPT'
import re
import os

title = os.environ.get('PR_TITLE')
pr_number = os.environ.get('PR_NUMBER')
pr_url = os.environ.get('PR_URL')
repo = os.environ.get('GITHUB_REPOSITORY')

with open('CHANGELOG.md', 'r') as f:
    content = f.read()

pr_entry = f"- [{repo}#{pr_number}]({pr_url}) {title}"
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
PYTHON_SCRIPT
}

# Function to add release PR
add_release_pr() {
  local title="$1"
  local number="$2"
  local url="$3"
  
  echo "→ Merging RELEASE PR #$number: $title"
  
  export VERSION=$(echo "$title" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+')
  export PR_NUMBER="$number"
  export PR_URL="$url"
  
  echo "  Version extracted: $VERSION"
  
  python3 << 'PYTHON_SCRIPT'
import re
import os

version = os.environ.get('VERSION')
pr_number = os.environ.get('PR_NUMBER')
pr_url = os.environ.get('PR_URL')

with open('CHANGELOG.md', 'r') as f:
    content = f.read()

new_section = f"### [{version}]({pr_url})"
content = re.sub(
    r'## Latest Release',
    f'## Latest Release\n\n{new_section}',
    content,
    count=1
)

with open('CHANGELOG.md', 'w') as f:
    f.write(content)
PYTHON_SCRIPT
}

# Simulate realistic workflow
echo "Step 1: Add some PRs"
add_normal_pr "Fix navigation bug" "101" "https://github.com/test/repo/pull/101"
add_normal_pr "Update dependencies" "102" "https://github.com/test/repo/pull/102"
add_normal_pr "Improve performance" "103" "https://github.com/test/repo/pull/103"

echo ""
cat CHANGELOG.md
echo ""
echo "================================"
echo ""

echo "Step 2: Release version 3.38.4"
add_release_pr "Release Build 3.38.4+1234" "104" "https://github.com/test/repo/pull/104"

echo ""
cat CHANGELOG.md
echo ""
echo "================================"
echo ""

echo "Step 3: Add more PRs for next release"
add_normal_pr "Add dark mode" "105" "https://github.com/test/repo/pull/105"
add_normal_pr "Fix memory leak" "106" "https://github.com/test/repo/pull/106"

echo ""
cat CHANGELOG.md
echo ""
echo "================================"
echo ""

echo "Step 4: Skip internal PR"
echo "→ Skipping PR #107: Internal Release Build 2.3210.012+3487"

echo ""
echo "================================"
echo ""

echo "Step 5: Add one more PR"
add_normal_pr "Update documentation" "108" "https://github.com/test/repo/pull/108"

echo ""
cat CHANGELOG.md
echo ""
echo "================================"
echo ""

echo "Step 6: Release version 3.38.5"
add_release_pr "Release Build 3.38.5+5678" "109" "https://github.com/test/repo/pull/109"

echo ""
echo "Final CHANGELOG.md:"
cat CHANGELOG.md
echo ""
echo "================================"
echo "✓ Full scenario test completed!"
