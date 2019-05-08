#!/usr/bin/env bash
set -euo pipefail

SCRIPTDIR=$(dirname $(readlink -f "$0"))

# The user / the organization which own the repositories to clone - SHOULD BE CHANGED
GIT_USER=git@github.com:alachambre

usage() {
    echo "*******************************************************************************************************************"
    echo -e "\033[31mERROR - $1 \033[0m"
    echo ""
    echo "Usage :"
    echo " $0 [-d <output_directory>]"
    echo ""
    echo "*******************************************************************************************************************"
    exit 1;
}

# Override default pushd / pod commands to NOT log output:
pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

while (( "$#" )); do
    case $1 in
        -d)
        SRCDIR="$2"
        shift 2
        ;;
        *)
        shift
        ;;
    esac
done

CONFFILE="sources.json"

if [ ! -f $CONFFILE ]; then
  usage "Can't find the configuration file $CONFFILE";
fi

OUTPUTDIR=$SCRIPTDIR/../build
TEMPLATEFILE=$OUTPUTDIR/build.sh

mkdir -p $SRCDIR
cd $SRCDIR


# $1 path
# $2 default value when not found
jsonpath() {
    val=$(jq $1 $CONFFILE | sed 's/"//g')
    if [ "null" == "$val" ]; then
      echo $2
    else
      echo $val
    fi
}

# don't warn about git clone detached HEAD, instead of redirecting ALL output to /dev/null
git config --global advice.detachedHead false

#################################################################################################
###### MAIN - Add repositories to build in the file build.sh, and clone them in necessary #######
#################################################################################################
echo "full_build() {" >> $TEMPLATEFILE
echo '. $BUILDSCRIPTDIR/setenv.sh "$BUILDTYPE"' $PRODUCT >> $TEMPLATEFILE
count=$(cat $CONFFILE | jq 'length')
for((i=0;i<$count;i++))
do
    repo=$(jsonpath '.['$i'].repo')
    tag=$(jsonpath '.['$i'].tag')
    directory=$repo.$tag
    args=$(jsonpath '.['$i'].args' "")
    gradlew=$(jsonpath '.['$i'].gradlew' "false")
    mvnw=$(jsonpath '.['$i'].mvnw' "false")
    if [ -d $directory ]
    then
        echo "# $directory already exists. Updating..."
        pushd $directory
        git fetch -q origin $tag
        git checkout -q $tag
        popd
    else
        echo "# Cloning tag $tag from $GIT_USER/$repo.git into $directory ..."
        git clone -q --branch $tag --single-branch $GIT_USER/$repo.git $directory
    fi

    if [ "$gradlew" = "true" ]; then
        echo "  gradle $directory $args" >> $TEMPLATEFILE
    elif [ "$mvnw" = "true" ]; then
        echo "  mvnw $directory $args" >> $TEMPLATEFILE
    else
        echo "  maven $directory $args" >> $TEMPLATEFILE     
    fi
done
echo "}" >> $TEMPLATEFILE
echo "" >> $TEMPLATEFILE
echo "(full_build) | tee \$BUILDSCRIPTDIR/build_\$BUILDTYPE.log" >> $TEMPLATEFILE
