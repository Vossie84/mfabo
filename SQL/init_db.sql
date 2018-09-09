/*
Create by Andries Vorster 2018-02-18
Version : 1.1
*/

CREATE EXTENSION IF NOT EXISTS plpgsql;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS file_fdw;
CREATE EXTENSION IF NOT EXISTS postgres_fdw;
CREATE EXTENSION IF NOT EXISTS plpython3u;


CREATE TABLE IF NOT EXISTS mfaglb.clients
(
    id                 BIGSERIAL NOT NULL,
    client_id          TEXT      NOT NULL,
    client_name        TEXT,
    client_providers   TEXT [],
    client_filespace   TEXT,
    client_last_import TIMESTAMP,
    client_last_push   TIMESTAMP,
    client_connection  JSONB DEFAULT '{}' :: JSONB,
    addr1              TEXT,
    addr2              TEXT,
    addr3              TEXT,
    addr4              TEXT,
    city               TEXT,
    province           TEXT,
    postcode           TEXT,
    country            TEXT,
    companytel         TEXT,
    contactname        TEXT,
    contactemail       TEXT,
    contactcellno      TEXT,
    pushemail          TEXT,
    dashboard_config   jsonb,
    import_config      jsonb,
    email_options       jsonb,
    additional_email_files text[],
    CONSTRAINT clients_clientid_pk
    PRIMARY KEY (client_id)
);
--alter table mfaglb.clients add column api_keys jsonb;
--alter table mfaglb.clients add column additional_email_files text[];

CREATE TABLE IF NOT EXISTS mfaglb.users
(
    login_email    TEXT NOT NULL,
    login_password TEXT,
    firstname      TEXT,
    surname        TEXT,
    alternate_mail TEXT,
    client_code    TEXT NOT NULL,
    CONSTRAINT userdata_username_client_code_pk
    PRIMARY KEY (login_email, client_code),
    CONSTRAINT users_clients_client_id_fk
    FOREIGN KEY (client_code) REFERENCES mfaglb.clients
);



CREATE TABLE IF NOT EXISTS mfaglb.oemstats
(
    client_id      TEXT NOT NULL,
    vehiclereg     TEXT NOT NULL,
    make           TEXT,
    model          TEXT,
    manufyear      INTEGER,
    transmission   TEXT,
    enginecapacity NUMERIC(30, 2) DEFAULT 0,
    fueltype       TEXT,
    lper100        NUMERIC(30, 2) DEFAULT 0,
    fuelcostperl   NUMERIC(30, 2) DEFAULT 0,
    fuelindex      NUMERIC(30, 2) DEFAULT 0,
    bodyshape      TEXT,
    co2emissions   INTEGER        DEFAULT 0,
    purchaseprice  BIGINT         DEFAULT 0,
    repayperm      NUMERIC(30, 2) DEFAULT 0,
    avgkmperm      NUMERIC(30, 2) DEFAULT 0,
    insuranceperm  NUMERIC(30, 2) DEFAULT 0,
    licregpery     NUMERIC(30, 2) DEFAULT 0,
    tuperm         NUMERIC(30, 2) DEFAULT 0,
    minorservintkm NUMERIC(30, 2) DEFAULT 0,
    minorservcost  NUMERIC(30, 2) DEFAULT 0,
    majorservintkm NUMERIC(30, 2) DEFAULT 0,
    majorservcost  NUMERIC(30, 2) DEFAULT 0,
    tyreintkm      NUMERIC(30, 2) DEFAULT 0,
    tyrecost       NUMERIC(30, 2) DEFAULT 0,
    brakeintkm     NUMERIC(30, 2) DEFAULT 0,
    brakecost      NUMERIC(30, 2) DEFAULT 0,
    depreccpk      NUMERIC(30, 2) DEFAULT 0,
    fml            NUMERIC(30, 2) DEFAULT 0,
    cpk            NUMERIC(30, 2) DEFAULT 0,
    CONSTRAINT oemstats_pkey
    PRIMARY KEY (client_id, vehiclereg),
    CONSTRAINT users_clients_client_id_fk
    FOREIGN KEY (client_code) REFERENCES mfaglb.clients
);


CREATE TABLE IF NOT EXISTS mfaglb.sessioninfo
(
    authtoken   TEXT,
    authdata    JSONB,
    expire_date TIMESTAMP
);


create table if not exists mfaglb.processed_files(
  client_id text REFERENCES mfaglb.clients (client_id),
  filename text,
  md5_checksum text,
  processed_time timestamp without time zone default now(),
  constraint processed_files_pk primary key (client_id, md5_checksum)
);


create or replace function mfaglb.calculate_risk_data(_client_id text) returns void
	language plpgsql
as $$
declare
  mysql text;
