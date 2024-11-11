DELIMITER //

DROP PROCEDURE IF EXISTS p_dm_waiting_time_by_work_group//

CREATE PROCEDURE p_dm_waiting_time_by_work_group()
BEGIN
    -- 创建表(如果不存在)
    CREATE TABLE IF NOT EXISTS dm_waiting_time (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
        work_group VARCHAR(200) COMMENT '工作组',
        total_waiting_minutes DECIMAL(20,2) COMMENT '总等待时间(分钟)',
        avg_waiting_minutes DECIMAL(20,2) COMMENT '平均等待时间(分钟)',
        ticket_count INT COMMENT '统计单据数',
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

    -- 清空目���表
    TRUNCATE TABLE dm_waiting_time;

    -- 插入并转换数据
    INSERT INTO dm_waiting_time (
        work_group, 
        total_waiting_minutes, 
        avg_waiting_minutes,
        ticket_count,
        stat_date,
        stat_year,
        stat_month,
        stat_day,
        period_type, 
        company_type
    )
    SELECT 
        m.alias as work_group,
        d.total_waiting_minutes,
        d.avg_waiting_minutes,
        d.ticket_count,
        d.stat_date,
        d.stat_year,
        d.stat_month,
        d.stat_day,
        d.period_type,
        d.company_type
    FROM dw_waiting_time d
    LEFT JOIN dw_work_group_mapping m ON d.work_group = m.code;

END//

DELIMITER ; 