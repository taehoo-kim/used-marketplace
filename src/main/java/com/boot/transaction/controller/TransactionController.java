package com.boot.transaction.controller;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.multipart.MultipartFile;

import com.boot.transaction.model.CategoryDTO;
import com.boot.transaction.model.ChatMessageDTO;
import com.boot.transaction.model.PageDTO;
import com.boot.transaction.model.ProductCommentDTO;
import com.boot.transaction.model.ProductDTO;
import com.boot.transaction.model.ReportDTO;
import com.boot.transaction.model.TransactionMapper;
import com.boot.transaction.model.UserDTO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;


@Controller
public class TransactionController {

	@Autowired
	private TransactionMapper mapper;
	
	// 페이지 변수
    private final int rowsize = 10;
    private final int salesRowsize = 5;
 	private int totalRecord = 0;
 	
 	List<String> areas = Arrays.asList("서울", "부산", "인천", "대구", "대전", "광주", "울산", "세종",
 			"수원", "성남", "고양", "용인", "창원", "청주", "전주", "포항", "천안", "안산", "안양", "남양주");
	
 	@GetMapping("/")
	public String main(@RequestParam(value = "page", defaultValue = "1") int page,
			@RequestParam(value = "category_code", required = false) String categoryCode,
			Model model) {
	
		totalRecord = this.mapper.products_count();
				
		PageDTO pdto = new PageDTO(page, rowsize, totalRecord);
	
		List<ProductDTO> productlist;
		
	    if(categoryCode == null || categoryCode.isEmpty()) {
	        productlist = mapper.product_list(pdto);  // 전체 제품
	    } else {
	        productlist = mapper.product_list_by_category(categoryCode);  // 카테고리별 제품
	    }	
		
		List<CategoryDTO> category = mapper.category_list();
		
		model.addAttribute("productList", productlist)
			.addAttribute("areas", areas)
			.addAttribute("paging", pdto)	
			.addAttribute("category", category)
			.addAttribute("selectedCategory", categoryCode);
		
		return "main";
		
	}
 	
 	@GetMapping("secondhand_list.go")
 	public String secondhandList(
 	    @RequestParam(value = "area", required = false) String area,
 	    @RequestParam(value = "category", required = false) String category,
 	    @RequestParam(value = "keyword", required = false) String keyword,
 	    @RequestParam(value = "minPrice", required = false) Integer minPrice,
 	    @RequestParam(value = "maxPrice", required = false) Integer maxPrice,
 	    @RequestParam(value = "page", defaultValue = "1") int page,
 	    Model model
 		) {
 	  
 	    Map<String, Object> map = new HashMap<String, Object>();
 	    map.put("area", area);        
 	    map.put("category", category);     
 	    map.put("keyword", keyword);  
 	    map.put("minPrice", minPrice);  
 	    map.put("maxPrice", maxPrice);  

 	    totalRecord = this.mapper.products_search_count(map);
 	    
 	    PageDTO pdto = new PageDTO(page, rowsize, totalRecord, area, category, keyword, minPrice, maxPrice);
 	    
 	    List<ProductDTO> productList = this.mapper.products_search_list(pdto);
 	   
 	    List<CategoryDTO> categorylist = this.mapper.category_list();
 	    
 	    model.addAttribute("productList", productList)
	 	     .addAttribute("area", area)
	 	     .addAttribute("areas", areas)
	 	     .addAttribute("category", category)
	 	     .addAttribute("categorylist", categorylist)
	 	     .addAttribute("paging", pdto)	
	 	     .addAttribute("minPrice", minPrice)	
	 	     .addAttribute("maxPrice", maxPrice)	
	 	     .addAttribute("keyword", keyword);
 	    

 	    return "product_search_list";
 	}
 	
