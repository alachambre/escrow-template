#!/usr/bin/env bash
set -e

SCRIPTDIR=$(dirname $BASH_SOURCE)

# We install by default Open JDK 12.0.1, and Apache maven 3.6.1, feel free to change it.
if [ ! -d "$JAVA_HOME" ]; then
    echo "# Installing openjdk-12.0.1_linux-x64_bin.tar.gz ..."
    echo "removing files `pwd`/openjdk-12.0.1_linux-x64_bin.tar.gz*"
    rm -f openjdk-12.0.1_linux-x64_bin.tar.gz*
    echo "removing dir `pwd`/jdk8u181-b13"
    rm -rf "jdk-12.0.1"
    echo "removing dir $JAVA_HOME"
    rm -rf "$JAVA_HOME"
    echo "retrieving the jdk archive"
    wget -q https://download.oracle.com/java/GA/jdk12.0.1/69cfe15208a647278a19ef0990eea691/12/GPL/openjdk-12.0.1_linux-x64_bin.tar.gz
    echo "extracting the jdk"
    # m to not restore modification time (this prevents 'Cannot utime: Operation not permitted' error when running on docker
    # with a bound folder that does not belong to the deposit group/user)
    tar -xmf OpenJDK8U-jdk_x64_linux_hotspot_8u181b13.tar.gz
    mv -T jdk-12.0.1 "$JAVA_HOME" && rm -f openjdk-12.0.1_linux-x64_bin.tar.gz
fi

if [ ! -d "$M2_HOME" ]; then
    echo "# Installing apache maven 3.6.1 ..."
    echo "removing files `pwd`/apache-maven-3.6.1-bin.tar.gz"
    rm -f apache-maven-3.6.1-bin.tar.gz*
    echo "removing dir `pwd`/apache-maven-3.6.1"
    rm -rf "apache-maven-3.6.1"
    echo "removing dir $M2_HOME"
    rm -rf "$M2_HOME"
    wget -q https://www-eu.apache.org/dist/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.tar.gz
    tar -kxzf apache-maven-3.6.1-bin.tar.gz
    mv -T apache-maven-3.6.1 "$M2_HOME" && rm -f apache-maven-3.6.1-bin.tar.gz
    cp "$SCRIPTDIR/conf/maven/settings.xml" "$M2_HOME"/conf
fi
