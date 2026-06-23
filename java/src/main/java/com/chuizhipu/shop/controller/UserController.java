package com.chuizhipu.shop.controller;

import com.chuizhipu.shop.common.R;
import com.chuizhipu.shop.entity.User;
import com.chuizhipu.shop.service.UserService;
import org.springframework.web.bind.annotation.*;

/**
 * 用户接口
 */
@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    /** GET /api/users/{id} */
    @GetMapping("/{id}")
    public R detail(@PathVariable Long id) {
        User user = userService.getById(id);
        if (user == null) {
            return R.error("用户不存在");
        }
        user.setPassword(null);  // 不暴露密码
        return R.ok(user);
    }

    /** POST /api/users/login — 手机号登录 */
    @PostMapping("/login")
    public R login(@RequestBody LoginReq req) {
        User user = userService.getByPhone(req.getPhone());
        if (user == null) {
            // 新用户自动注册
            User newUser = new User();
            newUser.setPhone(req.getPhone());
            newUser.setNickname("非遗爱好者");
            newUser.setAvatar("");
            Long id = userService.register(newUser);
            newUser.setId(id);
            newUser.setPassword(null);
            return R.ok(newUser);
        }
        user.setPassword(null);
        return R.ok(user);
    }

    /** PUT /api/users/{id} — 更新资料 */
    @PutMapping("/{id}")
    public R updateProfile(@PathVariable Long id, @RequestBody User user) {
        user.setId(id);
        userService.updateProfile(user);
        return R.ok(null);
    }

    public static class LoginReq {
        private String phone;
        public String getPhone() { return phone; }
        public void setPhone(String phone) { this.phone = phone; }
    }
}
