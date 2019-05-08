#!/usr/bin/env bash
set -euo pipefail # stop at first failure

SCRIPTDIR=$(dirname $(readlink -f "$0"))
echo "SCRIPTDIR: $SCRIPTDIR"

echo_big() {
    echo""
    echo "##############################################################################################################"
    echo "$1"
    echo "##############################################################################################################"
    echo""
}

# $1 sources folder
git_clean() {
    for project in $(find $1 -mindepth 1 -maxdepth 1 -type d); do
        git -C $project clean -dfx
    done
}

############ MAIN ############

BUILDDIR=$SCRIPTDIR/../build

#Used to clean generated artifacts fromn your sources in maven and gradle repo at the end of the online build (org.MY_COMPANY & com.MY_COMPANY) - SHOULD BE CHANGED
MY_COMPANY=myCompany

echo_big "Prepare build directory"

mkdir -p $BUILDDIR
chmod +x $SCRIPTDIR/templates/*.sh
cp $SCRIPTDIR/templates/* $BUILDDIR
# build tools configuration file used by default when not passed to the build.sh (offline build)
cp $SCRIPTDIR/conf/maven/settings.xml $BUILDDIR/settings.xml


echo "# Prepare setenv.sh"
. $BUILDDIR/setenv.sh online

cd $BUILDDIR
echo_big "Install repositories"
mkdir -p repositories
$SCRIPTDIR/repositories.sh

echo_big "Install tools"
mkdir -p tools
$SCRIPTDIR/tools.sh

echo_big "Retrieve sources"
$SCRIPTDIR/sources.sh --online -d $BUILDDIR/sources

echo_big "Build whole project"
./build.sh --online -s $SCRIPTDIR/conf/maven/settings.xml

echo_big "Clean"
echo "Cleaning maven repo"
# clean _maven.repositories that make offline build failing !!!!!
# see https://stackoverflow.com/questions/16866978/maven-cant-find-my-local-artifacts
find repositories/maven -name "_maven.repositories" -delete
find repositories/maven -name "_remote.repositories" -delete
rm -rf repositories/maven/org/$MY_COMPANY
rm -rf repositories/maven/com/$MY_COMPANY

echo "Cleaning gradle cache"
find $GRADLE_USER_HOME/caches -type d -name "org.$MY_COMPANY*" | xargs rm -rf
find $GRADLE_USER_HOME/caches -type d -name "com.$MY_COMPANY*" | xargs rm -rf

echo "Cleaning sources"
git_clean $BUILDDIR/sources

echo "Moving gradle user home in build directory"
mv $GRADLE_USER_HOME $ARCHIVE_GRADLE_USER_HOME

echo "Moving p2 repo in build directory"
mv $P2_REPO $ARCHIVE_P2_REPO

cd ..

echo "Archiving build folder..."
tar czf  "build.tar.gz" "build"


