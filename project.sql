SELECT *
FROM CovidDeaths
ORDER BY 3


--SELECT *
--FROM CovidVacination
--ORDER BY 3

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Total cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
Where location like '%states'
ORDER BY 1,2


-- Total cases vs population

select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From CovidDeaths
where location = 'India'
order by 1,2



-- Looking for countries  with highest Infection rate compared to Pupolation
  

select location, population, max(total_cases), max((total_cases/population))*100 as PercentagePopulationInfected
From CovidDeaths
Group by location, population
order by PercentagePopulationInfected desc


-- Looking for countries  with highest death rate compared to Pupolation

select location, max(total_deaths) as TotalDeathCount
From CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc



--select location, max(total_deaths) as TotalDeathCount
--From CovidDeaths
--Group by location
--order by TotalDeathCount desc


-- Looking for continents  with highest death rate compared to Pupolation

select continent, max(total_deaths) as TotalDeathCount
From CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Death percentage??????????????????????????????????????????????????

Select date, 
sum(cast(new_cases as int)), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/ sum(cast(new_cases as int)) * 100 as DeathPercentage
FROM CovidDeaths
Where continent is not null
group by  date 



select date,sum(cast(new_deaths as int)) ,sum(cast(new_cases as float))
From CovidDeaths
group by date


select date,sum(cast(new_deaths as int)) /sum(cast(new_cases as float))
From CovidDeaths
group by date

------------------------------------------------------------------------

select (new_vaccinations) from CovidVacination

--- totals population vs vaccination using CTE

;With PopVsVac (continent, location, date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select cd.continent,cd.location, cd.date, cd.population,cv.new_vaccinations,
sum(convert(bigint, cv.new_vaccinations)) OVER (Partition by cd.Location order by cd.location,cd.date)
as RollingPeopleVaccinated
from CovidDeaths cd
JOIN 
CovidVacination cv
ON 
cd.location = cv.location 
and
cd.date = cv.date
where cd.continent is not null
)
Select *, RollingPeopleVaccinated/ population *100
from popVSvac


------ Using tempo table
Drop table if exists #PercentagePopVaccinated
Create table #PercentagePopVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population bigint,
new_vaccinations bigint,
RollingPeopleVaccinated bigint
)

Insert into #PercentagePopVaccinated
select cd.continent,cd.location, cd.date, cd.population,cv.new_vaccinations,
sum(convert(float, cv.new_vaccinations)) OVER (Partition by cd.Location order by cd.location,cd.date)
as RollingPeopleVaccinated
from CovidDeaths cd
JOIN 
CovidVacination cv
ON 
cd.location = cv.location 
and
cd.date = cv.date
where cd.continent is not null

select *, RollingPeopleVaccinated/ population *100 
From
#PercentagePopVaccinated


--- Creating view
Create view PercentagePopVaccinated as
select cd.continent,cd.location, cd.date, cd.population,cv.new_vaccinations,
sum(convert(float, cv.new_vaccinations)) OVER (Partition by cd.Location order by cd.location,cd.date)
as RollingPeopleVaccinated
from CovidDeaths cd
JOIN 
CovidVacination cv
ON 
cd.location = cv.location 
and
cd.date = cv.date
where cd.continent is not null

Select * From PercentagePopVaccinated