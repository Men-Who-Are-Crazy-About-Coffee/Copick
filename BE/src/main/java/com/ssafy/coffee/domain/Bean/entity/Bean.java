package com.ssafy.coffee.domain.Bean.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
public class Bean {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "bean_index", nullable = false)
    private Long index;

    @Column(name = "bean_type", nullable = false, length = 255)
    private String type;

    // Constructors and Setters
}
