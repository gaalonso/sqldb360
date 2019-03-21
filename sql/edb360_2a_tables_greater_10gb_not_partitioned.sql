with dblksz as (
  select value bsiz from v$parameter where name='db_block_size'
),
part  as (
  select 10*1024*1024*1024/bsiz thold from dblksz
)
Select /*+  NO_MERGE  */
       owner, table_name, partitioned, blocks, blocks*bsiz bytes,
       case when blocks*bsiz between 1024*1024*1024      and 1024*1024*1024*1024-1
                 then to_char(round(blocks*bsiz /1024/1024/1024          ),'9999') ||' Gb'
            when blocks*bsiz between 1024*1024*1024      and 1024*1024*1024*1024*1024-1
                 then to_char(round(blocks*bsiz /1024/1024/1024/1024     ),'9999') ||' Tb'
            when blocks*bsiz between 1024*1024*1024*1024 and 1024*1024*1024*1024*1024*1024-1
                 then to_char(round(blocks*bsiz /1024/1024/1024/1024/1024),'9999') ||' Pb'
       else '??????????' end  display
From   dba_tables, dblksz, part
Where  blocks > thold
And    partitioned='NO'
And    owner NOT IN ('ANONYMOUS','APEX_030200','APEX_040000','APEX_040200','APEX_SSO','APPQOSSYS','CTXSYS','DBSNMP','DIP','EXFSYS','FLOWS_FILES','MDSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','OWBSYS')
And    owner NOT IN ('SI_INFORMTN_SCHEMA','SQLTXADMIN','SQLTXPLAIN','SYS','SYSMAN','SYSTEM','TRCANLZR','WMSYS','XDB','XS$NULL','PERFSTAT','STDBYPERF','MGDSYS','OJVMSYS')
order by blocks desc ;
