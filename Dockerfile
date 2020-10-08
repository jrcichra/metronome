FROM mozilla/sbt:8u232_1.3.13
WORKDIR /app
# env
ENV DEBIAN_FRONTEND "noninteractive"
ENV DEBCONF_NONINTERACTIVE_SEEN "true"
ARG LIBMESOS_BUNDLE_DOWNLOAD_URL="https://downloads.mesosphere.io/libmesos-bundle/libmesos-bundle-1.14-beta.tar.gz"
ARG BOOTSTRAP_DOWNLOAD_URL="https://downloads.mesosphere.com/dcos-commons/artifacts/0.57.0/bootstrap.zip"
# add
COPY . .
# build
RUN sbt universal:packageBin
RUN sbt stage
# lib mesos
ENV MESOSPHERE_HOME="/opt/mesosphere"
ARG BOOTSTRAP_BINARY="${MESOSPHERE_HOME}/bootstrap.zip"
RUN mkdir -p ${MESOSPHERE_HOME} \
    && curl -L ${LIBMESOS_BUNDLE_DOWNLOAD_URL} | tar -C ${MESOSPHERE_HOME} -zx \
    && curl -L -o ${BOOTSTRAP_BINARY} ${BOOTSTRAP_DOWNLOAD_URL} \
    && unzip ${BOOTSTRAP_BINARY} -d ${MESOSPHERE_HOME} \
    && rm ${BOOTSTRAP_BINARY}
# more env
ENV BOOTSTRAP ${MESOSPHERE_HOME}/bootstrap
ENV MESOS_NATIVE_JAVA_LIBRARY ${MESOSPHERE_HOME}/libmesos-bundle/lib/libmesos.so
# entry
ENTRYPOINT ./run.sh
