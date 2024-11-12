-- 创建表(如果不存在)
CREATE TABLE IF NOT EXISTS ods.dm_last_day_processed (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
    work_group VARCHAR(200) COMMENT '工作组',
    process_category VARCHAR(20) COMMENT '处理类别',
    count INT COMMENT '数量',
    stat_date DATE COMMENT '统计日期',
    stat_year INT COMMENT '统计年份',
    stat_month INT COMMENT '统计月份',
    stat_day INT COMMENT '统计日期',
    company_type VARCHAR(10) COMMENT '公司类型:listed/unlisted',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_stat_date (stat_date),
    INDEX idx_work_group (work_group)
) COMMENT '工作组每日处理统计结果表';

-- 清空目标表
TRUNCATE TABLE ods.dm_last_day_processed;

-- 插入并转换数据
INSERT INTO ods.dm_last_day_processed (
    work_group, 
    process_category, 
    count, 
    stat_date,
    stat_year,
    stat_month,
    stat_day,
    company_type
)
SELECT 
    m.alias as work_group,
    d.process_category,
    d.count,
    d.stat_date,
    d.stat_year,
    d.stat_month,
    d.stat_day,
    d.company_type
FROM ods.dw_last_day_processed d
LEFT JOIN ods.dw_work_group_mapping m ON d.work_group = m.code;
