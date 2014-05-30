########################################
# Data Wranglers DC : June 2014 Meetup #
# Data Wrangling with SQL              #
########################################
# Author:  Ryan B. Harvey
# Created: 2014-03-17
########################################
# Contents:
#   How to connect R to PostgreSQL
#   Options in dplyr for SQL
#   How to pull in tables from the DB
#   How to pull query results into R
#   Validation of analysis done in SQL
########################################
# Package Dependencies:
#   RPostgreSQL
#   dplyr
########################################

# Since we're using PostgreSQL, we'll need R connectors for that.
# If they don't exist, install the package:
# install.packages("RPostgreSQL")
require(RPostgreSQL)

# We'll use dplyr to connect to databases.
# If it doesn't exist, install the package:
# install.packages("dplyr")
require(dplyr)

# If you want to see what SQL is being run, you can turn on dplyr's option to view the SQL:
# options(dplyr.show_sql = TRUE)

# If you want to see more about the SQL being run, you can turn on dplyr's option to explain:
# options(dplyr.explain_sql = TRUE)

# Connect to the database, provides an object 'src' to use in future work
my_db <- src_postgres()
dbGetQuery(my_db$con,"set search_path to dwdc;") # Tell it what schema I want

# Grab a table from the database and dump it into a data frame
my_all_visits <- as.data.frame(tbl(my_db, "all_visits"))

# Grab the results of an arbitrary SQL query and dump it into a data frame
my_all_visits_joined_with_ids <- as.data.frame(tbl(my_db,
sql("
select 
  i.id, 
  i.first_name, 
  i.dob, 
  v.visit_date, 
  v.height 
from dwdc.ids i 
left join dwdc.all_visits v 
on i.first_name = v.first_name
")
))

# But we can get the age within the database to...  let's do that:
my_visits_with_age <- as.data.frame(tbl(my_db,
sql("
with all_visits_and_ids (id, first_name, dob, visit_date, height) as (
  select i.id, i.first_name, i.dob, v.visit_date, v.height
  from dwdc.ids i left join dwdc.all_visits v on i.first_name = v.first_name
)
select 
  id, first_name, dob, 
  extract(epoch from age(visit_date, dob))/(3600 * 24)/365.25 as age,
  visit_date, height
from all_visits_and_ids
")
))

# Now, we continue the analysis we were doing before...
my_visits_by_name <- group_by(my_visits_with_age, first_name)
est_growth <- function(x, y) {
  mod <- lm(y ~ x)
  return(coef(mod)[2])
}
my_growth_rates_R <- summarize(my_visits_by_name, growth_rate = est_growth(age, height))

# Actually, we can do all of this in SQL.  Load in the SQL version and compare...
my_growth_rates_sql <- as.data.frame(tbl(my_db,
sql("
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
")
))

my_comparison = left_join(my_growth_rates_sql, my_growth_rates_R, by="first_name")
my_comparison$new.col <- my_comparison$growth_rate.x - my_comparison$growth_rate.y

# Rename things for easier reading:
names(my_comparison)[3] <- "growth_rate_SQL"
names(my_comparison)[4] <- "growth_rate_R"
names(my_comparison)[5] <- "residual_SQLvsR"
