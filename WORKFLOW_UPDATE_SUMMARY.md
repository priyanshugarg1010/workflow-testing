# CHANGELOG Workflow Update Summary

## What Changed

The CHANGELOG workflow has been completely redesigned from a **per-PR trigger** model to a **batching model** that only triggers on Release PRs.

## Key Differences

### Old Behavior ❌
- Triggered on **every PR merge** (normal, release, internal)
- Added PRs individually to CHANGELOG as they merged
- Used "Latest Release" heading
- Required manual organization

### New Behavior ✅
- Triggers **only on Release PRs**
- **Batches all PRs** between releases
- **Groups by version** (major.minor like 2.2154)
- Automatically creates version sections
- Ignores Internal Release PRs at workflow level

## How It Works Now

### 1. Trigger
- **Only Release PRs** trigger the workflow
- Title must contain "elease" (Release/release/RELEASE)
- Title must NOT contain "nternal" (excludes Internal Release)

### 2. Version Comparison
When a Release PR merges:
```
Extract version: 2.2154.009+3467
Extract major.minor: 2.2154
Compare with previous release major.minor
```

**If major.minor changes** (e.g., 2.2154 → 2.2155):
- Creates **new version group**: `## Version 2.2155`

**If major.minor is the same** (e.g., 2.2154.001 → 2.2154.009):
- Adds to **existing version group**: `## Version 2.2154`

### 3. PR Batching
The workflow looks back and collects:
- ✅ All normal PRs since last Release
- ❌ Excludes Internal PRs (title starts with "Internal")
- ❌ Excludes other Release PRs

### 4. CHANGELOG Format

```markdown
# Changelog

## Version 2.2155

### [2.2155.001+3600](pr-url)
- [repo#110](url) PR title
- [repo#109](url) PR title
- [repo#108](url) PR title

## Version 2.2154

### [2.2154.009+3467](pr-url)
- [repo#106](url) PR title
- [repo#105](url) PR title

### [2.2154.001+1000](pr-url)
- [repo#103](url) PR title
- [repo#102](url) PR title
- [repo#101](url) PR title
```

## Real-World Example

**Day 1-10:** Developers merge normal PRs
- PR #101: Fix navigation bug
- PR #102: Update dependencies  
- PR #103: Improve performance
- *No workflow runs, PRs just accumulate*

**Day 11:** Release manager merges Release PR
- PR #104: `Release Build 2.2154.001+1000`
- ✅ **Workflow triggers!**
- Batches PRs #101, #102, #103
- Creates CHANGELOG entry

**Day 12-20:** More development
- PR #105: Add dark mode
- PR #106: Fix memory leak
- *No workflow runs*

**Day 21:** Another release in same version
- PR #107: `Release Build 2.2154.009+3467`  
- ✅ **Workflow triggers!**
- Batches PRs #105, #106
- Adds to existing Version 2.2154 group

**Day 22-30:** More development
- PR #108: Refactor auth
- PR #109: Add API endpoint
- PR #110: Fix validation
- *No workflow runs*

**Day 31:** New major/minor version
- PR #111: `Release Build 2.2155.001+3600`
- ✅ **Workflow triggers!**
- Detects version change (2.2154 → 2.2155)
- Creates **new Version 2.2155 group**
- Batches PRs #108, #109, #110

## Files Updated

### Workflow File
- `.github/workflows/update-changelog.yml` - Complete rewrite with:
  - Conditional trigger (Release PRs only)
  - GitHub API integration to query PRs
  - Version comparison logic
  - PR batching between releases
  - Dynamic version grouping

### Documentation
- `CHANGELOG_WORKFLOW.md` - Updated with:
  - New batching behavior explanation
  - Version grouping details
  - Updated examples showing batching
  - New workflow steps

### Test Scripts
- `test-batching-workflow.sh` - New comprehensive test showing:
  - Multiple releases in same version
  - Version changes
  - PR batching behavior

## Testing

Run the test script to see the batching in action:

```bash
./test-batching-workflow.sh
```

This simulates:
1. Release 2.2154.001+1000 with 3 PRs
2. Release 2.2154.009+3467 with 2 more PRs (same version)
3. Release 2.2154.012+3500 with 1 more PR (same version)
4. Release 2.2155.001+3600 with 3 PRs (NEW VERSION)
5. Release 2.2155.005+3700 with 2 more PRs (same new version)

Final output shows proper version grouping!

## Benefits

1. **Cleaner organization** - Versions are clearly grouped
2. **Less noise** - Workflow only runs on releases, not every PR
3. **Automatic batching** - No manual changelog updates needed
4. **Flexible versioning** - Handles both patch releases and version bumps
5. **Ignores internal releases** - Filtered at trigger level

## Migration

If you have an existing CHANGELOG with the old format:
1. The new workflow will create new sections going forward
2. Old entries remain unchanged
3. Consider manually reorganizing old entries (optional)

---

**Updated:** December 25, 2025  
**Status:** ✅ Tested and working
