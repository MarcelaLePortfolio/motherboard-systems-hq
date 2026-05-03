--
-- PostgreSQL database dump
--

\restrict CcJwgWPGCFEPubL3U9GcxFWvLVTDU9cJJ2GQAUAAiOydu3Os4DVG5m87PmRG61C

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
4	phase533-fill-test-1	task.created	debug	{"message": "Execution Inspector fill test event 1"}	phase533-fill-test	2026-04-29 22:28:18.619323+00	1777501698619
5	phase533-fill-test-2	task.started	debug	{"message": "Execution Inspector fill test event 2"}	phase533-fill-test	2026-04-29 22:28:18.619323+00	1777501698619
6	phase533-fill-test-3	task.updated	debug	{"message": "Execution Inspector fill test event 3"}	phase533-fill-test	2026-04-29 22:28:18.619323+00	1777501698619
7	phase533-fill-test-4	task.completed	debug	{"message": "Execution Inspector fill test event 4"}	phase533-fill-test	2026-04-29 22:28:18.619323+00	1777501698619
8	phase533-fill-test-5	task.created	debug	{"message": "Execution Inspector fill test event 5"}	phase533-fill-test	2026-04-29 22:28:18.619323+00	1777501698619
9	phase533-fill-test-6	task.started	debug	{"message": "Execution Inspector fill test event 6"}	phase533-fill-test	2026-04-29 22:28:18.619323+00	1777501698619
10	phase533-fill-test-7	task.updated	debug	{"message": "Execution Inspector fill test event 7"}	phase533-fill-test	2026-04-29 22:28:18.619323+00	1777501698619
11	phase533-fill-test-8	task.completed	debug	{"message": "Execution Inspector fill test event 8"}	phase533-fill-test	2026-04-29 22:28:18.619323+00	1777501698619
12	phase533-fill-test-9	task.created	debug	{"message": "Execution Inspector fill test event 9"}	phase533-fill-test	2026-04-29 22:28:18.619323+00	1777501698619
13	phase533-fill-test-10	task.started	debug	{"message": "Execution Inspector fill test event 10"}	phase533-fill-test	2026-04-29 22:28:18.619323+00	1777501698619
14	phase533-fill-test-11	task.updated	debug	{"message": "Execution Inspector fill test event 11"}	phase533-fill-test	2026-04-29 22:28:18.619323+00	1777501698619
15	phase533-fill-test-12	task.completed	debug	{"message": "Execution Inspector fill test event 12"}	phase533-fill-test	2026-04-29 22:28:18.619323+00	1777501698619
16	phase533-fill-test-13	task.created	debug	{"message": "Execution Inspector fill test event 13"}	phase533-fill-test	2026-04-29 22:28:18.619323+00	1777501698619
17	phase533-fill-test-14	task.started	debug	{"message": "Execution Inspector fill test event 14"}	phase533-fill-test	2026-04-29 22:28:18.619323+00	1777501698619
18	phase533-fill-test-15	task.updated	debug	{"message": "Execution Inspector fill test event 15"}	phase533-fill-test	2026-04-29 22:28:18.619323+00	1777501698619
19	phase533-fill-test-16	task.completed	debug	{"message": "Execution Inspector fill test event 16"}	phase533-fill-test	2026-04-29 22:28:18.619323+00	1777501698619
20	phase533-fill-test-17	task.created	debug	{"message": "Execution Inspector fill test event 17"}	phase533-fill-test	2026-04-29 22:28:18.619323+00	1777501698619
21	phase533-fill-test-18	task.started	debug	{"message": "Execution Inspector fill test event 18"}	phase533-fill-test	2026-04-29 22:28:18.619323+00	1777501698619
22	phase533-fill-test-bulk-1	task.created	debug	{"message": "Execution Inspector bulk fill test event 1"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
23	phase533-fill-test-bulk-2	task.started	debug	{"message": "Execution Inspector bulk fill test event 2"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
24	phase533-fill-test-bulk-3	task.updated	debug	{"message": "Execution Inspector bulk fill test event 3"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
25	phase533-fill-test-bulk-4	task.completed	debug	{"message": "Execution Inspector bulk fill test event 4"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
26	phase533-fill-test-bulk-5	task.created	debug	{"message": "Execution Inspector bulk fill test event 5"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
27	phase533-fill-test-bulk-6	task.started	debug	{"message": "Execution Inspector bulk fill test event 6"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
28	phase533-fill-test-bulk-7	task.updated	debug	{"message": "Execution Inspector bulk fill test event 7"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
29	phase533-fill-test-bulk-8	task.completed	debug	{"message": "Execution Inspector bulk fill test event 8"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
30	phase533-fill-test-bulk-9	task.created	debug	{"message": "Execution Inspector bulk fill test event 9"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
31	phase533-fill-test-bulk-10	task.started	debug	{"message": "Execution Inspector bulk fill test event 10"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
32	phase533-fill-test-bulk-11	task.updated	debug	{"message": "Execution Inspector bulk fill test event 11"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
33	phase533-fill-test-bulk-12	task.completed	debug	{"message": "Execution Inspector bulk fill test event 12"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
34	phase533-fill-test-bulk-13	task.created	debug	{"message": "Execution Inspector bulk fill test event 13"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
35	phase533-fill-test-bulk-14	task.started	debug	{"message": "Execution Inspector bulk fill test event 14"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
36	phase533-fill-test-bulk-15	task.updated	debug	{"message": "Execution Inspector bulk fill test event 15"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
37	phase533-fill-test-bulk-16	task.completed	debug	{"message": "Execution Inspector bulk fill test event 16"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
38	phase533-fill-test-bulk-17	task.created	debug	{"message": "Execution Inspector bulk fill test event 17"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
39	phase533-fill-test-bulk-18	task.started	debug	{"message": "Execution Inspector bulk fill test event 18"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
40	phase533-fill-test-bulk-19	task.updated	debug	{"message": "Execution Inspector bulk fill test event 19"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
41	phase533-fill-test-bulk-20	task.completed	debug	{"message": "Execution Inspector bulk fill test event 20"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
42	phase533-fill-test-bulk-21	task.created	debug	{"message": "Execution Inspector bulk fill test event 21"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
43	phase533-fill-test-bulk-22	task.started	debug	{"message": "Execution Inspector bulk fill test event 22"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
44	phase533-fill-test-bulk-23	task.updated	debug	{"message": "Execution Inspector bulk fill test event 23"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
45	phase533-fill-test-bulk-24	task.completed	debug	{"message": "Execution Inspector bulk fill test event 24"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
46	phase533-fill-test-bulk-25	task.created	debug	{"message": "Execution Inspector bulk fill test event 25"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
47	phase533-fill-test-bulk-26	task.started	debug	{"message": "Execution Inspector bulk fill test event 26"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
48	phase533-fill-test-bulk-27	task.updated	debug	{"message": "Execution Inspector bulk fill test event 27"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
49	phase533-fill-test-bulk-28	task.completed	debug	{"message": "Execution Inspector bulk fill test event 28"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
50	phase533-fill-test-bulk-29	task.created	debug	{"message": "Execution Inspector bulk fill test event 29"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
51	phase533-fill-test-bulk-30	task.started	debug	{"message": "Execution Inspector bulk fill test event 30"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
52	phase533-fill-test-bulk-31	task.updated	debug	{"message": "Execution Inspector bulk fill test event 31"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
53	phase533-fill-test-bulk-32	task.completed	debug	{"message": "Execution Inspector bulk fill test event 32"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
54	phase533-fill-test-bulk-33	task.created	debug	{"message": "Execution Inspector bulk fill test event 33"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
55	phase533-fill-test-bulk-34	task.started	debug	{"message": "Execution Inspector bulk fill test event 34"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
56	phase533-fill-test-bulk-35	task.updated	debug	{"message": "Execution Inspector bulk fill test event 35"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
57	phase533-fill-test-bulk-36	task.completed	debug	{"message": "Execution Inspector bulk fill test event 36"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
58	phase533-fill-test-bulk-37	task.created	debug	{"message": "Execution Inspector bulk fill test event 37"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
59	phase533-fill-test-bulk-38	task.started	debug	{"message": "Execution Inspector bulk fill test event 38"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
60	phase533-fill-test-bulk-39	task.updated	debug	{"message": "Execution Inspector bulk fill test event 39"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
61	phase533-fill-test-bulk-40	task.completed	debug	{"message": "Execution Inspector bulk fill test event 40"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
62	phase533-fill-test-bulk-41	task.created	debug	{"message": "Execution Inspector bulk fill test event 41"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
63	phase533-fill-test-bulk-42	task.started	debug	{"message": "Execution Inspector bulk fill test event 42"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
64	phase533-fill-test-bulk-43	task.updated	debug	{"message": "Execution Inspector bulk fill test event 43"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
65	phase533-fill-test-bulk-44	task.completed	debug	{"message": "Execution Inspector bulk fill test event 44"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
66	phase533-fill-test-bulk-45	task.created	debug	{"message": "Execution Inspector bulk fill test event 45"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
67	phase533-fill-test-bulk-46	task.started	debug	{"message": "Execution Inspector bulk fill test event 46"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
68	phase533-fill-test-bulk-47	task.updated	debug	{"message": "Execution Inspector bulk fill test event 47"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
69	phase533-fill-test-bulk-48	task.completed	debug	{"message": "Execution Inspector bulk fill test event 48"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
70	phase533-fill-test-bulk-49	task.created	debug	{"message": "Execution Inspector bulk fill test event 49"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
71	phase533-fill-test-bulk-50	task.started	debug	{"message": "Execution Inspector bulk fill test event 50"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
72	phase533-fill-test-bulk-51	task.updated	debug	{"message": "Execution Inspector bulk fill test event 51"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
73	phase533-fill-test-bulk-52	task.completed	debug	{"message": "Execution Inspector bulk fill test event 52"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
74	phase533-fill-test-bulk-53	task.created	debug	{"message": "Execution Inspector bulk fill test event 53"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
75	phase533-fill-test-bulk-54	task.started	debug	{"message": "Execution Inspector bulk fill test event 54"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
76	phase533-fill-test-bulk-55	task.updated	debug	{"message": "Execution Inspector bulk fill test event 55"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
77	phase533-fill-test-bulk-56	task.completed	debug	{"message": "Execution Inspector bulk fill test event 56"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
78	phase533-fill-test-bulk-57	task.created	debug	{"message": "Execution Inspector bulk fill test event 57"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
79	phase533-fill-test-bulk-58	task.started	debug	{"message": "Execution Inspector bulk fill test event 58"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
80	phase533-fill-test-bulk-59	task.updated	debug	{"message": "Execution Inspector bulk fill test event 59"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
81	phase533-fill-test-bulk-60	task.completed	debug	{"message": "Execution Inspector bulk fill test event 60"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
82	phase533-fill-test-bulk-61	task.created	debug	{"message": "Execution Inspector bulk fill test event 61"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
83	phase533-fill-test-bulk-62	task.started	debug	{"message": "Execution Inspector bulk fill test event 62"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
84	phase533-fill-test-bulk-63	task.updated	debug	{"message": "Execution Inspector bulk fill test event 63"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
85	phase533-fill-test-bulk-64	task.completed	debug	{"message": "Execution Inspector bulk fill test event 64"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
86	phase533-fill-test-bulk-65	task.created	debug	{"message": "Execution Inspector bulk fill test event 65"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
87	phase533-fill-test-bulk-66	task.started	debug	{"message": "Execution Inspector bulk fill test event 66"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
88	phase533-fill-test-bulk-67	task.updated	debug	{"message": "Execution Inspector bulk fill test event 67"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
89	phase533-fill-test-bulk-68	task.completed	debug	{"message": "Execution Inspector bulk fill test event 68"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
90	phase533-fill-test-bulk-69	task.created	debug	{"message": "Execution Inspector bulk fill test event 69"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
91	phase533-fill-test-bulk-70	task.started	debug	{"message": "Execution Inspector bulk fill test event 70"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
92	phase533-fill-test-bulk-71	task.updated	debug	{"message": "Execution Inspector bulk fill test event 71"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
93	phase533-fill-test-bulk-72	task.completed	debug	{"message": "Execution Inspector bulk fill test event 72"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
94	phase533-fill-test-bulk-73	task.created	debug	{"message": "Execution Inspector bulk fill test event 73"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
95	phase533-fill-test-bulk-74	task.started	debug	{"message": "Execution Inspector bulk fill test event 74"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
96	phase533-fill-test-bulk-75	task.updated	debug	{"message": "Execution Inspector bulk fill test event 75"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
97	phase533-fill-test-bulk-76	task.completed	debug	{"message": "Execution Inspector bulk fill test event 76"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
98	phase533-fill-test-bulk-77	task.created	debug	{"message": "Execution Inspector bulk fill test event 77"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
99	phase533-fill-test-bulk-78	task.started	debug	{"message": "Execution Inspector bulk fill test event 78"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
100	phase533-fill-test-bulk-79	task.updated	debug	{"message": "Execution Inspector bulk fill test event 79"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
101	phase533-fill-test-bulk-80	task.completed	debug	{"message": "Execution Inspector bulk fill test event 80"}	phase533-fill-test-bulk	2026-04-29 22:29:25.755281+00	1777501765755
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

SELECT pg_catalog.setval('public.task_events_id_seq', 101, true);


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

\unrestrict CcJwgWPGCFEPubL3U9GcxFWvLVTDU9cJJ2GQAUAAiOydu3Os4DVG5m87PmRG61C

