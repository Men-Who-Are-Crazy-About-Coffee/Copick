package com.ssafy.coffee.domain.board.entity;

import com.ssafy.coffee.global.entity.AuditableBaseObject;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@NoArgsConstructor
public class Board extends AuditableBaseObject {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "board_index", nullable = false)
    private Long index;

    @Setter
    @Column(name = "board_title", nullable = false, length = 255)
    private String title;

    @Setter
    @Column(name = "board_content", nullable = false, length = 255)
    private String content;

    @Setter
    @Column(name = "board_domain", nullable = false, length = 255)
    private BoardDomain domain;

    // Setters and Constructer
}