 	@GetMapping("user_my_page.go")
 	@ResponseStatus
 	public String my_page(HttpSession session, HttpServletResponse response) throws IOException {
 	    
 	    String loggedInUserId = (String) session.getAttribute("user_id");

 	    if (loggedInUserId == null) { 	        
 	        response.setContentType("text/html; charset=UTF-8");
 	        PrintWriter out = response.getWriter();
 	        out.println("<script>");
 	        out.println("alert('로그인 후 이용해 주세요.');");
 	        out.println("location.href='/';");  
 	        out.println("</script>");
 	        return null;  
 	    }

 	    UserDTO user = this.mapper.findId(loggedInUserId);
 	    session.setAttribute("user", user);  

 	    return "user_my_page"; 
 	}
 	
	 // ================= [수정된 부분 시작] =================
	 	@GetMapping("user_my_chat.go")
	 	public String my_chat(HttpSession session, HttpServletResponse response, Model model) throws IOException {
	 		UserDTO user = (UserDTO) session.getAttribute("user");
	 		if(user == null) {
	 			response.setContentType("text/html; charset=UTF-8");
	 			PrintWriter out = response.getWriter();
	 			out.println("<script>alert('로그인 세션이 만료되었습니다. 다시 로그인 해주세요.'); location.href='/';</script>");
	 			return null;
	 		}
	 		String userId = user.getUser_id();
	 		
	 		List<ChatMessageDTO> allMessages = this.mapper.myMessage(userId);
	
	 		Map<Integer, List<ChatMessageDTO>> chatsByRoom = allMessages.stream()
	 			.collect(Collectors.groupingBy(ChatMessageDTO::getChat_room_num));
	
	 		List<List<ChatMessageDTO>> activeChatRooms = new ArrayList<>();
	
	 		for (List<ChatMessageDTO> messagesInRoom : chatsByRoom.values()) {
	 			List<ChatMessageDTO> myMessagesInRoom = messagesInRoom.stream()
	 				.filter(msg -> msg.getFrom_user().equals(userId))
	 				.collect(Collectors.toList());

	 			boolean iHaveSentMessages = !myMessagesInRoom.isEmpty();
	 			boolean allMyMessagesAreLeft = iHaveSentMessages && myMessagesInRoom.stream().allMatch(msg -> msg.getIs_leave() == 1);

	 			// 내가 메시지를 보낸적이 없거나, 보낸 메시지 중 is_leave=0인 것이 하나라도 있으면 채팅방을 보여줌
	 			if (!iHaveSentMessages || !allMyMessagesAreLeft) {
	 				activeChatRooms.add(messagesInRoom);
	 			}
	 		}
	 		
	 		Map<Integer, Map<Integer, List<ChatMessageDTO>>> groupedChats = activeChatRooms.stream()
	 			.flatMap(List::stream)
	 			.collect(Collectors.groupingBy(ChatMessageDTO::getProduct_num,
	 					 Collectors.groupingBy(ChatMessageDTO::getChat_room_num)));
	 		
	 		model.addAttribute("groupedChatList", groupedChats);
	 		model.addAttribute("product_list", this.mapper.product_list_on_chat());
	 		return "user_my_chat";
	 	}

	
	
	@GetMapping("product_sales.go")
	public String product_sales(Model model, HttpSession session, HttpServletResponse response) throws IOException {
		
		response.setContentType("text/html; charset=UTF-8");
	    PrintWriter out = response.getWriter();
		
	    UserDTO user = (UserDTO) session.getAttribute("user");
	    
		if(user == null) {
			out.println("<script>");
	        out.println("alert('로그인 세션이 만료되었습니다. 다시 로그인 해주세요.');");
	        out.println("location.href='/'");
	        out.println("</script>");
	        
	        return null;
		}
		
		List<CategoryDTO> categoryList = this.mapper.category_list();
		
		model.addAttribute("categoryList", categoryList);
		
		return "product_sales";
	}
	
