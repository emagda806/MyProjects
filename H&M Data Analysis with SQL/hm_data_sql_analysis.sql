-- Analiza danych z SQL pochodzacych z konkursu Kaggle 
-- Dane zostaly na poczatku przetransformowane w Excelu,
-- a nastepnie wczytane do MS SQL Server Managment Studio.

-- Articles

-- Q1: Ile jest produktow z danej sekcji w asortymencie sklepu? Jaki to procent
-- wszystkich produktow?

SELECT index_group_name, COUNT(index_group_name) count_by_index_group_name,
COUNT(index_group_name)  * 100.0 / (select count(*) from dbo.articles) as percentage
FROM dbo.articles
GROUP BY index_group_name
ORDER BY count_by_index_group_name DESC

-- Najbardziej liczna okazuje sie sekcja 'LadiesWear' (37%), nastepnie 'Baby/Children'(32%) oraz 'Divided'(14%).
-- Najmniej w asortymencie jest ubran z sekcji 'Sport'(3%).

-- Q2: Ile jest ubran danego typu w danej sekcji?

SELECT index_group_name, garment_group_name, COUNT(article_id) count_by_garment_group
FROM dbo.articles
GROUP BY garment_group_name, index_group_name
ORDER BY index_group_name, count_by_garment_group DESC

-- W przypadku sekcji Baby/Children i Ladieswear przewazajacym typem produktu jest Jersey Fancy, jest on takze drugim co 
-- wielkosci typem produktu w sekcji Divided.

-- W przypadku sekcji Ladieswear i Baby/Children mamy do czynienia z podsekcjami:

SELECT index_group_name,  index_name, COUNT(article_id) as count_articles
FROM dbo.articles
GROUP BY index_group_name, index_name
ORDER BY index_group_name, index_name, count_articles DESC

-- W przypadku Baby/Children najwiecej ubran jest dla niemowlat (dzieci z rozmiarem 50-98) 9121 artykulow.

-- Ile poszczegolnych typow produktow mamy w danym typie grupy produktow?
-- Dla przykladu najwiecej wsrod akcesoriow (typ grupy produktu) mamy czapek/kapeluszy (typ produktu) - 1417.

SELECT product_group_name, product_type_name, COUNT(article_id) as count_articles
FROM dbo.articles
GROUP BY product_group_name, product_type_name
ORDER BY product_group_name, count_articles DESC,product_type_name

-- Q4: Ile mamy unikalnych nazw produktow, typow produktow oraz grup produktow?
SELECT COUNT(DISTINCT prod_name) AS number_of_unique_product_name,
COUNT(DISTINCT product_type_name) AS number_of_unique_product_type_name,
COUNT(DISTINCT product_group_name) AS number_of_unique_product_group_name
FROM dbo.articles

-- Customers

-- Q1: Z jakiej grupy wiekowej mamy najwiecej klientow?
-- Najwiecej mamy klientow miedzy 31 a 64 rokiem zycia, kolejna co do wielkosci grupa wiekowa sa
-- mlodzi dorosli (osoby spomiedzy 20 a 30 roku zycia).

SELECT COUNT(customer_id) as count_customers,
CASE 
	WHEN age BETWEEN 20 AND 30 THEN 'young adult'
	WHEN age BETWEEN 16 AND 19 THEN 'teenager'
	WHEN age BETWEEN 31 AND 64 THEN 'adult'
	WHEN age BETWEEN 65 AND 99 THEN 'seniors'
	ELSE 'no-information'
END AS age_group
FROM dbo.customers
GROUP BY CASE 
	WHEN age BETWEEN 20 AND 30 THEN 'young adult'
	WHEN age BETWEEN 16 AND 19 THEN 'teenager'
	WHEN age BETWEEN 31 AND 64 THEN 'adult'
	WHEN age BETWEEN 65 AND 99 THEN 'seniors'
	ELSE 'no-information'
END
ORDER BY count_customers DESC

-- Q2: Jaki status nasi klienci maja w klubie H&M?

SELECT club_member_status, COUNT(customer_id) AS count
FROM dbo.customers
WHERE club_member_status is NOT NULL
GROUP BY club_member_status 
ORDER BY count DESC

-- Q3: Jak czesto klienci chca, aby wysylac im wiadomosci?

SELECT fashion_news_frequency, COUNT(customer_id) AS count
FROM dbo.customers
WHERE club_member_status <> 'LEFT-CLUB' OR club_member_status is NOT NULL 
GROUP BY fashion_news_frequency
ORDER BY count DESC

-- Klienci wola, aby sie z nimi nie kontatkowac (oko³o 2/3).

-- Articles & Transactions

-- Q1: Cena maksymalna, minimalna i srednia w zaleznosci od grupy produktu?

SELECT product_group_name, AVG(price) avg_price, MIN(price) min_price, MAX(price) max_price
FROM articles art
LEFT JOIN transactions tr 
ON tr.article_id = art.article_id
WHERE product_group_name NOT IN ('Fun', 'Stationery')
GROUP BY product_group_name

-- Q2: Cena maksymalna, minimalna i srednia danego typu akcesorium?

SELECT product_type_name, AVG(price) avg_price, MIN(price) min_price, MAX(price) max_price
FROM articles art
LEFT JOIN transactions tr 
ON tr.article_id = art.article_id
WHERE product_group_name = 'Accessories'
GROUP BY product_type_name

-- Q3: srednia cena transakcji za dany typ produktu

-- paskow

SELECT AVG(price) avg_price, t_dat
FROM articles art
LEFT JOIN transactions tr 
ON tr.article_id = art.article_id
WHERE product_type_name = 'Belt' AND t_dat is NOT NULL
GROUP BY t_dat
ORDER BY t_dat 

-- portfeli

SELECT AVG(price) avg_price, t_dat
FROM articles art
LEFT JOIN transactions tr 
ON tr.article_id = art.article_id
WHERE product_type_name = 'Wallet' AND t_dat is NOT NULL
GROUP BY t_dat
ORDER BY t_dat 
