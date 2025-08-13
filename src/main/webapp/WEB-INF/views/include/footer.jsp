<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
	.footer {
	    background-color: #E6F0FF;
	    border-top: 1px solid #e0e0e0;
	    padding: 40px 0;
	    margin-top: 50px;
	    font-size: 14px;
	    color: #555;
	}
	
	.footer-inner {
	    width: 90%;
	    max-width: 1200px;
	    margin: auto;
	    display: flex;
	    justify-content: space-between;
	    flex-wrap: wrap;
	}
	
	.footer-left h3 {
	    font-size: 20px;
	    color: #2b7cff;
	    margin-bottom: 8px;
	}
	
	.footer-left p {
	    margin: 4px 0;
	}
	
	.footer-links {
	    display: flex;
	    gap: 60px;
	}
	
	.footer-links h4 {
	    margin-bottom: 10px;
	    font-size: 15px;
	    color: #333;
	}
	
	.footer-links ul {
	    list-style: none;
	    padding: 0;
	}
	
	.footer-links li {
	    margin-bottom: 6px;
	}
	
	.footer-links a {
	    color: #555;
	    text-decoration: none;
	}
	
	.footer-links a:hover {
	    color: #2b7cff;
	    text-decoration: underline;
	}
	
	@media screen and (max-width: 768px) {
	    .footer-inner {
	        flex-direction: column;
	        gap: 30px;
	    }
	
	    .footer-links {
	        flex-direction: column;
	        gap: 30px;
	    }
	}
</style>

<title>Insert title here</title>
</head>
<body>

	<!-- footer.jsp -->
	<div class="footer">
	    <div class="footer-inner">
	        <div class="footer-left">
	            <h3>중고마켓</h3>
	            <p>믿을 수 있는 중고 거래 플랫폼</p>
	            <p>© 2025 JungGoMarket</p>
	        </div>
	
	        <div class="footer-links">
	            <div>
	                <h4>회사</h4>
	                <ul>
	                    <li><a href="#">회사소개</a></li>
	                    <li><a href="#">채용</a></li>
	                    <li><a href="#">제휴문의</a></li>
	                </ul>
	            </div>
	            <div>
	                <h4>고객지원</h4>
	                <ul>
	                    <li><a href="#">공지사항</a></li>
	                    <li><a href="#">자주 묻는 질문</a></li>
	                    <li><a href="#">문의하기</a></li>
	                </ul>
	            </div>
	            <div>
	                <h4>정책</h4>
	                <ul>
	                    <li><a href="#">이용약관</a></li>
	                    <li><a href="#">개인정보 처리방침</a></li>
	                    <li><a href="#">위치기반서비스 약관</a></li>
	                </ul>
	            </div>
	        </div>
	    </div>
	</div>

</body>
</html>