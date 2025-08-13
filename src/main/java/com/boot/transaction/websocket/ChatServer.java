package com.boot.transaction.websocket;

import java.util.concurrent.ConcurrentHashMap;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import com.boot.transaction.model.ChatMessageDTO;
import com.boot.transaction.model.TransactionMapper;

import jakarta.websocket.*;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;

import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;

@Component
@ServerEndpoint("/chat/{userId}")
public class ChatServer {

	@Autowired
	private TransactionMapper mapper;

	private static Map<String, Session> userSessions = new ConcurrentHashMap<>();
	
    private static Map<String, Session> clients = new ConcurrentHashMap<>();

    private TransactionMapper getMapper() {
        ApplicationContext context = ApplicationContextProvider.getApplicationContext();
        if (context != null) {
            return context.getBean(TransactionMapper.class);
        }
        return null;
    }

    @OnOpen
    public void onOpen(Session session, @PathParam("userId") String userId) {
        System.out.println("WebSocket opened: " + session.getId() + ", userId: " + userId);
        clients.put(userId, session);
        userSessions.put(userId, session);
    }
    
    @OnMessage
    public void onMessage(String message, Session session, @PathParam("userId") String userId) {
        try {
            JSONObject obj = new JSONObject(message);
            String type = obj.optString("type", "chat");

            if ("chat".equals(type)) {
                String from = obj.getString("from");
                String to = obj.getString("to");
                String msg = obj.getString("message");
                int productNum = obj.getInt("product_num");

                System.out.println("Message from " + from + " to " + to + ": " + msg);

                // 메시지 DB 저장
                ChatMessageDTO cdto = new ChatMessageDTO();
                cdto.setFrom_user(from);
                cdto.setTo_user(to);
                cdto.setMessage(msg);
                cdto.setProduct_num(productNum);

                TransactionMapper mapper = getMapper();
                if (mapper != null) {
                    mapper.sendMessage(cdto);
                } else {
                    System.err.println("TransactionMapper bean을 가져올 수 없습니다.");
                }

                
                Session toSession = clients.get(to);
                if (toSession != null && toSession.isOpen()) {
                    JSONObject response = new JSONObject();
                    response.put("from", from);
                    response.put("message", msg);
                    response.put("product_num", productNum);

                    toSession.getBasicRemote().sendText(response.toString());
                }

            } else if ("read".equals(type)) {
                
                String opponentId = obj.getString("opponentId");
                int productNum = obj.getInt("productNum");

                markAsRead(userId, opponentId, productNum);
            } else {
                System.out.println("알 수 없는 메시지 타입: " + type);
            }

        } catch (Exception e) {
            System.err.println("메시지 처리 중 예외 발생: " + message);
            e.printStackTrace();
        }
    }


    @OnClose
    public void onClose(Session session, @PathParam("userId") String userId) {
        System.out.println("WebSocket closed: " + session.getId() + ", userId: " + userId);
        clients.remove(userId);
    }
    
    public void markAsRead(String userId, String opponentId, int productNum) {
        Map<String, Object> param = new HashMap<>();
        param.put("userId", userId);
        param.put("opponentId", opponentId);
        param.put("productNum", productNum);

        TransactionMapper mapper = getMapper(); 
        mapper.markMessagesAsRead(param);

        
        Session opponentSession = userSessions.get(opponentId);
        if (opponentSession != null && opponentSession.isOpen()) {
            JSONObject readAck = new JSONObject();
            readAck.put("type", "read_ack");
            readAck.put("from", userId);
            readAck.put("product_num", productNum);

            opponentSession.getAsyncRemote().sendText(readAck.toString());
        }
    }
}
