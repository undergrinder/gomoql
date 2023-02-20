CREATE OR REPLACE FUNCTION gomoql.turn_comp(av_col character varying, an_row integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare    
    vv_comp_char char(1);
    vv_sql varchar(150);
    vn_cnt integer;
    vn_gameid integer;
    vb_game_ended_chk boolean;
begin
    select case when player_char='O' then 'X' else 'O' end,
           action = 'game_ended' into vv_comp_char, 
                                      vb_game_ended_chk
    from gomoql.current_params;
    select last_value  into vn_gameid      from gomoql.seq_game_id;

    if coalesce(vb_game_ended_chk,false) is false then    
           
      alter table gomoql.gameboard_base disable rule gomoql_prevent_update;

      vv_sql := 'update gomoql.gameboard_base set '||av_col||' = '''||vv_comp_char||''' where rnum = '||an_row||' and length('||av_col||')= 0'; 
      execute vv_sql;
      get diagnostics vn_cnt = row_count;

      alter table gomoql.gameboard_base enable rule gomoql_prevent_update;
    
      if vn_cnt = 1 then           
          insert into gomoql.game_log(game_id,event,player,params) values(vn_gameid,'TURN',vv_comp_char,ARRAY['TURN', vv_comp_char, av_col, an_row::varchar]);
          raise notice 'computer move : %.%', av_col, an_row;
          perform gomoql.game_analyzer_kuka();
          perform gomoql.check_winner();
                
    end if;
  end if;
end; $function$
;
