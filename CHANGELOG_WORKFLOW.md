# CHANGELOG Workflow Documentation

## Overview

This GitHub Actions workflow automatically updates the `CHANGELOG.md` file whenever a **Release PR** is merged into the `main` branch. The workflow batches all normal PRs between releases and groups them by version (major.minor), while ignoring internal PRs.

## Workflow Trigger

The workflow runs when:
- A **Release PR** is **merged** into the `main` branch
- PR title contains "elease" (case-insensitive)
- PR title does NOT contain "nternal" (to exclude Internal Release PRs)
## How It Works

### 1. Trigger on Release PR Only

The workflow **only triggers** when a Release PR is merged. It does NOT run on every PR merge.

### 2. Version Comparison

When a Release PR is merged:
1. **Extracts version** from the Release PR title (format: `X.Y.Z+BUILD`)
2. **Finds the previous Release PR** (excluding Internal releases)
3. **Compares major.minor versions** (the first two numbers, e.g., `2.2154` from `2.2154.009+3467`)
4. **Determines if it's a new version**:
   - If `major.minor` changes (e.g., `2.2154` → `2.2155`): Creates a **new version group**
   - If `major.minor` is the same (e.g., `2.2154.001` → `2.2154.009`): Adds to **existing version group**

### 3. PR Batching

