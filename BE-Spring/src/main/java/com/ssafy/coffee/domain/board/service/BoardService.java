package com.ssafy.coffee.domain.board.service;

import com.ssafy.coffee.domain.board.dto.BoardGetListResponseDto;
import com.ssafy.coffee.domain.board.dto.BoardGetResponseDto;
import com.ssafy.coffee.domain.board.dto.BoardPostRequestDto;
import com.ssafy.coffee.domain.board.dto.BoardUpdateRequestDto;
import com.ssafy.coffee.domain.board.repository.BoardRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BoardService {
    private final BoardRepository boardRepository;

    public void addBoard(BoardPostRequestDto boardPostRequestDto) {

    }

    public BoardGetResponseDto getBoard(Long boardIndex) {
        return null;
    }

    public BoardGetListResponseDto searchBoard(String keyword, String domain, Pageable pageable) {
        return null;
    }

    public void updateBoard(Long boardId, BoardUpdateRequestDto boardUpdateRequestDto) {

    }

    public void deleteBoard(Long boardId) {

    }
}
