USE themeparks
GO

IF OBJECT_ID('themeparks') IS NOT NULL
	DROP TABLE themeparks;
IF OBJECT_ID('tp_ratings') IS NOT NULL
	DROP TABLE tp_ratings;
IF OBJECT_ID('tp_tickets') IS NOT NULL
	DROP TABLE tp_tickets;
IF OBJECT_ID('tp_attractions_num') IS NOT NULL
	DROP TABLE tp_attractions_num;
IF OBJECT_ID('tp_locations') IS NOT NULL
	DROP TABLE tp_locations;
IF OBJECT_ID('tp_contact') IS NOT NULL
	DROP TABLE tp_contact;
IF OBJECT_ID('cities_cz') IS NOT NULL
	DROP TABLE cities_cz;
IF OBJECT_ID('distance') IS NOT NULL
	DROP TABLE distance;
IF OBJECT_ID('tp_highlights') IS NOT NULL
	DROP TABLE tp_highlights;


CREATE TABLE [themeparks] (
  [id] int PRIMARY KEY IDENTITY(1, 1),
  [name] nvarchar(255),
  [opened] date,
  [visitors_per_annum] float,
  [area_in_acres] float
)
GO

CREATE TABLE [cities_cz] (
  [id] int PRIMARY KEY IDENTITY(1, 1),
  [name] nvarchar(255),
  [latitude] float,
  [longitude] float
)
GO

CREATE TABLE [tp_locations] (
  [tp_id] int,
  [country] nvarchar(255),
  [latitude] float,
  [longitude] float
)
GO

CREATE TABLE [tp_contact] (
  [tp_id] int,
  [website] nvarchar(255),
  [phone] nvarchar(255)
)
GO

CREATE TABLE [tp_attractions_num] (
  [tp_id] int,
  [total_attr] int,
  [rollercoasters] int,
  [waterrides] int
)
GO

CREATE TABLE [tp_ratings] (
  [tp_id] int,
  [rat_Klook] float,
  [rat_Google] float
)
GO

CREATE TABLE [tp_highlights] (
  [tp_id] int,
  [ride_name] text,
  [ride_description] text
)
GO

CREATE TABLE [distance] (
  [tp_id] int,
  [city_id] int,
  [distance] float
)
GO

ALTER TABLE [tp_locations] ADD FOREIGN KEY ([tp_id]) REFERENCES [themeparks] ([id])
GO

ALTER TABLE [tp_contact] ADD FOREIGN KEY ([tp_id]) REFERENCES [themeparks] ([id])
GO

ALTER TABLE [tp__attractions_num] ADD FOREIGN KEY ([tp_id]) REFERENCES [themeparks] ([id])
GO

ALTER TABLE [tp_ratings] ADD FOREIGN KEY ([tp_id]) REFERENCES [themeparks] ([id])
GO

ALTER TABLE [tp_tickets] ADD FOREIGN KEY ([tp_id]) REFERENCES [themeparks] ([id])
GO

ALTER TABLE [distance] ADD FOREIGN KEY ([tp_id]) REFERENCES [themeparks] ([id])
GO

ALTER TABLE [distance] ADD FOREIGN KEY ([city_id]) REFERENCES [cities_cz] ([id])
GO

/*filling table themeparks*/
INSERT INTO [themeparks] (
	[name],
	[opened],
	[visitors_per_annum],
	[area_in_acres]
)
SELECT
	[name],
	[opening_date],
	[visitors_per_annum],
    [area_in_acres]
	FROM [themeparks_work].[dbo].[parks_info_v1]
GO 

/*filling missing values manually*/
UPDATE [themeparks]
	SET [visitors_per_annum] = 0.86
	WHERE [name] = 'Walibi'
UPDATE [themeparks]
	SET [area_in_acres] = 56
	WHERE [name] = 'Walibi'
UPDATE [themeparks]
	SET [area_in_acres] = 20
	WHERE [name] = 'Tivoli'
GO

/*filling table attractions_num*/
INSERT INTO [tp_attractions_num] (
	[tp_id],
	[total_attr],
	[rollercoasters],
	[waterrides]
)
 SELECT
	  t2.id,
	  t1.num_attractions,
      t1.num_rollers_coasters,
      t1.num_water_rides
	  FROM [themeparks_work].[dbo].[parks_info_v1] AS t1
	  JOIN [themeparks].[dbo].[themeparks] AS t2
	  ON T1.name = T2.name
