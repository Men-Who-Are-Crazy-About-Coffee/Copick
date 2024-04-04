package com.ssafy.coffee.domain.roasting.service;

import com.ssafy.coffee.domain.roasting.dto.RoastingGetResponseDto;
import com.ssafy.coffee.domain.roasting.dto.RoastingPostRequestDto;
import com.ssafy.coffee.domain.roasting.dto.RoastingUpdateRequestDto;
import com.ssafy.coffee.domain.roasting.entity.Roasting;
import com.ssafy.coffee.domain.roasting.repository.RoastingRepository;
import com.ssafy.coffee.domain.s3.service.S3Service;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RoastingService {
    private final RoastingRepository roastingRepository;
    private final S3Service s3Service;

    public void addRoasting(RoastingPostRequestDto roastingPostRequestDto) {

        Roasting savedRoasting = roastingRepository.save(
                Roasting.builder()
                        .image("")
                        .type(roastingPostRequestDto.getType())
                        .content(roastingPostRequestDto.getContent())
                        .build()
        );

        String filePath = "roasting/" + savedRoasting.getIndex();
        String url = s3Service.uploadFile(filePath, roastingPostRequestDto.getImage());

        savedRoasting.setImage(url);
        roastingRepository.save(savedRoasting);
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
        if (roastingUpdateRequestDto.getImage() != null) {
            String filePath = "roasting/" + roastingIndex;
            String url = s3Service.uploadFile(filePath, roastingUpdateRequestDto.getImage());
            roasting.setImage(url);
        }

        roastingRepository.save(roasting);
    }

    public void deleteRoasting(Long roastingIndex) {
        if (!roastingRepository.existsById(roastingIndex))
            throw new IllegalArgumentException("Roasting with id " + roastingIndex + " does not exist");

        roastingRepository.deleteById(roastingIndex);
    }
}
