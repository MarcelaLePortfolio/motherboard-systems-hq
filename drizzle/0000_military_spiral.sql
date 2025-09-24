-- Current sql file was generated after introspecting the database
-- If you want to run this migration please uncomment this code before executing migrations
/*
CREATE TABLE `agent_state` (
	`agent` text PRIMARY KEY NOT NULL,
	`status` text,
	`last_ts` integer
);
--> statement-breakpoint
CREATE TABLE `tasks` (
	`id` text PRIMARY KEY NOT NULL,
	`type` text,
	`payload` text,
	`status` text,
	`created_at` text,
	`completed_at` text
);

*/