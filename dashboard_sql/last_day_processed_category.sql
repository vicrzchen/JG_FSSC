SELECT 
    process_category AS '处理类别',
    SUM(count) AS '数量',
    ROUND(SUM(count) * 100.0 / (SELECT SUM(count) FROM ods.dm_last_day_processed WHERE stat_date = DATE_SUB(CURDATE(), INTERVAL 1 DAY)), 2) AS '占比(%)'
FROM ods.dm_last_day_processed
WHERE stat_date = DATE_SUB(CURDATE(), INTERVAL 1 DAY)
GROUP BY process_category
ORDER BY SUM(count) DESC;
