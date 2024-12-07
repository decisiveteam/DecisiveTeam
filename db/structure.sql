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

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: api_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid NOT NULL,
    name character varying,
    token character varying NOT NULL,
    last_used_at timestamp(6) without time zone,
    expires_at timestamp(6) without time zone DEFAULT (CURRENT_TIMESTAMP + '1 year'::interval),
    scopes jsonb DEFAULT '[]'::jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    deleted_at timestamp(6) without time zone
);


--
-- Name: approvals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.approvals (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    decision_id uuid,
    decision_participant_id uuid,
    option_id uuid,
    value integer NOT NULL,
    stars integer DEFAULT 0,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    tenant_id uuid NOT NULL,
    studio_id uuid
);


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
-- Name: commitment_participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commitment_participants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    commitment_id uuid NOT NULL,
    user_id uuid,
    participant_uid character varying DEFAULT ''::character varying NOT NULL,
    name character varying,
    committed_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    tenant_id uuid NOT NULL,
    studio_id uuid
);


--
-- Name: commitments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commitments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title text,
    description text,
    critical_mass integer,
    deadline timestamp(6) without time zone,
    truncated_id character varying GENERATED ALWAYS AS ("left"((id)::text, 8)) STORED NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    tenant_id uuid NOT NULL,
    created_by_id uuid,
    updated_by_id uuid,
    studio_id uuid
);


--
-- Name: custom_data_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_data_associations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    parent_record_id uuid NOT NULL,
    child_record_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    studio_id uuid
);


--
-- Name: custom_data_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_data_configs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    config jsonb DEFAULT '{}'::jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    studio_id uuid
);


--
-- Name: custom_data_history_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_data_history_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    custom_data_record_id uuid NOT NULL,
    user_id uuid NOT NULL,
    happened_at timestamp(6) without time zone NOT NULL,
    event_type character varying NOT NULL,
    event_data jsonb DEFAULT '{}'::jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    studio_id uuid
);


--
-- Name: custom_data_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_data_records (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    created_by_id uuid NOT NULL,
    updated_by_id uuid NOT NULL,
    table_id uuid NOT NULL,
    custom_uid character varying,
    data jsonb DEFAULT '{}'::jsonb,
    deleted_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    studio_id uuid
);


--
-- Name: custom_data_tables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_data_tables (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    name character varying NOT NULL,
    config jsonb DEFAULT '{}'::jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    studio_id uuid
);


--
-- Name: decision_participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.decision_participants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    decision_id uuid,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id uuid,
    participant_uid character varying DEFAULT ''::character varying NOT NULL,
    tenant_id uuid NOT NULL,
    studio_id uuid
);


--
-- Name: decision_results; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.decision_results AS
SELECT
    NULL::uuid AS tenant_id,
    NULL::uuid AS decision_id,
    NULL::uuid AS option_id,
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
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    question text,
    description text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    truncated_id character varying GENERATED ALWAYS AS ("left"((id)::text, 8)) STORED NOT NULL,
    deadline timestamp(6) without time zone,
    options_open boolean DEFAULT true NOT NULL,
    tenant_id uuid NOT NULL,
    created_by_id uuid,
    updated_by_id uuid,
    studio_id uuid
);


--
-- Name: links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.links (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    from_linkable_type character varying NOT NULL,
    from_linkable_id uuid NOT NULL,
    to_linkable_type character varying NOT NULL,
    to_linkable_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    studio_id uuid
);


--
-- Name: note_history_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.note_history_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    note_id uuid NOT NULL,
    user_id uuid,
    event_type character varying,
    happened_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    tenant_id uuid NOT NULL,
    studio_id uuid
);


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title text,
    text text,
    truncated_id character varying GENERATED ALWAYS AS ("left"((id)::text, 8)) STORED NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    tenant_id uuid NOT NULL,
    deadline timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by_id uuid,
    updated_by_id uuid,
    studio_id uuid
);


--
-- Name: oauth_identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_identities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    provider character varying,
    uid character varying,
    last_sign_in_at timestamp(6) without time zone,
    url character varying,
    username character varying,
    image_url character varying,
    auth_data jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.options (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    decision_id uuid,
    decision_participant_id uuid,
    title text NOT NULL,
    description text,
    random_id integer DEFAULT (floor((random() * (1000000000)::double precision)))::integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    tenant_id uuid NOT NULL,
    studio_id uuid
);


