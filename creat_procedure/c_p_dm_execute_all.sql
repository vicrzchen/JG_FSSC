DELIMITER //

DROP PROCEDURE IF EXISTS p_dm_execute_all//

CREATE PROCEDURE p_dm_execute_all()
BEGIN
    -- 声明处理异常的handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 发生错误时回滚事务
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '执行DM层存储过程时发生错误';
    END;

    -- 开始事务
    START TRANSACTION;
    
    -- 按照数据依赖关系调用存储过程
    
    -- 1. 工作组相关统计
    CALL p_dm_received_by_work_group();
    CALL p_dm_processed_by_work_group();
    CALL p_dm_working_staff_by_work_group();
    CALL p_dm_waiting_time_by_work_group();
    CALL p_dm_reject_reason_by_work_group();
    
    -- 2. 申请组织相关统计
    CALL p_dm_processed_by_apply_org();
    CALL p_dm_reject_reason_by_apply_org();
    
    -- 3. 昨日处理情况统计
    CALL p_dm_last_day_processed_by_category_and_work_group();

    -- 提交事务
    COMMIT;
    
END //

DELIMITER ; 