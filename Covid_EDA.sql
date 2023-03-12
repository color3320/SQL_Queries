--EDA
SELECT Location, date, total_cases, new_cases,total_deaths, population
FROM dbo.CovidDeaths

--Total cases vs total deaths (shows the likelihood of dying if you contract covid in India)
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
FROM dbo.CovidDeaths
WHERE location='India' 

-- Total cases vs population (shows what percentage of population got covid)
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS percent_pop_infected
FROM dbo.CovidDeaths
WHERE location='India'


--Countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_pop_infected
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, population 
ORDER BY percent_pop_infected DESC

--Countries with the highest death count per population
SELECT Location, population, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, population 
ORDER BY total_death_count DESC

--Taking a look at data by continent
--Continents with the highest death count
SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC

--Global numbers 
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percent
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date 
--ORDER BY 1,2
--Order by 1,2 sorts the result by the first and second column

--Total population vs vaccinations
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vacc
--(rolling_people_vacc/population)/100
FROM dbo.CovidDeaths d
INNER JOIN dbo.CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL AND v.new_vaccinations IS NOT NULL
ORDER BY 1,2,3

--Using CTE to create population vs vaccination table and then using that table to get percentage of people vaccinated
WITH popvsvac(continent,location, date, population, new_vaccinations, rolling_people_vacc)
AS
	(SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vacc
	FROM dbo.CovidDeaths d
	INNER JOIN dbo.CovidVaccinations v
		ON d.location = v.location
		AND d.date = v.date
	WHERE d.continent IS NOT NULL AND v.new_vaccinations IS NOT NULL)
	SELECT *, (rolling_people_vacc/population)*100 AS percent_people_vacc
	FROM popvsvac

--Using Temp table instead of CTE
DROP TABLE IF EXISTS #percent_pop_vacc
CREATE TABLE #percent_pop_vacc
(
	continent VARCHAR(255),
	location VARCHAR(255),
	data DATETIME,
	population INT,
	new_vaccinations INT,
	rolling_people_vacc INT
)
INSERT INTO #percent_pop_vacc
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vacc
FROM dbo.CovidDeaths d
INNER JOIN dbo.CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL AND v.new_vaccinations IS NOT NULL

SELECT *, (rolling_people_vacc/population)*100 AS percent_people_vacc
FROM #percent_pop_vacc


--Creating View to store data for visulization
CREATE VIEW percent_people_vacc AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vacc
--(rolling_people_vacc/population)/100
FROM dbo.CovidDeaths d
INNER JOIN dbo.CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL AND v.new_vaccinations IS NOT NULL

SELECT * FROM percent_people_vacc