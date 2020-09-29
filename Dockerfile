FROM openjdk:1.8
WORKDIR /app
COPY . .
sbt universal:packageBin
CMD ./run.sh
