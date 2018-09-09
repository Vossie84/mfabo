/*
-- once off script
-- foreign data server setup from crunch server
CREATE EXTENSION IF NOT EXISTS plpgsql;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS file_fdw;
CREATE EXTENSION IF NOT EXISTS postgres_fdw;


drop  server crunch_server cascade;
CREATE SERVER crunch_server
   FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host '127.0.0.1',port '5495',dbname 'mfa_crunch');


-- give user acces from fleetdb to crunch server

CREATE USER MAPPING
   FOR postgres
   SERVER crunch_server
  OPTIONS (user 'postgres',password 'masterkey');

*/





----- fleet db
--DROP SCHEMA if EXISTS fleet cascade;
--DROP SCHEMA if EXISTS crunch cascade;
CREATE SCHEMA IF NOT EXISTS fleet;
CREATE SCHEMA IF NOT EXISTS crunch;
--
-- CREATE EXTENSION IF NOT EXISTS plpgsql;
-- CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- CREATE EXTENSION IF NOT EXISTS file_fdw;
-- CREATE EXTENSION IF NOT EXISTS postgres_fdw;



-------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------          LOCAL DB TABLES          ----------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

-- table for aggreagated data pushed from crunch server
CREATE TABLE IF NOT EXISTS fleet.trip_data
(
    vehiclereg    TEXT      NOT NULL,
    vehiclealias  TEXT,
    vehiclegroup  TEXT,
    cpk           NUMERIC(30, 2) DEFAULT 0.00,
    lper100       NUMERIC(30, 2) DEFAULT 0.00,
    tripstart     TIMESTAMP NOT NULL,
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
    speed0event   INTEGER []     DEFAULT ARRAY [] :: INTEGER [],
    speed0dur     INTEGER        DEFAULT 0,
    speed0cost    NUMERIC(30, 2) DEFAULT 0.00,
    speed1count   INTEGER        DEFAULT 0,
    speed1event   INTEGER []     DEFAULT ARRAY [] :: INTEGER [],
    speed1dur     INTEGER        DEFAULT 0,
    speed1cost    NUMERIC(30, 2) DEFAULT 0.00,
    speed2count   INTEGER        DEFAULT 0,
    speed2event   INTEGER []     DEFAULT ARRAY [] :: INTEGER [],
    speed2dur     INTEGER        DEFAULT 0,
    speed2cost    NUMERIC(30, 2) DEFAULT 0.00,
    speed3count   INTEGER        DEFAULT 0,
    speed3event   INTEGER []     DEFAULT ARRAY [] :: INTEGER [],
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
    rowid         BIGSERIAL NOT NULL,
    CONSTRAINT trip_data_pkey
    PRIMARY KEY (vehiclereg, tripstart)
);


-- table for weigh data pushed from crunch server
CREATE TABLE IF NOT EXISTS fleet.weigh_data
(
    vehiclereg   TEXT,
    weigh_date   DATE,
    weigh_amount NUMERIC(10, 5)
);


CREATE TABLE IF NOT EXISTS fleet.cid
(
  client_id text
);
truncate fleet.cid ;
insert into fleet.cid values (upper('<<CLIENTID>>'));


CREATE TABLE IF NOT EXISTS fleet.bi_data (
    vehiclereg      TEXT,
    bi_date         DATE,
    bi_speed        NUMERIC(30, 2),
    bi_acceleration NUMERIC(30, 2),
    bi_deceleration NUMERIC(30, 2),
    bi_cornering    NUMERIC(30, 2),
    bi_afterhours   NUMERIC(30, 2),
    bi_total        NUMERIC(30, 2),
    CONSTRAINT pk_bi_data
    PRIMARY KEY (vehiclereg, bi_date)
);


-------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------          FOREIGN TABLES TO CRUNCH          ------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

DROP SCHEMA IF EXISTS crunch CASCADE;
CREATE SCHEMA crunch;
IMPORT FOREIGN SCHEMA mfaglb LIMIT TO (clients)
    FROM SERVER crunch_server INTO crunch;
IMPORT FOREIGN SCHEMA <<LCLIENTID>> LIMIT TO (fleet_data, weigh_data)
    FROM SERVER crunch_server INTO crunch;


-------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------          API FUNCTIONS          -----------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
--dashboard data
CREATE OR REPLACE FUNCTION fleet.get_dashboard_data_v1(myvars json)
  RETURNS json AS
$BODY$
DECLARE
  varrec record;
  summary_json json;
  bi_json json;
  route_deviation_json json;
  distance_json json;
  client_json json;
  result_json json;
  banner_json json;
  weigh_json json;
  clientrec record;
