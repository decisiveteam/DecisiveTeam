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
    tenant_id uuid NOT NULL
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
    tenant_id uuid NOT NULL
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
    tenant_id uuid NOT NULL
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
    tenant_id uuid NOT NULL
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
    other_attributes jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    truncated_id character varying GENERATED ALWAYS AS ("left"((id)::text, 8)) STORED NOT NULL,
    deadline timestamp(6) without time zone,
    created_by_id uuid,
    options_open boolean DEFAULT true NOT NULL,
    auth_required boolean DEFAULT false,
    tenant_id uuid NOT NULL
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
    updated_at timestamp(6) without time zone NOT NULL
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
    tenant_id uuid NOT NULL
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
    deadline timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP
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
    other_attributes jsonb,
    random_id integer DEFAULT (floor((random() * (1000000000)::double precision)))::integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    tenant_id uuid NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
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
    updated_at timestamp(6) without time zone NOT NULL
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
    settings jsonb DEFAULT '{}'::jsonb
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    auth0_id character varying NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    picture_url character varying,
    metadata json,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    image_url character varying
);


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
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


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
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


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
-- Name: index_commitment_participants_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commitment_participants_on_tenant_id ON public.commitment_participants USING btree (tenant_id);


--
-- Name: index_commitment_participants_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commitment_participants_on_user_id ON public.commitment_participants USING btree (user_id);


--
-- Name: index_commitments_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commitments_on_tenant_id ON public.commitments USING btree (tenant_id);


--
-- Name: index_commitments_on_truncated_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_commitments_on_truncated_id ON public.commitments USING btree (truncated_id);


--
-- Name: index_decision_participants_on_decision_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decision_participants_on_decision_id ON public.decision_participants USING btree (decision_id);


--
-- Name: index_decision_participants_on_decision_id_and_participant_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_decision_participants_on_decision_id_and_participant_uid ON public.decision_participants USING btree (decision_id, participant_uid);


--
-- Name: index_decision_participants_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decision_participants_on_tenant_id ON public.decision_participants USING btree (tenant_id);


--
-- Name: index_decisions_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decisions_on_tenant_id ON public.decisions USING btree (tenant_id);


--
-- Name: index_decisions_on_truncated_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_decisions_on_truncated_id ON public.decisions USING btree (truncated_id);


--
-- Name: index_links_on_from_linkable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_links_on_from_linkable ON public.links USING btree (from_linkable_type, from_linkable_id);


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
-- Name: index_note_history_events_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_history_events_on_tenant_id ON public.note_history_events USING btree (tenant_id);


--
-- Name: index_note_history_events_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_history_events_on_user_id ON public.note_history_events USING btree (user_id);


--
-- Name: index_notes_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_tenant_id ON public.notes USING btree (tenant_id);


--
-- Name: index_notes_on_truncated_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_notes_on_truncated_id ON public.notes USING btree (truncated_id);


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
-- Name: index_options_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_options_on_tenant_id ON public.options USING btree (tenant_id);


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
-- Name: index_tenants_on_subdomain; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tenants_on_subdomain ON public.tenants USING btree (subdomain);


--
-- Name: index_users_on_auth0_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_auth0_id ON public.users USING btree (auth0_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


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
-- Name: approvals fk_rails_23f31e4409; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approvals
    ADD CONSTRAINT fk_rails_23f31e4409 FOREIGN KEY (option_id) REFERENCES public.options(id);


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
-- Name: note_history_events fk_rails_601d54357c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_history_events
    ADD CONSTRAINT fk_rails_601d54357c FOREIGN KEY (note_id) REFERENCES public.notes(id);


--
-- Name: note_history_events fk_rails_63e2a8744d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_history_events
    ADD CONSTRAINT fk_rails_63e2a8744d FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: decision_participants fk_rails_81ebc9cc6f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decision_participants
    ADD CONSTRAINT fk_rails_81ebc9cc6f FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: options fk_rails_9d942eefce; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.options
    ADD CONSTRAINT fk_rails_9d942eefce FOREIGN KEY (decision_participant_id) REFERENCES public.decision_participants(id);


--
-- Name: approvals fk_rails_a6ed1157e1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approvals
    ADD CONSTRAINT fk_rails_a6ed1157e1 FOREIGN KEY (decision_participant_id) REFERENCES public.decision_participants(id);


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
-- Name: decisions fk_rails_db126ea214; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decisions
    ADD CONSTRAINT fk_rails_db126ea214 FOREIGN KEY (created_by_id) REFERENCES public.decision_participants(id);


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
-- Name: notes fk_rails_e420fccb7e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_e420fccb7e FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


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
-- Name: commitment_participants fk_rails_f513f0d5dd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commitment_participants
    ADD CONSTRAINT fk_rails_f513f0d5dd FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


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
('20241125235008');


