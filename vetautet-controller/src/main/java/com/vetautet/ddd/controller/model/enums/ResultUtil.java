package com.vetautet.ddd.controller.model.enums;

import com.vetautet.ddd.controller.model.vo.ResultMessage;

public class ResultUtil<T> {

    private final ResultMessage<T> responseMessage;
    private static final Integer SUCCESS_CODE = 200;

    public ResultUtil() {
        responseMessage = new ResultMessage<>();
        responseMessage.setSuccess(true);
        responseMessage.setMessage("success");
        responseMessage.setCode(SUCCESS_CODE);
    }

    public ResultMessage<T> setData(T t) {
        this.responseMessage.setResult(t);
        return this.responseMessage;
    }

    public ResultMessage<T> setSuccessMsg(ResultCode resultCode) {
        this.responseMessage.setSuccess(true);
        this.responseMessage.setMessage(resultCode.message());
        this.responseMessage.setCode(resultCode.code());
        return this.responseMessage;
    }

    public static <T> ResultMessage<T> data(T t) {
        return new ResultUtil<T>().setData(t);
    }

    public static <T> ResultMessage<T> success(ResultCode responseStatusCode) {
        return new ResultUtil<T>().setSuccessMsg(responseStatusCode);
    }

    public static <T> ResultMessage<T> success() {
        return new ResultUtil<T>().setSuccessMsg(ResultCode.SUCCESS);
    }

    public static <T> ResultMessage<T> error(ResultCode responseStatusCode) {
        return new ResultUtil<T>().setErrorMsg(responseStatusCode);
    }

    public static <T> ResultMessage<T> error(Integer code, String msg) {
        return new ResultUtil<T>().setErrorMsg(code, msg);
    }

    public ResultMessage<T> setErrorMsg(ResultCode resultCode) {
        this.responseMessage.setSuccess(false);
        this.responseMessage.setMessage(resultCode.message());
        this.responseMessage.setCode(resultCode.code());
        return this.responseMessage;
    }

    public ResultMessage<T> setErrorMsg(Integer code, String msg) {
        this.responseMessage.setSuccess(false);
        this.responseMessage.setMessage(msg);
        this.responseMessage.setCode(code);
        return this.responseMessage;
    }
}