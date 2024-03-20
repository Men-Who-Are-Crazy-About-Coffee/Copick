package com.ssafy.coffee.domain.bean.service;

import com.ssafy.coffee.domain.bean.dto.BeanGetResponseDto;
import com.ssafy.coffee.domain.bean.dto.BeanPostRequestDto;
import com.ssafy.coffee.domain.bean.dto.BeanUpdateRequestDto;
import com.ssafy.coffee.domain.bean.entity.Bean;
import com.ssafy.coffee.domain.bean.repository.BeanRepository;
import com.ssafy.coffee.domain.s3.service.S3Service;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BeanService {
    private final BeanRepository beanRepository;
    private final S3Service s3Service;

    public void addBean(BeanPostRequestDto beanPostRequestDto) {

        Bean savedBean = beanRepository.save(
                Bean.builder()
                        .image("")
                        .type(beanPostRequestDto.getType())
                        .content(beanPostRequestDto.getContent())
                        .build()
        );

        String filePath = "bean/" + savedBean.getIndex();
        String url = s3Service.uploadFile(filePath, beanPostRequestDto.getImage());

        savedBean.setImage(url);
        beanRepository.save(savedBean);
    }

    public BeanGetResponseDto getBean(Long beanIndex) {
        Bean bean = beanRepository.findById(beanIndex)
                .orElseThrow(() -> new IllegalArgumentException("Bean with id " + beanIndex + " not found"));

        return new BeanGetResponseDto(bean);
    }

    public List<BeanGetResponseDto> getAllBeans() {
        List<Bean> beans = beanRepository.findAll();

        return beans.stream()
                .map(BeanGetResponseDto::new)
                .collect(Collectors.toList());
    }

    public void updateBean(Long beanIndex, BeanUpdateRequestDto beanUpdateRequestDto) {
        Bean bean = beanRepository.findById(beanIndex)
                .orElseThrow(() -> new IllegalArgumentException("Bean with id " + beanIndex + " not found"));

        if (beanUpdateRequestDto.getType() != null)
            bean.setType(beanUpdateRequestDto.getType());
        if (beanUpdateRequestDto.getContent() != null)
            bean.setContent(beanUpdateRequestDto.getContent());
        if (beanUpdateRequestDto.getImage() != null) {
            String filePath = "bean/" + beanIndex;
            String url = s3Service.uploadFile(filePath, beanUpdateRequestDto.getImage());
            bean.setImage(url);
        }

        beanRepository.save(bean);
    }

    public void deleteBean(Long beanIndex) {
        if (!beanRepository.existsById(beanIndex))
            throw new IllegalArgumentException("Bean with id " + beanIndex + " does not exist");

        beanRepository.deleteById(beanIndex);
    }
}
