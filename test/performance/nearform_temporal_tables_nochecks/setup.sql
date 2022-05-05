\timing off
\set ON_ERROR_STOP on

\include /pg/test/performance/nearform_temporal_tables_nochecks/versioning_function_nochecks.sql

CREATE TABLE subscriptions
(
  id SERIAL PRIMARY KEY,
  name text NOT NULL,
  state text NOT NULL,
  sys_period tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null)
);

CREATE TABLE subscriptions_history (
  id INTEGER,
  name text NOT NULL,
  state text NOT NULL,
  sys_period tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null)
);

CREATE TRIGGER versioning_trigger
BEFORE INSERT OR UPDATE OR DELETE ON subscriptions
FOR EACH ROW EXECUTE PROCEDURE versioning(
  'sys_period', 'subscriptions_history', true
);
