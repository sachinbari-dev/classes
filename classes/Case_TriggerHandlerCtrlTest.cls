@isTest
public class Case_TriggerHandlerCtrlTest {
    Static TestMethod Void CaseTriggerHandlerCtrlTestMethod(){
        List<User> TestUserList = [SELECT Name, Id FROM User LIMIT 2];
        Case TestTicket = New Case();
        TestTicket.Origin = 'Email';
        TestTicket.Status = 'New';
        TestTicket.Subject = 'Test1';
        TestTicket.SuppliedEmail = 'Test1@gmail.com';
        TestTicket.OwnerId = TestUserList[0].Id;
        Insert TestTicket;
        Case TestTicket1 = New Case();
        TestTicket1.Origin = 'Email';
        TestTicket1.Subject = 'Test1';
        TestTicket1.SuppliedEmail = 'Test1@gmail.com';
        TestTicket1.Status = 'New';
        TestTicket1.OwnerId = TestUserList[0].Id;
        try
        {
            Insert TestTicket1;
        }catch(Exception e)
        {
            
        }
            
                       
        User TestUser = New User();
        TestUser = [SELECT Name, Id FROM User Where Name = 'BVC Admin' limit 1];
        System.runAs(TestUser){
        	Test.StartTest();
        	TestTicket.OwnerId = TestUserList[1].Id;
        	Update TestTicket;
        	Test.stopTest();
        }     
    }
}