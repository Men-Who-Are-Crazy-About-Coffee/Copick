package com.ssafy.coffee.domain.roasting.service;

import com.ssafy.coffee.domain.roasting.dto.RoastingGetResponseDto;
import com.ssafy.coffee.domain.roasting.dto.RoastingPostRequestDto;
import com.ssafy.coffee.domain.roasting.dto.RoastingUpdateRequestDto;
import com.ssafy.coffee.domain.roasting.entity.Roasting;
import com.ssafy.coffee.domain.roasting.repository.RoastingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RoastingService {
    private final RoastingRepository roastingRepository;

    public void addRoasting(RoastingPostRequestDto roastingPostRequestDto) {
        Roasting roasting = Roasting.builder()
                .type(roastingPostRequestDto.getType())
                .content(roastingPostRequestDto.getContent())
                .image(roastingPostRequestDto.getImage())
                .build();

        roastingRepository.save(roasting);
    }

    public RoastingGetResponseDto getRoasting(Long roastingIndex) {
        Roasting roasting = roastingRepository.findById(roastingIndex)
                .orElseThrow(() -> new IllegalArgumentException("Roasting with id " + roastingIndex + " not found"));

        return new RoastingGetResponseDto(roasting);
    }

    public List<RoastingGetResponseDto> getAllRoastings() {
        List<Roasting> roastings = roastingRepository.findAll();

        return roastings.stream()
                .map(RoastingGetResponseDto::new)
                .collect(Collectors.toList());
    }

    public void updateRoasting(Long roastingIndex, RoastingUpdateRequestDto roastingUpdateRequestDto) {
        Roasting roasting = roastingRepository.findById(roastingIndex)
                .orElseThrow(() -> new IllegalArgumentException("Roasting with id " + roastingIndex + " not found"));

        if (roastingUpdateRequestDto.getType() != null)
            roasting.setType(roastingUpdateRequestDto.getType());
        if (roastingUpdateRequestDto.getContent() != null)
            roasting.setContent(roastingUpdateRequestDto.getContent());
        if (roastingUpdateRequestDto.getImage() != null)
            roasting.setImage(roastingUpdateRequestDto.getImage());

        roastingRepository.save(roasting);
    }

    public void deleteRoasting(Long roastingIndex) {
        if (!roastingRepository.existsById(roastingIndex))
            throw new IllegalArgumentException("Roasting with id " + roastingIndex + " does not exist");

        roastingRepository.deleteById(roastingIndex);
    }
}
