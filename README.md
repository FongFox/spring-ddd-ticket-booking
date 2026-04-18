# 🚂 java-ddd-vetautet

> High-concurrency ticket booking system built with Java Spring Boot + Domain-Driven Design (DDD).  
> A follow-along project based on the series by [tipjs/anonystick](https://anonystick.com).

---

## 📖 About

This project simulates a real-world **Tết train ticket booking system** (`vetautet.com`) — one of the highest-concurrency scenarios in Vietnam's e-commerce space, where thousands of users compete for a limited number of tickets at the same time.

The goal is to practice building a **scalable, resilient backend** using clean architecture principles and modern Java ecosystem tooling.

---

## 🏗️ Architecture

The application follows **Domain-Driven Design (DDD)** and is split into 5 main modules:

```
├── start/           # Entry point — bootstraps the Spring Boot application
├── application/     # Use cases, application logic, orchestration
├── controller/      # REST API layer — handles incoming requests
├── infrastructure/  # DB, cache, Kafka configs, external service adapters
└── domain/          # Core business logic, entities, value objects, repositories
```

---

## ⚙️ Tech Stack

| Layer | Technology |
|---|---|
| Language | Java 17+ |
| Framework | Spring Boot |
| Architecture | Domain-Driven Design (DDD) |
| Message Queue | Apache Kafka |
| Cache | Redis |
| Database | MySQL / PostgreSQL |
| Resilience | RateLimiter, CircuitBreaker |

---

## 🔑 Key Features

- **Rate Limiter** — controls the number of requests per user/IP to protect the system on sale day
- **Circuit Breaker** — prevents cascading failures when downstream services are slow or down
- **Kafka Integration** — async order processing to handle order spikes without blocking the user
- **DDD Structure** — clean separation of domain logic from infrastructure concerns
- **High-Concurrency Design** — architecture designed to handle 100K+ req/second

---

## 🚀 Getting Started

### Prerequisites

- Java 17+
- Maven 3.8+
- Docker & Docker Compose

### Run locally

```bash
# Clone the repo
git clone https://github.com/your-username/java-ddd-vetautet.git
cd java-ddd-vetautet

# Start dependencies (Kafka, Redis, DB)
docker-compose up -d

# Build and run
./mvnw spring-boot:run
```

---

## 📚 Series Reference

This project is a hands-on implementation following the **Java DDD - Vé Tàu Tết** series by **tipjs**:

- 🌐 Blog: [anonystick.com](https://anonystick.com)
- 📺 YouTube: [JAVA DDD Series](https://www.youtube.com/@anonystick)

> All credit for the architecture design and teaching material goes to tipjs/anonystick.  
> This repo is purely a **learning exercise**.

---

## 📂 Series Progress

- **Note**: ✅ Done; 🔄 In Progress; ⏳ Todo

| Section | Topic | link | Status |
|---|---|---|---|
| 01 | JAVA DDD 01: CÁCH xây dựng dự án triển khai về DDD bán VÉ TÀU, MUSIC với kiến trúc đồng thời CAO! | https://www.youtube.com/watch?v=WFlIoNHD_Yo&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=42 | 🔄 In Progress |

---

## 📝 License

[MIT](./LICENSE)  
Feel free to use this code for learning purposes. Please credit the original series if you share or build on top of it.