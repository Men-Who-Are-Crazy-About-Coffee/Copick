package com.ssafy.coffee.domain.result.service;

import com.ssafy.coffee.domain.result.dto.FlawResponseDto;
import com.ssafy.coffee.domain.result.entity.Flaw;
import com.ssafy.coffee.domain.result.entity.Result;
import com.ssafy.coffee.domain.result.entity.Sequence;
import com.ssafy.coffee.domain.result.repository.FlawRepository;
import com.ssafy.coffee.domain.result.repository.ResultRepository;
import com.ssafy.coffee.domain.result.repository.SequenceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@Slf4j
@RequiredArgsConstructor
public class FlawService {
    private final ResultRepository resultRepository;
    private final FlawRepository flawRepository;
    public List<FlawResponseDto> getFlawListByMemberIndex(long memberIndex){
        List<Result> accessMemberResultList = resultRepository.findAllByCreatedByIndex(memberIndex);
        List<FlawResponseDto> flawList = new ArrayList<>();
        for(Result r: accessMemberResultList)
            for(Flaw f : flawRepository.findAllByResultIndex(r.getIndex()))
                flawList.add(FlawResponseDto.builder()
                        .flawIndex(f.getFlawIndex())
                        .regDate(f.getRegDate())
                        .image(f.getImage())
                        .build());
        return flawList;
    }
}