--
-- Name: pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    studio_id uuid NOT NULL,
    user_id uuid NOT NULL,
    path character varying NOT NULL,
    title character varying DEFAULT ''::character varying NOT NULL,
    markdown text DEFAULT ''::text NOT NULL,
    html text DEFAULT ''::text NOT NULL,
    published boolean DEFAULT false NOT NULL,
    published_at timestamp(6) without time zone,
    archived_at timestamp(6) without time zone,
    settings jsonb DEFAULT '{}'::jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: representation_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.representation_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    studio_id uuid NOT NULL,
    representative_user_id uuid NOT NULL,
    trustee_user_id uuid NOT NULL,
    began_at timestamp(6) without time zone NOT NULL,
    ended_at timestamp(6) without time zone,
    confirmed_understanding boolean DEFAULT false NOT NULL,
    activity_log jsonb DEFAULT '{}'::jsonb,
    truncated_id character varying GENERATED ALWAYS AS ("left"((id)::text, 8)) STORED NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: studio_invites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.studio_invites (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    studio_id uuid NOT NULL,
    created_by_id uuid NOT NULL,
    invited_user_id uuid,
    code character varying NOT NULL,
    expires_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: studio_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.studio_users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    studio_id uuid NOT NULL,
    user_id uuid NOT NULL,
    archived_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    settings jsonb DEFAULT '{}'::jsonb
);


--
-- Name: studios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.studios (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    name character varying,
    handle character varying,
    settings jsonb DEFAULT '{}'::jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    created_by_id uuid NOT NULL,
    updated_by_id uuid NOT NULL,
    trustee_user_id uuid
);


--
-- Name: tenant_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid NOT NULL,
    handle character varying NOT NULL,
    display_name character varying NOT NULL,
    settings jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    archived_at timestamp(6) without time zone
);


--
-- Name: tenants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    subdomain character varying NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    settings jsonb DEFAULT '{}'::jsonb,
    main_studio_id uuid
);


--
-- Name: trustee_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trustee_permissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    trustee_user_id uuid NOT NULL,
    granting_user_id uuid NOT NULL,
    trusted_user_id uuid NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    relationship_phrase character varying DEFAULT '{trusted_user} on behalf of {granting_user}'::character varying NOT NULL,
    permissions jsonb DEFAULT '{}'::jsonb,
    expires_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    picture_url character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    image_url character varying,
    parent_id uuid,
    user_type character varying DEFAULT 'person'::character varying
);


--
-- Name: api_tokens api_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_tokens
    ADD CONSTRAINT api_tokens_pkey PRIMARY KEY (id);


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
-- Name: commitment_participants commitment_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commitment_participants
    ADD CONSTRAINT commitment_participants_pkey PRIMARY KEY (id);


--
-- Name: commitments commitments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commitments
    ADD CONSTRAINT commitments_pkey PRIMARY KEY (id);


--
-- Name: custom_data_associations custom_data_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_associations
    ADD CONSTRAINT custom_data_associations_pkey PRIMARY KEY (id);


--
-- Name: custom_data_configs custom_data_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_configs
    ADD CONSTRAINT custom_data_configs_pkey PRIMARY KEY (id);


--
-- Name: custom_data_history_events custom_data_history_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_history_events
    ADD CONSTRAINT custom_data_history_events_pkey PRIMARY KEY (id);


--
-- Name: custom_data_records custom_data_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_records
    ADD CONSTRAINT custom_data_records_pkey PRIMARY KEY (id);


--
-- Name: custom_data_tables custom_data_tables_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_tables
    ADD CONSTRAINT custom_data_tables_pkey PRIMARY KEY (id);


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
-- Name: links links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: note_history_events note_history_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_history_events
    ADD CONSTRAINT note_history_events_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: oauth_identities oauth_identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_identities
    ADD CONSTRAINT oauth_identities_pkey PRIMARY KEY (id);


--
-- Name: options options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.options
    ADD CONSTRAINT options_pkey PRIMARY KEY (id);


--
-- Name: pages pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: representation_sessions representation_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representation_sessions
    ADD CONSTRAINT representation_sessions_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: studio_invites studio_invites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.studio_invites
    ADD CONSTRAINT studio_invites_pkey PRIMARY KEY (id);


--
-- Name: studio_users studio_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.studio_users
    ADD CONSTRAINT studio_users_pkey PRIMARY KEY (id);


--
-- Name: studios studios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.studios
    ADD CONSTRAINT studios_pkey PRIMARY KEY (id);


