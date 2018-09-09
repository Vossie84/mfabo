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