SELECT *
FROM cbsa;

SELECT *
FROM drug;

SELECT *
FROM fips_county;

SELECT *
FROM overdose_deaths;

SELECT *
FROM population;

SELECT *
FROM prescriber;

SELECT *
FROM prescription;

SELECT *
FROM zip_fips;

-- 1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.


SELECT DISTINCT(npi), SUM(total_claim_count) AS total_claims
FROM prescription
GROUP BY npi
ORDER BY total_claims DESC;

-- Answer: NPI 1881634483 with total claims 99707

-- 1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT DISTINCT(npi), p2.nppes_provider_first_name, p2.nppes_provider_last_org_name, p2.specialty_description, SUM(total_claim_count) AS total_claims
FROM prescription AS p1
INNER JOIN prescriber AS p2 USING (NPI)
GROUP BY npi,p2.nppes_provider_first_name, p2.nppes_provider_last_org_name, p2.specialty_description
ORDER BY total_claims DESC;

-- Answer: Bruce Pendley, Family Practce with total claims 99707

-- 2a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT p2.specialty_description, SUM(p1.total_claim_count) AS total_claims
FROM prescriber AS p2
INNER JOIN prescription AS p1
USING (npi)
GROUP BY p2.specialty_description
ORDER BY total_claims DESC;

-- Answer: Family Practice at 9752347 total claims

-- 2b. Which specialty had the most total number of claims for opioids?

SELECT p2.specialty_description, SUM(p1.total_claim_count) AS total_claims
FROM prescriber AS p2
INNER JOIN prescription AS p1
USING (npi)
INNER JOIN drug AS d
ON p1.drug_name = d.drug_name
WHERE d.opioid_drug_flag ILIKE '%Y%'
GROUP BY p2.specialty_description
ORDER BY total_claims DESC;

-- Answer: Nurse Practitioner with 900845 total claims

-- 2c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT p2.specialty_description, SUM(p1.total_claim_count) AS total_claims
FROM prescriber AS p2
INNER JOIN prescription AS p1
USING (npi)
INNER JOIN drug AS d
ON p1.drug_name = d.drug_name
GROUP BY p2.specialty_description
ORDER BY total_claims;

-- 2d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?


-- 3a. Which drug (generic_name) had the highest total drug cost?


SELECT d.generic_name, SUM(p1.total_drug_cost) AS total_cost
FROM drug AS d
INNER JOIN prescription AS p1
USING (drug_name)
GROUP BY d.generic_name
ORDER BY total_cost DESC;

-- Answer: Insulin with total cost of 104264066.35

-- 3b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT d.generic_name, ROUND(SUM(p1.total_drug_cost)/SUM(p1.total_day_supply), 2)
AS cost_per_day
FROM drug AS d
INNER JOIN prescription AS p1
USING (drug_name)
GROUP BY d.generic_name
ORDER BY cost_per_day DESC;

-- Answer: "C1 ESTERASE INHIBITOR"	3495.22

-- 4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. 

SELECT drug_name,
CASE 
WHEN opioid_drug_flag = 'Y'
THEN 'opioid'
WHEN antibiotic_drug_flag ='Y'
THEN 'antibiotic'
ELSE 'neither' END AS drug_type
FROM drug;


-- Answer: SEE QUERY RESULT

-- 4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT SUM(MONEY(p1.total_drug_cost)) AS total_cost,
CASE 
WHEN opioid_drug_flag = 'Y'
THEN 'opioid'
WHEN antibiotic_drug_flag ='Y'
THEN 'antibiotic'
ELSE 'neither' END AS drug_type
FROM drug
INNER JOIN prescription AS p1
USING (drug_name)
GROUP BY drug_type
ORDER BY total_cost DESC;

-- Answer: Opioids at "$105,080,626.37"

-- 5a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.


SELECT COUNT(*)
FROM cbsa
WHERE cbsaname LIKE '%TN%';

-- Answer: 56


--5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.



SELECT c1.cbsaname, c1.cbsa, SUM(p1.population) AS top_pop
FROM CBSA AS c1
INNER JOIN population AS p1
USING (fipscounty)
GROUP BY c1.cbsaname,  c1.cbsa
ORDER BY top_pop DESC;

-- Answer: Nashville-Davidson, TN population of 1830410 is the largest. Morristown, TN population is 63465.

--  5c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.






