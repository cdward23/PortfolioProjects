SELECT *
FROM PP1Covid.dbo.[CovidDeaths']
Where continent is not NULL
order by 3,4

SELECT *
FROM PP1Covid.dbo.CovidVaccinations
Where continent is not NULL
order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PP1Covid.dbo.[CovidDeaths']
Where continent is not NULL
order by 1,2


--Looking at Total Cases vs Total Deaths in the US

SELECT location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as DeathPercentage
FROM PP1Covid.dbo.[CovidDeaths']
WHERE Location LIKE '%states%'
AND continent is not NULL
order by location,date

-- Looking at the Total Cases vs Population

SELECT date, location, population, total_cases, (NULLIF(CONVERT(float,total_cases)/CONVERT(float,population),0))*100 as AffectedPercentage
FROM PP1Covid.dbo.[CovidDeaths']
WHERE Location LIKE '%states%'
and continent is not NULL
order by location,date


--Looking at Highest Infection Rates compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases)/Population*100 as InfectedPercentage
FROM PP1Covid.dbo.[CovidDeaths']
Where continent is not NULL
Group BY Location, Population
order by InfectedPercentage desc


--Looking at Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PP1Covid.dbo.[CovidDeaths']
Where continent is not NULL
Group BY Location
order by TotalDeathCount desc


--Looking at total death count by continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PP1Covid.dbo.[CovidDeaths']
Where continent is not NULL
Group BY continent
order by TotalDeathCount desc

--Correct Way
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PP1Covid.dbo.[CovidDeaths']
Where continent is NULL
Group BY Location
order by TotalDeathCount desc

--global numbers
--by date
SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(Cast(New_Deaths as int))/NULLIF(SUM(New_Cases),0)*100 AS DeathPercentage
FROM PP1Covid.dbo.[CovidDeaths']
Where continent is not NULL
Group By date
order by date

--total
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(Cast(New_Deaths as int))/NULLIF(SUM(New_Cases),0)*100 AS DeathPercentage
FROM PP1Covid.dbo.[CovidDeaths']
WHERE continent is not NULL

--in the US by date
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

--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location ORDER BY dea.location, dea.date) as RollingTotalVaccinations
From PP1Covid.dbo.[CovidDeaths'] dea 
Join PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

--Use CTE 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingTotalVaccinations)
as
(
--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location ORDER BY dea.location, dea.date) as RollingTotalVaccinations
From PP1Covid.dbo.[CovidDeaths'] dea 
Join PP1Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)
Select *, (RollingTotalVaccinations/Population)*100 as PopulationPercentage
FROM PopvsVac

--Using a Temp Table

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

--Looking at Total Population vs Vaccinations

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

Select *
FROM PP1Covid.dbo.PercentPopVaccinated
