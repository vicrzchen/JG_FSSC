-- 创建表
CREATE TABLE IF NOT EXISTS ods.dw_gl_voucher_by_company (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
    stat_date DATE COMMENT '统计日期',
    stat_year INT COMMENT '统计年份', 
    stat_month INT COMMENT '统计月份',
    company_type VARCHAR(20) COMMENT '公司类型:listed/unlisted',
    pk_org VARCHAR(50) COMMENT '组织主键',
    voucher_count INT COMMENT '凭证数量',
    is_gl TINYINT(1) COMMENT '是否总账:1-是,0-否',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_stat_company (stat_date, company_type),
    INDEX idx_org (pk_org),
    INDEX idx_system (pk_system)
) COMMENT '公司凭证统计表';

-- 删除已存在的当月数据
DELETE FROM ods.dw_gl_voucher_by_company;

-- 插入统计数据
INSERT INTO ods.dw_gl_voucher_by_company (
    stat_date,
    stat_year,
    stat_month,
    company_type,
    pk_org,
    voucher_count,
    is_gl
)
-- 上市公司总账凭证统计
SELECT 
    DATE_FORMAT(ts, '%Y-%m-01') as stat_date,
    YEAR(ts) as stat_year,
    MONTH(ts) as stat_month,
    'listed' as company_type,
    pk_org,
    COUNT(*) as voucher_count,
    1 as is_gl
FROM 
    ods.t_ncc_listed_gl_voucher
WHERE pk_system = 'GL'
GROUP BY 
    DATE_FORMAT(ts, '%Y-%m-01'),
    YEAR(ts),
    MONTH(ts),
    pk_org

UNION ALL

-- 上市公司非总账凭证统计
SELECT 
    DATE_FORMAT(ts, '%Y-%m-01') as stat_date,
    YEAR(ts) as stat_year,
    MONTH(ts) as stat_month,
    'listed' as company_type,
    pk_org,
    COUNT(*) as voucher_count,
    0 as is_gl
FROM 
    ods.t_ncc_listed_gl_voucher
WHERE pk_system <> 'GL'
GROUP BY 
    DATE_FORMAT(ts, '%Y-%m-01'),
    YEAR(ts),
    MONTH(ts),
    pk_org

UNION ALL

-- 非上市公司总账凭证统计
SELECT 
    DATE_FORMAT(ts, '%Y-%m-01') as stat_date,
    YEAR(ts) as stat_year,
    MONTH(ts) as stat_month,
    'unlisted' as company_type,
    pk_org,
    COUNT(*) as voucher_count,
    1 as is_gl
FROM 
    ods.t_ncc_unlisted_gl_voucher
WHERE pk_system = 'GL'
GROUP BY 
    DATE_FORMAT(ts, '%Y-%m-01'),
    YEAR(ts),
    MONTH(ts),
    pk_org

UNION ALL

-- 非上市公司非总账凭证统计
SELECT 
    DATE_FORMAT(ts, '%Y-%m-01') as stat_date,
    YEAR(ts) as stat_year,
    MONTH(ts) as stat_month,
    'unlisted' as company_type,
    pk_org,
    COUNT(*) as voucher_count,
    0 as is_gl
FROM 
    ods.t_ncc_unlisted_gl_voucher
WHERE pk_system <> 'GL'
GROUP BY 
    DATE_FORMAT(ts, '%Y-%m-01'),
    YEAR(ts),
    MONTH(ts),
    pk_org;