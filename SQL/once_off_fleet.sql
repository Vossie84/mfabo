CREATE EXTENSION IF NOT EXISTS plpgsql;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS file_fdw;
CREATE EXTENSION IF NOT EXISTS postgres_fdw;


--drop  server crunch_server cascade;
CREATE SERVER crunch_server
   FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host '<<HOST>>',port '<<PORT>>',dbname '<<DATABASE>>');


-- give user acces from fleetdb to crunch server

CREATE USER MAPPING
   FOR postgres
   SERVER crunch_server
  OPTIONS (user '<<USERNAME>>',password '<<PASSWORD>>');
