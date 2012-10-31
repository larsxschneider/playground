#!/bin/sh
# Sets up this git repository for development

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$BASE_DIR/Build"

# 1. Init/Update submodules:
pushd "$BASE_DIR"
	git submodule sync
	if git submodule status | grep '^+'
	then
		echo ""
		echo "You have changes in the submodule(s) listed above."
		echo "Automatic submodule update is omitted."
		read NO_VAR
	else
		echo "Updating submodules..."
		git submodule update --init --recursive
	fi
popd

# 2. Install whitespace git hook for repository:
pushd "$BASE_DIR"
	if [ -f .git-fix-whitespaces.sh ]
	then
	    ln -fs ../../.git-fix-whitespaces.sh .git/hooks/pre-commit
	else
	    echo '\nError: Fix whitespace script not found repository.'
	fi
popd


