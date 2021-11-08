DELIMITER //

CREATE PROCEDURE AccommodationReview (
    IN guest_email_adress VARCHAR(100),
    IN accommodation_name VARCHAR(100),
    IN accommodation_score DECIMAL (1,0), 
    IN accommodation_text TEXT,
    OUT message VARCHAR(128)
)
BEGIN

    -- Declare Variables
    DECLARE guest_id INT;
    DECLARE accommodation_id INT;

    -- Check if the accommodation exists
    IF EXISTS(SELECT * FROM accommodations WHERE accommodations.AccommodationName = accommodation_name) THEN

        -- Query the AccommodationID
        SELECT AccommodationID INTO accommodation_id FROM accommodations WHERE accommodations.AccommodationName = accommodation_name;

        -- Check if the guest exists
        IF EXISTS(SELECT * FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress) THEN

            -- Query the GuestID
            SELECT GuestID INTO guest_id FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress;

             -- Check if the score is a number between 1 and 5
            IF accommodation_score BETWEEN 1 AND 5 THEN

                -- Create the host review
                START TRANSACTION;
                    -- Insert the information in the hostreviews table
                    INSERT INTO accommodationreviews (AccommodationScore,AccommodationText,AccommodationReviewDate,GuestID,AccommodationID) VALUES (accommodation_score,accommodation_text,CURRENT_DATE,guest_id,accommodation_id);

                        SET message = "Review was successfull";
                    COMMIT;
            -- Score is not a number between 1 and 5
            ELSE 
                SET message = 'Review failed - the score must be between 1 and 5';
            END IF;
        -- Guest does not exist
        ELSE 
            SET message = 'Review failed - guest not found';
        END IF;            
    -- Accommodation does not exist
    ELSE 
        SET message = 'Review failed - accommodation not found';
    END IF;
END //