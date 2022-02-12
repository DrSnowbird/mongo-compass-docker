# Mongodb-Compass 1.15 + OpenJDK Java 11 + Maven 3.8 + Python 3.8  + pip 21 + node 16 + npm 7 + Gradle 7

[![](https://images.microbadger.com/badges/image/openkbs/mongodb-compasss-docker.svg)](https://microbadger.com/images/openkbs/mongodb-compasss-docker "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/openkbs/mongodb-compasss-docker.svg)](https://microbadger.com/images/openkbs/mongodb-compasss-docker "Get your own version badge on microbadger.com")


# Components
* [Mongodb-Compass](https://docs.mongodb.com/compass) 1.15 
* [Base Container Image: openkbs/jdk11-mvn-py3](https://github.com/DrSnowbird/jdk11-mvn-py3)
* [Base Components: OpenJDK, Python 3, PIP, Node/NPM, Gradle, Maven, etc.](https://github.com/DrSnowbird/jdk11-mvn-py3#components)
* Other tools: git wget unzip vim python python-setuptools python-dev python-numpy 

# Run (recommended for easy-start)
Image is pulling from openkbs/mongodb-compass
```
./run.sh
```

# Run with MongoDB together
You can run Compass DB GUI and local MongoDB (as test database)
```
docker-compose -f ./docker-compose-with-mongo.yml up -d
```
The default password for local MongoDB:
```
      MONGO_INITDB_ROOT_USERNAME: admin-user
      MONGO_INITDB_ROOT_PASSWORD: admin-password
```
# Build
You can build your own image locally.
```
./build.sh
```

# Build / Run your own image

Say, you will build the image "my/mongodb-compasss-docker".

```bash
docker build -t my/mongodb-compasss-docker .
```

To run your own image, say, with some-mongodb-compasss-docker:

```bash
mkdir ./data
docker run -d --name mongodb-compasss-docker -v $PWD/data:/data -i -t my/mongodb-compasss-docker
```

# Shell into the Docker instance
```bash
docker exec -it mongodb-compasss-docker /bin/bash
or 
./shell.sh (if you use default ./run.sh -- not your local build)
```

# References & Resources
* [**Mongodb Document**](https://docs.mongodb.com/)
* [Mongodb Compass (import/export)](https://docs.mongodb.com/compass/master/import-export/)

# See also
* [MySQL Workbench for MySQL Database Server Docker at openkbs/mysql-workbench](https://hub.docker.com/r/openkbs/mysql-workbench/)
* [Sqlectron SQL GUI at openkbs/sqlectron-docker](https://hub.docker.com/r/openkbs/sqlectron-docker/)
* [Mysql-Workbench at openkbs/mysql-workbench](https://hub.docker.com/r/openkbs/mysql-workbench/)
* [PgAdmin4 for PostgreSQL at openkbs/pgadmin-docker](https://hub.docker.com/r/openkbs/pgadmin-docker/)

