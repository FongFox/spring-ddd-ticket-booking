package com.vetautet.ddd.infrastructure.cache.redis;

import java.util.concurrent.TimeUnit;

public interface RedisInfrasService {

    void setString(String key, String value);
    String getString(String key);

    void setObject(String key, Object value);
    void setObject(String key, Object value, long timeout, TimeUnit unit);
    <T> T getObject(String key, Class<T> targetClass);
}