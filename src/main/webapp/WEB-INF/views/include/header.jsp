<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>


<meta charset="UTF-8">
<title>중고 거래 사이트</title>
<style>
    .header {
        margin: 0;
        padding: 16px 40px;
        background-color: #ffffff;
        border-bottom: 1px solid #e0e0e0;
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-family: 'Segoe UI', sans-serif;
        position: sticky;
        top: 0;
        z-index: 1000;
    }

    .header-title h1 {
        font-size: 35px;
        color: #2b7cff;
        margin: 0;
        cursor: pointer;
        transition: 0.3s ease;
    }

    .header-title h1:hover {
        opacity: 0.8;
    }

    .main-btn {
        display: flex;
        gap: 12px;
    }

    .main-btn button {
        background-color: transparent;
        border: 1px solid #2b7cff;
        padding: 7px 16px;
        border-radius: 6px;
        font-size: 14px;
        color: #2b7cff;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.25s ease;
    }

    .main-btn button:hover {
        background-color: #2b7cff;
        color: white;
    }

    @media screen and (max-width: 768px) {
        .header {
            flex-direction: column;
            align-items: flex-start;
            gap: 12px;
            padding: 20px;
        }

        .header-title h1 {
            font-size: 24px;
        }

        .main-btn {
            flex-wrap: wrap;
        }
    }
</style>


    <div class="header">
        <div class="header-title">
            <h1 onclick="location.href='/'">중고마켓</h1>
        </div>
        <div id="user-location" style="font-weight: bold; margin: 10px 20px;"></div>
        <div class="main-btn">
            <button onclick="location.href='/'">HOME</button>
            <button onclick="location.href='product_sales.go'">물품 판매</button>
            <button onclick="location.href='user_my_page.go'">마이페이지</button>
        </div>
    </div>
    
    
    <c:otherwise>
            <div class="login-area">
                       
                <form method="post" action="login.go" style="display: flex; gap: 10px; align-items: center;">
                    <div class="login-input">
                        <input type="text" name="userId" placeholder="아이디" required />
                        <input type="password" name="userPwd" placeholder="비밀번호" required />
                    </div>
                    <div class="login-buttons">
                        <button type="submit">로그인</button>
                        <button type="button" onclick="location.href='sign_up.go'">회원가입</button>
                    </div>
                </form>
                
            </div>
        </c:otherwise>
    
     <script>
        function initMap() {
            console.log("Google Maps API loaded.");

            const locDiv = document.getElementById("user-location");
            console.log("locationEl (at initMap start):", locDiv); // initMap 시작 시 요소 확인

            if (locDiv) {
                locDiv.textContent = "현재 위치: 위치 정보를 가져오는 중..."; // 로딩 메시지
            }

            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(
                    pos => {
                        const lat = pos.coords.latitude;
                        const lng = pos.coords.longitude;
                        console.log("위치 정보:", lat, lng);
                        getAddressFromCoords(lat, lng);
                    },
                    err => {
                        console.error("위치 접근 실패:", err.message);
                        if (locDiv) {
                            locDiv.textContent = `위치 정보 접근 실패: ${err.message}`;
                            if (err.code === err.PERMISSION_DENIED) {
                                locDiv.textContent = "위치 정보 접근이 거부되었습니다. 브라우저 설정에서 위치 권한을 허용해주세요.";
                            }
                        }
                    },
                    { enableHighAccuracy: true, timeout: 5000, maximumAge: 0 } // 위치 옵션 추가
                );
            } else {
                if (locDiv) {
                    locDiv.textContent = "현재 브라우저에서 위치 정보 기능을 지원하지 않습니다.";
                }
            }
        }

        function getAddressFromCoords(lat, lng) {
            const geocoder = new google.maps.Geocoder();
            const latlng = { lat: parseFloat(lat), lng: parseFloat(lng) };
            const locationEl = document.getElementById("user-location");

            geocoder.geocode({ location: latlng }, (results, status) => {
                if (status === "OK" && results.length > 5) {
                    let fullAddress = results[5].formatted_address;
                    fullAddress = fullAddress.replace('대한민국 ', '');
                    if (locationEl) {
                        locationEl.innerHTML = "현재 위치: <strong>" + fullAddress + "</strong>";
                        // 전역변수에 저장 (여기서 바로)
                        window.userLocationFullAddress = fullAddress;
                    }
                } else {
                	  console.error("Geocoder failed:", status);
                }
            });
        }

        
        
       
        // 위치 텍스트가 "현재 위치: 경기도 고양시 일산동구 정발산동" 형식일 때
        function getUserLocationText() {
          const locEl = document.getElementById('user-location');
          if (!locEl) return null;
          const text = locEl.textContent || locEl.innerText || "";
          // "현재 위치: " 이후 문자열만 추출
          const prefix = "현재 위치: ";
          if (text.startsWith(prefix)) {
            return text.substring(prefix.length).trim();
          }
          return null;
        }
        // 전역변수로 노출
        window.userLocationFullAddress = getUserLocationText();
      

    </script>

    <script
      src="https://maps.googleapis.com/maps/api/js?key=AIzaSyC6GZL5JoPGTDsQqjhGD-dgKj7hRQSTxfE&callback=initMap"
      async defer>
    </script>
