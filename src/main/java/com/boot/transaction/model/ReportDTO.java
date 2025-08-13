package com.boot.transaction.model;

import java.util.Date;

import lombok.Data;

@Data
public class ReportDTO {

	private int report_num;
	private int product_num;
	private String reporter_id;
	private String reported_user_id;
	private Date reported_at;
	private String report_reason;
	
}
