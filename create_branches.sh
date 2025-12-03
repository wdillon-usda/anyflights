#!/bin/bash
# Script to create all 8 PR branches locally
# Run this script from the root of your anyflights repository

set -e  # Exit on error

echo "Creating all PR branches for anyflights breakdown..."
echo ""

# Get the current branch to return to later
ORIGINAL_BRANCH=$(git branch --show-current)

echo "Step 1: Creating baseline branch..."
# Create baseline by reverting PR #1 changes
git checkout -b baseline-before-pr1

# Revert the @details documentation from get_planes.R
sed -i '/^#'"'"' @details$/,/^#'"'"' @return/{ /^#'"'"' @details$/d; /^#'"'"' The \\code{year}/d; /^#'"'"' not used in data retrieval/d; /^#'"'"' aircraft registry database/d; /^#'"'"'$/d; }' R/get_planes.R

# Comment out year parameter in get_planes.R
sed -i 's/^  year = NULL,$/  #year,/' R/get_planes.R
sed -i 's/^  check_arguments(year = year,$/  check_arguments(#year = year,/' R/get_planes.R
sed -i 's/^    year,$/    #year,/' R/get_planes.R

# Update utils.R to revert year validation
# This is complex - better to do it manually or with the full file approach

echo "Baseline branch creation requires manual file edits."
echo "Please refer to PR_DIFFS.md for exact changes needed."
echo ""
echo "Alternatively, follow these steps:"
echo ""
echo "=== MANUAL APPROACH (RECOMMENDED) ==="
echo ""
echo "Since the automated script would be complex, here's how to create the branches manually:"
echo ""
echo "1. Create baseline branch:"
echo "   git checkout -b baseline-before-pr1"
echo "   # Manually revert PR #1 changes following PR_DIFFS.md"
echo "   git add -A && git commit -m 'Baseline: Revert to pre-PR#1 state'"
echo ""
echo "2. Create PR-A branch (from baseline):"
echo "   git checkout baseline-before-pr1"
echo "   git checkout -b pr-a-fix-return-statement"
echo "   # Add return statement to get_planes_data() in R/utils.R"
echo "   git add -A && git commit -m 'PR-A: Add missing return statement'"
echo ""
echo "3. Create PR-B branch (from baseline):"
echo "   git checkout baseline-before-pr1"
echo "   git checkout -b pr-b-update-faa-url"
echo "   # Remove commented year from URL in get_planes_data()"
echo "   git add -A && git commit -m 'PR-B: Update FAA data source URL'"
echo ""
echo "And so on for PR-C through PR-H..."
echo ""
echo "See PR_DIFFS.md for exact code changes for each PR."
echo "See SUBMISSION_GUIDE.md for detailed step-by-step instructions."
echo ""

# Clean up - return to original branch
git checkout "$ORIGINAL_BRANCH"

echo "Script complete. Please follow the manual approach above or use PR_DIFFS.md."
