package com.ssafy.coffee.domain.board.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.ssafy.coffee.domain.board.dto.BoardGetListResponseDto;
import com.ssafy.coffee.domain.board.dto.BoardGetResponseDto;
import com.ssafy.coffee.domain.board.dto.BoardPostRequestDto;
import com.ssafy.coffee.domain.board.dto.BoardUpdateRequestDto;
import com.ssafy.coffee.domain.board.entity.Board;
import com.ssafy.coffee.domain.board.entity.BoardDomain;
import com.ssafy.coffee.domain.board.repository.BoardRepository;
import com.ssafy.coffee.domain.member.entity.Member;
import com.ssafy.coffee.domain.s3.service.S3Service;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BoardService {
    private final BoardRepository boardRepository;
    private final S3Service s3Service;

    public void addBoard(BoardPostRequestDto boardPostRequestDto, Member member) {
        
        Board board = boardRepository.save(
                Board.builder()
                        .title(boardPostRequestDto.getTitle())
                        .content("")
                        .domain(BoardDomain.valueOf(boardPostRequestDto.getDomain().toUpperCase()))
                        .createdBy(member)
                        .build()
        );

        String filePath = "board/" + board.getIndex();
        List<String> urls = s3Service.uploadMultipleFiles(filePath, boardPostRequestDto.getUpfiles());

        ObjectMapper mapper = new ObjectMapper();
        ArrayNode contentArray = mapper.createArrayNode();

        for (String url : urls) {
            ObjectNode imageNode = mapper.createObjectNode();
            imageNode.put("type", "image");
            imageNode.put("content", url);
            contentArray.add(imageNode);
        }

        ObjectNode textNode = mapper.createObjectNode();
        textNode.put("type", "content");
        textNode.put("content", boardPostRequestDto.getContent());
        contentArray.add(textNode);

        String jsonContent = null;
        try {
            jsonContent = mapper.writeValueAsString(contentArray);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
        board.setContent(jsonContent);
        boardRepository.save(board);
    }


    public BoardGetResponseDto getBoard(Long boardIndex) {
        Board board = boardRepository.findById(boardIndex)
                .orElseThrow(() -> new IllegalArgumentException("Board with id " + boardIndex + " not found"));

        return new BoardGetResponseDto(board);
    }


    public BoardGetListResponseDto searchBoard(String keyword, String domain, Pageable pageable) {
        Page<Board> boards = boardRepository.findByTitleContainingAndDomain(keyword, BoardDomain.valueOf(domain), pageable);
        List<BoardGetResponseDto> content = boards.getContent().stream()
                .map(BoardGetResponseDto::new)
                .collect(Collectors.toList());

        return new BoardGetListResponseDto(content, boards.getTotalPages(), boards.getTotalElements());
    }


    public void updateBoard(Long boardId, BoardUpdateRequestDto boardUpdateRequestDto) {
        Board board = boardRepository.findById(boardId)
                .orElseThrow(() -> new IllegalArgumentException("Board with id " + boardId + " not found"));

        if (boardUpdateRequestDto.getTitle() != null)
            board.setTitle(boardUpdateRequestDto.getTitle());
        if (boardUpdateRequestDto.getContent() != null)
            board.setContent(boardUpdateRequestDto.getContent());

        boardRepository.save(board);
    }

    public void deleteBoard(Long boardIndex) {
        if (!boardRepository.existsById(boardIndex))
            throw new IllegalArgumentException("Board with index " + boardIndex + " does not exist");

        boardRepository.deleteById(boardIndex);
    }
}
