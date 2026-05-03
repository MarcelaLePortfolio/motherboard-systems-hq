CREATE TABLE IF NOT EXISTS `reflection_index` (
	`id` text PRIMARY KEY NOT NULL,
	`related_event_id` text,
	`agent` text,
	`insight` text,
	`confidence` integer,
	`created_at` text
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS `task_events` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`kind` text,
	`payload` text,
	`created_at` text
);
