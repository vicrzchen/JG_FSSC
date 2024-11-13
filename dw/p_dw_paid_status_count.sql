-- 创建表
CREATE TABLE IF NOT EXISTS ods.dw_paid_status_count (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
    stat_date DATE COMMENT '统计日期',
    stat_year INT COMMENT '统计年份',
    stat_month INT COMMENT '统计月份',
    stat_day INT COMMENT '统计日期',
    period_type VARCHAR(10) COMMENT '统计周期类型:day/month/year',
    paid_count INT COMMENT '支出笔数',
    paid_amount DECIMAL(20,2) COMMENT '支出金额(万元)',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_stat_period (stat_date, period_type)
) COMMENT '支付状态统计表';

-- 删除已存在的当天、当月、当年数据
DELETE FROM ods.dw_paid_status_count 
WHERE (stat_date = CURRENT_DATE AND period_type = 'day')
   OR (stat_date = DATE_FORMAT(CURRENT_DATE, '%Y-%m-01') AND period_type = 'month')
   OR (stat_date = DATE_FORMAT(CURRENT_DATE, '%Y-01-01') AND period_type = 'year');

-- 插入统计数据
INSERT INTO ods.dw_paid_status_count (
    stat_date,
    stat_year,
    stat_month,
    stat_day,
    period_type,
    paid_count,
    paid_amount
)
SELECT 
    dates.stat_date,
    YEAR(dates.stat_date) as stat_year,
    MONTH(dates.stat_date) as stat_month,
    DAY(dates.stat_date) as stat_day,
    dates.period_type,
    COUNT(DISTINCT CASE 
        WHEN dates.period_type = 'day' AND DATE(ap.paydate) = dates.stat_date THEN ap.billno
        WHEN dates.period_type = 'month' AND DATE_FORMAT(ap.paydate, '%Y-%m') = DATE_FORMAT(dates.stat_date, '%Y-%m') THEN ap.billno
        WHEN dates.period_type = 'year' AND YEAR(ap.paydate) = YEAR(dates.stat_date) THEN ap.billno
    END) as paid_count,
    ROUND(SUM(CASE 
        WHEN dates.period_type = 'day' AND DATE(ap.paydate) = dates.stat_date THEN ap.total_money
        WHEN dates.period_type = 'month' AND DATE_FORMAT(ap.paydate, '%Y-%m') = DATE_FORMAT(dates.stat_date, '%Y-%m') THEN ap.total_money
        WHEN dates.period_type = 'year' AND YEAR(ap.paydate) = YEAR(dates.stat_date) THEN ap.total_money
        ELSE 0
    END) / 10000, 2) as paid_amount
FROM (
    SELECT CURRENT_DATE as stat_date, 'day' as period_type
    UNION ALL SELECT DATE_FORMAT(CURRENT_DATE, '%Y-%m-01'), 'month'
    UNION ALL SELECT DATE_FORMAT(CURRENT_DATE, '%Y-01-01'), 'year'
) dates
CROSS JOIN (
    SELECT billno, PK_PAYBILL, MONEY AS total_money, paydate
    FROM ods.t_ncc_listed_ap_paybill
    WHERE dr = 0 AND BILLSTATUS = 8 AND def44 = 'Y'
) ap
LEFT JOIN ods.t_ncc_listed_ap_payitem ap2 
    ON ap.PK_PAYBILL = ap2.PK_PAYBILL 
    AND ap2.dr = 0
WHERE ap2.def10 = 'Y'
GROUP BY dates.stat_date, dates.period_type;
