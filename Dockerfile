FROM openjdk:8
WORKDIR /app
COPY . .
RUN sbt universal:packageBin
CMD ./run.sh
