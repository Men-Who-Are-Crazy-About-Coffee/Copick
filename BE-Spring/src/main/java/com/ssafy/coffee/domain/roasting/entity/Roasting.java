package com.ssafy.coffee.domain.roasting.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@NoArgsConstructor
public class Roasting {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "roasting_index", nullable = false)
    private Long index;

    @Setter
    @Column(name = "roasting_type", nullable = false, length = 255)
    private String type;

    @Setter
    @Column(name = "roasting_content", nullable = false, length = 255)
    private String content;

    @Setter
    @Column(name = "roasting_image", nullable = false, length = 255)
    private String image;

    // Constructors
}
