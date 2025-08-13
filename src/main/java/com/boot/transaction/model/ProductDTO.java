package com.boot.transaction.model;

import java.util.Date;

import org.springframework.web.multipart.MultipartFile;

import lombok.Data;

@Data
public class ProductDTO {

	private int product_num;
	private String category_code;
	private String product_name;
	private Date product_date;
	private String product_img;
	private String product_des;
	private String user_id;
	private Integer sales_price;
	private String sales_area;
	private String product_title;
	private String product_hits;
	private String product_status;
	
	private MultipartFile[] product_img_File;
	
}
