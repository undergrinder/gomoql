--optional query in order to observe the points of the cells

select rnum,
       nullif("1",0::varchar) as "1",
       nullif("2",0::varchar) as "2",
       nullif("3",0::varchar) as "3",
       nullif("4",0::varchar) as "4",
       nullif("5",0::varchar) as "5",
       nullif("6",0::varchar) as "6",
       nullif("7",0::varchar) as "7",
       nullif("8",0::varchar) as "8",
       nullif("9",0::varchar) as "9",
       nullif("10",0::varchar) as "10",
       nullif("11",0::varchar) as "11",
       nullif("12",0::varchar) as "12",
       nullif("13",0::varchar) as "13",
       nullif("14",0::varchar) as "14",
       nullif("15",0::varchar) as "15"
from crosstab('select rnum::numeric, 
                      cnum, 
                      case when value != '''' then value 
                     
            when (rowcheck_lr + rowcheck_rl >= 6 or
                  colcheck_ud + colcheck_du >= 6 or
                  diagon_udlr + diagon_durl >= 6 or
                  diagon_udrl + diagon_dulr >= 6) then 1000::varchar
            when (rowcheck_lr_c + rowcheck_rl_c >= 6 or
                  colcheck_ud_c + colcheck_du_c >= 6 or
                  diagon_udlr_c + diagon_durl_c >= 6 or
                  diagon_udrl_c + diagon_dulr_c >= 6) then 999::varchar
            when (rowcheck_lr + rowcheck_rl >= 5 or
                  colcheck_ud + colcheck_du >= 5 or
                  diagon_udlr + diagon_durl >= 5 or
                  diagon_udrl + diagon_dulr >= 5) then 998::varchar
            when (rowcheck_lr_c + rowcheck_rl_c >= 5 or
                  colcheck_ud_c + colcheck_du_c >= 5 or
                  diagon_udlr_c + diagon_durl_c >= 5 or
                  diagon_udrl_c + diagon_dulr_c >= 5) then 997::varchar
            when (rowcheck_lr >= 4 or
                  colcheck_ud >= 4 or
                  diagon_udlr >= 4 or
                  diagon_udrl >= 4 or
                  rowcheck_rl >= 4 or
                  colcheck_du >= 4 or
                  diagon_durl >= 4 or
                  diagon_dulr >= 4) then 996::varchar
            when (rowcheck_lr_c >= 4 or
                  colcheck_ud_c >= 4 or
                  diagon_udlr_c >= 4 or
                  diagon_udrl_c >= 4 or
                  rowcheck_rl_c >= 4 or
                  colcheck_du_c >= 4 or
                  diagon_durl_c >= 4 or
                  diagon_dulr_c >= 4) then 995::varchar               
             else greatest(rowcheck_lr + rowcheck_rl + colcheck_ud + colcheck_du + diagon_udlr + diagon_udrl + diagon_dulr + diagon_durl,
                           rowcheck_lr_c + rowcheck_rl_c + colcheck_ud_c + colcheck_du_c + diagon_udlr_c + diagon_udrl_c + diagon_dulr_c + diagon_durl_c)::varchar     
                      end as weight 
               from gomoql.game_analyzer_store 
               order by rnum, cnum') 
ct (rnum numeric,
"1" varchar(3),
"2" varchar(3),
"3" varchar(3),
"4" varchar(3),
"5" varchar(3),
"6" varchar(3),
"7" varchar(3),
"8" varchar(3),
"9" varchar(3),
"10"    varchar(3),
"11"    varchar(3),
"12"    varchar(3),
"13"    varchar(3),
"14"    varchar(3),
"15"    varchar(3));