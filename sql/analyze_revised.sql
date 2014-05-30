/***************************************
  Data Wranglers DC : June 2014 Meetup
  Data Wrangling with SQL
  **************************************
  Author:  Ryan B. Harvey
  Created: 2014-03-17
  **************************************
  This script computes growth rates
  for children as represented in the 
  data imported by the script:
    import_revised.sql
****************************************/

with all_visits_and_ids (id, first_name, dob, visit_date, height) as (
  select i.id, i.first_name, i.dob, v.visit_date, v.height
  from dwdc.ids i left join dwdc.all_visits v on i.first_name = v.first_name
)
, all_visits_and_ids_with_age (id, first_name, dob, age, visit_date, height) As (
  select 
    id, first_name, dob, 
    extract(epoch from age(visit_date, dob))/(3600 * 24)/365.25 as age,
    visit_date, height
  from all_visits_and_ids
)
select id, first_name, regr_slope(height, age) as growth_rate
from all_visits_and_ids_with_age
group by id, first_name
order by id ASC
;
/* To see what the above "EXTRACT" is doing, see below: */
/*
select 
  age(date '2010-12-16') as age_interval, 
  extract(epoch from age(date '2010-12-16'))/(3600 * 24)/365.25 as age_spec;
*/