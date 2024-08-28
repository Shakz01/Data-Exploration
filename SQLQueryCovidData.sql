-- Hi, I am a 10Analytics student
--Exploring the Death and Vaccination tables
SELECT *
FROM NewPortfolio.dbo.Death

SELECT *
FROM NewPortfolio.dbo.Vaccination

--Mapping out the needed table from the Death table
SELECT continent, location,date, population, new_cases, total_cases, new_deaths, total_deaths, hosp_patients, icu_patients
FROM NewPortfolio.dbo.Death

--total cases, total death, icu patients, hospital patients
--the are all in nvarchar format which is not suitable for calculations.
--We will need to CAST the values into Numeric format to make use of mathematical opetation
SELECT continent, location,date, population, new_cases, CAST(total_cases AS NUMERIC) total_cases, 
				new_deaths, CAST(total_deaths AS NUMERIC) total_deaths, CAST(hosp_patients AS NUMERIC) hospital_patients,
				CAST(icu_patients AS NUMERIC) icu_patients
FROM NewPortfolio.dbo.Death
ORDER BY 10 DESC

--continent data was also included in the location and it has equivalent of NUll in the continent
--so we can filter out only the country with the null
SELECT continent, location,date, population, new_cases, CAST(total_cases AS NUMERIC) total_cases, 
				new_deaths, CAST(total_deaths AS NUMERIC) total_deaths, CAST(hosp_patients AS NUMERIC) hospital_patients,
				CAST(icu_patients AS NUMERIC) icu_patients
FROM NewPortfolio.dbo.Death
WHERE continent IS NOT NULL
ORDER BY 4 DESC

--1. what is the mortality rate (percentage of deaths among total cases) in different locations.
SELECT location, MAX(CAST(total_cases AS NUMERIC)) total_cases, 
				 MAX(CAST(total_deaths AS NUMERIC)) total_deaths,
				ROUND((MAX(CAST(total_deaths AS NUMERIC))/MAX(CAST(total_cases AS NUMERIC)))*100, 2) MortalityRate
				--ROUND function will round up the decimals to 2 decimal place
FROM NewPortfolio.dbo.Death
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 4 DESC
--OR
SELECT Location, SUM(new_cases) TotalCases, SUM((new_deaths)) TotalDeath,
				ROUND((SUM(new_deaths)/NULLIF(SUM(new_cases), 0))*100, 2)  MortalityRate --NULLIF will return NULL if the denominator is 0
		FROM NewPortfolio.dbo.Death
		WHERE continent IS NOT  NULL
		--WHERE Location LIKE 'Nigeria'
GROUP BY location
ORDER BY 4 DESC

--2. Correlation between population size and the total number of cases or deaths.
SELECT location, population, MAX(CAST(total_cases AS NUMERIC)) total_cases
FROM NewPortfolio.dbo.Death
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 3 DESC
--OR
SELECT Location, population, SUM(new_cases) TotalCases
		FROM NewPortfolio.dbo.Death
		WHERE continent IS NOT  NULL
		--WHERE Location LIKE 'Nigeria'
GROUP BY location, population
ORDER BY 3 DESC 

--3. Correlation between population size and the total number of deaths.
SELECT location, population, MAX(CAST(total_deaths AS NUMERIC)) total_deaths
FROM NewPortfolio.dbo.Death
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 3 DESC
--OR
SELECT Location, population, SUM((new_deaths)) TotalDeath
		FROM NewPortfolio.dbo.Death
		WHERE continent IS NOT  NULL
		--WHERE Location LIKE 'Nigeria'
GROUP BY location, population
ORDER BY 3 DESC 

--4. showing individal countries highest infection rate wrt population
SELECT Location, population, MAX(CAST(total_cases AS NUMERIC)) TotalCases,
		(MAX(CAST(total_cases AS NUMERIC)/population))*100 CasesToPopulationPercent
FROM NewPortfolio.dbo.Death
WHERE continent IS NOT  NULL
--WHERE Location LIKE 'Nigeria'
GROUP BY location, population
ORDER BY 4 desc

--5. --Global data about the new cases, death
SELECT location, population, MAX(CAST(total_cases AS NUMERIC)) TotalCases,
		MAX(CAST(total_deaths AS NUMERIC)) total_deaths
FROM NewPortfolio.dbo.Death
WHERE location IN ('Africa', 'Europe', 'Asia', 'North America', 'South America', 'Oceania')
GROUP BY location, population
ORDER BY 4 DESC
--OR
SELECT Location, population,SUM(new_cases) TotalCases, SUM((new_deaths)) TotalDeath
		FROM NewPortfolio.dbo.Death
		WHERE location IN ('Africa', 'Europe', 'Asia', 'North America', 'Sout,h America', 'Oceania')
GROUP BY location, population
ORDER BY 4 DESC

--6. Global numbers for deaths.
--Numbers by continent
SELECT location, population, SUM(new_cases) TotalCases, SUM(CAST(new_deaths AS NUMERIC)) TotalDeath 
		FROM NewPortfolio.dbo.Death
		WHERE continent IS NULL AND location IN ('Africa', 'Europe', 'Asia', 'North America', 'South America', 'Oceania')
		group by population, location
		ORDER BY 2 DESC

--using CTE to get world number
WITH GlobalNumber (location,population, TotalCases, TotalDeath)
AS
(

SELECT location, population, SUM(new_cases) TotalCases, SUM(CAST(new_deaths AS NUMERIC)) TotalDeath 
		FROM NewPortfolio.dbo.Death
		WHERE continent IS NULL AND location IN ('Africa', 'Europe', 'Asia', 'North America', 'South America', 'Oceania')
		group by population, location
)
SELECT sum(population) World_Population, sum(TotalCases) Total_Cases, sum(TotalDeath) Total_Death, 
		ROUND((sum(TotalDeath)/sum(TotalCases))*100, 3) Death_to_Cases_Percentage
FROM GlobalNumber

--6.	Percentage of the population has been vaccinated in each location?

SELECT death.location, death.population,  MAX(CAST(vac.total_vaccinations AS NUMERIC)) TotalVaccination,
			ROUND((MAX(CAST(vac.total_vaccinations AS NUMERIC))/death.population)*100, 3)  PercentageOfVaccinatedPopulation
FROM NewPortfolio.dbo.Death			death
JOIN NewPortfolio.dbo.Vaccination	vac
	ON death.date = vac.date
	AND death.location = vac.location
	WHERE death.continent IS NOT NULL --AND death.location LIKE 'Nigeria'
	GROUP BY death.location, death.population
	ORDER BY 4 DESC

CREATE VIEW PercentageOfVaccinatedPopulation
AS
SELECT death.location, death.population,  MAX(CAST(vac.total_vaccinations AS NUMERIC)) TotalVaccination,
			ROUND((MAX(CAST(vac.total_vaccinations AS NUMERIC))/death.population)*100, 3)  PercentageOfVaccinatedPopulation
FROM NewPortfolio.dbo.Death			death
JOIN NewPortfolio.dbo.Vaccination	vac
	ON death.date = vac.date
	AND death.location = vac.location
	WHERE death.continent IS NOT NULL --AND death.location LIKE 'Nigeria'
	GROUP BY death.location, death.population
	--ORDER BY 4 DESC

SELECT *
FROM PercentageOfVaccinatedPopulation