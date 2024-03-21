package com.ssafy.coffee.domain.board.entity;

import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
public class BoardImage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "image_id", nullable = false)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "board_index", nullable = false)
    private Board board;

    @Column(name = "image_path", nullable = false, length = 500)
    private String image;

    @Builder
    BoardImage(Board board, String image) {
        this.board = board;
        this.image = image;
    }

}
