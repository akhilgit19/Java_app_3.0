# FROM openjdk:8-jdk-alpine
# WORKDIR /app
# COPY ./target/*.jar /app.jar
# CMD ["java", "-jar", "/app.jar"]
FROM eclipse-temurin:8-jdk

WORKDIR /app

COPY target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","app.jar"]
