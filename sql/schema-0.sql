PRAGMA foreign_keys = OFF;

CREATE TABLE IF NOT EXISTS "application" (
"id"  INTEGER(11) NOT NULL,
"sql_schema"  INTEGER(11) NOT NULL,
PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS `admin` (
"admin_id"  TEXT(255) NOT NULL,
"admin_pass"  TEXT(255) NOT NULL,
PRIMARY KEY ("admin_id")
);

CREATE TABLE IF NOT EXISTS `log` (
"log_id"  INTEGER(10) NOT NULL,
"user_id"  TEXT(32) NOT NULL,
"log_trusted_ip"  TEXT(32),
"log_trusted_port"  TEXT(16),
"log_remote_ip"  TEXT(32),
"log_remote_port"  TEXT(16),
"log_start_time"  TEXT NOT NULL,
"log_end_time"  TEXT,
"log_received"  REAL NOT NULL,
"log_send"  REAL NOT NULL,
PRIMARY KEY ("log_id")
);

CREATE TABLE IF NOT EXISTS `user` (
"user_id"  TEXT(32) NOT NULL,
"user_pass"  TEXT(255) NOT NULL,
"user_mail"  TEXT(64),
"user_phone"  TEXT(16),
"user_online"  INTEGER(1) NOT NULL,
"user_enable"  INTEGER(1) NOT NULL,
"user_start_date"  TEXT,
"user_end_date"  TEXT,
PRIMARY KEY ("user_id")
);


CREATE INDEX IF NOT EXISTS "user_id" ON "log" ("user_id" ASC);

CREATE INDEX IF NOT EXISTS "user_pass" ON "user" ("user_pass" ASC);