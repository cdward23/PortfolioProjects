--Select all data from CovidDeaths Table
SELECT *
FROM PP1Covid.dbo.[CovidDeaths']
Where continent is not NULL
order by 3,4

--Select all data from CovidVaccinations Table
SELECT *
FROM PP1Covid.dbo.CovidVaccinations
Where continent is not NULL
order by 3,4

--New Cases, Total Cases, Total Deaths and Population
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PP1Covid.dbo.[CovidDeaths']
Where continent is not NULL
order by 1,2

--Total Cases vs Total Deaths in the US
SELECT location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as DeathPercentage
FROM PP1Covid.dbo.[CovidDeaths']
WHERE Location LIKE '%states%'
AND continent is not NULL
order by location,date

--Total Cases vs Population in the US
SELECT date, location, population, total_cases, (NULLIF(CONVERT(float,total_cases)/CONVERT(float,population),0))*100 as AffectedPercentage
FROM PP1Covid.dbo.[CovidDeaths']
WHERE Location LIKE '%states%'
and continent is not NULL
order by location,date

--Highest Infection Rates compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases)/Population*100 as InfectedPercentage
FROM PP1Covid.dbo.[CovidDeaths']
Where continent is not NULL
Group BY Location, Population
order by InfectedPercentage desc

--Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PP1Covid.dbo.[CovidDeaths']
Where continent is not NULL
Group BY Location
order by TotalDeathCount desc

--Total Death Count by Continent
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PP1Covid.dbo.[CovidDeaths']
Where continent is NULL
Group BY Location
order by TotalDeathCount desc

--Global Numbers
--By Date
SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(Cast(New_Deaths as int))/NULLIF(SUM(New_Cases),0)*100 AS DeathPercentage
FROM PP1Covid.dbo.[CovidDeaths']
Where continent is not NULL
Group By date
order by date

--Total
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(Cast(New_Deaths as int))/NULLIF(SUM(New_Cases),0)*100 AS DeathPercentage
FROM PP1Covid.dbo.[CovidDeaths']
WHERE continent is not NULL

--In the US by Date
SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(Cast(New_Deaths as int))/NULLIF(SUM(New_Cases),0)*100 AS DeathPercentage
FROM PP1Covid.dbo.[CovidDeaths']
WHERE Location LIKE '%states%'
AND continent is not NULL
Group By date
order by date

--Total US
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(Cast(New_Deaths as int))/NULLIF(SUM(New_Cases),0)*100 AS DeathPercentage
FROM PP1Covid.dbo.[CovidDeaths']
WHERE Location LIKE '%states%'
AND continent is not NULL

--Joining Tables
Select *
From PP1Covid.dbo.[CovidDeaths'] dea
Join PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

--Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location ORDER BY dea.location, dea.date) as RollingTotalVaccinations
From PP1Covid.dbo.[CovidDeaths'] dea 
Join PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

--Use CTE, Total Population vs Vaccinations 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingTotalVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location ORDER BY dea.location, dea.date) as RollingTotalVaccinations
From PP1Covid.dbo.[CovidDeaths'] dea 
Join PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
)
Select *, (RollingTotalVaccinations/Population)*100 as PopulationPercentage
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location ORDER BY dea.location, dea.date) as RollingTotalVaccinations
From PP1Covid.dbo.[CovidDeaths'] dea 
Join PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL

Select *, (RollingTotalVaccinations/Population)*100 as PopulationPercentage
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations
Create View PercentPopVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location ORDER BY dea.location, dea.date) as RollingTotalVaccinations
From PP1Covid.dbo.[CovidDeaths'] dea 
Join PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL

--Show data from created View
Select *
FROM PP1Covid.dbo.PercentPopVaccinated

--Total data per Million by Country by Date
Select dea.location, dea.date, total_cases_per_million, icu_patients_per_million, total_deaths_per_million
From PP1Covid.dbo.[CovidDeaths'] dea
Join PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 1,2

--View of Total data by Country 
Create View HospDatabyCountry as
Select dea.location, SUM(new_cases) as TotalCases, SUM(cast(Hosp_patients as int)) as HospitalPatients, (SUM(cast(Hosp_patients as int))/SUM(New_cases)*100) as HospitalizedPercent, SUM(cast(icu_patients as int)) as ICUPatients, (SUM(cast(icu_patients as int))/sum(New_cases)*100) as ICUPercent, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(Cast(New_Deaths as int))/NULLIF(SUM(New_Cases),0)*100 AS DeathPercentage
From PP1Covid.dbo.[CovidDeaths'] dea
Join PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
GROUP BY dea.location

--Showing view of Total Data by Country
SELECT *
From HospDatabyCountry

--Vaccination Data by date
Select dea.location, dea.date, people_vaccinated, population, (people_vaccinated/population)*100 as PercentVaccinated, total_vaccinations_per_hundred, total_boosters_per_hundred, people_fully_vaccinated_per_hundred
From PP1Covid.dbo.[CovidDeaths'] dea
Join PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 1,2

--Total Vaccination Data 
Select dea.location, population, SUM(cast(New_Tests as int)) as PeopleTested, SUM(cast(New_Vaccinations as bigint)) as Vaccinations, SUM(cast(New_People_Vaccinated_Smoothed as int)) as PeopleVaccinated, (SUM(cast(New_people_vaccinated_Smoothed as int))/population)*100 as PercentVaccinated
From PP1Covid.dbo.[CovidDeaths'] dea
Join PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
GROUP by dea.location, population
ORDER BY 1

--View of Total Vaccination Data 
create view TotVacData as 
Select dea.location, population, SUM(cast(New_Tests as int)) as PeopleTested, SUM(cast(New_Vaccinations as bigint)) as Vaccinations, SUM(cast(New_People_Vaccinated_Smoothed as int)) as PeopleVaccinated, (SUM(cast(New_people_vaccinated_Smoothed as int))/population)*100 as PercentVaccinated
From PP1Covid.dbo.[CovidDeaths'] dea
Join PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
GROUP by dea.location, population

--Show Total Vaccination Data View
SELECT *
FROM TotVacData
ORDER BY 1

