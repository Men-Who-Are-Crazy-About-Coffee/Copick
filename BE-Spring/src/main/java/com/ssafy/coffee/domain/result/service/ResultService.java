package com.ssafy.coffee.domain.result.service;

import com.ssafy.coffee.domain.bean.repository.BeanRepository;
import com.ssafy.coffee.domain.global.entity.Global;
import com.ssafy.coffee.domain.global.repository.GlobalRepository;
import com.ssafy.coffee.domain.member.entity.Member;
import com.ssafy.coffee.domain.member.repository.MemberRepository;
import com.ssafy.coffee.domain.result.dto.AnalyzeResponseDto;
import com.ssafy.coffee.domain.result.entity.Result;
import com.ssafy.coffee.domain.result.entity.Sequence;
import com.ssafy.coffee.domain.result.repository.ResultRepository;
import com.ssafy.coffee.domain.result.repository.SequenceRepository;
import com.ssafy.coffee.domain.roasting.repository.RoastingRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.client.WebClient;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ResultService {
    private final ResultRepository resultRepository;
    private final MemberRepository memberRepository;
    private final RoastingRepository roastingRepository;
    private final BeanRepository beanRepository;
    private final SequenceRepository sequenceRepository;
    private final GlobalRepository globalRepository;

    @Value("${python.url}")
    private String pythonURL;

    @Transactional
    public Result insertEmptyResult(long memberIndex,Long beanIndex) {
        Member member = memberRepository.findByIndexAndIsDeletedFalse(memberIndex)
                .orElseThrow(() -> new EntityNotFoundException("Member not found with index: " + memberIndex));
        Result result = resultRepository.save(Result.builder()
                .roasting(roastingRepository.findById(1L).orElseThrow())
                .bean(beanRepository.findById(beanIndex).orElseThrow(()
                        -> new EntityNotFoundException("Bean not found with index: " + beanIndex)))
                .flawBeanCount(0)
                .normalBeanCount(0)
                .member(member)
                .build());
        return result;
    }

    @Transactional
    public Result updateEmptyResult(long resultIndex) {
        Result result = resultRepository.findByIndex(resultIndex)
                .orElseThrow(() -> new EntityNotFoundException("Result not found with index: " + resultIndex));
        List<Sequence> sequenceList = sequenceRepository.findAllByResultIndex(resultIndex);
        int resultFlawCnt = 0;
        int resultNormalCnt = 0;
        if (!sequenceList.isEmpty()) {
            for (Sequence s : sequenceList) {
                resultFlawCnt += s.getFlaw();
                resultNormalCnt += s.getNormal();
            }
//            result.setNormalBeanCount(sequenceList.get(sequenceList.size() - 1).getNormal());
            WebClient webClient = WebClient.builder().build();
            Long response = webClient.get()
                    .uri(pythonURL + "/api/python/roasting?image_link=" + sequenceList.get(sequenceList.size() - 1).getImage())
                    .retrieve().bodyToMono(Long.class).block();
            result.setRoasting(roastingRepository.findById(response).orElseThrow());
        }
        result.setFlawBeanCount(resultFlawCnt);
        result.setNormalBeanCount(resultNormalCnt);

        Global globalNormalBean = globalRepository.findById("global_normal_bean")
                .orElseThrow(() -> new EntityNotFoundException("Global not found with key: global_normal_bean"));
        globalNormalBean.setValue(globalNormalBean.getValue() + result.getNormalBeanCount());
        Global globalFlawBean = globalRepository.findById("global_flaw_bean")
                .orElseThrow(() -> new EntityNotFoundException("Global not found with key: global_flaw_bean"));
        globalFlawBean.setValue(globalNormalBean.getValue() + result.getFlawBeanCount());

        return result;
    }

    public AnalyzeResponseDto getResultByRegDate(long memberIndex, LocalDateTime startDate, LocalDateTime endDate) {
        Member accessMember = memberRepository.findByIndexAndIsDeletedFalse(memberIndex)
                .orElseThrow(() -> new EntityNotFoundException("Member not found with index: " + memberIndex));
        List<Result> resultList = resultRepository.findAllByCreatedByAndRegDateBetween(accessMember, startDate, endDate);
        if (resultList.isEmpty())
            throw new EntityNotFoundException("Result not found with date between " + startDate + "and" + endDate);
        double normalCount = 0;
        double flawCount = 0;
        double myNormalPercent = 0;
        for (Result result : resultList) {
            normalCount += result.getNormalBeanCount();
            flawCount += result.getFlawBeanCount();
        }
        if (normalCount + flawCount > 0)
            myNormalPercent = normalCount / (normalCount + flawCount);
        myNormalPercent = Math.round(myNormalPercent * 1000) / 10.0;

        double globalNormalBean = (double) globalRepository.findById("global_normal_bean")
                .orElseThrow(() -> new EntityNotFoundException("Global not found with key: global_normal_bean")).getValue();
        double globalFlawBean = (double) globalRepository.findById("global_flaw_bean")
                .orElseThrow(() -> new EntityNotFoundException("Global not found with key: global_normal_bean")).getValue();

        double totalNormalPercent = 0;
        if (globalNormalBean + globalFlawBean > 0)
            totalNormalPercent = globalNormalBean / (globalNormalBean + globalFlawBean);
        totalNormalPercent = Math.round(totalNormalPercent * 1000) / 10.0;

        return AnalyzeResponseDto.builder()
                .myNormalPercent(myNormalPercent)
                .myFlawPercent((1000 - myNormalPercent * 10) / 10.0)
                .totalNormalPercent(totalNormalPercent)
                .build();
    }
}