BEGIN
    -- parse json paramaters into record sturcture;
    WITH client_data AS (
        SELECT *
        FROM fleet.v_clients
    )
    SELECT *
    FROM client_data
        LEFT JOIN LATERAL (SELECT *
                           FROM jsonb_to_record(client_data.dashboard_config) AS x (weigh_data BOOLEAN, route_deviation BOOLEAN) ) AS dash_config
            ON TRUE
        LEFT JOIN LATERAL (SELECT *
                           FROM jsonb_to_record(client_data.import_config) AS x (import_weigh_data BOOLEAN, calculate_route_deviation BOOLEAN) ) AS import_config
            ON TRUE
    INTO clientrec;





    select * from json_to_record(myvars) as jvar
        (from_date timestamp , to_date timestamp, month_factor integer)
        into varrec;



    select (varrec.to_date::date - varrec.from_date::date) + 1 into varrec.month_factor;

    -- top levele banner data
	select json_build_object('banner_data', row_to_json(x.*)) from (
	select
	sum(distance) as total_distance,
	sum(tripcost) as total_cost,
	concat(coalesce(sum(tripdur),0), ' seconds')::interval as total_duration,
	concat(coalesce(sum(speeddur),0), ' seconds')::interval as total_speed_duration,
	sum(stylecost-brakecost-steeringcost) as total_speed_cost,
	concat(coalesce(sum(standstill),0), ' seconds')::interval as total_idle_time,
	count(*) filter (where tripdur >= 7200 or distance >= 150 ) as total_high_risk,
	sum(distance) filter (where
    (to_char(tripstart,'D')::integer in (3,4,5) and (tripstart::time >= '18:00' or tripstart::time <= '06:00')) or
    (       ((to_char(tripstart,'D')::integer = 6) and (tripstart::time >= '18:00')) or (to_char(tripstart,'D')::integer in (1,7))  or ((to_char(tripstart,'D')::integer = 2) and (tripstart::time <= '06:00'))       )
  )
 as total_after_hours_distance,
	sum(tripcost) filter (where
    (to_char(tripstart,'D')::integer in (3,4,5) and (tripstart::time >= '18:00' or tripstart::time <= '06:00')) or
    (       ((to_char(tripstart,'D')::integer = 6) and (tripstart::time >= '18:00')) or (to_char(tripstart,'D')::integer in (1,7))  or ((to_char(tripstart,'D')::integer = 2) and (tripstart::time <= '06:00'))       )
  )
as total_after_hours_cost,
	sum(routevar) as total_deviation_distance,
	sum(routevarcost) as total_deviation_cost
	 from fleet.trip_data
        WHERE tripstart >= varrec.from_date AND tripstart <= varrec.to_date
	 ) as x    into banner_json;



    -- summary data used for doughnuts / dials on dahsboard
    WITH summary_data AS (
        SELECT
            -- behavioral index stats
            avg(stylescore) :: NUMERIC(30, 2)                                                                               AS bi_score,
            sum(stylecost) :: NUMERIC(30, 2)                                                                                AS bi_cost,
            ((sum(stylecost::numeric)/varrec.month_factor) *26) :: NUMERIC(30, 2)                                           AS projected_bi_cost_month,
            ((sum(stylecost::numeric)/varrec.month_factor) * 26 *12) :: NUMERIC(30, 2)                                      AS projected_bi_cost_year,

            -- route variation / deviation stats
            sum(distance) :: NUMERIC(30, 2)                                                                                 AS total_distance,
            sum(routevar) :: NUMERIC(30, 2)                                                                                 AS total_rv,
            avg(routescore)::numeric(30,2)                                                                                  AS rv_score,
            sum(routevarcost) :: NUMERIC(30, 2)                                                                             AS rv_cost,
            ((sum(routevarcost)/varrec.month_factor ) *26) :: NUMERIC(30, 2)                                                AS projected_rv_cost_month,
            ((sum(routevarcost)/varrec.month_factor ) * 26 *12) :: NUMERIC(30, 2)                                           AS projected_rv_cost_year,

            --fleaathealth / total_running costs
            ((avg(stylescore) :: NUMERIC(30, 2) + avg(routescore) :: NUMERIC(30, 2)) / 2)::numeric(30,2)                    AS fleet_health,
            sum(tripcost)::numeric(30,2)                                                             AS running_cost_total,
            ((sum(tripcost)::numeric/varrec.month_factor) *26) :: NUMERIC(30, 2)                     AS projected_running_cost_month,
            ((sum(tripcost)::numeric/varrec.month_factor) * 26 *12) :: NUMERIC(30, 2)                AS projected_running_cost_year,

            coalesce((select sum(weigh_amount) from fleet.weigh_data where weigh_date >= varrec.from_date AND weigh_date <= varrec.to_date),0) as total_weigh_amount
            --(select sum(weigh_amount) from fleet.weigh_data where weigh_date >= '2018-01-25 00:00:00' AND weigh_date <= '2018-01-25 00:00:00') as total_weigh_amount
        FROM fleet.trip_data
        --WHERE tripstart >= '2018-01-25 00:00:00' AND tripstart <= '2018-01-25 23:59:59'
        WHERE tripstart >= varrec.from_date AND tripstart <= varrec.to_date
    ),
    weight as (
	with kg as (
	select
	vehiclereg ,
	sum(weigh_amount)*1000 as total_kgs from fleet.weigh_data  where weigh_date >= varrec.from_date AND weigh_date <= varrec.to_date
	group by vehiclereg
	)
	, tc as (
	select
	vehiclereg ,
	sum(tripcost) as total_tripcost
	from
	fleet.trip_data where tripstart >= varrec.from_date AND tripstart <= varrec.to_date
	group by vehiclereg
	)

	select sum(total_tripcost) as total_tripcost, sum(total_kgs) as total_kgs, (sum(total_tripcost) / sum(total_kgs))::numeric(30,2) as cost_per_kg
	from kg
	join
	tc
	using (vehiclereg)
     )
     , summ as  (
     select * from summary_data left join lateral (select * from weight) ff on true
     )
    SELECT json_build_object('summary_data', row_to_json(summ.*))
    FROM summ
    INTO summary_json;



    -- distance travelled
    with distance_data as
    (
        with aa as (
        SELECT
	    vehiclereg,
            concat(vehiclereg,'-',vehiclealias) as vehiclename,
            sum(distance) :: NUMERIC(30, 2)                                                                                  AS total_distance,
coalesce(sum(distance) filter (where
    (to_char(tripstart,'D')::integer in (3,4,5) and (tripstart::time >= '18:00' or tripstart::time <= '06:00')) or
    (       ((to_char(tripstart,'D')::integer = 6) and (tripstart::time >= '18:00')) or (to_char(tripstart,'D')::integer in (1,7))  or ((to_char(tripstart,'D')::integer = 2) and (tripstart::time <= '06:00'))       )
  ), 0.00) as after_hour_distance
        FROM fleet.trip_data
        --WHERE tripstart >= '2018-02-26 00:00:00' AND tripstart <= '2018-02-26 23:59:59'
        WHERE tripstart >= varrec.from_date AND tripstart <= varrec.to_date
        GROUP BY vehiclereg,vehiclename
        ORDER BY vehiclereg,vehiclename)
        select * , total_distance - coalesce(after_hour_distance,0.00) as work_hour_distance from aa
    )
    select
        json_build_object(
            'distance_data', json_agg(
                                row_to_json(distance_data.*)
                              )
        )
    from distance_data into distance_json;


    -- top 10 route deviation vehicles
    with route_deviation_data as
    (
        SELECT
	    vehiclereg,
            concat(vehiclereg,'-',vehiclealias) as vehiclename,
            avg(routescore) :: NUMERIC(30, 2)                                                                                 AS rv_score,
            sum(routevar) :: NUMERIC(30, 2)                                                                                   AS rv_distance
        FROM fleet.trip_data
        --WHERE tripstart >= '2018-01-25 00:00:00' AND tripstart <= '2018-01-25 23:59:59'
        WHERE tripstart >= varrec.from_date AND tripstart <= varrec.to_date
        GROUP BY vehiclereg,vehiclename
        ORDER BY vehiclereg,vehiclename,rv_score
    )
    select
        json_build_object(
            'route_deviation_data', json_agg(
                                row_to_json(route_deviation_data.*)
                              )
        )
    from route_deviation_data into route_deviation_json;


    with bi_data as
    (
        SELECT
	    vehiclereg,
            concat(vehiclereg,'-',vehiclealias) as vehiclename,
            avg(stylescore) :: NUMERIC(30, 2)                                                                                AS bi_score
        FROM fleet.trip_data
        --WHERE tripstart >= '2018-03-08 00:00:00' AND tripstart <= '2018-03-08 23:59:59'
        WHERE tripstart >= varrec.from_date AND tripstart <= varrec.to_date
        GROUP BY vehiclereg,vehiclename
        ORDER BY vehiclereg, vehiclename
    )
    select
        json_build_object(
            'bi_data', json_agg(
                                row_to_json(bi_data.*)
                              )
        )
    from bi_data
    where bi_score <> 100
    into bi_json;


    WITH client_data AS (
        SELECT
            client_name,client_id,addr1,addr2,
            addr3,addr4,city,province,
            postcode,country,companytel,contactemail,
            contactname,contactcellno,pushemail
        FROM fleet.v_clients
    )
    SELECT
    json_build_object(
            'customer_data' , row_to_json(client_data.*) )
    FROM client_data
    INTO client_json;


    with weigh_data as
    (
        SELECT
	    vehiclereg,

            sum(weigh_amount)as weigh_amount
        FROM fleet.weigh_data
        --WHERE weigh_date >= '2018-01-25 00:00:00' AND weigh_date <= '2018-01-25 23:59:59'
        WHERE weigh_date >= varrec.from_date AND weigh_date <= varrec.to_date
        GROUP BY vehiclereg
        ORDER BY vehiclereg
    )
    select
        json_build_object(
            'weigh_data', coalesce(json_agg(
                                row_to_json(weigh_data.*)
                              ),'[{"weigh_amount":0}]')
        )
    from weigh_data into weigh_json;



    if summary_json->'summary_data'->>'bi_cost' is not null then

        result_json = json_build_object('result', true);
        -- concatenate json strings and send it back

        RETURN (SELECT result_json :: JSONB ||
		       summary_json :: JSONB ||
		       distance_json :: JSONB ||
		       route_deviation_json :: JSONB ||
		       bi_json :: JSONB ||
		       client_json::JSONB ||
		       banner_json::jsonb ||
		       weigh_json::jsonb) :: JSON;

    else
        result_json = (jsonb_build_object('result', false) || client_json::JSONB)::json;
        return result_json;
    end if;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


