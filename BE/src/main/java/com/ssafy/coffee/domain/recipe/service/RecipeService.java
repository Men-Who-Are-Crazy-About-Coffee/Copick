package com.ssafy.coffee.domain.recipe.service;

import com.ssafy.coffee.domain.recipe.dto.RecipeGetResponseDto;
import com.ssafy.coffee.domain.recipe.dto.RecipePostRequestDto;
import com.ssafy.coffee.domain.recipe.dto.RecipeUpdateRequestDto;
import com.ssafy.coffee.domain.recipe.repository.RecipeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RecipeService {
    public final RecipeRepository recipeRepository;

    public void addRecipe(RecipePostRequestDto recipePostRequestDto) {
    }

    public RecipeGetResponseDto getRecipe(Long recipeIndex) {
        return null;
    }

    public Page<RecipeGetResponseDto> getAllRecipes(Pageable pageable) {
        return null;
    }

    public void updateRecipe(Long recipeIndex, RecipeUpdateRequestDto recipeUpdateRequestDto) {
    }

    public void deleteRecipe(Long recipeIndex) {
    }
}
