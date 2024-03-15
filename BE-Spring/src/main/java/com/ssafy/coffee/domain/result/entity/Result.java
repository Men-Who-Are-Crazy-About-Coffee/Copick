package com.ssafy.coffee.domain.result.entity;

import com.ssafy.coffee.domain.bean.entity.Bean;
import com.ssafy.coffee.domain.member.entity.Member;
import com.ssafy.coffee.domain.roasting.entity.Roasting;
import com.ssafy.coffee.global.entity.BaseObject;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

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

    @Setter
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bean_index", nullable = false)
    private Bean bean;

    @Setter
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "Rosting_index", nullable = false)
    private Roasting roasting;

    @Setter
    @Column(name = "result_normal")
    private int normalBeanCount;

    @Setter
    @Column(name = "result_flaw")
    private int flawBeanCount;

    @Builder
    public Result(Long index,Member member,Bean bean, Roasting roasting, int normalBeanCount,int flawBeanCount){
        this.index=index;
        this.member=member;
        this.bean=bean;
        this.roasting=roasting;
        this.normalBeanCount=normalBeanCount;
        this.flawBeanCount=flawBeanCount;
    }
}
