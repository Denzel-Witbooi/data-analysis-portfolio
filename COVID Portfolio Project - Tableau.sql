/*
	Queries used for Tableau Project
*/

-- 1.
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
-- Where location like '%states%'
where continent is not null
-- group by date
order by 1,2

-- 2.
-- We take these out as they are not in the above queries and want
-- to stay consistent
-- European Union is part of Europe

select location, SUM(CAST(new_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null
and location not in ('World', 'European Union', 'International')
group by location
order by TotalDeathCount desc

-- 3.

select location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases / population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

-- 4.
select location, population, date, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases / population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- Where location like '%states%'
group by location, population, date
order by PercentPopulationInfected desc