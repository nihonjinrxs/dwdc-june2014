/***************************************
  Data Wranglers DC : June 2014 Meetup
  Data Wrangling with SQL
  **************************************
  Author:  Ryan B. Harvey
  Created: 2014-03-17
  **************************************
  This creates the storage locations
  for and imports sample data on 
  children's height measurements upon
  visits to the doctor.
  This script imports each file as a 
  separate table.
****************************************/

/* To create a schema, execute something like this: */
CREATE SCHEMA IF NOT EXISTS dwdc AUTHORIZATION ryan;
GRANT ALL ON SCHEMA dwdc TO ryan;
COMMENT ON SCHEMA dwdc IS 'Schema for Data Wranglers DC June 2014 talk';

/* Create the tables we'll use to dump the data in: */
drop table if exists dwdc.ids;
CREATE TABLE dwdc.ids (
    id SERIAL PRIMARy Key,
    first_name text,
    gender char(1),
    dob Date
);
comment on table dwdc.ids is 'Sample data: ids of children in the data sample';

drop table if exists dwdc.visits1;
CREATE TABLE dwdc.visits1 (
    first_name text,
    visit_date date,
    height numeric
);
comment on table dwdc.visits1 is 'Sample data: first file of visits by children to the doctor';

drop table if exists dwdc.visits2;
CREATE TABLE dwdc.visits2 (
    first_name text,
    visit_date date,
    height numeric
);
comment on table dwdc.visits2 is 'Sample data: second file of visits by children to the doctor';

drop table if exists dwdc.visits3;
CREATE TABLE dwdc.visits3 (
    first_name text,
    visit_date date,
    height numeric
);
comment on table dwdc.visits3 is 'Sample data: third file of visits by children to the doctor';

drop table if exists dwdc.visits4;
CREATE TABLE dwdc.visits4 (
    first_name text,
    visit_date date,
    height numeric
);
comment on table dwdc.visits4 is 'Sample data: fourth file of visits by children to the doctor';

/* Dump the actual CSV data files into the tables: */
SET datestyle to postgres, mdy;
copy dwdc.ids (first_name, gender, dob) 
from '/Users/ryan/data/dwdc-june2014/csv/ID.csv'
with csv header NULL as '';
/* also: QUOTE '"', ESCAPE '\', DELIMITER ','*/ 

SET datestyle to postgres, mdy;
copy dwdc.visits1 (first_name, visit_date, height) 
from '/Users/ryan/data/dwdc-june2014/csv/Data Set 1.csv'
with csv header NULL as '';

SET datestyle to postgres, mdy;
copy dwdc.visits2 (first_name, visit_date, height) 
from '/Users/ryan/data/dwdc-june2014/csv/Data Set 2.csv'
with csv header NULL as '';

SET datestyle to postgres, mdy;
copy dwdc.visits3 (first_name, visit_date, height) 
from '/Users/ryan/data/dwdc-june2014/csv/Data Set 3.csv'
with csv header NULL as '';

SET datestyle to postgres, mdy;
copy dwdc.visits4 (first_name, visit_date, height) 
from '/Users/ryan/data/dwdc-june2014/csv/Data Set 4.csv'
with csv header NULL as '';

set datestyle to default;