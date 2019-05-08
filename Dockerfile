FROM ubuntu:18.04

ENV ESCROW_HOME /home/escrow

# mandatory to be able to install tzadata in non interactive mode (required to set the timezone)
ENV DEBIAN_FRONTEND noninteractive

ENV JAVA_TOOL_OPTIONS -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap
ENV MAVEN_OPTS -Xmx1g

RUN apt-get update && apt-get install -y --no-install-recommends \
	apt-utils \
	ca-certificates \
    git \
    jq  \
    locales \
    openssh-client \
    tzdata \
    unzip \
    wget

# ensure that we can create directories in deposit workdir
RUN mkdir -p "$ESCROW_HOME" 

# Set the locale to UTF-8:
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# Set timezone to Paris to avoid issues
RUN echo "Europe/Paris" > /etc/timezone && rm -f /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# Configure git identity
RUN git config --global user.email "user@gmail.com" \
    && git config --global user.name "User"

# Copy ssh keys (used to clone repo from github)
COPY src/ssh /root/.ssh/
# Ensure minimum visibility to let ssh accept the key (should be readable by the logged in user)
RUN chmod 400 /root/.ssh/id_rsa

# Ensure that bower install can be run as superuser by adding conf file
RUN cd /root && echo "{ \"allow_root\": true }" > .bowerrc

# Copy scripts used for the build
COPY src ${ESCROW_HOME}/src

WORKDIR ${ESCROW_HOME}

# Default command, for online build
CMD ./src/main.sh
