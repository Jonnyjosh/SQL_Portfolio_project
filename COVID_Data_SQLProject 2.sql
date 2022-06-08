Select *
From SQLPortfolioProjects..Covid_Data_Set_D
where continent is not null
order by 3,4

Select *
From SQLPortfolioProjects..Covid_Data_Set_V


--SELECTING DATA THAT WILL BE ANALYZED 

Select location, date,total_cases, new_cases, total_deaths, population
From SQLPortfolioProjects..Covid_Data_Set_D
order by 1,2

--COMPARING TOTAL CASES AND TOTAL DEATHS (viewing those who had covid and later died)
-- INSIGHTS: Nigeria as at 30th of April, 2021 had 1.24% death rate.

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageofDeath
From SQLPortfolioProjects..Covid_Data_Set_D
where location like '%Nigeria%'
order by 1,2

--COMPARING TOTAL CASES AND POPULATION 
--PERCENTAGE OF NIGERIA'S TOTAL CASES AND POPULATION 

Select location, date, population, total_cases, (total_cases/population)*100 as CovidperPopulation
From SQLPortfolioProjects..Covid_Data_Set_D
Where location like '%Nigeria%'
order by 1,2

--VIEWING COUNTRIES WITH MOST INFECTION RATE AND THEIR POPULATION 

Select location, population, Max(total_cases) as MostInfectionRecorded, Max((total_cases/population))*100 as CovidperPopulation
From SQLPortfolioProjects..Covid_Data_Set_D
Group by location, population
order by CovidperPopulation desc 

-- Veiwing, by comparing Highest Death Rate per Population

Select location, MAX(cast(total_deaths as int)) as TotalNumOfDeaths
From SQLPortfolioProjects..Covid_Data_Set_D
where continent is not null
Group by location
order by TotalNumOfDeaths desc 

--VIEWING BY COMPARING HIGHEST DAETH RATE PER POPULATION PER CONTINENT 

Select continent, MAX(cast(total_deaths as int)) as TotalNumOfDeaths
From SQLPortfolioProjects..Covid_Data_Set_D
where continent is not  null
Group by continent
order by TotalNumOfDeaths desc

--OR

Select location, MAX(cast(total_deaths as int)) as TotalNumOfDeaths
From SQLPortfolioProjects..Covid_Data_Set_D
where continent is  null
Group by location
order by TotalNumOfDeaths desc

--VIEWING WORLD DATA 

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
(new_cases)*100 as percentageOfDeath
From SQLPortfolioProjects..Covid_Data_Set_D
where continent is not null
group by date
order by 1,2

--REMOVING THE DATA FILTER

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM
(new_cases)*100 as percentageOfDeath
From SQLPortfolioProjects..Covid_Data_Set_D
where continent is not null
--group by date
order by 1,2

-- JOINING BOTH COVID DEATHS AND VACCINATIONS TABLES

Select *
From SQLPortfolioProjects..Covid_Data_Set_D D
Join SQLPortfolioProjects..Covid_Data_Set_V V
    on D.location = V.location
	and D.date = V.date
	
--VIEWING TOTAL POPULATION COMPARED TO VACCINATION
--USING CTE
 
with PopuVsVaccin (continent, location, Date, Population, New_vaccinations, ContiniuingPeopleVaccinated)
as 	
(
    Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
	SUM(Cast(V.new_vaccinations as int)) over (partition by D.location order by D.location, D.date)
	as ContiniuingPeopleVaccinated  
From SQLPortfolioProjects..Covid_Data_Set_D D
Join SQLPortfolioProjects..Covid_Data_Set_V V
    on D.location = V.location
	and D.date = V.date 
where D.continent is not null

)
select *, (ContiniuingPeopleVaccinated/Population)*100
from PopuVsVaccin

--TEMP TABLE

Create Table #PercentofPopulationVaccinated
(
continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
ContiniuingPeopleVaccinated numeric)

Insert into #PercentofPopulationVaccinated
 Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
	SUM(Cast(V.new_vaccinations as int)) over (partition by D.location order by D.location, D.date)
	as ContiniuingPeopleVaccinated  
From SQLPortfolioProjects..Covid_Data_Set_D D
Join SQLPortfolioProjects..Covid_Data_Set_V V
    on D.location = V.location
	and D.date = V.date 
where D.continent is not null

select *, (ContiniuingPeopleVaccinated/Population)*100
from #PercentofPopulationVaccinated

--COMMENTING WHERE OUT

drop table if exists  #PercentofPopulationVaccinated 
Create Table #PercentofPopulationVaccinated
(
continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
ContiniuingPeopleVaccinated numeric)

Insert into #PercentofPopulationVaccinated
 Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
	SUM(Cast(V.new_vaccinations as int)) over (partition by D.location order by D.location, D.date)
	as ContiniuingPeopleVaccinated  
From SQLPortfolioProjects..Covid_Data_Set_D D
Join SQLPortfolioProjects..Covid_Data_Set_V V
    on D.location = V.location
	and D.date = V.date 
--where D.continent is not null

select *, (ContiniuingPeopleVaccinated/Population)*100
from #PercentofPopulationVaccinated

--CREATING VIEW FOR LATER VISUALIZATION

Create view PercentofPopulationVaccinated as
Select D.continent, D.location, D.date, D.population, V.new_vaccinations,
	SUM(Cast(V.new_vaccinations as int)) over (partition by D.location order by D.location, D.date)
	as ContiniuingPeopleVaccinated  
From SQLPortfolioProjects..Covid_Data_Set_D D
Join SQLPortfolioProjects..Covid_Data_Set_V V
    on D.location = V.location
	and D.date = V.date 
where D.continent is not null
--order by 2,3
