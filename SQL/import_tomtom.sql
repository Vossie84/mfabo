/*
  Created by Andries Vorster
  Create Date 2018-02-18

  Script that creates the imports schema
  -- used to import csv data and update the actual data.

 */

----------------------------------------------------------------------------------------------------------------------
------------------------------------------     Create Structure Section     ------------------------------------------
----------------------------------------------------------------------------------------------------------------------


CREATE FOREIGN TABLE if not exists imports.tomtomtrip_csv (
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
OPTIONS ( filename 'f:/temp/mfa/tomtomtrip.csv', format 'csv', delimiter ',' , quote '"', header 'true', encoding 'LATIN1');


CREATE FOREIGN TABLE if not exists imports.tomtomspeed_csv (
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
OPTIONS ( filename 'f:/temp/mfa/tomtomspeed.csv', format 'csv', delimiter ',' , quote '"', header 'true', encoding 'LATIN1');

CREATE FOREIGN TABLE if not exists imports.tomtomevents_csv (
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
OPTIONS ( filename 'f:/temp/mfa/tomtomevents.csv', format 'csv', delimiter ',' , quote '"', header 'true', encoding 'LATIN1');


CREATE TABLE IF NOT EXISTS imports.tomtomtrip
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

----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------     Import Section     -----------------------------------------------
----------------------------------------------------------------------------------------------------------------------
CREATE or replace function imports.import_tomtom_data(_client_id text)
returns void AS
$function$
declare
  mysql text;
BEGIN
    mysql = format($QQ$

    -- actual trip data....
    TRUNCATE %1$s.fleet_data;
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
        FROM imports.tomtomtrip_csv;



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

            to_timestamp(_date:: BIGINT / 1000)::date + '1 day'::interval + ((_start_time :: INTEGER) / 1000 * INTERVAL '1 second' )                                  AS _start_time,
            to_timestamp(_date:: BIGINT / 1000)::date + '1 day'::interval + ((_end_time :: INTEGER) / 1000 * INTERVAL '1 second' )                                  AS _end_time
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
                FILTER (WHERE _max_speed > 150)                                                  AS speed3,
            sum(_speed_duration::integer)
                FILTER (WHERE _max_speed > 150)                                                  AS speed3_duration
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

    execute mysql;


END;
$function$
language plpgsql;













CREATE or replace function imports.calculate_risk_tomtom_data()
returns void AS
$function$
BEGIN
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

        FROM imports.tomtomtrip
       -- WHERE vehiclereg ILIKE '%susan%' AND tripstart = '2018-01-18 16:12:00.000000'
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
        FROM imports.oemstats
      --  WHERE vehiclereg ILIKE '%susan%'
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

    UPDATE imports.tomtomtrip tgt
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
END;
$function$
language plpgsql;







select * from imports.tomtomtrip order by rowid