package com.boot.transaction.model;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class PageDTO {

	// 페이징 처리 작업 관련 멤버 선언.
	private int page;                   // 현재 페이지
	private int rowsize;                // 한 페이지당 보여질 게시물의 수
	private int totalRecord;            // 테이블 전체 게시물의 수
	private int startNo;                // 해당 페이지에서 시작 번호
	private int endNo;                  // 해당 페이지에서 끝 번호
	private int startBlock;             // 해당 페이지에서 시작 블럭
	private int endBlock;               // 해당 페이지에서 끝 블럭
	private int allPage;                // 전체 페이지 수
	private int block = 3;              // 아래에 보여질 최대 페이지 수
	
	private String area;				// 검색 영역
	private String category;			// 검색 영역
	private String keyword;				// 검색 키워드
	private Integer minPrice;           // 최소 가격
	private Integer maxPrice;           // 최대 가격
	
	private String user_id;				// 회원 아이디
	
	
	// 일반적인 페이징 처리 인자 생성자
	public PageDTO(int page, int rowsize, int totalRecord) {
		
		this.page = page;
		this.rowsize = rowsize;
		this.totalRecord = totalRecord;
		
		// 해당 페이지에서 시작 번호.
		this.startNo = (this.page * this.rowsize) - (this.rowsize - 1);
		
		// 해당 페이지에서 끝 번호.
		this.endNo = (this.page * this.rowsize);
		
		// 해당 페이지에서 시작 블럭
		this.startBlock = 
				(((this.page - 1) / this.block) * this.block) + 1;
		
		// 해당 페이지에서 끝 블럭
		this.endBlock = 
				(((this.page - 1) / this.block) * this.block) + this.block;
		
		// 전체 페이지 수 얻어오는 과정
		this.allPage =
				(int)Math.ceil(this.totalRecord / (double)this.rowsize);
		
		// 전체 페이지 수보다 endBlock이 큰 경우
		if(this.endBlock > this.allPage) {
			this.endBlock = this.allPage;
		}
		
	}  // 일반적인 페이징 처리 인자 생성자
	
	
	// 검색을 하는 페이징 처리 인자 생성자
	public PageDTO(int page, int rowsize, int totalRecord,
				String area, String category, String keyword, Integer minPrice, Integer maxPrice) {
		
		this(page, rowsize, totalRecord);
		this.area = area;
		this.category = category;
		this.keyword = keyword;
		this.minPrice = minPrice;
		this.maxPrice = maxPrice;
		
	}  // 인자 생성자
	
	
	// 회원의 마이페이지에서 판매글 목록에 대한 페이징 처리 인자 생성자
	public PageDTO(int page, int rowsize, int totalRecord, String user_id) {
		
		this(page, rowsize, totalRecord);
		this.user_id = user_id;
		
	}  // 인자 생성자

}