package com.ssafy.coffee.domain.bean.entity;

import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@NoArgsConstructor
public class Bean {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "bean_index", nullable = false)
    private Long index;

    @Setter
    @Column(name = "bean_type", nullable = false, length = 255)
    private String type;

    @Setter
    @Column(name = "bean_content", nullable = false, length = 255)
    private String content;

    @Setter
    @Column(name = "bean_image", nullable = false, length = 255)
    private String image;

    @Builder
    public Bean(String type, String content, String image) {
        this.type = type;
        this.content = content;
        this.image = image;
    }
}
