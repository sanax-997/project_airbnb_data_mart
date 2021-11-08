DELIMITER //

CREATE PROCEDURE DeleteAccommodationReview (
    IN guest_email_adress VARCHAR(100),
    IN accommodation_name VARCHAR(100),
    OUT message VARCHAR(128)
)
BEGIN

    -- Declare Variables
    DECLARE guest_id INT;
    DECLARE accommodation_id INT;

    -- Check if the guest email exists
    IF EXISTS(SELECT * FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress) THEN

        -- Query the GuestID
        SELECT GuestID INTO guest_id FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress;

        -- Check if the accommodation exists
        IF EXISTS(SELECT * FROM accommodations WHERE accommodations.AccommodationName = accommodation_name) THEN

            -- Query the AccommodationID
            SELECT AccommodationID INTO accommodation_id FROM accommodations WHERE accommodations.AccommodationName = accommodation_name;

            -- Check if the review exists
            IF EXISTS(SELECT * FROM accommodationreviews WHERE accommodationreviews.GuestID = guest_id AND accommodationreviews.AccommodationID = accommodation_id) THEN

                -- Start the deletion process of the accommodation review
                START TRANSACTION;
                    -- Delete the accommodation review from the accommodationreviews table
                    DELETE FROM accommodationreviews WHERE accommodationreviews.GuestID = guest_id AND accommodationreviews.AccommodationID = accommodation_id;

                    SET message = "Accommodation review deletion was successfull";
                COMMIT; 

            -- Review does not exist
            ELSE 
                SET message = 'Review deletion failed - review does not exist';
            END IF;  
        -- Accommodation does not exist
        ELSE 
            SET message = 'Review deletion failed - accommodation does not exist';
        END IF;        
    -- Guest email does not exist
    ELSE 
        SET message = 'Review deletion failed - guest email does not exist';
    END IF;
END //