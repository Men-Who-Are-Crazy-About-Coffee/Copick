package com.ssafy.coffee.domain.comment.entity;

import com.ssafy.coffee.domain.board.entity.Board;
import com.ssafy.coffee.global.entity.AuditableBaseObject;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@NoArgsConstructor
public class Comment extends AuditableBaseObject {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "comment_index", nullable = false)
    private Long index;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "board_index", nullable = false)
    private Board board;

    @Setter
    @Column(name = "board_content", nullable = false, length = 255)
    private String content;

    // Setters and Constructer
}
