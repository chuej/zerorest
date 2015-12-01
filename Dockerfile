FROM chuej/mini-zerorest

ENV APP_DIR=/opt/app

ADD . ${APP_DIR}
WORKDIR ${APP_DIR}
RUN npm install
