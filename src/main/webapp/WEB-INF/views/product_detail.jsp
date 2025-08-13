<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
<style>

	#chat_modal, #report_modal {
        display: none;
        position: fixed;
        z-index: 1000;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.7);
    }

    #chat_room, #report_table {
        background-color: white;
        margin: 8% auto;
        padding: 30px;
        border-radius: 16px;
        width: 500px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        position: relative;
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
	
	.chat-msg {
        margin: 5px 0;
        padding: 8px 12px;
        border-radius: 10px;
        max-width: 70%;
        clear: both;
    }

    .chat-msg.me {
        background-color: #dcf8c6;
        float: right;
        text-align: right;
    }

    .chat-msg.other {
        background-color: #f1f0f0;
        float: left;
        text-align: left;
    }

    .chat-meta {
        font-size: 11px;
        color: #888;
        margin-top: 4px;
    }

    #chat_window::after {
        content: "";
        display: block;
        clear: both;
    }

	#commentList {
        margin-top: 20px;
    }
    .comment-box {
        background-color: #f0f0f0; 
        padding: 10px 15px;
        margin-bottom: 12px;
        border-radius: 5px;
        width: 80%;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        position: relative;
    }
    .comment-user {
        font-weight: bold;
        margin-bottom: 4px;
        font-size: 1.1em;
        color: #333;
    }
    .comment-content {
        margin-bottom: 8px;
        font-size: 1em;
        color: #222;
        white-space: pre-wrap; 
    }
    
    .comment-date {
        font-size: 0.85em;
        color: #666;
        text-align: left;
        font-family: 'Courier New', Courier, monospace;
    }
    
    .comment-actions { 
    	position: absolute; 
    	top: 10px; 
    	right: 10px; 
    }
    
    .comment-actions { 
	    position: absolute; 
	    top: 10px; 
	    right: 10px; 
	}
	
	.comment-actions button { 
	    margin-left: 5px; 
	}

