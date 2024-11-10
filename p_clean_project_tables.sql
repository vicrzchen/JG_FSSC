-- 删除 DM 层表
DROP TABLE IF EXISTS dm_last_day_processed;
DROP TABLE IF EXISTS dm_reject_reason;
DROP TABLE IF EXISTS dm_processed_tickets;
DROP TABLE IF EXISTS dm_received_tickets;
DROP TABLE IF EXISTS dm_waiting_time;
DROP TABLE IF EXISTS dm_working_staff;

-- 删除 DW 层表
DROP TABLE IF EXISTS dw_last_day_processed;
DROP TABLE IF EXISTS dw_reject_reason;
DROP TABLE IF EXISTS dw_processed_tickets;
DROP TABLE IF EXISTS dw_received_tickets;
DROP TABLE IF EXISTS dw_waiting_time;
DROP TABLE IF EXISTS dw_working_staff;
DROP TABLE IF EXISTS dw_work_group_mapping; 