GO

/*filling missing values manually*/
UPDATE [tp_attractions_num]
	SET [total_attr] = 54, [rollercoasters] = 8, [waterrides] = 4
	WHERE [tp_id] = 6
UPDATE [tp_attractions_num]
	SET [waterrides] = 10
	WHERE [tp_id] = 1
GO

/*filling table locations*/
INSERT INTO [tp_locations] (
	[tp_id],
	[country],
	[latitude],
	[longitude]
)
 SELECT
	  t2.id,
	  t1.country,
      t1.latitude,
      t1.longitude
	  FROM [themeparks_work].[dbo].[parks_info_v1] AS t1
	  JOIN [themeparks].[dbo].[themeparks] AS t2
	  ON T1.name = T2.name
GO

/*filling table ratings*/
INSERT INTO [tp_ratings] (
	[tp_id],
	[rat_Klook]
)
 SELECT
	  t2.id,
	  t1.ratingKlook
	  FROM [themeparks_work].[dbo].[parks_rating] AS t1
	  JOIN [themeparks].[dbo].[themeparks] AS t2
	  ON CAST(T1.name_new AS varchar) = T2.name
GO

/*filling missing values manually*/
UPDATE [tp_ratings] SET rat_Google = 4.9 WHERE tp_id = 1
UPDATE [tp_ratings] SET rat_Google = 4.8 WHERE tp_id = 2
UPDATE [tp_ratings] SET rat_Google = 4.3 WHERE tp_id = 3
UPDATE [tp_ratings] SET rat_Google = 4.4 WHERE tp_id = 4
UPDATE [tp_ratings] SET rat_Google = 4.5 WHERE tp_id = 5
UPDATE [tp_ratings] SET rat_Google = 4.5 WHERE tp_id = 6
UPDATE [tp_ratings] SET rat_Google = 4.5 WHERE tp_id = 7
UPDATE [tp_ratings] SET rat_Google = 4.7 WHERE tp_id = 8
UPDATE [tp_ratings] SET rat_Google = 4.4 WHERE tp_id = 9
UPDATE [tp_ratings] SET rat_Google = 4.4 WHERE tp_id = 10
GO

/*filling table contact*/
INSERT INTO [tp_contact] (
	[tp_id],
	[website],
	[phone]
)
 SELECT
	  t2.id,
	  t1.website,
	  t1.phone
	  FROM [themeparks_work].[dbo].[parks_contacts] AS t1
	  JOIN [themeparks].[dbo].[themeparks] AS t2
	  ON CAST(T1.name_new AS varchar) = T2.name
GO
/*filling missing values manually*/
UPDATE [tp_contact]
	SET [website] = 'www.portaventuraworld.com'
	WHERE [tp_id] = 10
GO

/*filling table highlights*/
INSERT INTO [tp_highlights] (
	[tp_id],
	[ride_name],
	[ride_description]
)
 SELECT
	  t2.id,
	  t1.ride,
	  t1.ride_desc
	  FROM [themeparks_work].[dbo].[parks_highlights] AS t1
	  JOIN [themeparks].[dbo].[themeparks] AS t2
	  ON CAST(T1.name_new AS varchar) = T2.name
GO

/*filling table cities_cz*/
INSERT INTO [cities_cz] (
	[name],
	[latitude],
	[longitude]
)
SELECT
	[Obec],
	[Latitude],
	[Longitude]
	FROM [themeparks_work].[dbo].[parks_cities]
GO 

/*filling table distance*/
INSERT INTO [distance] (
	[tp_id],
	[city_id],
	[distance]
)
SELECT
	t2.id,
	t3.id,
	t1.distance_km
	FROM [themeparks_work].[dbo].[parks_distance_v1] AS t1
	  JOIN [themeparks].[dbo].[themeparks] AS t2
	  ON t1.parkname = t2.name
	  JOIN [themeparks].[dbo].[cities_cz] AS t3
	  ON t1.cz_city = t3.name
GO 




