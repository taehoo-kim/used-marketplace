package com.boot.transaction.model;

import java.util.Date;

import lombok.Data;

@Data
public class UserDTO {

	private String user_id;
	private String user_nickname;
	private String user_pwd;
	private String user_name;	
	private int user_age;
	private String user_email;
	private String user_phone;
	private String user_zipcode;
	private String user_addr;
	private String user_addr_detail;
	private Date user_regdate;
}
