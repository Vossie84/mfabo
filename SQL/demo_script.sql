/*
 DEMO Script
 */

-- scramble data for demo purposes...
with aa as (
    SELECT DISTINCT vehiclereg
    FROM public.dci72
), qq as (
    SELECT
        concat('MFA', lpad((row_number()
        OVER ()) :: TEXT, 3, '0'), 'GP') as ss,
        *
    FROM aa
)
update public.dci72 tgt
set (vehiclereg) = (src.ss)
from
qq src
where tgt.vehiclereg = src.vehiclereg;

create schema import;

create table import.dci72  
(like public.dci72);