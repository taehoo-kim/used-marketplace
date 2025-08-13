<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원정보 수정</title>

<script>
// 실시간 검사(클라이언트 검사)
document.addEventListener("DOMContentLoaded", function() {    
    const passwordInput = document.getElementById("user_pwd");
    const confirmInput = document.getElementById("user_pwd_confirm");    
    const pwdMessage = document.getElementById("pwd_check_result");
    const pwdConfirmMessage = document.getElementById("pwd_confirm_result");
    const nameInput = document.getElementById("user_name");
    const nameMessage = document.getElementById("name_check_result");
    const nicknameInput = document.getElementById("user_nickname");
    const nicknameMessage = document.getElementById("nickname_check_result");

    
    const pwdRegex = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[\W_]).{8,16}$/;
    const nameRegex = /^[가-힣]+$/; 
    

    // 비밀번호 유효성 검사 (비밀번호 입력 없으면 검사 X)
    passwordInput.addEventListener("input", function() {
        if (passwordInput.value.length === 0) {
            pwdMessage.innerText = "";
            pwdConfirmMessage.innerText = "";
            return;
        }
        if (!pwdRegex.test(passwordInput.value)) {
            pwdMessage.innerText = "비밀번호는 8~16자리이면서 영문자, 숫자, 특수문자를 모두 포함해야 합니다.";
            pwdMessage.style.color = "red";
        } else {
            pwdMessage.innerText = "사용 가능한 비밀번호입니다.";
            pwdMessage.style.color = "blue";
        }
        checkPasswordConfirm();
    });

    confirmInput.addEventListener("input", checkPasswordConfirm);

    function checkPasswordConfirm() {
        if (confirmInput.value.length === 0) {
            pwdConfirmMessage.innerText = "";
            return;
        }
        if (passwordInput.value === confirmInput.value) {
            pwdConfirmMessage.innerText = "비밀번호가 일치합니다.";
            pwdConfirmMessage.style.color = "blue";
        } else {
            pwdConfirmMessage.innerText = "비밀번호가 일치하지 않습니다.";
            pwdConfirmMessage.style.color = "red";
        }
    }

    // 이름 유효성 검사
    nameInput.addEventListener("input", function() {
        if (nameInput.value.length === 0) {
            nameMessage.innerText = "";
            return;
        }
        if (!nameRegex.test(nameInput.value)) {
            nameMessage.innerText = "이름은 한글만 입력 가능합니다.";
            nameMessage.style.color = "red";
        } else {
            nameMessage.innerText = "";
        }
    });

    // 닉네임 유효성 검사
    nicknameInput.addEventListener("input", function() {
        if (nicknameInput.value.length === 0) {
            nicknameMessage.innerText = "";
            return;
        }
        const nicknameRegex = /^[가-힣a-zA-Z0-9_]{2,20}$/;
        if (!nicknameRegex.test(nicknameInput.value)) {
            nicknameMessage.innerText = "닉네임은 2~20자, 한글, 영문, 숫자, _만 가능합니다.";
            nicknameMessage.style.color = "red";
        } else {
            nicknameMessage.innerText = "";
        }
    });

    // 이메일 직접입력 
    document.querySelector("select[name='email_domain']").addEventListener("change", function() {
        const customInput = document.getElementById("email_custom");
        if (this.value === "direct") {
            customInput.style.display = "inline";
        } else {
            customInput.style.display = "none";
            customInput.value = "";
        }
    });
});

// 닉네임 중복 검사
function checkNicknameDuplicate() {
    const nickname = document.getElementById("user_nickname").value.trim();
    const nicknameResult = document.getElementById("nickname_check_result");

    if (nickname.length === 0) {
        nicknameResult.innerText = "닉네임을 입력해주세요.";
        nicknameResult.style.color = "red";
        return;
    }

    fetch("/check_nickname.go?user_nickname=" + encodeURIComponent(nickname))
        .then(response => response.text())
        .then(result => {
            nicknameResult.innerText = result;
            nicknameResult.style.color = result.includes("사용 가능한") ? "blue" : "red";
        })
        .catch(() => {
            nicknameResult.innerText = "서버 오류 발생";
            nicknameResult.style.color = "red";
        });
}
</script>

