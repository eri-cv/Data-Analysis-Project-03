/* preparation and data cleaning in work database*/

use themeparks_work
GO

/*creating help tables*/
IF OBJECT_ID('parks_tickets') IS NOT NULL
	DROP TABLE parks_tickets;
create table [parks_tickets](
	[name] text,
	[name_new] text,
	[price from] float,
	[parking] varchar,
	[type] varchar
)
GO

IF OBJECT_ID('parks_rating') IS NOT NULL
	DROP TABLE parks_rating;
create table [parks_rating](
	[name] text,
	[name_new] text,
	[ratingKlook] float,
	[ratingGoogle] float,
)
GO
IF OBJECT_ID('parks_contacts') IS NOT NULL
	DROP TABLE parks_contacts;
create table [parks_contacts](
	[name] text,
	[name_new] text,
	[website] text,
	[phone] text,
)
GO

IF OBJECT_ID('parks_highlights') IS NOT NULL
	DROP TABLE parks_highlights;
create table [parks_highlights](
	[name] text,
	[name_new] text,
	[ride] text,
	[ride_desc] text,
)
GO

INSERT INTO [parks_rating] (
	[name],
	[name_new],
	[ratingKlook]
)
SELECT 
	t1.name,
	(SELECT t2.name FROM parks_info_v1 as t2 
	WHERE t2.name LIKE '%' + (LEFT(t1.name, 4)) + '%'),
	t1.review
	FROM parks_info2_v1 as t1
GO

INSERT INTO [parks_contacts] (
	[name],
	[name_new],
	[website],
	[phone]
)
SELECT 
	t1.name,
	(SELECT t2.name FROM parks_info_v1 as t2 
	WHERE t2.name LIKE '%' + (LEFT(t1.name, 4)) + '%'),
	(SELECT t2.website FROM parks_info_v1 as t2
	WHERE t2.name LIKE '%' + (LEFT(t1.name, 4)) + '%'),
	t1.phone
	FROM parks_phones as t1
GO

UPDATE [parks_highlights_v1]
	SET [rides] = 'Sprookjesbos - fairytale forest'
	WHERE [rides] like 'Sprookjesbos%'
GO
INSERT INTO [parks_highlights] (
	[name],
	[name_new],
	[ride],
	[ride_desc]
)
SELECT 
	t1.name,
	(SELECT t2.name FROM parks_info_v1 as t2 
	WHERE t2.name LIKE '%' + (LEFT(t1.name, 4)) + '%'),
	CASE WHEN t1.name not like 'disneyland%' THEN TRIM(LEFT(t1.rides, CHARINDEX('-', t1.rides)-2)) ELSE t1.rides END,
	CASE WHEN t1.name not like 'disneyland%' THEN LOWER(SUBSTRING(t1.rides, CHARINDEX('-', t1.rides) + 2, LEN(t1.rides))) ELSE '' END	
	FROM parks_highlights_v1 as t1
GO

