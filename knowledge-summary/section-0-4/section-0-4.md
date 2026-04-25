# Những concept quan trọng mình cần nắm bắt trong section 0 - 4

---

Đây là các concept quan trọng trong source, giải thích từ đơn giản đến phức tạp:

---

## 1. DDD Layered Architecture

Cái quan trọng nhất — toàn bộ project xoay quanh nguyên tắc này:

```
Controller  → nhận request, không biết gì về business
Application → điều phối, không có business rule
Domain      → chứa business rule, không biết DB/Redis/Kafka
Infrastructure → kết nối thế giới bên ngoài (DB, Redis...)
```

> **Tại sao?** Domain hoàn toàn độc lập — có thể test mà không cần DB, không cần Redis. Thay DB từ MySQL sang PostgreSQL chỉ sửa Infrastructure, không đụng Domain.

---

## 2. Cache-Aside Pattern

Nằm trong `TicketDetailCacheService.getTicketDefaultCacheNormal()`:

```
Request đến
    ↓
Check Redis → có? → trả về luôn (cache hit)
    ↓ không có
Query DB → lưu vào Redis → trả về (cache miss)
```

> **Vấn đề của Normal:** nếu DB không có data → không cache null → mỗi request đều query DB mãi → **Cache Penetration**.

---

## 3. Cache Stampede & Distributed Lock

Nằm trong `getTicketDefaultCacheVip()` — giải quyết vấn đề khi **1000 request cùng lúc miss cache**:

```
Không có cache
    ↓
1000 request cùng query DB → DB chết

→ Fix: chỉ 1 request được vào DB (dùng Redisson Lock)
→ 999 request còn lại chờ hoặc trả về null
→ Request thắng lock → query DB → set cache → unlock
→ 999 request sau đó hit cache
```

> **Quy tắc vàng trong code:** `finally { locker.unlock() }` — **dù có lỗi hay không cũng phải unlock**, nếu không lock sẽ bị treo mãi.

---

## 4. Rate Limiter

Nằm trong `HiController` — `@RateLimiter(name = "backendA")`:

```
Config: limitForPeriod=2, limitRefreshPeriod=10s
→ Chỉ cho phép 2 request mỗi 10 giây
→ Request thứ 3 → gọi fallbackHello() → "Too many request!"
```

> **Dùng để:** chống bot spam, bảo vệ hệ thống ngày mở bán vé.

---

## 5. Circuit Breaker

Nằm trong `@CircuitBreaker(name = "checkRandom")`:

```
Bình thường: gọi FakeStore API → trả kết quả
Lỗi nhiều (>50%): Circuit OPEN → không gọi nữa
→ Gọi fallbackCircuitBreaker() → "Service fakestore API Error!"
Sau 5s: thử lại (Half-Open state)
```

> **3 trạng thái:** CLOSED (bình thường) → OPEN (ngắt) → HALF-OPEN (thử lại).

---

## 6. Interface + Impl Pattern

Xuyên suốt toàn bộ project — mọi service đều có `IXxx` + `XxxImpl`:

```java
ITicketDetailAppService       ← interface (contract)
TicketDetailAppServiceImpl    ← implementation
```

> **Tại sao?** Dễ thay implementation mà không đụng code gọi vào. Dễ mock khi viết test. Đúng nguyên tắc **Dependency Inversion** trong SOLID.

---

## 7. Dependency Injection (@Autowired)

Spring tự tạo object và inject vào — không cần `new`:

```java
@Autowired
private ITicketDetailDomainService ticketDetailDomainService;
// Spring tự tìm class implement ITicketDetailDomainService và inject vào
```

> **Lợi ích:** code không bị coupled, dễ test, dễ swap implementation.

---

## Thứ tự nên nắm

```
1. DDD layers → hiểu tại sao code tổ chức vậy
2. Interface/Impl → hiểu pattern xuyên suốt
3. Cache-Aside → hiểu caching cơ bản
4. Distributed Lock → hiểu tại sao cần lock
5. Rate Limiter → hiểu traffic control
6. Circuit Breaker → hiểu fault tolerance
```

