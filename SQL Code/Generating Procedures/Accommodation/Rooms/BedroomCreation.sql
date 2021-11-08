DELIMITER //

CREATE PROCEDURE BedroomCreation(
    IN accommodation_name VARCHAR(100),
    IN bedroom_name VARCHAR(100),
    IN bedroom_beds_number DECIMAL (2,0),
    IN bedroom_description TEXT,
    OUT message VARCHAR(128)
)

BEGIN
    -- Declare variables
    DECLARE accommodation_id INT;
    DECLARE interior_id INT;

    -- Check if the accommodation exists
    IF EXISTS(SELECT * FROM accommodations WHERE accommodations.AccommodationName = accommodation_name) THEN

        -- Query the AccommodationID
        SELECT AccommodationID INTO accommodation_id FROM accommodations WHERE accommodations.AccommodationName = accommodation_name;

        -- Check if the interior exists
        IF EXISTS(SELECT * FROM interiors WHERE interiors.AccommodationID = accommodation_id) THEN

            -- Query the interiorID
            SELECT InteriorID INTO interior_id FROM interiors WHERE interiors.AccommodationID = accommodation_id;

            -- Create the bedroom
            START TRANSACTION;
                -- Insert the bedroom data in the bedrooms table
                INSERT INTO bedrooms (BedroomName,BedsNumber,BedroomDescription,InteriorID) VALUES (bedroom_name,bedroom_beds_number,bedroom_description,interior_id);

                -- Change the number of rooms the interior has +1
                UPDATE interiors SET RoomNumber = RoomNumber + 1 WHERE interiors.AccommodationID = accommodation_id;

                SET message = "Bedroom creation success";
            COMMIT;

        -- Interior does not exist
        ELSE 
            SET message = 'Bedroom creation failed - Interior does not exist';
        END IF;

    -- Accommodation does not exist
    ELSE 
        SET message = 'Bedroom creation failed - accommodation does not exist';
    END IF;

END //