package com.ssafy.coffee.domain.result.controller;

import com.amazonaws.Response;
import com.ssafy.coffee.domain.auth.dto.PrincipalMember;
import com.ssafy.coffee.domain.recipe.entity.Recipe;
import com.ssafy.coffee.domain.recipe.service.RecipeService;
import com.ssafy.coffee.domain.result.dto.AnalyzeRequestDto;
import com.ssafy.coffee.domain.result.dto.AnalyzeResponseDto;
import com.ssafy.coffee.domain.result.dto.ResultResponseDto;
import com.ssafy.coffee.domain.result.entity.Result;
import com.ssafy.coffee.domain.result.entity.Sequence;
import com.ssafy.coffee.domain.result.service.ResultService;
import com.ssafy.coffee.domain.result.service.SequenceService;
import com.ssafy.coffee.global.util.DataUtil;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

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
    private final DataUtil dataUtil;

    @GetMapping ("/setting")
    public ResponseEntity<Object> addBasicData(){
        dataUtil.initRoasting();
        dataUtil.initBean();
        return ResponseEntity.status(HttpStatus.OK).body("success");
    }

    @GetMapping("/init")
    public ResponseEntity<Object> getNewResultIndex(@AuthenticationPrincipal PrincipalMember principalMember){
        Result result = resultService.insertEmptyResult(principalMember.getIndex());
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

    @PostMapping("/analyze")
    public ResponseEntity<AnalyzeResponseDto> getStatistic(@AuthenticationPrincipal PrincipalMember principalMember,
                                                           @RequestBody AnalyzeRequestDto analyzeRequestDto){
        return ResponseEntity.status(HttpStatus.OK).body(
                resultService.getResultByRegDate(principalMember.getIndex()
                ,analyzeRequestDto.getStartDate().atStartOfDay()
                ,analyzeRequestDto.getEndDate().plusDays(1).atStartOfDay()));
    }
}
