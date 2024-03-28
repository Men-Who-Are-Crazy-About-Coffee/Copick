package com.ssafy.coffee.domain.board.service;

import com.ssafy.coffee.domain.board.dto.*;
import com.ssafy.coffee.domain.board.entity.*;
import com.ssafy.coffee.domain.board.repository.BoardImageRepository;
import com.ssafy.coffee.domain.board.repository.BoardLikeRepository;
import com.ssafy.coffee.domain.board.repository.BoardRedisLikeRepository;
import com.ssafy.coffee.domain.board.repository.BoardRepository;
import com.ssafy.coffee.domain.comment.repository.CommentRepository;
import com.ssafy.coffee.domain.member.entity.Member;
import com.ssafy.coffee.domain.s3.service.S3Service;
import com.ssafy.coffee.global.constant.Role;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.SetOperations;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class BoardService {
    private final BoardRepository boardRepository;
    private final BoardImageRepository boardImageRepository;
    private final BoardLikeRepository boardLikeRepository;
    private final CommentRepository commentRepository;
    private final S3Service s3Service;
    private final BoardRedisLikeRepository boardRedisLikeRepository;
    private final RedisTemplate<String, String> redisTemplate;

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
        Board board = getExistBoard(boardIndex);

        List<BoardImage> boardImages = boardImageRepository.findAllByBoard(board);
        List<String> imageUrls = boardImages.stream()
                .map(BoardImage::getImage)
                .collect(Collectors.toList());

        BoardLikeInfoDto boardLikeInfo = getBoardLikeInfo(board,member);

        return new BoardGetResponseDto(board, imageUrls, boardLikeInfo.isLiked(),boardLikeInfo.getLikesCount(),boardLikeInfo.getCommentCount());
    }


    public BoardGetListResponseDto searchBoard(String keyword, String domain, Pageable pageable, Member member) {
        Page<Board> boards = boardRepository.findByTitleContainingAndDomainAndIsDeletedFalse(
                keyword, BoardDomain.valueOf(domain.toUpperCase()), pageable);

        List<BoardGetResponseDto> content = boards.getContent().stream().map(board -> {
            List<BoardImage> boardImages = boardImageRepository.findAllByBoard(board);
            List<String> imageUrls = boardImages.stream()
                    .map(BoardImage::getImage)
                    .collect(Collectors.toList());

            BoardLikeInfoDto boardLikeInfo = getBoardLikeInfo(board,member);

            return new BoardGetResponseDto(board, imageUrls, boardLikeInfo.isLiked(),boardLikeInfo.getLikesCount(),boardLikeInfo.getCommentCount());
        }).collect(Collectors.toList());

        return new BoardGetListResponseDto(content, boards.getTotalPages(), boards.getTotalElements());
    }

    public BoardLikeInfoDto getBoardLikeInfo(Board board, Member member) {
        SetOperations<String, String> stringStringSetOperations = redisTemplate.opsForSet();
        Set<String> boardRedisLikeSet = Objects.requireNonNull(stringStringSetOperations.intersect("board_like:boardIndex:"+board.getIndex(),"board_like:memberIndex:"+member.getIndex()));
//        log.debug("세트 : {} {}",boardRedisLikeSet,board.getIndex());
        return BoardLikeInfoDto.builder()
                .liked(boardLikeRepository.existsByBoardAndMember(board, member) || !boardRedisLikeSet.isEmpty())
                .likesCount(boardLikeRepository.countByBoard(board)+Objects.requireNonNull(stringStringSetOperations.size("board_like:boardIndex:"+board.getIndex())))
                .commentCount(commentRepository.countByBoard(board))
                .build();
    }

    public BoardGetListResponseDto getPostsByMember(Member member, Pageable pageable) {
        Page<Board> boards = boardRepository.findAllByCreatedByIndexAndIsDeletedFalse(member.getIndex(), pageable);
        List<BoardGetResponseDto> content = boards.getContent().stream().map(board -> {
            List<BoardImage> boardImages = boardImageRepository.findAllByBoard(board);
            List<String> imageUrls = boardImages.stream().map(BoardImage::getImage).collect(Collectors.toList());

            BoardLikeInfoDto boardLikeInfo = getBoardLikeInfo(board,member);

            return new BoardGetResponseDto(board, imageUrls, boardLikeInfo.isLiked(),boardLikeInfo.getLikesCount(),boardLikeInfo.getCommentCount());
        }).collect(Collectors.toList());

        return new BoardGetListResponseDto(content, boards.getTotalPages(), boards.getTotalElements());
    }

    public BoardGetListResponseDto getLikedPostsByMember(Member member, Pageable pageable) {
        Page<BoardLike> likes = boardLikeRepository.findAllByMemberIndex(member.getIndex(), pageable);
        List<BoardGetResponseDto> content = likes.getContent().stream().map(like -> {
            Board board = like.getBoard();
            List<BoardImage> boardImages = boardImageRepository.findAllByBoard(board);
            List<String> imageUrls = boardImages.stream().map(BoardImage::getImage).collect(Collectors.toList());

            BoardLikeInfoDto boardLikeInfo = getBoardLikeInfo(board,member);

            return new BoardGetResponseDto(board, imageUrls, boardLikeInfo.isLiked(),boardLikeInfo.getLikesCount(),boardLikeInfo.getCommentCount());
        }).collect(Collectors.toList());

        return new BoardGetListResponseDto(content, likes.getTotalPages(), likes.getTotalElements());
    }

    public void updateBoard(Long boardId, BoardUpdateRequestDto boardUpdateRequestDto, Member member) {
        Board board = getExistBoard(boardId);

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
        Board board = getExistBoard(boardIndex);

        if (member.getRole() != Role.ADMIN && !Objects.equals(board.getCreatedBy().getIndex(), member.getIndex()))
            throw new IllegalStateException("You do not have permission to update this board.");

        board.setDeleted(true);
        boardRepository.save(board);
    }

    public void addLike(Long boardIndex, Member member) {
        Board board = getExistBoard(boardIndex);
        Set<String> boardRedisLikeSet =getBoardRedisLikeSet(member, board);
        if(!boardRedisLikeSet.isEmpty()){
            throw new IllegalStateException("You already liked this board.");
        }
        boardLikeRepository.findByBoardAndMember(board, member)
                .ifPresent(like -> {
                    throw new IllegalStateException("You already liked this board.");
                });


        BoardRedisLike boardRedisLike = BoardRedisLike.builder()
                .boardIndex(board.getIndex())
                .memberIndex(member.getIndex())
                .build();
        boardRedisLikeRepository.save(boardRedisLike);
    }

    private Board getExistBoard(Long boardIndex) {
        return boardRepository.findByIndexAndIsDeletedFalse(boardIndex)
                .orElseThrow(() -> new IllegalArgumentException("Board with id " + boardIndex + " not found"));
    }

    @Scheduled(cron = "0 0/10 * * * *")
    public void saveBoardLikeFromRedis(){

        List<BoardLike> boardLikeList=new ArrayList<>();
        boardRedisLikeRepository.findAll().forEach(v->boardLikeList.add(v.toEntity()));
        boardRedisLikeRepository.deleteAll();
        boardLikeRepository.saveAll(boardLikeList);


    }

    public void removeLike(Long boardIndex, Member member) {
        Board board = getExistBoard(boardIndex);
        Set<String> boardRedisLikeSet = getBoardRedisLikeSet(member, board);
        if(!boardRedisLikeSet.isEmpty()){
            boardRedisLikeRepository.deleteById(Integer.valueOf(boardRedisLikeSet.iterator().next()));

        }else {
            BoardLike boardLike = boardLikeRepository.findByBoardAndMember(board, member)
                    .orElseThrow(() -> new IllegalArgumentException("Like not found"));
            boardLikeRepository.delete(boardLike);
        }
    }

    private Set<String> getBoardRedisLikeSet(Member member, Board board) {
        SetOperations<String, String> stringStringSetOperations = redisTemplate.opsForSet();
        return Objects.requireNonNull(stringStringSetOperations.intersect("board_like:boardIndex:"+ board.getIndex(),"board_like:memberIndex:"+ member.getIndex()));
    }
}
