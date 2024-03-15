package com.ssafy.coffee.global.util;

import com.ssafy.coffee.domain.bean.repository.BeanRepository;
import com.ssafy.coffee.domain.roasting.repository.RoastingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.GetMapping;

@Component
@RequiredArgsConstructor
public class DataUtil {
    private BeanRepository beanRepository;
    private RoastingRepository roastingRepository;
    public void initBean(){

    }
    public void initRoasting(){

    }
}
