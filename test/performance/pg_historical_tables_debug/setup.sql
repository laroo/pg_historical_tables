\timing off
\set ON_ERROR_STOP on

\include /pg/temporal_trigger_function_debug.sql

CREATE TABLE public.subscriptions
(
  id SERIAL PRIMARY KEY,
  name text NOT NULL,
  state text NOT NULL
);

CREATE TABLE public.subscriptions_history (
  id INTEGER,
  name text,
  state text,
  temporal_period tstzrange NOT NULL,
  temporal_start_at TIMESTAMPTZ NOT NULL,
  temporal_end_at TIMESTAMPTZ NOT NULL
);

CREATE TRIGGER subscriptions_temporal_trigger_row
BEFORE INSERT OR UPDATE OR DELETE ON public.subscriptions
FOR EACH ROW EXECUTE PROCEDURE public.temporal_trigger_func('public.subscriptions_history', 'id');
