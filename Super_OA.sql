-- Assumptions: 
-- Since I am doing this in SQL, I am assuming that the table in the DB is also called "data", just like the stringified table provided in the prompt
-- I am also assuming that the column names in the DB are exactly as provided in the stringified table (eg., "Airline Code" won't cause any errors)
-- I am also assuming that the SQL syntax I am using will work, because the specific SQL to be used was not specified (eg., SQLite, PLSQL, etc)


-- airline_data is the new table where the transformed data will be added
CREATE TABLE IF NOT EXISTS airline_data AS

    -- Getting the adjusted flight codes by accounting for nulls and the +10 increment for each row
    WITH adjusted_flight_codes AS (
    SELECT
        Airline Code,
        DelayTimes,
        COALESCE(FlightCodes, LAG(FlightCodes) OVER (ORDER BY Airline Code) + 10) AS FlightCodes,
        To_From
    FROM data
    ),

    -- Splitting the To_From column into 2 columns, "To" and "From", and converting them into uppercase
    -- Note: This splitting is done on the data that has the adjusted Flight Codes 
    split_to_from AS (
    SELECT
        Airline Code,
        DelayTimes,
        FlightCodes,
        UPPER(split_part(To_From, '_', 1)) AS "To",
        UPPER(split_part(To_From, '_', 2)) AS "From"
    FROM adjusted_flight_codes
    )

    -- Removing all punctuation except for spaces in the middle for the Airline Codes.
    -- Note: This is done on the splitted "To" and "From" data, so the following has the final required data to be added to a new table
    SELECT
        regexp_replace(Airline Code, '[^a-zA-Z\\s]', '', 'g') AS Airline_Code,
        DelayTimes,
        CAST(FlightCodes AS INTEGER) AS FlightCodes,
        "To",
        "From"
    FROM split_to_from;


