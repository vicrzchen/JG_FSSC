DELIMITER //

DROP PROCEDURE IF EXISTS p_dw_duration//

CREATE PROCEDURE p_dw_duration()
BEGIN
    -- 创建表(如果不存在)
    CREATE TABLE IF NOT EXISTS dw_duration (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
        work_group VARCHAR(50) COMMENT '工作组',
        avg_duration DECIMAL(10,2) COMMENT '平均处理时长(分钟)',
        count INT COMMENT '处理单量',
        stat_date DATE COMMENT '统计日期',
        stat_year INT COMMENT '统计年份',
        stat_month INT COMMENT '统计月份',
        stat_day INT COMMENT '统计日期',
        company_type VARCHAR(10) COMMENT '公司类型:listed/unlisted',
        create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        INDEX idx_stat_date (stat_date),
        INDEX idx_work_group (work_group)
    );

    -- 删除当天的数据
    DELETE FROM dw_duration 
    WHERE stat_date = CURRENT_DATE;

    -- 插入统计数据
    INSERT INTO dw_duration (
        work_group,
        avg_duration,
        count,
        stat_date,
        stat_year,
        stat_month,
        stat_day,
        company_type
    )
    SELECT 
        work_group,
        AVG(handle_duration1) as avg_duration,
        COUNT(1) as count,
        CURRENT_DATE as stat_date,
        YEAR(CURRENT_DATE) as stat_year,
        MONTH(CURRENT_DATE) as stat_month,
        DAY(CURRENT_DATE) as stat_day,
        CASE 
            WHEN work_group IN ('GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ') THEN 'listed'
            WHEN work_group IN ('GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB') THEN 'unlisted'
        END as company_type
    FROM ods.t_share_fssc_aging
    WHERE DATE(second_approved_time) = CURRENT_DATE
        AND work_group IN (
            'GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 
            'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ',
            'GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB'
        )
        AND handle_duration1 IS NOT NULL
    GROUP BY 
        work_group;

END//

DELIMITER ; 