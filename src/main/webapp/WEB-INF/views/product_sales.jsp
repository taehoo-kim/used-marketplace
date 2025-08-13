<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
  
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

    .body {
        max-width: 900px;
        margin: 40px auto;
        background-color: #ffffff;
        padding: 30px;
        border-radius: 10px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
    }

    .tbl table {
        width: 100%;
        border-collapse: collapse;
        font-size: 15px;
    }

    .tbl th, .tbl td {
        padding: 12px 16px;
        border: 1px solid #d9d9d9;
        text-align: left;
    }

    .tbl th {
        background-color: #f0f4f9;
        width: 160px;
        font-weight: 600;
    }

    .tbl input[type="text"],
    .tbl input[type="file"],
    .tbl textarea,
    .tbl select {
        width: 100%;
        padding: 10px 12px;
        font-size: 14px;
        color: #2a2a2a;
        background-color: #fafcff;
        border: 1px solid #ccd9ee;
        border-radius: 6px;
        box-sizing: border-box;
        outline: none;
        transition: border 0.2s ease, box-shadow 0.2s ease;
        font-family: 'Segoe UI', sans-serif;
    }

    .tbl input:focus,
    .tbl textarea:focus,
    .tbl select:focus {
        border-color: #2b7cff;
        box-shadow: 0 0 0 3px rgba(43, 124, 255, 0.15);
    }

    .tbl textarea {
        resize: vertical;
        min-height: 100px;
    }

    .tbl input[type="file"] {
        background-color: #f8fafd;
        border: 1px dashed #bcd2f5;
        padding: 10px;
        cursor: pointer;
    }

    .tbl input::placeholder,
    .tbl textarea::placeholder {
        color: #aaa;
        font-style: italic;
    }

    .btn {
        margin-top: 30px;
        text-align: center;
    }

    .btn button {
        background-color: #e6f0ff;
        border: none;
        padding: 10px 20px;
        border-radius: 6px;
        font-size: 14px;
        color: #2b7cff;
        cursor: pointer;
        margin: 0 12px;
        transition: background-color 0.2s ease;
    }

    .btn button:hover {
        background-color: #d0e4ff;
    }

    .sm-text {
        color: #888;
        font-size: 13px;
        margin-top: 6px;
        display: inline-block;
    }
</style>


<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script type="text/javascript">

    $(document).ready(function() {
        $("#upload").on("submit", function (e) {
            const files = $("input[name='product_img_File[]']")[0].files;

            if(files.length > 3) {
            	alert("사진은 최대 3개까지만 업로드할 수 있습니다.");
                e.preventDefault();
            }
            
            if($("select[name='category_code']").val() == 'none') {
            	alert("물품의 카테고리를 설정해주세요.");
                e.preventDefault();
            }
            
            if($("input[name='user_id']").val() == "" || $("input[name='sales_area']").val() == "") {
            	alert("세션이 만료되었습니다. 다시 로그인 해주세요.");
            	e.preventDefault();
            	location.href="/";
            }
            
        });
        
        $("#free").on("change", function () {
            if($(this).is(":checked")) {
                $("input[name='sales_price']").val("0").prop("readonly", true);
            } else {
                $("input[name='sales_price']").val("").prop("readonly", false);
            }
        });
    });
    
</script>

<title>Insert title here</title>
</head>
<body>
	
	<div class="main-bar">
		<jsp:include page="include/header.jsp" />
	</div>
	
	<div class="body" align="center">
		<c:set var="cList" value="${categoryList}" />
		<c:set var="userDTO" value="${sessionScope.user }" />
		
		<form id="upload" method="post" enctype="multipart/form-data"
			action="<%=request.getContextPath() %>/product_sales_ok.go">
		
			<div class="tbl">
				<input type="hidden" name="user_id" value="${userDTO.user_id }">
				<input type="hidden" name="sales_area" value="${userDTO.user_addr }">
				
				<table border="1" width="800">
					<tr>
						<th>판매 글 제목</th>
						<td colspan="3"><input type="text" name="product_title" required></td>
					</tr>
				
					<tr>
						<th>물품 카테고리</th>
						<td>
							<select name="category_code">
								<option value="none">:::카테고리 선택:::</option>
								<c:forEach var="category_dto" items="${cList}">
									<option value="${category_dto.category_code }">${category_dto.category_name }</option>
								</c:forEach>
							</select>
						</td>
						
						<th>물품명</th>
						<td><input type="text" name="product_name" required></td>
					</tr>
					
					<tr>
						<th>물품 설명</th>
						<td colspan="3"><textarea rows="5" cols="30" name="product_des" required></textarea></td>
					</tr>
					
					<tr>
						<th>물품 이미지</th>
						<td colspan="3">
							<input type="file" name="product_img_File[]" multiple="multiple">
							<small class="sm-text">사진은 최대 3개까지만 업로드할 수 있습니다.</small>
						</td>
					</tr>
					
					<tr>
						<th>판매 가격</th>
						<td colspan="2"><input type="text" name="sales_price" required></td>
						<td><input type="checkbox" id="free">무료나눔</td>
					</tr>
				
				</table>
			</div>
			
			<div class="btn">
				<button type="submit">물품 등록</button>
				<button type="button" onclick="location.href='/'">등록 취소</button>
			</div>
		
		</form>
		
	</div>
	
	<jsp:include page="include/footer.jsp" />

</body>
</html>