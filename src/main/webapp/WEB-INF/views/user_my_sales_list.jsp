<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style type="text/css">
    body {
        font-family: 'Segoe UI', sans-serif;
        background-color: #f4f7fb;
        margin: 0;
        padding: 0;
        color: #2a2a2a;
    }

    .main-bar {
        background-color: white;
        border-bottom: 1px solid #ddd;
        padding: 16px 20px;
    }

    .tbl {
        padding: 40px;
        max-width: 1000px;
        margin: 0 auto;
    }

    table {
        width: 100%;
        border-collapse: collapse;
        background-color: #ffffff;
        border-radius: 10px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        overflow: hidden;
        font-size: 15px;
    }

    th, td {
        padding: 14px 18px;
        text-align: center;
        border: 1px solid #e3e8f0;
    }

    th {
        background-color: #f0f4f9;
        font-weight: 600;
        color: #2a2a2a;
    }

    .product-btn {
        cursor: pointer;
        transition: background-color 0.2s ease;
    }

    .product-btn:hover {
        background-color: #f0f6ff;
    }

   	#product_modal, #product_modify_modal {
	    display: none;
	    position: fixed;
	    z-index: 1000;
	    top: 0;
	    left: 0;
	    height: 100%;
	    width: 100%;
	    background-color: rgba(0, 0, 0, 0.6);
	
	    display: flex;
	    align-items: center;
	    justify-content: center;
	    overflow-y: auto;
	    padding: 40px 20px;
	    box-sizing: border-box;
	}
	
	#product_content, #product_modify {
	    background-color: #ffffff;
	    padding: 30px 40px;
	    border-radius: 12px;
	    box-shadow: 0 8px 24px rgba(0,0,0,0.15);
	    width: 100%;
	    max-width: 800px;
	    max-height: 90vh;
	    overflow-y: auto;
	    animation: fadeIn 0.3s ease;
	    box-sizing: border-box;
	    position: relative;
	}

    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }

    .close_btn {
	    position: absolute;
	    top: 16px;
	    right: 20px;
	    font-size: 24px;
	    color: #999;
	    cursor: pointer;
	    z-index: 10;
	}
	
	.close_btn:hover {
	    color: #ff4d4f;
	}

    .modal-table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0 10px;
        font-size: 14px;
        color: #2a2a2a;
    }

    .modal-table td {
        padding: 12px 16px;
        background-color: #fafcff;
        border-radius: 6px;
        vertical-align: top;
    }

    .modal-table input[type="text"],
    .modal-table textarea {
        width: 100%;
        padding: 10px 12px;
        font-size: 14px;
        border: 1px solid #ccd9ee;
        border-radius: 6px;
        background-color: #ffffff;
        box-sizing: border-box;
        outline: none;
        font-family: 'Segoe UI', sans-serif;
        transition: border 0.2s ease, box-shadow 0.2s ease;
    }

    .modal-table textarea {
        resize: vertical;
        min-height: 80px;
    }

    .modal-table input:focus,
    .modal-table textarea:focus {
        border-color: #2b7cff;
        box-shadow: 0 0 0 3px rgba(43, 124, 255, 0.15);
    }

    .product-img-preview {
        border: 1px solid #ccd9ee;
        border-radius: 8px;
        margin: 6px 10px 6px 0;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }

    .button {
        margin-top: 30px;
        text-align: right;
    }

    .button button {
        background-color: #e6f0ff;
        border: none;
        padding: 10px 18px;
        border-radius: 6px;
        font-size: 14px;
        color: #2b7cff;
        cursor: pointer;
        margin-left: 12px;
        transition: background-color 0.2s ease;
        font-weight: 500;
    }

    .button button:hover {
        background-color: #d0e4ff;
    }
    
    .info-span {
	    margin-right: 50px;
	    display: inline-block;
	}
	
	.status-blue {
		color: blue;
	}
	
	.status-red {
		color: red;
	}
	
	.status-gray {
		color: gray;
	}
	
	.mod-img-guide {
		color: gray;
	}

	.pagination-wrapper {
        margin: 30px 0;
    }

    .pagination {
        display: inline-flex;
        gap: 6px;
        padding: 10px 20px;
        border-radius: 12px;
        background-color: #f2f7fd;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
    }

    .page-btn {
        display: inline-block;
        padding: 8px 14px;
        font-size: 14px;
        font-weight: 500;
        color: #2b7cff;
        background-color: white;
        border: 1px solid #b3d3ff;
        border-radius: 8px;
        text-decoration: none;
        transition: all 0.2s ease;
    }

    .page-btn:hover {
        background-color: #dceaff;
    }

    .page-btn.active {
        background-color: #2b7cff;
        color: white;
        border-color: #2b7cff;
    }

    .page-btn.first,
    .page-btn.last {
        font-weight: bold;
    }
    
    
	.product-img-wrapper {
	    position: relative;
	    width: 260px;
	    height: 260px;
	}

