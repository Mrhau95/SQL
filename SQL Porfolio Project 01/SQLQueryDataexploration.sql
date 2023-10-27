select *
from PorfolioProject..CovidDeaths
order by 3,4


 
 --select *
--from PorfolioProject..CovidVaccinations
--order by 3,4


--select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from PorfolioProject..CovidDeaths
order by 1,2 -- sẽ tháy được số người chết tăng theo thời gian từ tháng 2 trở đi


--Xem tỉ lệ phần trăm giữa total_case và total_deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as totaldethpercentace
from PorfolioProject..CovidDeaths
where location like '%ietnam%'and continent is not null
order by 1,2 


--xem phần trăm tổng số ca mắc so với dân số
select location, date, total_cases, population, (total_deaths/population)*100 as totalpercentage
from PorfolioProject..CovidDeaths
where location like '%ietnam%' and continent is not null
order by 1,2 


select location, date, total_cases, population, (total_cases/population)*100 as totalpercentage
from PorfolioProject..CovidDeaths
--where continent is not null
order by 1,2 


--nhìn vào các quốc gia với số ca nhiễm cao so với population

select location,population ,max(total_cases) as highestìnection,  max((total_cases/population))*100 as totalpercentage -- láy ra totalcase lớn nhất và tỉ lệ phần trăm cao nhất giữa dân số và total case
from PorfolioProject..CovidDeaths
where continent is not null
group by location, population
order by totalpercentage  desc


--let's break things down by continent
select continent ,max (cast (total_deaths as int)) as totaldeathcount
from PorfolioProject..CovidDeaths
where continent is not null
group by continent
order by totaldeathcount   desc



--thể hiện các quốc gia có số lượng người chết cao nhất
select location ,max (cast (total_deaths as int)) as totaldeathcount
from PorfolioProject..CovidDeaths
where continent is null
group by location
order by totaldeathcount   desc



--showing continents with the highest death count per population

select continent ,max (cast (total_deaths as int)) as totaldeathcount
from PorfolioProject..CovidDeaths
where continent is not null
group by continent
order by totaldeathcount   desc


--globals numbers
select  date, sum(new_cases) as totalnewcase --tổng số case mới theo thời gian
from PorfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2 

select  date, sum(new_cases)as totalnewcase, sum(cast(new_deaths as int)) as totalnewdeath, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathspercentage
from PorfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2 


select   sum(new_cases)as totalnewcase, sum(cast(new_deaths as int)) as totalnewdeath, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathspercentage
from PorfolioProject..CovidDeaths
where continent is not null
order by 1,2 


--JOIN 2 BẢNG
--LOOKING AT TOTAL POPULATION VS VACCINATIONS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PorfolioProject..CovidDeaths as dea
join PorfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--Rollingpeoplevaccinated: partition by sum sẽ cộng dồn
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from PorfolioProject..CovidDeaths as dea
join PorfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


--use CTE : số cột trong bảng cte phải trùng với số cột trong query đưa vào)
with PopvsVAC (continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated) 

as (

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from PorfolioProject..CovidDeaths as dea
join PorfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (Rollingpeoplevaccinated/population)*100 
from PopvsVAC


--temp table
drop table if exists #Percentapopulationvaccintaged
create table #Percentapopulationvaccintaged
(ontinent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
Rollingpeoplevaccinated numeric
)

insert into #Percentapopulationvaccintaged
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from PorfolioProject..CovidDeaths as dea
join PorfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *, (Rollingpeoplevaccinated/population)*100 as percentapopulationvaccintaged
from #Percentapopulationvaccintaged



--create view to store data for later visualizations
create view Percentapopulationvaccintaged as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from PorfolioProject..CovidDeaths as dea
join PorfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from Percentapopulationvaccintaged