FROM mutterio/mini-base

ENV VERSION=v4.2.0

RUN apk add --update curl make gcc g++ python linux-headers paxctl \
    libgcc libstdc++ libc-dev pkgconfig zeromq-dev && \
  curl -sSL https://nodejs.org/dist/${VERSION}/node-${VERSION}.tar.gz | tar -xz && \
  cd /node-${VERSION} && \

  ./configure --prefix=/usr ${CONFIG_FLAGS} && \
  make -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
  make install && \
  paxctl -cm /usr/bin/node && \
  cd / && \
  if [ -x /usr/bin/npm ]; then \
    npm install -g npm && \
    find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf; \
  fi && \
  rm -rf \
    /etc/ssl \
    /node-${VERSION} \
    ${RM_DIRS} \
    /usr/share/man \
    /tmp/* \
    /var/cache/apk/* \
    /root/.npm \
    /root/.node-gyp \
    /usr/lib/node_modules/npm/man \
    /usr/lib/node_modules/npm/doc \
    /usr/lib/node_modules/npm/html

ENV APP_DIR=/opt/app

ADD . ${APP_DIR}
WORKDIR ${APP_DIR}
RUN npm install
