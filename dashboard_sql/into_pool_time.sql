SELECT 
    SUM(avg_waiting_minutes * ticket_count) / SUM(ticket_count) AS avg_waiting_minutes,
    SUM(ticket_count) AS total_ticket_count,
    CURRENT_DATE() AS stat_date
FROM dm_waiting_time
WHERE stat_date = CURRENT_DATE();
