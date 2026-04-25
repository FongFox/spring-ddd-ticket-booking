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
spring-ddd-ticket-booking/
├── benchmark/
│   └── README.md
├── environment/
│   ├── docs/
│   │   └── run.md
│   ├── mysql/
│   │   ├── init/
│   │       └── ticket_init.sql
│   └── docker-compose-dev.yml
├── knowledge-summary/
│   ├── diagrams/
│   │   ├── DDD-Layered-Architecture-Diagram.drawio
│   │   └── module-dependency-diagram.drawio
│   ├── other/
│   │   ├── ddd-package-structures.html
│   │   ├── ddd-package-structures.md
│   │   └── spring-boot-ddd-from-scratch-ver-0.html
│   ├── section-0-4/
│       ├── Cache-Aside-Pattern-2.png
│       ├── Cache-Aside-Pattern.png
│       ├── Circuit Breaker-Resilience4j-2.png
│       ├── Circuit Breaker-Resilience4j.png
│       ├── DDD-Layered-Architecture-project-structure-2.png
│       ├── DDD-Layered-Architecture-project-structure.png
│       ├── Distributed-Lock-Redisson-2.png
│       ├── Distributed-Lock-Redisson.png
│       ├── Optional.md
│       ├── Rate Limiter-Resilience4j-2.png
│       ├── Rate Limiter-Resilience4j.png
│       └── section-0-4.md
├── vetautet-application/
│   ├── src/
│   │   ├── main/
│   │       ├── java/
│   │       │   ├── com/
│   │       │       ├── vetautet/
│   │       │           ├── ddd/
│   │       │               ├── application/
│   │       │                   ├── brokerMQ/
│   │       │                   ├── exception/
│   │       │                   ├── model/
│   │       │                   ├── scheduler/
│   │       │                   ├── service/
│   │       │                       ├── event/
│   │       │                       │   ├── cached/
│   │       │                       │   ├── impl/
│   │       │                       │   │   └── EventAppServiceImpl.java
│   │       │                       │   └── IEventAppService.java
│   │       │                       ├── ticket/
│   │       │                           ├── cache/
│   │       │                           │   └── TicketDetailCacheService.java
│   │       │                           ├── impl/
│   │       │                           │   └── TicketDetailAppServiceImpl.java
│   │       │                           └── ITicketDetailAppService.java
│   │       ├── resources/
│   └── pom.xml
├── vetautet-controller/
│   ├── src/
│   │   ├── main/
│   │       ├── java/
│   │           ├── com/
│   │               ├── vetautet/
│   │                   ├── ddd/
│   │                       ├── controller/
│   │                           ├── model/
│   │                           │   ├── enums/
│   │                           │   │   ├── ResultCode.java
│   │                           │   │   └── ResultUtil.java
│   │                           │   ├── vo/
│   │                           │       └── ResultMessage.java
│   │                           ├── resource/
│   │                               ├── HiController.java
│   │                               └── TicketDetailController.java
│   └── pom.xml
├── vetautet-domain/
│   ├── src/
│   │   ├── main/
│   │       ├── java/
│   │       │   ├── com/
│   │       │       ├── vetautet/
│   │       │           ├── ddd/
│   │       │               ├── domain/
│   │       │                   ├── model/
│   │       │                   │   ├── entity/
│   │       │                   │       ├── Ticket.java
│   │       │                   │       └── TicketDetail.java
│   │       │                   ├── repository/
│   │       │                   │   ├── IHiDomainRepository.java
│   │       │                   │   └── ITicketDetailRepository.java
│   │       │                   ├── service/
│   │       │                       ├── impl/
│   │       │                       │   ├── HiDomainServiceImpl.java
│   │       │                       │   └── TicketDetailDomainServiceImpl.java
│   │       │                       ├── IHiDomainService.java
│   │       │                       └── ITicketDetailDomainService.java
│   │       ├── resources/
│   └── pom.xml
├── vetautet-infrastructure/
│   ├── src/
│   │   ├── main/
│   │       ├── java/
│   │           ├── com/
│   │               ├── vetautet/
│   │                   ├── ddd/
│   │                       ├── infrastructure/
│   │                           ├── cache/
│   │                           │   ├── redis/
│   │                           │       ├── RedisInfrasService.java
│   │                           │       └── RedisInfrasServiceImpl.java
│   │                           ├── config/
│   │                           │   ├── AppConfig.java
│   │                           │   └── RedisConfig.java
│   │                           ├── distributed/
│   │                           │   ├── redisson/
│   │                           │       ├── config/
│   │                           │       │   └── RedissonConfig.java
│   │                           │       ├── impl/
│   │                           │       │   └── RedisDistributedLockerImpl.java
│   │                           │       ├── RedisDistributedLocker.java
│   │                           │       └── RedisDistributedService.java
│   │                           ├── persistence/
│   │                               ├── mapper/
│   │                               │   └── TicketDetailJPAMapper.java
│   │                               ├── model/
│   │                               ├── repository/
│   │                                   ├── HiInfrastructureRepositoryImpl.java
│   │                                   └── TicketDetailInfrasRepositoryImpl.java
│   └── pom.xml
├── vetautet-start/
│   ├── src/
│   │   ├── main/
│   │       ├── java/
│   │       │   ├── com/
│   │       │       ├── vetautet/
│   │       │           ├── config/
│   │       │           │   └── OpenApiConfig.java
│   │       │           └── StartApplication.java
│   │       ├── resources/
│   │           └── application.yml
│   └── pom.xml
├── LICENSE
├── README.md
├── mvnw
├── mvnw.cmd
├── pom.xml
└── test.js
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

