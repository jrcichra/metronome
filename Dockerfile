FROM mozilla/sbt:8u232_1.3.13
WORKDIR /app
COPY . .
RUN sbt universal:packageBin
ENTRYPOINT ./run.sh
