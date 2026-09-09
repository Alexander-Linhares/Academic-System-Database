-- Verifica se os elementos de um array são distintos entre si
-- A função retorna verdadeiro caso a cardinalidade do array original base com a sua seleção distinta.

CREATE OR REPLACE FUNCTION is_distinct (IN arr anyarray) RETURNS boolean
AS $$
    BEGIN
        RETURN cardinality(arr) = cardinality(
            ARRAY(SELECT DISTINCT * FROM unnest(arr)));
    END
$$ LANGUAGE plpgsql IMMUTABLE;