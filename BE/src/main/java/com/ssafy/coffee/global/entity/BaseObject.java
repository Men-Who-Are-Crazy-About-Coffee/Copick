package com.ssafy.coffee.global.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@MappedSuperclass
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
@Getter
public abstract class BaseObject {

    @Setter
    @Column(name = "is_deleted", nullable = false, columnDefinition = "TINYINT(1)")
    private boolean isDeleted = false; // 데이터 삭제 여부, 기본값 false

    @CreatedDate
    @Column(name = "reg_date", nullable = false)
    private LocalDateTime regDate; // 등록 일시

    @LastModifiedDate
    @Column(name = "mod_date")
    private LocalDateTime modDate; // 수정 일시
}
