select count(*)from coviddeaths;
create database nav_portfolio;
use nav_portfolio;
create table covid (iso_code	varchar(60) ,
continent	varchar(60) ,
location	varchar(60) ,
date	date ,
population	int  ,
total_cases int ,
new_cases	int ,
new_cases_smoothed	decimal(10,3) default null,
total_deaths	int default null ,
new_deaths	int default null ,
new_deaths_smoothed	decimal (10,3) default null ,
total_cases_per_million	decimal (10,3) default null,
new_cases_per_million	decimal (10,3) default null,
new_cases_smoothed_per_million	decimal (10,3) default null,
total_deaths_per_million	decimal (10,3) default null,
new_deaths_per_million	decimal (10,3)   default null ,
new_deaths_smoothed_per_million	decimal(10,3) default null ,
reproduction_rate	decimal (10,3) default null,
icu_patients	int default null ,
icu_patients_per_million	decimal(10,3) default null,
hosp_patients	int  default null,
hosp_patients_per_million	decimal(10,3) default null ,
weekly_icu_admissions	int default null ,
weekly_icu_admissions_per_million	decimal (10,3) default null,
weekly_hosp_admissions	int default null ,
weekly_hosp_admissions_per_million decimal(10,3)default null );

set session sql_mode ='';
select * from covid;
select count( * )from covid;
load data infile
'F:/coviddeaths.csv'
into table covid 
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows
set sql_safe_updates =0;

Create table vaccins(iso_code	VARCHAR(60),
continent	VARCHAR(60),
location	VARCHAR(60),
date	DATE,
total_tests	INT,
new_tests	INT,
total_tests_per_thousand	DECIMAL(20,5),
new_tests_per_thousand	DECIMAL(20,5),
new_tests_smoothed	DECIMAL(20,5),
new_tests_smoothed_per_thousand	DECIMAL(20,5),
positive_rate	DECIMAL(20,5),
tests_per_case	DECIMAL(20,5),
tests_units	VARCHAR(60),
total_vaccinations	INT,
people_vaccinated	INT,
people_fully_vaccinated INT,
total_boosters INT,
new_vaccinations INT,
	new_vaccinations_smoothed	int,
	total_vaccinations_per_hundred	DECIMAL(20,5),
	people_vaccinated_per_hundred	DECIMAL(20,5),
	people_fully_vaccinated_per_hundred	DECIMAL(20,5),
	total_boosters_per_hundred	DECIMAL(20,5),
	new_vaccinations_smoothed_per_million int,
	new_people_vaccinated_smoothed int,
	new_people_vaccinated_smoothed_per_hundred DECIMAL(20,5),
	stringency_index	DECIMAL(20,5),
	population_density	DECIMAL(20,5),
	median_age	DECIMAL(20,5),
	aged_65_older DECIMAL(20,5),
	aged_70_older DECIMAL(20,5),
	gdp_per_capita DECIMAL(20,5),
	extreme_poverty DECIMAL(20,5),
	cardiovasc_death_rate	DECIMAL(20,5),
	diabetes_prevalence	DECIMAL(20,5),
	female_smokers	DECIMAL(20,5),
	male_smokers	DECIMAL(20,5),
	handwashing_facilities	DECIMAL(20,5),
	hospital_beds_per_thousand DECIMAL(20,5),
	life_expectancy	DECIMAL(20,5),
	human_development_index DECIMAL(20,5),
	population INT,
	excess_mortality_cumulative_absolute DECIMAL(20,5),
	excess_mortality_cumulative	DECIMAL(20,5),
    excess_mortality	 DECIMAL(20,5),
	excess_mortality_cumulative_per_million DECIMAL(20,5))
    
load data infile
'F:/Covid_Vaccinations_new.csv'
into table vaccins
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows
 select * from vaccins
 select max(new_vaccinations) from vaccins
 select max(new_vaccinations_smoothed) from vaccins
 
#total cases vs total death in india
select location,date,total_cases,total_deaths, (total_deaths/total_cases*100) as death_percent from covid where location='India'

#total cases vs population
select location,date,total_cases,population, (total_cases/population*100) as case_percent from covid where location='India'

#looking at countries with highest infection rate compared to population
select location,population ,max(total_cases) as 'highest infection count', max(total_cases/population*100) as case_percent
 from covid group by location, population order by case_percent desc
 
 #showing countries with highest death count per population
 select location,population ,max(total_deaths) as 'highest death count', max(total_deaths/population*100) as death_percent
 from covid where continent is not null group by location, population order by death_percent desc
 

  #showing continents with highest death count
  select location, max(total_deaths) as 'highest death count', max(total_deaths/population*100) as death_percent
 from covid where continent is null group by location order by death_percent desc
 
  #global numbers i.e. across the world
  select date, sum(new_cases),sum(new_deaths),( sum(new_deaths)/sum(new_cases))*100 as death_percent_per_case from covid group by date
   select  sum(new_cases) as total_cases,sum(new_deaths) as total_deaths,( sum(new_deaths)/sum(new_cases))*100 as death_percent_per_case from covid 


#total vaccination vs population
select c.continent, c.location, c.date, c.population, v.new_vaccinations
 from covid c join vaccins v on c.location=v.location and c.date=v.date
where c.continent is not null 
order by new_vaccinations desc
 
 
 #total population vs vaccination rolling by , locationvise
 select c.continent, c.location, c.date, c.population, v.new_vaccinations,sum(new_vaccinations) over
 (partition by c.location,date order by location) as rolling_ppl_vaccinated
 from covid c join vaccins v on c.location=v.location and c.date=v.date
where c.continent is not null 
#order by new_vaccinations,date desc

#total % of ppl vaccinated in country=max(new vaccination)/population (use cte)
with PopvsVac as
 (select c.continent, c.location, c.date, c.population, v.new_vaccinations,sum(new_vaccinations) over
 (partition by c.location,date order by location) as rolling_ppl_vaccinated
 from covid c join vaccins v on c.location=v.location and c.date=v.date
where c.continent is not null )
select continent, location,  population, max(rolling_ppl_vaccinated)/population*100 as total_vaccinated from PopvsVac group by location
 
 set sql_mode=''
 
 #creating view for later data visualisation
 create view percent_pop_vaccinated as
  (select c.continent, c.location, c.date, c.population, v.new_vaccinations,sum(new_vaccinations) over
 (partition by c.location,date order by location) as rolling_ppl_vaccinated
 from covid c join vaccins v on c.location=v.location and c.date=v.date
where c.continent is not null )

select * from percent_pop_vaccinated