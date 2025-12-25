# PR Collection Logic Explained

## How the Workflow Collects PRs

The workflow uses **different strategies** depending on whether it's a **new version** or an **update to an existing version**.

### Scenario 1: New Version (Major.Minor Changed)

**Example:** 2.2154 → 2.2155

**What it does:**
- Collects PRs **only between the last Release PR and current Release PR**
- Creates a **new section** in the CHANGELOG

**Timeline:**
```
PR #100: Release 2.2154.009+3467 (last release of 2.2154)
PR #101: Fix bug
PR #102: Add feature
PR #103: Update docs
PR #110: Release 2.2155.001+3600 (NEW VERSION!)
```

**PRs collected:** #101, #102, #103

**CHANGELOG Result:**
```markdown
### [2.2155.001+3600](url) Version 2.2155
- PR #103
- PR #102
- PR #101

### [2.2154.009+3467](url) Version 2.2154
- ... (existing PRs)
```

---

### Scenario 2: Same Version (Major.Minor Unchanged)

**Example:** 2.2154.001 → 2.2154.009

**What it does:**
- Finds the **FIRST release PR** for version 2.2154
- Collects **ALL PRs** from that first release to the current release
- **Replaces** the existing 2.2154 section completely

**Timeline:**
```
PR #50: Release 2.2154.001+1000 (FIRST release of 2.2154)
PR #51: Fix bug A
PR #52: Add feature B
PR #60: Release 2.2154.005+2000 (second release)
PR #61: Fix bug C
PR #62: Add feature D
PR #70: Release 2.2154.009+3467 (current release)
```

**PRs collected:** #51, #52, #61, #62 (ALL PRs between first release #50 and current #70)

**CHANGELOG Result:**
```markdown
### [2.2154.009+3467](url) Version 2.2154
- PR #62 (newest first)
- PR #61
- PR #52
- PR #51
```

---

## Why This Approach?

### Problem It Solves

Without this logic, when you merge the 3rd release of version 2.2154:

**Bad (old approach):**
```markdown
### [2.2154.009](url) Version 2.2154
- PR #62 (only new PRs since last release)
- PR #61
```
❌ Missing PRs #51, #52 from earlier releases!

**Good (new approach):**
```markdown
### [2.2154.009](url) Version 2.2154
- PR #62
- PR #61
- PR #52
- PR #51
```
✅ All PRs for version 2.2154!

---

## Algorithm Flow

### For Each Release PR:

1. **Extract version and major.minor**
   - Version: `2.2154.009+3467`
   - Major.Minor: `2.2154`

2. **Find previous release**
   - Look for the most recent Release PR before current

3. **Compare major.minor**
   ```bash
   if current_major_minor != previous_major_minor:
       # NEW VERSION
       is_new_version = true
   else:
       # SAME VERSION
       is_new_version = false
   ```

4. **Collect PRs**
   ```bash
   if is_new_version:
       # Get PRs between previous release and current
       collect_prs(from=previous_release, to=current_release)
   else:
       # Find FIRST release of this major.minor
       first_release = find_first_release(major_minor)
       # Get ALL PRs for this entire version
       collect_prs(from=first_release, to=current_release)
   ```

5. **Update CHANGELOG**
   ```python
   if is_new_version:
       # Create new section
       create_section(version, prs)
   else:
       # Replace existing section
       replace_section(version, prs)
   ```

---

## Examples

### Example 1: First Release of a Version

**Releases:**
- `2.2154.001+1000` (#10)

**PRs:** #1, #2, #3, #4, #5 (before release)

**Result:**
```markdown
### [2.2154.001+1000](url) Version 2.2154
- PR #5
- PR #4
- PR #3
- PR #2
- PR #1
```

---

### Example 2: Second Release Same Version

**Releases:**
- `2.2154.001+1000` (#10) - first
- `2.2154.009+3467` (#20) - current

**PRs:** 
- #1-5 (before first release)
- #11-15 (between releases)

**Result:**
```markdown
### [2.2154.009+3467](url) Version 2.2154
- PR #15 (newest first)
- PR #14
- PR #13
- PR #12
- PR #11
- PR #5
- PR #4
- PR #3
- PR #2
- PR #1
```
✅ All PRs from the beginning!

---

### Example 3: Third Release Same Version

**Releases:**
- `2.2154.001+1000` (#10) - first
- `2.2154.009+3467` (#20) - second
- `2.2154.015+4000` (#30) - current

**PRs:**
- #1-5 (before first)
- #11-15 (between first and second)
- #21-25 (between second and third)

**Result:**
```markdown
### [2.2154.015+4000](url) Version 2.2154
- PR #25
- PR #24
- PR #23
- PR #22
- PR #21
- PR #15
- PR #14
- PR #13
- PR #12
- PR #11
- PR #5
- PR #4
- PR #3
- PR #2
- PR #1
```
✅ STILL all PRs from the beginning!

---

### Example 4: New Version

**Releases:**
- `2.2154.015+4000` (#30) - last of 2.2154
- `2.2155.001+5000` (#40) - first of 2.2155 (NEW VERSION!)

**PRs:**
- #1-25 (in 2.2154 section, already listed)
- #31-35 (between versions)

**Result:**
```markdown
### [2.2155.001+5000](url) Version 2.2155
- PR #35
- PR #34
- PR #33
- PR #32
- PR #31

### [2.2154.015+4000](url) Version 2.2154
- PR #25
- ... (all previous PRs)
```
✅ New section created! Old section unchanged.

---

## Key Points

1. **Same version = cumulative list**
   - Each new release in 2.2154.x adds to the complete list
   - The link updates to the latest release
   - All PRs since the first 2.2154 release are included

2. **New version = fresh start**
   - Only PRs since the last release (different version)
   - Creates a new section
   - Previous version section remains unchanged

3. **Filtered PRs**
   - ❌ Internal PRs (title starts with "Internal")
   - ❌ Release PRs (title starts with "Release")
   - ✅ All other normal PRs

4. **Order**
   - PRs listed newest first
   - Sections listed newest version first

---

## Testing

To test this locally, see `test-batching-workflow.sh` which simulates:
- Multiple releases in same version
- Version changes
- PR accumulation

Run: `./test-batching-workflow.sh`
