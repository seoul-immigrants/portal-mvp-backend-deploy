FROM azul/zulu-openjdk-alpine:17
ENV APP_NAME portal-mvp-backend
ENV OP_APP_PATH /data/system/${APP_NAME}
ENV OP_LOG_PATH /data/system/logs/${APP_NAME}

ENV BINARY_NAME app.jar

# make initial directories
RUN mkdir -p ${OP_APP_PATH}
RUN mkdir -p ${OP_LOG_PATH}

# change working directory
WORKDIR ${OP_APP_PATH}

#copy files
COPY ${BINARY_NAME} .

#run application
CMD java \
    -Dlogging.path=${OP_LOG_PATH} \
    -Dlogging.appender.console.level=DEBUG \
    -Dspring.config.location=${PROPERTIES_FILE} \
    -jar ${BINARY_NAME}

# expose port
EXPOSE 8080