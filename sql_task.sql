/*1.Написать запрос, считающий суммарное количество имеющихся на сайте новостей и обзоров.*/
SELECT COUNT(*) AS SUM FROM (SELECT n_header FROM news UNION SELECT r_header FROM reviews) AS headers;

/*2.Написать запрос, показывающий список категорий новостей и количество новостей в каждой категории.*/

SELECT nc_name, COUNT(n_id)
FROM news RIGHT JOIN news_categories ON nc_id = n_category
GROUP BY nc_name;

/*3. Написать запрос, показывающий список категорий обзоров и количество обзоров в каждой категории.*/
SELECT rc_name, COUNT(r_id)
FROM reviews RIGHT JOIN reviews_categories ON rc_id = r_category
GROUP BY rc_name;

/*4. Написать запрос, показывающий список категорий новостей, категорий обзоров 
и дату самой свежей публикации в каждой категории.*/
SELECT rc_name, MAX(r_dt) FROM reviews, reviews_categories 
WHERE r_category = reviews_categories.rc_id GROUP BY rc_name
UNION
SELECT nc_name, MAX(n_dt) FROM news, news_categories 
WHERE n_category = news_categories.nc_id GROUP BY nc_name;

/*5. Написать запрос, показывающий список страниц сайта верхнего уровня (у таких
страниц нет родительской страницы) и список баннеров для каждой такой страницы.*/
SELECT pages.p_name, banners.b_id, banners.b_url FROM pages, m2m_banners_pages, banners 
WHERE ISNULL(p_parent) AND pages.p_id = m2m_banners_pages.p_id AND banners.b_id = m2m_banners_pages.b_id;

/*6. Написать запрос, показывающий список страниц сайта, на которых есть баннеры. (Выполняется правильно, хоть и ругается)*/
SELECT p_name FROM pages WHERE p_id IN (SELECT m2m_banners_pages.p_id FROM m2m_banners_pages);  

/*7. Написать запрос, показывающий список страниц сайта, на которых нет баннеров.*/
SELECT p_name FROM pages WHERE p_id NOT IN (SELECT m2m_banners_pages.p_id FROM m2m_banners_pages);

/*8.Написать запрос, показывающий список баннеров, размещённых хотя бы на одной
странице сайта. 
1) не в порядке указаном в результате запроса приведенного в задаче*/
SELECT b_id, b_url FROM banners WHERE b_id IN (SELECT m2m_banners_pages.b_id FROM m2m_banners_pages);  
/*
2) в порядке указаном в результате запроса приведенного в задаче*/ 
SELECT DISTINCT m2m_banners_pages.b_id, b_url FROM m2m_banners_pages LEFT JOIN banners ON banners.b_id = m2m_banners_pages.b_id;  

/*9. Написать запрос, показывающий список баннеров, не размещённых ни на одной
странице сайта.*/
SELECT b_id, b_url FROM banners WHERE b_id NOT IN (SELECT m2m_banners_pages.b_id FROM m2m_banners_pages);  

/*10. Написать запрос, показывающий баннеры, для которых отношение кликов к показам
>= 80% (при условии, что баннер был показан хотя бы один раз).*/
SELECT b_id, b_url, (b_click / b_show * 100) AS rate FROM banners WHERE b_show > 0 AND (b_click / b_show * 100) >= 80;
