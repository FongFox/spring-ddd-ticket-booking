# Stage 1: Build
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /app

# Copy toàn bộ source
COPY . .

# Build — bỏ qua test cho nhanh
RUN ./mvnw clean package -DskipTests

# Stage 2: Run — dùng JRE nhẹ hơn JDK
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Chỉ copy JAR từ stage build — image nhỏ hơn
COPY --from=build /app/vetautet-start/target/*.jar app.jar

# Render tự inject PORT — Spring Boot đọc qua ${PORT:1122}
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]