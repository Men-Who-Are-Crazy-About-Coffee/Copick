package com.ssafy.coffee.domain.global.entity;

import jakarta.persistence.*;
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
    private int value;

}