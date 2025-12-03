# Breaking Down PR #1 Changes

## Context
PR #1 (https://github.com/wdillon-usda/anyflights/pull/1) contains 117 additions and 41 deletions across 2 files. The original package maintainer requested these be broken into smaller PRs (~10 lines each) that address specific issues only.

## Issues Addressed in PR #1

Based on the PR description and code changes, PR #1 addresses these distinct issues:

### Issue 1: Missing Return Statement (CRITICAL BUG)
- **Problem**: `get_planes_data()` function has no explicit return statement, returning NULL implicitly
- **File**: `R/utils.R`
- **Lines**: ~2 lines added
- **Priority**: HIGH - This is a critical bug that breaks functionality

### Issue 2: FAA Data Source URL Change
- **Problem**: FAA changed from yearly files (`ReleasableAircraft{year}.zip`) to consolidated (`ReleasableAircraft.zip`)
- **File**: `R/utils.R` 
- **Lines**: ~3 lines (remove year from URL construction)
- **Priority**: HIGH - Required for package to work with current FAA data

### Issue 3: Restore year Parameter for Backward Compatibility
- **Problem**: year parameter was commented out but anyflights() still passes it, causing signature mismatch
- **Files**: `R/get_planes.R`, `R/utils.R`
- **Lines**: ~6 lines (add `year = NULL` parameter back to function signatures)
- **Priority**: MEDIUM - Needed for backward compatibility

### Issue 4: Update Year Validation Logic
- **Problem**: check_arguments() needs to handle optional year parameter for planes context
- **File**: `R/utils.R`
- **Lines**: ~18 lines (update validation logic)
- **Priority**: MEDIUM - Supports Issue #3

### Issue 5: Case-Insensitive File Detection
- **Problem**: FAA files may have inconsistent casing (MASTER.txt vs Master.txt)
- **File**: `R/utils.R`
- **Lines**: ~43 lines (new helper function)
- **Priority**: MEDIUM - Improves robustness

### Issue 6: Use Case-Insensitive File Finding
- **Problem**: Hard-coded file paths don't work when FAA changes file casing
- **File**: `R/utils.R`
- **Lines**: ~6 lines (use helper function)
- **Priority**: MEDIUM - Applies Issue #5 fix

### Issue 7: Bounds Checking for Array Indexing  
- **Problem**: type_eng and type_acft can be out of bounds or NA, causing crashes
- **File**: `R/utils.R`
- **Lines**: ~25 lines (add bounds checking with case_when)
- **Priority**: MEDIUM - Prevents crashes on malformed data

### Issue 8: Documentation Updates
- **Problem**: year parameter behavior not documented
- **File**: `R/get_planes.R`
- **Lines**: ~7 lines (add @details section)
- **Priority**: LOW - Documentation only

## Recommended Breakdown into Separate PRs

### PR A: Fix missing return statement [Priority: HIGH, Size: ~2 lines]
**Addresses**: Issue #1  
**Changes**: Add return statement to `get_planes_data()`
```r
# return the planes data
planes
```

### PR B: Update FAA data source URL [Priority: HIGH, Size: ~3 lines]
**Addresses**: Issue #2
**Changes**: Remove year variable from URL construction in `get_planes_data()`

### PR C: Restore year parameter [Priority: MEDIUM, Size: ~6 lines]
**Addresses**: Issue #3  
**Depends on**: PR B
**Changes**: Add `year = NULL` parameter back to:
- `get_planes()` function signature
- `get_planes_data()` function signature  
- Pass year parameter in function calls

### PR D: Update year validation [Priority: MEDIUM, Size: ~18 lines]
**Addresses**: Issue #4
**Depends on**: PR C
**Changes**: Modify `check_arguments()` to make year optional for planes context

### PR E: Add case-insensitive file helper [Priority: MEDIUM, Size: ~43 lines]
**Addresses**: Issue #5
**Changes**: Create `find_file_case_insensitive()` helper function

### PR F: Use case-insensitive file detection [Priority: MEDIUM, Size: ~6 lines]
**Addresses**: Issue #6
**Depends on**: PR E
**Changes**: Update `process_planes_master()` and `process_planes_ref()` to use helper

### PR G: Add array bounds checking [Priority: MEDIUM, Size: ~25 lines]
**Addresses**: Issue #7
**Changes**: Add bounds checking in `join_planes_data()` for type_eng and type_acft

### PR H: Document year parameter behavior [Priority: LOW, Size: ~7 lines]
**Addresses**: Issue #8
**Depends on**: PR C
**Changes**: Add @details section to get_planes() documentation

## Submission Order

1. **PR A** (Critical bug fix - can be merged immediately)
2. **PR B** (Required for current FAA data)
3. **PR C** (Backward compatibility - depends on B)
4. **PR D** (Validation logic - depends on C)
5. **PR E** (Helper function - independent)
6. **PR F** (Uses helper - depends on E)
7. **PR G** (Robustness improvement - independent)
8. **PR H** (Documentation - depends on C)

## Benefits of This Breakdown

1. **Easier Review**: Each PR is small (~2-43 lines) and focuses on one specific issue
2. **Independent Testing**: Most changes can be tested separately
3. **Flexible Merging**: Maintainer can choose to merge high-priority fixes first
4. **Clear Intent**: Each PR has a single, well-defined purpose
5. **Easier Debugging**: If a regression occurs, it's easier to identify the cause
6. **Follows Guidelines**: Meets the maintainer's request for ~10 line changes

## Total Line Counts

- PR A: ~2 lines
- PR B: ~3 lines  
- PR C: ~6 lines
- PR D: ~18 lines
- PR E: ~43 lines (largest, but single cohesive function)
- PR F: ~6 lines
- PR G: ~25 lines
- PR H: ~7 lines

**Total**: ~110 lines (matches original PR #1)
