package com.vetautet.ddd.controller.model.enums;

public enum ResultCode {

    SUCCESS(200, "Thành công"),
    PARAMS_ERROR(4002, "Tham số bất thường"),
    ERROR(400, "Máy chủ bận, vui lòng thử lại sau"),

    USER_SESSION_EXPIRED(20004, "Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại"),
    USER_PERMISSION_ERROR(20005, "Quyền hạn không đủ"),
    USER_NOT_FOUND(20002, "Người dùng không tồn tại hoặc tài khoản đã bị vô hiệu hóa"),

    PRODUCT_NOT_EXIST(11001, "Sản phẩm đã hết hàng"),
    PRODUCT_SKU_QUANTITY_NOT_ENOUGH(11011, "Số lượng kho không đủ"),

    RATE_LIMIT_ERROR(1003, "Truy cập quá thường xuyên, vui lòng thử lại sau"),
    ;

    private final Integer code;
    private final String message;

    ResultCode(Integer code, String message) {
        this.code = code;
        this.message = message;
    }

    public Integer code() {
        return this.code;
    }

    public String message() {
        return this.message;
    }
}