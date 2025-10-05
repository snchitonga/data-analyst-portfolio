COVID-19 Global Analysis

Author: Sandra Chitonga
Purpose: This project explores the global impact of COVID-19 by analyzing case counts, death counts, and vaccination rates. The goal is to gain insights into country-level infection and mortality trends, as well as vaccination progress.

Datasets

coviddeaths – Daily COVID-19 case and death counts by country.

covidvaccinations – Daily vaccination counts by country.

Technologies

MySQL 8+

Window Functions (for rolling calculations)

Common Table Expressions (CTEs)

Views & Temporary Tables

Project Workflow
1. Explore Raw Data

Display all records in coviddeaths ordered by date and location.

2. Country-Level Analysis

Analyze total and new cases, deaths, and population per country.

3. Total Cases vs Total Deaths (Example: US)

Calculate death percentages: (total_deaths / total_cases) * 100

4. Total Cases vs Population

Calculate percentage of population infected per country.

5. Countries with Highest Infection Rate

Top 10 countries by % population infected.

6. Countries with Highest Death Count

Top 10 countries by total deaths.

7. Continent-Level Death Summary

Total deaths by continent.

8. Global Numbers Summary

Total cases, deaths, and overall death percentage worldwide.

9. Total Population vs Vaccinations

Rolling sum of vaccinated people per country using window functions.

10. Percent Population Vaccinated (CTE)

Calculate cumulative vaccination percentages using a CTE.

11. Temporary Table for Vaccination Analysis

Store rolling vaccination counts for further analysis.

12. View for Vaccination Analysis

Create a view to easily query percent of population vaccinated.

13. Extra Insights

Top 5 countries by death rate: Highest total_deaths / total_cases * 100

Top 5 countries by infection rate: Highest (total_cases / population) * 100

Key Insights

Countries with high populations may not always have the highest infection or death rates.

Vaccination rollouts can be tracked cumulatively over time using window functions.

CTEs and views make complex queries and repeated analysis simpler.

How to Run

Import coviddeaths and covidvaccinations datasets into MySQL.

Execute SQL scripts sequentially for analysis.

Use the views for quick insights on vaccination and mortality.