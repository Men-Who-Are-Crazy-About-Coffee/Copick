package com.ssafy.coffee.domain.board.service;

import com.ssafy.coffee.domain.board.dto.BoardGetListResponseDto;
import com.ssafy.coffee.domain.board.dto.BoardGetResponseDto;
import com.ssafy.coffee.domain.board.dto.BoardPostRequestDto;
import com.ssafy.coffee.domain.board.dto.BoardUpdateRequestDto;
import com.ssafy.coffee.domain.board.entity.Board;
import com.ssafy.coffee.domain.board.entity.BoardDomain;
import com.ssafy.coffee.domain.board.repository.BoardRepository;
import com.ssafy.coffee.domain.member.entity.Member;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BoardService {
    private final BoardRepository boardRepository;

    public void addBoard(BoardPostRequestDto boardPostRequestDto, Member member) {

        Board board = Board.builder()
                .title(boardPostRequestDto.getTitle())
                .content(boardPostRequestDto.getContent())
                .domain(BoardDomain.valueOf(boardPostRequestDto.getDomain().toUpperCase()))
                .createdBy(member)
                .build();

        boardRepository.save(board);
    }


    public BoardGetResponseDto getBoard(Long boardIndex) {
        Board board = boardRepository.findById(boardIndex)
                .orElseThrow(() -> new IllegalArgumentException("Board with id " + boardIndex + " not found"));

        //return new BoardGetResponseDto(board);
        return null;
    }


    public BoardGetListResponseDto searchBoard(String keyword, String domain, Pageable pageable) {
//        Page<Board> boards = boardRepository.findByKeywordAndDomain(keyword, domain, pageable);
//        List<BoardGetResponseDto> content = boards.getContent().stream()
//                .map(BoardGetResponseDto::new)
//                .collect(Collectors.toList());
//
//        return new BoardGetListResponseDto(content, boards.getNumber(), boards.getSize(), boards.getTotalElements());
        return null;
    }


    public void updateBoard(Long boardId, BoardUpdateRequestDto boardUpdateRequestDto) {
        Board board = boardRepository.findById(boardId)
                .orElseThrow(() -> new IllegalArgumentException("Board with id " + boardId + " not found"));

        if (boardUpdateRequestDto.getTitle() != null)
            board.setTitle(boardUpdateRequestDto.getTitle());
        if (boardUpdateRequestDto.getContent() != null)
            board.setContent(boardUpdateRequestDto.getContent());
        // 필요한 다른 필드들에 대한 업데이트 로직도 여기에 추가

        boardRepository.save(board);
    }

    public void deleteBoard(Long boardId) {
        if (!boardRepository.existsById(boardId))
            throw new IllegalArgumentException("Board with id " + boardId + " does not exist");

        boardRepository.deleteById(boardId);
    }
}
