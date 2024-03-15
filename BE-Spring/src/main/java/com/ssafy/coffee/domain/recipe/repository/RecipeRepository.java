package com.ssafy.coffee.domain.recipe.repository;

import com.ssafy.coffee.domain.recipe.entity.Recipe;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RecipeRepository extends JpaRepository<Recipe, Long> {

    Page<Recipe> findAllByTitleContaining(String keyword, Pageable pageable);

}
