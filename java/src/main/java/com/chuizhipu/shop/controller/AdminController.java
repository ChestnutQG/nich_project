package com.chuizhipu.shop.controller;

import com.chuizhipu.shop.common.R;
import com.chuizhipu.shop.entity.*;
import com.chuizhipu.shop.mapper.*;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final UserMapper userMapper;
    private final DisputeMapper disputeMapper;
    private final OrderMapper orderMapper;
    private final ProductMapper productMapper;

    public AdminController(UserMapper userMapper, DisputeMapper disputeMapper,
                           OrderMapper orderMapper, ProductMapper productMapper) {
        this.userMapper = userMapper;
        this.disputeMapper = disputeMapper;
        this.orderMapper = orderMapper;
        this.productMapper = productMapper;
    }

    /** GET /api/admin/disputes — 所有纠纷列表 */
    @GetMapping("/disputes")
    public R allDisputes(@RequestParam(required = false) String status) {
        List<Dispute> list;
        if (status != null && !status.isEmpty()) {
            list = disputeMapper.selectByStatus(status);
        } else {
            // 所有状态的纠纷
            List<Dispute> all = new ArrayList<>();
            all.addAll(disputeMapper.selectByStatus("negotiating"));
            all.addAll(disputeMapper.selectByStatus("voting"));
            all.addAll(disputeMapper.selectByStatus("resolved"));
            list = all;
        }
        return R.ok(list);
    }

    /** GET /api/admin/users — 用户列表 */
    @GetMapping("/users")
    public R allUsers() {
        List<User> users = userMapper.selectAll();
        List<Map<String, Object>> result = new ArrayList<>();
        for (User u : users) {
            Map<String, Object> map = new LinkedHashMap<>();
            map.put("id", u.getId().toString());
            map.put("nickname", u.getNickname());
            map.put("phone", u.getPhone());
            map.put("role", u.getRole());
            map.put("creditScore", u.getCreditScore());
            map.put("status", u.getStatus());
            map.put("collectCount", u.getCollectCount());
            map.put("followCount", u.getFollowCount());
            map.put("orderCount", u.getOrderCount());
            result.add(map);
        }
        return R.ok(result);
    }

    /** PUT /api/admin/users/{id}/freeze — 冻结/解冻用户 */
    @PutMapping("/users/{id}/freeze")
    public R freezeUser(@PathVariable Long id, @RequestBody Map<String, String> body) {
        User user = userMapper.selectById(id);
        if (user == null) return R.error("用户不存在");
        String newStatus = "frozen".equals(user.getStatus()) ? "active" : "frozen";
        user.setStatus(newStatus);
        userMapper.updateById(user);
        return R.ok("用户已" + ("frozen".equals(newStatus) ? "冻结" : "解冻"));
    }

    /** PUT /api/admin/users/{id}/credit — 调整信用分 */
    @PutMapping("/users/{id}/credit")
    public R adjustCredit(@PathVariable Long id, @RequestBody Map<String, Integer> body) {
        User user = userMapper.selectById(id);
        if (user == null) return R.error("用户不存在");
        Integer score = body.get("creditScore");
        if (score == null || score < 0 || score > 200) return R.error("信用分范围 0-200");
        user.setCreditScore(score);
        userMapper.updateById(user);
        return R.ok("信用分已更新为 " + score);
    }

    /** PUT /api/admin/users/{id}/role — 修改角色 */
    @PutMapping("/users/{id}/role")
    public R changeRole(@PathVariable Long id, @RequestBody Map<String, String> body) {
        User user = userMapper.selectById(id);
        if (user == null) return R.error("用户不存在");
        String role = body.get("role");
        if (role == null || !List.of("user", "artisan", "admin").contains(role))
            return R.error("角色只能是 user/artisan/admin");
        user.setRole(role);
        userMapper.updateById(user);
        return R.ok("角色已更新为 " + role);
    }

    /** GET /api/admin/stats — 管理端统计数据 */
    @GetMapping("/stats")
    public R stats() {
        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("negotiatingDisputes", disputeMapper.selectByStatus("negotiating").size());
        stats.put("votingDisputes", disputeMapper.selectByStatus("voting").size());
        stats.put("resolvedDisputes", disputeMapper.selectByStatus("resolved").size());
        stats.put("pendingProducts", productMapper.selectPending()
                .stream().filter(p -> "pending".equals(p.getAuditStatus())).count());
        return R.ok(stats);
    }

    /** GET /api/admin/products/pending — 待审核商品（审核页用） */
    @GetMapping("/products/pending")
    public R pendingProducts() {
        List<Product> list = productMapper.selectPending();
        List<Map<String, Object>> result = new ArrayList<>();
        for (Product p : list) {
            Map<String, Object> map = new LinkedHashMap<>();
            map.put("id", p.getId().toString());
            map.put("name", p.getName());
            map.put("price", p.getPrice());
            map.put("images", p.getImages());
            map.put("videoUrl", p.getVideoUrl());
            map.put("artisanName", p.getArtisanName());
            map.put("craftType", p.getCraftType());
            map.put("region", p.getRegion());
            map.put("auditStatus", p.getAuditStatus());
            map.put("createTime", p.getCreateTime() != null ? p.getCreateTime().toString() : "");
            result.add(map);
        }
        return R.ok(result);
    }

    /** PUT /api/admin/products/{id}/audit — 审核通过/驳回 */
    @PutMapping("/products/{id}/audit")
    public R auditProduct(@PathVariable Long id, @RequestBody Map<String, String> body) {
        String auditStatus = body.get("auditStatus");
        if (auditStatus == null || !List.of("approved", "rejected").contains(auditStatus)) {
            return R.error("审核结果只能是 approved 或 rejected");
        }
        productMapper.updateAuditStatus(id, auditStatus);
        return R.ok(auditStatus.equals("approved") ? "已通过审核" : "已驳回");
    }
}