Concept nào muốn đào sâu hơn thì hỏi tiếp nhé! 👍

---

---

## 1. DDD layers → hiểu tại sao code tổ chức vậy, liệu đây là case study (dự án cá nhân) quá lớn, mà role này thường do vị trí kiến trúc phần mềm chịu trách nhiệm, BE dev học được gì trong đây ?

---

Câu hỏi hay! Đây là điểm nhiều người học DDD bị nhầm.

---

## BE dev học được gì từ DDD layers?

### 1. Hiểu "tại sao code lại ở đây"

Khi join team mới, thấy project DDD → biết ngay:
- Business rule → tìm trong `domain`
- Gọi API/DB → tìm trong `infrastructure`
- Luồng xử lý → tìm trong `application`

Không mất thời gian đọc code lung tung.

---

### 2. Biết mình đang viết code vào đúng chỗ

```java
// Junior hay làm sai: nhét query DB thẳng vào Controller
@GetMapping("/ticket")
public Ticket getTicket() {
    return jdbcTemplate.query("SELECT * FROM ticket..."); // ❌ sai chỗ
}

// Sau khi hiểu DDD: biết query thuộc Infrastructure
// Controller chỉ gọi Service, không biết DB tồn tại
```

---

### 3. Không phải chỉ architect mới cần

Architect **thiết kế** cấu trúc — nhưng BE dev **viết code hàng ngày** trong cấu trúc đó. Nếu không hiểu thì:
- Nhét code sai layer → technical debt
- Team review reject → mất thời gian
- Bug khó trace vì không biết flow

---

### 4. DDD ở mức BE dev thực tế

Architect lo: bounded context, aggregate root, event storming...

BE dev lo:
```
✅ Biết viết code vào đúng layer
✅ Biết tại sao domain không import infrastructure
✅ Biết tại sao dùng interface thay vì class thẳng
✅ Biết flow request đi qua các layer như thế nào
```

---

### 5. Về câu "project cá nhân quá lớn"

Đúng — project thực tế 2-3 người không ai setup DDD đầy đủ vậy. Nhưng học ở đây để:

> Khi vào công ty lớn (Tiki, Shopee, VNG...) — họ dùng kiến trúc tương tự. Đọc code không bị lạ, onboard nhanh hơn người khác.

---

**Tóm lại:** Architect thiết kế nhà, BE dev xây nhà — nhưng thợ xây giỏi phải hiểu bản vẽ kiến trúc, không phải chỉ biết đặt gạch 🧱

---

---

## 2. Interface/Impl → hiểu pattern xuyên suốt

---

## Interface/Impl Pattern

### Bản chất đơn giản

Interface = **bản hợp đồng** — cam kết "tao sẽ làm được những việc này"
Impl = **người thực thi** hợp đồng đó

```java
// Hợp đồng: phải có method getTicketDetailById
public interface ITicketDetailDomainService {
    TicketDetail getTicketDetailById(Long ticketId);
}

// Người thực thi: làm đúng theo hợp đồng
@Service
public class TicketDetailDomainServiceImpl implements ITicketDetailDomainService {
    @Override
    public TicketDetail getTicketDetailById(Long ticketId) {
        return ticketDetailRepository.findById(ticketId).orElse(null);
    }
}
```

---

### Tại sao không viết thẳng vào class?

Hình dung thế này — bạn đang thuê shipper giao hàng:

```java
// Không dùng interface → gắn chặt với 1 shipper
GrabShipper shipper = new GrabShipper(); // ❌
shipper.deliver(order);

// Dùng interface → không quan tâm shipper nào
IShipper shipper = new GrabShipper(); // ✅
shipper.deliver(order);

// Muốn đổi sang Giao Hàng Nhanh → chỉ đổi 1 chỗ
IShipper shipper = new GHNShipper(); // ✅ code gọi không đổi gì
```

---

### Lợi ích thực tế trong project

**Swap implementation dễ dàng:**
```java
// Hiện tại đang dùng MySQL
public class TicketDetailInfrasRepositoryImpl implements ITicketDetailRepository {
    // query MySQL
}

// Mai muốn đổi sang MongoDB → tạo class mới, không đụng code cũ
public class TicketDetailMongoRepositoryImpl implements ITicketDetailRepository {
    // query MongoDB
}
```