</head>
<body>

    <div>
        <jsp:include page="include/header.jsp" />
    </div>

    <div>

        <div align="center">
            <a href="user_sales_product_list.go">판매글 목록</a>
            <a href="user_my_chat.go">메세지 목록</a>
        </div>

        <h2 align="center">회원정보 수정</h2>
        <form method="post" action="/user_update_ok.go" >

            <table border="1" width="600" align="center">
                <tr>
                    <th>아이디</th>
                    <td>
                        <input type="text" name="user_id" id="user_id" value="${user.user_id}" readonly>
                    </td>
                </tr>
                <tr>
                    <th>닉네임</th>
                    <td>
                        <input type="text" name="user_nickname" id="user_nickname" maxlength="20" value="${user.user_nickname}" required>
                        <button type="button" onclick="checkNicknameDuplicate()">중복확인</button>
                        <div id="nickname_check_result" style="margin-top: 5px;"></div>
                    </td>
                </tr>
                <tr>
                    <th>비밀번호</th>
                    <td>
                        <input type="password" name="user_pwd" id="user_pwd" placeholder="변경 시에만 입력">
                        <div id="pwd_check_result" style="margin-top: 5px;"></div>
                    </td>
                </tr>
                <tr>
                    <th>비밀번호 확인</th>
                    <td>
                        <input type="password" name="user_pwd_confirm" id="user_pwd_confirm" placeholder="변경 시에만 입력">
                        <div id="pwd_confirm_result" style="margin-top: 5px;"></div>
                    </td>
                </tr>
                <tr>
                    <th>이름</th>
                    <td>
                        <input type="text" name="user_name" id="user_name" value="${user.user_name}" required>
                        <div id="name_check_result" style="margin-top:5px;"></div>
                    </td>
                </tr>
                <tr>
                    <th>나이</th>
                    <td><input type="number" name="user_age" value="${user.user_age}" required></td>
                </tr>
                <tr>
                    <th>이메일</th>
                    <td>
                        <input type="text" name="email_id" value="${emailId}" required> @
                        <select name="email_domain" required>
                            <option value="">--선택--</option>
                            <option value="naver.com" ${emailDomain=='naver.com' ? 'selected' : ''}>naver.com</option>
                            <option value="gmail.com" ${emailDomain=='gmail.com' ? 'selected' : ''}>gmail.com</option>
                            <option value="hanmail.net" ${emailDomain=='hanmail.net' ? 'selected' : ''}>hanmail.net</option>
                            <option value="daum.net" ${emailDomain=='daum.net' ? 'selected' : ''}>daum.net</option>
                            <option value="nate.com" ${emailDomain=='nate.com' ? 'selected' : ''}>nate.com</option>
                            <option value="direct" ${emailDomain=='direct' ? 'selected' : ''}>직접입력</option>
                        </select>
                        <input type="text" name="email_custom" id="email_custom" value="${emailCustom}" style="display: ${emailDomain=='direct' ? 'inline' : 'none'};">
                    </td>
                </tr>
                <tr>
                    <th>전화번호</th>
                    <td>
                        <select name="phone1" required>
                            <option value="010" ${phone1=='010' ? 'selected' : ''}>010</option>
                            <option value="011" ${phone1=='011' ? 'selected' : ''}>011</option>
                            <option value="016" ${phone1=='016' ? 'selected' : ''}>016</option>
                        </select> -
                        <input type="text" name="phone2" maxlength="4" minlength="3" pattern="\d{3,4}" placeholder="3~4자리 숫자만 입력하세요" value="${phone2}" required> -
                        <input type="text" name="phone3" maxlength="4" minlength="4" pattern="\d{4}" placeholder="4자리 숫자만 입력하세요" value="${phone3}" required>
                    </td>
                </tr>
                <tr>
                    <th>우편번호</th>
                    <td>
                        <input type="text" name="user_zipcode" id="user_zipcode" value="${user.user_zipcode}" readonly required>
                        <button type="button" onclick="openPostcode()">주소 검색</button>
                    </td>
                </tr>
                <tr>
                    <th>기본주소</th>
                    <td><input type="text" name="user_addr_base" id="user_addr_base" value="${user.user_addr}" readonly required></td>
                </tr>
                <tr>
                    <th>상세주소</th>
                    <td><input type="text" name="user_addr_detail" id="user_addr_detail" value="${user.user_addr_detail}" required></td>
                </tr>
            </table>

            <div align="center">
                <input type="submit" value="회원정보 수정">
                <input type="reset" value="초기화">
            </div>
        </form>

    </div>

    <div>
        <jsp:include page="include/footer.jsp" />
    </div>

<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script>
function openPostcode() {
    new daum.Postcode({
        oncomplete: function(data) {
            document.getElementById('user_zipcode').value = data.zonecode;
            document.getElementById('user_addr_base').value = data.address;
            document.getElementById('user_addr_detail').focus();
        }
    }).open();
}
</script>

</body>
</html>