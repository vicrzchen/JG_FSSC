    -- 声明处理异常的handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 发生错误时回滚事务
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '执行DW层存储过程时发生错误';
    END;

    -- 开始事务
    START TRANSACTION;
    
    -- 按照数据依赖关系调用存储过程
    
    -- 1. 工作组映射表
    CALL p_dw_translate_work_group();
    
    -- 2. 基础统计数据
    CALL p_dw_paid_status_count();
    CALL p_dw_gl_voucher_by_company();
    
    -- 3. 工作组相关统计
    CALL p_dw_received_by_work_group();
    CALL p_dw_processed_by_work_group();
    CALL p_dw_working_staff_by_work_group();
    CALL p_dw_waiting_time_by_work_group();
    CALL p_dw_reject_reason_by_work_group();
    CALL p_dw_duration();
    
    -- 4. 申请组织相关统计
    CALL p_dw_processed_by_apply_org();
    CALL p_dw_reject_reason_by_apply_org();
    
    -- 5. 昨日处理情况统计
    CALL p_dw_last_day_processed_by_category_and_work_group();

    -- 提交事务
    COMMIT;
