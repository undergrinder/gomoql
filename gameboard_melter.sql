CREATE OR REPLACE FUNCTION gomoql.gameboard_melter()
 RETURNS TABLE(cnum integer, rnum integer, value character varying)
 LANGUAGE plpgsql
AS $function$
    DECLARE
        vv_dynamic_sql varchar;
        va_columns_arr varchar[];
        vv_columns     varchar;
        vn_iter        integer;
    BEGIN
        va_columns_arr := array(select cast(isc.column_name as varchar) from information_schema.columns isc where isc.table_name = 'gameboard_base' and table_schema = 'gomoql' and isc.column_name != 'rnum' order by isc.ordinal_position);
        
        FOR vn_iter IN 1..array_upper(va_columns_arr,1)
        LOOP
            IF vn_iter = 1 THEN
                vv_columns := va_columns_arr[vn_iter];
            ELSE
                vv_columns := vv_columns||','||va_columns_arr[vn_iter];
            END IF;
        END LOOP;
    
        vv_dynamic_sql := 'SELECT unnest(array(select ordinal_position-1 as cnum from information_schema.columns where table_name = ''gameboard_base'' and table_schema=''gomoql'' and column_name !=''rnum'' order by ordinal_position)) AS column_name,';    
        vv_dynamic_sql := vv_dynamic_sql || 'rnum,';            
        vv_dynamic_sql := vv_dynamic_sql || 'unnest(array['||vv_columns||']) AS value ';
        vv_dynamic_sql := vv_dynamic_sql || 'FROM gomoql.gameboard_base';
    
        RETURN QUERY EXECUTE vv_dynamic_sql;    
    END;
$function$
;