BEGIN
    mysql = format($QQ$
            --risk factior calculations
            WITH trip_data AS (
                SELECT
                    lper100                AS trip_vehiclefuelconsumption,
                    distance               AS distance,
                    brakeevent             AS harshbrakeevent,
                    steeringevent          AS steeringevent,
                    startlat               AS startlat,
                    endlat                 AS endlat,
                    startlon               AS startlon,
                    endlon                 AS endlon,
                    coalesce(speed0dur, 0) AS speed0duration,
                    coalesce(speed1dur, 0) AS speed1duration,
                    coalesce(speed2dur, 0) AS speed2duration,
                    coalesce(speed3dur, 0) AS speed3duration,
                    rowid                  AS rowid,
                    vehiclereg             AS vehiclereg

                FROM %1$s.fleet_data
            )
                , vehicle AS (
                SELECT
                    lper100          AS oem_vehiclefuelconsumption,
                    purchaseprice    AS purchaseprice,
                    repayperm        AS repaymentpermonth,
                    insuranceperm    AS insurancepermonth,
                    licregpery       AS vehicleliscenseandreg,
                    tuperm           AS telematicspermonth,
                    minorservintkm   AS minorserviceinterval,
                    minorservcost    AS minorservicecost,
                    majorservintkm   AS majorserviceinterval,
                    majorservcost    AS majorservicecost,
                    tyreintkm        AS tyreinterval,
                    tyrecost         AS tyrecost,
                    brakeintkm       AS brakeinterval,
                    brakecost        AS brakecost,
                    depreccpk        AS depreciation,
                    fuelcostperl     AS fuelprice,
                    avgkmperm        AS distancepermonth,
                    0.006 :: NUMERIC AS brakeratio,
                    0.007 :: NUMERIC AS tyreratio,
                    0.01 :: NUMERIC  AS speed0ratio,
                    0.013 :: NUMERIC AS speed1ratio,
                    0.02 :: NUMERIC  AS speed2ratio,
                    0.026 :: NUMERIC AS speed3ratio,
                    1.3 :: NUMERIC   AS speed0cap,
                    1.4 :: NUMERIC   AS speed1cap,
                    1.6 :: NUMERIC   AS speed2cap,
                    1.8 :: NUMERIC   AS speed3cap,
                    vehiclereg       AS vehiclereg
                FROM mfaglb.oemstats
            )
                , parsed_costs AS (
                SELECT
                    CASE
                    WHEN depreciation = 0 THEN
                        (repaymentpermonth + insurancepermonth + telematicspermonth + (vehicleliscenseandreg / 12)) /
                        distancepermonth
                    WHEN repaymentpermonth = 0 THEN
                        ((insurancepermonth + telematicspermonth + (vehicleliscenseandreg / 12)) / distancepermonth) +
                        (depreciation / 100)
                    ELSE 0
                    END                                                                                      AS fixedmonthly,
                    CASE
                    WHEN coalesce(trip_vehiclefuelconsumption, 0) > 0 THEN (trip_vehiclefuelconsumption * fuelprice) / 100
                    WHEN coalesce(oem_vehiclefuelconsumption, 0) > 0 THEN (oem_vehiclefuelconsumption * fuelprice) / 100
                    ELSE 0.00
                    END                                                                                      AS fuelcost,
                    CASE WHEN speed0duration * (speed0ratio / 60) > speed0cap THEN speed0cap
                    ELSE speed0duration * (speed0ratio / 60) END                                             AS speed0total,
                    CASE WHEN speed1duration * (speed1ratio / 60) > speed1cap THEN speed1cap
                    ELSE speed1duration * (speed1ratio / 60) END                                             AS speed1total,
                    CASE WHEN speed2duration * (speed2ratio / 60) > speed2cap THEN speed2cap
                    ELSE speed2duration * (speed2ratio / 60) END                                             AS speed2total,
                    CASE WHEN speed3duration * (speed3ratio / 60) > speed3cap THEN speed3cap
                    ELSE speed3duration * (speed3ratio / 60) END                                             AS speed3total,
                    coalesce(harshbrakeevent * (brakeratio * (brakecost / brakeinterval)), 0)                AS braketotal,
                    coalesce((harshbrakeevent + steeringevent) * (tyreratio * (tyrecost / tyreinterval)), 0) AS tyretotal,
                    (minorservicecost / minorserviceinterval) + --minorserviceperkm,
                    (majorservicecost / majorserviceinterval) + --majorserviceperkm,
                    (brakecost / brakeinterval) + -- brakesperkm,
                    (tyrecost / tyreinterval)                                                                AS maintainancecost
                    -- tyresperkm,
                    ,
                    *
                FROM
                    trip_data
                    JOIN vehicle
                    USING (vehiclereg)
            )
                , calculated_data AS (
                SELECT
                    speed0total + speed1total + speed2total + speed3total + braketotal + tyretotal AS behaviour,
                    speed0total + speed1total + speed2total + speed3total                          AS speedcost,
                    (fuelcost + fixedmonthly + maintainancecost + speed0total + speed1total + speed2total + speed3total + braketotal
                     + tyretotal) :: NUMERIC(30, 2)                                                AS cpk,
                    (fuelcost + fixedmonthly + maintainancecost + speed0total + speed1total + speed2total + speed3total + braketotal
                     + tyretotal) * distance                                                       AS tripcost,
                    CASE
                    WHEN speed0total + speed1total + speed2total + speed3total + braketotal + tyretotal <> 0 THEN
                        100 - (((speed0total + speed1total + speed2total + speed3total + braketotal + tyretotal) /
                                (fuelcost + fixedmonthly + maintainancecost + speed0total + speed1total + speed2total + speed3total
                                 + braketotal + tyretotal)) * 100)
                    ELSE 100 END                                                                   AS driverscore,
                    *
                FROM parsed_costs
            )

            UPDATE %1$s.fleet_data tgt
            SET
                (cpk, stylescore, stylecost, tripcost, speed0cost, speed1cost, speed2cost, speed3cost, speedcost) =
                (src.cpk, src.stylescore, src.stylecost, src.tripcost, src.speed0cost, src.speed1cost, src.speed2cost, src.speed3cost, src.speedcost)
            FROM (
                     SELECT
                         rowid,
                         cpk :: NUMERIC(30, 2)                    AS cpk,
                         driverscore :: NUMERIC(30, 2)            AS stylescore,
                         (behaviour * distance) :: NUMERIC(30, 2) AS stylecost,
                         tripcost :: NUMERIC(30, 2)               AS tripcost,
                         speed0total :: NUMERIC(30, 2)            AS speed0cost,
                         speed1total :: NUMERIC(30, 2)            AS speed1cost,
                         speed2total :: NUMERIC(30, 2)            AS speed2cost,
                         speed3total :: NUMERIC(30, 2)            AS speed3cost,
                         speedcost :: NUMERIC(30, 2)              AS speedcost
                     FROM calculated_data
                 ) src
            WHERE tgt.rowid = src.rowid;
    $QQ$ , lower(_client_id));
    --raise notice '%', mysql;
    execute mysql;
END;
$$
;

create or replace function mfaglb.setup_client_import_environment(_clientid text, _recreate boolean) returns void
	language plpgsql
as $$
declare
  mysql text;
  myrec record;