</style>


<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script type="text/javascript">
	
	const contextPath = "<%= request.getContextPath() %>/";
	
	$(document).ready(function() {
		
		$(".product-btn").click(function() {
			const product_num = $(this).data("productNum");
			const category_code = $(this).data("categoryCode");
			const product_name = $(this).data("productName");
			const product_date = $(this).data("productDate");
			const product_img = $(this).data("productImg");
			const product_des = $(this).data("productDes");
			const sales_price = $(this).data("salesPrice");
			const product_title = $(this).data("productTitle");
			const product_hits = $(this).data("productHits");
			const product_status = $(this).data("productStatus");
			const category_name = $(this).data("categoryName");
			
			const formatted_price = Number(sales_price).toLocaleString();
			
			let p_html = "<div>";
			p_html += "<h2>물품 판매글 정보</h2>";
			p_html += "</div>";
			
			p_html += "<div><table class='modal-table'>";
			
			p_html += "<tr>";
			p_html += "<td><b>판매글 제목 : </b>";
			p_html += product_title;
			p_html += "</td>";
			p_html += "<td><b>등록일 : </b>";
			p_html += product_date;
			p_html += "</td>";
			p_html += "<td><b>조회수 : </b>";
			p_html += product_hits;
			p_html += "</td>";
			p_html += "</tr>";
			
			p_html += "<tr>";
			p_html += "<td><b>물품명 : </b>";
			p_html += product_name;
			p_html += "</td>";
			p_html += "<td><b>카테고리 : </b>";
			p_html += category_name;
			p_html += "</td>";
			p_html += "<td><b>판매상태 : </b>";
			p_html += product_status;
			p_html += "</td>";
			p_html += "</tr>";
			
			p_html += "<tr>";
			p_html += "<td><b>물품 설명</b></td>";
			p_html += "<td colspan='2'>";
			p_html += product_des;
			p_html += "</td>";
			p_html += "</tr>";
			
			p_html += "<tr>";
			p_html += "<td><b>물품 사진</b></th>";
			p_html += "<td colspan='2'>";
			const imgArr = product_img.split(",");
			for (let img of imgArr) {
				p_html += "<img src='"+contextPath+"resources/upload/"+img.trim()+"' class='product-img-preview' width='150px' height='150px'>";
			}
			p_html += "</td>";
			p_html += "</tr>";
			
			p_html += "<tr>";
			p_html += "<td colspan='3'><b>판매 가격 : </b>";
			if(formatted_price == 0) {
				p_html += "무료나눔";
			}else {
				p_html += formatted_price;
				p_html += " 원";
			}
			p_html += "</td></tr>";
			
			p_html += "</table></div>";
			
			p_html += "<div class='button'>";
			p_html += "<button type='button' onclick='productModify(\"" + product_num + "\", \"" + product_title + "\", \"" + product_name + "\", \"" + category_name + "\", \"" + product_des + "\", \"" + product_img + "\", \"" + sales_price + "\")'>수정</button>";
			p_html += "<button type='button' onclick=\"if(confirm('현재 판매 글을 정말 삭제하시겠습니까?')) location.href='user_product_delete.go?product_num=" + product_num + "'\">삭제</button>";
			p_html += "</div>";
			p_html += "<div class='close_btn' onclick='closeProductModal()'>&times;</div>";
			
			document.getElementById("product_content").innerHTML = p_html;
			document.getElementById("product_modal").style.display = "block";
		});
		
	});
	
	
	function productModify(product_num, product_title, product_name, category_name, product_des, product_img, sales_price) {
		
		$(document).ready(function() {
			
			$("#free").on("change", function () {
	            if($(this).is(":checked")) {
	                $("input[name='sales_price']").val("0").prop("readonly", true);
	            } else {
	                $("input[name='sales_price']").val("").prop("readonly", false);
	            }
	        });
			
		});
		
		let modify_html = "<div>";
		modify_html += "<h2>물품 판매글 수정</h2>";
		modify_html += "</div>";
		
		modify_html += "<form id='mod_form' method='post' action='user_product_modify.go'>";
		modify_html += "<input type='hidden' name='product_num' value='"+product_num+"'>";
		modify_html += "<div><table class='modal-table'>";
		
		modify_html += "<tr>";
		modify_html += "<td colspan='2'><b>판매글 제목 : </b>";
		modify_html += "<input type='text' name='product_title' value='"+product_title+"'>";
		modify_html += "</td>";
		modify_html += "</tr>";
		
		modify_html += "<tr>";
		modify_html += "<td width='20%'><b>카테고리</b>";
		modify_html += "<input type='text' value='"+category_name+"' readOnly></input>";
		modify_html += "</td>";
		modify_html += "<td><b>물품명 : </b>";
		modify_html += "<input type='text' name='product_name' value='"+product_name+"'>";
		modify_html += "</td>";
		modify_html += "</tr>";
		
		modify_html += "<tr>";
		modify_html += "<td><b>물품 설명</b></td>";
		modify_html += "<td colspan='2'>";
		modify_html += "<textarea name='product_des' rows='5' cols='30'>"+product_des+"</textarea>";
		modify_html += "</td>";
		modify_html += "</tr>";
		
		modify_html += "<tr>";
		modify_html += "<td><b>물품 사진</b></th>";
		modify_html += "<td colspan='2'>";
		const imgArr = product_img.split(",");
		for (let img of imgArr) {
			modify_html += "<img src='"+contextPath+"resources/upload/"+img.trim()+"' class='product-img-preview' width='130px' height='130px'>";
		}
		modify_html += "<br><span class='mod-img-guide'>※사진 수정을 원하시면 판매 글 삭제 후 다시 등록해주세요.</span>"
		modify_html += "</td>";
		modify_html += "</tr>";
		
		modify_html += "<tr>";
		modify_html += "<td><b>판매 가격</b>";
		modify_html += "<br><br><input type='checkbox' id='free'>무료나눔</td>";
		modify_html += "<td><input type='text' name='sales_price' value='"+sales_price+"'> 원</td>";
		modify_html += "</tr>";
		
		modify_html += "</table></div>";
		
		modify_html += "<div class='button'>";
		modify_html += "<button type='submit'>수정완료</button>";
		modify_html += "<button type='button' onclick='closeProductModifyModal()'>취소</button>";
		modify_html += "</div></form>";
		modify_html += "<div class='close_btn' onclick='closeProductModifyModal()'>&times;</div>";
		
		document.getElementById("product_modify").innerHTML = modify_html;
		
		closeProductModal();
		document.getElementById("product_modify_modal").style.display = "block";
		
	}
	
	function closeProductModal() {
		document.getElementById("product_modal").style.display = "none";
	}
	
	function closeProductModifyModal() {
		document.getElementById("product_modify_modal").style.display = "none";
	}
	
	
	
