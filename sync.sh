#!/usr/bin/env bash
#
# sync.sh — keep this fork in sync with upstream (ed-donner/llm_engineering)
#
#   1. fast-forwards `main` to match upstream (the original course repo)
#   2. mirrors that to your GitHub (origin/main)
#   3. rebases your work branch on top, so your commits sit on the latest course code
#   4. pushes your updated work branch
#
# Usage:   ./sync.sh              # uses default work branch below
#          ./sync.sh some-branch  # sync a different work branch
#
set -euo pipefail

WORK_BRANCH="${1:-navi-dev}"

# Refuse to run with uncommitted changes — they'd be lost or block the checkout.
if ! git diff-index --quiet HEAD -- || [ -n "$(git status --porcelain)" ]; then
  echo "✋ You have uncommitted changes. Commit or stash them first, then re-run."
  exit 1
fi

echo "⬇️  Updating main from upstream (ed-donner)..."
git checkout main
git pull --ff-only upstream main
git push origin main

echo "🔀 Rebasing '$WORK_BRANCH' onto the latest main..."
git checkout "$WORK_BRANCH"
if ! git rebase main; then
  echo ""
  echo "⚠️  Merge conflicts during rebase. Fix the listed files, then:"
  echo "      git add <fixed-files> && git rebase --continue"
  echo "      git push --force-with-lease origin $WORK_BRANCH"
  echo "   ...or back out entirely with:  git rebase --abort"
  exit 1
fi

echo "⬆️  Pushing '$WORK_BRANCH' to your GitHub..."
git push --force-with-lease origin "$WORK_BRANCH"

echo ""
echo "✅ Done. '$WORK_BRANCH' is now rebased on the latest upstream course code."
