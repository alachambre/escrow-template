#!/usr/bin/env bash
set -euo pipefail # stop at first failure

echo "# Creating maven repository ..."
mkdir -p $M2_REPO

echo "# Creating npm cache directory ..."
mkdir -p $NPM_CACHE_DIR

echo "# Creating bower cache directory ..."
mkdir -p $BOWER_CACHE_DIR

echo "# Creating yarn cache directory ..."
mkdir -p $YARN_CACHE_FOLDER

echo "# Creating gradle user home..."
mkdir -p $GRADLE_USER_HOME