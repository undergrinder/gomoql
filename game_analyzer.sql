CREATE OR REPLACE FUNCTION gomoql.game_analyzer()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare

vv_player_char char(1);
vv_comp_char   char(1);
c_colcheck_ud cursor for select cnum, rnum, value, maxpos from gomoql.game_analyzer_store order by cnum, rnum asc;
c_colcheck_du cursor for select cnum, rnum, value, maxpos from gomoql.game_analyzer_store order by cnum, rnum desc;
c_rowcheck_lr cursor for select cnum, rnum, value, maxpos from gomoql.game_analyzer_store order by rnum, cnum asc;
c_rowcheck_rl cursor for select cnum, rnum, value, maxpos from gomoql.game_analyzer_store order by rnum, cnum desc;
c_dcheck_durl cursor for select cnum, rnum, value, maxpos from gomoql.game_analyzer_store order by cnum desc, rnum desc;
vn_prev numeric;
vn_act  numeric;
vn_dval char(1);
vb_chk_winner boolean;
vn_row integer;
vn_col numeric;
vv_col varchar(10);
tmp_debug numeric;

begin

    select player_char, 
           case when player_char='O' then 'X' else 'O' end into vv_player_char, vv_comp_char
    from gomoql.current_params;

    drop table if exists gomoql.game_analyzer_store;
    create table gomoql.game_analyzer_store as (select cnum,     
                                                       rnum,                        
                                                       value,
                                                       max(rnum) over (partition by cnum order by cnum) as maxpos,
                                                       0::numeric as rowcheck_lr,
                                                       0::numeric as rowcheck_rl,
                                                       0::numeric as colcheck_ud,
                                                       0::numeric as colcheck_du,
                                                       0::numeric as diagon_udlr,
                                                       0::numeric as diagon_udrl,
                                                       0::numeric as diagon_dulr,
                                                       0::numeric as diagon_durl,
                                                       0::numeric as rowcheck_lr_c,
                                                       0::numeric as rowcheck_rl_c,
                                                       0::numeric as colcheck_ud_c,
                                                       0::numeric as colcheck_du_c,
                                                       0::numeric as diagon_udlr_c,
                                                       0::numeric as diagon_udrl_c,
                                                       0::numeric as diagon_dulr_c,
                                                       0::numeric as diagon_durl_c                                                        
                                                from gomoql.gameboard_melter());
                                      
   --shit begins, use func later
    vn_prev := null;
    vn_act  := null;

    for rec in c_colcheck_ud
    loop
    
       if rec.value = vv_player_char then
          if vn_prev is null then
            vn_act := 1;
          else 
            vn_act := vn_prev + 1;
          end if;
         
          update gomoql.game_analyzer_store set colcheck_ud = vn_act where cnum = rec.cnum and rnum = rec.rnum;
          vn_prev := vn_act; 
      elsif vn_prev is not null and rec.value is not distinct from '' and rec.rnum != 1  then
          vn_act := vn_prev + 1;
          update gomoql.game_analyzer_store set colcheck_ud = vn_act where cnum = rec.cnum and rnum = rec.rnum;
          vn_prev := null; 
      else
              
          vn_prev := null;
          vn_act  := null;
       
       end if;

    end loop;

    vn_prev := null;
    vn_act  := null;
    for rec in c_colcheck_du 
    loop

       if rec.value = vv_player_char then
          if vn_prev is null then
            vn_act := 1;
          else 
            vn_act := vn_prev + 1;
          end if;
         
          update gomoql.game_analyzer_store set colcheck_du = vn_act where cnum = rec.cnum and rnum = rec.rnum;
          vn_prev := vn_act; 
      elsif vn_prev is not null and rec.value is not distinct from '' and rec.rnum != rec.maxpos then
          vn_act := vn_prev + 1;
          update gomoql.game_analyzer_store set colcheck_du = vn_act where cnum = rec.cnum and rnum = rec.rnum;
          vn_prev := null; 
      else
              
          vn_prev := null;
          vn_act  := null;
       
       end if;
    end loop;

    vn_prev := null;
    vn_act  := null;
    for rec in c_rowcheck_lr
    loop
    
       if rec.value = vv_player_char then
          if vn_prev is null then
            vn_act := 1;
          else 
            vn_act := vn_prev + 1;
          end if;
         
          update gomoql.game_analyzer_store set rowcheck_lr = vn_act where cnum = rec.cnum and rnum = rec.rnum;
          vn_prev := vn_act; 
      elsif vn_prev is not null and rec.value is not distinct from '' and rec.cnum != 1  then
          vn_act := vn_prev + 1;
         -- raise notice 'lefutott act:%, prev:%; cnum: %, rnum: %', vn_act, vn_prev, rec.cnum, rec.rnum;
          update gomoql.game_analyzer_store set rowcheck_lr = vn_act where cnum = rec.cnum and rnum = rec.rnum;
          GET DIAGNOSTICS tmp_debug = ROW_COUNT;
          --raise notice 'updated: %', tmp_debug;
      
          vn_prev := null; 
      else
              
          vn_prev := null;
          vn_act  := null;
       
       end if;

    end loop;


    vn_prev := null;
    vn_act  := null;
    for rec in c_rowcheck_rl
    loop
    
       if rec.value = vv_player_char then
          if vn_prev is null then
            vn_act := 1;
          else 
            vn_act := vn_prev + 1;
          end if;
         
          update gomoql.game_analyzer_store set rowcheck_rl = vn_act where cnum = rec.cnum and rnum = rec.rnum;
          vn_prev := vn_act; 
      elsif vn_prev is not null and rec.value is not distinct from '' and rec.cnum != rec.maxpos  then
          vn_act := vn_prev + 1;
          update gomoql.game_analyzer_store set rowcheck_rl = vn_act where cnum = rec.cnum and rnum = rec.rnum;
          vn_prev := null; 
      else
              
          vn_prev := null;
          vn_act  := null;
       
       end if;

    end loop;

    --diagon checks
    --diagon_udlr
    vn_prev := null;
    vn_act  := null;
    vn_dval := null;
    for rec in c_colcheck_ud
    loop
     select value, diagon_udlr into vn_dval, vn_prev from gomoql.game_analyzer_store where cnum = rec.cnum - 1 and rnum = rec.rnum - 1;

      if vn_dval = '' then
         vn_prev := 0;
     end if;
 
     vn_act := vn_prev + 1;
 
     if rec.value = vv_player_char then
         update gomoql.game_analyzer_store set diagon_udlr = vn_act where cnum = rec.cnum and rnum = rec.rnum;
     elsif vn_dval = vv_player_char and rec.value is not distinct from '' then
         update gomoql.game_analyzer_store set diagon_udlr = vn_act where cnum = rec.cnum and rnum = rec.rnum;     
     end if;
          

    end loop;

    --diagon_dulr
    vn_prev := null;
    vn_act  := null;
    vn_dval := null;
    for rec in c_colcheck_du
    loop
     select value, diagon_dulr into vn_dval, vn_prev from gomoql.game_analyzer_store where cnum = rec.cnum - 1 and rnum = rec.rnum + 1;
    
     if vn_dval = '' then
         vn_prev := 0;
     end if;
     
     vn_act := coalesce(vn_prev,0) + 1;
 
     if rec.value = vv_player_char then
         update gomoql.game_analyzer_store set diagon_dulr = vn_act where cnum = rec.cnum and rnum = rec.rnum;
     elsif vn_dval = vv_player_char and rec.value is not distinct from '' then
         update gomoql.game_analyzer_store set diagon_dulr = vn_act where cnum = rec.cnum and rnum = rec.rnum;     
     end if;
          

    end loop;

    --diagon_udrl
    vn_prev := null;
    vn_act  := null;
    vn_dval := null;
    for rec in c_rowcheck_rl
    loop
     select value, diagon_udrl into vn_dval, vn_prev from gomoql.game_analyzer_store where cnum = rec.cnum + 1 and rnum = rec.rnum - 1;

     if vn_dval = '' then
         vn_prev := 0;
     end if;
 
     vn_act := vn_prev + 1;
 
     if rec.value = vv_player_char then
         update gomoql.game_analyzer_store set diagon_udrl = vn_act where cnum = rec.cnum and rnum = rec.rnum;
     elsif vn_dval = vv_player_char and rec.value is not distinct from '' then
         update gomoql.game_analyzer_store set diagon_udrl = vn_act where cnum = rec.cnum and rnum = rec.rnum;     
     end if;
          

    end loop;

    --diagon_durl
    vn_prev := null;
    vn_act  := null;
    vn_dval := null;
    for rec in c_dcheck_durl
    loop
     select value, diagon_durl into vn_dval, vn_prev from gomoql.game_analyzer_store where cnum = rec.cnum + 1 and rnum = rec.rnum + 1;
     
      if vn_dval = '' then
         vn_prev := 0;
     end if;
 
 
     vn_act := coalesce(vn_prev,0) + 1;
 
     if rec.value = vv_player_char then
         update gomoql.game_analyzer_store set diagon_durl = vn_act where cnum = rec.cnum and rnum = rec.rnum;
     elsif vn_dval = vv_player_char and rec.value is not distinct from '' then
         update gomoql.game_analyzer_store set diagon_durl = vn_act where cnum = rec.cnum and rnum = rec.rnum;     
     end if;
          

    end loop;

