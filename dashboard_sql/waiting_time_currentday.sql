SELECT 
    work_group AS '工作组',
    ROUND(avg_waiting_minutes, 2) AS '平均等待时间(分钟)'
FROM ods.dm_waiting_time 
WHERE stat_date = CURRENT_DATE()
    AND period_type = 'day'
ORDER BY avg_waiting_minutes DESC;
