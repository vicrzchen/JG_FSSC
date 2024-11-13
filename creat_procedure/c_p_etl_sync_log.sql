DELIMITER //

-- 删除已存在的存储过程
DROP PROCEDURE IF EXISTS `p_etl_create_sync_log_table`//
DROP PROCEDURE IF EXISTS `p_etl_update_sync_status`//
DROP PROCEDURE IF EXISTS `p_etl_get_last_sync_time`//

-- 创建表的存储过程
CREATE PROCEDURE `p_etl_create_sync_log_table`()
BEGIN
    CREATE TABLE IF NOT EXISTS `etl_sync_log` (
        `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
        `table_name` VARCHAR(100) NOT NULL COMMENT '表名',
        `last_sync_time` TIMESTAMP NULL COMMENT '最后同步时间',
        `sync_status` BOOLEAN DEFAULT TRUE COMMENT '同步状态',
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        PRIMARY KEY (`id`),
        UNIQUE KEY `uk_table_name` (`table_name`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ETL同步状态日志表';
END//

-- 更新同步状态的存储过程
CREATE PROCEDURE `p_etl_update_sync_status`(
    IN `p_table_name` VARCHAR(100),
    IN `p_sync_status` BOOLEAN
)
BEGIN
    INSERT INTO `etl_sync_log` (`table_name`, `last_sync_time`, `sync_status`)
    VALUES (p_table_name, CURRENT_TIMESTAMP, p_sync_status)
    ON DUPLICATE KEY UPDATE 
        `last_sync_time` = CURRENT_TIMESTAMP,
        `sync_status` = p_sync_status;
END//

-- 获取最后同步时间的存储过程
CREATE PROCEDURE `p_etl_get_last_sync_time`(
    IN `p_table_name` VARCHAR(100),
    OUT `p_last_sync_time` TIMESTAMP
)
BEGIN
    SELECT `last_sync_time` INTO p_last_sync_time
    FROM `etl_sync_log`
    WHERE `table_name` = p_table_name
    AND `sync_status` = TRUE
    LIMIT 1;
END//

DELIMITER ; 