	@PostMapping("product_sales_ok.go")
	public void product_sales_ok(ProductDTO pdto, HttpServletRequest request, 
			HttpServletResponse response) throws IllegalStateException, IOException {

		response.setContentType("text/html; charset=UTF-8");
	    PrintWriter out = response.getWriter();
		
	    MultipartFile[] files = pdto.getProduct_img_File();
	    List<String> savedFileNames = new ArrayList<>();

	    if(files != null && files.length > 0) {
	        String uploadPath = request.getServletContext().getRealPath("resources/upload/");

	        for (MultipartFile file : files) {
	            if (!file.isEmpty()) {
	                String originalFileName = file.getOriginalFilename();

	                // 파일명 중복 방지
	                String uuid = UUID.randomUUID().toString();
	                String savedFileName = uuid + "_" + originalFileName;

	                File destFile = new File(uploadPath, savedFileName);
	                if (!destFile.getParentFile().exists()) {
	                    destFile.getParentFile().mkdirs();
	                }
	                savedFileNames.add(savedFileName);
	                file.transferTo(destFile);
	                	
	            }
	        }

	        String imgNames = String.join(",", savedFileNames);
	        pdto.setProduct_img(imgNames);
	    }

	    // DB insert
	    int insertCheck = this.mapper.product_insert(pdto);

	    if (insertCheck > 0) {
	        out.println("<script>");
	        out.println("alert('물품 판매 글이 등록되었습니다.');");
	        out.println("location.href='/'");
	        out.println("</script>");
	    } else {
	        out.println("<script>");
	        out.println("alert('물품 판매 글 등록에 실패하였습니다. 다시 시도해주세요.');");
	        out.println("history.back();");
	        out.println("</script>");
	    }
	}
	
	
	@GetMapping("user_sales_product_list.go")
	@ResponseStatus
	public String user_sales_list(HttpSession session, Model model,
			HttpServletResponse response,
			@RequestParam(value = "page", defaultValue = "1") int page) throws IOException {
		
		response.setContentType("text/html; charset=UTF-8");
	    PrintWriter out = response.getWriter();
		
	    UserDTO user = (UserDTO) session.getAttribute("user");
	    
	    if(user == null) {
			out.println("<script>");
	        out.println("alert('로그인 세션이 만료되었습니다. 다시 로그인 해주세요.');");
	        out.println("location.href='/'");
	        out.println("</script>");
	        
	        return null;
		}
	    
	    totalRecord = this.mapper.user_product_list_count(user.getUser_id());
	    
	    PageDTO pdto = new PageDTO(page, salesRowsize, totalRecord, user.getUser_id());
	    
		List<ProductDTO> user_product_list = this.mapper.user_product_list(pdto);
		List<CategoryDTO> cList = this.mapper.category_list();
		
		model.addAttribute("user_product_list", user_product_list)
			.addAttribute("category_list", cList)
			.addAttribute("paging", pdto);
		
		return "user_my_sales_list";
		
	}
	
	@PostMapping("user_product_modify.go")
	public void user_product_modify(ProductDTO pdto, HttpServletResponse response) throws IOException {
		
		response.setContentType("text/html; charset=UTF-8");
	    PrintWriter out = response.getWriter();
		
	    int modify_check = this.mapper.user_product_modify(pdto);
	    
	    if(modify_check > 0) {
	    	out.println("<script>");
	        out.println("alert('판매 글을 수정하였습니다.');");
	        out.println("location.href='user_sales_product_list.go'");
	        out.println("</script>");
	    }else {
	    	out.println("<script>");
	        out.println("alert('판매 글 수정 중 오류가 발생하였습니다. 다시 시도해주세요.');");
	        out.println("history.back();");
	        out.println("</script>");
	    }
	    
	}
	
	// 회원의 판매글 삭제
	@GetMapping("user_product_delete.go")
	public void user_product_delete(@RequestParam("product_num") int product_num,
			HttpServletResponse response, HttpServletRequest request) throws IOException {
		
		response.setContentType("text/html; charset=UTF-8");
	    PrintWriter out = response.getWriter();
	    
	    ProductDTO product = this.mapper.selectProduct(product_num);
	    
	    String uploadPath = request.getServletContext().getRealPath("resources/upload/");
	    
	    String[] imgArr = product.getProduct_img().split(",");
	    
	    int product_delete_check = this.mapper.user_product_delete(product_num);
	    
	    if(product_delete_check > 0) {
	    	this.mapper.deactivation_chat_room(product_num);
	    	
	    	for(String img : imgArr) {
	            if (img != null && !img.trim().isEmpty()) {
	                File file = new File(uploadPath + "/" + img.trim());
	                if (file.exists()) {
	                    file.delete();
	                }
	            }
	        }
	    	
	    	out.println("<script>");
	        out.println("alert('판매 글을 삭제하였습니다.');");
	        out.println("location.href='user_sales_product_list.go'");
	        out.println("</script>");
	    }else {
	    	out.println("<script>");
	        out.println("alert('판매 글 삭제 중 오류가 발생하였습니다. 다시 시도해주세요.');");
	        out.println("history.back();");
	        out.println("</script>");
	    }
		
	}
	
