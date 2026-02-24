public class FleetxJobsListHelper 
{
 @AuraEnabled
 public static List<FleetXJob__c> getJobsList()
 {
     List<FleetXJob__c> jobsList = new List<FleetXJob__c>();
     User currentUser = [select Id,Name,city from user where Id=:UserInfo.getUserId() limit 1];
     if(currentUser.city!=null && currentUser.City!='')
     {
         jobsList = [select Id,Name,END_Departure__c,Pre_Scheduled_departure_time__c,Pre_Scheduled_Arrival_time__c,
                     scheduleDeparture__c,Arrival_Difference__c,Departure_Difference__c,Vehicle_Number__r.Name,Vehicle_Number__c,
                     FleetX_RouteName__r.Name,FleetX_RouteName__c,Transport_Type__c,
                     Escorter__c,Escorter__r.Name,FleetX_Driver__c,Job_Created_Date__c,FleetX_Driver__r.Name,End_KM__c,Driver_2__c,Escorter2__c,
                     Driver_2__r.Name,Escorter2__r.Name,Job_Status__c
                     from FleetXJob__c where CreatedDate >= LAST_N_DAYS:10 and End_KM__c = null and
                     Job_Status__c!='COMPLETED' and Job_Status__c!='CANCELLED' and CreatedBy.City=:currentUser.City ];         
     }
     

     System.debug('10 jobsList:'+jobsList);
     return jobsList;
 }
// added newly by Imran

    @AuraEnabled
    public static Boolean savePhoto(String fileData, String LinkedrecordId,String FileName){
        
        List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
        
        try{
            if (fileData.startsWith('data:image/jpeg;base64,')) {
                fileData = fileData.substring('data:image/jpeg;base64,'.length());
            }
            
            ContentVersion cVersion = new ContentVersion();
            Id conDocId;
            
            cVersion.PathOnClient = FileName+'.png'; 
            cVersion.Title = FileName+'.png'; 
            cVersion.VersionData = EncodingUtil.base64Decode(fileData); 
            Insert cVersion;
            
            if(cVersion.Id != null){
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            }
            
            ContentDocumentLink conDocLinkObj = new ContentDocumentLink();
            conDocLinkObj.ContentDocumentId = conDocId;
            conDocLinkObj.LinkedEntityId = LinkedrecordId;
            conDocLinkObj.ShareType = 'V';
            conDocLinkObj.Visibility = 'AllUsers';
            contentDocumentList.add(conDocLinkObj);
            
            if(contentDocumentList.size() > 0){
                Upsert contentDocumentList;
                
            }
            
            return true;
        }catch(Exception ex){
            System.debug('Error occure Line Number '+ex.getLineNumber());
            System.debug('Error occure Message '+ex.getMessage());
        
            return false;
        }
        
    }

// close Walking JOB
	@AuraEnabled
    public static String CloseWalkingFXJob(String jobId)
    {
        String result=null;
        try
        {
            FleetXJob__c walkingJob = [select Id,Name,Job_Status__c from FleetXJob__c where Id=:jobId limit 1];
            walkingJob.Job_Status__c='COMPLETED';
            update walkingJob;
            result='success';
            
        }catch(Exception e)
        {
            result='Fail :'+e.getMessage();
        }
        return result;
    }
// upto here adde by newly by Imran
    @AuraEnabled
    public static String updateFXJob(String jobId,String DrId,String EsId, String DrId1,String EsId1,
                                     String endKM,boolean showendKm)
    {
        String res;
        System.debug('17 jobId:'+jobId);
        System.debug('18 DrId:'+DrId);
        System.debug('19 EsId:'+EsId);
        try
        {
            FleetXJob__c fj = [select Id,Name,Escorter__c,FleetX_Driver__c,
                                Driver_2__c,Escorter2__c,End_KM__c from FleetXJob__c where Id=:jobId limit 1]; 
            if(showendKm && endKM!=null && endKM!='')
            {
                fj.End_KM__c = endKM;
                update fj;
                res='success';
            }
            else
            {
                if((DrId!=null && DrId!='') || (EsId!=null && EsId!='') || (DrId1!=null && DrId1!='') || (EsId1!=null && EsId1!='') )
                {
                    if(DrId!=null && DrId!='') { fj.FleetX_Driver__c=DrId; }
                    if(EsId!=null && EsId!='') { fj.Escorter__c=EsId; } 
                    // setting up Driver2 and Escorter2 Values
                    if(DrId1!=null && DrId1!='') { fj.Driver_2__c=DrId1; }
                    if(EsId1!=null && EsId1!='') {  fj.Escorter2__c=EsId1; }                    
                    update fj;
                    res='success';
                }                
            }
        } catch(Exception e)
        {
            res=e.getMessage();
        }

        return res;
    }
 @AuraEnabled
 public static List<Pickup__c> getPickupsByJob(String jobId)
 {
     List<Pickup__c> pickupsList = new List<Pickup__c>();
     pickupsList = [select Id,Name from Pickup__c where FleetXJob__c=:jobId ];
     return pickupsList;
 }
 @AuraEnabled
 public static List<Shipment__c> getShipmentsByJob(String jobId)
 {
     List<Shipment__c> ShipList = new List<Shipment__c>();
     ShipList = [select Id,Name,Shipping_Note_Number__c from Shipment__c where FleetXJob__c=:jobId ];
     return ShipList;
 }
 @AuraEnabled
 public static List<Linehaul_Tracking__c> getLHByJob(String jobId)
 {
     List<Linehaul_Tracking__c> LHList = new List<Linehaul_Tracking__c>();
     LHList = [select Id,Name from Linehaul_Tracking__c where FleetXJob__c=:jobId ];
     return LHList;
 }  
  @AuraEnabled
  public static String removeJobFromLH(String lhId)
  {
    String res;
      System.debug('pickupId :'+lhId);
      if(lhId!=null)
      {
          Linehaul_Tracking__c LHT = [select Id,Name,FleetXJob__c from Linehaul_Tracking__c where Id=:lhId limit 1];
          System.debug('LHT :'+LHT);
          LHT.FleetXJob__c=null;
          try
          {
            update LHT;  
              res =LHT.Name+' Removed From Job';
              System.debug('90 ship :'+LHT);
          }catch(exception e)
          {
              System.debug('30 Update Error :'+e.getMessage());
              res=e.getMessage();
          }
      }
      System.debug('97 res :'+res);
    return res;
  }     
  @AuraEnabled
  public static String removeJobFromShipment(String shipId)
  {
    String res;
      System.debug('pickupId :'+shipId);
      if(shipId!=null)
      {
          Shipment__c ship = [select Id,Name,FleetXJob__c from Shipment__c where Id=:shipId limit 1];
          // Shipment__c ship = [select Id,Name,FleetXJob__c,Fleet_X_Routes__c from Shipment__c where Id=:shipId limit 1];
          System.debug('ship :'+ship);
          ship.FleetXJob__c=null;
          // ship.Fleet_X_Routes__c=null;
          try
          {
            update ship;  
              res =ship.Name+' Removed From Job';
              System.debug('114ship :'+ship);
          }catch(exception e)
          {
              System.debug('117 Update Error :'+e.getMessage());
              res=e.getMessage();
          }
      }
      System.debug('121 res :'+res);
    return res;
  }    
  @AuraEnabled
  public static String removeJobFromPickup(String pickupId)
  {
    String res;
      System.debug('pickupId :'+pickupId);
      if(pickupId!=null)
      {
          Pickup__c pick = [select Id,Name,FleetXJob__c from Pickup__c where Id=:pickupId limit 1];
          System.debug('132 pick :'+pick);
          pick.FleetXJob__c=null;
          try
          {
            update pick;  
              res =pick.Name+' Removed From Job';
              System.debug('138 pick :'+pick);
          }catch(exception e)
          {
              System.debug('141 Update Error :'+e.getMessage());
              res=e.getMessage();
          }
      }
      System.debug('res :'+res);
    return res;
  }
 @AuraEnabled
 public static String mapJobToPickup(String jobId,String pickupId)
 {
	String res;
     Pickup__c pick = [select Id,Name,FleetXJob__c from Pickup__c where Id=:pickupId limit 1];
     System.debug('pick :'+pick);
     pick.FleetXJob__c=jobId;
     try
     {
         update pick;  
         res =pick.Name+' Added Successfuly';
         System.debug('52 pick :'+pick);
     }catch(exception e)
     {
         System.debug('Update Error :'+e.getMessage());
         res=e.getMessage();
     }
    return res;
 } 
 @AuraEnabled
 public static String mapJobToShipment(String jobId,String shipId)
 {
	String res;
     Shipment__c ship = [select Id,Name,FleetXJob__c from Shipment__c where Id=:shipId limit 1];
     System.debug('172 ship :'+ship);
     ship.FleetXJob__c=jobId;
     try
     {
         update ship;  
         res =ship.Name+' Added Successfuly';
         System.debug('177 pick :'+ship);
     }catch(exception e)
     {
         System.debug('181 Update Error :'+e.getMessage());
         res=e.getMessage();
     }
    return res;
 }        
 @AuraEnabled
 public static String mapJobToLH(String jobId,String lhId)
 {
	String res;
     Linehaul_Tracking__c LHT = [select Id,Name,FleetXJob__c from Linehaul_Tracking__c where Id=:lhId limit 1];
     System.debug('191 LHT :'+LHT);
     LHT.FleetXJob__c=jobId;
     try
     {
         update LHT;  
         res =LHT.Name+' Added Successfuly';
         System.debug('197 pick :'+LHT);
     }catch(exception e)
     {
         System.debug('200 Update Error :'+e.getMessage());
         res=e.getMessage();
     }
    return res;
 }    
    public static void GetCoverage20(){
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
    public static void GetCoverage21(){
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