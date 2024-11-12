-- 删除2024年已存在的月度数据
DELETE FROM ods.dw_processed_tickets 
WHERE YEAR(stat_date) = 2024 
AND period_type = 'month';

-- 插入2024年所有月份的统计数据
INSERT INTO ods.dw_processed_tickets (
    work_group, 
    processed_count, 
    stat_date,
    stat_year,
    stat_month,
    stat_day,
    period_type, 
    company_type
)
SELECT 
    work_group,
    COUNT(1) as processed_count,
    DATE_FORMAT(create_time_, '%Y-%m-01') as stat_date,
    YEAR(create_time_) as stat_year,
    MONTH(create_time_) as stat_month,
    1 as stat_day,
    'month' as period_type,
    CASE 
        WHEN work_group IN ('GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ') THEN 'listed'
        WHEN work_group IN ('GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB') THEN 'unlisted'
    END as company_type
FROM ods.t_share_fssc_inst
WHERE del_flag_ = 0
    AND (fssc_process_state = 2 OR fssc_process_state = 3)
    AND work_group IN (
        'GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 
        'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ',
        'GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB'
    )
    AND YEAR(create_time_) = 2024
GROUP BY 
    work_group,
    DATE_FORMAT(create_time_, '%Y-%m-01');