--comp columns

   --shit begins, use func later
    vn_prev := null;
    vn_act  := null;

    for rec in c_colcheck_ud
    loop
    
       if rec.value = vv_comp_char then
          if vn_prev is null then
            vn_act := 1;
          else 
            vn_act := vn_prev + 1;
          end if;
         
          update gomoql.game_analyzer_store set colcheck_ud_c = vn_act where cnum = rec.cnum and rnum = rec.rnum;
          vn_prev := vn_act; 
      elsif vn_prev is not null and rec.value is not distinct from '' and rec.rnum != 1  then
          vn_act := vn_prev + 1;
          update gomoql.game_analyzer_store set colcheck_ud_c = vn_act where cnum = rec.cnum and rnum = rec.rnum;
          vn_prev := null; 
      else
              
          vn_prev := null;
          vn_act  := null;
       
       end if;

    end loop;

    vn_prev := null;
    vn_act  := null;
    for rec in c_colcheck_du 
    loop

       if rec.value = vv_comp_char then
          if vn_prev is null then
            vn_act := 1;
          else 
            vn_act := vn_prev + 1;
          end if;
         
          update gomoql.game_analyzer_store set colcheck_du_c = vn_act where cnum = rec.cnum and rnum = rec.rnum;
          vn_prev := vn_act; 
      elsif vn_prev is not null and rec.value is not distinct from '' and rec.rnum != rec.maxpos then
          vn_act := vn_prev + 1;
          update gomoql.game_analyzer_store set colcheck_du_c = vn_act where cnum = rec.cnum and rnum = rec.rnum;
          vn_prev := null; 
      else
              
          vn_prev := null;
          vn_act  := null;
       
       end if;
    end loop;

    vn_prev := null;
    vn_act  := null;
    for rec in c_rowcheck_lr
    loop
    
       if rec.value = vv_comp_char then
          if vn_prev is null then
            vn_act := 1;
          else 
            vn_act := vn_prev + 1;
          end if;
         
          update gomoql.game_analyzer_store set rowcheck_lr_c = vn_act where cnum = rec.cnum and rnum = rec.rnum;
          vn_prev := vn_act; 
      elsif vn_prev is not null and rec.value is not distinct from '' and rec.cnum != 1  then
          vn_act := vn_prev + 1;
          update gomoql.game_analyzer_store set rowcheck_lr_c = vn_act where cnum = rec.cnum and rnum = rec.rnum;
          vn_prev := null; 
      else
              
          vn_prev := null;
          vn_act  := null;
       
       end if;

    end loop;


    vn_prev := null;
    vn_act  := null;
    for rec in c_rowcheck_rl
    loop
    
       if rec.value = vv_comp_char then
          if vn_prev is null then
            vn_act := 1;
          else 
            vn_act := vn_prev + 1;
          end if;
         
          update gomoql.game_analyzer_store set rowcheck_rl_c = vn_act where cnum = rec.cnum and rnum = rec.rnum;
          vn_prev := vn_act; 
      elsif vn_prev is not null and rec.value is not distinct from '' and rec.cnum != rec.maxpos  then
          vn_act := vn_prev + 1;
          update gomoql.game_analyzer_store set rowcheck_rl_c = vn_act where cnum = rec.cnum and rnum = rec.rnum;
          vn_prev := null; 
      else
              
          vn_prev := null;
          vn_act  := null;
       
       end if;

    end loop;

    --diagon checks
    --diagon_udlr_c
    vn_prev := null;
    vn_act  := null;
    vn_dval := null;
    for rec in c_colcheck_ud
    loop
     select value, diagon_udlr_c into vn_dval, vn_prev from gomoql.game_analyzer_store where cnum = rec.cnum - 1 and rnum = rec.rnum - 1;

      if vn_dval = '' then
         vn_prev := 0;
     end if;
 
     vn_act := vn_prev + 1;
 
     if rec.value = vv_comp_char then
         update gomoql.game_analyzer_store set diagon_udlr_c = vn_act where cnum = rec.cnum and rnum = rec.rnum;
     elsif vn_dval = vv_comp_char and rec.value is not distinct from '' then
         update gomoql.game_analyzer_store set diagon_udlr_c = vn_act where cnum = rec.cnum and rnum = rec.rnum;     
     end if;
          

    end loop;

    --diagon_dulr
    vn_prev := null;
    vn_act  := null;
    vn_dval := null;
    for rec in c_colcheck_du
    loop
     select value, diagon_dulr_c into vn_dval, vn_prev from gomoql.game_analyzer_store where cnum = rec.cnum - 1 and rnum = rec.rnum + 1;
    
     if vn_dval = '' then
         vn_prev := 0;
     end if;
     
     vn_act := coalesce(vn_prev,0) + 1;
 
     if rec.value = vv_comp_char then
         update gomoql.game_analyzer_store set diagon_dulr_c = vn_act where cnum = rec.cnum and rnum = rec.rnum;
     elsif vn_dval = vv_comp_char and rec.value is not distinct from '' then
         update gomoql.game_analyzer_store set diagon_dulr_c = vn_act where cnum = rec.cnum and rnum = rec.rnum;     
     end if;
          

    end loop;

    --diagon_udrl
    vn_prev := null;
    vn_act  := null;
    vn_dval := null;
    for rec in c_rowcheck_rl
    loop
     select value, diagon_udrl_c into vn_dval, vn_prev from gomoql.game_analyzer_store where cnum = rec.cnum + 1 and rnum = rec.rnum - 1;

     if vn_dval = '' then
         vn_prev := 0;
     end if;
 
     vn_act := vn_prev + 1;
 
     if rec.value = vv_comp_char then
         update gomoql.game_analyzer_store set diagon_udrl_c = vn_act where cnum = rec.cnum and rnum = rec.rnum;
     elsif vn_dval = vv_comp_char and rec.value is not distinct from '' then
         update gomoql.game_analyzer_store set diagon_udrl_c = vn_act where cnum = rec.cnum and rnum = rec.rnum;     
     end if;
          

    end loop;

    --diagon_durl
    vn_prev := null;
    vn_act  := null;
    vn_dval := null;
    for rec in c_dcheck_durl
    loop
     select value, diagon_durl_c into vn_dval, vn_prev from gomoql.game_analyzer_store where cnum = rec.cnum + 1 and rnum = rec.rnum + 1;
     
      if vn_dval = '' then
         vn_prev := 0;
     end if;
 
 
     vn_act := coalesce(vn_prev,0) + 1;
 
     if rec.value = vv_comp_char then
         update gomoql.game_analyzer_store set diagon_durl_c = vn_act where cnum = rec.cnum and rnum = rec.rnum;
     elsif vn_dval = vv_comp_char and rec.value is not distinct from '' then
         update gomoql.game_analyzer_store set diagon_durl_c = vn_act where cnum = rec.cnum and rnum = rec.rnum;     
     end if;
          

    end loop;