--
-- Name: tenant_users tenant_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_users
    ADD CONSTRAINT tenant_users_pkey PRIMARY KEY (id);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: trustee_permissions trustee_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trustee_permissions
    ADD CONSTRAINT trustee_permissions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_api_tokens_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_api_tokens_on_tenant_id ON public.api_tokens USING btree (tenant_id);


--
-- Name: index_api_tokens_on_tenant_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_api_tokens_on_tenant_id_and_user_id ON public.api_tokens USING btree (tenant_id, user_id);


--
-- Name: index_api_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_api_tokens_on_token ON public.api_tokens USING btree (token);


--
-- Name: index_api_tokens_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_api_tokens_on_user_id ON public.api_tokens USING btree (user_id);


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
-- Name: index_approvals_on_studio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_approvals_on_studio_id ON public.approvals USING btree (studio_id);


--
-- Name: index_approvals_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_approvals_on_tenant_id ON public.approvals USING btree (tenant_id);


--
-- Name: index_commitment_participants_on_commitment_and_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_commitment_participants_on_commitment_and_uid ON public.commitment_participants USING btree (commitment_id, participant_uid);


--
-- Name: index_commitment_participants_on_commitment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commitment_participants_on_commitment_id ON public.commitment_participants USING btree (commitment_id);


--
-- Name: index_commitment_participants_on_participant_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commitment_participants_on_participant_uid ON public.commitment_participants USING btree (participant_uid);


--
-- Name: index_commitment_participants_on_studio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commitment_participants_on_studio_id ON public.commitment_participants USING btree (studio_id);


--
-- Name: index_commitment_participants_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commitment_participants_on_tenant_id ON public.commitment_participants USING btree (tenant_id);


--
-- Name: index_commitment_participants_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commitment_participants_on_user_id ON public.commitment_participants USING btree (user_id);


--
-- Name: index_commitments_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commitments_on_created_by_id ON public.commitments USING btree (created_by_id);


--
-- Name: index_commitments_on_studio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commitments_on_studio_id ON public.commitments USING btree (studio_id);


--
-- Name: index_commitments_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commitments_on_tenant_id ON public.commitments USING btree (tenant_id);


--
-- Name: index_commitments_on_truncated_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_commitments_on_truncated_id ON public.commitments USING btree (truncated_id);


--
-- Name: index_commitments_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commitments_on_updated_by_id ON public.commitments USING btree (updated_by_id);


--
-- Name: index_custom_data_associations_on_child_record_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_data_associations_on_child_record_id ON public.custom_data_associations USING btree (child_record_id);


--
-- Name: index_custom_data_associations_on_parent_record_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_data_associations_on_parent_record_id ON public.custom_data_associations USING btree (parent_record_id);


--
-- Name: index_custom_data_associations_on_studio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_data_associations_on_studio_id ON public.custom_data_associations USING btree (studio_id);


--
-- Name: index_custom_data_associations_on_ten_par; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_data_associations_on_ten_par ON public.custom_data_associations USING btree (tenant_id, parent_record_id);


--
-- Name: index_custom_data_associations_on_ten_par_chi; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_custom_data_associations_on_ten_par_chi ON public.custom_data_associations USING btree (tenant_id, parent_record_id, child_record_id);


--
-- Name: index_custom_data_associations_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_data_associations_on_tenant_id ON public.custom_data_associations USING btree (tenant_id);


--
-- Name: index_custom_data_configs_on_studio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_data_configs_on_studio_id ON public.custom_data_configs USING btree (studio_id);


--
-- Name: index_custom_data_configs_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_data_configs_on_tenant_id ON public.custom_data_configs USING btree (tenant_id);


--
-- Name: index_custom_data_history_events_on_custom_data_record_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_data_history_events_on_custom_data_record_id ON public.custom_data_history_events USING btree (custom_data_record_id);


--
-- Name: index_custom_data_history_events_on_studio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_data_history_events_on_studio_id ON public.custom_data_history_events USING btree (studio_id);


--
-- Name: index_custom_data_history_events_on_ten_cdr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_data_history_events_on_ten_cdr ON public.custom_data_history_events USING btree (tenant_id, custom_data_record_id);


--
-- Name: index_custom_data_history_events_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_data_history_events_on_tenant_id ON public.custom_data_history_events USING btree (tenant_id);


--
-- Name: index_custom_data_history_events_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_data_history_events_on_user_id ON public.custom_data_history_events USING btree (user_id);


