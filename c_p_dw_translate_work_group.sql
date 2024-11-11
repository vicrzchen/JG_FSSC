DELIMITER //

DROP PROCEDURE IF EXISTS p_dw_translate_work_group//

CREATE PROCEDURE p_dw_translate_work_group()
BEGIN
    -- 创建新表
    CREATE TABLE IF NOT EXISTS ods.dw_work_group_mapping (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
        name VARCHAR(200) COMMENT '名称', 
        code VARCHAR(50) COMMENT '编码',
        alias VARCHAR(200) COMMENT '别名',
        create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
    ) COMMENT '工作组设置表';

    -- 清空表数据
    TRUNCATE TABLE ods.dw_work_group_mapping;

    -- 插入并转换数据
    INSERT INTO ods.dw_work_group_mapping (name, code, alias)
    SELECT 
        CASE 
            WHEN name LIKE '共享中心_%' THEN
                CASE 
                    WHEN SUBSTRING(name, 6) LIKE '共享%' THEN SUBSTRING(name, 6)
                    ELSE CONCAT('共享', SUBSTRING(name, 6))
                END
            ELSE name
        END as name,
        code,
        CASE 
            WHEN name LIKE '共享中心_%' THEN
                CASE 
                    WHEN SUBSTRING(name, 6) LIKE '共享%' THEN SUBSTRING(SUBSTRING(name, 6), 3)
                    ELSE SUBSTRING(name, 6)
                END
            ELSE name
        END as alias
    FROM ods.t_share_fssc_post_group_setting;

END//

DELIMITER ; 