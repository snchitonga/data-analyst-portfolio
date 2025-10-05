
/*
Project: COVID-19 Global Analysis
Author: Sandra Chitonga
Purpose: Explore global COVID-19 impact, including cases, deaths, and vaccination rates.
Datasets:
  - coviddeaths: Daily COVID-19 case and death counts by country
  - covidvaccinations: Daily vaccination counts by country
Technologies: MySQL 8+, Window Functions, CTEs, Views, Temporary Tables
*/

-- ========================================================
-- 1. Explore Raw Data
-- ========================================================
Select *
From coviddeaths
order by date, location;

-- ========================================================
-- 2. Basic Country-Level Data
-- ========================================================
Select location, date, total_cases, new_cases, total_deaths, population
From coviddeaths
Where continent is not null 
order by location, date;

-- ========================================================
-- 3. Total Cases vs Total Deaths (US Example)
-- Likelihood of dying if you contract COVID in the country
-- ========================================================
Select location, date, total_cases, total_deaths, 
       (total_deaths/total_cases)*100 as death_percentage
From coviddeaths
Where location like '%states%'
  and continent is not null
  and total_cases > 0
order by location, date;

-- ========================================================
-- 4. Total Cases vs Population
-- Percentage of population infected
-- ========================================================
Select location, date, population, total_cases,  
       (total_cases/population)*100 as percent_population_infected
From coviddeaths
Where population > 0
order by location, date;

-- ========================================================
-- 5. Countries with Highest Infection Rate
-- ========================================================
Select location, population, 
       MAX(total_cases) as highest_infection_count,  
       MAX((total_cases/population)*100) as percent_population_infected
From coviddeaths
Where population > 0
Group by location, population
order by percent_population_infected desc
Limit 10;

-- ========================================================
-- 6. Countries with Highest Death Count
-- ========================================================
Select location, MAX(cast(total_deaths as signed)) as total_death_count
From coviddeaths
Where continent is not null
Group by location
order by total_death_count desc
Limit 10;

-- ========================================================
-- 7. Continent-Level Death Summary
-- ========================================================
Select continent, MAX(cast(total_deaths as signed)) as total_death_count
From coviddeaths
Where continent is not null
Group by continent
order by total_death_count desc;

-- ========================================================
-- 8. Global Numbers Summary
-- ========================================================
Select SUM(new_cases) as total_cases, 
       SUM(cast(new_deaths as signed)) as total_deaths, 
       SUM(cast(new_deaths as signed))/SUM(new_cases)*100 as death_percentage
From coviddeaths
Where continent is not null;

-- ========================================================
-- 9. Total Population vs Vaccinations (Rolling Vaccinations)
-- ========================================================
Select dea.continent, dea.location, STR_TO_DATE(dea.date, '%m/%d/%Y') as date, dea.population, vac.new_vaccinations,
       SUM(CAST(NULLIF(vac.new_vaccinations, '') AS SIGNED)) 
           OVER (Partition by dea.location Order by dea.location, STR_TO_DATE(dea.date, '%m/%d/%Y')) 
           as rolling_people_vaccinated
From coviddeaths dea
Join covidvaccinations vac
     On dea.location = vac.location
    and STR_TO_DATE(dea.date, '%m/%d/%Y') = STR_TO_DATE(vac.date, '%m/%d/%Y')
Where dea.continent is not null
  and vac.new_vaccinations <> ''
  and vac.new_vaccinations is not null
  and dea.population > 0
order by dea.location, date;

-- ========================================================
-- 10. Using CTE to calculate Percent Population Vaccinated
-- ========================================================
With popvsvac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated) as
(
    Select dea.continent, dea.location, STR_TO_DATE(dea.date, '%m/%d/%Y') as date, dea.population, vac.new_vaccinations,
           SUM(CAST(NULLIF(vac.new_vaccinations, '') AS SIGNED)) 
               OVER (Partition by dea.location Order by dea.location, STR_TO_DATE(dea.date, '%m/%d/%Y')) 
               as rolling_people_vaccinated
    From coviddeaths dea
    Join covidvaccinations vac
         On dea.location = vac.location
        and STR_TO_DATE(dea.date, '%m/%d/%Y') = STR_TO_DATE(vac.date, '%m/%d/%Y')
    Where dea.continent is not null
      and vac.new_vaccinations <> ''
      and vac.new_vaccinations is not null
      and dea.population > 0
)
Select *, (rolling_people_vaccinated/population)*100 as percent_population_vaccinated
From popvsvac;

-- ========================================================
-- 11. Temporary Table for Percent Population Vaccinated
-- ========================================================
DROP TEMPORARY TABLE if exists percent_population_vaccinated;
Create Temporary Table percent_population_vaccinated
(
    continent varchar(255),
    location varchar(255),
    date date,
    population numeric,
    new_vaccinations numeric,
    rolling_people_vaccinated numeric
);

Insert into percent_population_vaccinated
Select 
    dea.continent, 
    dea.location, 
    STR_TO_DATE(dea.date, '%m/%d/%Y') as date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(NULLIF(vac.new_vaccinations, '') AS SIGNED)) 
        OVER (Partition by dea.location Order by dea.location, STR_TO_DATE(dea.date, '%m/%d/%Y')) 
        as rolling_people_vaccinated
From coviddeaths dea
Join covidvaccinations vac
    On dea.location = vac.location
   and STR_TO_DATE(dea.date, '%m/%d/%Y') = STR_TO_DATE(vac.date, '%m/%d/%Y')
Where vac.new_vaccinations <> ''   
  and vac.new_vaccinations is not null
  and dea.population > 0;

Select *, (rolling_people_vaccinated/population)*100 as percent_population_vaccinated
From percent_population_vaccinated;

-- ========================================================
-- 12. Create View for Vaccination Analysis
-- ========================================================
Create or Replace View percent_population_vaccinated as
Select dea.continent, dea.location, STR_TO_DATE(dea.date, '%m/%d/%Y') as date, dea.population, vac.new_vaccinations,
       SUM(CAST(NULLIF(vac.new_vaccinations, '') AS SIGNED)) 
           OVER (Partition by dea.location Order by dea.location, STR_TO_DATE(dea.date, '%m/%d/%Y')) 
           as rolling_people_vaccinated
From coviddeaths dea
Join covidvaccinations vac
     On dea.location = vac.location
    and STR_TO_DATE(dea.date, '%m/%d/%Y') = STR_TO_DATE(vac.date, '%m/%d/%Y')
Where dea.continent is not null;

-- ========================================================
-- 13. Extra Insights (Top Countries by Death & Infection Rates)
-- ========================================================
-- Top 5 countries by death rate
Create or Replace View top5_death_rate AS
Select location, MAX(total_deaths/total_cases*100) AS death_rate
From coviddeaths
Where total_cases > 0
Group by location
Order by death_rate desc
Limit 5;

-- Top 5 countries by infection rate
Create or Replace View top5_infection_rate AS
Select location, MAX((total_cases/population)*100) AS infection_rate
From coviddeaths
Where population > 0
Group by location
Order by infection_rate desc
Limit 5;

-- ========================================================
-- END OF PROJECT
-- ========================================================

