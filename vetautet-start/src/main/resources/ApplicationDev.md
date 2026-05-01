server:
    port: 1122
    tomcat:
        threads:
            max: 200

spring:
    application:
        name: vetautet.com
    datasource:
        hikari:
            maximum-pool-size: 20
            minimum-idle: 5
        url: jdbc:mysql://localhost:3316/vetautet
        username: root
        password: root1234
        driver-class-name: com.mysql.cj.jdbc.Driver
        type: com.zaxxer.hikari.HikariDataSource
    jpa:
        database: mysql
        show-sql: true
        hibernate:
            ddl-auto: none
        properties:
            hibernate:
                format_sql: true
                use_sql_comments: true
    jackson:
        serialization:
            indent-output: true
    data:
        redis:
            host: 127.0.0.1
            port: 6319
            password: ""
            lettuce:
                pool:
                    max-active: 8
                    max-idle: 8
                    min-idle: 0
                    max-wait: -1ms
            connect-timeout: 30000

resilience4j:
    circuitbreaker:
        instances:
            checkRandom:
                registerHealthIndicator: true
                slidingWindowSize: 10
                permittedNumberOfCallsInHalfOpenState: 3
                minimumNumberOfCalls: 5
                waitDurationInOpenState: 5s
                failureRateThreshold: 50
                eventConsumerBufferSize: 10
    ratelimiter:
        instances:
            backendA:
                limitForPeriod: 2
                limitRefreshPeriod: 10s
                timeoutDuration: 0
                registerHealthIndicator: true
                eventConsumerBufferSize: 100
            backendB:
                limitForPeriod: 5
                limitRefreshPeriod: 10s
                timeoutDuration: 3s
springdoc:
    api-docs:
        path: /api-docs
    swagger-ui:
        path: /swagger-ui
        enabled: true

management:
    health:
        circuitbreakers:
            enabled: true
    endpoints:
        web:
            exposure:
                include:
                    - '*'
    endpoint:
        health:
            show-details: always
        prometheus:
            enabled: true