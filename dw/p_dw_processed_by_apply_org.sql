-- 创建表(如果不存在)
CREATE TABLE IF NOT EXISTS dw_processed_by_org (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
    apply_org VARCHAR(100) COMMENT '申请组织',
    work_group VARCHAR(50) COMMENT '工作组',
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
    INDEX idx_work_group (work_group)
);

-- 删除本月的数据
DELETE FROM dw_processed_by_org 
WHERE stat_date = DATE_FORMAT(CURRENT_DATE, '%Y-%m-01');

-- 插入本月的统计数据
INSERT INTO dw_processed_by_org (
    apply_org,
    work_group,
    processed_count,
    stat_date,
    stat_year,
    stat_month,
    stat_day,
    company_type
)
SELECT 
    fi.apply_org,
    fi.work_group,
    COUNT(1) as processed_count,
    DATE_FORMAT(CURRENT_DATE, '%Y-%m-01') as stat_date,
    YEAR(CURRENT_DATE) as stat_year,
    MONTH(CURRENT_DATE) as stat_month,
    1 as stat_day,
    CASE 
        WHEN fi.work_group IN ('GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ') THEN 'listed'
        WHEN fi.work_group IN ('GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB') THEN 'unlisted'
    END as company_type
FROM t_share_fssc_inst fi
WHERE fi.del_flag_ = 0
    AND (fi.fssc_process_state = 2 OR fi.fssc_process_state = 3)
    AND fi.work_group IN (
        'GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 
        'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ',
        'GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB'
    )
    AND DATE_FORMAT(fi.create_time_, '%Y-%m') = DATE_FORMAT(CURRENT_DATE, '%Y-%m')
GROUP BY 
    fi.apply_org,
    fi.work_group,
    CASE 
        WHEN fi.work_group IN ('GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ') THEN 'listed'
        WHEN fi.work_group IN ('GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB') THEN 'unlisted'
    END;

-- 建议在t_share_fssc_inst表上创建如下索引
-- CREATE INDEX idx_fssc_inst_org ON t_share_fssc_inst(del_flag_, fssc_process_state, work_group, apply_org, create_time_); 