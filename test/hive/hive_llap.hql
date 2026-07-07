set hive.execution.engine=tez;
set hive.execution.mode=llap;
set hive.llap.execution.mode=only;
-- set hive.llap.execution.mode=all;
-- set hive.llap.execution.mode=auto;

SELECT uname, fullname, hdir FROM userinfo ORDER BY uname;
