package com.ssafy.coffee.domain.result.entity;

import com.ssafy.coffee.global.entity.BaseObject;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
public class Flaw extends BaseObject {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "flaw_index", nullable = false)
    private Long FlawIndex;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "result_index", nullable = false)
    private Result result;

    @Column(name = "flaw_image", nullable = false, length = 255)
    private String image;

    // Constructors, Setters
}