The workflow collects ALL PRs merged between the previous Release PR and the current Release PR:
- **Includes**: All normal PRs (any title that doesn't start with "Internal" or "Release")
- **Excludes**: Internal PRs (title starts with "Internal")
- **Excludes**: Other Release PRs

### 4. Version Extraction
### 2. Version Extraction

For Release PRs, the workflow extracts version numbers in the format: `X.Y.Z+BUILD`

**Pattern:** `[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+`

**Examples:**
- `Release Build 3.38.5+1234` → Extracts `3.38.5+1234`
- `release build 2.2154.009+3467` → Extracts `2.2154.009+3467`

### 5. CHANGELOG Format

The workflow maintains the following structure grouped by **major.minor** version:

```markdown
# Changelog

## Version 2.2155

### [2.2155.005+3700](https://github.com/owner/repo/pull/113)
- [owner/repo#115](https://github.com/owner/repo/pull/115) Fix crash on startup
- [owner/repo#114](https://github.com/owner/repo/pull/114) Update UI components

### [2.2155.001+3600](https://github.com/owner/repo/pull/109)
- [owner/repo#112](https://github.com/owner/repo/pull/112) Fix login validation
- [owner/repo#111](https://github.com/owner/repo/pull/111) Add new API endpoint
- [owner/repo#110](https://github.com/owner/repo/pull/110) Refactor authentication

## Version 2.2154

### [2.2154.009+3467](https://github.com/owner/repo/pull/104)
- [owner/repo#106](https://github.com/owner/repo/pull/106) Fix memory leak
- [owner/repo#105](https://github.com/owner/repo/pull/105) Add dark mode

### [2.2154.001+1000](https://github.com/owner/repo/pull/100)
- [owner/repo#103](https://github.com/owner/repo/pull/103) Improve performance
- [owner/repo#102](https://github.com/owner/repo/pull/102) Update dependencies
- [owner/repo#101](https://github.com/owner/repo/pull/101) Fix navigation bug
```

**Key Points:**
- Versions are grouped by `## Version X.Y` (major.minor)
- Each release within a version gets its own `### [X.Y.Z+BUILD](url)` section
- PRs are listed under the release they were included in
- Newest versions and releases appear first

## Examples

### Example 1: First Release PR

**Scenario:**
- PRs #101, #102, #103 were merged (normal PRs)
- Release PR #104 is merged: `Release Build 2.2154.001+1000`

**Before:**
```markdown
# Changelog
```

**After:**
```markdown
# Changelog

## Version 2.2154

### [2.2154.001+1000](https://github.com/myorg/myapp/pull/104)
- [myorg/myapp#103](https://github.com/myorg/myapp/pull/103) Fix memory leak
- [myorg/myapp#102](https://github.com/myorg/myapp/pull/102) Update dependencies
- [myorg/myapp#101](https://github.com/myorg/myapp/pull/101) Add dark mode
```

*All PRs before the first release are batched together*

---

### Example 2: Same Version Release (2.2154.x)

**Scenario:**
- After Release #104 (2.2154.001+1000)
- PRs #105, #106 were merged
- Release PR #107 is merged: `Release Build 2.2154.009+3467`
- **Major.minor is still 2.2154** (no change)

**Result:**
```markdown
# Changelog

## Version 2.2154

### [2.2154.009+3467](https://github.com/myorg/myapp/pull/107)
- [myorg/myapp#106](https://github.com/myorg/myapp/pull/106) Fix memory leak
- [myorg/myapp#105](https://github.com/myorg/myapp/pull/105) Add dark mode

### [2.2154.001+1000](https://github.com/myorg/myapp/pull/104)
- [myorg/myapp#103](https://github.com/myorg/myapp/pull/103) Fix memory leak  
- [myorg/myapp#102](https://github.com/myorg/myapp/pull/102) Update dependencies
- [myorg/myapp#101](https://github.com/myorg/myapp/pull/101) Add dark mode
```

*New release is added to the same version group since major.minor didn't change*

---

### Example 3: New Version Release (2.2155.x)

**Scenario:**
- After Release #107 (2.2154.009+3467)
- PRs #108, #109, #110 were merged
- Release PR #111 is merged: `Release Build 2.2155.001+3600`
- **Major.minor changed from 2.2154 to 2.2155** (NEW VERSION!)

**Result:**
```markdown
# Changelog

## Version 2.2155

### [2.2155.001+3600](https://github.com/myorg/myapp/pull/111)
- [myorg/myapp#110](https://github.com/myorg/myapp/pull/110) Fix login validation
- [myorg/myapp#109](https://github.com/myorg/myapp/pull/109) Add new API endpoint
- [myorg/myapp#108](https://github.com/myorg/myapp/pull/108) Refactor authentication

## Version 2.2154

### [2.2154.009+3467](https://github.com/myorg/myapp/pull/107)
- [myorg/myapp#106](https://github.com/myorg/myapp/pull/106) Fix memory leak
- [myorg/myapp#105](https://github.com/myorg/myapp/pull/105) Add dark mode

### [2.2154.001+1000](https://github.com/myorg/myapp/pull/104)
- [myorg/myapp#103](https://github.com/myorg/myapp/pull/103) Fix memory leak
- [myorg/myapp#102](https://github.com/myorg/myapp/pull/102) Update dependencies
- [myorg/myapp#101](https://github.com/myorg/myapp/pull/101) Add dark mode
```

*A new version group is created because major.minor changed*

---

### Example 4: Internal Release PR (Ignored)

**PR Details:**
- Title: `Internal Release Build 2.3210.012+3487`
- Number: `#112`

**Result:** Workflow does NOT trigger ✅ (filtered at workflow level)

---

### Example 5: Normal PRs Between Releases

**Important Note:**

Normal PRs (#101, #102, #103) do **NOT** trigger the workflow individually. They are simply merged and wait in the repository.

Only when a Release PR (#104) is merged does the workflow:
1. Look back at all PRs since the last release
2. Collect all normal PRs (excluding Internal PRs)
3. Batch them together under the current release

---

### Example 6: Complete Workflow Lifecycle

**Timeline:**

1. **Merge normal PRs** (#101, #102, #103) → No workflow runs
2. **Merge Release** `2.2154.001+1000` (#104) → Workflow batches PRs #101-103
3. **Merge normal PRs** (#105, #106) → No workflow runs  
4. **Merge Release** `2.2154.009+3467` (#107, same 2.2154.x) → Workflow batches PRs #105-106
5. **Merge normal PRs** (#108, #109, #110) → No workflow runs
6. **Merge Release** `2.2155.001+3600` (#111, NEW 2.2155.x) → Workflow batches PRs #108-110, creates new version group

**Final CHANGELOG:**
```markdown
# Changelog

## Version 2.2155

### [2.2155.001+3600](https://github.com/myorg/myapp/pull/111)
- [myorg/myapp#110](https://github.com/myorg/myapp/pull/110) Fix login validation
- [myorg/myapp#109](https://github.com/myorg/myapp/pull/109) Add new API endpoint
- [myorg/myapp#108](https://github.com/myorg/myapp/pull/108) Refactor authentication

## Version 2.2154

### [2.2154.009+3467](https://github.com/myorg/myapp/pull/107)
- [myorg/myapp#106](https://github.com/myorg/myapp/pull/106) Fix memory leak
- [myorg/myapp#105](https://github.com/myorg/myapp/pull/105) Add dark mode

### [2.2154.001+1000](https://github.com/myorg/myapp/pull/104)
- [myorg/myapp#103](https://github.com/myorg/myapp/pull/103) Improve performance
- [myorg/myapp#102](https://github.com/myorg/myapp/pull/102) Update dependencies
- [myorg/myapp#101](https://github.com/myorg/myapp/pull/101) Fix navigation bug
```

## Workflow Steps

### 1. Trigger Check
Workflow only runs if:
- PR is merged (not just closed)
- Title contains "elease" (Release/release/RELEASE)
- Title does NOT contain "nternal" (to exclude Internal releases)

### 2. Checkout
Checks out the `main` branch with full git history

### 3. Configure Git
Sets up bot credentials:
- Name: `[bot] Changelog Updater`
- Email: `changelog-bot@github.com`

### 4. Extract Current Release Version
- Extracts full version (e.g., `2.2154.009+3467`)
- Extracts major.minor (e.g., `2.2154`)
- Stores PR number and URL

### 5. Find Previous Release
- Queries GitHub API for all merged PRs
- Finds the most recent Release PR before the current one
- Extracts previous version and major.minor
- Compares versions to determine if this is a new version group

### 6. Collect PRs Between Releases
- Gets all PRs between previous release and current release
- Filters out Internal PRs (title starts with "Internal")
- Filters out other Release PRs
- Collects normal PRs with their titles and URLs

### 7. Update CHANGELOG.md
- Creates `CHANGELOG.md` if it doesn't exist
- If **new version** (major.minor changed): Creates new `## Version X.Y` section
- If **same version**: Adds to existing `## Version X.Y` section
- Creates `### [X.Y.Z+BUILD](url)` subsection for this release
- Lists all collected PRs under this release

### 8. Commit and Push
- Commits changes with message: `chore: update CHANGELOG for release X.Y.Z+BUILD`
- Includes co-author attribution: `Co-Authored-By: Warp <agent@warp.dev>`
- Pushes directly to `main` branch

## Setup

### 1. Create Workflow File

Save the workflow as `.github/workflows/update-changelog.yml`

### 2. Ensure Permissions

The workflow requires:
```yaml
permissions:
  contents: write      # To commit and push changes
  pull-requests: read  # To read PR details
```

### 3. Initialize CHANGELOG.md

Create an initial `CHANGELOG.md` file:
```markdown
# Changelog
```

*Note: The workflow will create version sections automatically*

## PR Title Conventions

To ensure the workflow works correctly, follow these conventions:

### Normal PRs ✅
- `Fix login bug`
- `Add new dashboard feature`
- `Update user profile UI`
- `Refactor authentication module`

### Release PRs ✅
- `Release Build 3.38.5+1234`
- `release build 2.2154.009+3467`
- `RELEASE BUILD 1.0.0+100`

### Internal PRs (Ignored) ⛔
- `Internal Release Build 2.3210.012+3487`
- `internal testing updates`
- `INTERNAL: Debug logging`

## Testing

### Local Testing

Use the provided test script that simulates the batching workflow:

```bash
# Run batching workflow test
./test-batching-workflow.sh
```

This script simulates:
- Multiple releases within the same version (2.2154.x)
- A new major.minor version (2.2155.x)
- PR batching between releases

### GitHub Testing

1. Push the workflow to your repository
2. Merge several normal PRs (e.g., bug fixes, features)
3. Create and merge a Release PR with title like `Release Build 2.2154.001+1000`
4. Check the Actions tab to see the workflow run
5. Verify `CHANGELOG.md` was updated with all PRs batched together
6. Merge more normal PRs
7. Create another release (same or new version)
8. Verify the grouping behavior

## Troubleshooting

### CHANGELOG.md not updating

**Check:**
1. PR was merged (not just closed)
2. PR title doesn't start with "Internal"
3. Workflow has `contents: write` permission
4. Branch is `main` (or update trigger in workflow)

### Version not extracted from Release PR

**Check:**
1. Title starts with "Release" (case-insensitive)
2. Version follows format: `X.Y.Z+BUILD`
3. Example: `Release Build 3.38.5+1234`

### Duplicate entries

This shouldn't happen, but if it does:
1. Manually edit `CHANGELOG.md` to remove duplicates
2. Check workflow logs for errors
3. Ensure only one workflow file is active

## Best Practices

1. **Consistent PR Titles**: Use clear, descriptive titles
2. **Release Format**: Always use `Release Build X.Y.Z+BUILD` format
3. **Internal PRs**: Prefix with "Internal" to exclude from CHANGELOG
4. **Review Changes**: Check the workflow output in GitHub Actions
5. **Manual Edits**: You can manually edit CHANGELOG.md if needed - the workflow won't override manual changes, it only adds new entries

## Maintenance

### Changing Version Format

To support different version formats, modify the regex in the workflow:

```bash
# Current format: X.Y.Z+BUILD
VERSION=$(echo "$TITLE" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+')

# For semantic versioning (X.Y.Z):
VERSION=$(echo "$TITLE" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

# For date-based versions (YYYY.MM.DD):
VERSION=$(echo "$TITLE" | grep -oE '[0-9]{4}\.[0-9]{2}\.[0-9]{2}')
```

### Changing Branch

To use a different branch (e.g., `master`):

```yaml
on:
  pull_request:
    types: [closed]
    branches: [master]  # Change from [main]
```

And update the checkout step:
```yaml
- name: Checkout master
  uses: actions/checkout@v4
  with:
    ref: master  # Change from main
```

---

**Created by:** Warp AI Agent  
**Last Updated:** December 25, 2025
