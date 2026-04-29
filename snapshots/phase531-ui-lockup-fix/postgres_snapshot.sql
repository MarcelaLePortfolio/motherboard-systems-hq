--
-- PostgreSQL database dump
--

\restrict 7IcXFhAutKTsrdh7RDmYRPQ7XMWP9h5yEoc72pL6dFR2Ri9ZCt25DjjNdlNUi9V

-- Dumped from database version 16.13
-- Dumped by pg_dump version 16.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: agent_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agent_status (
    id integer NOT NULL,
    agent_name character varying(50) NOT NULL,
    status character varying(20) NOT NULL,
    current_task character varying(100),
    last_heartbeat timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.agent_status OWNER TO postgres;

--
-- Name: agent_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.agent_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.agent_status_id_seq OWNER TO postgres;

--
-- Name: agent_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.agent_status_id_seq OWNED BY public.agent_status.id;


--
-- Name: system_metrics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.system_metrics (
    id integer NOT NULL,
    active_agents integer DEFAULT 0,
    tasks_completed integer DEFAULT 0,
    system_load numeric DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.system_metrics OWNER TO postgres;

--
-- Name: system_metrics_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.system_metrics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.system_metrics_id_seq OWNER TO postgres;

--
-- Name: system_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.system_metrics_id_seq OWNED BY public.system_metrics.id;


--
-- Name: task_activity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_activity (
    id integer NOT NULL,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_count integer DEFAULT 0,
    completed_count integer DEFAULT 0,
    failed_count integer DEFAULT 0
);


ALTER TABLE public.task_activity OWNER TO postgres;

--
-- Name: task_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_activity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_activity_id_seq OWNER TO postgres;

--
-- Name: task_activity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.task_activity_id_seq OWNED BY public.task_activity.id;


--
-- Name: task_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_events (
    id bigint NOT NULL,
    task_id text,
    kind text NOT NULL,
    actor text,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    run_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    ts bigint DEFAULT ((EXTRACT(epoch FROM now()) * (1000)::numeric))::bigint NOT NULL
);


ALTER TABLE public.task_events OWNER TO postgres;

--
-- Name: task_events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.task_events ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.task_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tasks (
    id bigint NOT NULL,
    task_id text,
    status text,
    kind text,
    payload jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    title text,
    action_tier text,
    run_id text,
    claimed_by text,
    notes text,
    attempts integer DEFAULT 0 NOT NULL,
    max_attempts integer
);


ALTER TABLE public.tasks OWNER TO postgres;

--
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tasks_id_seq OWNER TO postgres;

--
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tasks_id_seq OWNED BY public.tasks.id;


--
-- Name: worker_heartbeats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.worker_heartbeats (
    owner text NOT NULL,
    last_seen_at bigint NOT NULL
);


ALTER TABLE public.worker_heartbeats OWNER TO postgres;

--
-- Name: agent_status id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agent_status ALTER COLUMN id SET DEFAULT nextval('public.agent_status_id_seq'::regclass);


--
-- Name: system_metrics id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_metrics ALTER COLUMN id SET DEFAULT nextval('public.system_metrics_id_seq'::regclass);


--
-- Name: task_activity id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_activity ALTER COLUMN id SET DEFAULT nextval('public.task_activity_id_seq'::regclass);


--
-- Name: tasks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks ALTER COLUMN id SET DEFAULT nextval('public.tasks_id_seq'::regclass);


--
-- Data for Name: agent_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.agent_status (id, agent_name, status, current_task, last_heartbeat) FROM stdin;
1	Matilda	IDLE	Available	2026-04-29 21:03:57.463758
2	Atlas	IDLE	Monitoring	2026-04-29 21:03:57.463758
3	Cade	IDLE	Available	2026-04-29 21:03:57.463758
4	Effie	IDLE	Available	2026-04-29 21:03:57.463758
\.


--
-- Data for Name: system_metrics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.system_metrics (id, active_agents, tasks_completed, system_load, created_at) FROM stdin;
1	4	0	0	2026-04-29 21:03:57.464524
\.


--
-- Data for Name: task_activity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_activity (id, "timestamp", created_count, completed_count, failed_count) FROM stdin;
1	2026-04-29 21:03:57.465963	1	0	0
\.


--
-- Data for Name: task_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_events (id, task_id, kind, actor, payload, run_id, created_at, ts) FROM stdin;
1	phase530-test	task.created	debug	{"message": "SSE verification event"}	phase530-run	2026-04-29 20:36:52.038232+00	1777495012038
2	phase530-ui-test	task.created	debug	{"message": "UI inspector verification event"}	phase530-ui-run	2026-04-29 20:50:15.259525+00	1777495815260
3	phase530-visible-test	task.created	debug	{"message": "Execution Inspector visible test"}	phase530-visible-run	2026-04-29 20:52:42.199041+00	1777495962199
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tasks (id, task_id, status, kind, payload, created_at, updated_at, title, action_tier, run_id, claimed_by, notes, attempts, max_attempts) FROM stdin;
\.


--
-- Data for Name: worker_heartbeats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.worker_heartbeats (owner, last_seen_at) FROM stdin;
\.


--
-- Name: agent_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.agent_status_id_seq', 4, true);


--
-- Name: system_metrics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.system_metrics_id_seq', 1, true);


--
-- Name: task_activity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_activity_id_seq', 1, true);


--
-- Name: task_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_events_id_seq', 3, true);


--
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tasks_id_seq', 1, false);


--
-- Name: agent_status agent_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agent_status
    ADD CONSTRAINT agent_status_pkey PRIMARY KEY (id);


--
-- Name: system_metrics system_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_metrics
    ADD CONSTRAINT system_metrics_pkey PRIMARY KEY (id);


--
-- Name: task_activity task_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_activity
    ADD CONSTRAINT task_activity_pkey PRIMARY KEY (id);


--
-- Name: task_events task_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_events
    ADD CONSTRAINT task_events_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_task_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_task_id_key UNIQUE (task_id);


--
-- Name: worker_heartbeats worker_heartbeats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worker_heartbeats
    ADD CONSTRAINT worker_heartbeats_pkey PRIMARY KEY (owner);


--
-- Name: idx_task_events_kind; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_events_kind ON public.task_events USING btree (kind);


--
-- Name: idx_task_events_task_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_events_task_id ON public.task_events USING btree (task_id);


--
-- Name: idx_task_events_ts; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_events_ts ON public.task_events USING btree (ts, id);


--
-- Name: task_events_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX task_events_created_at_idx ON public.task_events USING btree (created_at);


--
-- Name: task_events_task_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX task_events_task_id_idx ON public.task_events USING btree (task_id);


--
-- Name: tasks_task_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tasks_task_id_idx ON public.tasks USING btree (task_id);


--
-- Name: worker_heartbeats_last_seen_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX worker_heartbeats_last_seen_idx ON public.worker_heartbeats USING btree (last_seen_at);


--
-- PostgreSQL database dump complete
--

\unrestrict 7IcXFhAutKTsrdh7RDmYRPQ7XMWP9h5yEoc72pL6dFR2Ri9ZCt25DjjNdlNUi9V

