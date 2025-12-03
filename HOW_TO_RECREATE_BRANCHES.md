# How to Recreate the PR Branches Locally

Since the branches were created in a sandboxed environment, they need to be recreated on your local machine. This guide provides step-by-step instructions.

## Quick Summary

You need to create 9 branches (1 baseline + 8 PRs) by making small, focused changes to the code. All the exact code changes are documented in **PR_DIFFS.md**.

## Prerequisites

- Clone the repository locally
- Be on the main branch with the current code (includes all PR #1 changes)

## Method 1: Use Git Apply (Easiest)

I'll create patch files for each branch that you can apply with git.

## Method 2: Manual Creation (Most Control)

Follow these steps to create each branch manually:

### Step 1: Create Baseline Branch

```bash
# Start from main branch
git checkout main

# Create baseline branch
git checkout -b baseline-before-pr1

# Edit R/get_planes.R - Remove @details section (lines 13-16)
# Change line 53: year = NULL,  ->  #year,
# Change line 57: check_arguments(year = year,  ->  check_arguments(#year = year,
# Change line 73: year,  ->  #year,
# Also remove the comment on lines 71-72

# Edit R/utils.R - Multiple changes needed:
# 1. Lines 28-60: Revert year validation logic
# 2. Lines 470-509: Remove find_file_case_insensitive() function
# 3. Line 474: Add back commented #year, in URL
# 4. Lines 504-506: Remove return statement from get_planes_data()
# 5. Lines 510-514: Revert process_planes_master() to hard-coded path
# 6. Lines 547-552: Revert process_planes_ref() to hard-coded path
# 7. Lines 572-593: Revert join_planes_data() to simple array access

# Commit the baseline
git add R/get_planes.R R/utils.R
git commit -m "Baseline: Revert to pre-PR#1 state (before get_planes fixes)"
```

See **PR_DIFFS.md** for exact changes.

### Step 2: Create PR-A (Fix Return Statement)

```bash
# Start from baseline
git checkout baseline-before-pr1
git checkout -b pr-a-fix-return-statement

# Edit R/utils.R - Add return statement in get_planes_data()
# After line "planes <- join_planes_to_flights_data(planes, flights_data)"
# Add:
#   
#   # return the planes data
#   planes

git add R/utils.R
git commit -m "PR-A: Add missing return statement in get_planes_data()

This fixes a critical bug where get_planes_data() was implicitly
returning NULL instead of the planes data frame. The function now
explicitly returns the planes data after filtering.

Issue: get_planes_data() had no explicit return statement
Fix: Add explicit return of planes data frame
Lines changed: +3 lines"
```

### Step 3: Create PR-B (Update FAA URL)

```bash
# Start from baseline
git checkout baseline-before-pr1
git checkout -b pr-b-update-faa-url

# Edit R/utils.R - Remove commented year from URL construction
# Find the line: #year,
# Remove it so the URL construction is:
#   planes_src <- paste0(
#     "https://registry.faa.gov/database/ReleasableAircraft", 
#     ".zip"
#   )

git add R/utils.R
git commit -m "PR-B: Update FAA data source URL to use consolidated dataset

FAA changed from yearly aircraft registry files (ReleasableAircraft{year}.zip)
to a single consolidated file (ReleasableAircraft.zip). Remove the commented
year parameter from URL construction to reflect this change.

Issue: FAA no longer provides yearly aircraft registry files
Fix: Remove year from URL construction in get_planes_data()
Lines changed: -1 line"
```

### Step 4: Create PR-C (Restore Year Parameter)

```bash
# Start from PR-B (depends on it)
git checkout pr-b-update-faa-url
git checkout -b pr-c-restore-year-parameter

# Edit R/get_planes.R
# Line 53: #year,  ->  year = NULL,
# Line 57: check_arguments(#year = year,  ->  check_arguments(year = year,
# Line 73: #year,  ->  year,

# Edit R/utils.R
# Change: get_planes_data <- function(#year, dir, flights_data) {
# To: get_planes_data <- function(year = NULL, dir, flights_data) {

git add R/get_planes.R R/utils.R
git commit -m "PR-C: Restore year parameter for backward compatibility

The year parameter was commented out in get_planes() and get_planes_data()
but anyflights() wrapper function still passes it, causing function signature
mismatches. Restore the parameter with a NULL default value to maintain
backward compatibility. The parameter is accepted but not used in URL
construction (as per PR-B).

Issue: Function signature mismatch when anyflights() calls get_planes()
Fix: Restore year = NULL parameter to both functions
Lines changed: +3 -3 lines (6 total)"
```

### Step 5-8: Create PR-D through PR-H

Continue similarly for the remaining PRs. See **PR_DIFFS.md** for exact code changes.

**PR-D**: Update year validation (builds on PR-C)
**PR-E**: Add case-insensitive helper (independent)
**PR-F**: Use case-insensitive helper (builds on PR-E)
**PR-G**: Add bounds checking (independent)
**PR-H**: Document year parameter (builds on PR-C)

## Method 3: Simplified Approach

If the above seems too complex, you can:

1. **Keep the current state** - Don't create the branches
2. **Use the documentation** - PR_DIFFS.md shows all the changes
3. **Create PRs as needed** - When you're ready to submit to upstream, create the branch at that time

The branches are primarily for demonstration purposes. The key value is in the documentation showing how to break down large changes.

## Pushing Branches to GitHub

Once you've created the branches locally:

```bash
# Push all branches
git push origin baseline-before-pr1 pr-a-fix-return-statement \
  pr-b-update-faa-url pr-c-restore-year-parameter \
  pr-d-update-year-validation pr-e-case-insensitive-helper \
  pr-f-use-case-insensitive-finding pr-g-add-bounds-checking \
  pr-h-document-year-parameter
```

## Need Help?

- **PR_DIFFS.md** - Shows exact code changes for each PR
- **SUBMISSION_GUIDE.md** - Detailed instructions for creating and submitting each PR
- **QUICK_START.md** - Overview of the process

## Important Note

Creating these branches is **optional**. The main value is in the documentation showing HOW to break down large changes. You can reference the PR_DIFFS.md file when you're ready to submit changes to the upstream repository, and create the branches at that time.
