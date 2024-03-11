package com.ssafy.coffee.domain.comment.service;

import com.ssafy.coffee.domain.comment.dto.CommentGetListResponseDto;
import com.ssafy.coffee.domain.comment.dto.CommentPostRequestDto;
import com.ssafy.coffee.domain.comment.dto.CommentUpdateRequestDto;
import com.ssafy.coffee.domain.comment.repository.CommentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CommentService {
    private final CommentRepository commentRepository;

    public void addComment(CommentPostRequestDto commentPostRequestDto) {

    }

    public void updateComment(Long commentIndex, CommentUpdateRequestDto commentUpdateRequestDto) {

    }

    public void deleteComment(Long commentIndex) {

    }

    public CommentGetListResponseDto getCommentsByBoard(Long boardIndex, Pageable pageable) {
        return null;
    }

    public CommentGetListResponseDto getCommentsByUser(Long userIndex, Pageable pageable) {
        return null;
    }
}