--
-- Name: index_custom_data_on_ten_tab; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_data_on_ten_tab ON public.custom_data_records USING btree (tenant_id, table_id);


--
-- Name: index_custom_data_on_ten_tab_cuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_custom_data_on_ten_tab_cuid ON public.custom_data_records USING btree (tenant_id, table_id, custom_uid);


--
-- Name: index_custom_data_records_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_data_records_on_created_by_id ON public.custom_data_records USING btree (created_by_id);


--
-- Name: index_custom_data_records_on_studio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_data_records_on_studio_id ON public.custom_data_records USING btree (studio_id);


--
-- Name: index_custom_data_records_on_table_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_data_records_on_table_id ON public.custom_data_records USING btree (table_id);


--
-- Name: index_custom_data_records_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_data_records_on_tenant_id ON public.custom_data_records USING btree (tenant_id);


--
-- Name: index_custom_data_records_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_data_records_on_updated_by_id ON public.custom_data_records USING btree (updated_by_id);


--
-- Name: index_custom_data_tables_on_studio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_data_tables_on_studio_id ON public.custom_data_tables USING btree (studio_id);


--
-- Name: index_custom_data_tables_on_tenant_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_custom_data_tables_on_tenant_and_name ON public.custom_data_tables USING btree (tenant_id, name);


--
-- Name: index_custom_data_tables_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_data_tables_on_tenant_id ON public.custom_data_tables USING btree (tenant_id);


--
-- Name: index_decision_participants_on_decision_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decision_participants_on_decision_id ON public.decision_participants USING btree (decision_id);


--
-- Name: index_decision_participants_on_decision_id_and_participant_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_decision_participants_on_decision_id_and_participant_uid ON public.decision_participants USING btree (decision_id, participant_uid);


--
-- Name: index_decision_participants_on_studio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decision_participants_on_studio_id ON public.decision_participants USING btree (studio_id);


--
-- Name: index_decision_participants_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decision_participants_on_tenant_id ON public.decision_participants USING btree (tenant_id);


--
-- Name: index_decisions_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decisions_on_created_by_id ON public.decisions USING btree (created_by_id);


--
-- Name: index_decisions_on_studio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decisions_on_studio_id ON public.decisions USING btree (studio_id);


--
-- Name: index_decisions_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decisions_on_tenant_id ON public.decisions USING btree (tenant_id);


--
-- Name: index_decisions_on_truncated_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_decisions_on_truncated_id ON public.decisions USING btree (truncated_id);


--
-- Name: index_decisions_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decisions_on_updated_by_id ON public.decisions USING btree (updated_by_id);


--
-- Name: index_links_on_from_linkable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_links_on_from_linkable ON public.links USING btree (from_linkable_type, from_linkable_id);


--
-- Name: index_links_on_studio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_links_on_studio_id ON public.links USING btree (studio_id);


--
-- Name: index_links_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_links_on_tenant_id ON public.links USING btree (tenant_id);


--
-- Name: index_links_on_to_linkable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_links_on_to_linkable ON public.links USING btree (to_linkable_type, to_linkable_id);


--
-- Name: index_note_history_events_on_note_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_history_events_on_note_id ON public.note_history_events USING btree (note_id);


--
-- Name: index_note_history_events_on_studio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_history_events_on_studio_id ON public.note_history_events USING btree (studio_id);


--
-- Name: index_note_history_events_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_history_events_on_tenant_id ON public.note_history_events USING btree (tenant_id);


--
-- Name: index_note_history_events_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_history_events_on_user_id ON public.note_history_events USING btree (user_id);


--
-- Name: index_notes_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_created_by_id ON public.notes USING btree (created_by_id);


--
-- Name: index_notes_on_studio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_studio_id ON public.notes USING btree (studio_id);


--
-- Name: index_notes_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_tenant_id ON public.notes USING btree (tenant_id);


--
-- Name: index_notes_on_truncated_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_notes_on_truncated_id ON public.notes USING btree (truncated_id);


--
-- Name: index_notes_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_updated_by_id ON public.notes USING btree (updated_by_id);


--
-- Name: index_oauth_identities_on_provider_and_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_identities_on_provider_and_uid ON public.oauth_identities USING btree (provider, uid);


--
-- Name: index_oauth_identities_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_identities_on_user_id ON public.oauth_identities USING btree (user_id);


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
-- Name: index_options_on_studio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_options_on_studio_id ON public.options USING btree (studio_id);


