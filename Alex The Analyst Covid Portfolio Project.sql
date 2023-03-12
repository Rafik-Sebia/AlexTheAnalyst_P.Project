SELECT *
FROM AlexTheAnalyst_PortfolioProject.dbo.CovidDeaths
Where continent is not null
order by 3, 4

--SELECT *
--FROM AlexTheAnalyst_PortfolioProject.dbo.CovidVaccinations
--order by 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
FROM AlexTheAnalyst_PortfolioProject.dbo.CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercantage
FROM AlexTheAnalyst_PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population) * 100 as PercantPopulationInfected
FROM AlexTheAnalyst_PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercantPopulationInfected
FROM AlexTheAnalyst_PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Group by Location, population
order by PercantPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM AlexTheAnalyst_PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM AlexTheAnalyst_PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM AlexTheAnalyst_PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
-- Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) over (
Partition by dea.location Order by dea.location, dea.date
) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM AlexTheAnalyst_PortfolioProject..CovidDeaths dea
JOIN AlexTheAnalyst_PortfolioProject..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) over (
Partition by dea.location Order by dea.location, dea.date
) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM AlexTheAnalyst_PortfolioProject..CovidDeaths dea
JOIN AlexTheAnalyst_PortfolioProject..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
--Where dea.continent is not null
-- order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creatinv View to store data for later visualizations

Create View  PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) over (
Partition by dea.location Order by dea.location, dea.date
) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM AlexTheAnalyst_PortfolioProject..CovidDeaths dea
JOIN AlexTheAnalyst_PortfolioProject..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3

 Select *
 From PercentPopulationVaccinated