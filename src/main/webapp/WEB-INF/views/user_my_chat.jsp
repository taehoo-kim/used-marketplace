<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>마이페이지 - 채팅</title>
<style>
    #chat_modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.7); }
    #chat_room { background-color: white; margin: 8% auto; padding: 30px; border-radius: 16px; width: 500px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3); position: relative; }
    .close_btn { position: absolute; top: 16px; right: 20px; font-size: 24px; color: #999; cursor: pointer; }
    .close_btn:hover { color: #ff4d4f; }
    .chat-msg { margin: 5px 0; padding: 8px 12px; border-radius: 10px; max-width: 70%; clear: both; }
    .chat-msg.me { background-color: #dcf8c6; float: right; text-align: right; }
    .chat-msg.other { background-color: #f1f0f0; float: left; text-align: left; }
    .chat-meta { font-size: 11px; color: #888; margin-top: 4px; }
    #chat_window::after { content: ""; display: block; clear: both; }
    .system-msg { text-align: center; color: grey; margin: 10px 0; font-size: 0.9em; }
</style>
</head>
<body>
    <jsp:include page="include/header.jsp" />

    <c:if test="${empty groupedChatList}">
        <p align="center" style="margin-top: 50px;">수신한 채팅이 없습니다.</p>
    </c:if>

    <c:forEach var="productEntry" items="${groupedChatList}">
        <c:set var="productNum" value="${productEntry.key}" />
        <div style="margin: 30px auto; padding: 15px; border: 1px solid #ccc; max-width: 800px;">
            <h3>상품 번호: ${productNum}</h3>
            <c:forEach var="chatRoomEntry" items="${productEntry.value}">
                <c:set var="chatRoomNum" value="${chatRoomEntry.key}" />
                <c:set var="chatList" value="${chatRoomEntry.value}" />
                <c:set var="opponentId" value="" />
                <c:forEach var="chat" items="${chatList}" varStatus="loop">
                    <c:if test="${loop.first}">
                         <c:choose>
                            <c:when test="${chat.from_user ne sessionScope.user.user_id}"><c:set var="opponentId" value="${chat.from_user}" /></c:when>
                            <c:otherwise><c:set var="opponentId" value="${chat.to_user}" /></c:otherwise>
                         </c:choose>
                    </c:if>
                </c:forEach>
                <div style="margin-bottom: 10px; padding: 10px; border: 1px solid #ddd;">
                    <p><b>상대방 : </b>${opponentId}</p>
                    <p><b>판매글 : </b><c:forEach var="p" items="${product_list}"><c:if test="${p.product_num eq productNum}">${p.product_title}</c:if></c:forEach></p>
                    <button class="chat-btn" data-opponent-id="${opponentId}" data-product-num="${productNum}" data-chat-room-num="${chatRoomNum}">채팅하기</button>
                </div>
            </c:forEach>
        </div>
    </c:forEach>

    <div id="chat_modal" style="display:none;">
        <div id="chat_room">
            <span class="close_btn" onclick="closeChatModal()">&times;</span>
            <p id="chat_header" style="font-size: 1.2em; border-bottom: 1px solid #eee; padding-bottom: 10px;"><b>상대방 :</b> <span id="chat_opponent_id"></span></p>
            <div id="chat_window" style="height:300px; overflow-y:auto; border:1px solid #ccc; padding:10px; margin-bottom:10px; background-color: #f9f9f9;"></div>
            <div style="display: flex;">
                <input type="text" id="chat_input" placeholder="메시지를 입력하세요" style="flex-grow: 1; margin-right: 5px; padding: 8px;">
                <button id="send_btn" style="padding: 8px 12px;">보내기</button>
                <button id="leave_btn" style="padding: 8px 12px; background-color: #dc3545; color: white; border: none; margin-left: 5px; cursor: pointer;">나가기</button>
            </div>
        </div>
    </div>

    <jsp:include page="include/footer.jsp" />

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
    const loggedInUserId = "${sessionScope.user.user_id}";
    let socket;
    let currentChatRoomNum, currentOpponentId, currentProductNum;

    // 채팅창을 여는 메인 함수
    // [수정 후]
	function openChatModal(opponentId, productNum, chatRoomNum) {
	    if (!loggedInUserId) { alert("로그인 후 이용해주세요."); return; }
	
	    currentOpponentId = opponentId;
	    currentProductNum = productNum;
	    currentChatRoomNum = chatRoomNum;
	
	    // `/chat/rejoin` AJAX 호출을 제거하고 바로 setupChatWindow()를 호출합니다.
	    setupChatWindow();
	}
    
    // 채팅창 UI 설정 및 데이터 로딩을 담당하는 함수
    function setupChatWindow() {
        document.getElementById("chat_opponent_id").innerText = currentOpponentId;
        document.getElementById("chat_modal").style.display = "block";
        $('#chat_input').prop('disabled', false).val('');
        $('#send_btn').prop('disabled', false);

        // 과거 채팅 내역 불러오기
        $.ajax({
            url: "/chat/history", method: "GET",
            data: { chat_room_num: currentChatRoomNum },
            success: function(messages) {
                const chatWindow = document.getElementById("chat_window");
                chatWindow.innerHTML = "";
                messages.forEach(function(msg) {
                    if (msg.is_leave === 1) return; // 시스템 메시지 숨기기
                    const isMe = msg.from_user === loggedInUserId;
                    const formattedTime = new Date(msg.sent_time).toLocaleString();
                    let messageHtml = "<div class='chat-msg " + (isMe ? "me" : "other") + "'><div>" + (isMe ? "" : "<b>" + msg.from_user + ":</b> ") + msg.message + "</div><div class='chat-meta'>" + formattedTime + "</div></div>";
                    chatWindow.innerHTML += messageHtml;
                });
                chatWindow.scrollTop = chatWindow.scrollHeight;
                checkOpponentStatus(currentChatRoomNum, currentOpponentId);
            }
        });

        // 웹소켓 연결
        if (!socket || socket.readyState !== WebSocket.OPEN) {
            socket = new WebSocket("ws://localhost:8282/chat/" + loggedInUserId);
            socket.onmessage = (event) => {
                const data = JSON.parse(event.data);
                if(data.product_num !== currentProductNum) return;
                const chatWindow = document.getElementById("chat_window");
                const now = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                chatWindow.innerHTML += "<div class='chat-msg other'><div><b>" + data.from + ":</b> " + data.message + "</div><div class='chat-meta'>" + now + "</div></div>";
                chatWindow.scrollTop = chatWindow.scrollHeight;
            };
        }
        
        // 메시지 전송 버튼 이벤트
        $('#send_btn').off('click').on('click', () => {
            const input = document.getElementById('chat_input');
            const message = input.value;
            if (message.trim() && socket && socket.readyState === WebSocket.OPEN) {
                const payload = { type: "chat", from: loggedInUserId, to: currentOpponentId, message: message, product_num: currentProductNum };
                socket.send(JSON.stringify(payload));
                const chatWindow = document.getElementById("chat_window");
                const now = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                chatWindow.innerHTML += "<div class='chat-msg me'><div>" + message + "</div><div class='chat-meta'>" + now + "</div></div>";
                chatWindow.scrollTop = chatWindow.scrollHeight;
                input.value = "";
            }
        });
    }
    
    // 상대방 나감 상태 확인 함수
    function checkOpponentStatus(chatRoomNum, opponentId) {
        if (!chatRoomNum || !opponentId) return;
        $.getJSON('/chat/status', { chat_room_num: chatRoomNum, opponent_id: opponentId }, function(data) {
            if (data.has_left) {
                $('#chat_window').append("<div class='system-msg'>상대방이 나간 대화방입니다.</div>");
                $('#chat_input').prop('disabled', true);
                $('#send_btn').prop('disabled', true);
            }
        });
    }

    // 채팅 모달 닫기 함수
    function closeChatModal() {
        document.getElementById("chat_modal").style.display = "none";
        if (socket) { socket.close(); socket = null; }
        // 페이지를 새로고침하여 최신 채팅 목록을 반영
        if (window.location.href.includes("user_my_chat.go")) {
             location.reload();
        }
    }

    $(document).ready(function() {
        // '채팅하기' 버튼 이벤트
        $(document).on("click", ".chat-btn", function() {
            openChatModal($(this).data("opponent-id"), $(this).data("product-num"), $(this).data("chat-room-num"));
        });

        // Enter 키로 메시지 전송
        $("#chat_input").on("keydown", function(event) {
            if (event.key === "Enter" && !event.shiftKey) { event.preventDefault(); $("#send_btn").click(); }
        });

        // '나가기' 버튼 이벤트
        $('#leave_btn').on('click', function() {
            if (confirm('정말로 채팅방을 나가시겠습니까? 대화 내용이 목록에서 사라집니다.')) {
                $.ajax({
                    url: '/chat/leave', type: 'POST',
                    data: { chat_room_num: currentChatRoomNum, product_num: currentProductNum, opponent_id: currentOpponentId },
                    success: function(response) {
                        if (response === 'success') {
                            alert('채팅방에서 나갔습니다.');
                            closeChatModal();
                        } else { alert('오류가 발생했습니다.'); }
                    }
                });
            }
        });
    });
</script>
</body>
</html>