package com.chuizhipu.shop.controller;

import com.chuizhipu.shop.common.R;
import com.chuizhipu.shop.entity.User;
import com.chuizhipu.shop.service.UserService;
import com.chuizhipu.shop.util.TokenUtil;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    /** GET /api/users/me — 获取当前登录用户信息 */
    @GetMapping("/me")
    public R me(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        if (userId == null) return R.error(401, "请先登录");
        User user = userService.getById(userId);
        if (user == null) return R.error("用户不存在");
        user.setPassword(null);
        return R.ok(user);
    }

    /** GET /api/users/search — 搜索用户（按昵称/手机号） */
    @GetMapping("/search")
    public R search(@RequestParam String keyword) {
        return R.ok(userService.searchUsers(keyword));
    }

    /** GET /api/users/{id} */
    @GetMapping("/{id}")
    public R detail(@PathVariable Long id) {
        User user = userService.getById(id);
        if (user == null) return R.error("用户不存在");
        user.setPassword(null);
        return R.ok(user);
    }

    /** POST /api/users/register — 密码注册 */
    @PostMapping("/register")
    public R register(@RequestBody RegisterReq req) {
        if (req.getPhone() == null || req.getPhone().isEmpty()) return R.error("手机号不能为空");
        if (req.getPassword() == null || req.getPassword().length() < 6) return R.error("密码至少6位");
        if (req.getUsername() == null || req.getUsername().isEmpty()) return R.error("用户名不能为空");

        User exist = userService.getByPhone(req.getPhone());
        if (exist != null) return R.error("该手机号已注册");

        User user = new User();
        user.setPhone(req.getPhone());
        user.setPassword(req.getPassword());
        user.setNickname(req.getUsername());
        Long id = userService.register(user);
        user.setId(id);

        String token = TokenUtil.createToken(id);
        Map<String, Object> result = new HashMap<>();
        result.put("user", user);
        result.put("token", token);
        return R.ok(result);
    }

    /** POST /api/users/login — 密码登录 */
    @PostMapping("/login")
    public R login(@RequestBody LoginReq req) {
        if (req.getPhone() == null || req.getPhone().isEmpty()) return R.error("手机号不能为空");

        User user;
        if (req.getPassword() != null && !req.getPassword().isEmpty()) {
            // 密码登录
            user = userService.login(req.getPhone(), req.getPassword());
            if (user == null) return R.error("手机号或密码错误");
        } else {
            // 手机号一键登录/注册（无需密码）
            user = userService.phoneLogin(req.getPhone());
        }

        user.setPassword(null);
        String token = TokenUtil.createToken(user.getId());
        Map<String, Object> result = new HashMap<>();
        result.put("user", user);
        result.put("token", token);
        return R.ok(result);
    }

    /** POST /api/users/logout — 退出登录 */
    @PostMapping("/logout")
    public R logout(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            TokenUtil.removeToken(authHeader.substring(7));
        }
        return R.ok(null);
    }

    /** PUT /api/users/profile — 更新资料（需登录） */
    @PutMapping("/profile")
    public R updateProfile(HttpServletRequest request, @RequestBody User user) {
        Long userId = (Long) request.getAttribute("currentUserId");
        if (userId == null) return R.error(401, "请先登录");
        user.setId(userId);
        userService.updateProfile(user);
        return R.ok(null);
    }

    public static class LoginReq {
        private String phone;
        private String password;
        public String getPhone() { return phone; }
        public void setPhone(String phone) { this.phone = phone; }
        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }
    }

    public static class RegisterReq {
        private String username;
        private String phone;
        private String password;
        public String getUsername() { return username; }
        public void setUsername(String username) { this.username = username; }
        public String getPhone() { return phone; }
        public void setPhone(String phone) { this.phone = phone; }
        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }
    }
}