-- drill down data
CREATE OR REPLACE FUNCTION fleet.get_level1_data_v1(myvars json)
  RETURNS json AS
$BODY$
DECLARE
  varrec record;
  summary_json json;
  bi_json json;
  route_deviation_json json;
  distance_json json;
  var_json json;
  result_json json;

BEGIN
    -- parse json paramaters into record sturcture;
    select * from json_to_record(myvars) as jvar
        (from_date timestamp , to_date timestamp, vehiclereg text, month_factor integer)
    into varrec;

    select (varrec.to_date::date - varrec.from_date::date) + 1 into varrec.month_factor;

    select
    json_build_object('variable_data' ,
    to_json(varrec.*))  into var_json;

    -- summary data used for doughnuts / dials on dahsboard
    WITH summary_data AS (
        SELECT
            -- behavioral index stats
            avg(stylescore) :: NUMERIC(30, 2)                                                                               AS bi_score,
            sum(stylecost) :: NUMERIC(30, 2)                                                                                AS bi_cost,
            ((sum(stylecost::numeric)/varrec.month_factor) *26) :: NUMERIC(30, 2)                                           AS projected_bi_cost_month,
            ((sum(stylecost::numeric)/varrec.month_factor) * 26 *12) :: NUMERIC(30, 2)                                      AS projected_bi_cost_year,

            -- route variation / deviation stats
            sum(distance) :: NUMERIC(30, 2)                                                                                 AS total_distance,
            sum(routevar) :: NUMERIC(30, 2)                                                                                 AS total_rv,
            avg(routescore)::numeric(30,2)                                                                                  AS rv_score,
            sum(routevarcost) :: NUMERIC(30, 2)                                                                             AS rv_cost,
            ((sum(routevarcost)/varrec.month_factor ) *26) :: NUMERIC(30, 2)                                                AS projected_rv_cost_month,
            ((sum(routevarcost)/varrec.month_factor ) * 26 *12) :: NUMERIC(30, 2)                                           AS projected_rv_cost_year,

            --fleaathealth / total_running costs
            ((avg(stylescore) :: NUMERIC(30, 2) + avg(routescore) :: NUMERIC(30, 2)) / 2)::numeric(30,2)                    AS fleet_health,
            sum(tripcost+routevarcost+stylecost)::numeric(30,2)                                                             AS running_cost_total,
            ((sum(tripcost+routevarcost+stylecost)::numeric/varrec.month_factor) *26) :: NUMERIC(30, 2)                     AS projected_running_cost_month,
            ((sum(tripcost+routevarcost+stylecost)::numeric/varrec.month_factor) * 26 *12) :: NUMERIC(30, 2)                AS projected_running_cost_year
        FROM fleet.trip_data
        --WHERE tripstart >= '2018-01-25 00:00:00' AND tripstart <= '2018-01-25 23:59:59' AND vehiclereg = ' Susan - Highveld Region'
        WHERE tripstart >= varrec.from_date AND tripstart <= varrec.to_date and vehiclereg = varrec.vehiclereg
    )
    SELECT json_build_object('summary_data', row_to_json(summary_data.*))
    FROM summary_data
    INTO summary_json;

    -- summary data used for doughnuts / dials on dahsboard
    WITH summary_data AS (
        SELECT
            -- behavioral index stats
            avg(stylescore) :: NUMERIC(30, 2)                                                                               AS bi_score,
            sum(stylecost) :: NUMERIC(30, 2)                                                                                AS bi_cost,
            ((sum(stylecost::numeric)/varrec.month_factor) *26) :: NUMERIC(30, 2)                                           AS projected_bi_cost_month,
            ((sum(stylecost::numeric)/varrec.month_factor) * 26 *12) :: NUMERIC(30, 2)                                      AS projected_bi_cost_year,

            -- route variation / deviation stats
            sum(distance) :: NUMERIC(30, 2)                                                                                 AS total_distance,
            sum(routevar) :: NUMERIC(30, 2)                                                                                 AS total_rv,
            avg(routescore)::numeric(30,2)                                                                                  AS rv_score,
            sum(routevarcost) :: NUMERIC(30, 2)                                                                             AS rv_cost,
            ((sum(routevarcost)/varrec.month_factor ) *26) :: NUMERIC(30, 2)                                                AS projected_rv_cost_month,
            ((sum(routevarcost)/varrec.month_factor ) * 26 *12) :: NUMERIC(30, 2)                                           AS projected_rv_cost_year,

            --fleaathealth / total_running costs
            ((avg(stylescore) :: NUMERIC(30, 2) + avg(routescore) :: NUMERIC(30, 2)) / 2)::numeric(30,2)                    AS fleet_health,
            sum(tripcost)::numeric(30,2)                                                             AS running_cost_total,
            ((sum(tripcost)::numeric/varrec.month_factor) *26) :: NUMERIC(30, 2)                     AS projected_running_cost_month,
            ((sum(tripcost)::numeric/varrec.month_factor) * 26 *12) :: NUMERIC(30, 2)                AS projected_running_cost_year,

            coalesce((select sum(weigh_amount) from fleet.weigh_data where weigh_date >= varrec.from_date AND weigh_date <= varrec.to_date ),0) as total_weigh_amount,
            coalesce((select sum(weigh_amount) from fleet.weigh_data where weigh_date >= varrec.from_date AND weigh_date <= varrec.to_date and vehiclereg = varrec.vehiclereg),0) as vehicle_weigh_amount
            --(select sum(weigh_amount) from fleet.weigh_data where weigh_date >= '2018-01-25 00:00:00' AND weigh_date <= '2018-01-25 00:00:00') as total_weigh_amount
        FROM fleet.trip_data
        --WHERE tripstart >= '2018-01-25 00:00:00' AND tripstart <= '2018-01-25 23:59:59'
        WHERE tripstart >= varrec.from_date AND tripstart <= varrec.to_date and vehiclereg = varrec.vehiclereg
    ),
    weight as (
	with kg as (
	select
	vehiclereg ,
	sum(weigh_amount) over () as vehicletotal_kgs ,
	weigh_amount*1000 as total_kgs
	from fleet.weigh_data
	where weigh_date >= varrec.from_date AND weigh_date <= varrec.to_date  and vehiclereg = varrec.vehiclereg
	)
	, tc as (
	select
	vehiclereg ,
	sum(tripcost) as total_tripcost
	from
	fleet.trip_data where tripstart >= varrec.from_date AND tripstart <= varrec.to_date
	group by vehiclereg
	)

	select sum(total_tripcost) as total_tripcost, sum(total_kgs) as total_kgs, (sum(total_tripcost) / sum(total_kgs))::numeric(30,2) as cost_per_kg
	from kg
	join
	tc
	using (vehiclereg)
     )
     , summ as  (
     select * from summary_data left join lateral (select * from weight) ff on true
     )
    SELECT json_build_object('summary_data', row_to_json(summ.*))
    FROM summ
    INTO summary_json;




    -- distance travelled
    with distance_chart as (
        SELECT
            row_number()  OVER ( ORDER BY tripstart ),
            distance::numeric(30,2) as actual_distance,
            routevar::numeric(30,2) as deviation_distance,
case when  (to_char(tripstart,'D')::integer in (3,4,5) and (tripstart::time >= '18:00' or tripstart::time <= '06:00')) or
    (       ((to_char(tripstart,'D')::integer = 6) and (tripstart::time >= '18:00')) or (to_char(tripstart,'D')::integer in (1,7))  or ((to_char(tripstart,'D')::integer = 2) and (tripstart::time <= '06:00'))       )
then true else false end as after_hour_trip,
            json_object(
                    ARRAY ['start_end_time', 'tripcost', 'style'],
                    ARRAY [format('%s to %s', tripstart :: TIME,tripend :: TIME), tripcost :: NUMERIC(30, 2) :: TEXT,
                           format('Style Score : %s , Style Cost : %s', stylescore :: NUMERIC(30, 2),stylecost :: NUMERIC(30, 2))
                    ]
              ) as tooltip_data
        FROM fleet.trip_data
        --WHERE tripstart >= '2018-01-25 00:00:00' AND tripstart <= '2018-01-25 23:59:59' AND vehiclereg = ' Susan - Highveld Region'
        WHERE tripstart >= varrec.from_date AND tripstart <= varrec.to_date and vehiclereg = varrec.vehiclereg
        ORDER BY tripstart
    )
    select
        json_build_object(
            'distance_data', json_agg(
                                row_to_json(distance_chart.*)
                              )
        )
    from distance_chart into distance_json;

