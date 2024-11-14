SELECT 
    (@rank := @rank + 1) AS 排名,
    monthly_stats.org_name AS 二级公司名称,
    ROUND(IFNULL(
        monthly_stats.total_rejects / NULLIF(monthly_stats.total_processed, 0),
        0
    ), 2) AS 驳回率
FROM (
    SELECT 
        o4.code AS org_code,        -- 使用 4 位编码的组织编码
        o4.name AS org_name,        -- 使用 4 位编码的组织名称
        SUM(r.reject_count) AS total_rejects,      -- 总驳回数
        SUM(p.total_processed) AS total_processed  -- 总处理数
    FROM ods.dm_reject_by_org r
    LEFT JOIN ods.t_share_org_corp o ON r.apply_org = o.id_
        -- 将驳回数据与组织信息关联
    LEFT JOIN ods.t_share_org_corp o4 ON o4.code = LEFT(o.code, 4) AND LENGTH(o4.code) = 4
        -- 关联前 4 位编码且长度为 4 的组织，获取对应的名称
    LEFT JOIN (
        SELECT 
            o4_p.code AS org_code,      -- 4 位编码的组织编码
            p.stat_date,
            SUM(p.processed_count) AS total_processed
        FROM ods.dm_processed_by_org p
        LEFT JOIN ods.t_share_org_corp o_p ON p.apply_org = o_p.id_
            -- 将处理数据与组织信息关联
        LEFT JOIN ods.t_share_org_corp o4_p ON o4_p.code = LEFT(o_p.code, 4) AND LENGTH(o4_p.code) = 4
            -- 关联前 4 位编码且长度为 4 的组织
        WHERE 
            DATE_FORMAT(p.stat_date, '%Y-%m') = DATE_FORMAT(CURRENT_DATE, '%Y-%m')
            AND o4_p.code IS NOT NULL
        GROUP BY o4_p.code, p.stat_date
    ) p ON o4.code = p.org_code AND r.stat_date = p.stat_date
        -- 将驳回数据和处理数据按 4 位编码和统计日期关联
    WHERE 
        DATE_FORMAT(r.stat_date, '%Y-%m') = DATE_FORMAT(CURRENT_DATE, '%Y-%m')
        -- 仅选择当前月份的数据
        AND o4.code IS NOT NULL     -- 确保有有效的 4 位编码组织
    GROUP BY o4.code, o4.name      -- 按 4 位编码的组织进行分组
) monthly_stats, (SELECT @rank := 0) r
WHERE total_processed > 0
ORDER BY 驳回率 DESC, org_code ASC
LIMIT 10;