	@PostMapping("/user_update_ok.go")
 	public void userUpdate(UserDTO user, 
 	    @RequestParam("email_id") String emailId, 
 	    @RequestParam("email_domain") String emailDomain,
 	    @RequestParam(value = "email_custom", required = false) String emailCustom,
 	    @RequestParam("phone1") String phone1,
 	    @RequestParam("phone2") String phone2,
 	    @RequestParam("phone3") String phone3,
 	    @RequestParam("user_pwd_confirm") String userPwdConfirm,
 	    @RequestParam("user_zipcode") String userZipcode,
 	    @RequestParam("user_addr_base") String userAddrBase,
 	    @RequestParam("user_addr_detail") String userAddrDetail,
 	    @RequestParam("user_nickname") String userNickname,
 	    HttpServletResponse response,
 	    HttpSession session) throws IOException {

 	    response.setContentType("text/html; charset=UTF-8");
 	    PrintWriter out = response.getWriter();

 	    String loggedInUserId = (String) session.getAttribute("user_id");

 	    if (loggedInUserId == null) {
 	        out.println("<script>");
 	        out.println("alert('로그인 후 이용해주세요.');");
 	        out.println("location.href='login.go';");
 	        out.println("</script>");
 	        return;
 	    }

 	    if (!isValidKoreanName(user.getUser_name())) {
 	        out.println("<script>");
 	        out.println("alert('이름은 한글만 입력 가능합니다.');");
 	        out.println("history.back();");
 	        out.println("</script>");
 	        return;
 	    }

 	    if (user.getUser_pwd() != null && !user.getUser_pwd().isEmpty()) {
 	        if (!isValidPassword(user.getUser_pwd())) {
 	            out.println("<script>");
 	            out.println("alert('비밀번호는 8~16자리이면서 영문자, 숫자, 특수문자를 모두 포함해야 합니다.');");
 	            out.println("history.back();");
 	            out.println("</script>");
 	            return;
 	        }
 	        if (!user.getUser_pwd().equals(userPwdConfirm)) {
 	            out.println("<script>");
 	            out.println("alert('비밀번호가 일치하지 않습니다.');");
 	            out.println("history.back();");
 	            out.println("</script>");
 	            return; 
 	        }
 	    } else {
 	        // 비밀번호 입력하지 않으면 기존 비밀번호를 유지
 	        String existingPassword = this.mapper.getPassword(user.getUser_id());  
 	        user.setUser_pwd(existingPassword);  
 	    }

 	    String email = emailId + "@" + (emailDomain.equals("direct") ? emailCustom : emailDomain);
 	    user.setUser_email(email);

 	    String phone = phone1 + "-" + phone2 + "-" + phone3;
 	    user.setUser_phone(phone);

 	    if (userNickname == null || userNickname.trim().isEmpty()) {
 	        out.println("<script>");
 	        out.println("alert('닉네임을 입력해주세요.');");
 	        out.println("history.back();");
 	        out.println("</script>");
 	        return;
 	    }
 	    
 	    if (!isValidNickname(userNickname)) {
 	        out.println("<script>");
 	        out.println("alert('닉네임은 2~20자, 한글/영문/숫자/_ 만 가능합니다.');");
 	        out.println("history.back();");
 	        out.println("</script>");
 	        return;
 	    }

 	    UserDTO duplicateNickname = this.mapper.findNickname(userNickname);
 	    if (duplicateNickname != null && !duplicateNickname.getUser_id().equals(loggedInUserId)) {
 	        out.println("<script>");
 	        out.println("alert('이미 사용 중인 닉네임입니다.');");
 	        out.println("history.back();");
 	        out.println("</script>");
 	        return;
 	    }

 	    user.setUser_zipcode(userZipcode);
 	    user.setUser_addr(userAddrBase);
 	    user.setUser_addr_detail(userAddrDetail);
 	    user.setUser_nickname(userNickname);
 	    
 	    int check = this.mapper.updateUser(user);

 	    if (check > 0) {
 	        out.println("<script>");
 	        out.println("alert('회원정보가 수정되었습니다.');");
 	        out.println("location.href='/';");
 	        out.println("</script>");
 	    } else {
 	        out.println("<script>");
 	        out.println("alert('회원정보 수정 실패!');");
 	        out.println("history.back();");
 	        out.println("</script>");
 	    }
 	}
	
