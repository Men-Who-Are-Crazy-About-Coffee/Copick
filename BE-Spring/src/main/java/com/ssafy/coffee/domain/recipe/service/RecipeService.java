package com.ssafy.coffee.domain.recipe.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.ssafy.coffee.domain.bean.entity.Bean;
import com.ssafy.coffee.domain.bean.repository.BeanRepository;
import com.ssafy.coffee.domain.recipe.dto.RecipeGetListResponseDto;
import com.ssafy.coffee.domain.recipe.dto.RecipeGetResponseDto;
import com.ssafy.coffee.domain.recipe.dto.RecipePostRequestDto;
import com.ssafy.coffee.domain.recipe.dto.RecipeUpdateRequestDto;
import com.ssafy.coffee.domain.recipe.entity.Recipe;
import com.ssafy.coffee.domain.recipe.repository.RecipeRepository;
import com.ssafy.coffee.domain.roasting.entity.Roasting;
import com.ssafy.coffee.domain.roasting.repository.RoastingRepository;
import com.ssafy.coffee.domain.s3.service.S3Service;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RecipeService {
    private final RecipeRepository recipeRepository;

    private final BeanRepository beanRepository;
    private final RoastingRepository roastingRepository;

    private final S3Service s3Service;

    public void addRecipe(RecipePostRequestDto recipePostRequestDto) {


        Recipe recipe = recipeRepository.save(
                Recipe.builder()
                        .roasting(roastingRepository.findByIndex(recipePostRequestDto.getBeanIndex()))
                        .bean(beanRepository.findByIndex(recipePostRequestDto.getBeanIndex()))
                        .title(recipePostRequestDto.getTitle())
                        .content("")
                        .build()
        );

        String filePath = "recipe/" + recipe.getIndex();
        List<String> urls = s3Service.uploadMultipleFiles(filePath, recipePostRequestDto.getUpfiles());

        ObjectMapper mapper = new ObjectMapper();
        ArrayNode contentArray = mapper.createArrayNode();

        for (String url : urls) {
            ObjectNode imageNode = mapper.createObjectNode();
            imageNode.put("type", "image");
            imageNode.put("content", url);
            contentArray.add(imageNode);
        }

        ObjectNode textNode = mapper.createObjectNode();
        textNode.put("type", "content");
        textNode.put("content", recipePostRequestDto.getContent());
        contentArray.add(textNode);

        String jsonContent = null;
        try {
            jsonContent = mapper.writeValueAsString(contentArray);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
        recipe.setContent(jsonContent);
        recipeRepository.save(recipe);
    }

    public RecipeGetResponseDto getRecipe(Long recipeIndex) {
        Recipe recipe = recipeRepository.findById(recipeIndex)
                .orElseThrow(() -> new IllegalArgumentException("Recipe with id " + recipeIndex + " not found"));

        return new RecipeGetResponseDto(recipe);
    }

    public RecipeGetListResponseDto searchRecipes(String keyword, Pageable pageable) {
        Page<Recipe> recipes = recipeRepository.findAllByTitleContaining(keyword, pageable);
        List<RecipeGetResponseDto> content = recipes.getContent().stream()
                .map(RecipeGetResponseDto::new)
                .collect(Collectors.toList());

        return new RecipeGetListResponseDto(content, recipes.getTotalPages(), recipes.getTotalElements());
    }

    public void updateRecipe(Long recipeIndex, RecipeUpdateRequestDto recipeUpdateRequestDto) {
        Recipe recipe = recipeRepository.findById(recipeIndex)
                .orElseThrow(() -> new IllegalArgumentException("Recipe with id " + recipeIndex + " not found"));

        if (recipeUpdateRequestDto.getBeanIndex() != null) {
            Bean bean = beanRepository.findById(recipeUpdateRequestDto.getBeanIndex())
                    .orElseThrow(() -> new IllegalArgumentException("Bean with id " + recipeUpdateRequestDto.getBeanIndex() + " not found"));
            recipe.setBean(bean);
        }

        if (recipeUpdateRequestDto.getRoastingIndex() != null) {
            Roasting roasting = roastingRepository.findById(recipeUpdateRequestDto.getRoastingIndex())
                    .orElseThrow(() -> new IllegalArgumentException("Roasting with id " + recipeUpdateRequestDto.getRoastingIndex() + " not found"));
            recipe.setRoasting(roasting);
        }

        if (recipeUpdateRequestDto.getTitle() != null) {
            recipe.setTitle(recipeUpdateRequestDto.getTitle());
        }

        if (recipeUpdateRequestDto.getContent() != null) {
            recipe.setContent(recipeUpdateRequestDto.getContent());
        }

        recipeRepository.save(recipe);
    }


    public void deleteRecipe(Long recipeIndex) {
        if (!recipeRepository.existsById(recipeIndex))
            throw new IllegalArgumentException("Recipe with id " + recipeIndex + " does not exist");

        recipeRepository.deleteById(recipeIndex);
    }
    
    public List<Recipe> selectListByBeanOrRoasting(long beanIndex,long roastingIndex){
        return recipeRepository.findByBeanIndexOrRoastingIndex(beanIndex,roastingIndex);
    }
}