--select * from fleet.trip_data
    -- bi data
    WITH bi_data AS (
        SELECT
            speeddur as speedduration, speedcount as speedevents,
            --string_to_array(speed0dur, ',') || string_to_array(speed1dur, ',') || string_to_array(speed2dur, ',') ||string_to_array(speed3dur, ',')                                   AS speedduration,
            --coalesce(array_length(string_to_array(speed0dur, ',') || string_to_array(speed1dur, ',') ||string_to_array(speed2dur, ',') || string_to_array(speed3dur, ','), 1), 0)     AS speedevents,
            *
        FROM fleet.trip_data
--             LEFT JOIN LATERAL
--                       (SELECT sum(ff)
--                        FROM (SELECT unnest(string_to_array(speed0dur, ',') || string_to_array(speed1dur, ',') ||string_to_array(speed2dur, ',') ||string_to_array(speed3dur, ',')) :: INTEGER ff) b
--                       ) AS x (total_speed_duration )
--                 ON TRUE
        --WHERE tripstart >= '2018-01-25 00:00:00' AND tripstart <= '2018-01-25 23:59:59' AND vehiclereg = ' Susan - Highveld Region'
        WHERE tripstart >= varrec.from_date AND tripstart <= varrec.to_date and vehiclereg = varrec.vehiclereg

    )
    select
        json_build_object(
            'bi_data',
                json_build_object(
                    'brake_events',  sum(brakeevent) ,
                    'steering_events',  sum(steeringevent),
                    'speed_events',  sum(speedevents)
                )
        )
    FROM bi_data into bi_json;

    with deviation_data as (
        SELECT
            sum(distance) :: NUMERIC(30, 2) AS total_actual_distance,
            sum(routevar) :: NUMERIC(30, 2) AS total_deviation_distance
        from fleet.trip_data
        --WHERE tripstart >= '2018-01-25 00:00:00' AND tripstart <= '2018-01-25 23:59:59' AND vehiclereg = ' Susan - Highveld Region'
        WHERE tripstart >= varrec.from_date AND tripstart <= varrec.to_date and vehiclereg = varrec.vehiclereg
    )
    select
        json_build_object(
            'deviation_data',
                json_build_object(
                    'total_actual_distance',  total_actual_distance ,
                    'total_deviation_distance',  total_deviation_distance
                )
        )
    FROM deviation_data into route_deviation_json;


    if summary_json->'summary_data'->>'bi_cost' is not null then
            result_json = json_build_object('result', true);
	    -- concatenate json strings and send it back
	    RETURN (SELECT summary_json :: JSONB ||
			   distance_json :: JSONB ||
			   route_deviation_json :: JSONB ||
			   bi_json :: JSONB ||
			   var_json :: JSONB
			   ) :: JSON;

    else
        result_json = json_build_object('result', false);
        return result_json;
    end if;