**Dễ test (mock):**
```java
// Test không cần DB thật — mock interface là xong
ITicketDetailRepository mockRepo = Mockito.mock(ITicketDetailRepository.class);
when(mockRepo.findById(1L)).thenReturn(Optional.of(fakeTicket));
```

---

### Trong project này áp dụng xuyên suốt

```
IEventAppService          ← Application layer
ITicketDetailAppService   ← Application layer
ITicketDetailDomainService ← Domain layer
IHiDomainService          ← Domain layer
ITicketDetailRepository   ← Domain layer (interface)
RedisInfrasService        ← Infrastructure layer
RedisDistributedService   ← Infrastructure layer
RedisDistributedLocker    ← Infrastructure layer
```

---

### BE dev cần nhớ gì?

```
Khi viết service mới → luôn tạo interface trước, impl sau
Khi inject dependency → luôn inject interface, không inject class thẳng
```

```java
// ❌ Sai — inject thẳng class
@Autowired
private TicketDetailDomainServiceImpl service;

// ✅ Đúng — inject interface
@Autowired
private ITicketDetailDomainService service;
```

> Đây là nguyên tắc **D trong SOLID** — Dependency Inversion: depend on abstractions, not concretions. Hiểu cái này thì đọc bất kỳ codebase lớn nào cũng không bị lạ.

---

---

## 3. Cache-Aside → hiểu caching cơ bản

---

## Cache-Aside Pattern

### Bản chất

Ứng dụng **tự quản lý cache** — không có gì tự động cả. Code phải tự check, tự set, tự xử lý.

---

### Flow cơ bản

```
Request đến
    ↓
Check Redis → có? → trả về luôn ✅ (cache hit ~5ms)
    ↓ không có
Query DB (~50-100ms)
    ↓
Lưu vào Redis
    ↓
Trả về kết quả
```

Trong code `getTicketDefaultCacheNormal()`:

```java
// 1. Check cache trước
TicketDetail ticketDetail = redisInfrasService.getObject(genEventItemKey(id), TicketDetail.class);

// 2. Hit cache → trả về luôn
if (ticketDetail != null) {
    log.info("FROM CACHE");
    return ticketDetail;
}

// 3. Miss cache → query DB
ticketDetail = ticketDetailDomainService.getTicketDetailById(id);

// 4. Lưu vào cache
if (ticketDetail != null) {
    redisInfrasService.setObject(genEventItemKey(id), ticketDetail);
}
return ticketDetail;
```

---

### 3 vấn đề caching kinh điển cần biết

---

**Cache Miss (bình thường)** — data chưa có trong cache → query DB → set cache. Chấp nhận được.

---

**Cache Penetration** — request hỏi data **không tồn tại** trong cả cache lẫn DB:

```
Hacker gửi 1000 req với id=-1, id=-2...
→ Cache không có → query DB
→ DB không có → không set cache
→ Lần sau vẫn query DB tiếp
→ DB chết
```

Fix: **cache cả null**
```java
// Code hiện tại đang bị lỗi này
if (ticketDetail != null) { // ← chỉ cache khi có data
    redisInfrasService.setObject(key, ticketDetail);
}

// Fix đúng: cache null luôn
redisInfrasService.setObject(key, ticketDetail); // dù null vẫn cache
```

Tipjs đã comment trong code `// Code nay co van de` — đây là lỗi cố ý để học 😄

---

**Cache Stampede** — **1000 request cùng lúc miss cache**:

```
Cache hết hạn lúc 0h (giờ mở bán vé)
→ 1000 request cùng lúc miss
→ 1000 request cùng query DB
→ DB chết

→ Fix: Distributed Lock (getTicketDefaultCacheVip)
→ Chỉ 1 request query DB, 999 còn lại chờ
```

---

### Tại sao gọi là "Cache-Aside"?

