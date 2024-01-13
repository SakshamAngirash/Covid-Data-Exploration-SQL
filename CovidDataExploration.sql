select * from CovidDataExp.dbo.CovidDeaths
order by 3,4


--select * from CovidDataExp.dbo.CovidVaccinations
--order by 3,4


select location,date,total_cases,new_cases,total_deaths,population
from CovidDataExp.dbo.CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--shows the likelyhood of dying if you are diagonsed with covid in india
select location,date,total_cases,total_deaths,((total_deaths/total_cases)*100) as DeathPercentage
from CovidDataExp.dbo.CovidDeaths
where location like '%india%' and continent is not null
order by 1,2


--Looking at Total Cases vs Population in india 
select location,date,total_cases,population,((total_cases/population)*100) as AffectedPopulationPercentage
from CovidDataExp.dbo.CovidDeaths
where location like '%india%' and continent is not null
order by 1,2

--Country having highest infecation rate wrt population 
select location,population,max(total_cases)as HighestInfection,max((total_cases/population)*100) as HIRate
from CovidDataExp.dbo.CovidDeaths
where continent is not null
group by location,population 
order by HIRate desc


--Death Rate wrt to Population 
select location , population , MAX(cast(total_deaths as int)) as MaxTotalDeaths,max((total_deaths/population)*100) as DeathRateWRTpop
from CovidDataExp.dbo.CovidDeaths
where continent is not null
group by location , population 
order by DeathRateWRTpop desc

--select * from CovidDataExp.dbo.CovidDeaths
--where continent is not null
--order by 3,4

--LETS BREAK THINGS BY CONTINENT
select continent , MAX(cast(total_deaths as int)) as MaxTotalDeaths,max((total_deaths/population)*100) as DeathRateWRTpop
from CovidDataExp.dbo.CovidDeaths
where continent is not null
group by continent 
order by DeathRateWRTpop desc



--showing continents with the highest death count wrt population 
select continent , sum(cast(new_deaths as int)) as MaxDeaths,max(total_deaths/population)as maxrate
from CovidDataExp.dbo.CovidDeaths
where continent is not null
group by continent
order by maxrate


--GLOBAL NUMBERS

select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as
DeathPercentage
from CovidDataExp.dbo.CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as
DeathPercentage
from CovidDataExp.dbo.CovidDeaths
where continent is not null
order by 1,2




--JOINING BOTH TABLES 

--looking at total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingNewVaccinations
from CovidDataExp..CovidDeaths dea
join CovidDataExp..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null
order by 1,2,3


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingNewVaccinations
from CovidDataExp..CovidDeaths dea
join CovidDataExp..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

--USE CTE 
with PopvsVac(continent,location , date ,population ,new_vaccinations,RollingPeopleVaccination )
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingNewVaccinations
from CovidDataExp..CovidDeaths dea
join CovidDataExp..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null
)
select*,(RollingPeopleVaccination/population)*100
from PopvsVac

--USING TEMP TABLE 
Drop table if exists #PopvsVac
create table #PopvsVac
(continent nvarchar(255),
location nvarchar(255), 
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccination numeric)


insert into #PopvsVac
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingNewVaccinations
from CovidDataExp..CovidDeaths dea
join CovidDataExp..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null

select*,(RollingPeopleVaccination/population)*100
from #PopvsVac



--creating view to store data for later visualisations
create view PercentPopulationVaccinated2 as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingNewVaccinations
from CovidDataExp..CovidDeaths dea
join CovidDataExp..CovidVaccinations vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null 


select * from PercentPopulationVaccinated2