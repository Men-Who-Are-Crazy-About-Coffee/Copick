package com.ssafy.coffee.domain.comment.service;

import com.ssafy.coffee.domain.board.entity.Board;
import com.ssafy.coffee.domain.board.repository.BoardRepository;
import com.ssafy.coffee.domain.comment.dto.CommentGetListResponseDto;
import com.ssafy.coffee.domain.comment.dto.CommentGetResponseDto;
import com.ssafy.coffee.domain.comment.dto.CommentPostRequestDto;
import com.ssafy.coffee.domain.comment.dto.CommentUpdateRequestDto;
import com.ssafy.coffee.domain.comment.entity.Comment;
import com.ssafy.coffee.domain.comment.repository.CommentRepository;
import com.ssafy.coffee.domain.member.entity.Member;
import com.ssafy.coffee.global.constant.Role;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
public class CommentService {
    private final CommentRepository commentRepository;
    private final BoardRepository boardRepository;

    public void addComment(CommentPostRequestDto commentPostRequestDto, Member member) {
        Board board = boardRepository.findByIndexAndIsDeletedFalse(commentPostRequestDto.getBoardIndex())
                .orElseThrow(() -> new IllegalArgumentException("Board not found"));

        Comment comment = Comment.builder()
                .board(board)
                .content(commentPostRequestDto.getContent())
                .createBy(member)
                .build();

        commentRepository.save(comment);
    }

    public void updateComment(Long commentIndex, CommentUpdateRequestDto commentUpdateRequestDto, Member member) {
        Comment comment = commentRepository.findById(commentIndex)
                .orElseThrow(() -> new IllegalArgumentException("Comment not found"));

        if (!comment.getCreatedBy().equals(member) && member.getRole() != Role.ADMIN)
            throw new IllegalStateException("You do not have permission to update this comment.");

        comment.setContent(commentUpdateRequestDto.getContent());
        commentRepository.save(comment);
    }


    public void deleteComment(Long commentIndex, Member member) {
        Comment comment = commentRepository.findById(commentIndex)
                .orElseThrow(() -> new IllegalArgumentException("Comment not found"));

        if (!comment.getCreatedBy().equals(member) && member.getRole() != Role.ADMIN)
            throw new IllegalStateException("You do not have permission to update this comment.");

        commentRepository.delete(comment);
    }


    public CommentGetListResponseDto getCommentsByBoard(Long boardIndex, Pageable pageable) {

        Page<Comment> comments = commentRepository.findAllByBoard(boardIndex, pageable);
        List<CommentGetResponseDto> commentGetResponseDtos = comments.stream()
                .map(CommentGetResponseDto::new)
                .toList();
        return new CommentGetListResponseDto(
                commentGetResponseDtos,
                comments.getTotalPages(),
                comments.getNumberOfElements());
    }


    public CommentGetListResponseDto getCommentsByUser(Long userIndex, Pageable pageable) {
        Page<Comment> comments = commentRepository.findAllByCreatedByIndex(userIndex, pageable);
        List<CommentGetResponseDto> commentGetResponseDtos = comments.stream()
                .map(CommentGetResponseDto::new)
                .toList();
        return new CommentGetListResponseDto(
                commentGetResponseDtos,
                comments.getTotalPages(),
                comments.getNumberOfElements());
    }

}
