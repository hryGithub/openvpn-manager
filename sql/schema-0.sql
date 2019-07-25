CREATE TABLE IF NOT EXISTS "application" (
"id"  INTEGER PRIMARY KEY AUTOINCREMENT,
"sql_schema"  INTEGER(11)
);

CREATE TABLE IF NOT EXISTS "admin" (
"admin_id"  TEXT(255) PRIMARY KEY,
"admin_pass"  TEXT(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS "log" (
"log_id"  INTEGER PRIMARY KEY AUTOINCREMENT,
"user_id"  TEXT(32) NOT NULL,
"log_trusted_ip"  TEXT(32),
"log_trusted_port"  TEXT(16),
"log_remote_ip"  TEXT(32),
"log_remote_port"  TEXT(16),
"log_start_time"  TIMESTAMP NOT NULL DEFAULT (datetime('now','localtime')),
"log_end_time"  timestamp NULL DEFAULT NULL,
"log_received"  REAL NOT NULL DEFAULT 0,
"log_send"  REAL NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS "user" (
"user_id"  TEXT(32) PRIMARY KEY,
"user_pass"  TEXT(255) NOT NULL,
"user_mail"  TEXT(64),
"user_phone"  TEXT(16),
"user_online"  INTEGER(1) NOT NULL DEFAULT 0,
"user_enable"  INTEGER(1) NOT NULL DEFAULT 1,
"user_start_date"  TEXT,
"user_end_date"  TEXT
);