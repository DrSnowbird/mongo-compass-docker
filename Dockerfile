FROM openkbs/jdk11-mvn-py3-x11

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

#### ---- Build Specification ----
# Metadata params
ARG BUILD_DATE=${BUILD_DATE:-`date`}
ARG VERSION=${VERSION:-}
ARG VCS_REF=${VCS_REF:-}

#### ---- Product Specifications ----
ENV PRODUCT=${PRODUCT:-"compass"}
ENV PRODUCT_VERSION=${PRODUCT_VERSION:-1.32.0}
ENV PRODUCT_DIR=${PRODUCT_DIR}
ENV PRODUCT_EXE=${PRODUCT_EXE:-mongodb-compass}


#### --------------------------
#### ---- Install Product ----:
#### --------------------------
# https://downloads.mongodb.com/compass/mongodb-compass_1.32.0_amd64.deb
ARG PRODUCT_URL=https://downloads.mongodb.com/${PRODUCT}/mongodb-${PRODUCT}_${PRODUCT_VERSION}_amd64.deb
RUN sudo apt-get update -y && \
    sudo apt-get install -y libsecret-1-0 libgconf-2-4 libnss3 && \
    echo ">>> PRODUCT_URL:${PRODUCT_URL}" && \
    sudo wget -q --no-check-certificate ${PRODUCT_URL} && \
    sudo dpkg -i $(basename ${PRODUCT_URL}) && \
    sudo rm -f $(basename ${PRODUCT_URL})

#### ---- Plugin for Compass ---- ####
#RUN wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash && \
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash 

RUN export NVM_DIR="$HOME/.nvm" && \
    sudo chown -R ${USER}:${USER} ${HOME} && \
    chmod +x .nvm/nvm.sh && $NVM_DIR/nvm.sh && \
    #nvm install stable && \
    #npm install -g khaos && \
    mkdir -p ${HOME}/.mongodb/${PRODUCT}-community/plugins
    
    #cd ${HOME}/.mongodb/${PRODUCT}-community/plugins && khaos create mongodb-js/compass-plugin ./${USER}-plugin && \
    #cd ${HOME}/.mongo/compass/plugins

#### --- Copy Entrypoint script in the container ---- ####
COPY ./docker-entrypoint.sh /

#### ------------------------
#### ---- user: Non-Root ----
#### ------------------------
    
#### --- Enterpoint for container ---- ####
USER ${USER_NAME}
WORKDIR ${HOME}

#ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/bin/mongodb-compass", "--no-sandbox"]

#### (Test only)
#CMD ["/usr/bin/firefox"]

