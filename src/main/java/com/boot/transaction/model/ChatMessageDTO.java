package com.boot.transaction.model;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ChatMessageDTO {
    private Long message_id;
    private String from_user;
    private String to_user;
    private Integer product_num;
    private String message;
    private LocalDateTime sent_time;
    private int is_read;
    private Integer chat_room_num;
    private int is_leave; // '나가기' 상태를 표시할 필드
}

