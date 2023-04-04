SELECT*
FROM PortfolioProject..CovidDeaths
WHERE Continent is not null
ORDER BY 3,4

--SELECT*
--FROM PortfolioProject..CovidVaccinations 
--ORDER BY 3,4
--Select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE Continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Total Death
--Shows liklihood of dying if you contract Covid in your country

SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS int)/CAST(total_cases AS int))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at Total Cases vs population
--Shows what percentage of population got Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%state%'
ORDER BY 1,2

--Looking at countries with highest Infection Rate compared to Population

SELECT Location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%state%'
GROUP BY Location, Population 
ORDER BY PercentPopulationInfected desc

--Showing Countries with the Highest Death Count per Population 

SELECT Location, MAX(Cast(Total_deaths AS int)) AS TotalDeathCount
FROM portfolioProject..CovidDeaths
--WHERE location like '%state%'
WHERE Continent is not null
GROUP BY Location 
ORDER BY TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing the Continents with the highest Death Count per Population

SELECT continent, MAX(Cast(Total_deaths AS int)) AS TotalDeathCount
FROM portfolioProject..CovidDeaths
--WHERE location like '%state%'
WHERE Continent is not null
GROUP BY continent 
ORDER BY TotalDeathCount desc

--Global Numbers

Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int)), SUM(new_cases) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.Location, dea.Date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3



--Use CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.Location, dea.Date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT*, (RollingPeopleVaccinated/population)*100 
FROM PopvsVac

--Temp Table

Drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.Location, dea.Date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT*, (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated 

--Creating view to store data for later visualizations

CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.Location, dea.Date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT * 
FROM PercentPopulationVaccinated 