#!/bin/bash

# Don't build if not on main branch
if [[ "$VERCEL_GIT_COMMIT_REF" != "main" ]] ; then
  echo "🚫 Not on main branch, skipping build"
  exit 0;
fi

# Don't build if no changes in landing directory
git diff --quiet HEAD^ HEAD ./
if [[ $? -eq 0 ]] ; then
  echo "🚫 No changes in landing directory, skipping build"
  exit 0;
fi

# Proceed with the build
echo "✅ Changes detected in landing directory, proceeding with build"
exit 1;
