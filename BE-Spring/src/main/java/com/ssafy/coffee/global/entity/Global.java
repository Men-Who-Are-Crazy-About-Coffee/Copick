package com.ssafy.coffee.global.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@NoArgsConstructor
public class Global {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "global_index", nullable = false)
    private Long index;

    @Column(name = "global_key")
    private int key;

    @Setter
    @Column(name = "global_value")
    private int value;
}
