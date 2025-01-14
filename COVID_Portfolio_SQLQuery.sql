--select *
--from Covid19_Project..CovidDeaths
--order by 3,4

select location,date,total_cases, new_cases, total_deaths, population
from Covid19_Project..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in your country
select location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Covid19_Project..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Total case vs Population
select location, date, Population, total_cases, (total_cases/population)*100 as PercentageofPopulationInfected
from Covid19_Project..CovidDeaths
where location = 'United States'
order by 1,2

-- Looking at Contries with Highest Infection Rate compared to Population
select location, Population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentageofPopulationInfected
from Covid19_Project..CovidDeaths
group by location, population
order by PercentageofPopulationInfected desc




--Show Countries with Highest Death Count per Population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from Covid19_Project..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

select *
from Covid19_Project..CovidDeaths
order by 3,4

-- LET'S BREAK THINGS DOWN BY CONTINENT
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Covid19_Project..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

select location, max(cast(total_deaths as int)) as TotalDeathCount
from Covid19_Project..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- Showing continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Covid19_Project..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
	 sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Covid19_Project..CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
	 sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Covid19_Project..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location 
	order by dea.location, dea.date) as RollingPeopleVaccinated
from Covid19_Project..CovidDeaths dea
join Covid19_Project..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1, 2, 3

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as (
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(convert(int, vac.new_vaccinations)) over (partition by dea.location 
		order by dea.location, dea.date) as RollingPeopleVaccinated
	from Covid19_Project..CovidDeaths dea
	join Covid19_Project..CovidVaccination vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
)
select *, (RollingPeopleVaccinated / Population)*100
from PopvsVac

-- TEMP TABLE
drop table if exists #PercentPopulationVaccinated

create Table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location 
	order by dea.location, dea.date) as RollingPeopleVaccinated
from Covid19_Project..CovidDeaths dea
join Covid19_Project..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated / Population)*100
from #PercentPopulationVaccinated

-- Creating view to store data fror later visualization

drop view if exists percentpopulationvaccinated;

USE Covid19_Project;

create VIEW PercentPopulationVaccinated as
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    sum(convert(int, vac.new_vaccinations)) over (
        partition BY dea.location 
        order by dea.location, dea.date
    ) as rollingpeoplevaccinated
from covid19_project..coviddeaths dea
join covid19_project..covidvaccination vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null;


select *
from PercentPopulationVaccinated