</style>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script type="text/javascript">
	
	const loggedInUserId = "${user.user_id}";
	
	$(document).ready(function() {
		
		loadComments();
		
		$("#chat_btn").click(function() {
			
			let seller_id = $(this).data("sellerId");
			let buyer_id = $(this).data("buyerId");
			let product_num = $(this).data("productNum");
            let chat_room_num = $(this).data("chat-room-num")
			
			if(buyer_id == "") {
				alert("로그인이 필요한 서비스입니다.");
				return;
			}else {
				openChatModal(seller_id, buyer_id, product_num, chat_room_num);
			}
		});
		
		
		$("#report_btn").click(function() {
			
			let reported_user_id = $(this).data("reportedUserId");
			let reporter_id = $(this).data("reporterId");
			let product_num = $(this).data("productNum");
			
			if(reporter_id == "") {
				alert("로그인이 필요한 서비스입니다.");
				return;
			}else {
				openReportModal(reported_user_id, reporter_id, product_num);	
			}
		});
		
		
	    $('#addCommentBtn').click(function() {
	    	
	    	let product_num = $(this).data("productNum");
	    	let user_id = $(this).data("userId");
	    	let comment_content = document.getElementById("comment_content").value.trim();
	
	    	if(user_id == "") {
	    		alert("로그인이 필요한 서비스입니다.");
	    		return;
	    	}
	    	
	        if(comment_content === "") {
	            alert("댓글 내용을 입력하세요.");
	            return;
	        }
	
	        $.post('product_comment_insert.go', {product_num:product_num,
	        									 user_id:user_id,
	        									 comment_content:comment_content}, function(response) {
	            $('textarea[name="comment_content"]').val('');
	            loadComments();
	        });
	    });
	
	    $(document).on('click', '.delete-comment-btn', function() {
	        if (!confirm('정말 삭제하시겠습니까?')) return;
	
	        let commentId = $(this).data('id');
	
	        $.post('product_comment_delete.go', { comment_id: commentId }, function(response) {
	            if (response === 'success') {
	                alert('댓글이 삭제되었습니다.');
	                loadComments();
	            } else {
	                alert('삭제 실패');
	            }
	        });
	    });
	
	    $(document).on('click', '.edit-comment-btn', function() {
	        let commentId = $(this).data('id');
	        let contentDiv = $(this).closest('.comment-box').find('.comment-content');
	        let currentContent = contentDiv.text();
	
	        let newContent = prompt('댓글 수정:', currentContent);
	        if (newContent !== null) {
	            $.post('product_comment_update.go', { comment_id: commentId, comment_content: newContent }, function(response) {
	                if (response === 'success') {
	                    alert('수정 성공');
	                    loadComments();
	                } else {
	                    alert('수정 실패');
	                }
	            });
	        }
	    });
	    
	    function loadComments() {
	    	
	    	const product_sales_num = document.getElementById("product_num").value;

	        $.getJSON('product_comment_list.go', { product_num: product_sales_num }, function(comments) {
	            $('#commentList').empty();
	            $.each(comments, function(index, comment) {
	
	                let date = new Date(comment.comment_date);
	                date.setHours(date.getHours());
	
	                let formattedDate = date.getFullYear() + '-' +
	                    ('0' + (date.getMonth() + 1)).slice(-2) + '-' +
	                    ('0' + date.getDate()).slice(-2) + ' ' +
	                    ('0' + date.getHours()).slice(-2) + ':' +
	                    ('0' + date.getMinutes()).slice(-2) + ':' +
	                    ('0' + date.getSeconds()).slice(-2);
	
	                let $commentBox = $('<div>').addClass('comment-box');
	                $commentBox.append($('<div>').addClass('comment-user').text(comment.user_id));
	                $commentBox.append($('<div>').addClass('comment-content').text(comment.comment_content));
	                $commentBox.append($('<div>').addClass('comment-date').text(formattedDate));
	               
	                if ($.trim(comment.user_id) === $.trim(loggedInUserId)) {
					    let $actions = $('<div>').addClass('comment-actions');
					    let $deleteBtn = $('<button>').text('삭제').addClass('delete-comment-btn').attr('data-id', comment.comment_id);
					    let $editBtn = $('<button>').text('수정').addClass('edit-comment-btn').attr('data-id', comment.comment_id);
					    $actions.append($editBtn).append($deleteBtn);
					    $commentBox.append($actions);
					}

	                $('#commentList').append($commentBox);
	            });
	        });
	    }
	    
	});
	
	let socket;
	
	function openChatModal(seller_id, buyer_id, product_num, chat_room_num) {
	    
	    document.getElementById("chat_seller_id").innerText = seller_id;
	    document.getElementById("chat_modal").style.display = "block";

	    function formatDateTime(dateStr) {
	        const date = new Date(dateStr);
	        const yyyy = date.getFullYear();
	        const MM = String(date.getMonth() + 1).padStart(2, '0');
	        const dd = String(date.getDate()).padStart(2, '0');
	        const HH = String(date.getHours()).padStart(2, '0');
	        const mm = String(date.getMinutes()).padStart(2, '0');
	        return yyyy + "-" + MM + "-" + dd + " " + HH + ":" + mm;
	    }
	    
	    $.ajax({
	        url: "/chat/history",
	        method: "GET",
	        data: {
	            chat_room_num: chat_room_num
	        },
	        success: function(messages) {
	            const chatWindow = document.getElementById("chat_window");
	            chatWindow.innerHTML = "";
	            messages.forEach(function(msg) {
	                const isMe = msg.from_user === buyer_id;
	                const formattedTime = formatDateTime(msg.sent_time);

	                let messageHtml = "<div class='chat-msg " + (isMe ? "me" : "other") + "'>";
	                messageHtml += "<div>" + (isMe ? "" : "<b>" + msg.from_user + ":</b> ") + msg.message + "</div>";
	                messageHtml += "<div class='chat-meta'>" + formattedTime;
	                if (isMe && msg.is_read == 1) {
	                    messageHtml += " · 읽음";
	                }
	                messageHtml += "</div></div>";

	                chatWindow.innerHTML += messageHtml;
	            });
	            chatWindow.scrollTop = chatWindow.scrollHeight;

	            if (socket && socket.readyState === WebSocket.OPEN) {
	                const readPayload = {
	                    type: "read",
	                    opponentId: seller_id,
	                    productNum: product_num
	                };
	                socket.send(JSON.stringify(readPayload));
	            }
	        }
	    });

	    if (!socket || socket.readyState !== WebSocket.OPEN) {
		    socket = new WebSocket("ws://localhost:8282/chat/" + buyer_id);
	
		    socket.onopen = () => {
		        console.log("Connected to chat server.");
		    };
	
		    socket.onmessage = (event) => {
	            const data = JSON.parse(event.data);

	            if (data.type === "chat") {
	                const chatWindow = document.getElementById("chat_window");
	                const now = formatDateTime(new Date());

	                chatWindow.innerHTML += "<div class='chat-msg other'><div><b>"+data.from+":</b> "+data.message+"</div><div class='chat-meta'>"+now+"</div></div>";
	                chatWindow.scrollTop = chatWindow.scrollHeight;
	            } else if (data.type === "read_ack") {
	                $('#chat_window .chat-msg.me .chat-meta').each(function() {
	                    if (!$(this).text().includes('읽음')) {
	                        $(this).append(' · 읽음');
	                    }
	                });
	            }
	        };
	
		    socket.onerror = (error) => console.error("WebSocket error:", error);
	    }
	    
	    document.getElementById('send_btn').addEventListener('click', () => {
	        const input = document.getElementById('chat_input');
	        const message = input.value;
	        if (message && socket && socket.readyState === WebSocket.OPEN) {

	            const payload = {
	                type: "chat",
	                from: buyer_id,
	                to: seller_id,
	                message: message,
	                product_num: product_num
	            };

	            socket.send(JSON.stringify(payload));

	            const chatWindow = document.getElementById("chat_window");
	            const now = formatDateTime(new Date());

	            chatWindow.innerHTML += "<div class='chat-msg me'><div>"+message+"</div><div class='chat-meta'>"+now+"</div></div>";
	            chatWindow.scrollTop = chatWindow.scrollHeight;

	            input.value = "";
	        }
	    });
	    
	    document.getElementById("chat_input").addEventListener("keydown", function(event) {
            if (event.key === "Enter" && !event.shiftKey) {
                event.preventDefault();
                document.getElementById("send_btn").click();
            }
        });
	}

	function closeChatModal() {
	    document.getElementById("chat_modal").style.display = "none";
	    if (socket) {
	        socket.close();
	        socket = null;
	    }
	}
	
	window.sendMessage = function() {
	    const input = document.getElementById("chat_input");
	    const message = input.value;
	    if (message && socket && socket.readyState === WebSocket.OPEN) {
	        socket.send(message);
	        input.value = "";
	    }
	};
	
	function openReportModal(reported_user_id, reporter_id, product_num) {
		
		document.getElementById("report_modal").style.display = "block";
		
		$(document).on('change', 'input[name="report_reason"]', function() {
			const selectedValue = $(this).val();

			if (selectedValue === "other_reason") {
				$('#report_reason').show();
			} else {
				$('#report_reason').hide();
			}
		});
		
		$('#report_table #report_btn').off('click').on('click', function() {
	    	const selectedReason = $('input[name="report_reason"]:checked').val();
	    	let finalReason = selectedReason;

	    	if (selectedReason === "other_reason") {
	    		const customReason = $('#report_reason_text').val().trim();
	    		if (!customReason) {
	    			alert("신고 사유를 입력해주세요.");
	    			return;
	    		}
	    		finalReason = customReason;
	    	}

	    	$.ajax({
	    	    url: "report.go",
	    	    method: "GET",
	    	    data: {
	    	        product_num: product_num,
	    	        reporter_id: reporter_id,
	    	        reported_user_id: reported_user_id,
	    	        report_reason: finalReason,
	    	    },
	    	    success: function(res) {
	    	        if (res === "report") {
	    	            alert("신고가 접수되었습니다.");
	    	            closeReportModal();
	    	            
	    	        }else if(res === "already") {
	    	        	alert("이미 신고한 판매글입니다.");
	    	        	closeReportModal();
	    	        	
	    	        }else {
	    	            alert("신고에 실패했습니다. 다시 시도해주세요.");
	    	            closeReportModal();
	    	        }
	    	    },
	    	    error: function(xhr, status, error) {
	    	        alert("신고 처리 중 오류가 발생하였습니다. 다시 시도해주세요.");
	    	    }
	    	});

	    });

	}
	
	
	function closeReportModal() {
		document.getElementById("report_modal").style.display = "none";
		document.getElementById("report_reason_text").value = "";
	}

	