--
-- Name: index_options_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_options_on_tenant_id ON public.options USING btree (tenant_id);


--
-- Name: index_pages_on_studio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pages_on_studio_id ON public.pages USING btree (studio_id);


--
-- Name: index_pages_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pages_on_tenant_id ON public.pages USING btree (tenant_id);


--
-- Name: index_pages_on_tenant_id_and_studio_id_and_path; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pages_on_tenant_id_and_studio_id_and_path ON public.pages USING btree (tenant_id, studio_id, path);


--
-- Name: index_pages_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pages_on_user_id ON public.pages USING btree (user_id);


--
-- Name: index_representation_sessions_on_representative_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_representation_sessions_on_representative_user_id ON public.representation_sessions USING btree (representative_user_id);


--
-- Name: index_representation_sessions_on_studio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_representation_sessions_on_studio_id ON public.representation_sessions USING btree (studio_id);


--
-- Name: index_representation_sessions_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_representation_sessions_on_tenant_id ON public.representation_sessions USING btree (tenant_id);


--
-- Name: index_representation_sessions_on_truncated_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_representation_sessions_on_truncated_id ON public.representation_sessions USING btree (truncated_id);


--
-- Name: index_representation_sessions_on_trustee_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_representation_sessions_on_trustee_user_id ON public.representation_sessions USING btree (trustee_user_id);


--
-- Name: index_studio_invites_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_studio_invites_on_code ON public.studio_invites USING btree (code);


--
-- Name: index_studio_invites_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_studio_invites_on_created_by_id ON public.studio_invites USING btree (created_by_id);


--
-- Name: index_studio_invites_on_invited_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_studio_invites_on_invited_user_id ON public.studio_invites USING btree (invited_user_id);


--
-- Name: index_studio_invites_on_studio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_studio_invites_on_studio_id ON public.studio_invites USING btree (studio_id);


--
-- Name: index_studio_invites_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_studio_invites_on_tenant_id ON public.studio_invites USING btree (tenant_id);


--
-- Name: index_studio_users_on_studio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_studio_users_on_studio_id ON public.studio_users USING btree (studio_id);


--
-- Name: index_studio_users_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_studio_users_on_tenant_id ON public.studio_users USING btree (tenant_id);


--
-- Name: index_studio_users_on_tenant_id_and_studio_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_studio_users_on_tenant_id_and_studio_id_and_user_id ON public.studio_users USING btree (tenant_id, studio_id, user_id);


--
-- Name: index_studio_users_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_studio_users_on_user_id ON public.studio_users USING btree (user_id);


--
-- Name: index_studios_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_studios_on_created_by_id ON public.studios USING btree (created_by_id);


--
-- Name: index_studios_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_studios_on_tenant_id ON public.studios USING btree (tenant_id);


--
-- Name: index_studios_on_tenant_id_and_handle; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_studios_on_tenant_id_and_handle ON public.studios USING btree (tenant_id, handle);


--
-- Name: index_studios_on_updated_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_studios_on_updated_by_id ON public.studios USING btree (updated_by_id);


--
-- Name: index_tenant_users_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_users_on_tenant_id ON public.tenant_users USING btree (tenant_id);


--
-- Name: index_tenant_users_on_tenant_id_and_handle; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tenant_users_on_tenant_id_and_handle ON public.tenant_users USING btree (tenant_id, handle);


--
-- Name: index_tenant_users_on_tenant_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tenant_users_on_tenant_id_and_user_id ON public.tenant_users USING btree (tenant_id, user_id);


--
-- Name: index_tenant_users_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_users_on_user_id ON public.tenant_users USING btree (user_id);


--
-- Name: index_tenants_on_main_studio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenants_on_main_studio_id ON public.tenants USING btree (main_studio_id);


--
-- Name: index_tenants_on_subdomain; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tenants_on_subdomain ON public.tenants USING btree (subdomain);


--
-- Name: index_trustee_permissions_on_granting_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trustee_permissions_on_granting_user_id ON public.trustee_permissions USING btree (granting_user_id);


--
-- Name: index_trustee_permissions_on_trusted_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trustee_permissions_on_trusted_user_id ON public.trustee_permissions USING btree (trusted_user_id);