## 🧪 Load Testing with k6

### Prerequisites
- [k6](https://k6.io/docs/get-started/installation/) installed

### Run

```bash
# Basic test — 50 VUs, 5 seconds
k6 run test.js

# Custom VUs and duration
k6 run --vus 200 --duration 10s test.js

# Save result to file
k6 run test.js 2>&1 | Tee-Object -FilePath "benchmark/results/result-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
```

### Test script (`test.js`)

```javascript
import http from 'k6/http';
export const options = { vus: 50, duration: '5s' };
export default function () { http.get('http://localhost:1122/ticket/1/detail/1'); }
```

### Key metrics to watch

| Metric | Good | Bad |
|---|---|---|
| `http_req_failed` | 0% | > 0% |
| `p(95) latency` | < 200ms | > 500ms |
| `http_reqs/s` | increasing | flat/dropping |

### Benchmark results (local)

| VUs | Duration | Throughput | p(95) | Error rate |
|---|---|---|---|---|
| 50 | 5s | ~2,600/s | 30ms | 0% |
| 50 | 5s | ~2,879/s | 22ms | 0% ← cache warmed |
| 200 | 10s | ~2,694/s | 123ms | 0.72% ← bottleneck |

---

## 🚀 Getting Started

### Prerequisites

- Java 21+
- Maven 3.8+ (hoặc dùng `mvnw.cmd` wrapper đi kèm)
- Docker & Docker Compose

### Run locally

```bash
# Clone the repo
git clone https://github.com/your-username/java-ddd-vetautet.git
cd java-ddd-vetautet

# Start dependencies (MySQL + Redis)
docker-compose -f environment/docker-compose-dev.yml up -d

# Build all modules
./mvnw.cmd clean install -DskipTests

# Run
./mvnw.cmd spring-boot:run -pl vetautet-start
```

### Test API

```bash
curl http://localhost:1122/ticket/1/detail/1
curl http://localhost:1122/hello/hi
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
|---------|---|---|---|
| 01      | JAVA DDD 01: CÁCH xây dựng dự án triển khai về DDD bán VÉ TÀU, MUSIC với kiến trúc đồng thời CAO! | https://www.youtube.com/watch?v=WFlIoNHD_Yo&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=42 | ✅ Done |
| 02      | JAVA DDD 02: BÁN VÉ TÀU TẾT với DDD Structure Project - Phần 02 | https://www.youtube.com/watch?v=hux9dtGQL7w&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=40&t=601s | ✅ Done |
| 03      | Project bán vé TÀU TẾT: API sập ngày đầu bán vé (CODE TEST) Review CODE với thấy có vấn đề SAI SÓT. | https://www.youtube.com/watch?v=EQ4WTurq5I0&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=39 | ✅ Done |
| 04      | JAVA DDD 3: Hoàn thành SETUP Dự án theo kiến trúc Microservice | https://www.youtube.com/watch?v=IcDiMkb7_TA&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=38 | ✅ Done |
| 05      | JAVA DDD 04: Circuit Breaker vs RateLimiter - Tuyến phòng thủ đầu tiên cho DDD (bán vé trực tuyến) | https://www.youtube.com/watch?v=tK7NDEr_vtE | ✅ Done |
| 06      | JAVA DDD Source Code ~ 1.000 QPS: DDD Project - Bán Vé Từ Video 0 - 4 - How to run() | https://www.youtube.com/watch?v=nXmppGlu4hw | ✅ Done |
| 07      | JAVA DDD 05: Distributed Cache - Tuyến phòng thủ thứ hai API (bán vé trực tuyến) - LUA vs Redisson | https://www.youtube.com/watch?v=GqCohsho54s | ⏳ Todo |
| 08      | SỐC: Distributed Cache Redis đã phản bội chúng tôi, 1 tỷ thất thoát ở ngày bán vé thứ hai | https://www.youtube.com/watch?v=1pGuG5S68zM&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=36 | ⏳ Todo |
| 09      | 👉👉👉: LINK DISCORD FOR MEMBER | https://www.youtube.com/watch?v=AsLW8Xt0UHs&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=35 | ✅ Done |
| 10      | JAVA DDD 06: Tâm sự DEV và vì sao tôi lại không sử dụng LUA Redis trong kịch bản Distributed Cache! | https://www.youtube.com/watch?v=zQWWGnhyZ0s&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=34 | ⏳ Todo |
| 11      | JAVA DDD 07: Setup hệ thống giám sát API Prometheus Service giúp DEV ngủ ngon | https://www.youtube.com/watch?v=MGQrPOrtKhE&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=33 | ⏳ Todo |
| 12      | JAVA DDD 08: Big Brother Graphana - System Monitoring - Helps DEV Sleep Well | https://www.youtube.com/watch?v=NSpHw9tUFjs&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=32 | ⏳ Todo |
| 13      | JAVA DDD 09: Giám sát MYSQL ONLINE qua hệ thống API | https://www.youtube.com/watch?v=jqspVKUye9M&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=31 | ⏳ Todo |
| 14      | JAVA DDD 10: Hệ thống giám sát Connects vs Performance Distributed Redis như thế nào? Chưa ngủ ngon | https://www.youtube.com/watch?v=5IuSc2NAM60&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=30 | ⏳ Todo |

---

## 📝 License

[MIT](./LICENSE)  
Feel free to use this code for learning purposes. Please credit the original series if you share or build on top of it.