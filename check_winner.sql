CREATE OR REPLACE FUNCTION gomoql.check_winner()
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
declare
vv_player_char char(1);
vv_chk_winner  varchar(20);
vn_gameid      numeric;
begin
    
    select player_char into vv_player_char from gomoql.current_params;
    select last_value  into vn_gameid      from gomoql.seq_game_id;

   select case when greatest(rowcheck_lr, rowcheck_rl, colcheck_ud, colcheck_du, diagon_udlr, diagon_udrl, diagon_dulr, diagon_durl) = 5 then 'player_won'
               when greatest(rowcheck_lr_c,rowcheck_rl_c,colcheck_ud_c,colcheck_du_c,diagon_udlr_c,diagon_udrl_c,diagon_dulr_c,diagon_durl_c) = 5 then 'computer_won'
               else null
          end into vv_chk_winner     
   from gomoql.game_analyzer_store
   where value in ('X','O')
     and (rowcheck_lr   = 5
      or rowcheck_rl   = 5
      or colcheck_ud   = 5
      or colcheck_du   = 5
      or diagon_udlr   = 5
      or diagon_udrl   = 5
      or diagon_dulr   = 5
      or diagon_durl   = 5
      or rowcheck_lr_c = 5
      or rowcheck_rl_c = 5
      or colcheck_ud_c = 5
      or colcheck_du_c = 5
      or diagon_udlr_c = 5
      or diagon_udrl_c = 5
      or diagon_dulr_c = 5
      or diagon_durl_c = 5) limit 1;

  if vv_chk_winner is not null then    
     raise notice ' ';
     raise notice '%', vv_chk_winner;
     raise notice '%', case when vv_chk_winner='computer_won' then '(O.O)' else '(-.-)' end;

     raise notice '                                         ';
     raise notice '-----------------------------------------';
     raise notice '       !!!Thank you for playing!!!';
     raise notice '-----------------------------------------';

     
     update gomoql.current_params set action = 'game_ended';
     insert into gomoql.game_log(game_id,event,player,params) values(vn_gameid,'END',upper(vv_player_char),ARRAY['END', vv_chk_winner]);
 
 
    return true;
  else
     return false;
  end if;
    
end; $function$
;
