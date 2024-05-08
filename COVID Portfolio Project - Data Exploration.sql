/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, 
			Aggregate Functions, Creating Views, Converting Data Types
*/

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total cases vs Total deaths
-- shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where location like '%africa%'
and continent is not null
order by 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got Covid
select location, date, population, total_cases, (total_cases / population )*100 as populationInfected_percentage
from PortfolioProject..CovidDeaths
--where location like '%africa%'
where continent is not null
order by 1,2


-- Looking at countries with highest infection rate compared to population
select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases / population ))*100 as populationInfected_percentage
from PortfolioProject..CovidDeaths
--where location like '%africa%'
where continent is not null
group by location, population
order by populationInfected_percentage desc

-- Showing Countries with highest death count per population
select location, MAX(CAST(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
--where location like '%africa%'
where continent is not null
group by location
order by total_death_count desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
	
select continent, MAX(CAST(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
--where location like '%africa%'
where continent is not null
group by continent
order by total_death_count desc

select continent, MAX(CAST(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
--where location like '%africa%'
where continent is not null
group by continent
order by total_death_count desc

-- GLOBAL NUMBERS
select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases)) * 100 as death_percentage
from PortfolioProject..CovidDeaths
--where location like '%africa%'
where continent is not null
group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location order by dea.location , dea.date) as rollingPeople_vaccinationated 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, rollingPeople_vaccinationated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location order by dea.location , dea.date) as rollingPeople_vaccinationated 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac .location
	and dea.date = vac.date
where dea.continent is not null
)
Select * , (rollingPeople_vaccinationated/Population) * 100 as population_vaccinated_percentage
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime, 
	Population numeric,
	New_vaccinations numeric,
	rollingPeople_vaccinationated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location order by dea.location , dea.date) as rollingPeople_vaccinationated 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac .location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3
Select * , (rollingPeople_vaccinationated/Population) * 100 as population_vaccinated_percentage
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location order by dea.location , dea.date) as rollingPeople_vaccinationated 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac .location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3