--
-- Name: index_trustee_permissions_on_trustee_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trustee_permissions_on_trustee_user_id ON public.trustee_permissions USING btree (trustee_user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_parent_id ON public.users USING btree (parent_id);


--
-- Name: decision_results _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.decision_results AS
 SELECT o.tenant_id,
    o.decision_id,
    o.id AS option_id,
    o.title AS option_title,
    COALESCE(sum(a.value), (0)::bigint) AS approved_yes,
    (count(a.value) - COALESCE(sum(a.value), (0)::bigint)) AS approved_no,
    count(a.value) AS approval_count,
    COALESCE(sum(a.stars), (0)::bigint) AS stars,
    o.random_id
   FROM (public.options o
     LEFT JOIN public.approvals a ON ((a.option_id = o.id)))
  GROUP BY o.tenant_id, o.decision_id, o.id
  ORDER BY COALESCE(sum(a.value), (0)::bigint) DESC, COALESCE(sum(a.stars), (0)::bigint) DESC, o.random_id DESC;


--
-- Name: studio_invites fk_rails_07e7bb098b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.studio_invites
    ADD CONSTRAINT fk_rails_07e7bb098b FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: note_history_events fk_rails_0a4621d4f9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_history_events
    ADD CONSTRAINT fk_rails_0a4621d4f9 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: approvals fk_rails_0e623a5b8b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approvals
    ADD CONSTRAINT fk_rails_0e623a5b8b FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: options fk_rails_129a008786; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.options
    ADD CONSTRAINT fk_rails_129a008786 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: decisions fk_rails_148841bc6d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decisions
    ADD CONSTRAINT fk_rails_148841bc6d FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: custom_data_records fk_rails_16ae25aeab; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_records
    ADD CONSTRAINT fk_rails_16ae25aeab FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: studio_invites fk_rails_19f2570176; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.studio_invites
    ADD CONSTRAINT fk_rails_19f2570176 FOREIGN KEY (invited_user_id) REFERENCES public.users(id);


--
-- Name: custom_data_records fk_rails_1f9c7e3c30; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_records
    ADD CONSTRAINT fk_rails_1f9c7e3c30 FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: approvals fk_rails_23f31e4409; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approvals
    ADD CONSTRAINT fk_rails_23f31e4409 FOREIGN KEY (option_id) REFERENCES public.options(id);


--
-- Name: studio_users fk_rails_247e24a571; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.studio_users
    ADD CONSTRAINT fk_rails_247e24a571 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: pages fk_rails_2692f121c1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT fk_rails_2692f121c1 FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: studio_invites fk_rails_29373b6d24; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.studio_invites
    ADD CONSTRAINT fk_rails_29373b6d24 FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: commitments fk_rails_2b0260c142; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commitments
    ADD CONSTRAINT fk_rails_2b0260c142 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: oauth_identities fk_rails_2f75762ff1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_identities
    ADD CONSTRAINT fk_rails_2f75762ff1 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: decision_participants fk_rails_2fac9cdcc1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decision_participants
    ADD CONSTRAINT fk_rails_2fac9cdcc1 FOREIGN KEY (decision_id) REFERENCES public.decisions(id);


--
-- Name: representation_sessions fk_rails_33f2d734e7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representation_sessions
    ADD CONSTRAINT fk_rails_33f2d734e7 FOREIGN KEY (representative_user_id) REFERENCES public.users(id);


--
-- Name: custom_data_history_events fk_rails_37658b724a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_history_events
    ADD CONSTRAINT fk_rails_37658b724a FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: decisions fk_rails_3844b64911; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decisions
    ADD CONSTRAINT fk_rails_3844b64911 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: approvals fk_rails_387fb9c532; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approvals
    ADD CONSTRAINT fk_rails_387fb9c532 FOREIGN KEY (decision_id) REFERENCES public.decisions(id);


--
-- Name: custom_data_configs fk_rails_3a16ee90b1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_configs
    ADD CONSTRAINT fk_rails_3a16ee90b1 FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: studios fk_rails_3a6c376636; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.studios
    ADD CONSTRAINT fk_rails_3a6c376636 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: options fk_rails_3c650690de; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.options
    ADD CONSTRAINT fk_rails_3c650690de FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: custom_data_history_events fk_rails_3ed7817b22; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_history_events
    ADD CONSTRAINT fk_rails_3ed7817b22 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: commitment_participants fk_rails_40630ce2d2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commitment_participants
    ADD CONSTRAINT fk_rails_40630ce2d2 FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: custom_data_associations fk_rails_47eb6a7643; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_associations
    ADD CONSTRAINT fk_rails_47eb6a7643 FOREIGN KEY (child_record_id) REFERENCES public.custom_data_records(id);


--
-- Name: notes fk_rails_492bbd23f7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_492bbd23f7 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: commitments fk_rails_4bd2b4721e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commitments
    ADD CONSTRAINT fk_rails_4bd2b4721e FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: custom_data_associations fk_rails_5329956518; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_associations
    ADD CONSTRAINT fk_rails_5329956518 FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: custom_data_records fk_rails_547bd37e39; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_records
    ADD CONSTRAINT fk_rails_547bd37e39 FOREIGN KEY (table_id) REFERENCES public.custom_data_tables(id);


--
-- Name: studio_users fk_rails_55c1625b39; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.studio_users
    ADD CONSTRAINT fk_rails_55c1625b39 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: note_history_events fk_rails_601d54357c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_history_events
    ADD CONSTRAINT fk_rails_601d54357c FOREIGN KEY (note_id) REFERENCES public.notes(id);


--
-- Name: trustee_permissions fk_rails_61c22cd494; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trustee_permissions
    ADD CONSTRAINT fk_rails_61c22cd494 FOREIGN KEY (trusted_user_id) REFERENCES public.users(id);


--
-- Name: custom_data_history_events fk_rails_62e827a410; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_history_events
    ADD CONSTRAINT fk_rails_62e827a410 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: note_history_events fk_rails_63e2a8744d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_history_events
    ADD CONSTRAINT fk_rails_63e2a8744d FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: links fk_rails_6888b30c51; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT fk_rails_6888b30c51 FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: studio_users fk_rails_6922fe428a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.studio_users
    ADD CONSTRAINT fk_rails_6922fe428a FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: custom_data_tables fk_rails_6bf817584a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_tables
    ADD CONSTRAINT fk_rails_6bf817584a FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: studio_invites fk_rails_6dd1026bef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.studio_invites
    ADD CONSTRAINT fk_rails_6dd1026bef FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: notes fk_rails_6e1963e950; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_6e1963e950 FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: custom_data_records fk_rails_7a8f8686b3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_records
    ADD CONSTRAINT fk_rails_7a8f8686b3 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: decisions fk_rails_7ee5cf7c37; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decisions
    ADD CONSTRAINT fk_rails_7ee5cf7c37 FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: tenants fk_rails_81228c3d0f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT fk_rails_81228c3d0f FOREIGN KEY (main_studio_id) REFERENCES public.studios(id);


--
-- Name: decision_participants fk_rails_81ebc9cc6f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decision_participants
    ADD CONSTRAINT fk_rails_81ebc9cc6f FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: pages fk_rails_84a58494eb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT fk_rails_84a58494eb FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: custom_data_tables fk_rails_84f28416f5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_tables
    ADD CONSTRAINT fk_rails_84f28416f5 FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: trustee_permissions fk_rails_8bee20bb10; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trustee_permissions
    ADD CONSTRAINT fk_rails_8bee20bb10 FOREIGN KEY (trustee_user_id) REFERENCES public.users(id);


--
-- Name: studios fk_rails_8d8050599b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.studios
    ADD CONSTRAINT fk_rails_8d8050599b FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: note_history_events fk_rails_927b722124; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_history_events
    ADD CONSTRAINT fk_rails_927b722124 FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: options fk_rails_9d942eefce; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.options
    ADD CONSTRAINT fk_rails_9d942eefce FOREIGN KEY (decision_participant_id) REFERENCES public.decision_participants(id);


--
-- Name: custom_data_associations fk_rails_a0b74741d4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_associations
    ADD CONSTRAINT fk_rails_a0b74741d4 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: approvals fk_rails_a6ed1157e1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approvals
    ADD CONSTRAINT fk_rails_a6ed1157e1 FOREIGN KEY (decision_participant_id) REFERENCES public.decision_participants(id);


--
-- Name: commitments fk_rails_ae61a497df; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commitments
    ADD CONSTRAINT fk_rails_ae61a497df FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: custom_data_history_events fk_rails_ae91ef006c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_history_events
    ADD CONSTRAINT fk_rails_ae91ef006c FOREIGN KEY (custom_data_record_id) REFERENCES public.custom_data_records(id);


--
-- Name: approvals fk_rails_ae9f41675e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approvals
    ADD CONSTRAINT fk_rails_ae9f41675e FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: custom_data_associations fk_rails_bb143a6f24; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_associations
    ADD CONSTRAINT fk_rails_bb143a6f24 FOREIGN KEY (parent_record_id) REFERENCES public.custom_data_records(id);


--
-- Name: custom_data_configs fk_rails_bceb6b3236; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_configs
    ADD CONSTRAINT fk_rails_bceb6b3236 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: pages fk_rails_c7f006a55b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT fk_rails_c7f006a55b FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: commitment_participants fk_rails_ca2dcc834c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commitment_participants
    ADD CONSTRAINT fk_rails_ca2dcc834c FOREIGN KEY (commitment_id) REFERENCES public.commitments(id);


--
-- Name: links fk_rails_cd7c2a63d7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT fk_rails_cd7c2a63d7 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: api_tokens fk_rails_ce1100e505; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_tokens
    ADD CONSTRAINT fk_rails_ce1100e505 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: representation_sessions fk_rails_d99c283120; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representation_sessions
    ADD CONSTRAINT fk_rails_d99c283120 FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: decisions fk_rails_db126ea214; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decisions
    ADD CONSTRAINT fk_rails_db126ea214 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: representation_sessions fk_rails_db6c6b2118; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representation_sessions
    ADD CONSTRAINT fk_rails_db6c6b2118 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: trustee_permissions fk_rails_dc3eb15db3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trustee_permissions
    ADD CONSTRAINT fk_rails_dc3eb15db3 FOREIGN KEY (granting_user_id) REFERENCES public.users(id);


--
-- Name: options fk_rails_df3bc80da2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.options
    ADD CONSTRAINT fk_rails_df3bc80da2 FOREIGN KEY (decision_id) REFERENCES public.decisions(id);


--
-- Name: tenant_users fk_rails_e15916f8bf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_users
    ADD CONSTRAINT fk_rails_e15916f8bf FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: tenant_users fk_rails_e3b237e564; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_users
    ADD CONSTRAINT fk_rails_e3b237e564 FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: custom_data_records fk_rails_e3e720d41a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_data_records
    ADD CONSTRAINT fk_rails_e3e720d41a FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: notes fk_rails_e420fccb7e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_e420fccb7e FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: commitments fk_rails_e4837f1e6d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commitments
    ADD CONSTRAINT fk_rails_e4837f1e6d FOREIGN KEY (updated_by_id) REFERENCES public.users(id);


--
-- Name: representation_sessions fk_rails_ee2c2c283c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.representation_sessions
    ADD CONSTRAINT fk_rails_ee2c2c283c FOREIGN KEY (trustee_user_id) REFERENCES public.users(id);


--
-- Name: decision_participants fk_rails_ef2bebed7c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decision_participants
    ADD CONSTRAINT fk_rails_ef2bebed7c FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: commitment_participants fk_rails_f0bea833a7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commitment_participants
    ADD CONSTRAINT fk_rails_f0bea833a7 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: notes fk_rails_f11a0907b0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_f11a0907b0 FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: api_tokens fk_rails_f16b5e0447; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_tokens
    ADD CONSTRAINT fk_rails_f16b5e0447 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: commitment_participants fk_rails_f513f0d5dd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commitment_participants
    ADD CONSTRAINT fk_rails_f513f0d5dd FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: decision_participants fk_rails_f9c15d4765; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decision_participants
    ADD CONSTRAINT fk_rails_f9c15d4765 FOREIGN KEY (studio_id) REFERENCES public.studios(id);


--
-- Name: studios fk_rails_fbb5f3e2b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.studios
    ADD CONSTRAINT fk_rails_fbb5f3e2b8 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


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
('20230524032233'),
('20230619223228'),
('20230808204725'),
('20230810195248'),
('20230811224634'),
('20230811232138'),
('20230812051757'),
('20230826212206'),
('20230827183501'),
('20230827190826'),
('20230908024626'),
('20230913025720'),
('20231005010534'),
('20241003023146'),
('20241012185630'),
('20241108202425'),
('20241110205225'),
('20241112212624'),
('20241112214416'),
('20241115022429'),
('20241119182930'),
('20241120025254'),
('20241120183533'),
('20241123230912'),
('20241124001646'),
('20241125235008'),
('20241126215856'),
('20241127005322'),
('20241127011437'),
('20241127174032'),
('20241128041104'),
('20241128054723'),
('20241128204415'),
('20241130040434'),
('20241130211736'),
('20241203033229'),
('20241204200412'),
('20241205180447'),
('20241205223939'),
('20241205225353'),
('20241206195305');


