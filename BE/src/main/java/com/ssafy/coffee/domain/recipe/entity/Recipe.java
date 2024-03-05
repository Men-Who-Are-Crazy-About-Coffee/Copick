package com.ssafy.coffee.domain.recipe.entity;

import com.ssafy.coffee.domain.Bean.entity.Bean;
import com.ssafy.coffee.domain.roasting.entity.Roasting;
import com.ssafy.coffee.global.entity.AuditableBaseObject;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@NoArgsConstructor
public class Recipe extends AuditableBaseObject {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "recipe_index", nullable = false)
    private Long recipeId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bean_index", nullable = false)
    private Bean bean;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "roasting_index", nullable = false)
    private Roasting roasting;

    @Setter
    @Column(name = "recipe_title", nullable = false, length = 255)
    private String title;

    @Setter
    @Column(name = "recipe_content", nullable = false, length = 255)
    private String content;

    // Constructors, Setters
}
