--SELECT all data FROM CovidDeaths Table
SELECT *
FROM PP1Covid.dbo.[CovidDeaths']
WHERE continent is not NULL
ORDER BY 3,4

--SELECT all data FROM CovidVaccinations Table
SELECT *
FROM PP1Covid.dbo.CovidVaccinations
WHERE continent is not NULL
ORDER BY 3,4

--New Cases, Total Cases, Total Deaths and Population
SELECT location, date, population, total_cases, new_cases, total_deaths
FROM PP1Covid.dbo.[CovidDeaths']
WHERE continent is not NULL
ORDER BY 1,2

--Total Cases, Total Deaths and Population
SELECT location, date, population, total_cases, total_deaths
FROM PP1Covid.dbo.[CovidDeaths']
WHERE continent is not NULL
ORDER BY 1,2

--Total Cases vs Total Deaths in the US
SELECT location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as DeathPercentage
FROM PP1Covid.dbo.[CovidDeaths']
WHERE Location LIKE '%states%'
AND continent is not NULL
ORDER BY location,date

--Total Cases vs Population in the US
SELECT date, location, population, total_cases, (NULLIF(CONVERT(float,total_cases)/CONVERT(float,population),0))*100 as AffectedPercentage
FROM PP1Covid.dbo.[CovidDeaths']
WHERE Location LIKE '%states%'
AND continent is not NULL
ORDER BY location,date

--Highest Infection Rates compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases)/Population*100 as InfectedPercentage
FROM PP1Covid.dbo.[CovidDeaths']
WHERE continent is not NULL
GROUP BY Location, Population
ORDER BY InfectedPercentage desc

--Highest Infection Rates compared to Population including date
SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, MAX(total_cases)/Population*100 as InfectedPercentage
FROM PP1Covid.dbo.[CovidDeaths']
WHERE continent is not NULL
GROUP BY Location, Population, date
ORDER BY InfectedPercentage desc

--Countries with Highest Death Count per Population
SELECT location, population, MAX(CAST(total_deaths as int)) as TotalDeathCount, MAX(CAST(total_deaths as int))/population as DeathsPerPopulation 
FROM PP1Covid.dbo.[CovidDeaths']
WHERE continent is not NULL
GROUP BY Location, population
ORDER BY TotalDeathCount desc

--Total Death Count BY Continent
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PP1Covid.dbo.[CovidDeaths']
WHERE continent is NULL
GROUP BY Location
ORDER BY TotalDeathCount desc

--Version 2
--Total Death Count BY Continent
SELECT location, SUM(CAST(new_deaths as int)) as TotalDeathCount
FROM PP1Covid.dbo.[CovidDeaths']
WHERE continent is NULL
AND location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY Location
ORDER BY TotalDeathCount desc

--Global Numbers
--BY Date
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(New_Deaths as int))/NULLIF(SUM(New_Cases),0)*100 AS DeathPercentage
FROM PP1Covid.dbo.[CovidDeaths']
WHERE continent is not NULL
GROUP BY date
ORDER BY date

--Total
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(New_Deaths as int))/NULLIF(SUM(New_Cases),0)*100 AS DeathPercentage
FROM PP1Covid.dbo.[CovidDeaths']
WHERE continent is not NULL
ORDER BY 1,2

--In the US BY Date
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(New_Deaths as int))/NULLIF(SUM(New_Cases),0)*100 AS DeathPercentage
FROM PP1Covid.dbo.[CovidDeaths']
WHERE Location LIKE '%states%'
AND continent is not NULL
GROUP BY date
ORDER BY date

--Total US
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(New_Deaths as int))/NULLIF(SUM(New_Cases),0)*100 AS DeathPercentage
FROM PP1Covid.dbo.[CovidDeaths']
WHERE Location LIKE '%states%'
AND continent is not NULL

--Joining Tables
SELECT *
FROM PP1Covid.dbo.[CovidDeaths'] dea
JOIN PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

--Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingTotalVaccinations
FROM PP1Covid.dbo.[CovidDeaths'] dea 
JOIN PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

--Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingTotalVaccinations
FROM PP1Covid.dbo.[CovidDeaths'] dea 
JOIN PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

--For Tableau
SELECT dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PP1Covid.dbo.[CovidDeaths'] dea 
JOIN PP1Covid.dbo.CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
GROUP BY dea.continent, dea.location, dea.date, dea.population
ORDER BY 1,2,3

--Use CTE, Total Population vs Vaccinations 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingTotalVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingTotalVaccinations
FROM PP1Covid.dbo.[CovidDeaths'] dea 
JOIN PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT *, (RollingTotalVaccinations/Population)*100 as PopulationPercentage
FROM PopvsVac

--Use a Temp Table, Total Population vs Vaccinations
DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population Numeric,
New_Vaccinations numeric,
RollingTotalVaccinations numeric
)

INSERT Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingTotalVaccinations
FROM PP1Covid.dbo.[CovidDeaths'] dea 
JOIN PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *, (RollingTotalVaccinations/Population)*100 as PopulationPercentage
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations
CREATE VIEW PercentPopVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition BY dea.location ORDER BY dea.location, dea.date) as RollingTotalVaccinations
FROM PP1Covid.dbo.[CovidDeaths'] dea 
JOIN PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL

--Show data FROM created View
SELECT *
FROM PP1Covid.dbo.PercentPopVaccinated

--Total data per Million BY Country BY Date
SELECT dea.location, dea.date, total_cases_per_million, icu_patients_per_million, total_deaths_per_million
FROM PP1Covid.dbo.[CovidDeaths'] dea
JOIN PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 1,2

--View of Total data BY Country 
CREATE VIEW HospDataBYCountry 
as
SELECT dea.location, SUM(new_cases) as TotalCases, SUM(CAST(Hosp_patients as int)) as HospitalPatients, (SUM(CAST(Hosp_patients as int))/SUM(New_cases)*100) as HospitalizedPercent, SUM(CAST(icu_patients as int)) as ICUPatients, (SUM(CAST(icu_patients as int))/sum(New_cases)*100) as ICUPercent, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(New_Deaths as int))/NULLIF(SUM(New_Cases),0)*100 AS DeathPercentage
FROM PP1Covid.dbo.[CovidDeaths'] dea
JOIN PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
GROUP BY dea.location

--Showing view of Total Data BY Country
SELECT *
FROM HospDataBYCountry

--Vaccination Data BY date
SELECT dea.location, dea.date, people_vaccinated, population, (people_vaccinated/population)*100 as PercentVaccinated, total_vaccinations_per_hundred, total_boosters_per_hundred, people_fully_vaccinated_per_hundred
FROM PP1Covid.dbo.[CovidDeaths'] dea
JOIN PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 1,2

--Total Vaccination Data 
SELECT dea.location, population, SUM(CAST(New_Tests as int)) as PeopleTested, SUM(CAST(New_Vaccinations as bigint)) as Vaccinations, SUM(CAST(New_People_Vaccinated_Smoothed as int)) as PeopleVaccinated, (SUM(CAST(New_people_vaccinated_Smoothed as int))/population)*100 as PercentVaccinated
FROM PP1Covid.dbo.[CovidDeaths'] dea
JOIN PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
GROUP BY dea.location, population
ORDER BY 1

--View of Total Vaccination Data 
CREATE VIEW TotVacData 
as 
SELECT dea.location, population, SUM(CAST(New_Tests as int)) as PeopleTested, SUM(CAST(New_Vaccinations as bigint)) as Vaccinations, SUM(CAST(New_People_Vaccinated_Smoothed as int)) as PeopleVaccinated, (SUM(CAST(New_people_vaccinated_Smoothed as int))/population)*100 as PercentVaccinated
FROM PP1Covid.dbo.[CovidDeaths'] dea
JOIN PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
GROUP BY dea.location, population

--Show Total Vaccination Data View
SELECT *
FROM TotVacData
ORDER BY 1

--Population Vaccinated vs New Cases vs Death Rate in the US 
SELECT dea.location, dea.Date, population, dea.new_cases, dea.hosp_patients, dea.icu_patients, dea.new_deaths, CAST(vac.people_vaccinated as float)/1000000 as RollingVaccinationsInMillions 
FROM PP1Covid.dbo.[CovidDeaths'] dea
JOIN PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
AND dea.Location LIKE '%states%'
GROUP BY dea.location, dea.date, population, dea.new_cases, vac.people_vaccinated, dea.new_deaths, dea.hosp_patients, dea.icu_patients
ORDER BY 1, 2
