package com.ssafy.coffee.global.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
public class ResponseData<T> {
    private String responseMessage;
    private T data;

    public ResponseData(final String responseMessage) {
        this.responseMessage = responseMessage;
        this.data = null;
    }

    public static<T> ResponseData<T> res(final String responseMessage) {
        return res(responseMessage, null);
    }

    public static<T> ResponseData<T> res(final String responseMessage, final T data) {
        return ResponseData.<T>builder()
                .data(data)
                .responseMessage(responseMessage)
                .build();
    }
}
