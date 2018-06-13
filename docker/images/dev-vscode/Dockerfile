# Creates an image for skycoin development
FROM golang:1.10.2-stretch

MAINTAINER stdevDtkid

# Installs nodejs and npm. Needed for moxygen.

# Packages installed in buildpack-deps:stretch
RUN set -ex; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    bzip2 \
    dpkg-dev \
    file \
    g++ \
    gcc \
    imagemagick \
    libbz2-dev \
    libc6-dev \
    libcurl4-openssl-dev \
    libdb-dev \
    libevent-dev \
    libffi-dev \
    libgdbm-dev \
    libgeoip-dev \
    libglib2.0-dev \
    libjpeg-dev \
    libkrb5-dev \
    liblzma-dev \
    libmagickcore-dev \
    libmagickwand-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libpng-dev \
    libpq-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libtool \
    libwebp-dev \
    libxml2-dev \
    libxslt-dev \
    libyaml-dev \
    make \
    patch \
    xz-utils \
    zlib1g-dev \
    \
# No need for MySQL client
#
# # https://lists.debian.org/debian-devel-announce/2016/09/msg00000.html
#     $( \
# # if we use just "apt-cache show" here, it returns zero because "Can't select versions from package 'libmysqlclient-dev' as it is purely virtual", hence the pipe to grep
#       if apt-cache show 'default-libmysqlclient-dev' 2>/dev/null | grep -q '^Version:'; then \
#         echo 'default-libmysqlclient-dev'; \
#       else \
#         echo 'libmysqlclient-dev'; \
#       fi \
#     ) \
   ; \
  apt-get clean; \
  rm -rf /var/lib/apt/lists/*

# Build steps in node:10 (uid=2000)
RUN groupadd --gid 2000 node \
  && useradd --uid 2000 --gid node --shell /bin/bash --create-home node

# gpg keys listed at https://github.com/nodejs/node#release-team
RUN set -ex \
  && for key in \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
    77984A986EBC2AA786BC0F66B01FBB92821C587A \
  ; do \
    gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done

ENV NODE_VERSION 10.2.1

RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    i386) ARCH='x86';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
  && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs

ENV YARN_VERSION 1.7.0

RUN set -ex \
  && for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
  ; do \
    gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
  && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && mkdir -p /opt \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
  && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz

# Installs software
RUN set -ex ; \
    apt-get update ; \
    apt-get install -y --no-install-recommends \
    cmake \
    libpcre3-dev \
    gdbserver \
    gdb \
    vim \
    ctags \
    vim-scripts \
    screen \
    sudo \
    doxygen \
    swig \
    texlive-latex-base \
    ; \
    apt-get clean ; \
    rm -rf /var/lib/apt/lists/* ; \
    npm install moxygen -g ; \
    \
    \
    echo 'Installing Criterion ...' ; \
    git clone --recurse-submodules -j8 https://github.com/skycoin/Criterion /go/Criterion ; \
    cd /go/Criterion ; \
    cmake . ; \
    make install ; \
    rm -r /go/Criterion ; \
    echo 'Success nstalling Criterion ...'

# Installs go development tools
RUN go get -u github.com/derekparker/delve/cmd/dlv  && \
    go get -u github.com/FiloSottile/vendorcheck && \
    go get -u github.com/alecthomas/gometalinter && \
    gometalinter --vendored-linters --install && \
    go get -u github.com/zmb3/gogetdoc && \
    go get -u golang.org/x/tools/cmd/guru && \
    go get -u github.com/davidrjenni/reftools/cmd/fillstruct && \
    go get -u github.com/rogpeppe/godef && \
    go get -u github.com/fatih/motion && \
    go get -u github.com/nsf/gocode && \
    go get -u github.com/jstemmer/gotags && \
    go get -u github.com/josharian/impl && \
    go get -u github.com/fatih/gomodifytags && \
    go get -u github.com/dominikh/go-tools/cmd/keyify && \
    go get -u golang.org/x/tools/cmd/gorename && \
    go get -u github.com/klauspost/asmfmt/cmd/asmfmt && \
    go get -u github.com/ernesto-jimenez/goautomock

# Install vim-go development tools
RUN git clone https://github.com/fatih/vim-go /usr/share/vim/vim80/pack/dev/start/vim-go && \
    git clone https://github.com/tpope/vim-fugitive /usr/share/vim/vim80/pack/dev/start/vim-fugitive && \
    git clone https://github.com/Shougo/vimshell.vim /usr/share/vim/vim80/pack/dev/start/0vimshell && \
    git clone https://github.com/Shougo/vimproc.vim /usr/share/vim/vim80/pack/dev/start/0vimproc && \
    cd /usr/share/vim/vim80/pack/dev/start/0vimproc && make 

WORKDIR $GOPATH/src/github.com/skycoin
VOLUME $GOPATH/src/

ENV LD_LIBRARY_PATH=/usr/local/lib


# Install Vscode in the container
#

ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    VSCODE=https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable \
    TINI_VERSION=v0.16.1 \
    GOVERSION=1.9.1


ARG VCF_REF
ARG BUILD_DATE
LABEL org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.license="MIT" \
      org.label-schema.name="e.g. VsCode" \
      org.label-schema.url="https://code.visualstudio.com/" \
      org.label-schema.vcs-type="e.g. Git" \
      org.label-schema.vcs-url="e.g.https://github.com/allamand/docker-vscode" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF

ARG MYUSERNAME=developer
ARG MYUID=2000
ARG MYGID=200
ENV MYUSERNAME=${MYUSERNAME} \
    MYUID=${MYUID} \
    MYGID=${MYGID} 

RUN apt-get update -qq && \
    echo 'Installing OS dependencies' && \
    apt-get install -qq -y --fix-missing \ 
      software-properties-common libxext-dev libxrender-dev libxslt1.1 \
      libgconf-2-4 libnotify4 libnspr4 libnss3 libnss3-nssdb \
      libxtst-dev libgtk2.0-0 libcanberra-gtk-module \
      libxss1 \
      libxkbfile1 \
      git curl tree locate net-tools telnet \
      emacs ruby make bash-completion \
      bash-completion python python-pip meld \
      nodejs-legacy npm \
      libxkbfile1 \
      libxss1 \
      locales netcat \
    && \
    npm install -g npm && \
    pip install --upgrade pip && \
    pip install mkdocs && \
    echo 'Cleaning up' && \
    apt-get clean -qq -y && \
    apt-get autoclean -qq -y && \
    apt-get autoremove -qq -y &&  \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    updatedb && \
    locale-gen en_US.UTF-8

#RUN useradd --no-create-home -g users syncthing

RUN echo 'Creating user: ${MYUSERNAME} wit UID $UID' && \
    mkdir -p /home/${MYUSERNAME} && \
    echo "${MYUSERNAME}:x:${MYUID}:${MYGID}:Developer,,,:/home/${MYUSERNAME}:/bin/bash" >> /etc/passwd && \
    echo "${MYUSERNAME}:x:${MYGID}:" >> /etc/group && \
    sudo echo "${MYUSERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${MYUSERNAME} && \
    sudo chmod 0440 /etc/sudoers.d/${MYUSERNAME} && \
    sudo chown ${MYUSERNAME}:${MYUSERNAME} -R /home/${MYUSERNAME} && \
    sudo chown root:root /usr/bin/sudo && \
    chmod 4755 /usr/bin/sudo && \

    echo "Downloading Go ${GOVERSION}" && \
    echo curl -o /tmp/go.tar.gz -J -L "https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz" && \
    curl -o /tmp/go.tar.gz -J -L "https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz" && \     
    
    echo "Installing Go ${GOVERSION}" && \
    sudo tar -zxf /tmp/go.tar.gz -C /usr/local/ && \
    rm -f /tmp/go.tar.gz && \

    echo 'Installing VsCode' && \
    curl -o vscode.deb -J -L "$VSCODE" && \
    dpkg -i vscode.deb && rm -f vscode.deb && \


    echo 'Installing Cloud Foundry Client' && \
    curl -o cf_cli.deb -J -L 'https://cli.run.pivotal.io/stable?release=debian64&source=github' && \
    dpkg -i cf_cli.deb  && rm cf_cli.deb && \
    sudo gem install cf_completion && \
    echo "complete -C cf_completion cf" >> ~/.bash_profile && \
    echo "Install OK"



#USER ${MYUSERNAME}
ENV HOME /home/${MYUSERNAME}
ENV GOPATH /home/${MYUSERNAME}/go
ENV PATH $PATH:/home/${MYUSERNAME}/go/bin:/usr/local/go/bin
ENV TERM=xterm

WORKDIR /home/${MYUSERNAME}/go

ADD ./entrypoint.sh /entrypoint.sh

# Add Tini Init System
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini && chmod +x /entrypoint.sh
ENTRYPOINT ["/tini", "--", "/entrypoint.sh"]
CMD ["vscode"]
