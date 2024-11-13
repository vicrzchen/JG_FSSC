SELECT 
    MAX(CASE WHEN period = 'day' AND rank = 1 THEN work_group END) as '当天第一',
    MAX(CASE WHEN period = 'day' AND rank = 1 THEN processed_count END) as '当天第一处理量',
    MAX(CASE WHEN period = 'day' AND rank = 2 THEN work_group END) as '当天第二',
    MAX(CASE WHEN period = 'day' AND rank = 2 THEN processed_count END) as '当天第二处理量',
    MAX(CASE WHEN period = 'day' AND rank = 3 THEN work_group END) as '当天第三',
    MAX(CASE WHEN period = 'day' AND rank = 3 THEN processed_count END) as '当天第三处理量',
    
    MAX(CASE WHEN period = 'month' AND rank = 1 THEN work_group END) as '本月第一',
    MAX(CASE WHEN period = 'month' AND rank = 1 THEN processed_count END) as '本月第一处理量',
    MAX(CASE WHEN period = 'month' AND rank = 2 THEN work_group END) as '本月第二',
    MAX(CASE WHEN period = 'month' AND rank = 2 THEN processed_count END) as '本月第二处理量',
    MAX(CASE WHEN period = 'month' AND rank = 3 THEN work_group END) as '本月第三',
    MAX(CASE WHEN period = 'month' AND rank = 3 THEN processed_count END) as '本月第三处理量',
    
    MAX(CASE WHEN period = 'year' AND rank = 1 THEN work_group END) as '本年第一',
    MAX(CASE WHEN period = 'year' AND rank = 1 THEN processed_count END) as '本年第一处理量',
    MAX(CASE WHEN period = 'year' AND rank = 2 THEN work_group END) as '本年第二',
    MAX(CASE WHEN period = 'year' AND rank = 2 THEN processed_count END) as '本年第二处理量',
    MAX(CASE WHEN period = 'year' AND rank = 3 THEN work_group END) as '本年第三',
    MAX(CASE WHEN period = 'year' AND rank = 3 THEN processed_count END) as '本年第三处理量'
FROM (
    -- 当天前三
    SELECT 
        t.*,
        @day_rank := @day_rank + 1 as rank
    FROM (
        SELECT 
            work_group,
            processed_count,
            'day' as period
        FROM ods.dm_processed_tickets
        WHERE period_type = 'day' 
        AND stat_date = CURRENT_DATE
        ORDER BY processed_count DESC
        LIMIT 3
    ) t, (SELECT @day_rank := 0) r

    UNION ALL

    -- 当月前三
    SELECT 
        t.*,
        @month_rank := @month_rank + 1 as rank
    FROM (
        SELECT 
            work_group,
            processed_count,
            'month' as period
        FROM ods.dm_processed_tickets
        WHERE period_type = 'month' 
        AND stat_year = YEAR(CURRENT_DATE)
        AND stat_month = MONTH(CURRENT_DATE)
        ORDER BY processed_count DESC
        LIMIT 3
    ) t, (SELECT @month_rank := 0) r

    UNION ALL

    -- 当年前三
    SELECT 
        t.*,
        @year_rank := @year_rank + 1 as rank
    FROM (
        SELECT 
            work_group,
            processed_count,
            'year' as period
        FROM ods.dm_processed_tickets
        WHERE period_type = 'year' 
        AND stat_year = YEAR(CURRENT_DATE)
        ORDER BY processed_count DESC
        LIMIT 3
    ) t, (SELECT @year_rank := 0) r
) combined;
