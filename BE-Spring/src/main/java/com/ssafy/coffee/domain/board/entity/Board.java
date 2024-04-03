package com.ssafy.coffee.domain.board.entity;

import com.ssafy.coffee.domain.member.entity.Member;
import com.ssafy.coffee.global.entity.AuditableBaseObject;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.util.List;

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
    @Column(name = "board_content", nullable = false, length = 4095)
    private String content;

    @Setter
    @Enumerated(EnumType.STRING)
    @Column(name = "board_domain", nullable = false, length = 255)
    private BoardDomain domain;

    @Builder
    public Board(Long index,String title, String content, BoardDomain domain, Member createdBy) {
        this.index = index;
        this.title = title;
        this.content = content;
        this.domain = domain;
        this.setCreatedBy(createdBy);
    }
}
