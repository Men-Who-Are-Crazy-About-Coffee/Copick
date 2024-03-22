package com.ssafy.coffee.domain.global.entity;

import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@NoArgsConstructor
public class Global {

    @Id
    @Column(name = "global_key", nullable = false)
    private String key;

    @Setter
    @Column(name = "global_value", nullable = false)
    private Long value;

    @Builder
    public Global(String key, Long value) {
        this.key = key;
        this.value = value;
    }
}