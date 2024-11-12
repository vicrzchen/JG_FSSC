SELECT 
    back_opinion as reject_reason,
    reject_count,
    CONCAT(ROUND(reject_count * 100.0 / (
        SELECT SUM(reject_count) 
        FROM ods.dm_reject_reason 
        WHERE work_group = 'ALL'
          AND stat_year = YEAR(CURRENT_DATE)
          AND stat_month = MONTH(CURRENT_DATE)
          AND company_type = 'ALL'
    ), 2), '%') as percentage
FROM ods.dm_reject_reason
WHERE work_group = 'ALL'
    AND stat_year = YEAR(CURRENT_DATE)
    AND stat_month = MONTH(CURRENT_DATE)
    AND company_type = 'ALL'
ORDER BY reject_count DESC
LIMIT 3;