</script>

<title>Insert title here</title>
</head>
<body>

	<div class="main-bar">
		<jsp:include page="include/header.jsp" />
	</div>
	
	<div>
		<c:set var="user_sales_list" value="${user_product_list}"/>
		<c:set var="category_list" value="${category_list }"/>
		
		<div class="tbl" align="center">
			<table border="1">
				<tr>
					<th colspan="3">등록된 판매 글</th>
				</tr>
				
				<c:if test="${empty user_sales_list }">
				
					<tr>
						<td colspan="3">등록된 판매 글이 존재하지 않습니다.</td>
					</tr>
				
				</c:if>
				
				<c:forEach var="user_sales_product" items="${user_sales_list}">
					<c:set var="imgList" value="${fn:split(user_sales_product.product_img, ',')}" />
					
					<c:forEach var="categoryDTO" items="${category_list }">
						<c:if test="${categoryDTO.category_code == user_sales_product.category_code }">
							<tr class="product-btn" data-product-num="${user_sales_product.product_num }"
												data-category-code="${user_sales_product.category_code }"
												data-product-name="${user_sales_product.product_name }"
												data-product-date="<fmt:formatDate value='${user_sales_product.product_date}' pattern='yyyy-MM-dd'/>"
												data-product-img="${user_sales_product.product_img }"
												data-product-des="${user_sales_product.product_des }"
												data-sales-price="${user_sales_product.sales_price }"
												data-product-title="${user_sales_product.product_title }"
												data-product-hits="${user_sales_product.product_hits }"
												data-product-status="${user_sales_product.product_status }"
												data-category-name="${categoryDTO.category_name }"
							>
								<td width="20%">
									<img src="<%=request.getContextPath() %>resources/upload/${imgList[0]}" width="80" height="80">
								</td>
								
								<td width="30%">
									<b>${user_sales_product.product_title }</b><br><br>
									<b>판매물품 : </b>${user_sales_product.product_name }
								</td>
								
								<td class="product-info" width="50%">
									<span class="info-span"><b>등록일 : </b><fmt:formatDate value="${user_sales_product.product_date }" /></span>
									<span class="info-span"><b>판매상태 : </b>
										<c:if test="${user_sales_product.product_status == '판매중'}">
											<span class="status-blue">${user_sales_product.product_status }</span>
										</c:if>
										
										<c:if test="${user_sales_product.product_status == '예약중'}">
											<span class="status-red">${user_sales_product.product_status }</span>
										</c:if>
										
										<c:if test="${user_sales_product.product_status == '판매완료'}">
											<span class="status-gray">${user_sales_product.product_status }</span>
										</c:if>
									</span>
									<b>조회수 : </b>${user_sales_product.product_hits }
								</td>
							</tr>
						</c:if>
					</c:forEach>
					
				</c:forEach>
			
			</table>
		</div>
		
		<div class="pagination-wrapper" align="center">
		        <div class="pagination">
		            <c:if test="${paging.page > paging.block}">
		                <a href="user_sales_product_list.go?page=1" class="page-btn first">처음</a>
		                <a href="user_sales_product_list.go?page=${paging.startBlock - 1}" class="page-btn">◀</a>
		            </c:if>
		
		            <c:forEach begin="${paging.startBlock}" end="${paging.endBlock}" var="i">
		                <c:choose>
		                    <c:when test="${i == paging.page}">
		                        <a href="user_sales_product_list.go?page=${i}" class="page-btn active">${i}</a>
		                    </c:when>
		             
		                    <c:otherwise>
		                        <a href="user_sales_product_list.go?page=${i}" class="page-btn">${i}</a>
		                    </c:otherwise>
		                </c:choose>
		            </c:forEach>
		
		            <c:if test="${paging.endBlock < paging.allPage}">
		                <a href="user_sales_product_list.go?page=${paging.endBlock + 1}" class="page-btn">▶</a>
		                <a href="user_sales_product_list.go?page=${paging.allPage}" class="page-btn last">마지막</a>
		            </c:if>
		        </div>
		    </div>
		
	</div>
	
	<jsp:include page="include/footer.jsp" />
	
	<div id="product_modal" style="display : none;">
		<div id="product_content"></div>
	</div>
	
	<div id="product_modify_modal" style="display : none;">
		<div id="product_modify"></div>
	</div>

</body>
</html>