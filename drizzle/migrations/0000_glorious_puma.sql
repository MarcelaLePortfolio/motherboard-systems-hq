CREATE TABLE `agent_tasks` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`agent` text NOT NULL,
	`type` text NOT NULL,
	`status` text DEFAULT 'Idle',
	`content` text,
	`ts` integer
);
