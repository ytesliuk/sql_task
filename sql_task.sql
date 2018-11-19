/*1.Написать запрос, считающий суммарное количество имеющихся на сайте новостей и обзоров.*/
SELECT COUNT(*) AS SUM FROM 
		(SELECT n_header FROM news UNION SELECT r_header FROM reviews) AS headers;

/*2.Написать запрос, показывающий список категорий новостей и количество новостей в каждой категории.*/
SELECT nc_name, COUNT(n_id) FROM news 
	RIGHT JOIN news_categories ON nc_id = n_category
	GROUP BY nc_name;

/*3. Написать запрос, показывающий список категорий обзоров и количество обзоров в каждой категории.*/
SELECT rc_name, COUNT(r_id) FROM reviews 
	RIGHT JOIN reviews_categories ON rc_id = r_category
	GROUP BY rc_name;

/*4. Написать запрос, показывающий список категорий новостей, категорий обзоров 
и дату самой свежей публикации в каждой категории.*/
SELECT rc_name, MAX(r_dt) FROM reviews, reviews_categories 
	WHERE r_category = reviews_categories.rc_id GROUP BY rc_name
UNION SELECT nc_name, MAX(n_dt) FROM news, news_categories 
	WHERE n_category = news_categories.nc_id GROUP BY nc_name;

/*5. Написать запрос, показывающий список страниц сайта верхнего уровня (у таких
страниц нет родительской страницы) и список баннеров для каждой такой страницы.*/
SELECT pages.p_name, banners.b_id, banners.b_url FROM pages, m2m_banners_pages, banners 
	WHERE ISNULL(p_parent) AND pages.p_id = m2m_banners_pages.p_id AND banners.b_id = m2m_banners_pages.b_id;

/*6. Написать запрос, показывающий список страниц сайта, на которых есть баннеры. (Выполняется правильно, хоть и ругается)*/
/*6.1 Using IN*/
SELECT p_name FROM pages WHERE p_id IN (SELECT m2m_banners_pages.p_id FROM m2m_banners_pages);  
/*6.2 Using JOIN*/
SELECT DISTINCT p_name FROM pages RIGHT JOIN m2m_banners_pages ON pages.p_id = m2m_banners_pages.p_id;

/*7. Написать запрос, показывающий список страниц сайта, на которых нет баннеров.*/
SELECT p_name FROM pages WHERE p_id NOT IN (SELECT m2m_banners_pages.p_id FROM m2m_banners_pages);

/*8.Написать запрос, показывающий список баннеров, размещённых хотя бы на одной
странице сайта. 
8.1) не в порядке указаном в результате запроса приведенного в задаче*/
SELECT b_id, b_url FROM banners WHERE b_id IN (SELECT m2m_banners_pages.b_id FROM m2m_banners_pages);  
/*
8.2) в порядке указаном в результате запроса приведенного в задаче*/ 
SELECT DISTINCT m2m_banners_pages.b_id, b_url FROM m2m_banners_pages 
	LEFT JOIN banners ON banners.b_id = m2m_banners_pages.b_id;  

/*9. Написать запрос, показывающий список баннеров, не размещённых ни на одной
странице сайта.*/
SELECT b_id, b_url FROM banners WHERE b_id NOT IN (SELECT m2m_banners_pages.b_id FROM m2m_banners_pages);  

/*10. Написать запрос, показывающий баннеры, для которых отношение кликов к показам
>= 80% (при условии, что баннер был показан хотя бы один раз).*/
SELECT b_id, b_url, (b_click / b_show * 100) AS rate FROM banners 
	WHERE b_show > 0 AND (b_click / b_show * 100) >= 80;

/*11.Написать запрос, показывающий список страниц сайта, на которых показаны
баннеры с текстом (в поле `b_text` не NULL).*/
SELECT DISTINCT p_name FROM pages 
	INNER JOIN m2m_banners_pages ON pages.p_id = m2m_banners_pages.p_id 
	INNER JOIN banners ON banners.b_id = m2m_banners_pages.b_id AND NOT ISNULL(banners.b_text);

