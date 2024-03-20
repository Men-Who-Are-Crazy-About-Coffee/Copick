package com.ssafy.coffee.domain.result.service;

import com.ssafy.coffee.domain.bean.repository.BeanRepository;
import com.ssafy.coffee.domain.member.entity.Member;
import com.ssafy.coffee.domain.member.repository.MemberRepository;
import com.ssafy.coffee.domain.result.entity.Result;
import com.ssafy.coffee.domain.result.entity.Sequence;
import com.ssafy.coffee.domain.result.repository.ResultRepository;
import com.ssafy.coffee.domain.result.repository.SequenceRepository;
import com.ssafy.coffee.domain.roasting.repository.RoastingRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SequenceService {
    private final SequenceRepository sequenceRepository;
    public List<Sequence> selectSequenceByResultIndex(long resultIndex){
        List<Sequence> sequenceList = sequenceRepository.findAllByResultIndex(resultIndex);
        return sequenceList;
    }
}
