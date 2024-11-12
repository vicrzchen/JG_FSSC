SELECT 
    MAX(CASE WHEN period_type = 'day' THEN paid_count END) as day_paid_count,
    MAX(CASE WHEN period_type = 'day' THEN paid_amount END) as day_paid_amount,
    MAX(CASE WHEN period_type = 'month' THEN paid_count END) as month_paid_count,
    MAX(CASE WHEN period_type = 'month' THEN paid_amount END) as month_paid_amount,
    MAX(CASE WHEN period_type = 'year' THEN paid_count END) as year_paid_count,
    MAX(CASE WHEN period_type = 'year' THEN paid_amount END) as year_paid_amount
FROM ods.dw_paid_status_count
WHERE (stat_year = YEAR(CURRENT_DATE)
    AND (
        (period_type = 'day' AND stat_month = MONTH(CURRENT_DATE) AND stat_day = DAY(CURRENT_DATE))
        OR (period_type = 'month' AND stat_month = MONTH(CURRENT_DATE) AND stat_day = 1)
        OR (period_type = 'year' AND stat_month = 1 AND stat_day = 1)
    )
);
