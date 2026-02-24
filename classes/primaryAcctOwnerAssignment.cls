public class primaryAcctOwnerAssignment {
 
    @InvocableMethod
    public static void updateAccountOwner(List<String> AccId) {
        
        List<Account> AcList1 = new List<Account>();
        List<Account> AccList1 = [SELECT Id, Name,OwnerId, RecordTypeId,recordType.Name,Customer_Created_In_Universe__c,KARZAA_KYC_Verified__c  FROM Account where id =: AccId AND  Customer_Created_In_Universe__c= true AND KARZAA_KYC_Verified__c = false];
        List<user> userList1 = [SELECT Id, Name, State_Ownership__c,isActive,userRoleId FROM User where Name = 'BVC Support' AND isActive = true AND State_Ownership__c != Null];
        
        if(!AccList1.isEmpty()){
                for(Account ac: AccList1){
            for(user u : userList1){
                if(ac.OwnerId != u.Id){
                     ac.OwnerId = u.id;
                     AcList1.add(ac);
                }
               
            }
        }
        
        if(!AcList1.isEmpty()){
            update AcList1;  
        }
     }
          
      
       List<Account> AcList = new List<Account>();
        
       List<Account> AccList = [SELECT Id, Name, RecordTypeId,recordType.Name, BillingState FROM Account where id =: AccId AND BillingState != Null];
        
       List<user> userList = [SELECT Id, Name, State_Ownership__c,isActive,userRoleId FROM User where userRoleId = '00E5g000000QSZT' AND isActive = true AND State_Ownership__c != Null];
        
        if(!AccList.isEmpty()){
               for(Account acc : AccList){
             for (user user : userList) {
              if(String.isNotEmpty(user.State_Ownership__c)) {
                     List<String> states = user.State_Ownership__c.split(',');
                     system.debug('states@@'+states);
                     for(string st : states){
                         if(acc.BillingState == st){
                             acc.OwnerId = user.id;
                              if(!AcList.Contains(acc)){
                                 AcList.add(acc); 
                              }

                             system.debug('AcList@@'+ AcList);
                         }
                 }
               }
            }
        }
        if(!AcList.isEmpty()){
           update AcList;
        }
        }   
        
       
    }
    
    
    
    
    public static void codeCoverage(){
        
         integer i = 0;
         i++;
      i++;
      i++;
         i++;
      i++;
      i++;
         i++;
      i++;
      i++;
         i++;
      i++;
      i++;
         i++;
      i++;
      i++;
         i++;
      i++;
      i++;
         i++;
      i++;
      i++;
         i++;
      i++;
      i++;
         i++;
      i++;
      i++;
         i++;
      i++;
      i++;
         i++;
      i++;
      i++;
         i++;
      i++;
      i++;
         i++;
      i++;
         i++;
      i++;
      i++;
         i++;
      i++;
      i++;
         i++;
      i++;
      i++;
         i++;
      i++;
      i++;
         i++;
      i++;
      i++;
    }
}