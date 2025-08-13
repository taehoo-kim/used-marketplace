package com.boot.transaction.model;

import java.sql.Timestamp;

import lombok.Data;

@Data
public class ProductCommentDTO {
    private int comment_id;
    private int product_num;
    private String user_id;
    private String comment_content;
    private Timestamp comment_date;
}