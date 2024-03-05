package com.ssafy.coffee.domain.member.entity;

import com.ssafy.coffee.global.entity.BaseObject;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@NoArgsConstructor
public class Member extends BaseObject {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "member_index", nullable = false)
    private Long index;

    @Column(name = "member_id", nullable = false, unique = true, length = 255)
    private String id;

    @Column(name = "member_password", nullable = false, length = 255)
    private String password;

    @Setter
    @Column(name = "member_nickname", nullable = false, length = 255)
    private String nickname;

    @Setter
    @Column(name = "member_profile_image", length = 255)
    private String profileImage;

    // Constructors, Setters
}
