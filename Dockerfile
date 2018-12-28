FROM openkbs/jdk-mvn-py3-x11

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

#### ---- Build Specification ----
# Metadata params
ARG BUILD_DATE=${BUILD_DATE:-`date`}
ARG VERSION=${BUILD_DATE:-}
ARG VCS_REF=${BUILD_DATE:-}

#### ---- Product Specifications ----
ARG PRODUCT=${PRODUCT:-"compass"}
ARG PRODUCT_VERSION=${PRODUCT_VERSION:-1.15.1}
ARG PRODUCT_DIR=${PRODUCT_DIR:-/usr/share}
ARG PRODUCT_EXE=${PRODUCT_EXE:-mongodb-compass}
ENV PRODUCT=${PRODUCT:-"compass"}
ENV PRODUCT_VERSION=${PRODUCT_VERSION:-1.15.1}
ENV PRODUCT_DIR=${PRODUCT_DIR}
ENV PRODUCT_EXE=${PRODUCT_EXE:-mongodb-compass}

# Metadata
LABEL org.label-schema.url="https://imagelayers.io" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.version=$VERSION \
      org.label-schema.vcs-url="https://github.com/microscaling/imagelayers-graph.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.description="This utility provides a docker template files for building Docker." \
      org.label-schema.schema-version="1.0"
      
RUN echo PRODUCT=${PRODUCT} && echo HOME=$HOME && \
    sudo apt install -y gosu firefox

#### --------------------------
#### ---- Install Product ----:
#### --------------------------

#RUN sudo wget https://downloads.mongodb.com/compass/mongodb-compass_1.15.1_amd64.deb;
RUN sudo wget https://downloads.mongodb.com/${PRODUCT}/mongodb-${PRODUCT}_${PRODUCT_VERSION}_amd64.deb;

RUN sudo apt-get update -y && \
    sudo apt-get install -y libsecret-1-0 libgconf-2-4 libnss3 && \
    sudo dpkg -i mongodb-compass_1.15.1_amd64.deb;

#### --- Copy Entrypoint script in the container ---- ####
COPY ./docker-entrypoint.sh /

#### ------------------------
#### ---- user: Non-Root ----
#### ------------------------
#ENV USER_NAME=${USER_NAME:-developer}
#ENV HOME=/home/${USER_NAME}

#ARG USER_ID=${USER_ID:-1000}
#ENV USER_ID=${USER_ID}

#ARG GROUP_ID=${GROUP_ID:-1000}
#ENV GROUP_ID=${GROUP_ID}

#RUN \
#    groupadd -g ${GROUP_ID} ${USER_NAME} && \
#    useradd -d ${HOME} -s /bin/bash -u ${USER_ID} -g ${USER_NAME} ${USER_NAME} && \
#    usermod -aG root ${USER_NAME} && \
#    export uid=${USER_ID} gid=${GROUP_ID} && \
#    mkdir -p ${HOME} && \
#    mkdir -p ${HOME}/workspace && \
#    mkdir -p /etc/sudoers.d && \
#    echo "${USER_NAME}:x:${USER_ID}:${GROUP_ID}:${USER_NAME},,,:${HOME}:/bin/bash" >> /etc/passwd && \
#    echo "${USER_NAME}:x:${USER_ID}:" >> /etc/group && \
#    echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER_NAME} && \
#    chmod 0440 /etc/sudoers.d/${USER_NAME} && \
#    chown ${USER_NAME}:${USER_NAME} -R ${HOME} && \
#    apt-get clean all
    
#### --- Enterpoint for container ---- ####
USER ${USER_NAME}
WORKDIR ${HOME}

ENTRYPOINT ["/docker-entrypoint.sh"]

#### (Test only)
#CMD ["/usr/bin/firefox"]
#CMD ["/bin/bash"]

