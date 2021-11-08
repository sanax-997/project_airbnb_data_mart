DELIMITER //

CREATE PROCEDURE BathroomCreation(
    IN accommodation_name VARCHAR(100),
    IN bathroom_name VARCHAR (100),
    IN bathroom_description TEXT,
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

            -- Create the bathroom
            START TRANSACTION;
                -- Insert the bathroom data in the bathrooms table
                INSERT INTO bathrooms (BathroomName,BathroomDescription,InteriorID) VALUES (bathroom_name, bathroom_description,interior_id);

                -- Change the number of rooms the interior has +1
                UPDATE interiors SET RoomNumber = RoomNumber + 1 WHERE interiors.AccommodationID = accommodation_id;

                SET message = "Bathroom creation success";
            COMMIT;

        -- Interior does not exist
        ELSE 
            SET message = 'Bathroom creation failed - Interior does not exist';
        END IF;

    -- Accommodation does not exist
    ELSE 
        SET message = 'Bathroom creation failed - accommodation does not exist';
    END IF;

END //