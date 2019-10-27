--SET client_min_messages TO 'debug';

BEGIN;

DROP TRIGGER IF EXISTS mytable_temporal_trigger_row ON public.mytable;
DROP TABLE IF EXISTS public.mytable;
DROP TABLE IF EXISTS public.mytable_historical;
-- DROP FUNCTION IF EXISTS public.temporal_trigger_func();

CREATE TABLE public.mytable (
    id           SERIAL PRIMARY KEY,
    admin_name   VARCHAR(200) NOT NULL,
    comment      TEXT,
    price        NUMERIC(12,2),
    is_enabled   BOOLEAN DEFAULT TRUE NOT NULL,
    CONSTRAINT admin_name_unique UNIQUE(admin_name)
);

CREATE TABLE public.mytable_historical (
    id           INTEGER,
    admin_name   VARCHAR(200),
    comment      TEXT,
    price        NUMERIC(12,2),
    is_enabled   BOOLEAN,
    temporal_period tstzrange NOT NULL,
    temporal_start_at TIMESTAMPTZ NOT NULL,
    temporal_end_at TIMESTAMPTZ NOT NULL
);

CREATE TRIGGER mytable_temporal_trigger_row 
-- AFTER INSERT OR UPDATE ON public.mytable FOR EACH ROW EXECUTE PROCEDURE public.temporal_trigger_func();
BEFORE INSERT OR UPDATE OR DELETE ON public.mytable
FOR EACH ROW EXECUTE PROCEDURE public.temporal_trigger_func('public.mytable_historical', 'id');

COMMIT;

INSERT INTO public.mytable(admin_name, comment, price, is_enabled) VALUES ('product1', 'new product 1: 9.95', 9.95, TRUE);
SELECT * FROM public.mytable;
SELECT * FROM public.mytable_historical;

UPDATE public.mytable SET comment='update product1 to 10.50', price=10.50 WHERE admin_name = 'product1';
SELECT * FROM public.mytable;
SELECT * FROM public.mytable_historical;

INSERT INTO public.mytable(admin_name, comment, price, is_enabled) VALUES ('product2', 'new product 2: 99.99', 99.99, TRUE);
SELECT * FROM public.mytable;
SELECT * FROM public.mytable_historical;

UPDATE public.mytable SET comment='update product1 to 11.95 and disabled', price=11.95, is_enabled=FALSE WHERE admin_name = 'product1';
SELECT * FROM public.mytable;
SELECT * FROM public.mytable_historical;

UPDATE public.mytable SET comment = 'update product2 to 100.00', price=100.00 WHERE admin_name = 'product2';
SELECT * FROM public.mytable;
SELECT * FROM public.mytable_historical;

DELETE FROM public.mytable WHERE admin_name = 'product1';
SELECT * FROM public.mytable;
SELECT * FROM public.mytable_historical;

/*
-- Column migrations needs to be applied on both tables
ALTER TABLE public.mytable DROP COLUMN is_enabled;
ALTER TABLE public.mytable_historical DROP COLUMN is_enabled;

SELECT * FROM public.mytable_historical WHERE temporal_period @> '2019-03-29 23:24:34.69681'::timestamp;
*/