#!/bin/sh
# Pre-commit hook for git which removes trailing whitespace, converts tabs to spaces, and enforces a max line length.

if git-rev-parse --verify HEAD >/dev/null 2>&1 ; then
   against=HEAD
else
   # Initial commit: diff against an empty tree object
   against=4b825dc642cb6eb9a060e54bf8d69288fbee4904
fi


staged_files=`git diff-index --name-status --cached $against      | # Find all staged files
                egrep -i '^(A|M).*\.(h|m|mm|cpp|js|html|txt|sh)$' | # Only process certain files
                sed -e 's/A.//g'                                  | # Remove leading git info
                sed -e 's/M.//g'                                  | # Remove leading git info
                sort                                              | # Remove duplicates
                uniq`


partially_staged_files=`git status --porcelain --untracked-files=no | # Find all staged files
                        egrep -i '^(A|M)M '                         | # Filter only partially staged files
                        sed -e 's/^AM //g'                          | # Remove leading git info
                        sed -e 's/^MM //g'                          | # Remove leading git info
                        sort                                        | # Remove duplicates
                        uniq`

# Merge staged files and partially staged files
staged_and_partially_staged_files=${staged_files}$'\n'${partially_staged_files}

# Remove all files that are staged *AND* partially staged
# Thus we get only the fully staged files
fully_staged_files=`echo "$staged_and_partially_staged_files" | sort | uniq -u`

# Change field separator to newline so that for correctly iterates over lines
IFS=$'\n'

# Find files with trailing whitespace
for FILE in $fully_staged_files ; do
    echo "Fixing whitespace in $FILE" >&2
    # Replace tabs with four spaces
    sed -i "" $'s/\t/    /g' "$FILE"
    # Strip trailing whitespace
    sed -i '' -E 's/[[:space:]]*$//' "$FILE"
    # git add "$FILE"
done

exit 1
