Select *
From PortfolioPrac..CovidDeaths
Order by 3,4

--Select *
--From PortfolioPrac..CovidVaccinations
--Order by 3,4

--Select data that I am going to use

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioPrac..CovidDeaths 
order by 1,2

--Looking at Total Cases VS Total Deaths
--How to convert a string datatype to a numeric/interger
Select location, date, total_cases, total_deaths,
(CONVERT(float, total_deaths)/ NULLIF(CONVERT(float, total_cases),0))*100 AS Deathpercentage
From PortfolioPrac..CovidDeaths 
Where location like'%africa'
order by 1,2


--Looking at Total Cases VS Population
--Show what percentage of population got covid
Select location, date, population, total_cases,
(CONVERT(float, total_cases)/ NULLIF(CONVERT(float, population),0))*100 AS PercentPopulationInfected
From PortfolioPrac..CovidDeaths 
Where location like'%africa'
order by 1,2

--Looking at countries with the highest infection rate compared to the population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(CONVERT(float, total_cases)/ NULLIF(CONVERT(float, population),0))*100 as PercentagePopulationInfected
From PortfolioPrac..CovidDeaths 
Where location like'%africa'
Group by location, population
order by PercentagePopulationInfected desc


--Lets break this down by continent


--Showing the continents with the highest death count
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount 
From PortfolioPrac..CovidDeaths 
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers across the world
Select date, SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(cast(New_Cases as int))*100 as DeathPercentage
From PortfolioPrac..CovidDeaths 
Where continent is not null
Group by date
order by 1,2



--Joining the table
Select *
From PortfolioPrac..CovidDeaths dea
Join PortfolioPrac..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


--Looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioPrac..CovidDeaths dea
Join PortfolioPrac..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 1,2,3


--Rolling count
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioPrac..CovidDeaths dea
Join PortfolioPrac..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 1,2,3

--Use CTE
With PopvsVac (Continent, location, date, population,New_vaccinations, RollingPeopleVaccinated )

as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioPrac..CovidDeaths dea
Join PortfolioPrac..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select*, (CONVERT(int, RollingPeopleVaccinated/population))*100
From PopvsVac


--Creating view to store data for visializations
Create view RollingPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioPrac..CovidDeaths dea
Join PortfolioPrac..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 1,2,3

Select*
From RollingPeopleVaccinated