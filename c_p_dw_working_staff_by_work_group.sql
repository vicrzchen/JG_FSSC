DELIMITER //

DROP PROCEDURE IF EXISTS p_dw_working_staff_by_work_group//

CREATE PROCEDURE p_dw_working_staff_by_work_group()
BEGIN
    -- 创建表(如果不存在)
    CREATE TABLE IF NOT EXISTS dw_working_staff (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
        work_group VARCHAR(50) COMMENT '工作组',
        staff_count INT COMMENT '工作人员数量',
        stat_date DATE COMMENT '统计日期',
        stat_year INT COMMENT '统计年份',
        stat_month INT COMMENT '统计月份',
        stat_day INT COMMENT '统计日期',
        period_type VARCHAR(10) COMMENT '统计周期类型:day/month/year',
        company_type VARCHAR(10) COMMENT '公司类型:listed/unlisted',
        create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        INDEX idx_stat_period (stat_date, period_type)
    );

    -- 删除已存在的当天、当月、当年数据
    DELETE FROM dw_working_staff 
    WHERE (stat_date = CURRENT_DATE AND period_type = 'day')
       OR (stat_date = DATE_FORMAT(CURRENT_DATE, '%Y-%m-01') AND period_type = 'month')
       OR (stat_date = DATE_FORMAT(CURRENT_DATE, '%Y-01-01') AND period_type = 'year');

    -- 插入统计数据
    INSERT INTO dw_working_staff (
        work_group, 
        staff_count, 
        stat_date, 
        stat_year,
        stat_month,
        stat_day,
        period_type, 
        company_type
    )
    -- 当天数据统计
    SELECT 
        work_group,
        COUNT(DISTINCT handler_p1) as staff_count,
        CURRENT_DATE as stat_date,
        YEAR(CURRENT_DATE) as stat_year,
        MONTH(CURRENT_DATE) as stat_month,
        DAY(CURRENT_DATE) as stat_day,
        'day' as period_type,
        CASE 
            WHEN work_group IN ('GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ') THEN 'listed'
            WHEN work_group IN ('GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB') THEN 'unlisted'
        END as company_type
    FROM t_share_fssc_inst
    WHERE del_flag_ = 0
        AND (fssc_process_state = 2 OR fssc_process_state = 3)
        AND work_group IN (
            'GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 
            'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ',
            'GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB'
        )
        AND DATE(create_time_) = CURRENT_DATE
    GROUP BY work_group

    UNION ALL

    -- 当月数据统计
    SELECT 
        work_group,
        COUNT(DISTINCT handler_p1) as staff_count,
        DATE_FORMAT(CURRENT_DATE, '%Y-%m-01') as stat_date,
        YEAR(CURRENT_DATE) as stat_year,
        MONTH(CURRENT_DATE) as stat_month,
        1 as stat_day,
        'month' as period_type,
        CASE 
            WHEN work_group IN ('GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ') THEN 'listed'
            WHEN work_group IN ('GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB') THEN 'unlisted'
        END as company_type
    FROM t_share_fssc_inst
    WHERE del_flag_ = 0
        AND (fssc_process_state = 2 OR fssc_process_state = 3)
        AND work_group IN (
            'GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 
            'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ',
            'GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB'
        )
        AND DATE_FORMAT(create_time_, '%Y-%m') = DATE_FORMAT(CURRENT_DATE, '%Y-%m')
    GROUP BY work_group

    UNION ALL

    -- 当年数据统计
    SELECT 
        work_group,
        COUNT(DISTINCT handler_p1) as staff_count,
        DATE_FORMAT(CURRENT_DATE, '%Y-01-01') as stat_date,
        YEAR(CURRENT_DATE) as stat_year,
        1 as stat_month,
        1 as stat_day,
        'year' as period_type,
        CASE 
            WHEN work_group IN ('GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ') THEN 'listed'
            WHEN work_group IN ('GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB') THEN 'unlisted'
        END as company_type
    FROM t_share_fssc_inst
    WHERE del_flag_ = 0
        AND (fssc_process_state = 2 OR fssc_process_state = 3)
        AND work_group IN (
            'GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 
            'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ',
            'GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB'
        )
        AND YEAR(create_time_) = YEAR(CURRENT_DATE)
    GROUP BY work_group;

END//

DELIMITER ; 