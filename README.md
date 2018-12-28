# Mongodb-Compass 1.15 + Java 8 JDK + Maven 3.5 + Python 3.5 +  Gradle 4.9

[![](https://images.microbadger.com/badges/image/openkbs/mongodb-compasss-docker.svg)](https://microbadger.com/images/openkbs/mongodb-compasss-docker "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/openkbs/mongodb-compasss-docker.svg)](https://microbadger.com/images/openkbs/mongodb-compasss-docker "Get your own version badge on microbadger.com")

# License Agreement
By using this image, you agree the [Oracle Java JDK License](http://www.oracle.com/technetwork/java/javase/terms/license/index.html).
This image contains [Oracle JDK 8](http://www.oracle.com/technetwork/java/javase/downloads/index.html). You must accept the [Oracle Binary Code License Agreement for Java SE](http://www.oracle.com/technetwork/java/javase/terms/license/index.html) to use this image.

# Components
* [Mongodb-Compass](https://docs.mongodb.com/compass) 1.15 
* java version "1.8.0_191"
  Java(TM) SE Runtime Environment (build 1.8.0_191-b12)
  Java HotSpot(TM) 64-Bit Server VM (build 25.191-b12, mixed mode)
* Apache Maven 3.5.3
* Python 3.5.2
* Other tools: git wget unzip vim python python-setuptools python-dev python-numpy 

# Run (recommended for easy-start)
Image is pulling from openkbs/mongodb-compass
```
./run.sh
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

# See also
* [MySQL Workbench for MySQL Database Server Docker at openkbs/mysql-workbench](https://hub.docker.com/r/openkbs/mysql-workbench/)
* [Sqlectron SQL GUI at openkbs/sqlectron-docker](https://hub.docker.com/r/openkbs/sqlectron-docker/)
* [Mysql-Workbench at openkbs/mysql-workbench](https://hub.docker.com/r/openkbs/mysql-workbench/)
* [PgAdmin4 for PostgreSQL at openkbs/pgadmin-docker](https://hub.docker.com/r/openkbs/pgadmin-docker/)

