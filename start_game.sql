CREATE OR REPLACE FUNCTION gomoql.start_game(an_size integer, av_o_or_x character varying)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
declare    
    crt_game text := '';
    chk_prev_game bool;
begin
    --initial checks
    if an_size > 702 then 
        return 'The gameboard maximum size is 702 tile';
    elseif an_size < 15 then
        return 'The gameboard minimum size is 15 tile';
    end if;

    if lower(av_o_or_x) not in ('x','o') then
        return 'The second parameter must be X or O FIXME: ADD HELP';
    end if;

    --Is there any unfinished game
    select case when count(*) = 0 or coalesce(max(action),'') = 'game_ended' then false 
                when coalesce(max(action),'') != 'game_can_be_deleted'       then true 
            end into chk_prev_game
    from gomoql.current_params;

    if chk_prev_game then 
        update  gomoql.current_params set action = 'game_can_be_deleted';
        return 'There is an unfinished game. To override start the game again';
    else
        delete from gomoql.current_params;    
    end if;
   
   raise notice '                                        '; 
   raise notice '                                  (     ';
   raise notice ' (                           (    )\ )  ';
   raise notice ' )\ )            )         ( )\  (()/(  ';
   raise notice '(()/(     (     (      (   )((_)  /(_)) ';
   raise notice ' /(_))_   )\    )\  ''  )\ ((_)_  (_))   ';
   raise notice '(_)) __| ((_) _((_))  ((_) / _ \ | |    ';
   raise notice '  | (_ |/ _ \| ''  \()/ _ \| (_) || |__  ';
   raise notice '   \___|\___/|_|_|_| \___/ \__\_\|____| ';
   raise notice '========================================';
   raise notice '      UNDERGRINDER - v0.1 HURKA release '; 
   raise notice '                                        ';
   raise notice '                                        ';
   
   
    --create base table max 26*26+26 = 702 field
    with 
        cols_base as (
            select nr-96 as nr,chr(nr) as col
            from generate_series(97,122) a (nr)
            ),
        cols_cartesian as (
            select row_number() over (order by a.col, b.col) + 26 as nr, 
                   a.col||b.col as col
            from      cols_base a
            left join cols_base b on 1=1 
        ),
        cols_final as (
            select nr, col from cols_base
            union 
            select nr, col from cols_cartesian
			order by nr
            limit an_size
        )
    select 'drop table if exists gomoql.gameboard_base cascade; create table gomoql.gameboard_base (rnum integer,'|| string_agg(quote_ident(col) || ' varchar(3) default ''''',',')||');' into crt_game
    from cols_final;
    
    execute crt_game;
    
    insert into gomoql.gameboard_base(rnum) select generate_series(1,an_size);  
   
    --create view without the rnum field
    with 
        cols_base as (
            select nr-96 as nr,chr(nr) as col
            from generate_series(97,122) a (nr)
            ),
        cols_cartesian as (
            select row_number() over (order by a.col, b.col) + 26 as nr, 
                   a.col||b.col as col
            from      cols_base a
            left join cols_base b on 1=1 
        ),
        cols_final as (
            select nr, col from cols_base
            union 
            select nr, col from cols_cartesian
			order by nr
            limit an_size
        )
    select 'create or replace view gomoql.gameboard as select '|| string_agg(quote_ident(col),',')||' from gomoql.gameboard_base order by rnum' into crt_game
    from cols_final;
    
    execute crt_game;
    
    crt_game = 'CREATE or replace RULE gomoql_prevent_delete AS ON DELETE TO gomoql.gameboard_base DO INSTEAD NOTHING;'  ||
               'CREATE or replace RULE gomoql_prevent_update AS ON UPDATE TO gomoql.gameboard_base DO INSTEAD NOTHING;'  ||
               'CREATE or replace RULE gomoql_prevent_insert AS ON INSERT TO gomoql.gameboard_base DO INSTEAD NOTHING;';  
    
    execute crt_game;    

    insert into gomoql.current_params(game_id,player_char,action) values(nextval('gomoql.seq_game_id'),upper(av_o_or_x),null);
    insert into gomoql.game_log(game_id,event,player,params) values(currval('gomoql.seq_game_id'),'START',upper(av_o_or_x),ARRAY['START', an_size::varchar]);    
    
    return 'The game has started';
end;
$function$
;
