-- Queries for PowerBI visulization

-- 1. death percentage as compared to total cases and total deaths

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS death_percentage
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- 2. Total death count per continent
--    I am taking out World, European Union and International as they are not inluded in the above queries and want to stay consistent
--    European Union is part of Europe similarly for world and international 

SELECT location, SUM(CAST(new_deaths AS INT)) AS total_death_count
FROM dbo.CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY total_death_count DESC


-- 3. Percent of population infected from each country and highest infection count for each country

SELECT location, population, MAX(total_cases) AS highest_infection_count,  MAX((total_cases/population))*100 AS percentage_of_pop_infected
FROM dbo.CovidDeaths
GROUP BY location, population
ORDER BY percentage_of_pop_infected DESC


-- 4. Same as 3rd but seperated by each day

SELECT location, population, date, MAX(total_cases) AS highest_infection_count,  MAX((total_cases/population))*100 AS percentage_of_pop_infected
FROM dbo.CovidDeaths
GROUP BY location, population, date
ORDER BY percentage_of_pop_infected DESC