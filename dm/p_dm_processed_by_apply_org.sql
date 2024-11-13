-- 创建表(如果不存在)
CREATE TABLE IF NOT EXISTS dm_processed_by_org (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
    apply_org VARCHAR(100) COMMENT '原始申请组织',
    org_code VARCHAR(50) COMMENT '组织编码',
    org_name VARCHAR(100) COMMENT '组织名称',
    work_group VARCHAR(200) COMMENT '工作组',
    processed_count INT COMMENT '已处理数量',
    stat_date DATE COMMENT '统计日期',
    stat_year INT COMMENT '统计年份',
    stat_month INT COMMENT '统计月份',
    stat_day INT COMMENT '统计日期',
    company_type VARCHAR(10) COMMENT '公司类型:listed/unlisted',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_stat_date (stat_date),
    INDEX idx_apply_org (apply_org),
    INDEX idx_org_code (org_code),
    INDEX idx_work_group (work_group),
    INDEX idx_company_type (company_type)
);

-- 清空目标表
TRUNCATE TABLE dm_processed_by_org;

-- 插入并转换数据
INSERT INTO dm_processed_by_org (
    apply_org,
    org_code,
    org_name,
    work_group,
    processed_count,
    stat_date,
    stat_year,
    stat_month,
    stat_day,
    company_type
)
SELECT 
    d.apply_org,
    o.code as org_code,
    o.name as org_name,
    m.alias as work_group,
    d.processed_count,
    d.stat_date,
    d.stat_year,
    d.stat_month,
    d.stat_day,
    d.company_type
FROM dw_processed_by_org d
LEFT JOIN dw_work_group_mapping m ON d.work_group = m.code
LEFT JOIN t_share_org_corp o ON d.apply_org = o.id_; 