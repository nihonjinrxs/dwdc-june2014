# Data Wrangling in SQL & Other Tools
##### Scripting Reproducible and Understandable Data Wrangling and Analysis Pipelines with Tabular and Relational Data

This repository contains materials for [my talk at the Data Wranglers DC meetup on June 4, 2014](http://www.meetup.com/Data-Wranglers-DC/events/171768162/).

### Contents
The talk consists of several major directions:
- A slide deck (`./slides`) in Apple Keynote, [PDF](https://nihonjinrxs.github.io/dwdc-june2014/DWDC-June2014-RyanHarvey.pdf) and [HTML](https://nihonjinrxs.github.io/dwdc-june2014) formats
- Sample data in CSV format (`./csv`), courtesy of [tilling](https://github.com/tilling)
- A set of SQL scripts (`./sql`) that create the local PostgreSQL database used for the examples and perform the simple linear model analysis example
- An RMarkdown document (`./R`), [published on RPubs](http://rpubs.com/ryanbharvey/dwdc-june2014), that uses the data from the database to perform the analysis in R and compare with the SQL results
- An iPython notebook document (`./python`) that uses the data from the database to perform the example analysis, compare the results across SQL and R, and plot the resulting linear models

### Where do I start?
I recommend that anyone wishing to understand what I've done should tackle these pieces in order, starting with the slide deck.

### Future Work
Given time and maturity of database libraries, I hope to add a parallel example in Julia soon.

### Disclaimer
This work and the opinions expressed here are my own, and do not purport to represent the views of my current or former employers.
