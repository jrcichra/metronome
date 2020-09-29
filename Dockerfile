FROM openjdk:1.8
WORKDIR /app
COPY . .
RUN sbt universal:packageBin
CMD ./run.sh
