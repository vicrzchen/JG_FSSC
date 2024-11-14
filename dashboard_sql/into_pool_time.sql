-- 创建表(如果不存在)
CREATE TABLE IF NOT EXISTS into_pool_time (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
    avg_waiting_minutes DECIMAL(20,2) COMMENT '平均等待时间(分钟)',
    total_ticket_count INT COMMENT '总单量',
    stat_date DATE COMMENT '统计日期',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
);

-- 清空目标表
TRUNCATE TABLE into_pool_time;

-- 插入当天的加权平均等待时间和总单量
INSERT INTO into_pool_time (
    avg_waiting_minutes,
    total_ticket_count,
    stat_date
)
SELECT 
    SUM(avg_waiting_minutes * ticket_count) / SUM(ticket_count) AS avg_waiting_minutes,
    SUM(ticket_count) AS total_ticket_count,
    CURRENT_DATE() AS stat_date
FROM dm_waiting_time
WHERE stat_date = CURRENT_DATE();
