DELIMITER //

DROP PROCEDURE IF EXISTS p_dw_last_day_processed_by_category_and_work_group//

CREATE PROCEDURE p_dw_last_day_processed_by_category_and_work_group()
BEGIN
    -- 创建表(如果不存在)
    CREATE TABLE IF NOT EXISTS dw_last_day_processed (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
        work_group VARCHAR(50) COMMENT '工作组',
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
    );

    -- 删除昨天的数据
    DELETE FROM dw_last_day_processed 
    WHERE stat_date = DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY);

    -- 插入统计数据
    INSERT INTO dw_last_day_processed (
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
        work_group,
        process_category,
        COUNT(1) as count,
        DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY) as stat_date,
        YEAR(DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY)) as stat_year,
        MONTH(DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY)) as stat_month,
        DAY(DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY)) as stat_day,
        CASE 
            WHEN work_group IN ('GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ') THEN 'listed'
            WHEN work_group IN ('GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB') THEN 'unlisted'
        END as company_type
    FROM (
        -- 已审核
        SELECT work_group, '已审核' as process_category
        FROM t_share_fssc_inst
        WHERE del_flag_ = 0
            AND fssc_process_state = 2
            AND DATE(create_time_) = DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY)
            AND work_group IN (
                'GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 
                'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ',
                'GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB'
            )
        
        UNION ALL
        
        -- 已挂起
        SELECT work_group, '已挂起' as process_category
        FROM t_share_fssc_inst
        WHERE del_flag_ = 0
            AND task_state = 'SUSPENDED'
            AND DATE(create_time_) = DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY)
            AND work_group IN (
                'GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 
                'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ',
                'GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB'
            )
        
        UNION ALL
        
        -- 待调整
        SELECT work_group, '待调整' as process_category
        FROM t_share_fssc_inst
        WHERE del_flag_ = 0
            AND task_state = 'ADJUST'
            AND DATE(create_time_) = DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY)
            AND work_group IN (
                'GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 
                'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ',
                'GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB'
            )
        
        UNION ALL
        
        -- 已提单待审核
        SELECT work_group, '已提单待审核' as process_category
        FROM t_share_fssc_inst
        WHERE del_flag_ = 0
            AND task_state = 'UNHANDLE'
            AND DATE(create_time_) = DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY)
            AND work_group IN (
                'GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 
                'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ',
                'GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB'
            )
        
        UNION ALL
        
        -- 待提取
        SELECT work_group, '待提取' as process_category
        FROM t_share_fssc_inst
        WHERE del_flag_ = 0
            AND task_state = 'UNPICKUP'
            AND DATE(create_time_) = DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY)
            AND work_group IN (
                'GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 
                'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ',
                'GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB'
            )
    ) t
    GROUP BY work_group, process_category;

END//

DELIMITER ; 