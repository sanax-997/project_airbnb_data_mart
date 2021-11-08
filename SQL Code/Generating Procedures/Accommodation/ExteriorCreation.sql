DELIMITER //

CREATE PROCEDURE ExteriorCreation(
    IN accommodation_name VARCHAR(100),
    IN exterior_type VARCHAR(100),
    IN exterior_description TEXT,
    OUT message VARCHAR(128)
)
BEGIN
    -- Declare variables
    DECLARE accommodation_id INT;

    -- Check if the accommodation exists
    IF EXISTS(SELECT * FROM accommodations WHERE accommodations.AccommodationName = accommodation_name) THEN

        -- Query the AccommodationID
        SELECT AccommodationID INTO accommodation_id FROM accommodations WHERE accommodations.AccommodationName = accommodation_name;

        -- Check if the accommodation already has an exterior
        IF NOT EXISTS(SELECT * FROM exteriors WHERE exteriors.AccommodationID = accommodation_id) THEN

            -- Create the Exterior
            START TRANSACTION;       
                -- Insert the exterior information in the exterior table
                INSERT INTO exteriors (ExteriorType,ExteriorDescription,AccommodationID) VALUES (exterior_type,exterior_description,accommodation_id);

                SET message = "Exterior creation success";
            COMMIT;

        -- Exterior already exists
        ELSE 
            SET message = 'Exterior creation failed - accommodation already has an exterior';
        END IF;
    -- Accommodation does not exist
    ELSE 
        SET message = 'Exterior creation failed - accommodation does not exists';
    END IF;
END //  