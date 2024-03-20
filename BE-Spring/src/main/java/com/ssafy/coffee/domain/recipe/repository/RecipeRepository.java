package com.ssafy.coffee.domain.recipe.repository;

import com.ssafy.coffee.domain.recipe.entity.Recipe;
import io.lettuce.core.dynamic.annotation.Param;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RecipeRepository extends JpaRepository<Recipe, Long> {
    
    @Query("SELECT r FROM Recipe r WHERE r.bean.index = :beanIndex OR r.roasting.index = :roastingIndex")
    List<Recipe> findByBeanIndexOrRoastingIndex(@Param("beanIndex") Long beanIndex, @Param("roastingIndex") Long roastingIndex);

    Page<Recipe> findAllByTitleContaining(String keyword, Pageable pageable);

}