	// 로그인 기능
	@PostMapping("/login.go")
	public void login(
	    @RequestParam("userId") String userId,
	    @RequestParam("userPwd") String userPwd,
	    HttpSession session,
	    HttpServletResponse response
	) throws IOException {
	    response.setContentType("text/html; charset=UTF-8");
	    PrintWriter out = response.getWriter();

	    UserDTO user = mapper.findId(userId);
	    if (user != null && user.getUser_pwd().equals(userPwd)) {
	        
	        session.setAttribute("user", user);
	        session.setAttribute("user_id", user.getUser_id());

	        String loginUserNickname = user.getUser_nickname();

	        out.println("<script>");
	        out.println("alert('" + loginUserNickname + "님 환영합니다.');");  
	        out.println("location.href='/'");
	        out.println("</script>");
	    } else {
	        out.println("<script>");
	        out.println("alert('아이디 또는 비밀번호를 다시 확인해주세요.');");
	        out.println("history.back();");
	        out.println("</script>");
	    }
	}

	
	// 로그아웃 기능
	@GetMapping("/logout.go")
	public String logout(HttpSession session) {
	    session.invalidate();  
	    return "redirect:/";   
	}
	
	
	// 회원가입 기능
	private boolean isValidUserId(String userId) {
	    return userId != null && userId.matches("^[a-zA-Z0-9]{6,12}$");
	}

	private boolean isValidPassword(String password) {
	    return password != null && password.matches("^(?=.*[a-zA-Z])(?=.*\\d)(?=.*[\\W_]).{8,16}$");
	}
	
	private boolean isValidKoreanName(String name) {
	    return name != null && name.matches("^[가-힣]+$");
	}
	
	private boolean isValidNickname(String nickname) {
	    return nickname != null && nickname.matches("^[가-힣a-zA-Z0-9_]{2,20}$");
	}
	
