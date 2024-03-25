package com.ssafy.coffee.domain.board.service;

import com.ssafy.coffee.domain.board.dto.BoardGetListResponseDto;
import com.ssafy.coffee.domain.board.dto.BoardGetResponseDto;
import com.ssafy.coffee.domain.board.dto.BoardPostRequestDto;
import com.ssafy.coffee.domain.board.dto.BoardUpdateRequestDto;
import com.ssafy.coffee.domain.board.entity.Board;
import com.ssafy.coffee.domain.board.entity.BoardDomain;
import com.ssafy.coffee.domain.board.entity.BoardImage;
import com.ssafy.coffee.domain.board.entity.BoardLike;
import com.ssafy.coffee.domain.board.repository.BoardImageRepository;
import com.ssafy.coffee.domain.board.repository.BoardLikeRepository;
import com.ssafy.coffee.domain.board.repository.BoardRepository;
import com.ssafy.coffee.domain.comment.repository.CommentRepository;
import com.ssafy.coffee.domain.member.entity.Member;
import com.ssafy.coffee.domain.s3.service.S3Service;
import com.ssafy.coffee.global.constant.Role;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BoardService {
    private final BoardRepository boardRepository;
    private final BoardImageRepository boardImageRepository;
    private final BoardLikeRepository boardLikeRepository;
    private final CommentRepository commentRepository;
    private final S3Service s3Service;

    @Transactional
    public void addBoard(BoardPostRequestDto boardPostRequestDto, Member member) {
        // 게시글 생성 및 저장
        Board board = boardRepository.save(
                Board.builder()
                        .title(boardPostRequestDto.getTitle())
                        .content(boardPostRequestDto.getContent())
                        .domain(BoardDomain.valueOf(boardPostRequestDto.getDomain().toUpperCase()))
                        .createdBy(member)
                        .build()
        );

        if (boardPostRequestDto.getImages() != null) {
            String filePath = "board/" + board.getIndex();
            List<String> urls = s3Service.uploadMultipleFiles(filePath, boardPostRequestDto.getImages());

            for (String url : urls) {
                BoardImage boardImage = BoardImage.builder().board(board).image(url).build();
                boardImageRepository.save(boardImage);
            }
        }
    }


    public BoardGetResponseDto getBoard(Long boardIndex, Member member) {
        Board board = boardRepository.findByIndexAndIsDeletedFalse(boardIndex)
                .orElseThrow(() -> new IllegalArgumentException("Board with id " + boardIndex + " not found"));

        List<BoardImage> boardImages = boardImageRepository.findAllByBoard(board);
        List<String> images = boardImages.stream()
                .map(BoardImage::getImage)
                .collect(Collectors.toList());

        boolean liked = boardLikeRepository.existsByBoardAndMember(board, member);
        long likesCount = boardLikeRepository.countByBoard(board);
        long commentCount = commentRepository.countByBoard(board);

        return new BoardGetResponseDto(board, images, liked, likesCount, commentCount);
    }


    public BoardGetListResponseDto searchBoard(String keyword, String domain, Pageable pageable, Member member) {
        Page<Board> boards = boardRepository.findByTitleContainingAndDomainAndIsDeletedFalse(
                keyword, BoardDomain.valueOf(domain.toUpperCase()), pageable);

        List<BoardGetResponseDto> content = boards.getContent().stream().map(board -> {
            List<BoardImage> boardImages = boardImageRepository.findAllByBoard(board);
            List<String> imageUrls = boardImages.stream()
                    .map(BoardImage::getImage)
                    .collect(Collectors.toList());

            boolean liked = boardLikeRepository.existsByBoardAndMember(board, member);
            long likesCount = boardLikeRepository.countByBoard(board);
            long commentCount = commentRepository.countByBoard(board);

            return new BoardGetResponseDto(board, imageUrls, liked, likesCount, commentCount);
        }).collect(Collectors.toList());

        return new BoardGetListResponseDto(content, boards.getTotalPages(), boards.getTotalElements());
    }

    public BoardGetListResponseDto getPostsByMember(Member member, Pageable pageable) {
        Page<Board> boards = boardRepository.findAllByCreatedByIndexAndIsDeletedFalse(member.getIndex(), pageable);
        List<BoardGetResponseDto> content = boards.getContent().stream().map(board -> {
            List<BoardImage> boardImages = boardImageRepository.findAllByBoard(board);
            List<String> imageUrls = boardImages.stream().map(BoardImage::getImage).collect(Collectors.toList());

            boolean liked = boardLikeRepository.existsByBoardAndMember(board, member);
            long likesCount = boardLikeRepository.countByBoard(board);
            long commentCount = commentRepository.countByBoard(board);

            return new BoardGetResponseDto(board, imageUrls, liked, likesCount, commentCount);
        }).collect(Collectors.toList());

        return new BoardGetListResponseDto(content, boards.getTotalPages(), boards.getTotalElements());
    }

    public BoardGetListResponseDto getLikedPostsByMember(Member member, Pageable pageable) {
        Page<BoardLike> likes = boardLikeRepository.findAllByMemberIndex(member.getIndex(), pageable);
        List<BoardGetResponseDto> content = likes.getContent().stream().map(like -> {
            Board board = like.getBoard();
            List<BoardImage> boardImages = boardImageRepository.findAllByBoard(board);
            List<String> imageUrls = boardImages.stream().map(BoardImage::getImage).collect(Collectors.toList());

            boolean liked = boardLikeRepository.existsByBoardAndMember(board, member);
            long likesCount = boardLikeRepository.countByBoard(board);
            long commentCount = commentRepository.countByBoard(board);

            return new BoardGetResponseDto(board, imageUrls, liked, likesCount, commentCount);
        }).collect(Collectors.toList());

        return new BoardGetListResponseDto(content, likes.getTotalPages(), likes.getTotalElements());
    }

    public void updateBoard(Long boardId, BoardUpdateRequestDto boardUpdateRequestDto, Member member) {
        Board board = boardRepository.findByIndexAndIsDeletedFalse(boardId)
                .orElseThrow(() -> new IllegalArgumentException("Board with id " + boardId + " not found"));

        if (member.getRole() != Role.ADMIN && !Objects.equals(board.getCreatedBy().getIndex(), member.getIndex()))
            throw new IllegalStateException("You do not have permission to update this board.");

        if (boardUpdateRequestDto.getDomain() != null)
            board.setDomain(BoardDomain.valueOf(boardUpdateRequestDto.getDomain()));
        if (boardUpdateRequestDto.getTitle() != null)
            board.setTitle(boardUpdateRequestDto.getTitle());
        if (boardUpdateRequestDto.getContent() != null)
            board.setContent(boardUpdateRequestDto.getContent());

        boardRepository.save(board);
    }

    public void deleteBoard(Long boardIndex, Member member) {
        Board board = boardRepository.findByIndexAndIsDeletedFalse(boardIndex)
                .orElseThrow(() -> new IllegalArgumentException("Board with index " + boardIndex + " does not exist"));

        if (member.getRole() != Role.ADMIN && !Objects.equals(board.getCreatedBy().getIndex(), member.getIndex()))
            throw new IllegalStateException("You do not have permission to update this board.");

        board.setDeleted(true);
        boardRepository.save(board);
    }

    public void addLike(Long boardIndex, Member member) {
        Board board = boardRepository.findByIndexAndIsDeletedFalse(boardIndex)
                .orElseThrow(() -> new IllegalArgumentException("Board with id " + boardIndex + " not found"));

        boardLikeRepository.findByBoardAndMember(board, member)
                .ifPresent(like -> {
                    throw new IllegalStateException("You already liked this board.");
                });

        BoardLike boardLike = BoardLike.builder().board(board).member(member).build();
        boardLikeRepository.save(boardLike);
    }

    public void removeLike(Long boardIndex, Member member) {
        Board board = boardRepository.findByIndexAndIsDeletedFalse(boardIndex)
                .orElseThrow(() -> new IllegalArgumentException("Board with id " + boardIndex + " not found"));

        BoardLike boardLike = boardLikeRepository.findByBoardAndMember(board, member)
                .orElseThrow(() -> new IllegalArgumentException("Like not found"));

        boardLikeRepository.delete(boardLike);
    }


}
