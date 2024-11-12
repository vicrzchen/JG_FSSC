SELECT 
    r.stat_month as month,
    SUM(r.received_count) as total_received,
    SUM(p.processed_count) as total_processed
FROM 
    ods.dm_received_tickets r
    LEFT JOIN ods.dm_processed_tickets p ON 
        r.stat_year = p.stat_year 
        AND r.stat_month = p.stat_month
        AND r.period_type = p.period_type
WHERE 
    r.stat_year = YEAR(CURRENT_DATE)
    AND r.period_type = 'month'
GROUP BY 
    r.stat_month
ORDER BY 
    r.stat_month;
