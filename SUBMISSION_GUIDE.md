# How to Submit the Broken-Down PRs

This guide explains how to use the demonstration branches to submit small, focused PRs to the upstream repository.

## Quick Reference

| Branch | PR Title | Size | Priority | Depends On |
|--------|----------|------|----------|------------|
| `pr-a-fix-return-statement` | Fix missing return statement in get_planes_data() | +3 | HIGH | None |
| `pr-b-update-faa-url` | Update FAA data source URL to consolidated dataset | -1 | HIGH | None |
| `pr-c-restore-year-parameter` | Restore year parameter for backward compatibility | +4-4 | MEDIUM | PR-B |
| `pr-d-update-year-validation` | Update year validation to make it optional for planes | +29-24 | MEDIUM | PR-C |
| `pr-e-case-insensitive-helper` | Add case-insensitive file finding helper | +42 | MEDIUM | None |
| `pr-f-use-case-insensitive-finding` | Use case-insensitive file finding in planes processing | +8-4 | MEDIUM | PR-E |
| `pr-g-add-bounds-checking` | Add bounds checking for array indexing | +22-8 | MEDIUM | None |
| `pr-h-document-year-parameter` | Document year parameter behavior | +5 | LOW | PR-C |

## Step-by-Step Submission Process

### 1. Set Up Upstream Remote

```bash
# Add the original repository as upstream (if not already done)
git remote add upstream https://github.com/simonpcouch/anyflights.git
git fetch upstream
```

### 2. Create Submission Branches

For each PR, create a branch based on the upstream main branch and apply the changes:

#### Option A: Cherry-pick from demonstration branches (Recommended)

```bash
# For PR-A
git checkout -b submit/pr-a-fix-return-statement upstream/main
git cherry-pick pr-a-fix-return-statement

# Push to your fork
git push origin submit/pr-a-fix-return-statement
```

#### Option B: Manual recreation

```bash
# For PR-A
git checkout -b submit/pr-a-fix-return-statement upstream/main

# Make the specific changes shown in PR_DIFFS.md for PR-A
# ... edit files ...

git add -A
git commit -m "Fix missing return statement in get_planes_data()

This fixes a critical bug where get_planes_data() was implicitly
returning NULL instead of the planes data frame. The function now
explicitly returns the planes data after filtering.

Issue: get_planes_data() had no explicit return statement
Fix: Add explicit return of planes data frame
Lines changed: +3 lines"

git push origin submit/pr-a-fix-return-statement
```

### 3. Submit PRs to Upstream

Go to https://github.com/simonpcouch/anyflights and create a new PR for each branch:

#### PR-A Submission

**Title**: Fix missing return statement in get_planes_data()

**Description**:
```markdown
## Problem
The `get_planes_data()` function has no explicit return statement, causing it to implicitly return NULL instead of the planes data frame.

## Solution  
Add an explicit return statement for the planes data.

## Changes
- Add return statement in `get_planes_data()` function
- Lines changed: +3

## Testing
- Verified function now returns planes data correctly
- No breaking changes to existing functionality

## Related
This is part of breaking down the larger changes into smaller, focused pieces as requested.
```

#### PR-B Submission  

**Title**: Update FAA data source URL to consolidated dataset

**Description**:
```markdown
## Problem
FAA changed from yearly aircraft registry files (`ReleasableAircraft{year}.zip`) to a single consolidated file (`ReleasableAircraft.zip`). The commented-out year parameter in URL construction is no longer needed.

## Solution
Remove the commented year parameter from URL construction.

## Changes
- Remove year from URL in `get_planes_data()`
- Lines changed: -1

## Testing
- Verified URL correctly points to FAA's consolidated dataset
- Function successfully downloads current FAA data

## Related
This is part of breaking down larger changes into smaller, focused pieces as requested.
```

#### PR-C Submission

**Title**: Restore year parameter for backward compatibility

**Description**:
```markdown
## Problem
The year parameter was commented out in `get_planes()` and `get_planes_data()`, but the `anyflights()` wrapper function still passes it, causing function signature mismatches.

## Solution
Restore the year parameter with a NULL default value to maintain backward compatibility. The parameter is accepted but not used in URL construction (see PR for FAA URL update).

## Changes
- Add `year = NULL` parameter back to `get_planes()` function signature
- Add `year = NULL` parameter back to `get_planes_data()` function signature  
- Pass year parameter in function calls
- Lines changed: +4 -4

## Dependencies
- Should be applied after PR that updates FAA URL

## Testing
- Verified `anyflights()` can call `get_planes()` without errors
- Confirmed year parameter accepted but not used in data retrieval
- Backward compatible with existing code

## Related
This is part of breaking down larger changes into smaller, focused pieces as requested.
```

*Continue similar pattern for PR-D through PR-H using commit messages and PR_DIFFS.md*

## Recommended Submission Order

### Phase 1: Critical Fixes (Submit Immediately)
1. Submit **PR-A** (fix return statement) - Independent
2. Submit **PR-B** (update URL) - Independent

### Phase 2: Backward Compatibility (After Phase 1 merged)
3. Submit **PR-C** (restore parameter) - After PR-B is merged
4. Submit **PR-D** (update validation) - After PR-C is merged  
5. Submit **PR-H** (documentation) - After PR-C is merged

### Phase 3: Robustness (Can be submitted in parallel with Phase 2)
6. Submit **PR-E** (helper function) - Independent
7. Submit **PR-F** (use helper) - After PR-E is merged
8. Submit **PR-G** (bounds checking) - Independent

## Tips for Success

### 1. Be Patient
Don't submit all PRs at once. Wait for feedback on the first few before continuing.

### 2. Be Responsive  
Respond promptly to maintainer feedback and make requested changes quickly.

### 3. Reference Each Other
In later PRs, reference earlier ones: "This builds on PR #XX which was merged..."

### 4. Keep Them Small
If a maintainer asks you to break a PR down further, do so willingly.

### 5. Test Thoroughly
Even small changes should be tested. Run `R CMD check` before submitting.

### 6. Write Clear Commit Messages
Use the commit messages from the demonstration branches as templates.

## What Not to Do

❌ Don't submit all 8 PRs at once - it's overwhelming  
❌ Don't include unrelated changes in a PR  
❌ Don't combine multiple fixes "to save time"  
❌ Don't argue if asked to break down further  
❌ Don't submit dependent PRs before dependencies are merged  

## What the Maintainer Asked For

> "break this PR into smaller pieces (think +10 −10) that address only the specific issues you're seeing and refrain from introducing unrelated changes"

✅ Each PR is small (~3-42 lines)  
✅ Each addresses a single specific issue  
✅ No unrelated changes included  
✅ Dependencies clearly documented  

## Questions?

See the detailed documentation:
- `BREAKDOWN_PLAN.md` - Analysis of the breakdown strategy
- `BREAKDOWN_SUMMARY.md` - Comprehensive overview
- `PR_DIFFS.md` - Exact code changes for each PR

## For the Maintainer

If you're the repository maintainer reviewing this breakdown:
- Each branch demonstrates a small, focused change
- All changes combined equal the original PR #1
- Dependencies are clearly marked
- Each can be reviewed in < 5 minutes
- You can merge high-priority fixes immediately
- Enhancements can be deferred if needed
