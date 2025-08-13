<%@ page language="java" contentType="text/html; charset=UTF-8" 
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원가입 페이지</title>

<script>
// 실시간 검사(클라이언트 검사)
document.addEventListener("DOMContentLoaded", function() {
    const userIdInput = document.getElementById("user_id");
    const passwordInput = document.getElementById("user_pwd");
    const confirmInput = document.getElementById("user_pwd_confirm");
    const idMessage = document.getElementById("check_result");
    const pwdMessage = document.getElementById("pwd_check_result");
    const pwdConfirmMessage = document.getElementById("pwd_confirm_result");
    const nameInput = document.getElementById("user_name");
    const nameMessage = document.getElementById("name_check_result");
    const nicknameInput = document.getElementById("user_nickname");
    const nicknameMessage = document.getElementById("nickname_check_result");

    const idRegex = /^[a-zA-Z0-9]{6,12}$/;
    const pwdRegex = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[\W_]).{8,16}$/;
    const nameRegex = /^[가-힣]+$/; 

    // 아이디 유효성 검사
    userIdInput.addEventListener("input", function() {
        if (userIdInput.value.length === 0) {
            idMessage.innerText = "";
            return;
        }
        if (!idRegex.test(userIdInput.value)) {
            idMessage.innerText = "아이디는 6~12자 영문과 숫자의 조합이어야 합니다.";
            idMessage.style.color = "red";
        } else {
            idMessage.innerText = "";
        }
    });

    // 비밀번호 유효성 검사
    passwordInput.addEventListener("input", function() {
        if (passwordInput.value.length === 0) {
            pwdMessage.innerText = "";
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

    // 이메일 도메인 직접입력 표시 제어
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

// 아이디 중복 검사
function checkDuplicate() {
    const userId = document.getElementById("user_id").value.trim();
    const checkResult = document.getElementById("check_result");

    if (userId.length === 0) {
        checkResult.innerText = "아이디를 입력해주세요.";
        checkResult.style.color = "red";
        return;
    }

    fetch("/check_id.go?user_id=" + encodeURIComponent(userId))
        .then(response => response.text())
        .then(result => {
            checkResult.innerText = result;
            checkResult.style.color = result.includes("사용 가능한") ? "blue" : "red";
        })
        .catch(() => {
            checkResult.innerText = "서버 오류 발생";
            checkResult.style.color = "red";
        });
}

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
        <h2 align="center">회원가입</h2>
        <form method="post" action="/sign_up_ok.go" >
            <table border="1" width="400" align="center">
                <tr>
                    <th>아이디</th>
                    <td>
                        <input type="text" name="user_id" id="user_id" required>
                        <button type="button" onclick="checkDuplicate()">중복확인</button>
                        <div id="check_result" style="margin-top: 5px;"></div>
                    </td>
                </tr>
                <tr>
                    <th>닉네임</th>
                    <td>
                        <input type="text" name="user_nickname" id="user_nickname" maxlength="20" required>
                        <button type="button" onclick="checkNicknameDuplicate()">중복확인</button>
                        <div id="nickname_check_result" style="margin-top: 5px;"></div>
                    </td>
                </tr>
                <tr>
                    <th>비밀번호</th>
                    <td>
                        <input type="password" name="user_pwd" id="user_pwd" required>
                        <div id="pwd_check_result" style="margin-top: 5px;"></div>
                    </td>
                </tr>
                <tr>
                    <th>비밀번호 확인</th>
                    <td>
                        <input type="password" name="user_pwd_confirm" id="user_pwd_confirm" required>
                        <div id="pwd_confirm_result" style="margin-top: 5px;"></div>
                    </td>
                </tr>
                <tr>
                    <th>이름</th>
                    <td>
                        <input type="text" name="user_name" id="user_name" required>
                        <div id="name_check_result" style="margin-top:5px;"></div>
                    </td>
                </tr>
                <tr>
                    <th>나이</th>
                    <td><input type="number" name="user_age" required></td>
                </tr>
                <tr>
                    <th>이메일</th>
                    <td>
                        <input type="text" name="email_id" placeholder="이메일 아이디" required> @
                        <select name="email_domain" required>
                            <option value="">--선택--</option>
                            <option value="naver.com">naver.com</option>
                            <option value="gmail.com">gmail.com</option>
                            <option value="hanmail.net">hanmail.net</option>
                            <option value="daum.net">daum.net</option>
                            <option value="nate.com">nate.com</option>
                            <option value="direct">직접입력</option>
                        </select>
                        <input type="text" name="email_custom" id="email_custom" style="display: none;">
                    </td>
                </tr>
                <tr>
                    <th>전화번호</th>
                    <td>
                        <select name="phone1" required>
                            <option value="010">010</option>
                            <option value="011">011</option>
                            <option value="016">016</option>
                        </select> -
                        <input type="text" name="phone2" maxlength="4" minlength="3" pattern="\d{3,4}" placeholder="3~4자리 숫자만 입력하세요" required> -
                        <input type="text" name="phone3" maxlength="4" minlength="4" pattern="\d{4}" placeholder="4자리 숫자만 입력하세요" required>
                    </td>
                </tr>
                <tr>
                    <th>우편번호</th>
                    <td>
                        <input type="text" name="user_zipcode" id="user_zipcode" readonly required>
                        <button type="button" onclick="openPostcode()">주소 검색</button>
                    </td>
                </tr>
                <tr>
                    <th>기본주소</th>
                    <td><input type="text" name="user_addr_base" id="user_addr_base" readonly required></td>
                </tr>
                <tr>
                    <th>상세주소</th>
                    <td><input type="text" name="user_addr_detail" id="user_addr_detail" required></td>
                </tr>
                <tr>
                    <td colspan="2" align="center">
                        <input type="submit" value="가입하기">
                        <input type="reset" value="다시작성">
                    </td>
                </tr>
            </table>
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