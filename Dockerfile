# using debian:jessie for it's smaller size over ubuntu
FROM debian:jessie

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Set environment variables
ENV appDir /var/www/app/current

# Run updates and install deps
RUN apt-get update

RUN apt-get install -y -q --no-install-recommends \
    apt-transport-https \
    build-essential \
    ca-certificates \
    curl \
    g++ \
    gcc \
    git \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libgif-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libpango1.0-dev \
    libssl-dev \
    make \
    nginx \
    rsync \
    rsyslog \
    software-properties-common \
    sudo \
    telnet \
    wget \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get -y autoclean

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 5.1.0

# Install nvm with node and npm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.26.0/install.sh | bash \
    && source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# Set up our PATH correctly so we don't have to long-reference npm, node, &c.
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Set the work directory
RUN mkdir -p /var/www/app/current
WORKDIR ${appDir}

# Add our package.json and install *before* adding our app files
ADD package.json ./
RUN npm i --production

# Add app files
ADD . /var/www/app/current

# Restart nginx
RUN service nginx restart

#Expose the port
EXPOSE 4500

CMD ["pm2", "start", "processes.json"]

# voila!
