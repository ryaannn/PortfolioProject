Select *
From SQLPortfolio..CovidDeaths
Where continent is not null
Order By 3,4

--Select *
--From SQLPortfolio..CovidVaccinations
--Order By 3,4

-- Select Data we will be using

Select Location, date, total_cases, new_cases, total_deaths, population
From SQLPortfolio..CovidDeaths
Where continent is not null
Order By 1,2


-- Looking at the Total Cases vs Total Deaths per country
-- Likelihood of dying if you get Covid by country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
From SQLPortfolio..CovidDeaths
Where location like '%canada%'
and continent is not null
Order By 1,2

-- Looking at Total Cases vs Population
--Show what percentage of population contracted Covid by country
Select Location, date, total_cases, population, (total_cases/population)*100 as ContractionRate
From SQLPortfolio..CovidDeaths
Where location like '%canada%'
and continent is not null
Order By 1,2

-- Looking at countries with highest contraction rate compared to population

Select Location, MAX(total_cases) as HighestContractionCount, population, MAX((total_cases/population))*100 as PopulationContractionRate
From SQLPortfolio..CovidDeaths
--Where location like '%canada%'
Where continent is not null
Group By location, population
Order By PopulationContractionRate desc

--Looking at countries with highest death count compared to population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From SQLPortfolio..CovidDeaths
--Where location like '%canada%'
Where continent is not null
Group By location
Order By TotalDeathCount desc

-- Looking at highest total death count by continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From SQLPortfolio..CovidDeaths
--Where location like '%canada%'
Where continent is null
Group By location
Order By TotalDeathCount desc

-- Looking at global death rate by day

Select date, SUM(total_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathRate
From SQLPortfolio..CovidDeaths
--Where location like '%canada%'
Where continent is not null
Group By date
Order By 1,2

-- Looking at the total global death rate

Select SUM(total_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathRate
From SQLPortfolio..CovidDeaths
--Where location like '%canada%'
Where continent is not null
--Group By date
Order By 1,2

-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by 
	dea.location, dea.date) as RollingVaccinationCount, 
	--(RollingVaccinationCount/population)*100
From SQLPortfolio..CovidDeaths dea
JOIN SQLPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3

-- CTE USE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinationCount)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by 
	dea.location, dea.date) as RollingVaccinationCount 
	--(RollingVaccinationCount/population)*100
From SQLPortfolio..CovidDeaths dea
JOIN SQLPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)

SELECT *, (RollingVaccinationCount/population)*100
From PopvsVac

-- TEMP TABLE USE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinationCount numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by 
	dea.location, dea.date) as RollingVaccinationCount 
	--(RollingVaccinationCount/population)*100
From SQLPortfolio..CovidDeaths dea
JOIN SQLPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3

SELECT *, (RollingVaccinationCount/population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by 
	dea.location, dea.date) as RollingVaccinationCount 
	--(RollingVaccinationCount/population)*100
From SQLPortfolio..CovidDeaths dea
JOIN SQLPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3

SELECT *
From PercentPopulationVaccinated