/*12. Написать запрос, показывающий список страниц сайта, на которых показаны
баннеры с картинкой (в поле `b_pic` не NULL).*/
SELECT DISTINCT p_name FROM pages
	INNER JOIN m2m_banners_pages ON pages.p_id = m2m_banners_pages.p_id
	INNER JOIN banners ON m2m_banners_pages.b_id = banners.b_id AND NOT ISNULL(banners.b_pic);
        
/*13.Написать запрос, показывающий список публикаций (новостей и обзоров) за 2011-й
год.*/
SELECT n_header AS header, n_dt AS date FROM news WHERE n_dt BETWEEN "2011-01-01" AND "2011-12-31"
	UNION SELECT r_header, r_dt FROM reviews WHERE r_dt BETWEEN "2011-01-01" AND "2011-12-31";

/*14.Написать запрос, показывающий список категорий публикаций (новостей и обзоров),
в которых нет публикаций.*/
SELECT nc_name AS category FROM news_categories WHERE nc_id NOT IN (SELECT n_category FROM news)
	UNION SELECT rc_name FROM reviews_categories WHERE rc_id NOT IN (SELECT r_category FROM reviews);

/*15. Написать запрос, показывающий список новостей из категории «Логистика» за 2012-
й год.*/
SELECT n_header, n_dt FROM news 
	INNER JOIN news_categories ON n_category = nc_id 
	WHERE nc_name = "Логистика" AND (n_dt BETWEEN "2012-01-01" AND "2012-12-31");

/*16.Написать запрос, показывающий список годов, за которые есть новости, а также
количество новостей за каждый из годов.*/
SELECT YEAR(n_dt) as "year", COUNT(*) from news GROUP BY YEAR(n_dt) ORDER BY YEAR(n_dt);

/*17.Написать запрос, показывающий URL и id таких баннеров, где для одного и того же
URL есть несколько баннеров.*/
SELECT banners.b_url, banners.b_id FROM banners 
	INNER JOIN (SELECT b_url, b_id, COUNT(b_url) as "number" from banners GROUP BY b_url) as tamp 
	ON banners.b_url = tamp.b_url AND tamp.number > 1;


/*18.Написать запрос, показывающий список непосредственных подстраниц страницы
«Юридическим лицам» со списком баннеров этих подстраниц.*/
SELECT p_name, m2m_banners_pages.b_id, banners.b_url FROM pages 
	INNER JOIN m2m_banners_pages on pages.p_id = m2m_banners_pages.p_id 
	INNER JOIN banners ON m2m_banners_pages.b_id = banners.b_id
	WHERE p_parent = (
			SELECT p_id FROM pages WHERE p_name = "Юридическим лицам");

/*19.Написать запрос, показывающий список всех баннеров с картинками (поле `b_pic` не
NULL), отсортированный по убыванию отношения кликов по баннеру к показам
баннера.*/
SELECT b_id, b_url, (b_click / b_show) AS rate FROM banners WHERE NOT ISNULL(b_pic) ORDER BY rate DESC;

/*20. Написать запрос, показывающий самую старую публикацию на сайте (не важно –
новость это или обзор).*/
SELECT n_header as header, n_dt AS "date" 
	FROM (SELECT n_header, n_dt FROM news 
	UNION SELECT r_header, r_dt FROM reviews) AS tamp 
	ORDER BY date LIMIT 1;

/*21.Написать запрос, показывающий список баннеров, URL которых встречается в
таблице один раз.*/
SELECT banners.b_url, banners.b_id FROM banners 
	INNER JOIN (SELECT b_url, COUNT(b_url) as number FROM banners GROUP BY b_url) as tamp 
	ON banners.b_url = tamp.b_url WHERE tamp.number = 1; 

