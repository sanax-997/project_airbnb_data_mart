DELIMITER //

CREATE PROCEDURE PayConfirmation (
    IN guest_email_adress VARCHAR(100),
    IN guest_phone_number VARCHAR(100),
    IN accommodation_name VARCHAR(100),
    IN payment_confirmation_cancellation BOOLEAN,
    OUT message VARCHAR(128)
)
BEGIN

    -- Declare Variables
    DECLARE guest_id INT;
    DECLARE accommodation_id INT;
    DECLARE price_id INT;
    DECLARE payment_id INT;
    DECLARE payment_confirmations_id INT;
    DECLARE payment_amount INT;

    -- Check if the accommodation exists
    IF EXISTS(SELECT * FROM accommodations WHERE accommodations.AccommodationName = accommodation_name) THEN

        -- Query the AccommodationID
        SELECT AccommodationID INTO accommodation_id FROM accommodations WHERE accommodations.AccommodationName = accommodation_name;

        -- Check if the guest exists
        IF EXISTS(SELECT * FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress AND guestcontacts.GuestPhoneNumber = guest_phone_number) THEN

            -- Query the GuestID
            SELECT GuestID INTO guest_id FROM guestcontacts WHERE guestcontacts.GuestEmailAdress = guest_email_adress AND guestcontacts.GuestPhoneNumber = guest_phone_number;

            -- Check if the PriceID exist
            IF EXISTS(SELECT * FROM prices WHERE prices.AccommodationID = accommodation_id) THEN

                -- Query the PriceID
                SELECT PriceID INTO price_id FROM prices WHERE prices.AccommodationID = accommodation_id;

                -- Check if the payment exist
                IF EXISTS(SELECT * FROM payments WHERE payments.GuestID = guest_id AND payments.PriceID = price_id) THEN

                    -- Query PaymentID
                    SELECT PaymentID INTO payment_id FROM payments WHERE payments.GuestID = guest_id AND payments.PriceID = price_id;

                    -- Check if the payment confirmation exists
                    IF EXISTS(SELECT * FROM payconfirmations WHERE payconfirmations.PaymentID = payment_id) THEN

                        -- Check if the payment has been confirmed either by the user or by the date
                        IF payment_confirmation_cancellation = TRUE OR CURRENT_TIMESTAMP > (SELECT PossibleCancellationTime FROM payconfirmations WHERE payconfirmations.PaymentID = payment_id)THEN
                            -- Update Information in the payment confirmations table and create the income
                            START TRANSACTION;
                                -- Update the information of payment confirmations
                                UPDATE payconfirmations SET payconfirmations.ConfirmationCancellation = 1, payconfirmations.CancellationConfirmationTime = CURRENT_TIMESTAMP WHERE payconfirmations.PaymentID = payment_id;

                                -- Query the PayConfirmationID
                                SELECT PayConfirmationID INTO payment_confirmations_id FROM payconfirmations WHERE payconfirmations.PaymentID = payment_id;
                                
                                -- Query the payment amount
                                SELECT PaymentAmount INTO payment_amount FROM payments WHERE payments.GuestID = guest_id AND payments.PriceID = price_id;

                                -- Insert the information into the income table
                                INSERT INTO income (Income,IncomeTime,AccommodationID,PayConfirmationID) VALUES (payment_amount,CURRENT_TIMESTAMP,accommodation_id,payment_confirmations_id);

                                SET message = "Payment was successfull";
                            COMMIT;
                        END IF;
                        -- If the payment has been cancelled
                        IF payment_confirmation_cancellation = FALSE AND NOT CURRENT_TIMESTAMP > (SELECT PossibleCancellationTime FROM payconfirmations WHERE payconfirmations.PaymentID = payment_id)THEN
                            -- Update Information in the payment confirmations and delete information from the reservations table
                            START TRANSACTION;
                                -- Update the information of payment confirmations
                                UPDATE payconfirmations SET payconfirmations.ConfirmationCancellation = 0, payconfirmations.CancellationConfirmationTime = CURRENT_TIMESTAMP WHERE payconfirmations.PaymentID = payment_id;

                                -- Delete the information from reservations
                                DELETE FROM reservations WHERE reservations.GuestID = guest_id AND reservations.AccommodationID = accommodation_id;

                                SET message = "Payment has been cancelled";
                            COMMIT;
                        END IF;
                    -- Payment confirmation does not exist
                    ELSE 
                        SET message = 'Pay confirmation failed - payment confirmation not found';
                    END IF;  
                -- Payment does not exist
                ELSE 
                    SET message = 'Pay confirmation failed - payment not found';
                END IF;       
            -- Price does not exist
            ELSE 
                SET message = 'Pay confirmation failed - price not found';
            END IF;        
        -- Guest does not exist
        ELSE 
            SET message = 'Pay confirmation failed - guest not found';
        END IF;  
    -- Accommodation does not exist
    ELSE 
        SET message = 'Pay confirmation failed - accommodation not found';
    END IF;
END //