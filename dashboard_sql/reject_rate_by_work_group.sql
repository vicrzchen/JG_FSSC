-- 选择工作组及其对应的驳回率，驳回率为总驳回数除以总处理数

SELECT 
    work_group as 工作组,  -- 工作组名称
    company_type as 公司类型,  -- 新增公司类型字段
    ROUND(IFNULL(
        total_rejects / NULLIF(total_processed, 0),  -- 计算驳回率，避免除以零
        0  -- 如果总处理数为零，则驳回率默认为0
    ) , 2) as 驳回率  -- 保留两位小数
FROM (
    -- 计算每个工作组的总驳回数和总处理数
    SELECT 
        r.work_group,
        r.company_type,  -- 新增company_type字段
        SUM(r.reject_count) as total_rejects,  -- 计算工作组总驳回数
        p.total_processed as total_processed  -- 获取工作组总处理数
    FROM ods.dm_reject_by_org r
    LEFT JOIN (
        -- 汇总当前年份和月份的每个工作组的总处理数
        SELECT 
            work_group,
            stat_year,
            stat_month,
            SUM(processed_count) as total_processed  -- 计算总处理数
        FROM ods.dm_processed_tickets
        WHERE stat_year = YEAR(CURRENT_DATE)  -- 过滤当前年份
            AND stat_month = MONTH(CURRENT_DATE)  -- 过滤当前月份
            AND period_type = 'month'  -- 只考虑月度数据
        GROUP BY work_group, stat_year, stat_month  -- 按工作组、年份和月份分组
    ) p ON r.work_group = p.work_group 
        AND r.stat_year = p.stat_year 
        AND r.stat_month = p.stat_month  -- 关联匹配工作组及年月
    WHERE 
        r.stat_year = YEAR(CURRENT_DATE)  -- 过滤当前年份
        AND r.stat_month = MONTH(CURRENT_DATE)  -- 过滤当前月份
        AND r.work_group IS NOT NULL  -- 确保工作组不为空
    GROUP BY r.work_group, r.company_type  -- 按工作组和公司类型分组
) monthly_stats
WHERE total_processed > 0  -- 只选择有处理数的记录
ORDER BY  驳回率 DESC, 公司类型 ASC  -- 先按公司类型，再按驳回率降序排序
LIMIT 20;  -- 限制结果为前10条
