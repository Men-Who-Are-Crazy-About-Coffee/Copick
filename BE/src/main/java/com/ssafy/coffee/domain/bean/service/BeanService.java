package com.ssafy.coffee.domain.bean.service;

import com.ssafy.coffee.domain.bean.dto.BeanGetResponseDto;
import com.ssafy.coffee.domain.bean.dto.BeanPostRequestDto;
import com.ssafy.coffee.domain.bean.dto.BeanUpdateRequestDto;
import com.ssafy.coffee.domain.bean.repository.BeanRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class BeanService {
    private final BeanRepository beanRepository;

    public void addBean(BeanPostRequestDto beanPostRequestDto) {

    }

    public BeanGetResponseDto getBean(Long beanId) {
        return null;
    }

    public void updateBean(Long beanId, BeanUpdateRequestDto beanUpdateRequestDto) {

    }

    public void deleteBean(Long beanId) {

    }
}
