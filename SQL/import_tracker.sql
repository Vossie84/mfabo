drop foreign table if exists imports.tracker_trip_csv cascade;

ALTER FOREIGN TABLE imports.tracker_trip_csv
  OPTIONS (SET filename 'f:/temp/mfa/bre001/tracker_trip.csv');


CREATE FOREIGN TABLE if not exists imports.tracker_trip_csv (
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
OPTIONS ( filename 'f:/temp/mfa/tracker_trip.csv', format 'csv', delimiter ',' , quote '"', header 'true', encoding 'LATIN1');

drop view if exists imports.tracker_trip_pretty;
create or replace view imports.tracker_trip_pretty as
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
    FROM imports.tracker_trip_csv
    ORDER BY vehiclereg, tripnr, rtcdatetime;


DROP TABLE if exists imports.tracker_trip;
CREATE TABLE IF NOT EXISTS imports.tracker_trip
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

truncate imports.tracker_trip;
select * from mfaglb.client_config
select * from bre001.fleet_data
select imports.import_tracker_data('BRE001');




WITH formatted_data AS (
    SELECT *
    FROM imports.tracker_trip_pretty
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

 INSERT INTO imports.tracker_trip (
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
    FROM imports.tracker_trip_pretty
    --where vehicle_alias = 'robert sibisi'
    ORDER BY vehiclereg, tripnr, rtcdate, rtcdatetime
);


with risk_factor_data as (
select
vehiclereg, tripnr , eventdate,
coalesce(sum(EXTRACT(EPOCH FROM event_duration)::integer) filter (where status = 'stopped'),0)::integer as standstill,

coalesce(sum(EXTRACT(EPOCH FROM event_duration)::integer) filter (where status ilike '%harsh brake%'),0)::integer as tota_brake_event_duration,
coalesce(count(EXTRACT(EPOCH FROM event_duration)::integer) filter (where status ilike '%harsh brake%'),0)::integer as tota_brake_event_count,

coalesce(sum(EXTRACT(EPOCH FROM event_duration)::integer) filter (where status ilike '%over speed%'),0)::integer as total_speed_duration,
coalesce(count(EXTRACT(EPOCH FROM event_duration)::integer) filter (where status ilike '%over speed%'),0)::integer as total_speed_count,

coalesce(array_agg(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE speed < 130 and status ilike '%over speed%'),'{}')::integer[]                                                  AS speed0,
coalesce(sum(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE speed < 130  and status ilike '%over speed%') ,0)::integer                                 AS speed0_duration,
coalesce(count(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE speed < 130  and status ilike '%over speed%') ,0)::integer                       AS speed0_count,

coalesce(array_agg(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE (speed > 130 AND speed < 141) and status ilike '%over speed%'),'{}')::integer[]                            AS speed1,
coalesce(sum(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE (speed > 130 AND speed < 141) and status ilike '%over speed%'),0)::integer                            AS speed1_duration,
coalesce(count(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE (speed > 130 AND speed < 141) and status ilike '%over speed%'),0)::integer                            AS speed1_count,

coalesce(array_agg(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE (speed > 140 AND speed < 151) and status ilike '%over speed%'),'{}')::integer[]                            AS speed2,
coalesce(sum(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE (speed > 140 AND speed < 151)and status ilike '%over speed%'),0)::integer                            AS speed2_duration,
coalesce(count(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE (speed > 140 AND speed < 151)and status ilike '%over speed%'),0)::integer                            AS speed2_count,

coalesce(array_agg(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE speed > 150 and status ilike '%over speed%'),'{}')::integer[]                                                  AS speed3,
coalesce(sum(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE speed > 150 and status ilike '%over speed%'),0)::integer                                                  AS speed3_duration,
coalesce(count(EXTRACT(EPOCH FROM event_duration)::integer) FILTER (WHERE speed > 150 and status ilike '%over speed%'),0)::integer                                                  AS speed3_count
from tracker_events_data
group by
    vehiclereg, eventdate, tripnr
)
update imports.tracker_trip tgt
set
(
 speedcount, speeddur,standstill,
 speed0event, speed0count, speed0dur,
 speed1event, speed1count, speed1dur,
 speed2event, speed2count, speed2dur,
 speed3event, speed3count, speed3dur) =
 (
 src.total_speed_count, src.total_speed_duration,src.standstill,
 src.speed0, src.speed0_count, src.speed0_duration,
 src.speed1, src.speed1_count, src.speed1_duration,
 src.speed2, src.speed2_count, src.speed2_duration,
 src.speed3, src.speed3_count, src.speed3_duration)
from (
    SELECT
        vehiclereg,tripnr,eventdate,standstill,
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
where tgt.vehiclereg = src.vehiclereg and tgt.tripnr = src.tripnr and tgt.tripstart::date = src.eventdate
RETURNING *;


delete from imports.tracker_trip where coalesce(distance,0) = 0;

update imports.tracker_trip set vehiclereg = upper(vehiclereg), vehiclealias = upper(vehiclealias) , vehiclegroup = upper(vehiclegroup);



















CREATE or replace function mfaglb.calculate_risk_data(_client_id text)
returns void AS
$function$
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
                FROM imports.oemstats
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
    execute mysql;
END;
$function$
language plpgsql;





















select * from imports.tracker_trip
order by vehiclereg, tripstart;
