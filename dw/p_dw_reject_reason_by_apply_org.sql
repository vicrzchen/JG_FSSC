-- 创建表(如果不存在)
CREATE TABLE IF NOT EXISTS dw_reject_by_org (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
    apply_org VARCHAR(100) COMMENT '申请组织',
    work_group VARCHAR(50) COMMENT '工作组',
    company_type VARCHAR(10) COMMENT '公司类型:listed/unlisted',
    reject_count INT COMMENT '驳回数量',
    stat_date DATE COMMENT '统计日期',
    stat_year INT COMMENT '统计年份',
    stat_month INT COMMENT '统计月份',
    stat_day INT COMMENT '统计日期，如果统计月份这里统一放1',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_stat_date (stat_date),
    INDEX idx_apply_org (apply_org),
    INDEX idx_work_group (work_group),
    INDEX idx_company_type (company_type)
);

-- 删除本月的数据
DELETE FROM dw_reject_by_org
WHERE stat_date = DATE_FORMAT(CURRENT_DATE, '%Y-%m-01');

-- 插入本月各组织的驳回统计
INSERT INTO dw_reject_by_org (
    apply_org,
    work_group,
    company_type,
    reject_count,
    stat_date,
    stat_year,
    stat_month,
    stat_day
)
SELECT 
    fi.apply_org,
    fi.work_group,
    CASE 
        WHEN fi.work_group IN ('GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ') THEN 'listed'
        WHEN fi.work_group IN ('GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB') THEN 'unlisted'
    END as company_type,
    COUNT(fi.bill_no) as reject_count,
    DATE_FORMAT(CURRENT_DATE, '%Y-%m-01') as stat_date,
    YEAR(CURRENT_DATE) as stat_year,
    MONTH(CURRENT_DATE) as stat_month,
    1 as stat_day
FROM t_share_fssc_inst fi
WHERE fi.del_flag_ = 0
    AND fi.task_state = 'REJECTTED'
    AND DATE_FORMAT(fi.create_time_, '%Y-%m') = DATE_FORMAT(CURRENT_DATE, '%Y-%m')
GROUP BY 
    fi.apply_org, 
    fi.work_group,
    CASE 
        WHEN fi.work_group IN ('GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ') THEN 'listed'
        WHEN fi.work_group IN ('GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB') THEN 'unlisted'
    END; 