	@GetMapping("/sign_up.go")
	public String signupForm(Model model) {	    
	    return "sign_up";
	}
	
    
	@PostMapping("/sign_up_ok.go")
	public void signupUser(UserDTO dto,
	        @RequestParam("email_id") String emailId,
	        @RequestParam("email_domain") String emailDomain,
	        @RequestParam(value = "email_custom", required = false) String emailCustom,
	        @RequestParam("phone1") String phone1,
	        @RequestParam("phone2") String phone2,
	        @RequestParam("phone3") String phone3,
	        @RequestParam("user_pwd_confirm") String user_pwd_confirm,
	        @RequestParam("user_zipcode") String user_zipcode,
	        @RequestParam("user_addr_base") String user_addr_base,
	        @RequestParam("user_addr_detail") String user_addr_detail,
	        @RequestParam("user_nickname") String user_nickname,
	        HttpServletResponse response) throws IOException {
	    
	    response.setContentType("text/html; charset=UTF-8");
	    PrintWriter out = response.getWriter();
	    
	    	    	    	    
	    if (!isValidUserId(dto.getUser_id())) {
	        out.println("<script>");
	        out.println("alert('아이디는 6~12자, 영문과 숫자만 포함되어야 합니다.');");
	        out.println("history.back();");
	        out.println("</script>");
	        return;
	    }
	    
	    UserDTO duplicateUser = mapper.findId(dto.getUser_id());
	    if (duplicateUser != null) {
	        out.println("<script>");
	        out.println("alert('이미 사용 중인 아이디입니다.');");
	        out.println("history.back();");
	        out.println("</script>");
	        return;
	    }
	    
	    dto.setUser_nickname(user_nickname);
	    
	    if (user_nickname == null || user_nickname.trim().isEmpty()) {
	        out.println("<script>");
	        out.println("alert('닉네임을 입력해주세요.');");
	        out.println("history.back();");
	        out.println("</script>");
	        return;
	    }
	    
	    UserDTO duplicateNickname = mapper.findNickname(user_nickname);
	    if (duplicateNickname != null) {
	        out.println("<script>");
	        out.println("alert('이미 사용 중인 닉네임입니다.');");
	        out.println("history.back();");
	        out.println("</script>");
	        return;
	    }
	    
	    if (!isValidNickname(user_nickname)) {
	        out.println("<script>");
	        out.println("alert('닉네임은 2~20자, 한글/영문/숫자/_ 만 가능합니다.');");
	        out.println("history.back();");
	        out.println("</script>");
	        return;
	    }

	    
	    if (!isValidPassword(dto.getUser_pwd())) {
	        out.println("<script>");
	        out.println("alert('비밀번호는 8~16자리이면서 영문자, 숫자, 특수문자를 모두 포함해야 합니다.');");
	        out.println("history.back();");
	        out.println("</script>");
	        return;
	    }

	    
	    if (!dto.getUser_pwd().equals(user_pwd_confirm)) {
	        out.println("<script>");
	        out.println("alert('비밀번호를 정확히 입력했는지 확인해주세요!');");
	        out.println("history.back();");
	        out.println("</script>");
	        return;
	    }

	    
	    if (!isValidKoreanName(dto.getUser_name())) {
	        out.println("<script>");
	        out.println("alert('이름은 한글만 입력 가능합니다.');");
	        out.println("history.back();");
	        out.println("</script>");
	        return;
	    }
	    
	    
	    String domain = "direct".equals(emailDomain) && emailCustom != null && !emailCustom.trim().isEmpty()
	            ? emailCustom.trim()
	            : emailDomain;
	    dto.setUser_email(emailId + "@" + domain);
	    
	    
	    dto.setUser_phone(phone1 + "-" + phone2 + "-" + phone3);
	    
	    dto.setUser_zipcode(user_zipcode);
	    dto.setUser_addr(user_addr_base);
	    dto.setUser_addr_detail(user_addr_detail);
	    	   	    

	    int check = this.mapper.insertUser(dto);

	    if (check > 0) {
	        out.println("<script>");
	        out.println("alert('회원 등록 성공!!!');");
	        out.println("location.href='/'");
	        out.println("</script>");
	    } else {
	        out.println("<script>");
	        out.println("alert('회원 등록 실패!');");
	        out.println("history.back();");
	        out.println("</script>");
	    }
	}

    
	@GetMapping("/check_id.go")
    public void checkId(@RequestParam("user_id") String id, HttpServletResponse response) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        if (id == null || id.trim().isEmpty()) {
            out.println("아이디를 입력해주세요."); 
            return;
        }

        UserDTO duplicateUser = mapper.findId(id);

