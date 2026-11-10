SELECT
    schema_name,
    schema_owner
FROM information_schema.schemata
    WHERE schema_name <> 'information_schema';



