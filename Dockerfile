FROM openkbs/jdk-mvn-py3-x11

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

#### ---- Build Specification ----
# Metadata params
ARG BUILD_DATE=${BUILD_DATE:-`date`}
ARG VERSION=${VERSION:-}
ARG VCS_REF=${VCS_REF:-}

#### ---- Product Specifications ----
ENV PRODUCT=${PRODUCT:-"compass"}
ENV PRODUCT_VERSION=${PRODUCT_VERSION:-1.16.3}
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
    sudo apt-get install -y gosu firefox

#### --------------------------
#### ---- Install Product ----:
#### --------------------------
# https://downloads.mongodb.com/compass/mongodb-compass-community_1.16.3_amd64.deb
ARG PRODUCT_URL=https://downloads.mongodb.com/${PRODUCT}/mongodb-${PRODUCT}_${PRODUCT_VERSION}_amd64.deb
#RUN sudo wget https://downloads.mongodb.com/compass/mongodb-compass-community_1.16.3_amd64.deb
RUN sudo wget --no-check-certificate ${PRODUCT_URL}
#RUN wget wget https://downloads.mongodb.com/compass/mongodb-compass-community_1.16.3_amd64.deb

RUN sudo apt-get update -y && \
    sudo apt-get install -y libsecret-1-0 libgconf-2-4 libnss3 && \
    sudo dpkg -i $(basename ${PRODUCT_URL});

#### ---- Plugin for Compass ---- ####
#RUN wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash && \
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash 

RUN \
    export NVM_DIR="$HOME/.nvm" && \
    sudo chown -R ${USER}:${USER} ${HOME} && \
    chmod +x .nvm/nvm.sh && $NVM_DIR/nvm.sh && \
    #nvm install stable && \
    #npm install -g khaos && \
    mkdir -p ${HOME}/.mongodb/${PRODUCT}-community/plugins
    
    #cd ${HOME}/.mongodb/${PRODUCT}-community/plugins && khaos create mongodb-js/compass-plugin ./${USER}-plugin && \
    #cd ${HOME}/.mongo/compass/plugins

#RUN \
#    # [ -s "$NVM_DIR/nvm.sh" ] && \
#    /bin/bash -c "$NVM_DIR/nvm.sh" 
#    # This loads nvm

#### --- Copy Entrypoint script in the container ---- ####
COPY ./docker-entrypoint.sh /

#### ------------------------
#### ---- user: Non-Root ----
#### ------------------------
    
#### --- Enterpoint for container ---- ####
USER ${USER_NAME}
WORKDIR ${HOME}

#ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/bin/mongodb-compass"]

#### (Test only)
#CMD ["/usr/bin/firefox"]