BEGIN
  select * from mfaglb.clients where lower(client_id) = lower(_clientid) into myrec;

  if _recreate then
      execute format('drop schema if exists %1$s cascade;', lower(myrec.client_id));
  END IF;

  mysql = format($FF$


    create schema if not exists %1$s;


    -- tomtom structure
    drop foreign table if exists %1$s.tomtomtrip_csv;
    CREATE FOREIGN TABLE if not exists %1$s.tomtomtrip_csv (
    _vehicle text ,
    _day text ,
    _start_time text ,
    _end_time text ,
    _duration text ,
    _standstill text ,
    _start_odometer text ,
    _end_odometer text ,
    _distance text ,
    _driver text ,
    _start_location text ,
    _end_location text ,
    _start_latitude text ,
    _start_longitude text ,
    _end_latitude text ,
    _end_longitude text)
    SERVER mfa_files
    OPTIONS ( filename '%2$stomtomtrip.csv', format 'csv', delimiter ',' , quote '"', header 'true', encoding 'LATIN1');


    drop foreign table if exists %1$s.tomtomspeed_csv;
    CREATE FOREIGN TABLE if not exists %1$s.tomtomspeed_csv (
    _vehicle text,
    _date text,
    _start_time text,
    _end_time text,
    _driver text,
    _start_location text,
    _end_location text,
    _duration text,
    _max_speed text,
    _avg_speed text,
    _speed_limit text
    )
    SERVER mfa_files
    OPTIONS ( filename '%2$stomtomspeed.csv', format 'csv', delimiter ',' , quote '"', header 'true', encoding 'LATIN1');

    drop foreign table if exists %1$s.tomtomevents_csv;
    CREATE FOREIGN TABLE if not exists %1$s.tomtomevents_csv (
    _vehicle text,
    _date text,
    _time text,
    _driver text,
    _event text,
    _duration text,
    _speed text,
    _severity text,
    _g_force text,
    _location text
    )
    SERVER mfa_files
    OPTIONS ( filename '%2$stomtomevents.csv', format 'csv', delimiter ',' , quote '"', header 'true', encoding 'LATIN1');


    ---- trackestructure
    drop foreign table if exists %1$s.tracker_trip_csv cascade;
    CREATE FOREIGN TABLE if not exists %1$s.tracker_trip_csv (
        vehiclereg     TEXT,
        vehicle_alias   TEXT,
        vehicle_group    TEXT,
        rtcdate     TEXT,
        SMSDatetime3 TEXT,
        RTCDateTime  TEXT,
        SMSDatetime1 TEXT,
        Latitude     TEXT,
        Longitude    TEXT,
        Location     TEXT,
        Speed        TEXT,
        RoadSpeed    TEXT,
        Odometer     TEXT,
        Status       TEXT,
        tripnr    TEXT,
        duration    TEXT,
        avg    TEXT,
        distance    TEXT,
        date2    TEXT,
        total_trips    TEXT,
        licenseplate    TEXT,
        total_duration    TEXT,
        total_distance    TEXT,
        total_avg    TEXT,
        topspeed    TEXT,
        simcard    TEXT
    )
    SERVER mfa_files
    OPTIONS ( filename '%2$stracker_trip.csv', format 'csv', delimiter ',' , quote '"', header 'true', encoding 'LATIN1');


    drop view if exists %1$s.tracker_trip_pretty;
    create or replace view %1$s.tracker_trip_pretty as
        SELECT
            trim(replace(lower(tripnr), 'trip nr :', '')) :: INTEGER                       AS tripnr,
            trim(replace(lower(vehiclereg), 'vehicle registration :', ''))                 AS vehiclereg,
            trim(replace(lower(vehicle_alias), 'vehicle alias :', ''))                     AS vehicle_alias,
            trim(replace(lower(vehicle_group), 'vehicle group:', ''))                      AS vehicle_group,
            to_date(trim(replace(lower(rtcdate), 'rtcdatetime', '')), 'yyyy/mm/dd')        AS rtcdate,
            to_date(trim(replace(lower(smsdatetime3), 'smsdatetime', '')), 'yyyy/mm/dd')   AS smsdate,
            rtcdatetime :: TIME                                                            AS rtcdatetime,
            smsdatetime1 :: TIME                                                           AS smsdatetime,
            latitude :: NUMERIC(15, 10)                                                    AS latitude,
            longitude :: NUMERIC(15, 10)                                                   AS longitude,
            trim(location)                                                                 AS location,
            speed :: INTEGER                                                               AS speed,
            roadspeed :: INTEGER                                                           AS roadspeed,
            odometer :: INTEGER                                                            AS odometer,
            trim(lower(status))                                                            AS status,
            trim(split_part(lower(duration), 'duration :', 2))                  AS duration,
            trim(split_part((split_part(lower(duration), 'driver:', 2)), 'duration :', 1)) AS driver,
            split_part(trim(split_part(lower(avg), 'avg :', 2)), 'km', 1)                  AS avgspeed,
            split_part(trim(split_part(lower(avg), 'max :', 2)), 'km', 1)                  AS maxspeed,
            split_part(trim(split_part(lower(distance), 'distance :', 2)), 'km', 1)        AS distance,
            total_trips,
            licenseplate,
            total_duration,
            total_distance,
            total_avg,
            topspeed,
            simcard
        FROM %1$s.tracker_trip_csv
        ORDER BY vehiclereg, tripnr, rtcdatetime;



    CREATE TABLE IF NOT EXISTS %1$s.fleet_data
    (
        vehiclereg    TEXT,
        vehiclealias  TEXT,
        vehiclegroup  TEXT,
        cpk           NUMERIC(30, 2) DEFAULT 0.00,
        lper100       NUMERIC(30, 2) DEFAULT 0.00,
        tripstart     TIMESTAMP,
        tripend       TIMESTAMP,
        tripdur       INTEGER        DEFAULT 0,
        standstill    INTEGER        DEFAULT 0,
        startodo      INTEGER        DEFAULT 0,
        endodo        INTEGER        DEFAULT 0,
        distance      NUMERIC(30, 2) DEFAULT 0.00,
        tripcost      NUMERIC(30, 2) DEFAULT 0.00,
        brakeevent    INTEGER        DEFAULT 0,
        brakecost     NUMERIC(30, 2) DEFAULT 0.00,
        steeringevent INTEGER        DEFAULT 0,
        steeringcost  NUMERIC(30, 2) DEFAULT 0.00,
        speed0count   INTEGER        DEFAULT 0,
        speed0event   INTEGER []     DEFAULT ARRAY[] :: INTEGER [],
        speed0dur     INTEGER        DEFAULT 0,
        speed0cost    NUMERIC(30, 2) DEFAULT 0.00,
        speed1count   INTEGER        DEFAULT 0,
        speed1event   INTEGER []     DEFAULT ARRAY[] :: INTEGER [],
        speed1dur     INTEGER        DEFAULT 0,
        speed1cost    NUMERIC(30, 2) DEFAULT 0.00,
        speed2count   INTEGER        DEFAULT 0,
        speed2event   INTEGER []     DEFAULT ARRAY[] :: INTEGER [],
        speed2dur     INTEGER        DEFAULT 0,
        speed2cost    NUMERIC(30, 2) DEFAULT 0.00,
        speed3count   INTEGER        DEFAULT 0,
        speed3event   INTEGER []     DEFAULT ARRAY[] :: INTEGER [],
        speed3dur     INTEGER        DEFAULT 0,
        speed3cost    NUMERIC(30, 2) DEFAULT 0.00,
        speedcount    INTEGER        DEFAULT 0,
        speeddur      INTEGER        DEFAULT 0,
        speedcost     NUMERIC(30, 2) DEFAULT 0.00,
        stylescore    NUMERIC(30, 2) DEFAULT 0.00,
        stylecost     NUMERIC(30, 2) DEFAULT 0.00,
        startloc      TEXT,
        endloc        TEXT,
        startlat      NUMERIC(15, 10),
        startlon      NUMERIC(15, 10),
        endlat        NUMERIC(15, 10),
        endlon        NUMERIC(15, 10),
        routevar      NUMERIC(30, 2) DEFAULT 0.00,
        routevarcost  NUMERIC(30, 2) DEFAULT 0.00,
        routescore    NUMERIC(30, 2) DEFAULT 0.00,
        driver        TEXT,
        tripnr        INTEGER        DEFAULT 0,
        riskfactor    NUMERIC(30, 2) DEFAULT 0.00,
        processed     SMALLINT       DEFAULT 0,
        rowid         BIGSERIAL
    );


    CREATE TABLE IF NOT EXISTS %1$s.weigh_data
    (
      vehiclereg text,
      weigh_date date,
      weigh_amount numeric(10,5)
    );

    CREATE FOREIGN TABLE %1$s.weigh_data_csv
       (vehiclereg text ,
        weigh_date text ,
        weigh_amount text )
       SERVER mfa_files
       OPTIONS (filename '%2$sdailytons.csv', format 'csv', delimiter ',', quote '"', header 'false', encoding 'utf8');


$FF$ , lower(myrec.client_id), myrec.client_filespace   );
raise notice '%', mysql;
execute mysql;

