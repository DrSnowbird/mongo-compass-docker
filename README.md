# Docker Project Template
[![](https://images.microbadger.com/badges/image/openkbs/mongo-gui-docker.svg)](https://microbadger.com/images/openkbs/mongo-gui-docker "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/openkbs/mongo-gui-docker.svg)](https://microbadger.com/images/openkbs/mongo-gui-docker "Get your own version badge on microbadger.com")

# Purpose
To provide the common files for building, running a docker project

# Concepts
## > Simple command-based Docker environments:
- Open Source code for all containers:
For community to extend or improve upon.
- Hiding the details with one command to run or build:
As simple as just one command to start a Docker-based applications without fudging and mistakes in launching containers.

## > Container-based Development and Big Data Analytic Environments
- Providing many commonly used "pure docker-based IDEs, Applications, Servers" for software development daily needs.
- Supporting development (e.g. JDK, Python, ...) and advanced applications/servers (e.g., scala-ide-docker, Netbean-docker, Jupyter, Zeppelin, SparkNotebook, Eclipse-docker, and many other big data analytic, deep learning, machine learning, and semantic knowledge graph applications/servers).

## > Only needs two scripts: "./run.sh" and "./build.sh"
- "./run.sh" to instantly stand up and "./build/sh" to build containers.
- For Product usage, please ensure all aspects of security by enhancing source code and setup.

# Resources
- This project template folder assumes you like to adopt and use simple command-based Docker life-cycle paradigm using containers:
1. OpenKBS Docker HUB [https://hub.docker.com/r/openkbs/] - for pulling the ready to use public Docker Images.
2. OpenKBS GIT HUB [https://github.com/DrSnowbird/] - for advanced users like to build and customize to your own flavor using our open source environments.

# How to Use this template?
1. Git clone or Copy all the folder's files to your destination, i.e., your new project folder.
2. Globally replace "mongo-gui-docker" for all the files with your new Docker project repo name, e.g., scala-ide-docker.
3. Modify files below depending upon your use case:
Dockerfile, docker-compose.yaml, or docker.env (if you need to modify docker environments input file)
4. You don't have to modify the generic scripts, "build.sh" and "run.sh".
5. (optional) Modify "build.sh" and "run.sh" if needed to change any of these two scripts - expert only!
6. Add any Volumes you want auto mapping between Host and Docker Container: add volume entries in "docker.env" files - the file has explanation text in it. For example, to create two mapping of volumes, "data" and "workspace", 
```
## Rider configuration for run.sh ####
# - Use "#VOLUMES" and "#PORTS" to indicate that the variables for run.sh"
# - To ignore line, use "##" (double) in the beginning, 
#     e.g. "##VOLUMES" and "##PORTS"
# - To indicate that the variables for run.sh", use only one "#",  
#     e.g. "#VOLUMES" and "#PORTS"
#VOLUMES_LIST="data workspace"

```
Then, you are ready to build and run (see below).

# Build
- This project provides a simple Dockerfile for the purpose of illustration only. You need to extend/modify the Docker to
support whatever you want to do.
```
./build.sh
```

# (NEW) Configuration
New extension to allow users to enter "Volume mapping" and "Port mapping" entries together with "docker.env" file with "#" syntax to avoid docker-compose pick up the entries -- "Rider" configuration!
Here is the example syntax:
```
## Rider configuration for run.sh ####
# - Use "#VOLUMES" and "#PORTS" to indicate that the variables for run.sh"
# - To ignore line, use "##" (double) in the beginning, e.g. "##VOLUMES" and "##PORTS"
# - To indicate that the variables for run.sh", use only one "#",  e.g. "#VOLUMES" and "#PORTS"
#VOLUMES_LIST="data workspace"
##PORTS_LIST="18080:8000 17200:7200"
```
# Run
- To run the simple example build image; it will pop up X11 to display Firefox docker-based browser.
Note that the script "run.sh" is designed to generic for every project with assumption that it use the "current git directory name" to figure out the image name you may want to use.
```
./run.sh
```

# Utility Scripts
Scripts under ./bin have several useful bash scripts to jump start what you need.
1. dockerCE-install.sh: Install docker CE with latest version available.
2. portainer_resume.sh: Launch portainer to manage all you desktop Docker containers.
3. container-launcher.sh: Launch specific container using "pattern expression".

# References & Resources
* [Docker ARG and ENV Guide](https://vsupalov.com/docker-arg-env-variable-guide/)
* [Docker SECCOMP] (https://en.wikipedia.org/wiki/Seccomp)

# Docker Finer-grained Access Control 
Docker is a software that allows to run applications inside of isolated containers. Docker can associate a seccomp profile with the container using the **--security-opt** parameter. Using OPA, you can easily have finer-grained access control.
* [OpenPolicyAgent OPA](https://www.openpolicyagent.org/docs/docker-authorization.html)
