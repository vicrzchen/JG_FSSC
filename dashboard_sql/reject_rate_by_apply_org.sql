SELECT 
    (@rank := @rank + 1) as 排名,
    org_name as 二级公司名称,
    ROUND(IFNULL(
        total_rejects / NULLIF(total_processed, 0),
        0
    ) , 2) as 驳回率
FROM (
    SELECT 
        r.apply_org,
        r.org_name,
        r.org_code,
        SUM(r.reject_count) as total_rejects,
        MAX(p.total_processed) as total_processed
    FROM ods.dm_reject_by_org r
    LEFT JOIN (
        SELECT 
            apply_org,
            stat_date,
            SUM(processed_count) as total_processed
        FROM ods.dm_processed_by_org
        WHERE DATE_FORMAT(stat_date, '%Y-%m') = DATE_FORMAT(CURRENT_DATE, '%Y-%m')
        GROUP BY apply_org, stat_date
    ) p ON r.apply_org = p.apply_org AND r.stat_date = p.stat_date
    WHERE 
        DATE_FORMAT(r.stat_date, '%Y-%m') = DATE_FORMAT(CURRENT_DATE, '%Y-%m')
        AND r.org_code IS NOT NULL
        AND LENGTH(r.org_code) = 4
    GROUP BY r.apply_org, r.org_name, r.org_code
) monthly_stats, (SELECT @rank := 0) r
WHERE total_processed > 0
ORDER BY 驳回率 DESC, org_code ASC
LIMIT 10;
