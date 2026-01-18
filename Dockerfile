# Build stage
FROM gradle:8-jdk21-alpine AS build

WORKDIR /app

# Copy Gradle wrapper and build files
COPY gradle/ gradle/
COPY build.gradle settings.gradle ./
COPY gradlew ./
RUN chmod +x gradlew

# Copy source code
COPY src/ src/

# Build the application
RUN ./gradlew clean build -x test --no-daemon

# Runtime stage
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Create non-root user
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copy the built JAR from build stage
COPY --from=build /app/build/libs/*.jar app.jar

# Expose port
EXPOSE 8080

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