        if (duplicateUser != null) {
            out.println("이미 사용 중인 아이디입니다.");
        } else {
            out.println("사용 가능한 아이디입니다.");
        }
    }
    
	 @GetMapping("/check_nickname.go")
	    @ResponseStatus
	    public void checkNickname(@RequestParam("user_nickname") String nickname, HttpServletResponse response) throws IOException {
	        response.setContentType("text/html; charset=UTF-8");
	        PrintWriter out = response.getWriter();

	        if (nickname == null || nickname.trim().isEmpty()) {
	            out.println("닉네임을 입력해주세요.");
	            return;
	        }

	        UserDTO duplicateNickname = mapper.findNickname(nickname);

	        if (duplicateNickname != null) {
	            out.println("이미 사용 중인 닉네임입니다.");
	        } else {
	            out.println("사용 가능한 닉네임입니다.");
	        }
	    }
    
    @GetMapping("product_detail.go")
    public String productDetail(@RequestParam(name = "product_num") int productNum, Model model) {
        
    	this.mapper.update_product_hits(productNum);
    	
    	ProductDTO product = this.mapper.selectProduct(productNum);
        model.addAttribute("product", product);
        return "product_detail";
    }
    
    @GetMapping("report.go")
    @ResponseBody
    public String report(ReportDTO rdto) {
    	String res = "";
    	
    	int already_reported = this.mapper.reported_check(rdto);
    	
    	if(already_reported > 0) {
    		res = "already";
    		
    	}else {
    		int report_check = this.mapper.report(rdto);
        	
        	if(report_check > 0) {
        		res = "report";
        	}else {
        		res = "failed";
        	}
        	
    	}
    	
    	return res;
    }


    @PostMapping("wishlist_insert.do")
    public String wishlistInsert(@RequestParam String user_id, @RequestParam int product_num) {
        this.mapper.insertWishList(user_id, product_num);
        return "redirect:/product_detail.go?product_num=" + product_num;
    }

    //채팅
    @GetMapping("/chat/history")
    @ResponseBody
    public List<ChatMessageDTO> getChatHistory(
            @RequestParam("buyer_id") String buyer_id,
            @RequestParam("seller_id") String seller_id,
            @RequestParam("product_num") int product_num) {

        return this.mapper.getChatMessages(buyer_id, seller_id, product_num);
    }
    
    @GetMapping("delete_chat_room.go")
    public void delete_chat_room(@RequestParam("product_num") int product_num,
    		HttpServletResponse response) throws IOException {
    	
    	response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        int delete_check = this.mapper.deactivation_chat_room(product_num);
        
        if(delete_check > 0) {
        	out.println("<script>");
	        out.println("alert('채팅방을 삭제하였습니다.');");
	        out.println("location.href='user_my_chat.go'");
	        out.println("</script>");
        }else {
        	out.println("<script>");
	        out.println("alert('채팅방 삭제 중 오류가 발생하였습니다. 다시 시도해주세요.');");
	        out.println("history.back();");
	        out.println("</script>");
        }
    	
    }
    
    //댓글
    @GetMapping("product_comment_list.go")
    @ResponseBody
    public List<ProductCommentDTO> getCommentList(@RequestParam("product_num") int productNum) {
        return mapper.getCommentsByProduct(productNum);
    }

    @PostMapping("product_comment_insert.go")
    @ResponseBody
    public String insertComment(ProductCommentDTO commentDTO) {
        mapper.insertProductComment(commentDTO);
        return "success";
    }
    
    @PostMapping("/product_comment_delete.go")
    @ResponseBody
    public String deleteProductComment(@RequestParam("comment_id") int commentId) {
        mapper.deleteProductComment(commentId);
        return "success";
    }

    @PostMapping("/product_comment_update.go")
    @ResponseBody
    public String updateProductComment(@RequestParam("comment_id") int commentId,
                                       @RequestParam("comment_content") String commentContent) {
        mapper.updateProductComment(commentId, commentContent);
        return "success";
    }
    
    // 추가
    @PostMapping("/chat/leave")
    @ResponseBody
    public String leaveChat(@RequestParam("chat_room_num") int chatRoomNum,
                            @RequestParam("opponent_id") String opponentId,
                            HttpSession session) {
        UserDTO user = (UserDTO) session.getAttribute("user");
        if (user == null) return "fail_auth";

		// 내가 보낸 모든 메시지의 is_leave를 1로 변경
        mapper.leaveChatRoomForUser(chatRoomNum, user.getUser_id());

        // 상대방도 이미 나갔는지 확인
        int opponentLeft = mapper.checkIfOpponentLeft(chatRoomNum, opponentId);
        
        // 상대방도 나갔다면 (opponentLeft == 1), 채팅방의 모든 기록 삭제
        if (opponentLeft == 1) {
            mapper.deleteChatRoomHistory(chatRoomNum);
        }
        
        return "success";
    }
}
