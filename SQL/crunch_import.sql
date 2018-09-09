/***********************************************************************************************************************

 IMPORTS CSV DATA INTO "STAGING" SCHEMA ON MFA CRUNCH DATABASE

 Gets Client Record
 Loops through client_providers array and executes neccescary functions


  Checks import config json to see what needs to be imported
  -- weigh data

  calculates risk data

  Params replace to run manually , gets sent through from MFABO app:
  <<CLIENTID>>  -- mfaglb.clients.client_id
***********************************************************************************************************************/


create or replace function mfaglb.crunch_import(myvars jsonb)
returns void as
$$
DECLARE
    clientrec RECORD;
    loopcount integer;
    _client_id text;
    max_steps integer;
    current_step integer;
    varrec record;
BEGIN
    select * from jsonb_to_record(myvars) as jvar
    (_client_id text)
    into varrec;

    max_steps = 8;
    current_step = 1;
    
    Raise notice '[PB][%,%] Client Config', current_step, max_steps;
    current_step = current_step + 1;

    WITH client_data AS (
        SELECT *
        FROM mfaglb.clients
        WHERE client_id = varrec._client_id
    )
    SELECT *
    FROM client_data
        LEFT JOIN LATERAL (SELECT * FROM jsonb_to_record(client_data.dashboard_config) AS x (weigh_data BOOLEAN, route_deviation BOOLEAN) ) AS dash_config ON TRUE
        LEFT JOIN LATERAL (SELECT * FROM jsonb_to_record(client_data.import_config) AS x (import_weigh_data BOOLEAN, calculate_route_deviation BOOLEAN) ) AS import_config ON TRUE
    INTO clientrec;

    Raise notice '[PB][%,%] Truncating Fleet Data', current_step, max_steps;
    current_step = current_step + 1;
    EXECUTE format('TRUNCATE %1$s.fleet_data;', varrec._client_id);

    Raise notice '[PB][%,%] Importing Fleet Data..', current_step, max_steps;
    current_step = current_step + 1;
    FOR loopcount IN 1 ..array_length(clientrec.client_providers, 1) LOOP
        RAISE NOTICE '%', clientrec.client_name;

        IF clientrec.client_providers [loopcount] = 'tracker' THEN
            Raise notice '[PB][%,%] Importing Fleet Data..Tracker', current_step, max_steps;
            current_step = current_step + 1;
            perform imports.import_tracker_data(varrec._client_id);
        END IF;

        IF clientrec.client_providers [loopcount] = 'tomtom' THEN
            Raise notice '[PB][%,%] Importing Fleet Data..TomTom', current_step, max_steps;
            current_step = current_step + 1;
            perform imports.import_tomtom_data(varrec._client_id);
        END IF;
    END LOOP;

    Raise notice '[PB][%,%] Normalizing Data', current_step, max_steps;
    current_step = current_step + 1;
    EXECUTE format('delete from %1$s.fleet_data where coalesce(distance,0) = 0;', varrec._client_id);

    EXECUTE format('update %1$s.fleet_data set vehiclereg = upper(vehiclereg), vehiclealias = upper(vehiclealias) , vehiclegroup = upper(vehiclegroup);', varrec._client_id);

    Raise notice '[PB][%,%] Route Deviation', current_step, max_steps;
    current_step = current_step + 1;
    IF NOT clientrec.calculate_route_deviation THEN
        EXECUTE format('update %1$s.fleet_data set routescore = 100;', varrec._client_id);
    ELSE
        perform imports.populate_google_distance(varrec._client_id);
        perform imports.calculate_route_deviation(varrec._client_id);
    END IF;

    Raise notice '[PB][%,%] Weigh Data', current_step, max_steps;
    current_step = current_step + 1;
    IF clientrec.import_weigh_data THEN
        PERFORM imports.import_weigh_data(varrec._client_id);
    END IF;

    Raise notice '[PB][%,%] Calculating Risk Data', current_step, max_steps;
    current_step = current_step + 1;
    PERFORM mfaglb.calculate_risk_data(varrec._client_id);

    Raise notice '[PB][%,%] Timestamp', current_step, max_steps;
    current_step = current_step + 1;
    UPDATE mfaglb.clients
    SET client_last_import = clock_timestamp()
    WHERE client_id = varrec._client_id;

end;
$$
language plpgsql;