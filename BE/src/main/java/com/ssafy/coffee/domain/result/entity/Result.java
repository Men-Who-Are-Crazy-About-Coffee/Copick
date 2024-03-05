package com.ssafy.coffee.domain.result.entity;

import com.ssafy.coffee.domain.Bean.entity.Bean;
import com.ssafy.coffee.domain.member.entity.Member;
import com.ssafy.coffee.domain.roasting.entity.Roasting;
import com.ssafy.coffee.global.entity.BaseObject;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
public class Result extends BaseObject {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "result_index", nullable = false)
    private Long index;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_index", nullable = false)
    private Member member;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bean_index", nullable = false)
    private Bean bean;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "Rosting_index", nullable = false)
    private Roasting rosting;

    @Column(name = "result_normal", nullable = false)
    private int normalBeanCount;

    @Column(name = "result_flaw", nullable = false)
    private int flawBeanCount;

    // Constructors, Setters
}
