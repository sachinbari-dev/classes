/*
*  @Created By  : Imran
*  Created Date : 16/02/2024
*  version 1.0		: Remove Sharing from Shipmet for Operation Field Executive Users 
* 
*/

public class EscorterSharingRemove 
{
    @InvocableMethod(label='Escorter Sharing Remove')
    public static void removeSharing(List<String> shipIds)
    {        
        if(shipIds.size()>0)
        {                        
            Shipment__c ship = [select Id,OwnerId,Owner.Profile.Name,Owner.Name from Shipment__c where Id=:shipIds[0]];
            List<Shipment__Share> OldShare = new List<Shipment__Share>();
            List<String> Old_userIds = new List<String>();
            List<String> existingIds = new List<String>();
            System.debug('Record Owner Profile name :'+ship.Owner.Profile.Name);
            System.debug('Owner Name :'+ship.Owner.Name);
            if(ship.Owner.Profile.Name=='Operations Field Executive')
            {
                Shipment__Share singleSH = [select Id,UserOrGroupId,UserOrGroup.Name
                                            from Shipment__Share where ParentId=:shipIds[0] and UserOrGroupId!=:ship.OwnerId limit 1];
                System.debug('UserOrGroup.Name :'+singleSH.UserOrGroup.Name);
                OldShare = [select Id,ParentId, UserOrGroupId,UserOrGroup.Name, UserOrGroup.Profile.Name  
                            from Shipment__Share where ParentId=:shipIds[0] and
                            UserOrGroup.Profile.Name!=:'Operations Field Executive'];
                System.debug('After this'+OldShare);
                if(OldShare.size()>0)
                {
                    for(Shipment__Share ss : OldShare)
                    {
                        Old_userIds.add(ss.UserOrGroupId);
                    }                    
                }
                
                try{                    
                    try
                    {
                        System.debug('Before Getting User');
                        User user = [select Id from user where Id=:singleSH.UserOrGroupId limit 1];
                        System.debug('Getting User');
                        if(user!=null)
                        {
                            System.debug('user : '+user);
                            ship.OwnerId=user.Id;
                            update ship;                        
                        }                        
                    }
                    catch(Exception e)
                    {
                        User user1 = [select Id from user where Name=:'imran shaik' limit 1];
                        System.debug('user1 : '+user1);
                        ship.OwnerId=user1.Id;
                        update ship;                         
                    }

                    if(Old_userIds.size()>0)
                    {
                        List<Shipment__Share> existingShare = [select Id,ParentId, UserOrGroupId,UserOrGroup.Name, UserOrGroup.Profile.Name  
                                                               from Shipment__Share where ParentId=:shipIds[0] ]; 
                        for(Shipment__Share s:existingShare)
                        {
                            existingIds.add(s.UserOrGroupId);
                        }
                        List<Shipment__Share> newSharing = new List<Shipment__Share>();
                        
                        for(String singleid:Old_userIds)
                        {
                            if(!(existingIds.contains(singleid)))
                            {
                                Shipment__Share share = new Shipment__Share();
                                share.UserOrGroupId=singleid;
                                share.ParentId=ship.Id;
                                share.RowCause='Manual';
                                share.AccessLevel='Edit';
                                newSharing.add(share);
                            }                                              
                        }
                        if(newSharing.size()>0)  
                        {
                            insert newSharing;
                        }
                    }                    
                }
                catch(Exception e)
                {
                    System.debug('Error Found :'+e.getMessage());
                }                                
            }            
        }      
    }
}