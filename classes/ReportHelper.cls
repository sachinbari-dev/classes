/*Class      : ReportHelper
 *Author     : Sanket.pisal@bvclogistics.com
 *Date       : April 2024
 */

public without sharing class ReportHelper {
  @AuraEnabled
    public static List<Pickup__c> getPickups1()
    {
       User u = [select Id,Name,City,User_Hub__c from User where Id=: UserInfo.getUserId()];
        System.debug('User Name:'+u.Name);
      
        System.debug('User Address City:'+u.City);
      
        
        List<Pickup__c> pickupList = new List<Pickup__c>();
            pickupList = [SELECT Id, Name, Shipper_Name__c, Shipper_Name__r.Name, Shipper_Address__r.City__c, BVC_Origin_Hub__r.Name, 
                     Pickup_Assigned_To__r.FirstName, Pickup_Assigned_To__r.LastName, Shipper_Address__r.Name, 
                     Pickup_Route_Number__c, Pickup_Route_Number__r.Name, created_date_time__c, Pickup_Status__c, 
                     Pickup_Assigned_To__c, Number_of_Shipments_Picked_Up__c, Number_of_Packages__c, 
                     Pickup_Date__c, Assigned_Date_and_Time__c, Created_Date__c
              FROM Pickup__c
              WHERE Pickup_Status__c NOT IN ('Completed', 'Cancelled')
              AND (Pickup_Date__c = TODAY)
              AND (BVC_Origin_Hub__r.Name = :u.User_Hub__c )
              ORDER BY Created_Date__c DESC
              LIMIT 1000];
    return pickupList;       
    }
    //Delivery//
  @AuraEnabled
public static List<Delivery__c> getDeliveries(String searchText) {
    System.debug('Search Text' +searchText);
    User currentUser = [SELECT Id, Name,User_Hub__c, City FROM User WHERE Id = :UserInfo.getUserId()];
    System.debug('User Name: ' + currentUser.Name);
    System.debug('User City: ' + currentUser.City);
    
    List<Delivery__c> deliveryList = new List<Delivery__c>();
    
    if(searchText != null) {
        String Searchkey = '%' + searchText + '%';
        deliveryList = [SELECT Id, Name, Status__c, Shipment__c, Destination_Hub__c, Shipment__r.Name,Shipment__r.Destination_Hub__r.Name,Origin_Hub__c,Address__r.Name,CreatedDate,Number_of_Secure_Bag__c,Delivery_Assigned_To__c,POD__c,Shipping_Note_Number__c,Customer_Name__c,Actual_Delivery_Date_and_Time__c,Address__r.ADDRESS1__c
                        FROM Delivery__c
                        WHERE CreatedDate = Today
                        AND (Shipment__r.Destination_Hub__r.Name = :currentUser.User_Hub__c )
                        
                        AND (Shipping_Note_Number__c LIKE :Searchkey OR Status__c LIKE :Searchkey OR Customer_Name__c LIKE :Searchkey OR Delivery_Assigned_To__c LIKE :Searchkey )
                        LIMIT 1000]; 
    } else {
        deliveryList = [SELECT Id, Name, Status__c, Shipment__c, Destination_Hub__c,Origin_Hub__c,Shipment__r.Origin_Hub__r.Name,Shipment__r.Name, Address__r.Name,CreatedDate,Number_of_Secure_Bag__c,Delivery_Assigned_To__c,POD__c,Shipping_Note_Number__c,Customer_Name__c,Actual_Delivery_Date_and_Time__c,Address__r.ADDRESS1__c
                        FROM Delivery__c
                        WHERE CreatedDate = Today
                        AND (Shipment__r.Destination_Hub__r.Name = :currentUser.User_Hub__c )
                       
                        LIMIT 1000]; 
    }
     System.debug('Delivery List' +deliveryList);
    return deliveryList;       
}
//Partner Vehicle
 @AuraEnabled
public static List<Vehicle_Data__c> getVehicleData(String searchText) {
    System.debug('Search Text: ' + searchText);
    User currentUser = [SELECT Id, Name,User_Hub__c, City FROM User WHERE Id = :UserInfo.getUserId()];
    System.debug('User Name: ' + currentUser.Name);
    System.debug('User City: ' + currentUser.City);

    List<Vehicle_Data__c> vehicleDataList = new List<Vehicle_Data__c>();

    if (searchText != null) {
        String searchKey = '%' + searchText + '%';
        vehicleDataList = [SELECT Id, Name, Start_KM__c,End_KM__c,Escorter__r.Name,Vehicle_Number__r.Name,CreatedBy.Name
                            FROM Vehicle_Data__c
                           WHERE CreatedDate = Today
                           AND (User_Hub__r.Name = :currentUser.User_Hub__c )
                           
                           AND Vehicle_Number__r.Name LIKE :searchKey 
                           LIMIT 1000]; 
    } else {
        vehicleDataList = [SELECT Id, Name, Start_KM__c,End_KM__c,Escorter__r.Name,Vehicle_Number__r.Name,CreatedBy.Name
                           FROM Vehicle_Data__c
                           WHERE CreatedDate = Today
                           AND (User_Hub__r.Name = :currentUser.User_Hub__c )
                           
                           LIMIT 1000];
    }
    System.debug('Vehicle Data List: ' + vehicleDataList);
    return vehicleDataList;
}
   
    
    
    
//Secure Bags
 @AuraEnabled
public static List<Secure_Bag__c> getSecureBags(String searchText) {
    
    User currentUser = [SELECT Id, Name, City,User_Hub__c FROM User WHERE Id = :UserInfo.getUserId()];
    System.debug('User Name: ' + currentUser.Name);
    System.debug('User City: ' + currentUser.City);
    System.debug('SecuretextList:' +searchText);
    List<Secure_Bag__c> secureBagList = new List<Secure_Bag__c>();
    
    if(searchText != null) {
       String searchKey = '%' + searchText + '%';
        secureBagList = [SELECT Id, Name, Current_Scan_Hub__c, Shipping_Note_Number__c, Shipment__c,Secure_Packaging_Identifier__c,
                        Current_Scan_Hub__r.Name, Shipment__r.Name, Next_Destination__c,Shipment_Origin__c,Vaults__c,Vaults__r.Name,Current_Scan_Loction__c,Destination_Hub__c,CreatedDate,Shipper_Account__c,Consignee_Account__c
                        FROM Secure_Bag__c
                        WHERE Current_Scan_Loction__c IN ('Picked Up','Origin Hub','Transit Hub','Destination Hub','Out for Delivery')
                        AND (Current_Scan_Hub__r.Name = :currentUser.User_Hub__c )
                        AND (Secure_Packaging_Identifier__c LIKE :searchKey OR Shipping_Note_Number__c LIKE :searchKey OR Current_Scan_Loction__c LIKE :searchKey OR Vaults__r.Name LIKE :searchKey )   
                        AND LastModifiedDate = LAST_N_DAYS:7 AND Shipment__r.Cancel_Shipment__c= false AND Shipment__r.RTO__c = false
                        ORDER BY CreatedDate DESC 
                        LIMIT 1000];
    } else {
        secureBagList = [SELECT Id, Name, Current_Scan_Hub__c, Shipping_Note_Number__c, Shipment__c,Secure_Packaging_Identifier__c,
                        Current_Scan_Hub__r.Name, Shipment__r.Name, Next_Destination__c,Shipment_Origin__c,Vaults__c,Vaults__r.Name,Current_Scan_Loction__c,Destination_Hub__c,CreatedDate,Shipper_Account__c,Consignee_Account__c
                        FROM Secure_Bag__c
                        WHERE Current_Scan_Loction__c IN ('Picked Up','Origin Hub','Transit Hub','Destination Hub','Out for Delivery')
                        AND (Current_Scan_Hub__r.Name = :currentUser.User_Hub__c )
                        AND LastModifiedDate = LAST_N_DAYS:7 AND Shipment__r.Cancel_Shipment__c= false AND Shipment__r.RTO__c = false
                        ORDER BY CreatedDate DESC
                        LIMIT 1000];
    }
    System.debug('Secure List List' +secureBagList);
    return secureBagList;       
    
}



    @AuraEnabled
    public static List<Linehaul_Tracking__c> getLinehauls(String searchText) {
        User u = [SELECT City FROM User WHERE Id = :UserInfo.getUserId()];
        List<Linehaul_Tracking__c> linehaulList = new List<Linehaul_Tracking__c>();
        System.debug('searchText :'+searchText);
        if(searchText!=null)
        {
            searchText = '%'+searchText+'%';
            linehaulList = [SELECT Id, Name,Origin__c,AWB_Number__c,Destination__c,Fleet_X_Routes__r.Name,
                            Linehaul_Type__c,Fleet_X_Routes__c,CreatedDate,Airline__c,Vehicle_Number__c,No_of_Shipment_Notes__c,No_of_Package__c,Finalized_Linehaul_Number__c,Total_Number_of_Airline_Packages__c FROM Linehaul_Tracking__c 
                            WHERE (CreatedDate=TODAY OR CreatedDate = LAST_N_DAYS:7) and (Origin__c = :u.City OR Extracted_Origin__c =:u.City) and 
                            (AWB_Number__c Like:searchText OR Destination__c Like:searchText) limit 1000];            
        }
        else
        {
            linehaulList = [SELECT Id, Name,Origin__c,AWB_Number__c,Destination__c,Fleet_X_Routes__r.Name,
                            Linehaul_Type__c,Fleet_X_Routes__c,CreatedDate,Airline__c,Vehicle_Number__c,No_of_Shipment_Notes__c,No_of_Package__c,Finalized_Linehaul_Number__c,Total_Number_of_Airline_Packages__c FROM Linehaul_Tracking__c  
                            WHERE (CreatedDate=TODAY OR CreatedDate = LAST_N_DAYS:7) and (Origin__c = :u.City OR Extracted_Origin__c =:u.City)];            
        }
       
        return linehaulList;
    }
    @AuraEnabled
    public static List<Pickup__c> getPickups(String searchkey)
    {
        List<Pickup__c> pickupList = new List<Pickup__c>();
        User u = [select Id,Name,City,User_Hub__c from User where Id=: UserInfo.getUserId()];
        System.debug('Pickup Search key :'+searchkey);
        // User u = [select Id,Name,Address from User where Id=: UserInfo.getUserId()];
        if(searchkey!=null && searchkey!=''){
            pickupList = [select Id,Name,Shipper_Name__c,Shipper_Name__r.Name,Shipper_Address__r.City__c,BVC_Origin_Hub__r.Name,Pickup_Assigned_To__r.FirstName,Pickup_Assigned_To__r.LastName,Pickup_Status__c,Pickup_Assigned_To__c,
                          Shipper_Address__r.Name,Pickup_Route_Number__c,Pickup_Route_Number__r.Name,Customer__r.Name,Created_Date__c,created_date_time__c,Number_of_Shipments_Picked_Up__c,Number_of_Packages__c,Pickup_Date__c,Assigned_Date_and_Time__c
                          From Pickup__c WHERE  Pickup_Status__c !='Completed'
                          AND (Pickup_Date__c =TODAY)
                          AND (Shipper_Name__c=:searchkey OR Pickup_Status__c LIKE :searchKey OR Name LIKE :searchKey OR Pickup_Assigned_To__r.FirstName LIKE :searchKey )  and (BVC_Origin_Hub__r.Name = :u.User_Hub__c )  ORDER BY Created_Date__c DESC limit 1000];
            System.debug('Size :'+pickupList.size());
            
                       
        }
       
        
        if(pickupList.size()>0)
        {
            for(Pickup__c p: pickupList)
            {
                System.debug('P :'+p.Pickup_Route_Number__c);
            }
            return pickupList;
        }
        else
        {
            return null;
        }        
    }

   @AuraEnabled
public static List<Shipment__c> getShipments1() {
    User u = [SELECT City,User_Hub__c FROM User WHERE Id = :UserInfo.getUserId()];
    List<Shipment__c> shpList = [SELECT Id, Name, Pickup__c,
                   Customer_Product_Category__c, 
                   Customer__c,
                   Shipper_Name_TMS__r.Name,Shipper_Name_TMS__c,
                   Origin_Address_Name__c,Origin_Address_Name__r.Name,Origin_Address_City__c,
                   Insurance_By__c,
                   Shipment_Value__c,
                   Net_Weight__c,Origin_Hub__r.Name,
                   Reference_1__c, Delivery_Route_Assigned_To__c,
                   Consignee_Name_TMS__c, Consignee_Name_TMS__r.Name,
                   Destination_Address_Name__c,Destination_Address_Name__r.Name,Destination_Address_Name__r.City__c,Destination_Address_City__c,
                   Product_Description__c,Shipment_Created_Date_Time__c,Shipment_Date__c,
                   Net_Weight_UOM_TMS__c, Tracking_Status__c, Shipping_Note_Number__c,
                   Reciever_Name__c, Shipment_Created_Through__c, Delivery_Route_Number__c, Delivery_Route_Number__r.Name, CreatedDate,
                   Customer_Gross_Weight__c, Created_Through_Scan_Shipment__c, Number_of_Secure_Bags__c,Destination_Hub__r.Name,Cancel_Shipment__c,RTO__c
                   FROM Shipment__c 
                   WHERE Tracking_Status__c IN ('Created','Picked Up','Origin Hub','Pickup In Progress') AND Cancel_Shipment__c= false AND RTO__c = false
                   AND RecordTypeId NOT IN ('0125g000002AW4HAAW', '0125g000002AW4GAAW')              
                   AND (Origin_Hub__r.Name = :u.User_Hub__c)  AND CreatedDate = LAST_N_DAYS:7 AND Shipping_Note_Number__c != NUll];
    return shpList;
}

@AuraEnabled
public static List<Shipment__c> getShipments(String searchText) {
    System.debug('Shipment searchText :' + searchText);
    List<Shipment__c> shpList = new List<Shipment__c>();
    User u = [SELECT City,User_Hub__c FROM User WHERE Id = :UserInfo.getUserId()];

    if (searchText != null && searchText != '') {
        String searchkey = '%' + searchText + '%';
        System.debug('Shipment Search key :' + searchkey);
        shpList = [SELECT Id, Name, Pickup__c,
                   Customer_Product_Category__c, 
                   Customer__c,
                   Shipper_Name_TMS__c,
                   Origin_Address_Name__c,
                   Insurance_By__c,
                   Shipment_Value__c,
                   Net_Weight__c,
                   Reference_1__c, Delivery_Route_Assigned_To__c,
                   Consignee_Name_TMS__c, Consignee_Name_TMS__r.Name,
                   Destination_Address_Name__c, Destination_Address_Name__r.Name,Destination_Address_Name__r.City__c,Destination_Address_City__c,
                   Product_Description__c,Shipment_Created_Date_Time__c,Shipment_Date__c,
                   Net_Weight_UOM_TMS__c, Tracking_Status__c, Shipping_Note_Number__c,
                   Reciever_Name__c, Shipment_Created_Through__c,Delivery_Route_Number__c, Delivery_Route_Number__r.Name,
                   Customer_Gross_Weight__c, Created_Through_Scan_Shipment__c, Number_of_Secure_Bags__c,Destination_Hub__r.Name,Origin_Hub__r.Name,Shipper_Name_TMS__r.Name,Cancel_Shipment__c,RTO__c
                   FROM Shipment__c 
                   WHERE CreatedDate = LAST_N_DAYS:7
                   AND Tracking_Status__c IN ('Created','Picked Up','Origin Hub','Pickup In Progress') AND Cancel_Shipment__c= false AND RTO__c = false
                   AND Shipping_Note_Number__c != NUll
                   AND RecordTypeId NOT IN ('0125g000002AW4HAAW', '0125g000002AW4GAAW')
                   AND (Shipping_Note_Number__c LIKE :searchkey OR Shipper_Name_TMS__r.Name LIKE : searchkey OR Destination_Hub__r.Name LIKE : searchkey OR Tracking_Status__c LIKE : searchkey)
                   AND (Origin_Hub__r.Name = :u.User_Hub__c )];

        System.debug('size :' + shpList.size());
        System.debug('for checking shpList--- ' + shpList);
    } else {
        shpList = [SELECT Id, Name, Pickup__c,
                   Customer_Product_Category__c, 
                   Customer__c,
                   Shipper_Name_TMS__c,
                   Origin_Address_Name__c,
                   Insurance_By__c,
                   Shipment_Value__c,
                   Net_Weight__c,
                   Reference_1__c,
                   Consignee_Name_TMS__c, Consignee_Name_TMS__r.Name,
                   Destination_Address_Name__c,Destination_Address_Name__r.Name,Destination_Address_Name__r.City__c,Destination_Address_City__c,
                   Product_Description__c,Shipment_Created_Date_Time__c,Shipment_Date__c,
                   Net_Weight_UOM_TMS__c, Tracking_Status__c, Shipping_Note_Number__c,
                   Reciever_Name__c, Shipment_Created_Through__c, Delivery_Route_Number__c, Delivery_Route_Number__r.Name,
                   Customer_Gross_Weight__c, Created_Through_Scan_Shipment__c,Number_of_Secure_Bags__c,Destination_Hub__r.Name
                   FROM Shipment__c 
                   WHERE Tracking_Status__c IN ('Created','Picked Up','Origin Hub','Pickup In Progress') 
                   AND RecordTypeId NOT IN ('0125g000002AW4HAAW', '0125g000002AW4GAAW')
                   AND (Origin_Hub__r.Name = :u.User_Hub__c )AND CreatedDate = LAST_N_DAYS:7 AND Shipping_Note_Number__c != NUll];

    }        
    System.debug('for checking shpList--- ' + shpList);
    return shpList;
}

 @AuraEnabled
public static List<Shipment__c> getInboundShipments(String searchText) {
    System.debug('Shipment searchText :' + searchText);
    List<Shipment__c> shpList = new List<Shipment__c>();
    User u = [SELECT City,User_Hub__c FROM User WHERE Id = :UserInfo.getUserId()];

    if (searchText != null && searchText != '') {
        String searchkey = '%' + searchText + '%';
        System.debug('Shipment Search key :' + searchkey);
        shpList = [SELECT Id, Name, Pickup__c,
                   Customer_Product_Category__c, 
                   Customer__c,Customer__r.Name,
                   Shipper_Name_TMS__c,
                   Origin_Address_Name__c,
                   Insurance_By__c,
                   Shipment_Value__c,
                   Net_Weight__c,
                   Reference_1__c, Delivery_Route_Assigned_To__c,
                   Consignee_Name_TMS__c, Consignee_Name_TMS__r.Name,
                   Destination_Address_Name__c, Destination_Address_Name__r.Name,Destination_Address_Name__r.City__c,Destination_Address_City__c,
                   Product_Description__c,Shipment_Created_Date_Time__c,Shipment_Date__c,
                   Net_Weight_UOM_TMS__c, Tracking_Status__c, Shipping_Note_Number__c,
                   Reciever_Name__c, Shipment_Created_Through__c,Delivery_Route_Number__c, Delivery_Route_Number__r.Name,
                   Customer_Gross_Weight__c, Created_Through_Scan_Shipment__c, Number_of_Secure_Bags__c,Destination_Hub__r.Name,Origin_Hub__r.Name,Shipper_Name_TMS__r.Name,Cancel_Shipment__c,RTO__c
                   FROM Shipment__c 
                   WHERE CreatedDate = LAST_N_DAYS:10
                   AND Tracking_Status__c IN ('Created','Picked Up','Origin Hub','Transit Hub','Linehaul Finalised','Pickup In Progress') AND Cancel_Shipment__c = false
                   AND Shipping_Note_Number__c != NUll
                   AND RecordTypeId NOT IN ('0125g000002AW4HAAW', '0125g000002AW4GAAW')
                   AND (Origin_Hub__r.Name LIKE :searchkey OR Customer__r.Name LIKE :searchkey OR Consignee_Name_TMS__r.Name LIKE : searchkey OR Destination_Address_City__c LIKE : searchkey )
                   AND (Destination_Hub__r.Name = :u.User_Hub__c AND Origin_Hub__r.Name != :u.User_Hub__c)];

        System.debug('size :' + shpList.size());
        System.debug('for checking shpList--- ' + shpList);
    } else {
        shpList = [SELECT Id, Name, Pickup__c,
                   Customer_Product_Category__c, 
                   Customer__c,Customer__r.Name,
                   Shipper_Name_TMS__c,
                   Origin_Address_Name__c,
                   Insurance_By__c,
                   Shipment_Value__c,
                   Net_Weight__c,
                   Reference_1__c,
                   Consignee_Name_TMS__c, Consignee_Name_TMS__r.Name,
                   Destination_Address_Name__c,Destination_Address_Name__r.Name,Destination_Address_Name__r.City__c,Destination_Address_City__c,
                   Product_Description__c,Shipment_Created_Date_Time__c,Shipment_Date__c,
                   Net_Weight_UOM_TMS__c, Tracking_Status__c, Shipping_Note_Number__c,
                   Reciever_Name__c, Shipment_Created_Through__c, Delivery_Route_Number__c, Delivery_Route_Number__r.Name,
                   Customer_Gross_Weight__c, Created_Through_Scan_Shipment__c,Number_of_Secure_Bags__c,Destination_Hub__r.Name,Origin_Hub__r.Name,Shipper_Name_TMS__r.Name
                   FROM Shipment__c 
                   WHERE Tracking_Status__c IN ('Created','Picked Up','Origin Hub','Transit Hub','Linehaul Finalised','Pickup In Progress') 
                   AND Shipping_Note_Number__c != NUll
                   AND RecordTypeId NOT IN ('0125g000002AW4HAAW', '0125g000002AW4GAAW')
                   AND ( Destination_Hub__r.Name = :u.User_Hub__c AND Origin_Hub__r.Name != :u.User_Hub__c ) AND CreatedDate = LAST_N_DAYS:10 AND Cancel_Shipment__c = false];

    }        
    System.debug('for checking shpList--- ' + shpList);
    return shpList;
}
   
    
    
    

public class ShipPick
{
    public String pick;
} 
}