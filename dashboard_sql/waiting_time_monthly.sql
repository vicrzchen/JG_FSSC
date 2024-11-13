SELECT 
    CONCAT(stat_year, '-', LPAD(stat_month, 2, '0')) AS '月份',
    ROUND(
        SUM(avg_waiting_minutes * ticket_count) / SUM(ticket_count), 
        2
    ) AS '平均等待时间(分钟)'
FROM ods.dm_waiting_time 
WHERE period_type = 'month'
    AND stat_year = YEAR(CURRENT_DATE())
GROUP BY stat_year, stat_month
ORDER BY stat_month ASC; 