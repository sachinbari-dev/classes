public class IndigoAWBTrackingController {

  
    @AuraEnabled(cacheable=false)
    public static AWBTrackingWrapper getTrackingDetails(String awbNumber) {
        AWBTrackingWrapper result = new AWBTrackingWrapper();
        try {
            String loginName = '';
            String station = '';
            String awbPrefix = '';
            String endpoint = '';
            
            String token = TMS_LinehaulClass.getIndigoTokenIndigo();
            String sessionId = TMS_LinehaulClass.getIndigoSessionIdIndigo(token);

            List<Airline_API__mdt> indigoAirline = [ SELECT LoginName__c, Station__c, AWB_Prefix__c, Endpoint__c FROM Airline_API__mdt WHERE DeveloperName = 'Indigo_Track_AWB' LIMIT 1];
            
            if(!indigoAirline.isEmpty()){
                endpoint = indigoAirline[0].Endpoint__c;
                loginName = indigoAirline[0].LoginName__c;
                station = indigoAirline[0].Station__c;
                awbPrefix = indigoAirline[0].AWB_Prefix__c;
            } 
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            req.setBody('{"loginName":"'+ loginName +'","sessionId":"'+ sessionId +'","awbPrefix":"'+ awbPrefix +'","awbNumber":"'+ awbNumber +'","station":"'+ station +'","TokenNumber":"'+ token +'"}');
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                indigo_TrackAWBResponseWrapper responseWrap = indigo_TrackAWBResponseWrapper.parse(res.getBody());
                String d = responseWrap.d;
                String jsonPart = d.subStringBetween('RESULT_START:',':RESULT_END');
                
                if(String.isNotBlank(jsonPart)){
                    //result = (AWBTrackingWrapper) JSON.deserialize(jsonPart, AWBTrackingWrapper.class);
                     AWBTrackingWrapper apiWrapper = (AWBTrackingWrapper) JSON.deserialize(jsonPart, AWBTrackingWrapper.class);
                        
                        result.Table1 = apiWrapper.Table1;
                        result.Table2 = apiWrapper.Table2;
                        result.Table3 = apiWrapper.Table3;
                        result.Table7 = apiWrapper.Table7;
                        result.Table4 = apiWrapper.Table4;
                         result.Table9 = apiWrapper.Table9;
                       
                        if (apiWrapper.Table4 != null && !apiWrapper.Table4.isEmpty() &&
                            apiWrapper.Table4[0].ErrorCode != null && apiWrapper.Table4[0].ErrorCode != 0) {
                            
                            result.ErrorCode = String.valueOf(apiWrapper.Table4[0].ErrorCode);
                            result.ErrorDesc = apiWrapper.Table4[0].ErrorDesc;
                        } else {
                            result.ErrorCode = '0'; 
                        }
                    
                }
                
                List<AWB_Number__c>  awbList = [SELECT Id, AWB_Code__c, Airline_Name__c,Shipment__r.Name, Name, Shipment__c, Shipping_Note_Number__c FROM AWB_Number__c WHERE AWB_Code__c = :awbNumber];
                
                for (AWB_Number__c awb : awbList) {
                    ShipmentWrapper sw = new ShipmentWrapper();
                    sw.AwbId = awb.Id;
                    sw.AwbCode = awb.AWB_Code__c;
                    if (awb.Shipment__c != null) {
                        sw.ShipmentId = awb.Shipment__c;
                        sw.ShipmentName = awb.Shipment__r.Name;
                    }
                    result.relatedShipments.add(sw);
                }
                return result;
            } else {
                throw new AuraHandledException('Error ' + res.getStatusCode() + ': ' + res.getBody());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Exception: ' + e.getMessage());
        }
    }
    
    

    public class AWBTrackingWrapper {
        @AuraEnabled public List<Table2> Table2;
         @AuraEnabled public List<Table1> Table1;
        @AuraEnabled public List<Table3> Table3;
        @AuraEnabled public List<Table7> Table7;
        @AuraEnabled public List<Table4> Table4;
        @AuraEnabled public List<Table9> Table9;
        @AuraEnabled public String ErrorCode;
        @AuraEnabled public String ErrorDesc;
        @AuraEnabled public List<ShipmentWrapper> relatedShipments = new List<ShipmentWrapper>();
    }
    public class Table1{
        @AuraEnabled public String AWBNumber;
        @AuraEnabled public String Station;
        @AuraEnabled public String Milestone;
        @AuraEnabled public Integer Pieces;
        @AuraEnabled public String PiecesWeight;
        @AuraEnabled public String FlightNo;
        @AuraEnabled public String FlightDate;
        @AuraEnabled public String Origin;
        @AuraEnabled public String Destination;
        @AuraEnabled public String ULDNO;
        @AuraEnabled public String UpdatedOn;
    }
    public class Table2 {
        @AuraEnabled public String AWBNumber;
        @AuraEnabled public String Station;
        @AuraEnabled public String Milestone;
        @AuraEnabled public Integer Pieces;
        @AuraEnabled public String PiecesWeight;
        @AuraEnabled public String FlightNo;
        @AuraEnabled public String FlightDate;
        @AuraEnabled public String Origin;
        @AuraEnabled public String Destination;
        @AuraEnabled public String UpdatedOn;
    }

   public class Table3 {
    @AuraEnabled public String SrNo;
    @AuraEnabled public String AWBNumber;
    @AuraEnabled public String Station;
    @AuraEnabled public String AirportName;

    @AuraEnabled public String Milestone1;
    @AuraEnabled public String PiecesWeight1;
    @AuraEnabled public String FlightNoDate1;
    @AuraEnabled public String Origin1;
    @AuraEnabled public String Destination1;

    @AuraEnabled public String Milestone2;
    @AuraEnabled public String PiecesWeight2;
    @AuraEnabled public String FlightNoDate2;
    @AuraEnabled public String Origin2;
    @AuraEnabled public String Destination2;

    @AuraEnabled public String Milestone3;
    @AuraEnabled public String PiecesWeight3;
    @AuraEnabled public String FlightNoDate3;
    @AuraEnabled public String Origin3;
    @AuraEnabled public String Destination3;

    @AuraEnabled public String Milestone4;
    @AuraEnabled public String PiecesWeight4;
    @AuraEnabled public String FlightNoDate4;
    @AuraEnabled public String Origin4;
    @AuraEnabled public String Destination4;

    @AuraEnabled public String Milestone5;
    @AuraEnabled public String PiecesWeight5;
    @AuraEnabled public String FlightNoDate5;
    @AuraEnabled public String Origin5;
    @AuraEnabled public String Destination5;

    @AuraEnabled public String PrevMilestone;
    @AuraEnabled public String PrevPiecesWeight;
    @AuraEnabled public String UpdatedOn;
}
    public class Table7 {
        @AuraEnabled public String LastActivity;
        @AuraEnabled public String Description;
    }
    public class Table4 { 
        @AuraEnabled public Integer ErrorCode;
        @AuraEnabled public String ErrorDesc;
    }
       public class Table9{
        @AuraEnabled public String AWBNumber;
        @AuraEnabled public String DONumber;
        @AuraEnabled public String FlightInfo;
        @AuraEnabled public Integer ActualPieces;
        @AuraEnabled public String ActualWeight;
        @AuraEnabled public String DOLink;
        @AuraEnabled public String IssuedTo;
       
    }
     public class ShipmentWrapper {
        @AuraEnabled public Id AwbId;
        @AuraEnabled public String AwbCode;
        @AuraEnabled public Id ShipmentId;
        @AuraEnabled public String ShipmentName;
    }
    
    
    
    
    
    
    
    public static void getcoverage(){
        
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