END;
$$
;

create or replace function mfaglb.get_auth_token(authdata json) returns text
	language plpgsql
as $$
BEGIN

END;
$$
;

create or replace function mfaglb.authentication(myvars json) returns json
	language plpgsql
as $$
DECLARE
  retval json;
  varrec record;
  authrec record;
BEGIN
    SELECT *
    FROM json_to_record(myvars) AS jvar
         (username text, password text)
    INTO varrec;

    with client_data as (
         SELECT
             encode(digest(varrec.password::text, 'sha1'), 'hex') = login_password as result,*
         FROM mfaglb.users
         WHERE login_email = varrec.username
    )
    select
        case
            when result then encode(digest(concat(login_email, chr((random()*100)::integer) , login_password, clock_timestamp(), client_code ) , 'sha256'), 'hex')
            else null::text
        end as authkey, *
    from client_data into authrec;

    if authrec.authkey is not null then
        with client_data as (
            SELECT
                client_id,client_name,client_connection,
                addr1,addr2,addr3,addr4,city,
                province,postcode,country,companytel,
                contactname,contactemail,contactcellno,pushemail
            FROM mfaglb.clients
            where
                client_id = authrec.client_code
        )
        select row_to_json(client_data.*) from client_data into retval;

        insert into mfaglb.sessioninfo (authtoken, authdata, expire_date)
        values (authrec.authkey , retval ,  clock_timestamp()+'1 hour');

        retval = (retval::jsonb || '{"result":true}'::jsonb)::json;
        --retval = json_object(array['result', 'authkey'], array['true', authrec.authkey]);
    else
        retval = '{"result":false}'::json;
    end if;

    --if retval is null then retval = '{"result":false}'::json; end if;
    return retval;
end;
$$
;

create or replace function mfaglb.get_token(myvars json) returns json
	language plpgsql
as $$
DECLARE
  retval json;
  varrec record;
  authrec record;
BEGIN
    SELECT *
    FROM json_to_record(myvars) AS jvar
         (username text, password text)
    INTO varrec;

    with client_data as (
         SELECT
             encode(digest(varrec.password::text, 'sha1'), 'hex') = login_password as result,*
         FROM mfaglb.users
         WHERE login_email = varrec.username
    )
    select
        case
            when result then encode(digest(concat(login_email, chr((random()*100)::integer) , login_password, clock_timestamp(), client_code ) , 'sha256'), 'hex')
            else null::text
        end as authkey, *
    from client_data into authrec;

    if authrec.authkey is not null then
        select row_to_json(a.*) from mfaglb.clients a where client_id = authrec.client_code into retval;
        insert into mfaglb.sessioninfo (authtoken, authdata, expire_date)
        values (authrec.authkey , retval ,  clock_timestamp()+'1 hour');

        retval = json_object(array['result', 'authkey'], array['true', authrec.authkey]);
    else
        retval = '{"result":false}'::json;
    end if;

    --if retval is null then retval = '{"result":false}'::json; end if;
    return retval;
end;
$$
;



CREATE OR REPLACE FUNCTION imports.import_weigh_data(clientid text)
  RETURNS void AS
$BODY$
declare
mysql text;
begin
	mysql = format($QQ$
	truncate %1$s.weigh_data;

	insert into %1$s.weigh_data
	SELECT
	trim(vehiclereg)                  AS vehiclereg,
	to_date(weigh_date, 'YYYY-MM-DD') AS weigh_date,
	trim(weigh_amount) :: NUMERIC(10, 5)    AS weigh_amount
	FROM %1$s.weigh_data_csv;$QQ$ ,
	clientid
	);
	execute mysql;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE;



CREATE OR REPLACE FUNCTION imports.import_tracker_data(_client_id text)
  RETURNS void AS
$BODY$
declare
  mysql text;
