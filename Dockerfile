FROM mozilla/sbt:8u232_1.3.13
WORKDIR /app
COPY . .
RUN sbt universal:packageBin
RUN sbt stage
ENTRYPOINT /bin/bash ./run.sh