Vì cache nằm **bên cạnh** (aside) DB — không phải nằm giữa. Ứng dụng tự quyết định đọc/ghi cache, không phải DB tự đẩy vào cache.

```
App ←→ Cache (Redis)
App ←→ DB (MySQL)
```

Khác với **Read-Through** (cache tự query DB khi miss) hay **Write-Through** (ghi vào cache, cache tự ghi DB).

---

### BE dev cần nhớ gì?

```
Cache-Aside = tự check + tự set + tự xử lý
3 vấn đề kinh điển:
  - Cache Penetration → cache null
  - Cache Stampede    → distributed lock
  - Cache miss        → bình thường, chấp nhận được
Key naming quan trọng:
  "PRO_TICKET:ITEM:1" → dễ debug, dễ xóa theo pattern
```

> Trong thực tế phỏng vấn senior BE, hỏi về caching gần như 100% sẽ hỏi 3 vấn đề này. Nắm được là ăn điểm ngay 👍

---

---

## 4. Distributed Lock → hiểu tại sao cần lock

---

## Distributed Lock

### Vấn đề cần giải quyết trước

Hình dung **1 server, 1000 request cùng lúc** vào mua vé:

```
Còn 1 vé cuối cùng
Thread 1: check → còn vé → đang xử lý...
Thread 2: check → còn vé → đang xử lý...
Thread 3: check → còn vé → đang xử lý...
→ 3 người cùng mua được 1 vé → oversell 💀
```

Lock thông thường (`synchronized` trong Java) fix được vấn đề này — nhưng chỉ trong **1 server**.

---

### Tại sao cần Distributed Lock?

Thực tế production chạy **nhiều server (cluster)**:

```
Server 1 ←─┐
Server 2 ←─┼─── Load Balancer ←── 1000 users
Server 3 ←─┘

synchronized chỉ lock trong 1 JVM
→ Server 1 lock xong
→ Server 2 không biết → vẫn chạy tiếp
→ Vẫn bị oversell 💀
```

Cần 1 nơi **trung tâm** mà tất cả server đều phải hỏi trước khi làm — đó là **Redis + Redisson**.

---

### Cách Redisson hoạt động

```
Server 1 muốn làm gì đó:
    → Hỏi Redis: "Cho tao lock key PRO_LOCK_KEY_ITEM_1"
    → Redis: "OK, tao ghi nhận mày đang giữ lock"
    → Server 1 làm việc...

Server 2 cũng muốn làm việc đó:
    → Hỏi Redis: "Cho tao lock key PRO_LOCK_KEY_ITEM_1"
    → Redis: "Không được, Server 1 đang giữ rồi"
    → Server 2: chờ hoặc trả về luôn

Server 1 xong việc:
    → Unlock → Redis xóa lock
    → Server 2 được phép vào
```

---

### Code trong project

```java
// Tạo lock với key theo itemId
RedisDistributedLocker locker = redisDistributedService
    .getDistributedLock("PRO_LOCK_KEY_ITEM" + id);

try {
    // Thử lấy lock — chờ tối đa 1 giây, giữ lock tối đa 5 giây
    boolean isLock = locker.tryLock(1, 5, TimeUnit.SECONDS);

    if (!isLock) {
        return null; // Không lấy được lock → trả về luôn
    }

    // Double-check cache sau khi có lock
    // (request trước có thể đã set cache rồi)
    ticketDetail = redisInfrasService.getObject(key, TicketDetail.class);
    if (ticketDetail != null) {
        return ticketDetail; // Có cache rồi → không cần query DB
    }

    // Chắc chắn chỉ 1 request vào đây
    ticketDetail = ticketDetailDomainService.getTicketDetailById(id);
    redisInfrasService.setObject(key, ticketDetail);
    return ticketDetail;

} finally {
    locker.unlock(); // BẮT BUỘC — dù lỗi hay không
}
```

---

### Double-check là gì?

Sau khi lấy được lock, vẫn phải check cache lần 2:

```
1000 request miss cache cùng lúc
→ Request A lấy được lock → query DB → set cache → unlock
→ Request B lấy được lock (sau A)
→ Nếu không double-check → query DB lại → thừa
→ Double-check → thấy cache có rồi → return luôn ✅
```

