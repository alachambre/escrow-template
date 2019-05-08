#!/bin/bash
set -euo pipefail

checkErrs() {
    if [ "$1" != "0" ]; then
         exit ${1}
    fi
}

BUILDSCRIPTDIR=$(dirname $(readlink -f "$0"))

SETTINGS="$BUILDSCRIPTDIR/settings.xml"
OFFLINE="-o"
OFFLINE_GRADLE="--offline"
BUILDTYPE="offline"
while (( "$#" )); do
    case $1 in
        -s|--settings)
          SETTINGS="$2"
          shift 2
          ;;
        --online)
          OFFLINE=""
          OFFLINE_GRADLE=""
          BUILDTYPE="online"
          shift
          ;;
        *)
          shift
        ;;
    esac
done

echo_big() {
    echo""
    echo "##############################################################################################################"
    echo "$1"
    echo "##############################################################################################################"
    echo""
}

maven() {
  project=$1
  shift
  echo "-------------------------------------------------------------------------------------------------------------"
  echo "Building project $project..."
  echo "mvn clean install -B -ff -DskipTests -s $SETTINGS $OFFLINE -f $BUILDSCRIPTDIR/sources/$project/pom.xml $@"
  echo "-------------------------------------------------------------------------------------------------------------"
  mvn clean install -B -ff -DskipTests -s $SETTINGS $OFFLINE -f $BUILDSCRIPTDIR/sources/$project/pom.xml "$@"
  checkErrs $?
}

mvnw() {
  project=$1
  shift
  echo "-------------------------------------------------------------------------------------------"
  echo "Building project $project..."
  echo "./mvnw clean install -ff -DskipTests -s $SETTINGS $OFFLINE $@"
  echo "-------------------------------------------------------------------------------------------"

  pushd $BUILDSCRIPTDIR/sources/${project}
  ./mvnw clean install -ff -DskipTests -s $SETTINGS $OFFLINE "$@"
  popd
  checkErrs $?
}

gradle() {
  project=$1
  shift
  echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
  echo "Building project $project..."
  echo "$BUILDSCRIPTDIR/sources/$project/gradlew $OFFLINE_GRADLE -b $BUILDSCRIPTDIR/sources/$project/build.gradle clean build publishToMavenLocal --info --stacktrace -x test $@"
  echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
  $BUILDSCRIPTDIR/sources/$project/gradlew $OFFLINE_GRADLE -b $BUILDSCRIPTDIR/sources/$project/build.gradle clean build publishToMavenLocal -x test --no-build-cache "$@"
  checkErrs $?
}