/*22. Написать запрос, показывающий список страниц сайта в порядке убывания
количества баннеров, расположенных на странице. Для случаев, когда на
нескольких страницах расположено одинаковое количество баннеров, этот список
страниц должен быть отсортирован по возрастанию имён страниц.*/
SELECT p_name, COUNT(m2m_banners_pages.p_id) AS banners_count FROM pages, m2m_banners_pages 
	WHERE pages.p_id = m2m_banners_pages.p_id
	GROUP BY m2m_banners_pages.p_id ORDER BY banners_count DESC, p_name;

/*23.Написать запрос, показывающий самую «свежую» новость и самый «свежий» обзор.*/
SELECT n_header AS header, n_dt AS date FROM news
	WHERE n_dt = 
		(SELECT MAX(n_dt) FROM news) 
UNION SELECT r_header, r_dt FROM reviews 
	WHERE r_dt = 
		(SELECT MAX(r_dt) FROM reviews);

/*24.Написать запрос, показывающий баннеры, в тексте которых встречается часть URL,
на который ссылается баннер.*/
SELECT b_id, b_url, b_text FROM banners WHERE b_text LIKE (CONCAT("%",SUBSTRING(b_url, 8, LENGTH(b_url) - 7),"%"));

/*25.Написать запрос, показывающий страницу, на которой размещён баннер с самым
высоким отношением кликов к показам.*/
/*Баннер №2 имеет наибольшее соотношение (хоть и не правильное). 
И всего три страницы, на которых есть этот банер, а не 1, как указано в ответе*/
SELECT p_name FROM pages 
	INNER JOIN m2m_banners_pages ON pages.p_id = m2m_banners_pages.p_id 
	INNER JOIN banners ON banners.b_id = m2m_banners_pages.b_id 
		WHERE b_click / b_show = (
			SELECT MAX(b_click / b_show) FROM banners);

/*26.Написать запрос, считающий среднее отношение кликов к показам по всем
баннерам, которые были показаны хотя бы один раз.*/
SELECT AVG(b_click/b_show) AS "AVG(`b_click`/`b_show`)" FROM banners WHERE b_show > 0;

/*27.Написать запрос, считающий среднее отношение кликов к показам по баннерам, у
которых нет графической части (поле `b_pic` равно NULL).*/
SELECT AVG(b_click / b_show) AS "AVG(`b_click`/`b_show`)" FROM banners WHERE ISNULL(b_pic);

/*28.Написать запрос, показывающий количество баннеров, размещённых на страницах
сайта верхнего уровня (у таких страниц нет родительских страниц).*/
SELECT COUNT(b_id) as "COUNT" FROM m2m_banners_pages 
INNER JOIN pages ON m2m_banners_pages.p_id = pages.p_id WHERE ISNULL(pages.p_parent);

/*29.Написать запрос, показывающий баннер(ы), который(ые) показаны на самом
большом количестве страниц.*/
SELECT m2m_banners_pages.b_id, b_url, COUNT(p_id) as COUNT FROM banners, m2m_banners_pages 
WHERE banners.b_id = m2m_banners_pages.b_id
GROUP BY m2m_banners_pages.b_id
HAVING COUNT = (
		SELECT COUNT(p_id) AS rep FROM m2m_banners_pages 
		GROUP BY b_id
		ORDER BY rep DESC 
		LIMIT 1);

/*30.Написать запрос, показывающий страницу(ы), на которой(ых) показано больше всего
баннеров.*/
SELECT p_name, COUNT(b_id) as COUNT FROM pages, m2m_banners_pages 
WHERE pages.p_id = m2m_banners_pages.p_id
GROUP BY p_name
HAVING COUNT = (
		SELECT COUNT(b_id) AS rep FROM m2m_banners_pages 
		GROUP BY p_id
		ORDER BY rep DESC 
		LIMIT 1);