---

### Quy tắc vàng — `finally`

```java
// Tipjs nhắc 3 lần trong code không phải ngẫu nhiên
// Lưu ý: Cho dù thành công hay không cũng phải unLock, bằng mọi giá.
// Lưu ý: Cho dù thành công hay không cũng phải unLock, bằng mọi giá.
// Lưu ý: Cho dù thành công hay không cũng phải unLock, bằng mọi giá.
finally {
    locker.unlock();
}
```

Nếu không unlock:
```
Request A giữ lock → code bị exception → không unlock
→ Lock treo 5 giây (leaseTime)
→ 999 request còn lại chờ 5 giây
→ Timeout → user thấy lỗi
→ Hệ thống tê liệt
```

---

### tryLock(1, 5, TimeUnit.SECONDS) là gì?

```
tryLock(waitTime=1, leaseTime=5, unit=SECONDS)

waitTime=1   → chờ tối đa 1 giây để lấy lock
              (nếu 1 giây không lấy được → bỏ cuộc)

leaseTime=5  → giữ lock tối đa 5 giây
              (dù code chưa unlock, Redis tự xóa sau 5 giây)
              → tránh lock bị treo mãi mãi nếu server crash
```

---

### BE dev cần nhớ gì?

```
Distributed Lock dùng khi:
  - Nhiều server cùng xử lý 1 resource
  - Không muốn race condition (oversell, duplicate...)

3 điều bắt buộc:
  1. Luôn unlock trong finally
  2. Luôn set leaseTime (tránh lock treo mãi)
  3. Luôn double-check sau khi có lock

Key đặt theo resource cụ thể:
  "PRO_LOCK_KEY_ITEM_1"  → lock cho item 1
  "PRO_LOCK_KEY_ITEM_2"  → lock cho item 2
  (khác item → khác lock → không block nhau)
```

> Đây là concept **cực kỳ hay gặp trong phỏng vấn** — "làm sao tránh oversell khi flash sale?" Trả lời được Distributed Lock + Double-check là senior level rồi 👍

---

---

## 5. Rate Limiter → hiểu traffic control

---

## Rate Limiter

### Bản chất

Đặt **giới hạn số request** được phép vào hệ thống trong một khoảng thời gian nhất định.

---

### Tại sao cần?

Hình dung ngày mở bán vé tàu Tết:

```
0h00 mở bán
→ 1 triệu người cùng bấm F5
→ 1 triệu request/giây đổ vào server
→ Server không chịu được → sập
→ Không ai mua được vé
```

Rate Limiter giống **bảo vệ đứng cửa** — chỉ cho một số người nhất định vào mỗi lúc.

---

### Config trong project

```yaml
resilience4j:
  ratelimiter:
    instances:
      backendA:
        limitForPeriod: 2      # chỉ cho 2 request
        limitRefreshPeriod: 10s # mỗi 10 giây
        timeoutDuration: 0     # không chờ, từ chối ngay

      backendB:
        limitForPeriod: 5      # chỉ cho 5 request
        limitRefreshPeriod: 10s # mỗi 10 giây
        timeoutDuration: 3s    # chờ tối đa 3 giây
```

---

### Code trong project

```java
@GetMapping("hi")
@RateLimiter(name = "backendA", fallbackMethod = "fallbackHello")
public String getHello() {
    return eventAppService.sayHi("who???");
}

// Khi vượt limit → gọi method này thay vì báo lỗi
public String fallbackHello(Throwable throwable) {
    return "Too many request!\n";
}
```

---

### `timeoutDuration` — khác biệt quan trọng

```
timeoutDuration: 0   → từ chối ngay lập tức
                       user nhận "Too many request" ngay

timeoutDuration: 3s  → chờ tối đa 3 giây
                       nếu có slot trống trong 3s → cho vào
                       nếu 3s vẫn không có → từ chối
```

---

### 3 thuật toán Rate Limiter phổ biến

**Token Bucket** (Resilience4j đang dùng):
```
Có 1 cái xô chứa token
Mỗi 10s đổ đầy 2 token
Mỗi request tiêu 1 token
Hết token → từ chối
→ Cho phép burst ngắn
```

