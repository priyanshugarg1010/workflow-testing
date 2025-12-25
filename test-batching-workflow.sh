#!/bin/bash

# Test script for batching workflow logic

echo "=== Testing Batching Workflow ==="
echo ""

# Initialize CHANGELOG
cat > CHANGELOG.md << 'EOF'
# Changelog
EOF

echo "Initial CHANGELOG.md:"
cat CHANGELOG.md
echo ""
echo "================================"
echo ""

# Function to simulate release with PR batching
simulate_release() {
  local version="$1"
  local pr_number="$2"
  local pr_url="$3"
  local is_new_version="$4"
  shift 4
  local prs=("$@")
  
  echo "→ Processing Release: $version (PR #$pr_number)"
  echo "  New Version: $is_new_version"
  echo "  PRs to include: ${#prs[@]}"
  
  export CURRENT_VERSION="$version"
  export CURRENT_PR_URL="$pr_url"
  export IS_NEW_VERSION="$is_new_version"
  export REPO="test/repo"
  
  # Write PRs to file
  > normal_prs.txt
  for pr_data in "${prs[@]}"; do
    echo "$pr_data" >> normal_prs.txt
  done
  
  python3 << 'PYTHON_SCRIPT'
import re
import os

current_version = os.environ.get('CURRENT_VERSION')
current_pr_url = os.environ.get('CURRENT_PR_URL')
is_new_version = os.environ.get('IS_NEW_VERSION')
repo = os.environ.get('REPO')

# Read the CHANGELOG
with open('CHANGELOG.md', 'r') as f:
    content = f.read()

# Read the collected PRs
pr_entries = []
try:
    with open('normal_prs.txt', 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.split('|')
            if len(parts) == 3:
                pr_num, pr_title, pr_url = parts
                pr_entries.append(f"- [{repo}#{pr_num}]({pr_url}) {pr_title}")
except FileNotFoundError:
    pass

# Reverse to show newest first
pr_entries.reverse()

# Build the new version section
new_section = f"### [{current_version}]({current_pr_url})\n"
if pr_entries:
    new_section += "\n".join(pr_entries) + "\n"

# Check if this is a new major.minor version
if is_new_version == 'true':
    # Create a new version heading
    major_minor = '.'.join(current_version.split('.')[:2])
    version_heading = f"## Version {major_minor}\n\n"
    
    # Check if we already have content
    if content.strip() == "# Changelog":
        # First release
        content = f"# Changelog\n\n{version_heading}{new_section}\n"
    else:
        # Insert after the title
        content = re.sub(
            r'(# Changelog\s*\n)',
            r'\1\n' + version_heading + new_section + '\n',
            content,
            count=1
        )
else:
    # Same major.minor version - add to existing section
    major_minor = '.'.join(current_version.split('.')[:2])
    version_heading = f"## Version {major_minor}"
    
    # Find the version heading and add the new section after it
    pattern = re.escape(version_heading) + r'(\s*\n)'
    if re.search(pattern, content):
        content = re.sub(
            pattern,
            version_heading + r'\1\n' + new_section + '\n',
            content,
            count=1
        )
    else:
        # Version heading doesn't exist, create it
        content = re.sub(
            r'(# Changelog\s*\n)',
            r'\1\n' + version_heading + '\n\n' + new_section + '\n',
            content,
            count=1
        )

with open('CHANGELOG.md', 'w') as f:
    f.write(content)

print(f"✓ Added release {current_version} with {len(pr_entries)} PRs")
PYTHON_SCRIPT
}

# Scenario 1: First release (2.2154.x) with 3 PRs
echo "Scenario 1: First release in version 2.2154"
echo "---"
simulate_release "2.2154.001+1000" "100" "https://github.com/test/repo/pull/100" "true" \
  "101|Fix navigation bug|https://github.com/test/repo/pull/101" \
  "102|Update dependencies|https://github.com/test/repo/pull/102" \
  "103|Improve performance|https://github.com/test/repo/pull/103"

echo ""
cat CHANGELOG.md
echo ""
echo "================================"
echo ""

# Scenario 2: Another release in same version (2.2154.x) with 2 more PRs
echo "Scenario 2: Another release in same version 2.2154"
echo "---"
simulate_release "2.2154.009+3467" "104" "https://github.com/test/repo/pull/104" "false" \
  "105|Add dark mode|https://github.com/test/repo/pull/105" \
  "106|Fix memory leak|https://github.com/test/repo/pull/106"

echo ""
cat CHANGELOG.md
echo ""
echo "================================"
echo ""

# Scenario 3: One more release in same version (2.2154.x) with 1 PR
echo "Scenario 3: Third release in same version 2.2154"
echo "---"
simulate_release "2.2154.012+3500" "107" "https://github.com/test/repo/pull/107" "false" \
  "108|Update documentation|https://github.com/test/repo/pull/108"

echo ""
cat CHANGELOG.md
echo ""
echo "================================"
echo ""

# Scenario 4: NEW VERSION (2.2155.x) with 3 PRs - should create new section
echo "Scenario 4: NEW VERSION 2.2155 (major.minor changed)"
echo "---"
simulate_release "2.2155.001+3600" "109" "https://github.com/test/repo/pull/109" "true" \
  "110|Refactor authentication|https://github.com/test/repo/pull/110" \
  "111|Add new API endpoint|https://github.com/test/repo/pull/111" \
  "112|Fix login validation|https://github.com/test/repo/pull/112"

echo ""
echo "Final CHANGELOG.md:"
cat CHANGELOG.md
echo ""
echo "================================"
echo ""

# Scenario 5: Another release in new version (2.2155.x)
echo "Scenario 5: Second release in version 2.2155"
echo "---"
simulate_release "2.2155.005+3700" "113" "https://github.com/test/repo/pull/113" "false" \
  "114|Update UI components|https://github.com/test/repo/pull/114" \
  "115|Fix crash on startup|https://github.com/test/repo/pull/115"

echo ""
echo "Final CHANGELOG.md with two version groups:"
cat CHANGELOG.md
echo ""
echo "================================"
echo "✓ All scenarios completed!"

# Clean up
rm -f normal_prs.txt