--check winner
/*select case when greatest(rowcheck_lr, rowcheck_rl, colcheck_ud, colcheck_du, diagon_udlr, diagon_udrl, diagon_dulr, diagon_durl) = 5 then 'player won'
            when greatest(rowcheck_lr_c,rowcheck_rl_c,colcheck_ud_c,colcheck_du_c,diagon_udlr_c,diagon_udrl_c,diagon_dulr_c,diagon_durl_c) = 5 then 'computer won'
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
    or diagon_durl_c = 5) limit 1;*/
  select gomoql.check_winner() into vb_chk_winner;  

  if vb_chk_winner is false then      
   --computer's turn
   select cnum, 
          rnum into vn_col, vn_row
--          greatest(rowcheck_rl + colcheck_ud + colcheck_du + diagon_udlr + diagon_udrl + diagon_dulr + diagon_durl,            
--          rowcheck_rl_c + colcheck_ud_c + colcheck_du_c + diagon_udlr_c + diagon_udrl_c + diagon_dulr_c + diagon_durl_c) as field_score
   from gomoql.game_analyzer_store
   where value is not distinct from ''
   order by case when (rowcheck_lr + rowcheck_rl >= 6 or
                  colcheck_ud + colcheck_du >= 6 or
                  diagon_udlr + diagon_durl >= 6 or
                  diagon_udrl + diagon_dulr >= 6) then 1000
            when (rowcheck_lr_c + rowcheck_rl_c >= 6 or
                  colcheck_ud_c + colcheck_du_c >= 6 or
                  diagon_udlr_c + diagon_durl_c >= 6 or
                  diagon_udrl_c + diagon_dulr_c >= 6) then 999
            when (rowcheck_lr >= 5 or
                  colcheck_ud >= 5 or
                  diagon_udlr >= 5 or
                  diagon_udrl >= 5 or
                  rowcheck_rl >= 5 or
                  colcheck_du >= 5 or
                  diagon_durl >= 5 or
                  diagon_dulr >= 5) then 998
            when (rowcheck_lr_c >= 5 or
                  colcheck_ud_c >= 5 or
                  diagon_udlr_c >= 5 or
                  diagon_udrl_c >= 5 or
                  rowcheck_rl_c >= 5 or
                  colcheck_du_c >= 5 or
                  diagon_durl_c >= 5 or
                  diagon_dulr_c >= 5) then 997                  
            when (rowcheck_lr + rowcheck_rl >= 5 or
                  colcheck_ud + colcheck_du >= 5 or
                  diagon_udlr + diagon_durl >= 5 or
                  diagon_udrl + diagon_dulr >= 5) then 996
            when (rowcheck_lr_c + rowcheck_rl_c >= 5 or
                  colcheck_ud_c + colcheck_du_c >= 5 or
                  diagon_udlr_c + diagon_durl_c >= 5 or
                  diagon_udrl_c + diagon_dulr_c >= 5) then 995
            when (rowcheck_lr >= 4 or
                  colcheck_ud >= 4 or
                  diagon_udlr >= 4 or
                  diagon_udrl >= 4 or
                  rowcheck_rl >= 4 or
                  colcheck_du >= 4 or
                  diagon_durl >= 4 or
                  diagon_dulr >= 4) then 994
            when (rowcheck_lr_c >= 4 or
                  colcheck_ud_c >= 4 or
                  diagon_udlr_c >= 4 or
                  diagon_udrl_c >= 4 or
                  rowcheck_rl_c >= 4 or
                  colcheck_du_c >= 4 or
                  diagon_durl_c >= 4 or
                  diagon_dulr_c >= 4) then 993               
             else greatest(rowcheck_lr + rowcheck_rl + colcheck_ud + colcheck_du + diagon_udlr + diagon_udrl + diagon_dulr + diagon_durl,
                           rowcheck_lr_c + rowcheck_rl_c + colcheck_ud_c + colcheck_du_c + diagon_udlr_c + diagon_udrl_c + diagon_dulr_c + diagon_durl_c) end desc
   limit 1;
     
   select column_name into vv_col from information_schema.columns where table_name = 'gameboard_base' and table_schema='gomoql' and column_name !='rnum' and ordinal_position - 1 = vn_col;
   perform gomoql.turn_comp(vv_col, vn_row);
   
  end if;

end;$function$
;
