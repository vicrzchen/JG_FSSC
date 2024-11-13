DELIMITER //

DROP PROCEDURE IF EXISTS p_dw_reject_reason_by_work_group//

CREATE PROCEDURE p_dw_reject_reason_by_work_group()
BEGIN
    -- 初始化变量
    SET @rank := 0;
    SET @current_group := '';
    SET @rn := 0;

    -- 创建表(如果不存在)
    CREATE TABLE IF NOT EXISTS dw_reject_reason (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
        work_group VARCHAR(50) COMMENT '工作组',
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

    -- 删除本月的数据
    DELETE FROM dw_reject_reason 
    WHERE stat_date = DATE_FORMAT(CURRENT_DATE, '%Y-%m-01');

    -- 创建临时表存储统计结果
    CREATE TEMPORARY TABLE tmp_reject_stats (
        work_group VARCHAR(50),
        back_opinion VARCHAR(500),
        reject_count INT,
        stat_date DATE,
        stat_year INT,
        stat_month INT,
        stat_day INT,
        company_type VARCHAR(10)
    );

    -- 插入按工作组统计的数据
    INSERT INTO tmp_reject_stats
    SELECT 
        fi.work_group,
        ft.back_opinion,
        COUNT(fi.bill_no) as reject_count,
        DATE_FORMAT(CURRENT_DATE, '%Y-%m-01') as stat_date,
        YEAR(CURRENT_DATE) as stat_year,
        MONTH(CURRENT_DATE) as stat_month,
        1 as stat_day,
        CASE 
            WHEN fi.work_group IN ('GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ') THEN 'listed'
            WHEN fi.work_group IN ('GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB') THEN 'unlisted'
        END as company_type
    FROM t_share_fssc_inst fi
    LEFT JOIN t_share_fssc_task ft ON fi.task_no = ft.task_no
    WHERE fi.del_flag_ = 0
        AND fi.task_state = 'REJECTTED'
        AND ft.back_opinion != '99'
        AND DATE_FORMAT(fi.create_time_, '%Y-%m') = DATE_FORMAT(CURRENT_DATE, '%Y-%m')
        AND fi.work_group IN (
            'GXZX_GXCBZ', 'GXZX_GXSRZ', 'GXZX_GXSRCBZ', 'GXZX_ZCCHZ', 
            'GXZX_FYXCZ', 'GZZXZ_ZZBBZ', 'GZZX_SWZ',
            'GXZX_JYB_FSS', 'GXZX_FSSZZBBB', 'GXZX_FSSHSB'
        )
    GROUP BY fi.work_group, ft.back_opinion;

    -- 创建临时表存储工作组排名
    CREATE TEMPORARY TABLE tmp_reject_rank AS
    SELECT 
        t.*,
        @rank := IF(@current_group = t.work_group, @rank + 1,
            IF(@current_group := t.work_group, 1, 1)
        ) AS rank_no
    FROM (
        SELECT 
            work_group,
            back_opinion,
            reject_count,
            stat_date,
            stat_year,
            stat_month,
            stat_day,
            company_type
        FROM tmp_reject_stats
        ORDER BY work_group, reject_count DESC
    ) t;

    -- 插入按工作组的TOP10
    INSERT INTO dw_reject_reason (
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
        work_group,
        back_opinion,
        reject_count,
        stat_date,
        stat_year,
        stat_month,
        stat_day,
        company_type,
        rank_no,
        'N'
    FROM tmp_reject_rank
    WHERE rank_no <= 10;

    -- 插入总的TOP10
    INSERT INTO dw_reject_reason (
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
        'ALL' AS work_group,
        t.back_opinion,
        t.total_count AS reject_count,
        t.stat_date,
        t.stat_year,
        t.stat_month,
        t.stat_day,
        'ALL' AS company_type,
        @rn := @rn + 1 AS rank_no,
        'Y'
    FROM (
        SELECT 
            back_opinion,
            SUM(reject_count) AS total_count,
            stat_date,
            stat_year,
            stat_month,
            stat_day
        FROM tmp_reject_stats
        GROUP BY back_opinion, stat_date, stat_year, stat_month, stat_day
        ORDER BY total_count DESC
        LIMIT 10
    ) t;

    -- 删除临时表
    DROP TEMPORARY TABLE IF EXISTS tmp_reject_stats;
    DROP TEMPORARY TABLE IF EXISTS tmp_reject_rank;

END//

DELIMITER ; 