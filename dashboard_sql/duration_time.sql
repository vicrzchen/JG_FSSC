-- 计算当天整体加权平均处理时长（分钟）
SELECT 
    ROUND(SUM(avg_duration / 60 * count) / SUM(count), 2) as avg_duration_minutes,
    SUM(count) as total_processed_count,
    stat_date
FROM dw_duration 
WHERE stat_date = CURRENT_DATE;
