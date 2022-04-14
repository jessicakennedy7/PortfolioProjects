SELECT * 
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * FROM CovidPortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select data to use for project

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Review Total Cases vs Total Deaths
--Shows likelihood of dying if Covid is contracted in a particular country

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location like 'United States'
ORDER BY 1,2


--Reviewing Total Cases vs Population
--Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location like 'United States'
ORDER BY 1,2


--Reviewing Countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location like 'United States'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


--Showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location like 'United States'
GROUP BY location, population
ORDER BY TotalDeathCount desc

--Breaking down by continent


--Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location like 'United States'
GROUP BY continent
ORDER BY TotalDeathCount desc


--Global Numbers

SELECT date as Date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2



-- Total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, 
vax.new_vaccinations, SUM(cast(vax.new_vaccinations as bigint)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent is not null
ORDER BY 2,3


--use CTE

WITH PopvsVax (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, 
vax.new_vaccinations, SUM(cast(vax.new_vaccinations as bigint)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100 FROM PopvsVax



--temp table

DROP table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, 
vax.new_vaccinations, SUM(cast(vax.new_vaccinations as bigint)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVax



-- create view to store data for visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, 
vax.new_vaccinations, SUM(cast(vax.new_vaccinations as bigint)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent is not null
--ORDER BY 2,3