</script>

<head>
    <title>상품 상세</title>
</head>
<body>

	<jsp:include page="include/header.jsp" />

	<input type="hidden" id="product_num" value="${product.product_num }">
	<c:set var="imgList" value="${fn:split(product.product_img, ',')}" />

	<h2>${product.product_name}</h2>
	<img src="<%=request.getContextPath() %>resources/upload/${imgList[0]}" width="300" height="300">
	<p><b>가격 : </b>
		<c:if test="${product.sales_price == 0}">
			무료나눔
		</c:if>
		<c:if test="${product.sales_price != 0}">
			<fmt:formatNumber value="${product.sales_price}"/> 원
		</c:if>
	</p>
	<p><b>지역 : </b>${product.sales_area}</p>
	<p><b>등록일 : </b><fmt:formatDate value="${product.product_date}" pattern="yyyy-MM-dd"/></p>
	<p><b>판매자 : </b>${product.user_id}</p>
	<p><b>조회수 : </b>${product.product_hits}</p>

	<div class="chat-btn">
		<button type="button" id="chat_btn" data-seller-id="${product.user_id}"
											data-buyer-id="${sessionScope.user.user_id }"
											data-product-num="${product.product_num}"
											>채팅</button>
	</div>
	
	<div class="report-btn">
		<button type="button" id="report_btn" data-reported-user-id="${product.user_id}"
											  data-reporter-id="${sessionScope.user.user_id }"
											  data-product-num="${product.product_num}"
											  >🚨신고하기</button>
	</div>

	<h3>댓글</h3>
    <form id="commentForm">
        <textarea id="comment_content" name="comment_content" rows="3" cols="50" maxlength="200" placeholder="댓글을 입력하세요."></textarea>
        <button type="button" id="addCommentBtn" data-product-num="${product.product_num }"
        										 data-user-id="${sessionScope.user.user_id }"
        	>댓글 등록</button>
    </form>

    <div id="commentList"></div>

	<jsp:include page="include/footer.jsp" />

	<div id="chat_modal" style="display:none;">
	    <div id="chat_room">
	        <div class="close_btn" onclick="closeChatModal()">&times;</div>
	        <p id="chat_header"><b>상대방:</b> <span id="chat_seller_id"></span></p>
	        <div id="chat_window" style="height:200px; overflow:auto; border:1px solid #ccc; padding:10px; margin-bottom:10px;"></div>
	        <input type="text" id="chat_input" placeholder="메시지를 입력하세요" style="width:85%;">
	        <button id="send_btn">보내기</button>
	    </div>
	</div>
	
	<div id="report_modal" style="display:none;">
		<div id="report_table">
			<div class="close_btn" onclick="closeReportModal()">&times;</div>
			<div>
				<label>
					<input type="radio" name="report_reason" value="광고/홍보 목적의 게시글" checked> 광고/홍보 목적의 게시글
				</label><br>
				
				<label>
					<input type="radio" name="report_reason" value="불법 또는 위조 상품 판매"> 불법 또는 위조 상품 판매
				</label><br>
				
				<label>
					<input type="radio" name="report_reason" value="허위 또는 오해의 소지가 있는 정보"> 허위 또는 오해의 소지가 있는 정보
				</label><br>
				
				<label>
					<input type="radio" name="report_reason" value="사기 또는 부정 거래 의심"> 사기 또는 부정 거래 의심
				</label><br>
				
				<label>
					<input type="radio" name="report_reason" value="욕설, 혐오 등 부적절한 내용 포함"> 욕설, 혐오 등 부적절한 내용 포함
				</label><br>
				
				<label>
					<input type="radio" name="report_reason" value="other_reason"> 기타 사유(직접 작성)
				</label>
			</div>
			
			<div id="report_reason" style="display:none; margin-top: 10px;">
				<textarea id="report_reason_text" rows="3" cols="50" maxlength="100" placeholder="신고 사유를 입력하세요. (최대 100자)"></textarea>
			</div>
			
			<br>
			<div align="center">
				<button type="button" id="report_btn">🚨신고하기</button>
			</div>
		</div>
	</div>

</body>
</html>