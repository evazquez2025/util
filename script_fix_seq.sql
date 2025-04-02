DO $$ 
DECLARE
    seq_name text := 'namescreening_audits_id_seq'; -- Secuencia
    table_name text := 'namescreening_audits'; -- Tabla
    column_name text := 'id'; -- Columna
    schema_name text := 'compass'; -- Esquema
	max_value bigint; -- Valor máximo de la columna
BEGIN

	EXECUTE format('SELECT COALESCE(MAX(%I), 0) FROM %I.%I', column_name, schema_name, table_name)
    INTO max_value;
    -- Verificar si la secuencia existe
    IF NOT EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE relname = seq_name AND n.nspname = schema_name) THEN
        -- Crear la secuencia en el esquema correcto con el valor máximo de la columna
		EXECUTE format('CREATE SEQUENCE %I.%I START %s', schema_name, seq_name, max_value + 1);
    END IF;
    
    -- Asociar la secuencia a la columna correspondiente en la tabla
    EXECUTE format('ALTER SEQUENCE %I.%I OWNED BY %I.%I.%I', schema_name, seq_name, schema_name, table_name, column_name);
    
    -- Ajustar el valor de la secuencia al máximo valor actual de la columna
    EXECUTE format('SELECT setval(%L, COALESCE((SELECT MAX(%I) FROM %I.%I), 1), false)',
                   seq_name, column_name, schema_name, table_name);
END $$;
