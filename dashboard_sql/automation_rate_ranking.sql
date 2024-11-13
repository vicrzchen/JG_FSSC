SELECT 
    o.name as company_name,
    ROUND(IFNULL(
        SUM(CASE WHEN v.is_gl = 0 THEN v.voucher_count ELSE 0 END) * 100.0 / 
        NULLIF(SUM(v.voucher_count), 0), 
        0
    ), 2) as automation_rate
FROM ods.dw_gl_voucher_by_company v
LEFT JOIN ods.t_share_org_corp o ON v.pk_org = o.id_
WHERE 
    DATE_FORMAT(v.stat_date, '%Y-%m') = DATE_FORMAT(CURRENT_DATE, '%Y-%m')
    AND LENGTH(o.code) = 4  -- 只选择编码长度为4的组织
GROUP BY v.pk_org, o.name
HAVING SUM(v.voucher_count) > 0  -- 确保只包含有凭证的组织
ORDER BY automation_rate DESC, o.code ASC
LIMIT 10;
