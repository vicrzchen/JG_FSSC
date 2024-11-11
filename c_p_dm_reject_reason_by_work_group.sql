DELIMITER //

DROP PROCEDURE IF EXISTS p_dm_reject_reason_by_work_group//

CREATE PROCEDURE p_dm_reject_reason_by_work_group()
BEGIN
    -- 创建表(如果不存在)
    CREATE TABLE IF NOT EXISTS dm_reject_reason (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
        work_group VARCHAR(200) COMMENT '工作组',
        back_opinion VARCHAR(500) COMMENT '驳回原因',
        reject_count INT COMMENT '驳回数量',
        stat_date DATE COMMENT '统计日期',
        stat_year INT COMMENT '统计年份',
        stat_month INT COMMENT '统计月份',
        stat_day INT COMMENT '统计日期',
        company_type VARCHAR(10) COMMENT '公司类型:listed/unlisted',
        rank_no INT COMMENT '排名序号',
        is_total CHAR(1) DEFAULT 'N' COMMENT '是否合计：Y-是，N-否',
        create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        INDEX idx_stat_date (stat_date),
        INDEX idx_work_group (work_group)
    );

    -- 清空目标表
    TRUNCATE TABLE dm_reject_reason;

    -- 插入并转换数据
    INSERT INTO dm_reject_reason (
        work_group, 
        back_opinion, 
        reject_count, 
        stat_date,
        stat_year,
        stat_month,
        stat_day,
        company_type, 
        rank_no,
        is_total
    )
    SELECT 
        CASE 
            WHEN d.work_group = 'ALL' THEN 'ALL'
            ELSE m.alias 
        END as work_group,
        d.back_opinion,
        d.reject_count,
        d.stat_date,
        d.stat_year,
        d.stat_month,
        d.stat_day,
        d.company_type,
        d.rank_no,
        d.is_total
    FROM dw_reject_reason d
    LEFT JOIN dw_work_group_mapping m ON d.work_group = m.code;

END//

DELIMITER ; 