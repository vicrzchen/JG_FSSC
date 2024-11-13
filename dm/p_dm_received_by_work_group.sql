-- 创建表(如果不存在)
CREATE TABLE IF NOT EXISTS dm_received_tickets (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
    work_group VARCHAR(200) COMMENT '工作组',
    received_count INT COMMENT '接收数量',
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

-- 清空目标表
TRUNCATE TABLE dm_received_tickets;

-- 插入并转换数据
INSERT INTO dm_received_tickets (
    work_group, 
    received_count, 
    stat_date,
    stat_year,
    stat_month,
    stat_day,
    period_type, 
    company_type
)
SELECT 
    m.alias as work_group,
    d.received_count,
    d.stat_date,
    d.stat_year,
    d.stat_month,
    d.stat_day,
    d.period_type,
    d.company_type
FROM dw_received_tickets d
LEFT JOIN dw_work_group_mapping m ON d.work_group = m.code; 