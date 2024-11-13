-- 统计当天的接收量、处理量和人均处理量
SELECT 
    t1.period_type as '统计周期',
    t1.total_received as '接收量',
    t2.total_processed as '处理量',
    ROUND(t2.total_processed / t3.total_staff, 2) as '人均处理量'
FROM (
    -- 接收量统计
    SELECT 
        period_type,
        SUM(received_count) as total_received
    FROM ods.dm_received_tickets
    WHERE period_type = 'day' 
    AND stat_date = CURDATE()
    GROUP BY period_type
) t1
LEFT JOIN (
    -- 处理量统计
    SELECT 
        period_type,
        SUM(processed_count) as total_processed
    FROM ods.dm_processed_tickets
    WHERE period_type = 'day' 
    AND stat_date = CURDATE()
    GROUP BY period_type
) t2 ON t1.period_type = t2.period_type
LEFT JOIN (
    -- 工作人员数量统计
    SELECT 
        period_type,
        SUM(staff_count) as total_staff
    FROM ods.dm_working_staff
    WHERE period_type = 'day' 
    AND stat_date = CURDATE()
    GROUP BY period_type
) t3 ON t1.period_type = t3.period_type; 