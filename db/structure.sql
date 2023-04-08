CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "users" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "email" varchar DEFAULT '' NOT NULL, "encrypted_password" varchar DEFAULT '' NOT NULL, "reset_password_token" varchar, "reset_password_sent_at" datetime(6), "remember_created_at" datetime(6), "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE sqlite_sequence(name,seq);
CREATE UNIQUE INDEX "index_users_on_email" ON "users" ("email");
CREATE UNIQUE INDEX "index_users_on_reset_password_token" ON "users" ("reset_password_token");
CREATE TABLE IF NOT EXISTS "oauth_access_grants" ("id" integer NOT NULL PRIMARY KEY, "resource_owner_id" integer NOT NULL, "application_id" integer NOT NULL, "token" varchar NOT NULL, "expires_in" integer NOT NULL, "redirect_uri" text NOT NULL, "scopes" varchar DEFAULT '' NOT NULL, "created_at" datetime(6) NOT NULL, "revoked_at" datetime(6) DEFAULT NULL, CONSTRAINT "fk_rails_b4b53e07b8"
FOREIGN KEY ("application_id")
  REFERENCES "oauth_applications" ("id")
);
CREATE INDEX "index_oauth_access_grants_on_resource_owner_id" ON "oauth_access_grants" ("resource_owner_id");
CREATE INDEX "index_oauth_access_grants_on_application_id" ON "oauth_access_grants" ("application_id");
CREATE UNIQUE INDEX "index_oauth_access_grants_on_token" ON "oauth_access_grants" ("token");
CREATE TABLE IF NOT EXISTS "oauth_access_tokens" ("id" integer NOT NULL PRIMARY KEY, "resource_owner_id" integer DEFAULT NULL, "application_id" integer NOT NULL, "token" varchar NOT NULL, "refresh_token" varchar DEFAULT NULL, "expires_in" integer DEFAULT NULL, "scopes" varchar DEFAULT NULL, "created_at" datetime(6) NOT NULL, "revoked_at" datetime(6) DEFAULT NULL, "previous_refresh_token" varchar DEFAULT '' NOT NULL, CONSTRAINT "fk_rails_732cb83ab7"
FOREIGN KEY ("application_id")
  REFERENCES "oauth_applications" ("id")
);
CREATE INDEX "index_oauth_access_tokens_on_resource_owner_id" ON "oauth_access_tokens" ("resource_owner_id");
CREATE INDEX "index_oauth_access_tokens_on_application_id" ON "oauth_access_tokens" ("application_id");
CREATE UNIQUE INDEX "index_oauth_access_tokens_on_token" ON "oauth_access_tokens" ("token");
CREATE UNIQUE INDEX "index_oauth_access_tokens_on_refresh_token" ON "oauth_access_tokens" ("refresh_token");
CREATE TABLE IF NOT EXISTS "oauth_applications" ("id" integer NOT NULL PRIMARY KEY, "name" varchar NOT NULL, "uid" varchar NOT NULL, "secret" varchar NOT NULL, "redirect_uri" text NOT NULL, "scopes" varchar DEFAULT '' NOT NULL, "confidential" boolean DEFAULT 1 NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "owner_id" integer DEFAULT NULL, "owner_type" varchar, CONSTRAINT "fk_rails_cc886e315a"
FOREIGN KEY ("owner_id")
  REFERENCES "users" ("id")
);
CREATE UNIQUE INDEX "index_oauth_applications_on_uid" ON "oauth_applications" ("uid");
CREATE INDEX "index_oauth_applications_on_owner_id" ON "oauth_applications" ("owner_id");
CREATE TABLE IF NOT EXISTS "teams" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "handle" varchar, "name" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "team_members" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "status" varchar, "team_id" integer NOT NULL, "user_id" integer NOT NULL, "external_ids" json, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_194b5b076d"
FOREIGN KEY ("team_id")
  REFERENCES "teams" ("id")
