# 🚂 java-ddd-vetautet

> High-concurrency ticket booking system built with Java 21 + Spring Boot + Domain-Driven Design (DDD).  
> A follow-along project based on the series by [tipjs/anonystick](https://anonystick.com).

---

## ⏸️ Paused At — Resume Guide

> **Last completed:** ep11 (Guava L1 cache + virtual threads) + ep12 (extreme benchmark tuning)  
> **Next episode:** [ep13 — ELK Logs for distributed system](https://www.youtube.com/watch?v=6DGnzYkK0uQ&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=27)

### What was done in the last session (ep11–12)

| What | Detail |
|---|---|
| Guava L1 cache | Added in `TicketDetailCacheService` — local in-memory cache before hitting Redis |
| 2-level cache flow | `Guava (L1) → Redis (L2) → Redisson lock → MySQL` |
| Virtual threads | `spring.threads.virtual.enabled: true` in `application.yml` |
| Extreme benchmark | New `extreme` mode: 2000 VUs × 2m with staged ramp-up in `run-benchmark.ps1` / `.sh` |
| Tomcat tuning | `server.tomcat.accept-count: 2000` to prevent connection refused under high load |

### Root cause investigated (ep12 debug)

- k6 extreme mode (2000 VUs, no ramp-up) was causing **"connection refused"**
- Diagnosed via `netstat`: `ESTABLISHED` dropped from 4002 → 2 for ~15 seconds, then recovered
- Root cause: `server.tomcat.accept-count` defaulted to **100** — OS rejected connections beyond the queue
- Fix: increased to `2000` + added staged ramp-up in k6 script

### To resume from here

```powershell
# 1. Start Docker services
docker-compose -f environment/docker-compose-dev.yml up -d

# 2. Build
.\mvnw.cmd clean install -DskipTests

# 3. Run app
.\mvnw.cmd spring-boot:run -pl vetautet-start

# 4. Verify monitoring stack
# Prometheus : http://localhost:9090
# Grafana    : http://localhost:3000  (admin / admin)
# App        : http://localhost:1122/swagger-ui.html

# 5. Continue: ep13 — ELK Logs
# https://www.youtube.com/watch?v=6DGnzYkK0uQ
```

---

## 📖 About

This project simulates a real-world **Tết train ticket booking system** (`vetautet.com`) — one of the highest-concurrency scenarios in Vietnam's e-commerce space, where thousands of users compete for a limited number of tickets at the same time.

The goal is to practice building a **scalable, resilient backend** using clean architecture principles and modern Java ecosystem tooling.

---

## 🏗️ Architecture

The application follows **Domain-Driven Design (DDD)** and is split into 5 Maven modules:

```
spring-ddd-ticket-booking/
├── vetautet-start/          # Entry point, Spring Boot main, application.yml
├── vetautet-controller/     # REST controllers (@RestController)
├── vetautet-application/    # Application services, 2-level cache logic
├── vetautet-domain/         # Domain models, repository interfaces, domain services
├── vetautet-infrastructure/ # JPA, Redis, Redisson, DB implementations
├── environment/             # Docker Compose (MySQL, Redis, Prometheus, Grafana, exporters)
├── benchmark/               # k6 test results
├── knowledge-summary/       # Study notes, diagrams, screenshots per section
├── run-benchmark.ps1        # Load test runner (Windows)
└── run-benchmark.sh         # Load test runner (Linux/macOS)
```

### Cache Architecture (2-level)

```
Request
  │
  ▼
Guava (L1) ──hit──▶ return immediately (in-memory, ~0ms)
  │ miss
  ▼
Redis (L2) ──hit──▶ populate L1 → return (~1ms)
  │ miss
  ▼
Redisson distributed lock
  │ locked
  ▼
MySQL ──▶ populate L2 + L1 → return
```

- **L1 (Guava):** `expireAfterAccess(10, MINUTES)`, `concurrencyLevel` = number of CPU cores
- **L2 (Redis):** `TTL = 1 day`, protected by Redisson distributed lock to prevent cache stampede

---

## ⚙️ Tech Stack

| Layer | Technology |
|---|---|
| Language | Java 21 |
| Framework | Spring Boot 3.5 |
| Architecture | Domain-Driven Design (DDD), Maven multi-module |
| Local Cache (L1) | Guava Cache |
| Distributed Cache (L2) | Redis (Redisson client) |
| Distributed Lock | Redisson |
| Database | MySQL 8.0 |
| Concurrency | Virtual Threads (`spring.threads.virtual.enabled=true`) |
| Resilience | Resilience4j (CircuitBreaker + RateLimiter) |
| Monitoring | Prometheus + Grafana |
| Exporters | mysqld-exporter, node-exporter, redis-exporter |
| API Docs | springdoc-openapi (Swagger UI) |
| Load Testing | k6 |
| CI/CD | GitHub Actions |

---

## 🐳 Infrastructure Services

Start all services:

```powershell
docker-compose -f environment/docker-compose-dev.yml up -d
```

| Service | Container | Port | URL |
|---|---|---|---|
| MySQL 8.0 | `pre-event-mysql` | `3316` | — |
| Redis | `pre-event-redis` | `6319` | — |
| Prometheus | `pre-event-prometheus` | `9090` | http://localhost:9090 |
| Grafana | `pre-event-grafana` | `3000` | http://localhost:3000 (admin/admin) |
| node-exporter | `pre-event-node-exporter` | `9100` | — |
| mysqld-exporter | `pre-event-mysqld-exporter` | `9104` | — |
| redis-exporter | `pre-event-redis-exporter` | `9121` | — |
| Spring Boot App | — | `1122` | http://localhost:1122 |

### Grafana Dashboards

| Dashboard | ID |
|---|---|
| JVM (Micrometer) | `4701` |
| MySQL Overview | via mysqld-exporter |
| Redis Overview | via redis-exporter |

---

## 🔑 Key Features

- **2-Level Cache** — Guava (L1 local) + Redis (L2 distributed) to reduce DB load and latency
- **Virtual Threads** — Java 21 virtual threads for higher concurrency with lower resource usage
- **Distributed Lock** — Redisson prevents cache stampede on cache miss under high concurrency
- **Rate Limiter** — Resilience4j controls request rate to protect the system on sale day
- **Circuit Breaker** — Resilience4j prevents cascading failures when downstream services degrade
- **Monitoring Stack** — Prometheus scrapes metrics; Grafana visualizes JVM, MySQL, Redis health
- **DDD Structure** — clean separation of domain logic from infrastructure concerns

---

## 🧪 Load Testing with k6

### Prerequisites

- [k6](https://k6.io/docs/get-started/installation/) installed

### Run (Windows PowerShell)

```powershell
# Smoke test — 50 VUs x 5s
.\run-benchmark.ps1

# Standard benchmark — 50 VUs x 30s
.\run-benchmark.ps1 -Mode normal

# Stress test — 200 VUs x 30s
.\run-benchmark.ps1 -Mode heavy

# Extreme test — 2000 VUs x 2m (staged ramp-up)
.\run-benchmark.ps1 -Mode extreme

# Against prod
.\run-benchmark.ps1 -Target prod -Mode normal
```

### Run (Linux / macOS)

```bash
chmod +x run-benchmark.sh

./run-benchmark.sh              # normal (default)
./run-benchmark.sh heavy        # stress
./run-benchmark.sh extreme      # 2000 VUs
./run-benchmark.sh normal prod  # prod target
```

### Extreme mode — staged ramp-up

```
0s ──── 30s: ramp up   0 → 2000 VUs
30s ─── 90s: sustain   2000 VUs
90s ── 120s: ramp down 2000 → 0 VUs
```

> Staged ramp-up prevents OS-level "connection refused" caused by 2000 connections hitting the server simultaneously.  
> Tomcat `accept-count` is also tuned to `2000` (default was `100`).

### Key metrics to watch

| Metric | Good | Investigate |
|---|---|---|
| `http_req_failed` | 0% | > 1% |
| `p(95) latency` | < 200ms | > 1s |
| `http_reqs/s` | stable / increasing | dropping |

### Benchmark results (local, Windows 11)

| Mode | VUs | Duration | Throughput | p(95) | Error rate | Notes |
|---|---|---|---|---|---|---|
| normal (cold) | 50 | 5s | ~2,600/s | 30ms | 0% | — |
| normal (warm) | 50 | 5s | ~2,879/s | 22ms | 0% | cache warmed |
| heavy | 200 | 30s | ~2,694/s | 123ms | 0.72% | bottleneck visible |
| extreme | 2000 | 2m | ~2,823/s | 2.46s | 1.17% | before ramp-up fix |

---

## 🚀 Getting Started

### Prerequisites

- Java 21+
- Docker & Docker Compose
- `mvnw.cmd` wrapper included (no global Maven needed)

### Run locally

```powershell
# Clone
git clone https://github.com/FongFox/spring-ddd-ticket-booking.git
cd spring-ddd-ticket-booking

# Start dependencies
docker-compose -f environment/docker-compose-dev.yml up -d

# Build all modules (install, not package — needed for cross-module JARs)
.\mvnw.cmd clean install -DskipTests

# Run
.\mvnw.cmd spring-boot:run -pl vetautet-start
```

### Verify

```
App        : http://localhost:1122/swagger-ui.html
Prometheus : http://localhost:9090
Grafana    : http://localhost:3000
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

- **Note:** ✅ Done · ⏳ Todo

| Section | Topic | Link | Status |
|---------|-------|------|--------|
| 01 | JAVA DDD 01: Xây dựng dự án DDD bán vé tàu, kiến trúc đồng thời cao | [▶](https://www.youtube.com/watch?v=WFlIoNHD_Yo&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=42) | ✅ Done |
| 02 | JAVA DDD 02: DDD Structure Project | [▶](https://www.youtube.com/watch?v=hux9dtGQL7w&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=40) | ✅ Done |
| 03 | Project bán vé tàu: API sập ngày đầu bán vé, review code | [▶](https://www.youtube.com/watch?v=EQ4WTurq5I0&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=39) | ✅ Done |
| 04 | JAVA DDD 3: Hoàn thành setup Microservice | [▶](https://www.youtube.com/watch?v=IcDiMkb7_TA&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=38) | ✅ Done |
| 05 | JAVA DDD 04: Circuit Breaker vs RateLimiter | [▶](https://www.youtube.com/watch?v=tK7NDEr_vtE) | ✅ Done |
| 06 | Source Code ~1,000 QPS: Section 0–4 How to run | [▶](https://www.youtube.com/watch?v=nXmppGlu4hw) | ✅ Done |
| 07 | JAVA DDD 05: Distributed Cache — LUA vs Redisson | [▶](https://www.youtube.com/watch?v=GqCohsho54s) | ✅ Done |
| 08 | Distributed Cache Redis phản bội — 1 tỷ thất thoát | [▶](https://www.youtube.com/watch?v=1pGuG5S68zM&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=36) | ✅ Done |
| 10 | JAVA DDD 06: Vì sao không dùng LUA Redis | [▶](https://www.youtube.com/watch?v=zQWWGnhyZ0s&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=34) | ✅ Done |
| 11 | JAVA DDD 07: Setup Prometheus monitoring | [▶](https://www.youtube.com/watch?v=MGQrPOrtKhE&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=33) | ✅ Done |
| 12 | JAVA DDD 08: Grafana — System Monitoring | [▶](https://www.youtube.com/watch?v=NSpHw9tUFjs&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=32) | ✅ Done |
| 13 | JAVA DDD 09: Giám sát MySQL online | [▶](https://www.youtube.com/watch?v=jqspVKUye9M&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=31) | ✅ Done |
| 14 | JAVA DDD 10: Giám sát Redis distributed | [▶](https://www.youtube.com/watch?v=5IuSc2NAM60&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=30) | ✅ Done |
| 15 | Source Code ~5,000 QPS: Section 4–10 How to run | [▶](https://www.youtube.com/watch?v=zoZu10avosY&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=29) | ✅ Done |
| 16 | JAVA DDD 11: Vũ khí tăng tốc 20,000 req/s — 5 tiêu chí | [▶](https://www.youtube.com/watch?v=gv_XHpOigbk&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=28) | ✅ Done |
| 17 | JAVA DDD 12: 25,000 req/s — Guava L1 + virtual threads | [▶](https://www.youtube.com/watch?v=akl14joFf2A&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=27) | ✅ Done |
| 18 | JAVA DDD 13: ELK Logs for distributed system | [▶](https://www.youtube.com/watch?v=6DGnzYkK0uQ&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=27) | ⏳ Todo ← **resume here** |
| 19 | JAVA DDD 14: Consistency — tính nhất quán thực tế | [▶](https://www.youtube.com/watch?v=agIL52ZnQ0o&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=25) | ⏳ Todo |
| 20 | JAVA DDD 15: Nginx proxy + 2 server, StockAvailable không nhất quán | [▶](https://www.youtube.com/watch?v=S0jeMyqSrVE&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=24) | ⏳ Todo |
| 21 | JAVA DDD 16: DEV SA, dữ liệu phân tán nhất quán — cách đơn giản | [▶](https://www.youtube.com/watch?v=XKCKnwJ0F9Y&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=23) | ⏳ Todo |
| 24 | JAVA DDD 17: Triển khai mức nhất quán phù hợp (2) | [▶](https://www.youtube.com/watch?v=0w-DO4guvRU&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=21) | ⏳ Todo |
| 25 | Source Code ~15,000 QPS: Section 5–17 How to run | [▶](https://www.youtube.com/watch?v=_4KTlUvdXoM&list=PLw0w5s5b9NK5Trt3AIxCtpRHWR7nI0RyX&index=20) | ⏳ Todo |

---

## 📝 License

[MIT](./LICENSE)  
Feel free to use this code for learning purposes. Please credit the original series if you share or build on top of it.
