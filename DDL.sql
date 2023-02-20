create schema gomoql;
select set_config('search_path',current_setting('search_path')||',gomoql',false);

create table gomoql.game_log(id           serial primary key,
                             game_id      integer,
                             event        varchar(20),
                             player       char(1),
                             params       varchar[],
							 timestamp    timestamp default now());       

create sequence gomoql.seq_game_id start 1;

create table gomoql.current_params(game_id      integer,
                                   player_char  char(1),
                                   action       varchar(20));								  