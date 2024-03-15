package com.ssafy.coffee.domain.result.controller;

import com.ssafy.coffee.domain.recipe.entity.Recipe;
import com.ssafy.coffee.domain.recipe.service.RecipeService;
import com.ssafy.coffee.domain.result.dto.ResultResponseDto;
import com.ssafy.coffee.domain.result.entity.Result;
import com.ssafy.coffee.domain.result.entity.Sequence;
import com.ssafy.coffee.domain.result.service.ResultService;
import com.ssafy.coffee.domain.result.service.SequenceService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
@Tag(name = "result", description = "분석 결과 API")
@RequestMapping("/api/result")
public class ResultController {
    private final ResultService resultService;
    private final SequenceService sequenceService;
    private final RecipeService recipeService;

    @GetMapping("/init/{memberIndex}")
    public ResponseEntity<Object> getNewResultIndex(@PathVariable long memberIndex){
        Result result = resultService.insertEmptyResult(memberIndex);
        return ResponseEntity.status(HttpStatus.OK).body(result.getIndex());
    }

    @GetMapping("/show/{resultIndex}")
    public ResponseEntity<ResultResponseDto> getResult(@PathVariable long resultIndex){
        Result result = resultService.updateEmptyResult(resultIndex);
        List<Sequence> sequenceList = sequenceService.selectSequenceByResultIndex(resultIndex);
        List<String> sequenceLinkList = sequenceList.stream().map(Sequence::getImage).toList();
        List<Recipe> recipeList = recipeService.selectListByBeanOrRoasting(result.getBean().getIndex(),result.getRoasting().getIndex());
        return ResponseEntity.status(HttpStatus.OK).body(ResultResponseDto.builder()
                .sequenceLink(sequenceLinkList)
                .resultNormal(result.getNormalBeanCount())
                .resultFlaw(result.getFlawBeanCount())
                .roastingType(result.getRoasting().getType())
                .beanType(result.getBean().getType())
                .recipeList(recipeList)
                .build());
    }
}
