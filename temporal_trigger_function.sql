/*

pg_historical_tables

main table	-> historical table
insert		-> insert range(now, infinity)
update  	-> update range(..., now) where range infinity, insert range(now, infinity)
delete		-> update range(..., now) where range infinity

*/

--SET client_min_messages TO 'debug';

CREATE OR REPLACE FUNCTION public.temporal_trigger_func ()
RETURNS TRIGGER AS $body$
DECLARE
	pk_column text;
	history_table text;
	manipulate jsonb;
	common_columns text[];
	transaction_info txid_snapshot;
	time_stamp_to_use timestamptz := current_timestamp;
	existing_range tstzrange;
BEGIN

	history_table := TG_ARGV[0];
  	pk_column := TG_ARGV[1];  
	-- RAISE INFO 'history_table: %', history_table;
	-- RAISE INFO 'pk_column:     %', pk_column;

	IF TG_WHEN != 'BEFORE' OR TG_LEVEL != 'ROW' THEN
		RAISE TRIGGER_PROTOCOL_VIOLATED USING
		MESSAGE = 'function "temporal_trigger_func" must be fired BEFORE ROW';
	END IF;

	IF TG_OP != 'INSERT' AND TG_OP != 'UPDATE' AND TG_OP != 'DELETE' THEN
		RAISE TRIGGER_PROTOCOL_VIOLATED USING
		MESSAGE = 'function "temporal_trigger_func" must be fired for INSERT or UPDATE or DELETE';
	END IF;
	
	WITH history AS (
		SELECT attname
		FROM   pg_attribute
		WHERE  attrelid = history_table::regclass
		AND    attnum > 0
		AND    NOT attisdropped
	),
	main AS (
		SELECT attname
		FROM   pg_attribute
		WHERE  attrelid = TG_RELID
		AND    attnum > 0
		AND    NOT attisdropped
	)
	SELECT array_agg(quote_ident(history.attname)) INTO common_columns
	FROM history
	INNER JOIN main ON history.attname = main.attname;
	
	IF TG_OP = 'INSERT' THEN

		EXECUTE ('INSERT INTO ' ||
		  CASE split_part(history_table, '.', 2)
		  WHEN '' THEN
			quote_ident(history_table)
		  ELSE
			quote_ident(split_part(history_table, '.', 1)) || '.' || quote_ident(split_part(history_table, '.', 2))
		  END ||
		  '(' ||
		  array_to_string(common_columns , ',') ||
		  ', temporal_period' || 
		  ', temporal_start_at' || 
		  ', temporal_end_at' ||
		  ') VALUES ($1.' ||
		  array_to_string(common_columns, ',$1.') ||
		  ',tstzrange($2, NULL, ''[)''), $2, ''infinity'')'
		  ) USING NEW, time_stamp_to_use;
	
	END IF;
	
	IF TG_OP = 'UPDATE' OR TG_OP = 'DELETE' THEN
		-- Ignore rows already modified in this transaction
		transaction_info := txid_current_snapshot();
		IF OLD.xmin::text >= (txid_snapshot_xmin(transaction_info) % (2^32)::bigint)::text
			AND OLD.xmin::text <= (txid_snapshot_xmax(transaction_info) % (2^32)::bigint)::text THEN
			IF TG_OP = 'DELETE' THEN
				RETURN OLD;
			END IF;

			RETURN NEW;
		END IF;
		
		EXECUTE	(
			'UPDATE ' || 
			CASE split_part(history_table, '.', 2)
			WHEN '' THEN quote_ident(history_table)
			ELSE quote_ident(split_part(history_table, '.', 1)) || '.' || quote_ident(split_part(history_table, '.', 2))
			END || 
			' SET ' || 
			' temporal_period = tstzrange(lower(temporal_period), ''' || time_stamp_to_use || ''', ''[)''), ' || 
			' temporal_end_at = ''' || time_stamp_to_use || ''' ' ||
			' WHERE ' || pk_column || ' = $1.' || quote_ident(pk_column) || 
			' AND upper_inf(temporal_period) RETURNING temporal_period')
			USING OLD INTO existing_range;
			
			-- RAISE INFO 'existing_range: %', existing_range;
			IF upper(existing_range) IS NULL THEN
				-- No existing historical record found; so historical tables was installed
				-- at a later point in time. Start historical record from current timestamp
				existing_range := tstzrange(NULL, time_stamp_to_use, '[)');
			END IF;
		
	END IF;

	IF TG_OP = 'UPDATE' THEN
		EXECUTE ('INSERT INTO ' ||
		  CASE split_part(history_table, '.', 2)
		  WHEN '' THEN
			quote_ident(history_table)
		  ELSE
			quote_ident(split_part(history_table, '.', 1)) || '.' || quote_ident(split_part(history_table, '.', 2))
		  END ||
		  '(' ||
		  array_to_string(common_columns , ',') ||
		  ', temporal_period' || 
		  ', temporal_start_at' || 
		  ', temporal_end_at' ||
		  ') VALUES ($1.' ||
		  array_to_string(common_columns, ',$1.') ||
		  ',tstzrange(upper($2), NULL, ''[)''), upper($2), ''infinity'')')
		   USING NEW, existing_range;
		
    END IF;

	IF TG_OP = 'UPDATE' OR TG_OP = 'INSERT' THEN
		manipulate := jsonb_set('{}'::jsonb, ('{' || 'temporal_period' || '}')::text[], to_jsonb(tstzrange(time_stamp_to_use, null, '[)')));
		
		RETURN jsonb_populate_record(NEW, manipulate);
	END IF;

    RETURN OLD;
END;
$body$
LANGUAGE 'plpgsql';
