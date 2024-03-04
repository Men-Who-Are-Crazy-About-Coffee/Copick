package com.ssafy.coffee.domain.member.entity;

import jakarta.persistence.*;

@Entity
public class Member{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "member_id", nullable = false)
    private Long memberId;

    @Column(name = "member_id", nullable = false)
    private Long Id;

}