BEGIN
    mysql = format($QQ$
            WITH formatted_data AS (
                SELECT *
                FROM %1$s.tracker_trip_pretty
                ORDER BY vehiclereg, tripnr, rtcdatetime
            )
            , parsed_data AS (
                SELECT
                    vehiclereg,
                    tripnr,
                    rtcdate,
                    vehicle_alias,
                    vehicle_group,
                    driver,
                    min(rtcdate) FILTER (WHERE status = 'ignition on')  AS datestart,
                    max(rtcdate) FILTER (WHERE status = 'ignition off') AS dateend,
                    min(rtcdatetime) FILTER (WHERE status = 'ignition on')  AS tripstart,
                    max(rtcdatetime) FILTER (WHERE status = 'ignition off') AS tripend,
                    max(duration) FILTER (WHERE status = 'ignition off') AS durationend,
                    max(distance) FILTER (WHERE status = 'ignition off') AS distanceend,
                    min(latitude) FILTER (WHERE status = 'ignition on')  AS startlat,
                    min(longitude) FILTER (WHERE status = 'ignition on')  AS startlon,
                    max(latitude) FILTER (WHERE status = 'ignition off') AS endlat,
                    max(longitude) FILTER (WHERE status = 'ignition off') AS endlon,
                    min(location) FILTER (WHERE status = 'ignition on')  AS startloctaion,
                    max(location) FILTER (WHERE status = 'ignition off') AS endloctaion,
                    min(odometer) FILTER (WHERE status = 'ignition on')  AS startodo,
                    max(odometer) FILTER (WHERE status = 'ignition off') AS endodo
                FROM formatted_data
                GROUP BY vehiclereg, tripnr, vehicle_alias, vehicle_group, driver, rtcdate
                ORDER BY vehiclereg, tripnr
            )

             INSERT INTO %1$s.fleet_data (
                 vehiclereg, vehiclealias , vehiclegroup, tripstart, tripend, tripdur, standstill,
                 startodo, endodo, distance, driver, startloc,
                 endloc, startlat, startlon, endlat, endlon, tripnr)
            SELECT
                vehiclereg,
                vehicle_alias,
                vehicle_group,
                datestart + tripstart           AS tripstart,
                dateend + tripend               AS tripend,
                EXTRACT(EPOCH FROM ((dateend + tripend)-(datestart + tripstart))) AS duration,
                0                               AS standstill,
                startodo,
                endodo,
                endodo - startodo               AS distance,
                driver,
                startloctaion,
                endloctaion,
                startlat,
                startlon,
                endlat,
                endlon,
                tripnr
            FROM parsed_data;


            drop table if exists tracker_events_data;
            create temp table tracker_events_data as (
                SELECT
                    vehiclereg,
                    tripnr,
                    vehicle_alias,
                    vehicle_group,
                    driver,
                    status,
                    rtcdate                                                 AS eventdate,
                    lag(rtcdatetime)
                    OVER (
                        ORDER BY vehiclereg, tripnr, rtcdate, rtcdatetime ) AS prev_eventtime,
                    rtcdatetime                                             AS eventtime,
                    rtcdatetime - lag(rtcdatetime)
                    OVER (
                        ORDER BY vehiclereg, tripnr, rtcdate, rtcdatetime ) AS event_duration,
                    speed,
                    roadspeed,
                    avgspeed,
                    maxspeed
                FROM %1$s.tracker_trip_pretty
                --where vehicle_alias = 'robert sibisi'
                ORDER BY vehiclereg, tripnr, rtcdate, rtcdatetime
            );


            with risk_factor_data as (
            select
            vehiclereg, tripnr , eventdate,
            coalesce(sum(EXTRACT(EPOCH FROM event_duration)::integer) filter (where status = 'stopped'),0)::integer as standstill,

            coalesce(sum(EXTRACT(EPOCH FROM event_duration)::integer) filter (where status ilike '%2$sharsh brake%2$s'),0)::integer as total_brake_event_duration,
            coalesce(count(EXTRACT(EPOCH FROM event_duration)::integer) filter (where status ilike '%2$sharsh brake%2$s'),0)::integer as total_brake_event_count,

            coalesce(sum(EXTRACT(EPOCH FROM event_duration)::integer) filter (where status ilike '%2$sover speed%2$s'),0)::integer as total_speed_duration,
            coalesce(count(EXTRACT(EPOCH FROM event_duration)::integer) filter (where status ilike '%2$sover speed%2$s2$s'),0)::integer as total_speed_count,

            coalesce(array_agg(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE speed < 130 and status ilike '%2$sover speed%2$s'),'{}')::integer[]                                                  AS speed0,
            coalesce(sum(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE speed < 130  and status ilike '%2$sover speed%2$s') ,0)::integer                                 AS speed0_duration,
            coalesce(count(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE speed < 130  and status ilike '%2$sover speed%2$s') ,0)::integer                       AS speed0_count,

            coalesce(array_agg(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE (speed > 130 AND speed < 141) and status ilike '%2$sover speed%2$s'),'{}')::integer[]                            AS speed1,
            coalesce(sum(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE (speed > 130 AND speed < 141) and status ilike '%2$sover speed%2$s'),0)::integer                            AS speed1_duration,
            coalesce(count(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE (speed > 130 AND speed < 141) and status ilike '%2$sover speed%2$s'),0)::integer                            AS speed1_count,

            coalesce(array_agg(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE (speed > 140 AND speed < 151) and status ilike '%2$sover speed%2$s'),'{}')::integer[]                            AS speed2,
            coalesce(sum(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE (speed > 140 AND speed < 151)and status ilike '%2$sover speed%2$s'),0)::integer                            AS speed2_duration,
            coalesce(count(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE (speed > 140 AND speed < 151)and status ilike '%2$sover speed%2$s'),0)::integer                            AS speed2_count,

            coalesce(array_agg(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE speed > 150 and status ilike '%2$sover speed%2$s'),'{}')::integer[]                                                  AS speed3,
            coalesce(sum(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE speed > 150 and status ilike '%2$sover speed%2$s'),0)::integer                                                  AS speed3_duration,
            coalesce(count(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE speed > 150 and status ilike '%2$sover speed%2$s'),0)::integer                                                  AS speed3_count
            from tracker_events_data
            group by
                vehiclereg, eventdate, tripnr
            )
            update %1$s.fleet_data tgt
            set
            (
             brakeevent, steeringevent,
             speedcount, speeddur,standstill,
             speed0event, speed0count, speed0dur,
             speed1event, speed1count, speed1dur,
             speed2event, speed2count, speed2dur,
             speed3event, speed3count, speed3dur) =
             (
             src.total_brake_event_count,0,
             src.speed0_count+src.speed1_count+src.speed2_count+src.speed3_count,
             src.speed0_duration+src.speed1_duration+src.speed2_duration+src.speed3_duration,
             src.standstill,
             src.speed0, src.speed0_count, src.speed0_duration,
             src.speed1, src.speed1_count, src.speed1_duration,
             src.speed2, src.speed2_count, src.speed2_duration,
             src.speed3, src.speed3_count, src.speed3_duration)
            from (
                SELECT
                    vehiclereg,tripnr,eventdate,standstill,
                    total_brake_event_count,
                    total_speed_count, total_speed_duration,
                    coalesce(speed0,'{}')::integer[] as speed0,
                    speed0_count,
                    coalesce(speed0_duration,0) as speed0_duration,
                    coalesce(speed1,'{}')::integer[] as speed1,
                    speed1_count,
                    coalesce(speed1_duration,0) as speed1_duration ,
                    coalesce(speed2,'{}')::integer[] as speed2,
                    speed2_count,
                    coalesce(speed2_duration,0) as speed2_duration,
                    coalesce(speed3,'{}')::integer[] as speed3,
                    speed3_count,
                    coalesce(speed3_duration,0) as speed3_duration
                FROM risk_factor_data
            )src
            where tgt.vehiclereg = src.vehiclereg and tgt.tripnr = src.tripnr and tgt.tripstart::date = src.eventdate;
            -- RETURNING *;


            delete from %1$s.fleet_data where coalesce(distance,0) = 0;

            update %1$s.fleet_data set vehiclereg = upper(vehiclereg), vehiclealias = upper(vehiclealias) , vehiclegroup = upper(vehiclegroup);
    $QQ$,
    lower(_client_id), '%'
    );
--raise notice '%', mysql;
   execute mysql;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE;





CREATE OR REPLACE FUNCTION imports.import_tomtom_data(_client_id text)
  RETURNS void AS
$BODY$
declare
  mysql text;
