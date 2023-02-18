USE portfolioproject;
SELECT * FROM coviddeaths;
SELECT * FROM covidvaccinations;

-- change date column to acceptable MYSQL text format before conversion to "date" type
update coviddeaths
set date=str_to_date(date,"%d/%m/%Y");
-- change date column's datatype from "text" to "date" <-- seems like dont need this step though..
alter table covviddeaths
modify date date;

describe coviddeaths;
SELECT * FROM coviddeaths;

-- EXPLORING THE DATA FROM cociddeaths table
-- Select data to explore
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY 1,2 ;

-- Explore total cases vs total deaths, and probability of death given covid case
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as total_death_percent
FROM coviddeaths
WHERE location like '%Sing%'
ORDER BY 1,2 ;

-- Explore total population vs total cases overtime, and proportion of population that got covid before
SELECT location, date, population, total_cases, (total_cases/population)*100 as total_cases_percent
FROM coviddeaths
WHERE location like '%Sing%'
ORDER BY 1,2 ;

-- Explore the highest infection rates and count for all avaialble countries
SELECT location, population, MAX(total_cases) as highest_inf_count, (MAX(total_cases)/population)*100 as pop_inf_rate
FROM coviddeaths
WHERE continent is not null and continent <> '' -- exclude blank and NULL data from 'continent' column
GROUP BY location
ORDER BY 3 DESC; 

-- Explore the highest death rates and death count for all avaialble countries
SELECT location, population, MAX(total_deaths) as highest_death_count, (MAX(total_deaths)/population)*100 as death_rate
FROM coviddeaths
WHERE continent is not null and continent <> '' -- exclude blank and NULL data from 'continent' column
GROUP BY location
ORDER BY 3 DESC; 

-- Explore daily cases, deaths and death rate
SELECT date, SUM(new_cases) as daily_cases, SUM(new_deaths) as daily_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as death_rate
FROM coviddeaths
WHERE continent is not null and continent <> '' -- exclude blank and NULL data from 'continent' column
GROUP BY date;

-- my coviddeaths table's first row is duplicated, delete 1 of them now
DELETE FROM coviddeaths LIMIT 1;
SELECT * FROM coviddeaths;

-- Trying to join the 2 tables but it's notworking.. send help plz
SELECT * FROM (SELECT * FROM coviddeaths LIMIT 2000) coviddeaths 
LEFT JOIN (SELECT * FROM covidvaccinations LIMIT 2000) covidvaccinations 
ON coviddeaths.location = covidvaccinations.location and coviddeaths.date = covidvaccinations.date;

-- Lookking at Country, Population, and vaccinations
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(new_vaccinations) OVER (partition by cd.location ORDER BY cd.location, cd.date) as cumulative_total
FROM coviddeaths cd
LEFT JOIN covidvaccinations cv
ON cd.date = cv.date
WHERE cd.continent is not null and cd.continent <> '';