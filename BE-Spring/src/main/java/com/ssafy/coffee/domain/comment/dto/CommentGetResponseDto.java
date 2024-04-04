package com.ssafy.coffee.domain.comment.dto;

import com.ssafy.coffee.domain.comment.entity.Comment;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class CommentGetResponseDto {
    private Long index;
    private Long boardIndex;
    private String content;
    private LocalDateTime regDate;
    private LocalDateTime modDate;

    private Long memberIndex;
    private String memberName;
    private String memberPrifileImage;

    public CommentGetResponseDto(Comment comment) {
        this.index = comment.getIndex();
        this.boardIndex = comment.getBoard().getIndex();
        this.content = comment.getContent();
        this.regDate = comment.getRegDate();
        this.modDate = comment.getModDate();

        this.memberIndex = comment.getCreatedBy().getIndex();
        this.memberName = comment.getCreatedBy().getNickname();
        this.memberPrifileImage = comment.getCreatedBy().getProfileImage();
    }

}
