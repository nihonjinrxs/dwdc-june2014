/***************************************
  Data Wranglers DC : June 2014 Meetup
  Data Wrangling with SQL
  **************************************
  Author:  Ryan B. Harvey
  Created: 2014-03-17
  **************************************
  This script destroy all storage 
  locations and associated data for 
  this exercise.
****************************************/

DROP VIEW IF EXISTS dwdc.analysis_results;
DROP TABLE IF EXISTS dwdc.ids;
DROP TABLE IF EXISTS dwdc.visits1;
DROP TABLE IF EXISTS dwdc.visits2;
DROP TABLE IF EXISTS dwdc.visits3;
DROP TABLE IF EXISTS dwdc.visits4;
DROP TABLE IF EXISTS dwdc.all_visits;
drop schema if exists dwdc;