**Fixed Window:**
```
Đếm request trong cửa sổ cố định (0s-10s, 10s-20s...)
Vượt quá → từ chối
→ Vấn đề: cuối window 9s + đầu window 11s → burst gấp đôi
```

**Sliding Window:**
```
Cửa sổ trượt theo thời gian thực
Chính xác hơn Fixed Window
→ Không bị vấn đề burst ở ranh giới window
```

---

### Fallback — quan trọng không kém

Khi bị rate limit, có 3 cách xử lý:

```java
// Cách 1: Trả về message thân thiện (đang dùng)
public String fallbackHello(Throwable t) {
    return "Too many request!\n";
}

// Cách 2: Trả về cached data
public TicketDetail fallback(Throwable t) {
    return cachedTicketDetail; // data cũ nhưng vẫn có
}

// Cách 3: Redirect sang queue
public String fallback(Throwable t) {
    return "Hệ thống đang bận, bạn đang ở hàng chờ số 1234";
}
```

---

### Rate Limiter vs Circuit Breaker

Hay bị nhầm — khác nhau hoàn toàn:

| | Rate Limiter | Circuit Breaker |
|---|---|---|
| Bảo vệ | Server của **mình** | Service **bên ngoài** |
| Khi nào kích hoạt | Quá nhiều request đến | Service bên ngoài bị lỗi |
| Mục đích | Chống quá tải | Chống lỗi lan dây chuyền |

```
Rate Limiter: "Tao chỉ nhận 2 req/10s thôi, còn lại cút"
Circuit Breaker: "FakeStore API đang lỗi, tao không gọi nó nữa"
```

---

### BE dev cần nhớ gì?

```
Rate Limiter dùng khi:
  - API public có thể bị spam
  - Ngày flash sale cần kiểm soát traffic
  - Muốn fair cho tất cả user (không ai chiếm hết)

Luôn có fallback:
  - Không để user thấy lỗi 500
  - Trả về message rõ ràng hoặc cached data

Đặt limit hợp lý:
  - Quá thấp → user bình thường bị chặn
  - Quá cao → không bảo vệ được server
```

> Trong phỏng vấn hay hỏi: "Làm sao protect API khỏi DDoS hoặc bot spam?" — Rate Limiter là câu trả lời đầu tiên cần nói 👍

---

---

## 6. Circuit Breaker → hiểu fault tolerance

---

## Circuit Breaker

### Bản chất — lấy tên từ cầu dao điện

Cầu dao điện trong nhà: khi điện quá tải → **tự ngắt** để bảo vệ thiết bị.

Circuit Breaker trong code: khi service bên ngoài liên tục lỗi → **tự ngắt kết nối** để bảo vệ hệ thống.

---

### Vấn đề không có Circuit Breaker

```
Hệ thống gọi FakeStore API
FakeStore API bị chết
→ Mỗi request chờ timeout 30s
→ 1000 request đang chờ
→ 1000 thread bị block
→ Server hết thread
→ Hệ thống của mình cũng chết theo
```

> Đây gọi là **Cascading Failure** — lỗi dây chuyền. 1 service chết kéo theo cả hệ thống chết.

---

### 3 trạng thái Circuit Breaker

```
CLOSED (bình thường)
│   Request đến → gọi service → trả kết quả
│   Đếm số lần lỗi...
│   Lỗi > 50% trong 10 request
↓
OPEN (ngắt)
│   Không gọi service nữa
│   Trả về fallback ngay lập tức (~0ms)
│   Chờ 5 giây...
↓
HALF-OPEN (thử lại)
│   Cho 3 request thử qua
│   Thành công → về CLOSED
│   Thất bại → về OPEN tiếp
```

---

### Config trong project

```yaml
resilience4j:
  circuitbreaker:
    instances:
      checkRandom:
        slidingWindowSize: 10          # đếm trong 10 request gần nhất
        failureRateThreshold: 50       # lỗi > 50% → OPEN
        waitDurationInOpenState: 5s    # OPEN 5 giây rồi thử lại
        permittedNumberOfCallsInHalfOpenState: 3  # cho 3 request thử
        minimumNumberOfCalls: 5        # cần ít nhất 5 request mới tính
```