BEGIN
    mysql = format($QQ$

    -- actual trip data....
    --TRUNCATE %1$s.fleet_data;
    INSERT INTO %1$s.fleet_data (
        vehiclereg, tripstart, tripend, tripdur, standstill,
        startodo, endodo, distance, driver, startloc,
        endloc, startlat, startlon, endlat, endlon)
        SELECT
            _vehicle,
            to_date(_day, 'Dy DD/MM') + (extract('year' FROM current_timestamp) || ' years') :: INTERVAL +
            (_start_time :: INTEGER) / 1000 * INTERVAL '1 second',
            to_date(_day, 'Dy DD/MM') + (extract('year' FROM current_timestamp) || ' years') :: INTERVAL +
            (_end_time :: INTEGER) / 1000 * INTERVAL '1 second',
            _duration :: INTEGER / 1000,
            _standstill :: INTEGER / 1000,
            _start_odometer :: INTEGER,
            _end_odometer :: INTEGER,
            _distance :: NUMERIC(30, 2),
            _driver,
            _start_location,
            _end_location,
            _start_latitude :: NUMERIC / 1000000,
            _start_longitude :: NUMERIC / 1000000,
            _end_latitude :: NUMERIC / 1000000,
            _end_longitude :: NUMERIC / 1000000
        FROM %1$s.tomtomtrip_csv;



    -- speeding events
    WITH parsed_speed AS (
        SELECT
            _vehicle,
            _driver,
            _start_location,
            _end_location,
            _duration :: INTEGER / 1000                                                                                   AS _speed_duration,
            _max_speed :: INTEGER                                                                                         AS _max_speed,
            _avg_speed :: INTEGER                                                                                         AS _avg_speed,
            _speed_limit :: INTEGER                                                                                       AS _speed_limit,

            to_timestamp(_date:: BIGINT / 1000)::date + '1 second'::interval + ((_start_time :: INTEGER) / 1000 * INTERVAL '1 second' )                                  AS _start_time,
            to_timestamp(_date:: BIGINT / 1000)::date + '1 second'::interval + ((_end_time :: INTEGER) / 1000 * INTERVAL '1 second' )                                  AS _end_time
        FROM %1$s.tomtomspeed_csv
    )
    , trip_speed AS (
        SELECT *
        FROM parsed_speed
            JOIN
            %1$s.fleet_data
                ON _vehicle = vehiclereg AND
                   ((_start_time BETWEEN tripstart AND tripend) AND (_end_time BETWEEN tripstart AND tripend))
    )
    , aggregate_data as (
        SELECT
            rowid,
            _vehicle,
            tripstart,
            tripend,
            count(_speed_duration::integer)                                                   AS speed_count,
            sum(_speed_duration::integer)                                                   AS speed_duration,
            array_agg(_speed_duration)
                FILTER (WHERE _max_speed < 130)                                                  AS speed0,  --anything less than 130
            sum(_speed_duration::integer)
                FILTER (WHERE _max_speed < 130)                                                  AS speed0_duration,
            array_agg(_speed_duration)
                FILTER (WHERE _max_speed > 130 AND _max_speed < 141)                            AS speed1,
            sum(_speed_duration::integer)
                FILTER (WHERE _max_speed > 130 AND _max_speed < 141)                            AS speed1_duration,
            array_agg(_speed_duration)
                FILTER (WHERE _max_speed > 140 AND _max_speed < 151)                            AS speed2,
            sum(_speed_duration::integer)
                FILTER (WHERE _max_speed > 140 AND _max_speed < 151)                            AS speed2_duration,
            array_agg(_speed_duration)
                FILTER (WHERE _max_speed > 151)                                                  AS speed3,
            sum(_speed_duration::integer)
                FILTER (WHERE _max_speed > 151)                                                  AS speed3_duration
        FROM trip_speed
        GROUP BY rowid, _vehicle, tripstart, tripend
    )

    update %1$s.fleet_data tgt
    set
    ( speeddur, speedcount,
     speed0event, speed0count, speed0dur,
     speed1event, speed1count, speed1dur,
     speed2event, speed2count, speed2dur,
     speed3event, speed3count, speed3dur) =
     ( src.speed_duration, src.speed_count,
     src.speed0, src.speed0count, src.speed0_duration,
     src.speed1, src.speed1count, src.speed1_duration,
     src.speed2, src.speed2count, src.speed2_duration,
     src.speed3, src.speed3count, src.speed3_duration)
    from (
        SELECT
            rowid,
            coalesce(speed_count, 0) as speed_count,
            coalesce(speed_duration, 0) as speed_duration,
            coalesce(speed0,'{}')::integer[] as speed0,
            coalesce(array_length(speed0, 1),0) AS speed0count,
            coalesce(speed0_duration,0) as speed0_duration,
            coalesce(speed1,'{}')::integer[] as speed1,
            coalesce(array_length(speed1, 1),0) AS speed1count,
            coalesce(speed1_duration,0) as speed1_duration ,
            coalesce(speed2,'{}')::integer[] as speed2,
            coalesce(array_length(speed2, 1),0) AS speed2count,
            coalesce(speed2_duration,0) as speed2_duration,
            coalesce(speed3,'{}')::integer[] as speed3,
            coalesce(array_length(speed3, 1),0) AS speed3count,
            coalesce(speed3_duration,0) as speed3_duration
        FROM aggregate_data
    )src
    where tgt.rowid = src.rowid;
    $QQ$, lower(_client_id));
raise notice '%' , mysql;
    execute mysql;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;



drop table if exists mfaglb.lists cascade;

create table if not exists mfaglb.lists
(id SERIAL,
 list_type integer,
 description text,
 constraint lists_pk primary key (list_type, description)
 );

truncate mfaglb.lists;

INSERT INTO mfaglb.lists (list_type, description) VALUES (2, 'import_weigh_data') on conflict do nothing;
INSERT INTO mfaglb.lists (list_type, description) VALUES (2, 'calculate_route_deviation') on conflict do nothing;

INSERT INTO mfaglb.lists (list_type, description) VALUES (3, 'weigh_data') on conflict do nothing;
INSERT INTO mfaglb.lists (list_type, description) VALUES (3, 'route_deviation') on conflict do nothing;

INSERT INTO mfaglb.lists (list_type, description) VALUES (4, 'host') on conflict do nothing;
INSERT INTO mfaglb.lists (list_type, description) VALUES (4, 'port') on conflict do nothing;
INSERT INTO mfaglb.lists (list_type, description) VALUES (4, 'database') on conflict do nothing;
INSERT INTO mfaglb.lists (list_type, description) VALUES (4, 'username') on conflict do nothing;
INSERT INTO mfaglb.lists (list_type, description) VALUES (4, 'password') on conflict do nothing;


INSERT INTO mfaglb.lists (list_type, description) VALUES (5, 'incoming_server') on conflict do nothing;
INSERT INTO mfaglb.lists (list_type, description) VALUES (5, 'incoming_port') on conflict do nothing;
INSERT INTO mfaglb.lists (list_type, description) VALUES (5, 'username') on conflict do nothing;
INSERT INTO mfaglb.lists (list_type, description) VALUES (5, 'password') on conflict do nothing;
INSERT INTO mfaglb.lists (list_type, description) VALUES (5, 'outgoing_server') on conflict do nothing;
INSERT INTO mfaglb.lists (list_type, description) VALUES (5, 'outgoing_port') on conflict do nothing;
INSERT INTO mfaglb.lists (list_type, description) VALUES (5, 'ssl') on conflict do nothing;
INSERT INTO mfaglb.lists (list_type, description) VALUES (5, 'protocol') on conflict do nothing;
INSERT INTO mfaglb.lists (list_type, description) VALUES (5, 'sender_domain') on conflict do nothing;


create or replace view mfaglb.v_providers as
select * from mfaglb.telematics_providers;

create or replace view mfaglb.v_import_config_options as
select * from mfaglb.lists where list_type = 2;

create or replace view mfaglb.v_dashboard_options as
select * from mfaglb.lists where list_type = 3;

create or replace view mfaglb.v_fleet_connection_options as
select * from mfaglb.lists where list_type = 4;

create or replace view mfaglb.v_email_options as
select * from mfaglb.lists where list_type = 5;


create table if not exists mfaglb.telematics_providers(
  provider_name text,
  provider_allowed_files text[],
  constraint telematics_providers_pk primary key (provider_name)
);

insert into mfaglb.telematics_providers (provider_name, provider_allowed_files) values ('tomtom', array['tomtomspeed.csv', 'tomtomevents.csv', 'tomtomtrip.csv']) on conflict do nothing;
insert into mfaglb.telematics_providers (provider_name, provider_allowed_files) values ('tracker', array['tracker_trip.csv']) on conflict do nothing;
insert into mfaglb.telematics_providers (provider_name, provider_allowed_files) values ('ctrack', null) on conflict do nothing;


