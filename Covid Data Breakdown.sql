--Selecting data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2;

--Looking at Total Cases vs Total Deaths
--Shows Likelihood of dying if you contract covid in the USA
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1, 2;

--Looking at the total cases vs population
--Shows what percentage of population got Covid
SELECT Location, date, population, total_cases, (total_cases/population) * 100 AS PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1, 2;

--Looking at countries with highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

--Showing the countries with the highest death count per population
SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC;

--Breaking down by continent
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Global numbers
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases) *  100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 1, 2;

 --Looking at total population vs vaccinations
 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PopvsVac