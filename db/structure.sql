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
    updated_at timestamp(6) without time zone NOT NULL
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
-- Name: decision_participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.decision_participants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    decision_id uuid,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id uuid,
    participant_uid character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: decision_results; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.decision_results AS
SELECT
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
    auth_required boolean DEFAULT false
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
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
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
    updated_at timestamp(6) without time zone NOT NULL
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
-- Name: index_decision_participants_on_decision_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_decision_participants_on_decision_id ON public.decision_participants USING btree (decision_id);


--
-- Name: index_decision_participants_on_decision_id_and_participant_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_decision_participants_on_decision_id_and_participant_uid ON public.decision_participants USING btree (decision_id, participant_uid);


--
-- Name: index_decisions_on_truncated_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_decisions_on_truncated_id ON public.decisions USING btree (truncated_id);


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
('20231005010534');


