use [PortfolioProject ];

SELECT * FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY LOCATION DESC ;


--Looking at Total Cases Vs Total Deats 

SELECT location , date , total_cases , total_deaths , (total_deaths / total_cases)*100 as DeathPercentage 
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2; 


--Looking at Total Cases Vs Total Deats at location having  United in there name 

SELECT location , date , total_cases , total_deaths , (total_deaths / total_cases)*100 as DeathPercentage 
FROM CovidDeaths$ 
WHERE location LIKE '%United%' and continent IS NOT NULL
ORDER BY 1,2; 


--Looking at Total Cases Vs Population 

SELECT location , date , total_cases , population , (total_cases/ population)*100 as 'Total Cases Percentage'
FROM CovidDeaths$ 
WHERE continent IS NOT NULL
ORDER BY 1,2;  


--Looking at Countries with Highest Infection Rate compared to Population 

SELECT location , Population , MAX(total_cases) as HighestInfected, MAX((total_cases/ population)*100) as 'Total Cases Percentage'
FROM CovidDeaths$ 
WHERE continent is not null
GROUP BY location ,Population 
ORDER BY [Total Cases Percentage] DESC;  

--SELECT location , population  FROM CovidDeaths$
--where location like 'united%'
--GROUP BY location , population ;


-- Showing Countries with Highest Death Count Per Population 

SELECT location , MAX(CAST(total_deaths as int)) AS MaxDeathCount  FROM CovidDeaths$
WHERE Continent IS NOT NULL 
GROUP BY LOCATION 
ORDER BY MaxDeathCount desc;  


-- Showing Continent with Highest Death Count Per Population 

SELECT continent , MAX(CAST(total_deaths as int)) AS MaxDeathCount  FROM CovidDeaths$
WHERE Continent IS NOT NULL 
GROUP BY continent 
ORDER BY MaxDeathCount desc;  


-- Total Death Percentage in Daily basis ? 


-- Looking at Total Population Vs Vaccination 



SELECT DISTINCT  CD.continent , CD.location , CD.date ,  CD.population , CV.new_vaccinations,
SUM(Convert(int , CV.new_vaccinations )) OVER (PARTITION BY CD.location order by CD.location, cd.date)  as RollingPeopleVaccinated
FROM CovidDeaths$  CD
JOIN CovidVaccinations$  CV ON  CD.location = CV.location AND  CD.date = CV.date
Where CD.continent is not null   
ORDER BY 2,3 ; 


-- Using CTE to perform Calculation on Partition By in previous query
--A Common Table Expression (CTE) is a named temporary result set within a SQL query that can be referenced by name within the same query. It provides a way to break down complex queries into modular and more readable components.
WITH POPvsVaccinations(Continent , Location , Date , Population , New_Vaccination , RollingPeopleVaccinated)
as 
(
	SELECT DISTINCT  CD.continent , CD.location , CD.date ,  CD.population , CV.new_vaccinations,
SUM(Convert(int , CV.new_vaccinations )) OVER (PARTITION BY CD.location order by CD.location, cd.date) 
FROM CovidDeaths$  CD
JOIN CovidVaccinations$  CV ON  CD.location = CV.location AND  CD.date = CV.date
Where CD.continent is not null   
--ORDER BY 2,3 
)  
SELECT *, (RollingPeopleVaccinated/Population)*100 from POPvsVaccinations ;  


-- Using Temp Table to perform Calculation on Partition By in previous query

CREATE TABLE #TEMP (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric

);

insert into #TEMP 
SELECT DISTINCT  CD.continent , CD.location , CD.date ,  CD.population , CV.new_vaccinations,
SUM(Convert(int , CV.new_vaccinations )) OVER (PARTITION BY CD.location order by CD.location, cd.date) 
FROM CovidDeaths$  CD
JOIN CovidVaccinations$  CV ON  CD.location = CV.location AND  CD.date = CV.date
Where CD.continent is not null   
--ORDER BY 2,3 
;

Select distinct *, (RollingPeopleVaccinated/Population)*100 
from #temp
where  (RollingPeopleVaccinated/Population)*100 is not null  ;


--view 

CREATE VIEW SUN AS
SELECT DISTINCT 
	CD.continent , 
	CD.location , 
	CD.date ,  
	CD.population , 
	CV.new_vaccinations, 
	SUM(Convert(int , CV.new_vaccinations )) OVER (PARTITION BY CD.location order by CD.location, cd.date) AS Rollin 
FROM CovidDeaths$  CD
JOIN CovidVaccinations$  CV ON  CD.location = CV.location AND  CD.date = CV.date
Where CD.continent is not null  ; 
--ORDER BY 2,3 

SELECT *, (Rollin/Population)*100 as vacVSpop  FROM SUN
where (Rollin/Population)*100 is not null;