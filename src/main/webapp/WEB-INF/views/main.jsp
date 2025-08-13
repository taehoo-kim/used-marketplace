<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %> 
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>중고 전자기기 목록</title>
<style>
    body {
	    font-family: 'Segoe UI', sans-serif;
	    background-color: #f4f7fb;
	    margin: 0;
	    padding: 0;
	}
	
	.main-bar {
	    background-color: white;
	    border-bottom: 1px solid #ddd;
	    padding: 16px 20px;
	}
	
	.main-container {
	    display: flex;
	}


    .sidebar {
        width: 15%;
        padding: 20px;
        background-color: #ffffff;
        border-right: 1px solid #ddd;
        overflow-y: auto;
    }

    .sidebar h3 {
        font-size: 16px;
        margin-bottom: 10px;
    }

    .sidebar label {
        display: block;
        margin-bottom: 6px;
        font-size: 14px;
    }

    .content {
        flex: 1;
        padding: 20px;
    }

    .top-bar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
    }

    .search-bar input[type="text"] {
        width: 250px;
        padding: 8px 12px;
        border: 1px solid #ccc;
        border-radius: 5px;
    }

    .search-bar input[type="submit"] {
        padding: 8px 16px;
        background-color: #2b7cff;
        color: white;
        border: none;
        border-radius: 5px;
        margin-left: 8px;
        cursor: pointer;
    }

    .product-count {
        font-size: 15px;
        color: #555;
        margin-right: 10px;
    }

    .product-count strong {
        color: #2b7cff;
    }

    .product-list {
        display: flex;
        flex-wrap: wrap;
        gap: 20px;
    }

    .product-card {
        width: calc(20% - 20px);
        background: white;
        border-radius: 10px;
        display: flex;
        flex-direction: column;
        padding: 12px;
        box-shadow: 1px 2px 5px rgba(0,0,0,0.05);
        transition: 0.2s ease;
        box-sizing: border-box;
    }

    .product-img {
        width: 100%;
        height: 200px;
        border-radius: 8px;
        object-fit: cover;
        border: 1px solid #ddd;
    }

    .product-info {
        margin-top: 10px;
    }

    .product-info a {
        font-size: 18px;
        font-weight: 600;
        color: #2a2a2a;
        text-decoration: none;
        display: block;            
		width: 100%;               
		white-space: nowrap;     
		overflow: hidden;        
		text-overflow: ellipsis;   
    }

    .product-info a:hover {
        text-decoration: underline;
    }
    
    

    .product-meta {
        color: #666;
        font-size: 14px;
        margin-top: 6px;
        display: block;            
		width: 100%;               
		white-space: nowrap;     
		overflow: hidden;        
		text-overflow: ellipsis;   
    }

    .product-price {
        font-weight: bold;
        margin-top: 4px;
        font-size: 16px;
        color: #4e8fe1;
    }

    .settings-btn {
        background-color: #dbe7ff;
        border: none;
        padding: 8px 16px;
        border-radius: 5px;
        cursor: pointer;
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
	
	.sold-out {
	    opacity: 0.4;
	    filter: grayscale(70%);
	}
	
	.status-overlay {
	    position: absolute;
	    top: 50%;
	    left: 50%;
	    transform: translate(-50%, -50%);
	    font-weight: bold;
	    font-size: 18px;
	    padding: 4px 12px;
	    border-radius: 6px;
	    background-color: rgba(255, 255, 255, 0.8);
	}
	
	.sold-text {
	    color: red;
	}
	
	.reserved-text {
	    color: green;
	}

    .product-card:hover {
	    background-color: #eef4ff;
	    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
	}

</style>

<!-- Google Maps API 불러오기 -->

<script
  src="https://maps.googleapis.com/maps/api/js?key=AIzaSyC6GZL5JoPGTDsQqjhGD-dgKj7hRQSTxfE&callback=initMap"
  async defer>
</script>

<script>
  // 구글 맵 API 콜백 (API 로딩 완료 시 실행)
  function initMap() {
    console.log("Google Maps API loaded.");

    // 위치 정보 요청
    navigator.geolocation.getCurrentPosition(
      pos => {
        const lat = pos.coords.latitude;
        const lng = pos.coords.longitude;

        // 1. 위도, 경도 텍스트 출력 (초기 위치 정보)
        document.getElementById("user-location").textContent = `현재 위치: 위도 ${lat.toFixed(6)}, 경도 ${lng.toFixed(6)}`;

        // 2. 좌표로 구 이름 가져오기
        getGuFromCoords(lat, lng);
      },
      err => {
        console.error("위치 접근 실패:", err.message);
        document.getElementById("user-location").textContent = `위치 정보 접근 실패: ${err.message}`;
        document.getElementById("location-checkbox-area").textContent = "위치 정보를 가져올 수 없습니다.";
      }
    );
  }

  // 위도, 경도로 행정구(구) 이름을 받아와서 출력 + 체크박스 생성
  function getGuFromCoords(lat, lng) {
    const geocoder = new google.maps.Geocoder();
    const latlng = { lat: parseFloat(lat), lng: parseFloat(lng) };

    geocoder.geocode({ location: latlng }, (results, status) => {
      if (status === "OK" && results[0]) {
        const addressComponents = results[0].address_components;
        let gu = null;

        for (const component of addressComponents) {
          if (
            component.types.includes("sublocality_level_1") && 
            component.long_name.endsWith("구")
          ) {
            gu = component.long_name.trim();
            break;
          }
        }

        if (gu) {
          // user-location 텍스트를 구 이름으로 업데이트
          document.getElementById("user-location").textContent = `현재 위치 : ${gu}`;

          // 체크박스 생성
          const container = document.getElementById("location-checkbox-area");
          container.innerHTML = "";

          const label = document.createElement("label");
          const checkbox = document.createElement("input");
          checkbox.type = "checkbox";
          checkbox.name = "area";
          checkbox.value = gu;
          checkbox.checked = true;

          label.appendChild(checkbox);
          label.appendChild(document.createTextNode(" " + gu));
          container.appendChild(label);

          console.log("체크박스 생성 완료:", checkbox.outerHTML);
        } else {
          document.getElementById("location-checkbox-area").textContent = "구 단위 주소를 찾을 수 없습니다.";
        }
      } else {
        document.getElementById("location-checkbox-area").textContent = `주소를 찾을 수 없습니다. 상태: ${status}`;
      }
    });
  }
</script>

</head>
<body>

		<jsp:include page="include/header.jsp" />
	
	<div class="main-container">
		<div class="sidebar">
		
		    <form method="get" action="secondhand_list.go">
		      <h3>지역 선택</h3>
				<c:forEach var="a" items="${areas}">
				    <label>
				        <input type="radio" name="area" value="${a}"
				               onchange="this.form.submit()"
				               <c:if test="${area == a}">checked</c:if>> ${a}
				    </label>
				</c:forEach>

		        <hr>
		        <h3>카테고리</h3>
		        <c:forEach var="c" items="${category}">
		            <label>
		                <input type="radio" name="category" value="${c.category_code}" onchange="this.form.submit()">
		                <c:if test="${empty selectedCategory and empty c.category_code}">checked</c:if>  
		                <c:if test="${selectedCategory == c.category_code }">checked</c:if>
		                ${c.category_name}
		            </label>
		        </c:forEach>
		        
		        <hr>

		        <h3>가격 범위</h3>
		        <input type="number" name="minPrice" placeholder="최소가격" value="${minPrice}" style="width: 33%; margin-bottom: 8px;" /> ~
		        <input type="number" name="maxPrice" placeholder="최대가격" value="${maxPrice}" style="width: 33%; margin-bottom: 8px;" />
		
		        <input type="submit" value="가격 검색" style="margin-top: 10px; width: 50%; background-color: #2b7cff; color: white; border: none; padding: 5px; border-radius: 6px; cursor: pointer;"/>
				        
		    </form>
		</div>
		
		<div class="content">
		
		    <h1>중고 전자기기</h1>
		
		    <div class="top-bar">
		        <form class="search-bar" method="get" action="secondhand_list.go">
		            <input type="text" name="keyword" placeholder="제품명을 입력하세요">
		            <input type="submit" value="검색">
		        </form>
		
		        <div style="display: flex; align-items: center; gap: 20px;">
		            <div class="product-count">총 <strong>${paging.totalRecord}</strong>개 상품</div>
		        </div>
		    </div>
		
		    <div class="product-list">
		        <c:forEach var="p" items="${productList}">
		        	<c:set var="imgList" value="${fn:split(p.product_img, ',')}" />
		            <div class="product-card" onclick="location.href='product_detail.go?product_num=${p.product_num}'" style="cursor: pointer;">
					    <div class="product-img-wrapper">
					        <img src="<%=request.getContextPath() %>/resources/upload/${imgList[0]}" width="260px" height="260px"
					             class="<c:if test='${p.product_status == "판매완료"}'>sold-out</c:if>">
					        
					        <c:choose>
					            <c:when test="${p.product_status == '판매완료'}">
					                <div class="status-overlay sold-text">판매완료</div>
					            </c:when>
					            <c:when test="${p.product_status == '예약중'}">
					                <div class="status-overlay reserved-text">예약중</div>
					            </c:when>
					        </c:choose>
					    </div>
					
					    <div class="product-info">
					        <a href="product_detail.go?product_num=${p.product_num}">${p.product_title}</a>
					        <fmt:formatDate value="${p.product_date}" pattern="YYYY-MM-dd · a h:mm" var="formattedTime" />
					        <div class="product-meta">${p.sales_area}</div>
					        <div class="product-meta">${formattedTime}</div>
					        <div class="product-price">
					            <c:choose>
					                <c:when test="${p.sales_price == 0}">
					                    무료 나눔
					                </c:when>
					                <c:otherwise>
					                    <fmt:formatNumber value="${p.sales_price}" type="number" />원
					                </c:otherwise>
					            </c:choose>
					        </div>
					    </div>
					</div>
					
		        </c:forEach>
		    </div>
		
		    <br><br>
		
		    <div class="pagination-wrapper" align="center">
		        <div class="pagination">
		            <c:if test="${paging.page > paging.block}">
		                <a href="?page=1" class="page-btn first">처음</a>
		                <a href="?page=${paging.startBlock - 1}" class="page-btn">◀</a>
		            </c:if>
		
		            <c:forEach begin="${paging.startBlock}" end="${paging.endBlock}" var="i">
		                <c:choose>
		                    <c:when test="${i == paging.page}">
		                        <a href="?page=${i}" class="page-btn active">${i}</a>
		                    </c:when>
		             
		                    <c:otherwise>
		                        <a href="?page=${i}" class="page-btn">${i}</a>
		                    </c:otherwise>
		                </c:choose>
		            </c:forEach>
		
		            <c:if test="${paging.endBlock < paging.allPage}">
		                <a href="?page=${paging.endBlock + 1}" class="page-btn">▶</a>
		                <a href="?page=${paging.allPage}" class="page-btn last">마지막</a>
		            </c:if>
		        </div>
		    </div>
		
		</div>
	</div>

	<jsp:include page="include/footer.jsp" />

</body>
</html>