---

### Code trong project

```java
@GetMapping("circuit/breaker")
@CircuitBreaker(name = "checkRandom", fallbackMethod = "fallbackCircuitBreaker")
public String circuitBreaker() {
    // Gọi FakeStore API
    int productId = secureRandom.nextInt(20) + 1;
    String url = "https://fakestoreapi.com/products/" + productId;
    return restTemplate.getForObject(url, String.class);
}

// OPEN → không gọi API nữa → chạy thẳng vào đây
public String fallbackCircuitBreaker(Throwable throwable) {
    return "Service fakestore API Error!";
}
```

---

### Timeline thực tế

```
Request 1-4:   thành công → CLOSED
Request 5-9:   lỗi (tắt mạng)
Request 10:    lỗi → tính tỉ lệ: 5/10 = 50% → OPEN!

Request 11-∞:  không thèm gọi API
               → fallback ngay (~0ms)
               → "Service fakestore API Error!"

Sau 5 giây:    → HALF-OPEN
               → cho 3 request thử

Nếu 3 request OK: → CLOSED, bình thường lại
Nếu vẫn lỗi:     → OPEN tiếp 5 giây nữa
```

---

### Fallback nên làm gì?

```java
// ❌ Tệ — trả lỗi thô ra cho user
public String fallback(Throwable t) {
    throw new RuntimeException("Service died");
}

// ✅ Tốt — trả cached data
public TicketDetail fallback(Throwable t) {
    return redisInfrasService.getObject(cacheKey, TicketDetail.class);
}

// ✅ Tốt — trả default value
public String fallback(Throwable t) {
    return "Service tạm thời không khả dụng, vui lòng thử lại sau";
}

// ✅ Tốt — gọi service dự phòng
public String fallback(Throwable t) {
    return backupService.getData(); // fallback sang service khác
}
```

---

### Circuit Breaker vs Retry

Hay dùng kết hợp nhau:

```
Request đến
    ↓
Retry: thử lại 3 lần nếu lỗi tạm thời
    ↓ vẫn lỗi
Circuit Breaker: đếm lỗi
    ↓ vượt threshold
OPEN: không thử nữa → fallback luôn
```

```
Retry    → xử lý lỗi tạm thời (mạng chập chờn)
Circuit  → xử lý service chết hẳn
```

---

### Xem trạng thái Circuit Breaker qua Actuator

```bash
curl http://localhost:1122/actuator/health
```

```json
{
  "circuitBreakers": {
    "checkRandom": {
      "status": "CLOSED",
      "details": {
        "failureRate": "0.0%",
        "state": "CLOSED"
      }
    }
  }
}
```

---

### BE dev cần nhớ gì?

```
Circuit Breaker dùng khi:
  - Gọi service bên ngoài (API, microservice khác)
  - Không muốn lỗi 1 service làm chết cả hệ thống

3 trạng thái:
  CLOSED    → bình thường
  OPEN      → ngắt, fallback luôn
  HALF-OPEN → đang thử phục hồi

Fallback phải có ý nghĩa:
  - Cached data > default value > error message
  - Không bao giờ để user thấy stack trace

Kết hợp với Retry:
  - Retry xử lý lỗi nhỏ
  - Circuit Breaker xử lý service chết hẳn
```

---

### Tổng kết 6 concepts

```
DDD Layers          → tổ chức code đúng chỗ
Interface/Impl      → linh hoạt, dễ test, dễ swap
Cache-Aside         → tăng tốc, giảm tải DB
Distributed Lock    → tránh race condition nhiều server
Rate Limiter        → bảo vệ server khỏi quá tải
Circuit Breaker     → bảo vệ khỏi lỗi dây chuyền
```

> 6 concepts này cover hầu hết những gì một BE developer cần biết để làm việc trong hệ thống high-concurrency. Nắm được hết là đủ tự tin phỏng vấn senior level rồi 👍