, CONSTRAINT "fk_rails_9ec2d5e75e"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_team_members_on_team_id" ON "team_members" ("team_id");
CREATE INDEX "index_team_members_on_user_id" ON "team_members" ("user_id");
CREATE TABLE IF NOT EXISTS "approvals" ("id" integer NOT NULL PRIMARY KEY, "value" integer DEFAULT NULL, "note" text DEFAULT NULL, "option_id" integer NOT NULL, "decision_id" integer NOT NULL, "created_by_id" integer NOT NULL, "team_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_d0108bdf1a"
FOREIGN KEY ("team_id")
  REFERENCES "teams" ("id")
, CONSTRAINT "fk_rails_387fb9c532"
FOREIGN KEY ("decision_id")
  REFERENCES "decisions" ("id")
, CONSTRAINT "fk_rails_23f31e4409"
FOREIGN KEY ("option_id")
  REFERENCES "options" ("id")
);
CREATE INDEX "index_approvals_on_option_id" ON "approvals" ("option_id");
CREATE INDEX "index_approvals_on_decision_id" ON "approvals" ("decision_id");
CREATE INDEX "index_approvals_on_created_by_id" ON "approvals" ("created_by_id");
CREATE INDEX "index_approvals_on_team_id" ON "approvals" ("team_id");
CREATE TABLE IF NOT EXISTS "options" ("id" integer NOT NULL PRIMARY KEY, "title" text DEFAULT NULL, "description" text DEFAULT NULL, "created_by_id" integer NOT NULL, "decision_id" integer NOT NULL, "team_id" integer NOT NULL, "external_ids" json DEFAULT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_9c86b231af"
FOREIGN KEY ("team_id")
  REFERENCES "teams" ("id")
, CONSTRAINT "fk_rails_df3bc80da2"
FOREIGN KEY ("decision_id")
  REFERENCES "decisions" ("id")
);
CREATE INDEX "index_options_on_created_by_id" ON "options" ("created_by_id");
CREATE INDEX "index_options_on_decision_id" ON "options" ("decision_id");
CREATE INDEX "index_options_on_team_id" ON "options" ("team_id");
CREATE TABLE IF NOT EXISTS "decisions" ("id" integer NOT NULL PRIMARY KEY, "context" text DEFAULT NULL, "question" text DEFAULT NULL, "status" varchar DEFAULT NULL, "deadline" datetime(6) DEFAULT NULL, "created_by_id" integer NOT NULL, "team_id" integer NOT NULL, "external_ids" json DEFAULT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "title" varchar DEFAULT NULL, CONSTRAINT "fk_rails_453a12fd18"
FOREIGN KEY ("team_id")
  REFERENCES "teams" ("id")
);
CREATE INDEX "index_decisions_on_created_by_id" ON "decisions" ("created_by_id");
CREATE INDEX "index_decisions_on_team_id" ON "decisions" ("team_id");
CREATE TABLE IF NOT EXISTS "webhooks" ("id" integer NOT NULL PRIMARY KEY, "url" varchar DEFAULT NULL, "secret" varchar DEFAULT NULL, "event" varchar DEFAULT NULL, "team_id" integer NOT NULL, "decision_id" integer DEFAULT NULL, "created_by_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_c37817a11f"
FOREIGN KEY ("team_id")
  REFERENCES "teams" ("id")
, CONSTRAINT "fk_rails_bb12e00e3c"
FOREIGN KEY ("decision_id")
  REFERENCES "decisions" ("id")
, CONSTRAINT "fk_rails_e567730fa3"
FOREIGN KEY ("created_by_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_webhooks_on_team_id" ON "webhooks" ("team_id");
CREATE INDEX "index_webhooks_on_decision_id" ON "webhooks" ("decision_id");
CREATE INDEX "index_webhooks_on_created_by_id" ON "webhooks" ("created_by_id");
CREATE INDEX "index_oauth_applications_on_owner_id_and_owner_type" ON "oauth_applications" ("owner_id", "owner_type");
CREATE VIEW decision_results AS
        SELECT
          o.decision_id,
          o.id AS option_id,
          o.title AS option_title,
          SUM(a.value) AS approved_yes,
          COUNT(a.value) - SUM(a.value) AS approved_no,
          COUNT(a.value) AS approval_count
        FROM options o
        LEFT JOIN approvals a ON a.option_id = o.id
        GROUP BY o.decision_id, o.id
        ORDER BY approved_yes DESC
/* decision_results(decision_id,option_id,option_title,approved_yes,approved_no,approval_count) */;
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
('20230326165801'),
('20230328030056'),
('20230329005723'),
('20230402225200'),
('20230405011057'),
('20230406011007'),
('20230408031436');


