-- USE WITH POSTGRES! --

--- Discord message logging ---
create table discord_log (
    cid bigint not null,
    mid bigint not null,
    uid bigint not null,
    mtime timestamp not null,
    mdata text not null,
    etime timestamp,
    edata text,
    del boolean,
    primary key(cid, mid)
);
create index ix_discord_log_user on discord_log (uid);
create index ix_discord_log_channel on discord_log (cid);