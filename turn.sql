CREATE OR REPLACE FUNCTION gomoql.turn(av_col character varying, an_row integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
declare    
    vv_player_char char(1);
    vv_sql varchar(150);
    vn_cnt integer;
    vn_gameid integer;
    vb_game_ended_chk boolean;
begin
        
    select player_char,
           action = 'game_ended' into vv_player_char, vb_game_ended_chk
    from gomoql.current_params;
        select last_value  into vn_gameid      from gomoql.seq_game_id;   

    if coalesce(vb_game_ended_chk,false) is true then
      return 'The previous game has ended, start a new one ;)'; 
    end if;    
    
    alter table gomoql.gameboard_base disable rule gomoql_prevent_update;

    vv_sql := 'update gomoql.gameboard_base set '||av_col||' = '''||vv_player_char||''' where rnum = '||an_row||' and length('||av_col||')= 0'; 
    execute vv_sql;
    get diagnostics vn_cnt = row_count;

    alter table gomoql.gameboard_base enable rule gomoql_prevent_update;
    
    if vn_cnt = 1 then 
        insert into gomoql.game_log(game_id,event,player,params) values(vn_gameid,'TURN',vv_player_char,ARRAY['TURN', vv_player_char, av_col, an_row::varchar]);
        perform gomoql.game_analyzer();
        return 'OK';
    else
        return 'False move';
    end if;
      
end; $function$
;
