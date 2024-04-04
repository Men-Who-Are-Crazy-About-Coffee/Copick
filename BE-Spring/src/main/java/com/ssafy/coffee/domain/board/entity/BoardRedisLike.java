package com.ssafy.coffee.domain.board.entity;

import com.ssafy.coffee.domain.member.entity.Member;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;
import org.springframework.data.annotation.Id;
import org.springframework.data.redis.core.RedisHash;
import org.springframework.data.redis.core.index.Indexed;

import java.util.List;

@RedisHash("board_like")
@Getter
@ToString
public class BoardRedisLike {
    @Id
    private Integer likeIndex;
    @Indexed
    private Long memberIndex;
    @Indexed
    private Long boardIndex;

    @Builder
    public BoardRedisLike(Long memberIndex, Long boardIndex) {
        this.memberIndex = memberIndex;
        this.boardIndex = boardIndex;
    }
    static public List<BoardLike> toEntity(List<BoardRedisLike> list){
        return list.stream().map(v->v.toEntity()).toList();
    }
    public BoardLike toEntity(){
        return BoardLike.builder()
                .board(Board.builder().index(this.boardIndex).build())
                .member(Member.builder().index(this.memberIndex).build())
                .build();
    }
}
