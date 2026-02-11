Perform a release commit for this Flutter project. Follow these steps exactly:

1. Run `git status` and `git diff` to see all changes
2. Draft a concise commit message summarizing the changes
3. Determine the version bump:
   - Read the current version from `pubspec.yaml` (format: `X.Y.Z+build`)
   - Increment the patch version (Z) by 1 and the build number by 1
   - Update `pubspec.yaml` with the new version
4. Update `CHANGELOG.md`:
   - Add a new entry at the top (below the header) with the new version and today's date
   - List the changes under appropriate headings (Added/Changed/Fixed)
5. Stage ONLY the relevant changed files (not docs/ unless the changes are specifically about docs). Use specific file names, not `git add .`
6. Create the commit with a clear message
7. After committing, write release notes to `RELEASE_NOTES.md` (gitignored) with two sections:
   - **Google Play release notes**: List of sentence(s) describing the update
   - **GitHub release notes**: Markdown format with version header and bullet points
8. Tell the user the release notes are in `RELEASE_NOTES.md`

Do NOT push to remote. Do NOT commit docs/ files unless the user explicitly changed them as part of this feature.

User's arguments (if any): $ARGUMENTS
