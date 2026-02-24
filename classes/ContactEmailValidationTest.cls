@isTest
public class ContactEmailValidationTest {

    
    @isTest
    static void testValidEmail() {
        Contact testContact = new Contact(
            FirstName = 'krishna',
            LastName = 'M',
            Email = 'krishna@example.com',
            MobilePhone='+9189518328'
        );
        insert testContact;
        
       
    }

    
    @isTest
    static void testInvalidEmail() {
        Contact testContact = new Contact(
            FirstName = 'Imran',
            LastName = 'Sh',
            Email = 'janesmith@bvclogistics.com'
        );
        
      
        try {
            insert testContact;
        } catch (DmlException e) {
            
           
        }
        
                }
}