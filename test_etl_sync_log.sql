-- 测试用例：ETL同步日志存储过程测试脚本

-- 1. 创建表测试
CALL p_etl_create_sync_log_table();

-- 2. 测试数据推送
-- 测试用例 2.1: 插入新表同步状态
CALL p_etl_update_sync_status('test_table_1', TRUE);

-- 测试用例 2.2: 更新已存在表的同步状态为失败
CALL p_etl_update_sync_status('test_table_1', FALSE);

-- 测试用例 2.3: 同时插入多个不同表的同步状态
CALL p_etl_update_sync_status('test_table_2', TRUE);
CALL p_etl_update_sync_status('test_table_3', TRUE);

-- 3. 测试数据获取
-- 测试用例 3.1: 获取成功同步的表的最后同步时间
SET @last_sync_time_1 = NULL;
CALL p_etl_get_last_sync_time('test_table_2', @last_sync_time_1);
SELECT 'test_table_2最后同步时间' as test_case, @last_sync_time_1 as last_sync_time;

-- 测试用例 3.2: 获取同步失败的表的最后同步时间（应该返回NULL）
SET @last_sync_time_2 = NULL;
CALL p_etl_get_last_sync_time('test_table_1', @last_sync_time_2);
SELECT 'test_table_1最后同步时间（同步失败）' as test_case, @last_sync_time_2 as last_sync_time;

-- 测试用例 3.3: 获取不存在的表的最后同步时间（应该返回NULL）
SET @last_sync_time_3 = NULL;
CALL p_etl_get_last_sync_time('non_existing_table', @last_sync_time_3);
SELECT '不存在的表最后同步时间' as test_case, @last_sync_time_3 as last_sync_time;

-- 4. 验证数据完整性
-- 查看所有同步日志记录
SELECT 
    table_name,
    last_sync_time,
    sync_status,
    created_at,
    updated_at
FROM etl_sync_log
ORDER BY id;

-- 5. 清理测试数据（可选）
-- DELETE FROM etl_sync_log WHERE table_name LIKE 'test_table%'; 