CREATE OR REPLACE FUNCTION mfaglb.get_connection_options(_client_id TEXT)
    RETURNS BOOLEAN AS
$BODY$
BEGIN
    DROP TABLE IF EXISTS client_conn;
    CREATE TEMP TABLE client_conn AS (
        WITH config AS (
            SELECT description AS key
            FROM mfaglb.v_fleet_connection_options
        )
            , setup AS (
            SELECT (jsonb_each_text(client_connection)).*
            FROM mfaglb.clients
            WHERE upper(client_id) = upper(_client_id)
        )
        SELECT *
        FROM config
            LEFT JOIN setup
            USING (key)
    );
    RETURN (SELECT count(*) > 0
            FROM client_conn);
END;
$BODY$
LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION mfaglb.get_import_config_options(_client_id TEXT)
    RETURNS BOOLEAN AS
$BODY$
BEGIN
    DROP TABLE IF EXISTS import_conn;
    CREATE TEMP TABLE import_conn AS (
        WITH config AS (
            SELECT description AS key
            FROM mfaglb.v_import_config_options
        )
            , setup AS (
            SELECT (jsonb_each_text(import_config)).*
            FROM mfaglb.clients
            WHERE upper(client_id) = upper(_client_id)
        )
        SELECT *
        FROM config
            LEFT JOIN setup
            USING (key)
    );
    RETURN (SELECT count(*) > 0
            FROM import_conn);
END;
$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION mfaglb.get_dashboard_config_options(_client_id TEXT)
    RETURNS BOOLEAN AS
$BODY$
BEGIN
    DROP TABLE IF EXISTS dash_conn;
    CREATE TEMP TABLE dash_conn AS (
        WITH config AS (
            SELECT description AS key
            FROM mfaglb.v_dashboard_options
        )
            , setup AS (
            SELECT (jsonb_each_text(dashboard_config)).*
            FROM mfaglb.clients
            WHERE upper(client_id) = upper(_client_id)
        )
        SELECT *
        FROM config
            LEFT JOIN setup
            USING (key)
    );
    RETURN (SELECT count(*) > 0
            FROM dash_conn);
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION mfaglb.get_email_options(_client_id TEXT)
    RETURNS BOOLEAN AS
$BODY$
BEGIN
    DROP TABLE IF EXISTS email_conn;
    CREATE TEMP TABLE email_conn AS (
        WITH config AS (
            SELECT description AS key
            FROM mfaglb.v_email_options
        )
            , setup AS (
            SELECT (jsonb_each_text(email_options)).*
            FROM mfaglb.clients
            WHERE upper(client_id) = upper(_client_id)
        )
        SELECT *
        FROM config
            LEFT JOIN setup
            USING (key)
    );
    RETURN (SELECT count(*) > 0
            FROM email_conn);
END;
$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION  mfaglb.get_list_of_clients_json()
returns jsonb as
$$
begin
  return (
        with client_files as (
            SELECT
                client_id,
                additional_email_files,
                unnest(client_providers) AS provider_name
            FROM mfaglb.clients
        )
        , email_files as (
            SELECT
                client_id,
                provider_allowed_files || additional_email_files AS allowed_email_files
            FROM client_files
                JOIN mfaglb.v_providers
                USING (provider_name)
        )
        , clients as (
            SELECT *
            FROM mfaglb.clients
                JOIN email_files
                USING (client_id)
        )
        select json_build_object('clients', jsonb_agg( row_to_json(clients.*) )) from clients
  );
end;
$$
language plpgsql;


CREATE OR REPLACE FUNCTION mfaglb.get_providers(_client_id TEXT)
    RETURNS BOOLEAN AS
$BODY$
BEGIN
    DROP TABLE IF EXISTS provider_conn;
    CREATE TEMP TABLE provider_conn AS (
        WITH config AS (
            SELECT provider_name AS key
            FROM mfaglb.v_providers
        )
            , setup AS (
            SELECT unnest(client_providers ) as key, true as value
            FROM mfaglb.clients
            WHERE upper(client_id) = upper(_client_id)
        )
        SELECT *, row_number() over ()
        FROM config
            LEFT JOIN setup
            USING (key)
    );
    RETURN (SELECT count(*) > 0
            FROM provider_conn);
END;
$BODY$
LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS mfaglb.add_processed_file(_client_id TEXT, _filename TEXT, _checksum TEXT );
CREATE OR REPLACE FUNCTION mfaglb.add_processed_file(_client_id TEXT, _filename TEXT, _checksum TEXT)
    RETURNS VOID AS
$BODY$
BEGIN
    INSERT INTO mfaglb.processed_files (client_id, filename, md5_checksum)
    VALUES (_client_id, _filename, _checksum)
    ON CONFLICT DO NOTHING;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION mfaglb.check_processed_checksum(_client_id TEXT, _checksum TEXT)
    RETURNS JSONB AS
$BODY$
DECLARE
    ret_json JSONB;
BEGIN
    SELECT row_to_json( processed_files.* ) :: JSONB
    FROM mfaglb.processed_files
    WHERE client_id = _client_id AND md5_checksum = _checksum
    INTO ret_json;

    IF ret_json IS NOT NULL THEN
        RETURN jsonb_build_object( 'result', TRUE ) || ret_json;
    ELSE
        RETURN jsonb_build_object( 'result', FALSE );
    END IF;
END;
$BODY$
LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS mfaglb.add_user(userdata JSONB );
CREATE OR REPLACE FUNCTION mfaglb.add_user(userdata JSONB)
    RETURNS JSONB AS
$BODY$
DECLARE
    userrec  RECORD;
    err_var1 TEXT;
    err_var2 TEXT;
    err_var3 TEXT;
    err_var4 TEXT;
    err_var5 TEXT;
    err_var6 TEXT;
    err_var7 TEXT;
    err_var8 TEXT;
    err_var9 TEXT;

BEGIN

    SELECT *
    FROM jsonb_populate_record(NULL :: mfaglb.USERS, userdata)
    INTO userrec;

    IF trim(coalesce(userrec.login_email, '')) = '' THEN
        RETURN jsonb_build_object('result', FALSE, 'message', 'Username cannot be empty');
    END IF;

    IF trim(coalesce(userrec.login_password, '')) = '' THEN
        RETURN jsonb_build_object('result', FALSE, 'message', 'Password cannot be empty');
    END IF;

    IF trim(coalesce(userrec.client_code, '')) = '' THEN
        RETURN jsonb_build_object('result', FALSE, 'message', 'Client code cannot be empty');
    END IF;

    SELECT encode(digest(userrec.login_password :: TEXT, 'sha1'), 'hex')
    INTO userrec.login_password;

    BEGIN
        INSERT INTO mfaglb.users (login_email, login_password, firstname, surname, alternate_mail, client_code)
        VALUES (userrec.login_email, userrec.login_password, userrec.firstname, userrec.surname, userrec.alternate_mail, userrec.client_code);

        RETURN jsonb_build_object('result', TRUE, 'message', format('User : %s created successfully', userrec.login_email));
        EXCEPTION
            WHEN unique_violation THEN
                RETURN jsonb_build_object('result', FALSE, 'message', format('%s already exists', userrec.login_email));
            WHEN OTHERS THEN
                GET STACKED DIAGNOSTICS err_var1 = RETURNED_SQLSTATE,
                err_var2 = COLUMN_NAME,
                err_var3 = CONSTRAINT_NAME,
                err_var4 = PG_DATATYPE_NAME,
                err_var5 = MESSAGE_TEXT,
                err_var6 = SCHEMA_NAME,
                err_var7 = PG_EXCEPTION_DETAIL,
                err_var8 = PG_EXCEPTION_HINT,
                err_var9 = PG_EXCEPTION_CONTEXT;
                RETURN jsonb_build_object('result', FALSE,
                                          'message', 'Exception occured',
                                          'exception_details',
                                          mfaglb.build_stack_diagnostics_object(ARRAY [err_var1, err_var2, err_var3, err_var4, err_var5, err_var6, err_var7, err_var8, err_var9]));
    END;

