#!/usr/bin/env bash
# Environment variable for build

CURR_FILE_DIR=$(dirname $(readlink -f "$BASH_SOURCE"))
export BUILDDIR=$CURR_FILE_DIR

########### Artefact repositories
export MAVEN_USER_HOME=$CURR_FILE_DIR/repositories/maven
export M2_REPO=$CURR_FILE_DIR/repositories/maven
export NPM_CACHE_DIR=$CURR_FILE_DIR/repositories/npm
export BOWER_CACHE_DIR=$CURR_FILE_DIR/repositories/bower
export YARN_CACHE_FOLDER=$CURR_FILE_DIR/repositories/yarn
# Gradle cache use absolute path -> to reuse the gradle cache during an offline build, we must ensure that the gradle cache has always the same location.
export GRADLE_USER_HOME=/tmp/escrow/gradle
export ARCHIVE_GRADLE_USER_HOME=$CURR_FILE_DIR/repositories/gradle

########### tools
export TOOLSDIR=$CURR_FILE_DIR/tools
export JAVA_HOME=$TOOLSDIR/jdk
export M2_HOME=$TOOLSDIR/maven
export NODE_HOME=$TOOLSDIR/node

export PATH="$M2_HOME/bin:$JAVA_HOME/bin:$NODE_HOME/bin:$PATH"

export npm_config_cache=$NPM_CACHE_DIR
export npm_config_cache_min=999999999
export bower_storage__packages=$BOWER_CACHE_DIR
export bower_storage__repository=$BOWER_CACHE_DIR

if [ "$1" == "online" ]; then
   echo "Online build !!"
else
   echo "Offline build !!"
   alias bower='bower --offline $@'
   mkdir -p /tmp/$PRODUCT

   # Moving the gradle cache in the tmp folder used during online build, to avoid absolute path issues
   echo "Start moving the gradle user home (it can take a few minutes)"
   mv $ARCHIVE_GRADLE_USER_HOME $GRADLE_USER_HOME
   echo "Move of the gradle user home completed!"
fi
