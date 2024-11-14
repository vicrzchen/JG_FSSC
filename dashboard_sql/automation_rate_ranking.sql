SELECT 
    o4.name AS company_name,  -- 使用编码长度为 4 的组织名称作为公司名称
    ROUND(IFNULL(
        SUM(CASE WHEN v.is_gl = 0 THEN v.voucher_count ELSE 0 END) / 
        NULLIF(SUM(v.voucher_count), 0), 
        0
    ), 2) AS automation_rate     -- 计算自动化率，保留两位小数
FROM ods.dw_gl_voucher_by_company v
LEFT JOIN ods.t_share_org_corp o ON v.pk_org = o.id_  -- 将凭证数据与组织信息关联
LEFT JOIN ods.t_share_org_corp o4 ON LEFT(o.code, 4) = o4.code AND LENGTH(o4.code) = 4
                                     -- 将组织表再次关联，匹配编码前 4 位且长度为 4 的组织
WHERE 
    DATE_FORMAT(v.stat_date, '%Y-%m') = DATE_FORMAT(CURRENT_DATE, '%Y-%m')
    -- 过滤出当前月份的数据
    AND o4.code IS NOT NULL  -- 确保只包含有效的 4 位编码组织
GROUP BY o4.code, o4.name    -- 按编码前 4 位的组织进行分组
HAVING SUM(v.voucher_count) > 0  -- 仅包含有凭证数量的组织
ORDER BY automation_rate DESC, o4.code ASC  -- 按自动化率降序排列，编码升序排列
LIMIT 10;  -- 只取前 10 条记录
