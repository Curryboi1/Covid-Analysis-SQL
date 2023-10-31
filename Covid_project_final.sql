-- Lets explore the dataset 

select * from CovidDeaths_csv


Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From P..CovidDeaths_csv
order by 1,2

--Average population per country ?

select location,avg(population) as avg_population_country
from dbo.CovidDeaths_csv
group by location

-- The minimum population 

select min(population) 
from dbo.CovidDeaths_csv



-- Lets Count the Percentage of Death ratio 

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from P..CovidDeaths_csv
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country (I.e United States, Iceland,Ireland,Poland)

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from P..CovidDeaths_csv
where location like '%states'

-- Deathration in Finland,Ireland,Iceland,New Zealand, Poland, Thailand

Select location,continent date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from P..CovidDeaths_csv
where location like '%and'


Select location,continent, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from P..CovidDeaths_csv
where location like 'and%'

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid



SELECT Location, 
       Date, 
       Population, 
       Total_Cases,
       (CAST(Total_Cases AS float) / CAST(Population AS float) * 100) AS PercentPopulationInfected
FROM CovidDeaths_csv
ORDER BY Location, Date;


SELECT Location, Date, Population, Total_Cases,
       (CAST(Total_Cases AS float) / CAST(Population AS float) * 100) AS PercentPopulationInfected
FROM CovidDeaths_csv
ORDER BY Location, Date;

-- percentage of people infected where population is >9999999

SELECT Location, Date, Population, Total_Cases,
       (CAST(Total_Cases AS float) / CAST(Population AS float) * 100) AS PercentPopulationInfected
FROM CovidDeaths_csv
where population>=9999999
ORDER BY Location, Date;

-- Population vs max total cases 


select location,population,max(total_cases)as max_totalcase
from dbo.CovidDeaths_csv
group by population,location 

-- Countries with Highest Infection Rate compared to Population

select location,population,max(total_cases) as highestInfectionCount,max((Cast(total_cases as float)/population))*100 percantageInfectionCount
from dbo.CovidDeaths_csv
group by location,population
order by location
asc 

-- Countries with Highest Death Count per Population

select location,population,Max(cast(total_deaths as float)) as TotalDeathCount
from dbo.CovidDeaths_csv
Where continent is not null 
group by location,population
order by TotalDeathCount
desc 

 --BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths_csv
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as float))/SUM(cast(New_Cases as float))*100 as DeathPercentage
From dbo.CovidDeaths_csv
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

select * 
from p..CovidVaccinations_csv

                                  -- Joining data 

select * from p..CovidDeaths_csv dea 
join p..CovidVaccinations_csv vac
on dea.location=vac.location
and dea.date=vac.date


-- total population vs vaccinations 

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from p..CovidDeaths_csv dea 
join p..CovidVaccinations_csv vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 

--Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From P..CovidDeaths_csv dea
Join P..CovidVaccinations_csv vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From P..CovidDeaths_csv dea
Join P..CovidVaccinations_csv vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From P..CovidDeaths_csv dea
Join P..CovidVaccinations_csv vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From P..CovidDeaths_csv	 dea
Join P..CovidVaccinations_csv vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 