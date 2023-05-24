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
-- Name: approvals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.approvals (
    id bigint NOT NULL,
    value integer,
    note text,
    option_id bigint NOT NULL,
    decision_id bigint NOT NULL,
    decision_participant_id bigint NOT NULL,
    team_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    stars integer DEFAULT 0
);


--
-- Name: approvals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.approvals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: approvals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.approvals_id_seq OWNED BY public.approvals.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: decision_invites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.decision_invites (
    id bigint NOT NULL,
    team_id bigint NOT NULL,
    decision_id bigint NOT NULL,
    created_by_id bigint NOT NULL,
    code character varying NOT NULL,
    expires_at timestamp(6) without time zone NOT NULL,
    max_uses integer DEFAULT 1 NOT NULL,
    uses integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: decision_invites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.decision_invites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: decision_invites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.decision_invites_id_seq OWNED BY public.decision_invites.id;


--
-- Name: decision_participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.decision_participants (
    id bigint NOT NULL,
    decision_id bigint NOT NULL,
    entity_type character varying,
    entity_id bigint,
    name character varying,
    invite_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: decision_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.decision_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: decision_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.decision_participants_id_seq OWNED BY public.decision_participants.id;


--
-- Name: decision_results; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.decision_results AS
SELECT
    NULL::bigint AS decision_id,
    NULL::bigint AS option_id,
    NULL::text AS option_title,
    NULL::bigint AS approved_yes,
    NULL::bigint AS approved_no,
    NULL::bigint AS approval_count,
    NULL::bigint AS stars,
    NULL::integer AS random_id;


--
-- Name: decisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.decisions (
    id bigint NOT NULL,
    question text,
    status character varying,
    deadline timestamp(6) without time zone,
    created_by_id bigint NOT NULL,
    team_id bigint NOT NULL,
    other_attributes jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: decisions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.decisions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: decisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.decisions_id_seq OWNED BY public.decisions.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_grants (
    id bigint NOT NULL,
    resource_owner_id bigint NOT NULL,
    application_id bigint NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    revoked_at timestamp(6) without time zone
);


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_access_grants_id_seq OWNED BY public.oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_tokens (
    id bigint NOT NULL,
    resource_owner_id bigint,
    application_id bigint NOT NULL,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    scopes character varying,
    created_at timestamp(6) without time zone NOT NULL,
    revoked_at timestamp(6) without time zone,
    previous_refresh_token character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_access_tokens_id_seq OWNED BY public.oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_applications (
    id bigint NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri text NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    confidential boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    owner_id integer,
    owner_type character varying
);


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_applications_id_seq OWNED BY public.oauth_applications.id;


--
-- Name: options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.options (
    id bigint NOT NULL,
    title text,
    description text,
    decision_participant_id bigint NOT NULL,
    decision_id bigint NOT NULL,
    team_id bigint NOT NULL,
    other_attributes jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    random_id integer DEFAULT (floor((random() * (1000000000)::double precision)))::integer
);


--
-- Name: options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.options_id_seq OWNED BY public.options.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: team_invites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_invites (
    id bigint NOT NULL,
    team_id bigint NOT NULL,
    created_by_id bigint NOT NULL,
    code character varying NOT NULL,
    expires_at timestamp(6) without time zone NOT NULL,
    max_uses integer DEFAULT 1 NOT NULL,
    uses integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: team_invites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_invites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_invites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_invites_id_seq OWNED BY public.team_invites.id;


--
-- Name: team_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_members (
    id bigint NOT NULL,
    name character varying,
    status character varying,
    team_id bigint NOT NULL,
    user_id bigint NOT NULL,
    other_attributes jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    team_invite_id bigint
);


--
-- Name: team_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_members_id_seq OWNED BY public.team_members.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams (
    id bigint NOT NULL,
    handle character varying,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    username character varying,
    display_name character varying,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp(6) without time zone,
    remember_created_at timestamp(6) without time zone,
    confirmation_token character varying,
    confirmed_at timestamp(6) without time zone,
    confirmation_sent_at timestamp(6) without time zone,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    locked_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    is_admin boolean
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: webhooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhooks (
    id bigint NOT NULL,
    url character varying,
    secret character varying,
    event character varying,
    team_id bigint NOT NULL,
    decision_id bigint,
    created_by_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: webhooks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webhooks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webhooks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.webhooks_id_seq OWNED BY public.webhooks.id;


--
-- Name: approvals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approvals ALTER COLUMN id SET DEFAULT nextval('public.approvals_id_seq'::regclass);


--
-- Name: decision_invites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decision_invites ALTER COLUMN id SET DEFAULT nextval('public.decision_invites_id_seq'::regclass);


--
-- Name: decision_participants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decision_participants ALTER COLUMN id SET DEFAULT nextval('public.decision_participants_id_seq'::regclass);


--
-- Name: decisions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decisions ALTER COLUMN id SET DEFAULT nextval('public.decisions_id_seq'::regclass);


--
-- Name: oauth_access_grants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_grants_id_seq'::regclass);


--
-- Name: oauth_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_tokens_id_seq'::regclass);


--
-- Name: oauth_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications ALTER COLUMN id SET DEFAULT nextval('public.oauth_applications_id_seq'::regclass);


--
-- Name: options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.options ALTER COLUMN id SET DEFAULT nextval('public.options_id_seq'::regclass);


--
-- Name: team_invites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_invites ALTER COLUMN id SET DEFAULT nextval('public.team_invites_id_seq'::regclass);


--
-- Name: team_members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members ALTER COLUMN id SET DEFAULT nextval('public.team_members_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: webhooks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks ALTER COLUMN id SET DEFAULT nextval('public.webhooks_id_seq'::regclass);


--
-- Name: approvals approvals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approvals
    ADD CONSTRAINT approvals_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: decision_invites decision_invites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decision_invites
    ADD CONSTRAINT decision_invites_pkey PRIMARY KEY (id);


--
-- Name: decision_participants decision_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decision_participants
    ADD CONSTRAINT decision_participants_pkey PRIMARY KEY (id);


--
-- Name: decisions decisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decisions
    ADD CONSTRAINT decisions_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants oauth_access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications oauth_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: options options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.options
    ADD CONSTRAINT options_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: team_invites team_invites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_invites
    ADD CONSTRAINT team_invites_pkey PRIMARY KEY (id);


--
-- Name: team_members team_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT team_members_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: webhooks webhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT webhooks_pkey PRIMARY KEY (id);


--
-- Name: index_approvals_on_decision_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_approvals_on_decision_id ON public.approvals USING btree (decision_id);


--
-- Name: index_approvals_on_decision_participant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_approvals_on_decision_participant_id ON public.approvals USING btree (decision_participant_id);


--
-- Name: index_approvals_on_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_approvals_on_option_id ON public.approvals USING btree (option_id);


--
-- Name: index_approvals_on_option_id_and_decision_participant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_approvals_on_option_id_and_decision_participant_id ON public.approvals USING btree (option_id, decision_participant_id);


--
-- Name: index_approvals_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_approvals_on_team_id ON public.approvals USING btree (team_id);


--
-- Name: index_decision_invites_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_decision_invites_on_code ON public.decision_invites USING btree (code);


--
-- Name: index_decision_invites_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decision_invites_on_created_by_id ON public.decision_invites USING btree (created_by_id);


--
-- Name: index_decision_invites_on_decision_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decision_invites_on_decision_id ON public.decision_invites USING btree (decision_id);


--
-- Name: index_decision_invites_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decision_invites_on_team_id ON public.decision_invites USING btree (team_id);


--
-- Name: index_decision_participants_on_decision_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decision_participants_on_decision_id ON public.decision_participants USING btree (decision_id);


--
-- Name: index_decision_participants_on_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decision_participants_on_entity ON public.decision_participants USING btree (entity_type, entity_id);


--
-- Name: index_decision_participants_on_invite_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decision_participants_on_invite_id ON public.decision_participants USING btree (invite_id);


--
-- Name: index_decisions_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decisions_on_created_by_id ON public.decisions USING btree (created_by_id);


--
-- Name: index_decisions_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decisions_on_team_id ON public.decisions USING btree (team_id);


--
-- Name: index_oauth_access_grants_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_application_id ON public.oauth_access_grants USING btree (application_id);


--
-- Name: index_oauth_access_grants_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_resource_owner_id ON public.oauth_access_grants USING btree (resource_owner_id);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON public.oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_application_id ON public.oauth_access_tokens USING btree (application_id);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON public.oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON public.oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON public.oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_applications_on_owner_id ON public.oauth_applications USING btree (owner_id);


--
-- Name: index_oauth_applications_on_owner_id_and_owner_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_applications_on_owner_id_and_owner_type ON public.oauth_applications USING btree (owner_id, owner_type);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON public.oauth_applications USING btree (uid);


--
-- Name: index_options_on_decision_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_options_on_decision_id ON public.options USING btree (decision_id);


--
-- Name: index_options_on_decision_id_and_title; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_options_on_decision_id_and_title ON public.options USING btree (decision_id, title);


--
-- Name: index_options_on_decision_participant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_options_on_decision_participant_id ON public.options USING btree (decision_participant_id);


--
-- Name: index_options_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_options_on_team_id ON public.options USING btree (team_id);


--
-- Name: index_team_invites_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_team_invites_on_code ON public.team_invites USING btree (code);


--
-- Name: index_team_invites_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_invites_on_created_by_id ON public.team_invites USING btree (created_by_id);


--
-- Name: index_team_invites_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_invites_on_team_id ON public.team_invites USING btree (team_id);


--
-- Name: index_team_members_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_members_on_team_id ON public.team_members USING btree (team_id);


--
-- Name: index_team_members_on_team_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_team_members_on_team_id_and_user_id ON public.team_members USING btree (team_id, user_id);


--
-- Name: index_team_members_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_members_on_user_id ON public.team_members USING btree (user_id);


--
-- Name: index_teams_on_handle; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_teams_on_handle ON public.teams USING btree (handle);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON public.users USING btree (unlock_token);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_username ON public.users USING btree (username);


--
-- Name: index_webhooks_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_webhooks_on_created_by_id ON public.webhooks USING btree (created_by_id);


--
-- Name: index_webhooks_on_decision_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_webhooks_on_decision_id ON public.webhooks USING btree (decision_id);


--
-- Name: index_webhooks_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_webhooks_on_team_id ON public.webhooks USING btree (team_id);


--
-- Name: decision_results _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.decision_results AS
 SELECT o.decision_id,
    o.id AS option_id,
    o.title AS option_title,
    COALESCE(sum(a.value), (0)::bigint) AS approved_yes,
    (count(a.value) - COALESCE(sum(a.value), (0)::bigint)) AS approved_no,
    count(a.value) AS approval_count,
    COALESCE(sum(a.stars), (0)::bigint) AS stars,
    o.random_id
   FROM (public.options o
     LEFT JOIN public.approvals a ON ((a.option_id = o.id)))
  GROUP BY o.decision_id, o.id
  ORDER BY COALESCE(sum(a.value), (0)::bigint) DESC, COALESCE(sum(a.stars), (0)::bigint) DESC, o.random_id DESC;


--
-- Name: decision_invites fk_rails_0558686910; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decision_invites
    ADD CONSTRAINT fk_rails_0558686910 FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: team_members fk_rails_194b5b076d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT fk_rails_194b5b076d FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: approvals fk_rails_23f31e4409; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approvals
    ADD CONSTRAINT fk_rails_23f31e4409 FOREIGN KEY (option_id) REFERENCES public.options(id);


--
-- Name: decision_participants fk_rails_2fac9cdcc1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decision_participants
    ADD CONSTRAINT fk_rails_2fac9cdcc1 FOREIGN KEY (decision_id) REFERENCES public.decisions(id);


--
-- Name: approvals fk_rails_387fb9c532; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approvals
    ADD CONSTRAINT fk_rails_387fb9c532 FOREIGN KEY (decision_id) REFERENCES public.decisions(id);


--
-- Name: decisions fk_rails_453a12fd18; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decisions
    ADD CONSTRAINT fk_rails_453a12fd18 FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: decision_invites fk_rails_62d2975652; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decision_invites
    ADD CONSTRAINT fk_rails_62d2975652 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: team_invites fk_rails_70e00c2daa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_invites
    ADD CONSTRAINT fk_rails_70e00c2daa FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: oauth_access_tokens fk_rails_732cb83ab7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_rails_732cb83ab7 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: decision_participants fk_rails_9abb85eb34; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decision_participants
    ADD CONSTRAINT fk_rails_9abb85eb34 FOREIGN KEY (invite_id) REFERENCES public.decision_invites(id);


--
-- Name: options fk_rails_9c86b231af; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.options
    ADD CONSTRAINT fk_rails_9c86b231af FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: options fk_rails_9d942eefce; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.options
    ADD CONSTRAINT fk_rails_9d942eefce FOREIGN KEY (decision_participant_id) REFERENCES public.decision_participants(id);


--
-- Name: team_members fk_rails_9ec2d5e75e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT fk_rails_9ec2d5e75e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: decision_invites fk_rails_a203efa0b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decision_invites
    ADD CONSTRAINT fk_rails_a203efa0b9 FOREIGN KEY (decision_id) REFERENCES public.decisions(id);


--
-- Name: approvals fk_rails_a6ed1157e1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approvals
    ADD CONSTRAINT fk_rails_a6ed1157e1 FOREIGN KEY (decision_participant_id) REFERENCES public.decision_participants(id);


--
-- Name: team_invites fk_rails_adf016a6d4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_invites
    ADD CONSTRAINT fk_rails_adf016a6d4 FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: oauth_access_grants fk_rails_b4b53e07b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_rails_b4b53e07b8 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: webhooks fk_rails_bb12e00e3c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT fk_rails_bb12e00e3c FOREIGN KEY (decision_id) REFERENCES public.decisions(id);


--
-- Name: webhooks fk_rails_c37817a11f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT fk_rails_c37817a11f FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: oauth_applications fk_rails_cc886e315a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT fk_rails_cc886e315a FOREIGN KEY (owner_id) REFERENCES public.users(id);


--
-- Name: approvals fk_rails_d0108bdf1a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approvals
    ADD CONSTRAINT fk_rails_d0108bdf1a FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: decisions fk_rails_db126ea214; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decisions
    ADD CONSTRAINT fk_rails_db126ea214 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: options fk_rails_df3bc80da2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.options
    ADD CONSTRAINT fk_rails_df3bc80da2 FOREIGN KEY (decision_id) REFERENCES public.decisions(id);


--
-- Name: webhooks fk_rails_e567730fa3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT fk_rails_e567730fa3 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20230325020222'),
('20230325020226'),
('20230325205117'),
('20230325231457'),
('20230325231507'),
('20230325231519'),
('20230325231529'),
('20230325231541'),
('20230325231549'),
('20230328030056'),
('20230329005723'),
('20230402225200'),
('20230405011057'),
('20230406011007'),
('20230408031436'),
('20230411232043'),
('20230411232223'),
('20230412040616'),
('20230412041938'),
('20230412044504'),
('20230415035625'),
('20230416044353'),
('20230416224308'),
('20230507175029'),
('20230507185725'),
('20230507200305'),
('20230507202114'),
('20230514003758'),
('20230514234410'),
('20230520210702'),
('20230520210703'),
('20230520211339'),
('20230524032233');


