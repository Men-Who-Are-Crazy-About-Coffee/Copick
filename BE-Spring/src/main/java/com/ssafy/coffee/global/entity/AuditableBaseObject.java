package com.ssafy.coffee.global.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.annotation.CreatedBy;
import org.springframework.data.annotation.LastModifiedBy;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@MappedSuperclass
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
@Getter
public abstract class AuditableBaseObject extends BaseObject {

    // 이 어노테이션을 사용하기 위해서는 Spring Security의 Authentication 객체에서 사용자명을 가져오는 AuditorAware 구현체를 등록해야함

    //@CreatedBy
    @Setter
    @Column(name = "created_by", updatable = false)
    private String createdBy; // 생성자

    //@LastModifiedBy
    @Setter
    @Column(name = "last_modified_by")
    private String lastModifiedBy; // 수정자
}