END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION mfaglb.build_stack_diagnostics_object(stack_array TEXT [])
    RETURNS JSONB AS
$BODY$
BEGIN
    RETURN jsonb_build_object( 'returned_sqlstate', stack_array [1],
                               'column_name', stack_array [2],
                               'constraint_name', stack_array [3],
                               'pg_datatype_name', stack_array [4],
                               'message_text', stack_array [5],
                               'schema_name', stack_array [6],
                               'pg_exception_detail', stack_array [7],
                               'pg_exception_hint', stack_array [8],
                               'pg_exception_context', stack_array [9]
    );
END;
$BODY$
LANGUAGE plpgsql;




create table if not exists mfaglb.google_distance
(
    startlat      NUMERIC(15, 10),
    startlon      NUMERIC(15, 10),
    endlat        NUMERIC(15, 10),
    endlon        NUMERIC(15, 10),
    google_result jsonb,
    CONSTRAINT pk_google_distance
    PRIMARY KEY (startlat, startlon, endlat, endlon)
);

drop function if exists mfaglb.get_google_distance(jsonb);
CREATE OR REPLACE FUNCTION mfaglb.get_google_distance(geo_info jsonb)
  RETURNS text AS
$BODY$
import urllib
import urllib.request
import urllib.parse
import datetime
import json

try:
    geo_json = json.loads(geo_info)
    myurl = "https://maps.googleapis.com/maps/api/distancematrix/json?"
    myvalues = {'origins': str(geo_json['start_lat'])+','+str(geo_json['start_lon']),'destinations':str(geo_json['end_lat'])+','+str(geo_json['end_lon']),  'key': geo_json['apikey']}
    mydata = urllib.parse.urlencode(myvalues)
    myurl = myurl + mydata
    myreq = urllib.request.Request(myurl)
    myresponse = urllib.request.urlopen(myreq, timeout=5).read().decode('utf-8')
    #kaaswors = myresponse.read().decode('utf-8')
    return myresponse
except Exception as e:
    return '{"error" : "%s"}' % (str(e))
$BODY$
  LANGUAGE plpython3u VOLATILE;

drop function if exists imports.populate_google_distance(text);
create or replace function imports.populate_google_distance(_client_id text)
returns void as
$BODY$
declare
  mysql text;
  clientrec record;
begin
    -- parse json paramaters into record sturcture;
    WITH client_data AS (
        SELECT *
        FROM mfaglb.clients where client_id = _client_id
    )
    SELECT *
    FROM client_data
        LEFT JOIN LATERAL (SELECT *
                           FROM jsonb_to_record(client_data.dashboard_config) AS x (weigh_data BOOLEAN, route_deviation BOOLEAN) ) AS dash_config
            ON TRUE
        LEFT JOIN LATERAL (SELECT *
                           FROM jsonb_to_record(client_data.import_config) AS x (import_weigh_data BOOLEAN, calculate_route_deviation BOOLEAN) ) AS import_config
            ON TRUE
        LEFT JOIN LATERAL (SELECT *
                           FROM jsonb_to_record(client_data.api_keys) AS x (google_distance_matrix text) ) AS api_config
            ON TRUE
    INTO clientrec;


    mysql = format($QQ$
    with
    preps as (
            SELECT distinct on (startlat,startlon,endlat,endlon) *
            FROM %1$s.fleet_data
                LEFT JOIN mfaglb.google_distance
                USING (startlat, startlon, endlat, endlon)
            WHERE google_result IS NULL AND startlat is not null and startlon is not null and endlat is not null and endlon is not null
        )
    ,googles as (
        SELECT
            mfaglb.get_google_distance(
                jsonb_build_object(
                    'start_lat', startlat,
                    'start_lon', startlon,
                    'end_lat', endlat,
                    'end_lon', endlon,
                    'apikey', %2$L
                )) :: JSONB as myresult,
            *
        FROM preps
    )
    ,ginserts as (
        INSERT INTO mfaglb.google_distance
            SELECT
                startlat,
                startlon,
                endlat,
                endlon,
                myresult
            FROM googles
        ON CONFLICT ON CONSTRAINT pk_google_distance DO UPDATE SET google_result = excluded.google_result
        RETURNING *
    )
    select * from ginserts;
    $QQ$, clientrec.client_id, clientrec.google_distance_matrix );

    execute mysql;
end;
$BODY$
language plpgsql;


drop view if exists mfaglb.v_google_distance;
create or replace view mfaglb.v_google_distance as
select
jsonb_extract_path_text(google_result, 'status') as google_status,
    ((jsonb_extract_path_text(google_result, 'rows','0', 'elements','0','distance', 'value'))::numeric / 1000)::numeric(30,1) as google_distance,
jsonb_extract_path_text(google_result, 'rows','0', 'elements','0','duration', 'value') as google_duration,
* from mfaglb.google_distance;



create or replace function imports.calculate_route_deviation(_client_id text)
returns void as
$BODY$
declare
  mysql text;
begin
    mysql = format($QQ$
    update %1$s.fleet_data tgt
    set (routevar, routevarcost, routescore) = (src._routevar, src._routevarcost, src._routescore)
    from (
        select
        distance ,  google_distance,
        case when distance - google_distance < 0 or google_distance <= 5 or distance <= 10 then 0 else distance - google_distance end as _routevar,
        case when distance - google_distance < 0 or google_distance <= 5 or distance <= 10 then 0 else (distance - google_distance)*cpk end as _routevarcost,
        case when distance - google_distance < 0 or google_distance <= 5 or distance <= 10 then 100 else 100 - (((distance - google_distance)/distance)*100)::numeric(30,2) end as _routescore,
        * from mfaglb.v_google_distance
        join %1$s.fleet_data
        using (startlat, startlon, endlat, endlon)
        where coalesce(google_status,'') = 'OK'
    ) src
    where tgt.rowid = src.rowid;
    $QQ$ , lower(_client_id));
    execute mysql;
end;
$BODY$
language plpgsql;