END;
$BODY$
  LANGUAGE plpgsql VOLATILE;


--select * from fleet.get_dashboard_data_v1('{"from_date":"2018-03-08 00:00:00", "to_date":"2018-03-08 23:59:59"}');
--select * from fleet.get_level1_data_v1('{"from_date":"2018-03-08 00:00:00", "to_date":"2018-03-08 23:59:59", "vehiclereg":"BJX423L"}');




-------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------          VIEWS          ---------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

create or replace view fleet.v_clients as
select * from crunch.clients
join fleet.cid using (client_id);












/***********************************************************************************************************************

 INSERTS DATA FROM MFA CRUNCH DATABASE

 Gets Client Record

  Checks import config json to see what needs to be imported
  -- weigh data

***********************************************************************************************************************/


create or replace function fleet.push_import(myvars jsonb)
returns void as
$$
DECLARE
    clientrec    RECORD;
    max_steps    INTEGER;
    current_step INTEGER;
BEGIN
    max_steps = 3;
    current_step = 1;

    RAISE NOTICE '[PB][%,%] Client Config', current_step, max_steps;
    current_step = current_step + 1;

    WITH client_data AS (
        SELECT *
        FROM fleet.v_clients
    )
    SELECT *
    FROM client_data
        LEFT JOIN LATERAL (SELECT *
                           FROM jsonb_to_record(client_data.dashboard_config) AS x (weigh_data BOOLEAN, route_deviation BOOLEAN) ) AS dash_config
            ON TRUE
        LEFT JOIN LATERAL (SELECT *
                           FROM jsonb_to_record(client_data.import_config) AS x (import_weigh_data BOOLEAN, calculate_route_deviation BOOLEAN) ) AS import_config
            ON TRUE
    INTO clientrec;

    RAISE NOTICE '[PB][%,%] Inserting Fleet data', current_step, max_steps;
    current_step = current_step + 1;

    INSERT INTO fleet.trip_data (
        vehiclereg, vehiclealias, vehiclegroup, cpk, lper100, tripstart,
        tripend, tripdur, standstill, startodo, endodo, distance, tripcost,
        brakeevent, brakecost, steeringevent, steeringcost, speed0count,
        speed0event, speed0dur, speed0cost, speed1count, speed1event,
        speed1dur, speed1cost, speed2count, speed2event, speed2dur, speed2cost,
        speed3count, speed3event, speed3dur, speed3cost, speedcount,
        speeddur, speedcost, stylescore, stylecost, startloc, endloc,
        startlat, startlon, endlat, endlon, routevar, routevarcost, routescore,
        driver, tripnr, riskfactor)
        SELECT
            vehiclereg,vehiclealias,vehiclegroup,cpk,lper100,tripstart,
            tripend,tripdur,standstill,startodo,endodo,distance,tripcost,
            brakeevent,brakecost,steeringevent,steeringcost,
            speed0count,speed0event,speed0dur,speed0cost,
            speed1count,speed1event,speed1dur,speed1cost,
            speed2count,speed2event,speed2dur,speed2cost,
            speed3count,speed3event,speed3dur,speed3cost,
            speedcount,speeddur,speedcost,stylescore,stylecost,
            startloc,endloc,startlat,startlon,endlat,endlon,routevar,
            routevarcost,routescore,driver,tripnr,riskfactor
        FROM crunch.fleet_data
    ON CONFLICT (vehiclereg, tripstart)
        DO NOTHING;


    RAISE NOTICE '[PB][%,%] Inserting Weigh Data', current_step, max_steps;
    current_step = current_step + 1;
    IF clientrec.import_weigh_data THEN
        INSERT INTO fleet.weigh_data
            SELECT *
            FROM crunch.weigh_data
                LEFT JOIN fleet.weigh_data rt
                USING (vehiclereg, weigh_date, weigh_amount)
            WHERE rt.vehiclereg IS NULL;
    END IF;



