package com.ssafy.coffee.domain.result.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
public class Sequence {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "sequence_index", nullable = false)
    private Long index;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "result_index", nullable = false)
    private Result result;

    @Column(name = "sequence_link", nullable = false, length = 255)
    private String link;

    @Column(name = "result_normal", nullable = false)
    private int normal = 0;

    @Column(name = "result_flaw", nullable = false)
    private int flaw = 0;

    // Constructors, Setters

}
