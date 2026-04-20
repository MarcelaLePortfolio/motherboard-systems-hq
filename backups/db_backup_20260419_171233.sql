--
-- PostgreSQL database dump
--

\restrict gmfCYUSPtQusLyccCdFqMVJbHuKPe5banNhs910W2RgBCFpkgEeAV1nUHuHyaZb

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
-- Name: task_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_events (
    id bigint NOT NULL,
    task_id text,
    kind text,
    actor text,
    payload jsonb,
    created_at timestamp with time zone DEFAULT now(),
    run_id text,
    ts bigint DEFAULT ((EXTRACT(epoch FROM now()) * (1000)::numeric))::bigint NOT NULL
);


ALTER TABLE public.task_events OWNER TO postgres;

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
-- Name: run_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.run_view AS
 WITH latest_event AS (
         SELECT DISTINCT ON (te_1.task_id) te_1.task_id,
            te_1.id AS last_event_id,
            te_1.ts AS last_event_ts,
            te_1.kind AS last_event_kind,
            COALESCE(te_1.actor, 'unassigned'::text) AS actor,
            te_1.run_id
           FROM public.task_events te_1
          ORDER BY te_1.task_id, te_1.ts DESC, te_1.id DESC
        ), terminal_event AS (
         SELECT DISTINCT ON (te_1.task_id) te_1.task_id,
            te_1.kind AS terminal_event_kind,
            te_1.ts AS terminal_event_ts,
            te_1.id AS terminal_event_id
           FROM public.task_events te_1
          WHERE (te_1.kind = ANY (ARRAY['task.completed'::text, 'task.failed'::text, 'task.canceled'::text]))
          ORDER BY te_1.task_id, te_1.ts DESC, te_1.id DESC
        )
 SELECT COALESCE(le.run_id, t.run_id, t.task_id) AS run_id,
    t.task_id,
    t.status AS task_status,
    (t.status = ANY (ARRAY['completed'::text, 'failed'::text, 'canceled'::text])) AS is_terminal,
    le.last_event_id,
    le.last_event_ts,
    le.last_event_kind,
    COALESCE(le.actor, (t.payload ->> 'agent'::text), (t.payload ->> 'owner'::text), (t.payload ->> 'actor'::text), 'unassigned'::text) AS actor,
    NULL::timestamp with time zone AS lease_expires_at,
    false AS lease_fresh,
    NULL::bigint AS lease_ttl_ms,
    NULL::bigint AS last_heartbeat_ts,
    NULL::bigint AS heartbeat_age_ms,
    te.terminal_event_kind,
    te.terminal_event_ts,
    te.terminal_event_id,
    (t.id)::text AS id,
    t.status,
    t.updated_at,
    t.created_at,
    COALESCE((t.payload ->> 'agent'::text), (t.payload ->> 'owner'::text), (t.payload ->> 'actor'::text), 'unassigned'::text) AS agent
   FROM ((public.tasks t
     LEFT JOIN latest_event le ON ((le.task_id = t.task_id)))
     LEFT JOIN terminal_event te ON ((te.task_id = t.task_id)));


ALTER VIEW public.run_view OWNER TO postgres;

--
-- Name: task_events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_events_id_seq OWNER TO postgres;

--
-- Name: task_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.task_events_id_seq OWNED BY public.task_events.id;


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
-- Name: task_events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_events ALTER COLUMN id SET DEFAULT nextval('public.task_events_id_seq'::regclass);


--
-- Name: tasks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks ALTER COLUMN id SET DEFAULT nextval('public.tasks_id_seq'::regclass);


--
-- Data for Name: task_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_events (id, task_id, kind, actor, payload, created_at, run_id, ts) FROM stdin;
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tasks (id, task_id, status, kind, payload, created_at, updated_at, title, action_tier, run_id, claimed_by, notes, attempts, max_attempts) FROM stdin;
\.


--
-- Name: task_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_events_id_seq', 1, false);


--
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tasks_id_seq', 1, false);


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
-- Name: idx_tasks_action_tier; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_action_tier ON public.tasks USING btree (action_tier);


--
-- Name: idx_tasks_kind; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_kind ON public.tasks USING btree (kind);


--
-- Name: idx_tasks_run_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_run_id ON public.tasks USING btree (run_id);


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
-- PostgreSQL database dump complete
--

\unrestrict gmfCYUSPtQusLyccCdFqMVJbHuKPe5banNhs910W2RgBCFpkgEeAV1nUHuHyaZb

