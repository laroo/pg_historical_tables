SET client_min_messages TO 'error';

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
BEFORE INSERT OR UPDATE OR DELETE ON public.mytable
FOR EACH ROW EXECUTE PROCEDURE public.temporal_trigger_func('public.mytable_historical', 'id');

INSERT INTO public.mytable(admin_name, comment, price, is_enabled) VALUES ('product1', 'new product 1: 9.95', 9.95, TRUE);
SELECT id, admin_name, comment, price, is_enabled FROM public.mytable ORDER BY id;
SELECT id, admin_name, comment, price, is_enabled FROM public.mytable_historical ORDER BY id, temporal_period;

UPDATE public.mytable SET comment='update product1 to 10.50', price=10.50 WHERE admin_name = 'product1';
SELECT id, admin_name, comment, price, is_enabled FROM public.mytable ORDER BY id;
SELECT id, admin_name, comment, price, is_enabled FROM public.mytable_historical ORDER BY id, temporal_period;

INSERT INTO public.mytable(admin_name, comment, price, is_enabled) VALUES ('product2', 'new product 2: 99.99', 99.99, TRUE);
SELECT id, admin_name, comment, price, is_enabled FROM public.mytable ORDER BY id;
SELECT id, admin_name, comment, price, is_enabled FROM public.mytable_historical ORDER BY id, temporal_period;

UPDATE public.mytable SET comment='update product1 to 11.95 and disabled', price=11.95, is_enabled=FALSE WHERE admin_name = 'product1';
SELECT id, admin_name, comment, price, is_enabled FROM public.mytable ORDER BY id;
SELECT id, admin_name, comment, price, is_enabled FROM public.mytable_historical ORDER BY id, temporal_period;

UPDATE public.mytable SET comment = 'update product2 to 100.00', price=100.00 WHERE admin_name = 'product2';
SELECT id, admin_name, comment, price, is_enabled FROM public.mytable ORDER BY id;
SELECT id, admin_name, comment, price, is_enabled FROM public.mytable_historical ORDER BY id, temporal_period;

DELETE FROM public.mytable WHERE admin_name = 'product1';
SELECT id, admin_name, comment, price, is_enabled FROM public.mytable ORDER BY id;
SELECT id, admin_name, comment, price, is_enabled FROM public.mytable_historical ORDER BY id, temporal_period;
