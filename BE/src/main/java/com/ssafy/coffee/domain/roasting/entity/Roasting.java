package com.ssafy.coffee.domain.roasting.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
public class Roasting {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "roasting_index", nullable = false)
    private Long index;

    @Column(name = "roasting_type", nullable = false, length = 255)
    private String type;

    // Constructors, Setters
}
