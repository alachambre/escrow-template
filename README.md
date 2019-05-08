# Escrow

## Goal

Register the source code to
- prove that we are the owner of the code in case of legal procedure
- reassure customers about the ability to rebuild the product as good development practises or by a 3rd party in case of
Bonitasoft company bankrupt


## Overview

The code deposit is composed of 2 phases
* 1st build an archive containing all resources (sources, tools, dependencies) required to build the solution offline
* Then use the previously built archive and build the solution offline. This ensures that the code-deposit source archive
contains all resources without any external dependencies

## Content
- apply to Bonita Platform and Bonita ICI (for other addons, see related folders in this repository)
- community and subscription sources, buildable offline
- dossier de fabrication (built with code deposit people)
- documentation: sources are packaged in the provided archive

## Build standalone bonita build system

### Requirements
- Linux 64 bit OS
- _jq_ installed http://stedolan.github.io/jq/  (on ubuntu: `sudo apt-get install jq`)
- Have a github account [configured with ssh](https://help.github.com/articles/generating-an-ssh-key/) to checkout bonita private projects (you can use bonita-ci account for that)

### Create archive
Launch main script with wanted TAG as argument
```shell
./main.sh 7.0.0
```

What does it does
- Create a _build_ directory
- Install tools needed for build
- Checkout projects
- Patch sources before online build
- Build the whole product
- Patch sources after online build
- Clean

### Overview
#### conf
Code deposit configuration. Contains settings to build product online and json files with repo and associated version.
Loaded conf file will be <tag>.json

Here is json model used for our specific needs. By default, projects are built using the maven distribution installed by
the overall process.

```javascript
{
  "repo": "<repository name>",
  "tag": "<repo tag (main tag if not specified)>",
  "directory": "<directory to be cloned in (repo name if not specified)",
  "args": "<extra maven/gradle arguments (optional)>",
  "mvnw": "<true/false, whether the project uses maven wrapper to be built or not (optional, default: false)>",
  "gradlew": "<true/false, whether the project uses gradle wrapper to be built or not (optional, default: false)>",
  "type": "<doc/regular, wether the project is a doc project or not (default: regular)>"
}
```

#### templates
Template files that will be copied to build directory and use to build project offline and online. Some of them will be filled by main script.

#### Scripts
- _main.sh_ main script to be launched for creating code deposit archive. Prepare build environment, launch other scripts and clean build environment after online build.
- _repositories.sh_ install needed repositories (p2, maven, npm, bower, gradle)
- _tools.sh_ install needed build tools (java, maven, node/npm, bitrock)
- _sources.sh_ checkout sources defined in configuration files
- _patch-before.sh_ patch sources before online build to be built correctly, this patches are not wanted and Jira issues are open for each patched lines. Please remove this patches while Jira issues are resolved
- _patch-after.sh_ patch sources after online build, main changes are done in order to build projects when no internet connection is provided.




## Docker image

A docker image is set to run code deposit. Purpose is to
* provide a environment with all prerequisites installed to have it up and running quickly
* use it as often as required using a CI job and weekly tags


### Prepare de the image

Build the image, the argument `tag` is mandatory and should match one of the json file in the conf folder:
```
docker build --build-arg tag=7.8.0 -t registry.rd.lan/bonitasoft/deposit .
```

### Use image to run deposit

Run the image with the default command:
```
docker run registry.rd.lan/bonitasoft/deposit
```

For an interactive mode, you can overwrite the default command with `bash` :
* useful for development, in the following, `PWD` supposes that the command is run from the project directory (otherwise
adapt by setting the path on the host machine)
* `--rm` is to use the container as a tool, it will be deleted on exit
```
docker run -ti --rm --name bonita-deposit -v "${PWD}:/home/deposit/bonita" registry.rd.lan/bonitasoft/deposit bash
```

* if you want to test an offline build (no internet connection), add the following parameters to the docker command (see also the `Jenkinsfile` of the project for more info about the options)

  ```
  --net none --add-host=deposit:10.0.0.1 --hostname=deposit
  ```