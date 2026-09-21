-- Verifica se os elementos de um array são distintos entre si
-- A função retorna verdadeiro caso a cardinalidade do array original base com a sua seleção distinta.

CREATE OR REPLACE FUNCTION is_distinct (IN arr anyarray) RETURNS boolean
AS $$
    BEGIN
        RETURN cardinality(arr) = cardinality(
            ARRAY(SELECT DISTINCT * FROM unnest(arr)));
    END
$$ LANGUAGE plpgsql IMMUTABLE;

-- Função para converter os dias da semana em inteiros
CREATE OR REPLACE FUNCTION ACADEMIC.days_to_intarray(days e_day_of_week[])
RETURNS integer[]
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE AS $$
BEGIN
    SELECT ARRAY(
        SELECT array_position(
            ARRAY['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']::text[],
            day
        )
        FROM unnest(days) AS day
    )::integer[];
END;
$$;

-- Função para converter os turnos em inteiros (Ajuste os textos conforme os seus valores reais de d_shifts)
CREATE OR REPLACE FUNCTION ACADEMIC.shifts_to_intarray(shifts e_shift[])
RETURNS integer[]
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE AS $$
BEGIN
    SELECT ARRAY(
        SELECT array_position(
            ARRAY['Morning', 'Afternoon', 'Evening']::text[],
            shift
        )
        FROM unnest(shifts) AS shift
    )::integer[];
END;
$$;