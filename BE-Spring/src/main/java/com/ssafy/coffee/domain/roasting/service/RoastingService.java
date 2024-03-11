package com.ssafy.coffee.domain.roasting.service;

import com.ssafy.coffee.domain.roasting.dto.RoastingGetResponseDto;
import com.ssafy.coffee.domain.roasting.dto.RoastingPostRequestDto;
import com.ssafy.coffee.domain.roasting.dto.RoastingUpdateRequestDto;
import com.ssafy.coffee.domain.roasting.repository.RoastingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RoastingService {
    private final RoastingRepository roastingRepository;

    public void addRoasting(RoastingPostRequestDto roastingPostRequestDto) {

    }

    public RoastingGetResponseDto getRoasting(Long roastingIndex) {
        return null;
    }

    public List<RoastingGetResponseDto> getAllRoastings() {
        return null;
    }

    public void updateRoasting(Long roastingIndex, RoastingUpdateRequestDto roastingUpdateRequestDto) {

    }

    public void deleteRoasting(Long roastingIndex) {

    }

}
