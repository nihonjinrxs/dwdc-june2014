---
title: "Data Wrangling with SQL : Data Wranglers DC : June 2014 Meetup"
output:
  html_document:
    author: Ryan B. Harvey
    date: March 17, 2014
---

Data Wrangling with SQL : Data Wranglers DC : June 2014 Meetup
==============================================================
**Author:**  [Ryan B. Harvey](http://datascientist.guru)

**Created:** 2014-03-17 / **Last Updated:** 2014-06-01

**Contents:**
- How to connect R to PostgreSQL
- Options in dplyr for SQL
- How to pull in tables from the DB
- How to pull query results into R
- Validation of analysis done in SQL

**Package Dependencies:**
- **[RPostgreSQL](http://cran.r-project.org/package=RPostgreSQL):** [more info & source](https://code.google.com/p/rpostgresql/)
- **[dplyr](http://cran.r-project.org/package=dplyr):** [intro blog post](http://blog.rstudio.org/2014/01/17/introducing-dplyr/), [more info & source](https://github.com/hadley/dplyr)

**References:**
- This RPub was created for a talk to the Data Wranglers DC meetup group on June 4, 2014.
  - Talk information: [http://www.meetup.com/Data-Wranglers-DC/events/171768162/](http://www.meetup.com/Data-Wranglers-DC/events/171768162/)
  - This is only a portion of the talk, which included database information, SQL code (which sets up the database used below), and an iPython notebook too.
  - My code, slides and the sample data are all available on Github. [https://github.com/nihonjinrxs/dwdc-june2014](https://github.com/nihonjinrxs/dwdc-june2014)
- The sample data for this work were created by John Tillinghast for his talk, for which mine is a sequel (no pun intended).
  - Talk information: [http://www.meetup.com/Data-Wranglers-DC/events/160287602/](http://www.meetup.com/Data-Wranglers-DC/events/160287602/)
  - John's data, code and slides are available on Github: [https://github.com/tilling/Reduce-the-Pain](https://github.com/tilling/Reduce-the-Pain)

Since we're using PostgreSQL, we'll need R connectors for that. If the RPostgreSQL package doesn't exist in your environment, install it. Once you have it, require it.

```r
# install.packages("RPostgreSQL")
require(RPostgreSQL)
```

```
## Loading required package: RPostgreSQL
## Loading required package: DBI
```

Although you can just connect to the database directly through RPostgreSQL, we'll use dplyr tools with our connection to databases in order to make our data manipulation easier and more portable across different database platforms.  If the dplyr package doesn't exist in your environment, install the package.  Once you have it, require it.

```r
# install.packages("dplyr")
require(dplyr)
```

```
## Loading required package: dplyr
## 
## Attaching package: 'dplyr'
## 
## The following objects are masked from 'package:stats':
## 
##     filter, lag
## 
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

Connect to the database using the dplyr connection function. Provides a connection object `my_db` to use in future work.  
> Note that since I'm using defaults for my local PostgreSQL install, dplyr and RPostgreSQL are smart enough to not need any parameters except the name of the database (`ryan` in this case).

```r
my_db <- src_postgres(dbname="ryan")
```

Then we'll tell it which schema in the database we want to work with.

```r
dbGetQuery(my_db$con,"set search_path to dwdc;")
```

```
## NULL
```

Now we'll do some pulling from tables, just to see how RPostgreSQL works.
--------------------------------

Grab a table from the database and dump it into a data frame

```r
my_all_visits <- as.data.frame(tbl(my_db, "all_visits"))
my_all_visits
```

```
##    first_name visit_date height
## 1        Noah 2009-01-31     43
## 2      Olivia 2009-02-15     48
## 3      Sophia 2009-04-26     48
## 4        Emma 2009-05-23     41
## 5       Ethan 2009-10-11     42
## 6     William 2009-11-01     52
## 7       Jacob 2009-11-22     42
## 8    Isabella 2009-12-06     48
## 9        Emma 2010-01-16     42
## 10   Isabella 2010-03-05     48
## 11      Mason 2010-08-10     48
## 12      Jacob 2010-08-11     43
## 13    William 2010-10-10     54
## 14       Noah 2010-12-08     47
## 15     Sophia 2010-12-10     51
## 16    William 2011-05-20     55
## 17     Sophia 2011-05-29     51
## 18      Mason 2011-06-07     49
## 19   Isabella 2011-07-10     50
## 20      Ethan 2011-07-11     45
## 21     Olivia 2011-09-24     54
## 22       Noah 2011-11-29     49
## 23      Jacob 2012-01-14     46
## 24       Emma 2012-06-25     47
## 25     Sophia 2012-07-15     53
## 26      Mason 2012-08-29     52
## 27    William 2012-11-15     59
## 28   Isabella 2012-11-25     53
## 29      Ethan 2012-12-31     48
```

Side note: If you want to see what SQL is being run, you can turn on dplyr's option to view the SQL.

```r
options(dplyr.show_sql = TRUE)

my_all_visits <- as.data.frame(tbl(my_db, "all_visits"))
```

```
## SELECT "first_name", "visit_date", "height"
## FROM "all_visits"
```

If you want to see more about the SQL being run, you can turn on dplyr's option to explain:

```r
options(dplyr.explain_sql = TRUE)

my_all_visits <- as.data.frame(tbl(my_db, "all_visits"))
```

```
## SELECT "first_name", "visit_date", "height"
## FROM "all_visits"
## Seq Scan on all_visits  (cost=0.00..18.30 rows=830 width=68)
```

For now, we'll turn the more detailed logging off:

```r
options(dplyr.show_sql = FALSE)
options(dplyr.explain_sql = FALSE)
```

We can also grab the results of an arbitrary SQL query and dump it into a data frame.

```r
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
my_all_visits_joined_with_ids
```

```
##    id first_name        dob visit_date height
## 1   7       Emma 2005-12-03 2009-05-23     41
## 2   7       Emma 2005-12-03 2012-06-25     47
## 3   7       Emma 2005-12-03 2010-01-16     42
## 4   3      Ethan 2005-09-27 2011-07-11     45
## 5   3      Ethan 2005-09-27 2009-10-11     42
## 6   3      Ethan 2005-09-27 2012-12-31     48
## 7   8   Isabella 2002-05-27 2011-07-10     50
## 8   8   Isabella 2002-05-27 2009-12-06     48
## 9   8   Isabella 2002-05-27 2012-11-25     53
## 10  8   Isabella 2002-05-27 2010-03-05     48
## 11  1      Jacob 2005-09-18 2009-11-22     42
## 12  1      Jacob 2005-09-18 2010-08-11     43
## 13  1      Jacob 2005-09-18 2012-01-14     46
## 14  2      Mason 2004-02-08 2010-08-10     48
## 15  2      Mason 2004-02-08 2012-08-29     52
## 16  2      Mason 2004-02-08 2011-06-07     49
## 17  4       Noah 2004-06-18 2009-01-31     43
## 18  4       Noah 2004-06-18 2010-12-08     47
## 19  4       Noah 2004-06-18 2011-11-29     49
## 20  9     Olivia 2002-02-03 2009-02-15     48
## 21  9     Olivia 2002-02-03 2011-09-24     54
## 22  6     Sophia 2002-01-17 2011-05-29     51
## 23  6     Sophia 2002-01-17 2010-12-10     51
## 24  6     Sophia 2002-01-17 2012-07-15     53
## 25  6     Sophia 2002-01-17 2009-04-26     48
## 26  5    William 2002-09-16 2009-11-01     52
## 27  5    William 2002-09-16 2012-11-15     59
## 28  5    William 2002-09-16 2010-10-10     54
## 29  5    William 2002-09-16 2011-05-20     55
```

Back to the problem at hand...
------------------------------
Since we can get the age within the database too...  let's do that.

```r
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
my_visits_with_age
```

```
##    id first_name        dob    age visit_date height
## 1   7       Emma 2005-12-03  3.465 2009-05-23     41
## 2   7       Emma 2005-12-03  6.553 2012-06-25     47
## 3   7       Emma 2005-12-03  4.118 2010-01-16     42
## 4   3      Ethan 2005-09-27  5.778 2011-07-11     45
## 5   3      Ethan 2005-09-27  4.038 2009-10-11     42
## 6   3      Ethan 2005-09-27  7.257 2012-12-31     48
## 7   8   Isabella 2002-05-27  9.120 2011-07-10     50
## 8   8   Isabella 2002-05-27  7.520 2009-12-06     48
## 9   8   Isabella 2002-05-27 10.490 2012-11-25     53
## 10  8   Isabella 2002-05-27  7.764 2010-03-05     48
## 11  1      Jacob 2005-09-18  4.175 2009-11-22     42
## 12  1      Jacob 2005-09-18  4.884 2010-08-11     43
## 13  1      Jacob 2005-09-18  6.318 2012-01-14     46
## 14  2      Mason 2004-02-08  6.498 2010-08-10     48
## 15  2      Mason 2004-02-08  8.550 2012-08-29     52
## 16  2      Mason 2004-02-08  7.323 2011-06-07     49
## 17  4       Noah 2004-06-18  4.611 2009-01-31     43
## 18  4       Noah 2004-06-18  6.465 2010-12-08     47
## 19  4       Noah 2004-06-18  7.441 2011-11-29     49
## 20  9     Olivia 2002-02-03  7.033 2009-02-15     48
## 21  9     Olivia 2002-02-03  9.632 2011-09-24     54
## 22  6     Sophia 2002-01-17  9.361 2011-05-29     51
## 23  6     Sophia 2002-01-17  8.887 2010-12-10     51
## 24  6     Sophia 2002-01-17 10.490 2012-07-15     53
## 25  6     Sophia 2002-01-17  7.271 2009-04-26     48
## 26  5    William 2002-09-16  7.123 2009-11-01     52
## 27  5    William 2002-09-16 10.162 2012-11-15     59
## 28  5    William 2002-09-16  8.066 2010-10-10     54
## 29  5    William 2002-09-16  8.668 2011-05-20     55
```

Now, we continue the analysis we were doing before.

```r
my_visits_by_name <- group_by(my_visits_with_age, first_name)
est_growth <- function(x, y) {
  mod <- lm(y ~ x)
  return(coef(mod)[2])
}
my_growth_rates_R <- summarize(my_visits_by_name, growth_rate = est_growth(age, height))
my_growth_rates_R
```

```
## Source: local data frame [9 x 2]
## 
##   first_name growth_rate
## 1       Emma       1.973
## 2      Ethan       1.860
## 3   Isabella       1.705
## 4      Jacob       1.900
## 5      Mason       1.988
## 6       Noah       2.125
## 7     Olivia       2.308
## 8     Sophia       1.526
## 9    William       2.301
```

Compare results with the SQL only version
-----------------------------------------
As we saw, we can do all of this in SQL.  Load in the SQL version and compare.

```r
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
my_growth_rates_sql
```

```
##   id first_name growth_rate
## 1  1      Jacob       1.900
## 2  2      Mason       1.988
## 3  3      Ethan       1.860
## 4  4       Noah       2.125
## 5  5    William       2.301
## 6  6     Sophia       1.526
## 7  7       Emma       1.973
## 8  8   Isabella       1.705
## 9  9     Olivia       2.308
```

Now let's build the comparison table (and rename columns for easier reading):

```r
my_comparison = left_join(my_growth_rates_sql, my_growth_rates_R, by="first_name")
my_comparison$new.col <- my_comparison$growth_rate.x - my_comparison$growth_rate.y

names(my_comparison)[3] <- "growth_rate.SQL"
names(my_comparison)[4] <- "growth_rate.R"
names(my_comparison)[5] <- "residual.SQLvsR"

my_comparison
```

```
##   id first_name growth_rate.SQL growth_rate.R residual.SQLvsR
## 1  1      Jacob           1.900         1.900       7.550e-15
## 2  2      Mason           1.988         1.988       1.168e-13
## 3  3      Ethan           1.860         1.860      -4.219e-15
## 4  4       Noah           2.125         2.125      -8.438e-15
## 5  5    William           2.301         2.301      -4.441e-15
## 6  6     Sophia           1.526         1.526       9.326e-15
## 7  7       Emma           1.973         1.973      -1.377e-14
## 8  8   Isabella           1.705         1.705      -6.661e-16
## 9  9     Olivia           2.308         2.308      -1.199e-14
```
