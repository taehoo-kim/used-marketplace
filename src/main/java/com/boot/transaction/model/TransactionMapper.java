package com.boot.transaction.model;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface TransactionMapper {

	List<ProductDTO> product_list(PageDTO pdto); // 기존의 메서드에 인자 추가
	
	List<ProductDTO> product_list_on_chat();	// 채팅 기능에서 사용할 인자 없는 상품 판매글 조회
	
	int products_count();
	
	List<ProductDTO> product_list_by_category(String categoryCode);
	
	List<CategoryDTO> category_list();
	
	
	int product_insert(ProductDTO pdto);
	
	List<ProductDTO> user_product_list(PageDTO pdto);
	
	int user_product_list_count(String user_id);
	
	int user_product_modify(ProductDTO pdto);
	
	int user_product_delete(int product_num);
	
	int deactivation_chat_room(int product_num);
	
	void markMessagesAsRead(Map<String, Object> param);
	
	
	int insertUser(UserDTO user);

	UserDTO findId(String user_id);
	
	UserDTO findNickname(String user_nickname);
	
	int updateUser(UserDTO user);
	
	String getPassword(String userId);
	
	int products_search_count(Map<String, Object> map);

	List<ProductDTO> products_search_list(PageDTO pdto);
	
	ProductDTO selectProduct(int product_num);

	void update_product_hits(int product_num);
	
	// 판매글 신고
	int report(ReportDTO rdto);
	
	int reported_check(ReportDTO rdto);
	
	
	void insertWishList(@Param("user_id") String user_id, @Param("product_num") int product_num);

	
	
	
	
	// 댓글
	List<ProductCommentDTO> getCommentsByProduct(int product_num);

	void insertProductComment(ProductCommentDTO commentDTO);
		    
	void deleteProductComment(@Param("comment_id") int commentId);
	  
	void updateProductComment(@Param("comment_id") int commentId, @Param("comment_content") String commentContent);
	
	// ================== [수정] 채팅 관련 메서드 ==================

		void sendMessage(ChatMessageDTO cdto);
		List<ChatMessageDTO> getChatMessages(@Param("buyer_id") String buyer_id, 
				@Param("seller_id") String seller_id, @Param("product_num") int product_num);
		List<ChatMessageDTO> myMessage(String user_id);
		
		/**
		 * 나가기: 특정 유저가 보낸 모든 메시지의 is_leave 상태를 1로 변경합니다.
		 */
		void leaveChatRoomForUser(@Param("chat_room_num") int chatRoomNum, @Param("user_id") String userId);

		/**
		 * 상대방이 나갔는지 확인합니다. (상대방 메시지 중 is_leave=0인 것이 없으면 나간 것으로 간주)
		 */
		int checkIfOpponentLeft(@Param("chat_room_num") int chatRoomNum, @Param("opponent_id") String opponentId);
		
		/**
		 * 두 명 모두 나갔을 때 채팅방의 모든 메시지를 삭제합니다.
		 */
		void deleteChatRoomHistory(@Param("chat_room_num") int chatRoomNum);

    Integer findLastChatRoomNum(@Param("user1") String user1,
                                @Param("user2") String user2,
                                @Param("product_num") int productNum);

    int didUserLeave(@Param("chat_room_num") int chatRoomNum,
                     @Param("user_id") String userId);

    int createNewRoomNum();
}