END;
$$
LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION fleet.get_tracker_dashboard_data_v1(myvar JSONB)
    RETURNS JSONB AS
$BODY$
DECLARE
    varrec      RECORD;
    client_json JSONB;
    result_json JSONB;
    banner_json JSONB;
    dial_json   JSONB;
    best_json   JSONB;
    worst_json  JSONB;
    risk_json   JSONB;
BEGIN

    SELECT *
    FROM jsonb_to_record(myvar) AS jvar
         (from_date TIMESTAMP, to_date TIMESTAMP)
    INTO varrec;


    WITH banner AS (
        SELECT
            sum(distance) :: NUMERIC(30, 2)                AS total_distance,
            sum(tripcost) :: NUMERIC(30, 2)                AS total_cost,
            concat(coalesce(sum(tripdur),0), ' seconds')::interval                                   AS total_duration,

            concat(coalesce(sum(speeddur),0), ' seconds')::interval                                  AS total_speed_duration,
            sum(speedcost) :: NUMERIC(30, 2)               AS total_speed_cost,

            concat(coalesce(sum(standstill),0), ' seconds')::interval                                AS total_standstil_duration,

            coalesce(count(rowid)
                         FILTER (WHERE tripdur > 7200), 0) AS total_high_risk_trips,

            coalesce(sum(distance)
                         FILTER (WHERE
                             (to_char(tripstart, 'D') :: INTEGER IN (3, 4, 5) AND (tripstart :: TIME >= '18:00' OR tripstart :: TIME <= '06:00')) OR
                             (((to_char(tripstart, 'D') :: INTEGER = 6) AND (tripstart :: TIME >= '18:00')) OR (to_char(tripstart, 'D') :: INTEGER IN (1, 7)) OR
                              ((to_char(tripstart, 'D') :: INTEGER = 2) AND (tripstart :: TIME <= '06:00')))
                         ), 0)                             AS total_after_hour_distance,

            concat(coalesce(sum(tripdur)
                         FILTER (WHERE
                             (to_char(tripstart, 'D') :: INTEGER IN (3, 4, 5) AND (tripstart :: TIME >= '18:00' OR tripstart :: TIME <= '06:00')) OR
                             (((to_char(tripstart, 'D') :: INTEGER = 6) AND (tripstart :: TIME >= '18:00')) OR (to_char(tripstart, 'D') :: INTEGER IN (1, 7)) OR
                              ((to_char(tripstart, 'D') :: INTEGER = 2) AND (tripstart :: TIME <= '06:00')))
                         ),0), ' seconds')::interval                             AS total_after_hour_duration,

            sum(routevar)                                  AS total_route_deviation_distance,
            sum(routevarcost)                              AS total_route_deviation_cost
        FROM fleet.trip_data
        WHERE tripstart >= varrec.from_date AND tripstart <= varrec.to_date
    )
    SELECT jsonb_build_object(
        'banner_data',
        row_to_json(banner.*)

    )
    FROM banner
    INTO banner_json;

    -- guage stuff
    WITH dials AS (
        SELECT
            avg(bi_speed) :: NUMERIC(30, 2)        AS bi_speed,
            avg(bi_acceleration) :: NUMERIC(30, 2) AS bi_acceleration,
            avg(bi_deceleration) :: NUMERIC(30, 2) AS bi_deceleration,
            avg(bi_cornering) :: NUMERIC(30, 2)    AS bi_cornering,
            avg(bi_afterhours) :: NUMERIC(30, 2)   AS bi_afterhours,
            avg(bi_total) :: NUMERIC(30, 2)        AS bi_total
        FROM fleet.bi_data
        WHERE bi_date >= varrec.from_date AND bi_date <= varrec.to_date
    )
    SELECT jsonb_build_object(
        'dial_data',
        row_to_json(dials.*)
    )
    FROM dials
    INTO dial_json;

    --best
    WITH best AS (
        SELECT
            vehiclereg,
            avg(bi_total) :: NUMERIC(30, 2) AS bi_total
        FROM fleet.bi_data
        WHERE bi_date >= varrec.from_date AND bi_date <= varrec.to_date
        GROUP BY vehiclereg
        ORDER BY bi_total DESC
        LIMIT 10
    )
    SELECT jsonb_build_object(
        'best_vehicles', json_agg(
            row_to_json(best.*)
        )
    )
    FROM best
    INTO best_json;

    -- worst
    WITH worst AS (
        SELECT
            vehiclereg,
            avg(bi_total) :: NUMERIC(30, 2) AS bi_total
        FROM fleet.bi_data
        WHERE bi_date >= varrec.from_date AND bi_date <= varrec.to_date
        GROUP BY vehiclereg
        ORDER BY bi_total
        LIMIT 10
    )
    SELECT jsonb_build_object(
        'worst_vehicles', json_agg(
            row_to_json(worst.*)
        )
    )
    FROM worst
    INTO worst_json;


    WITH
            speed AS (
            SELECT
                'Speeding' :: TEXT AS category,
                (SELECT row_to_json((vehiclereg, bi_speed))
                 FROM fleet.bi_data
                 WHERE bi_date >= varrec.from_date AND bi_date <= varrec.to_date
                 ORDER BY bi_speed DESC
                 LIMIT 1)          AS best,
                (SELECT row_to_json((vehiclereg, bi_speed))
                 FROM fleet.bi_data
                 WHERE bi_date >= varrec.from_date AND bi_date <= varrec.to_date
                 ORDER BY bi_speed
                 LIMIT 1)          AS worst
        )
        , acceleration AS (
        SELECT
            'Acceleration' :: TEXT AS category,
            (SELECT row_to_json((vehiclereg, bi_acceleration))
             FROM fleet.bi_data
             WHERE bi_date >= varrec.from_date AND bi_date <= varrec.to_date
             ORDER BY bi_acceleration DESC
             LIMIT 1)              AS best,
            (SELECT row_to_json((vehiclereg, bi_acceleration))
             FROM fleet.bi_data
             WHERE bi_date >= varrec.from_date AND bi_date <= varrec.to_date
             ORDER BY bi_acceleration
             LIMIT 1)              AS worst
    )
        , deceleration AS (
        SELECT
            'Deceleration' :: TEXT AS category,
            (SELECT row_to_json((vehiclereg, bi_deceleration))
             FROM fleet.bi_data
             WHERE bi_date >= varrec.from_date AND bi_date <= varrec.to_date
             ORDER BY bi_deceleration DESC
             LIMIT 1)              AS best,
            (SELECT row_to_json((vehiclereg, bi_deceleration))
             FROM fleet.bi_data
             WHERE bi_date >= varrec.from_date AND bi_date <= varrec.to_date
             ORDER BY bi_deceleration
             LIMIT 1)              AS worst
    )
        , bi_cornering AS (
        SELECT
            'Cornering' :: TEXT AS category,
            (SELECT row_to_json((vehiclereg, bi_cornering))
             FROM fleet.bi_data
             WHERE bi_date >= varrec.from_date AND bi_date <= varrec.to_date
             ORDER BY bi_cornering DESC
             LIMIT 1)           AS best,
            (SELECT row_to_json((vehiclereg, bi_cornering))
             FROM fleet.bi_data
             WHERE bi_date >= varrec.from_date AND bi_date <= varrec.to_date
             ORDER BY bi_cornering
             LIMIT 1)           AS worst
    )
        , bi_afterhours AS (
        SELECT
            'After Hours' :: TEXT AS category,
            (SELECT row_to_json((vehiclereg, bi_afterhours))
             FROM fleet.bi_data
             WHERE bi_date >= varrec.from_date AND bi_date <= varrec.to_date
             ORDER BY bi_afterhours DESC
             LIMIT 1)             AS best,
            (SELECT row_to_json((vehiclereg, bi_afterhours))
             FROM fleet.bi_data
             WHERE bi_date >= varrec.from_date AND bi_date <= varrec.to_date
             ORDER BY bi_afterhours
             LIMIT 1)             AS worst
    )
        , final AS (
        SELECT *
        FROM speed
        UNION ALL
        SELECT *
        FROM acceleration
        UNION ALL
        SELECT *
        FROM deceleration
        UNION ALL
        SELECT *
        FROM bi_cornering
        UNION ALL
        SELECT *
        FROM bi_afterhours
    )
    SELECT jsonb_build_object('risk_factors', jsonb_agg(row_to_json(final.*)))
    FROM final
    INTO risk_json;


    WITH client_data AS (
        SELECT
            client_name,
            client_id,
            addr1,
            addr2,
            addr3,
            addr4,
            city,
            province,
            postcode,
            country,
            companytel,
            contactemail,
            contactname,
            contactcellno,
            pushemail
        FROM fleet.v_clients
    )
    SELECT jsonb_build_object(
        'customer_data', row_to_json(client_data.*))
    FROM client_data
    INTO client_json;


    IF banner_json -> 'banner_data'->'total_distance' IS NOT NULL THEN

        result_json = jsonb_build_object('result', TRUE);
        -- concatenate json strings and send it back

        RETURN (SELECT client_json ||
                       result_json ||
                       banner_json ||
                       dial_json ||
                       best_json ||
                       worst_json ||
                       risk_json
        );

    ELSE
        result_json = (jsonb_build_object('result', FALSE) || client_json :: JSONB) :: JSON;
        RETURN result_json;
    END IF;


END;

$BODY$
LANGUAGE plpgsql;