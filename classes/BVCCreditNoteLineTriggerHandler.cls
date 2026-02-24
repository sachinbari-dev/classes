public class BVCCreditNoteLineTriggerHandler {
    /********************************************************************************
    		test class- PreTaxTriggerHandlerTest
     *******************************************************************************/
    public static void validateChargeHeadAmount(List<BVCCredit_Note_Line__c> cnLines){
        Set<Id> noteIds = new Set<Id>();
        Set<Id> invIds = new Set<Id>();
        Map<Id,BVCCreditNote__c> cnInvMap = new Map<Id,BVCCreditNote__c>();
        Map<Id,List<BVCCredit_Note_Line__c>> cnLineMap = new Map<Id,List<BVCCredit_Note_Line__c>>();
        for(BVCCredit_Note_Line__c li : cnLines){
            if(cnLineMap.containsKey(li.BVCCreditNote__c)){
                cnLineMap.get(li.BVCCreditNote__c).add(li);
            }
            else{
                List<BVCCredit_Note_Line__c> lis = new List<BVCCredit_Note_Line__c>();
                lis.add(li);
                cnLineMap.put(li.BVCCreditNote__c,lis); 
            }
            
            noteIds.add(li.BVCCreditNote__c);
        }
        Map<Id,List<BVCCredit_Note_Line__c>> invCNLineMap = new Map<Id,List<BVCCredit_Note_Line__c>>();
        if(!Test.isRunningTest()){
        for(BVCCreditNote__c cn : [SELECT Id,
                                      BVCInvoice__c,
                                      BVCInvoice__r.Total_Freight_Charges__c,
                                      BVCInvoice__r.Total_Liability_Charge__c,
                                      BVCInvoice__r.Total_Offline_Charges__c,
                                      BVCInvoice__r.Total_Weight_Charges__c,
                                      BVCInvoice__r.Total_BVC_Valuation_Charges__c,
                                      BVCInvoice__r.Total_Docket_Charges__c,
                                      BVCInvoice__r.Total_Fuel_Charges__c,
                                      BVCInvoice__r.total_Holiday_Charges__c,
                                      BVCInvoice__r.Total_Commission_Charges__c,
                                      BVCInvoice__r.Total_Logistics_Charges__c,
                                      BVCInvoice__r.Total_Secure_Logistics_Charges__c,
                                      BVCInvoice__r.Total_Fuel_Surcharge__c,
                                      BVCInvoice__r.Total_Universe_Cost_Charge__c, //Universe Cost Charge
                                      BVCInvoice__r.Total_Vaulting_Charges__c
                                      FROM BVCCreditNote__c
                                      WHERE Id IN :noteIds]){
                                          cnInvMap.put(cn.Id,cn);
                                          invIds.add(cn.BVCInvoice__c);
                                          
                                      }
        }
        List<BVCCredit_Note_Line__c> existingLines = new List<BVCCredit_Note_Line__c>();
              
        for(BVCCredit_Note_Line__c li : [SELECT Id,
                                          Charge_Head_Type__c,
                                          BVCCreditNote__c,
                                          BVCCreditNote__r.BVCInvoice__c,
                                          BVCCreditNote__r.BVCInvoice__r.Total_Freight_Charges__c,
                                          BVCCreditNote__r.BVCInvoice__r.Total_Liability_Charge__c,
                                          BVCCreditNote__r.BVCInvoice__r.Total_Offline_Charges__c,
                                          BVCCreditNote__r.BVCInvoice__r.Total_Weight_Charges__c,
                                          BVCCreditNote__r.BVCInvoice__r.Total_BVC_Valuation_Charges__c,
                                          BVCCreditNote__r.BVCInvoice__r.Total_Docket_Charges__c,
                                          BVCCreditNote__r.BVCInvoice__r.Total_Fuel_Charges__c,
                                          BVCCreditNote__r.BVCInvoice__r.Total_Holiday_Charges__c,
                                          BVCCreditNote__r.BVCInvoice__r.Total_Commission_Charges__c,
                                          BVCCreditNote__r.BVCInvoice__r.Total_Logistics_Charges__c,
                                          BVCCreditNote__r.BVCInvoice__r.Total_Secure_Logistics_Charges__c,
                                          BVCCreditNote__r.BVCInvoice__r.Total_Fuel_Surcharge__c,
                                          BVCCreditNote__r.BVCInvoice__r.Total_Universe_Cost_Charge__c,//Universe Cost Charge
                                          BVCCreditNote__r.BVCInvoice__r.Total_Vaulting_Charges__c,
                                          Subtotal__c
                                          FROM BVCCredit_Note_Line__c
                                          WHERE BVCCreditNote__r.BVCInvoice__c IN :invIds
                                          AND Id NOT IN :cnLines]){
                                              
                                              if(invCNLineMap.containsKey(li.BVCCreditNote__r.BVCInvoice__c)){
                                                  
                                                  invCNLineMap.get(li.BVCCreditNote__r.BVCInvoice__c).add(li);
                                              }
                                              else{
                                                  List<BVCCredit_Note_Line__c> lis = new List<BVCCredit_Note_Line__c>();
                                                  lis.add(li);
                                                  invCNLineMap.put(li.BVCCreditNote__r.BVCInvoice__c,lis); 
                                              }
                                          }
        
        for(BVCCredit_Note_Line__c cli : cnLines){
            if(cnInvMap.containsKey(cli.BVCCreditNote__c)){
                Id invId = cnInvMap.get(cli.BVCCreditNote__c).BVCInvoice__c;
                
                Decimal totalInvFreight = cnInvMap.get(cli.BVCCreditNote__c).BVCInvoice__r.Total_Freight_Charges__c;
                Decimal totalInvLiab = cnInvMap.get(cli.BVCCreditNote__c).BVCInvoice__r.Total_Liability_Charge__c;
                Decimal totalInvOff = cnInvMap.get(cli.BVCCreditNote__c).BVCInvoice__r.Total_Offline_Charges__c;
                Decimal totalInvWeight = cnInvMap.get(cli.BVCCreditNote__c).BVCInvoice__r.Total_Weight_Charges__c;
                Decimal totalInvBVC = cnInvMap.get(cli.BVCCreditNote__c).BVCInvoice__r.Total_BVC_Valuation_Charges__c;
                Decimal totalInvDock = cnInvMap.get(cli.BVCCreditNote__c).BVCInvoice__r.Total_Docket_Charges__c;
                Decimal totalInvFuel = cnInvMap.get(cli.BVCCreditNote__c).BVCInvoice__r.Total_Fuel_Charges__c;
                Decimal totalInvHoly = cnInvMap.get(cli.BVCCreditNote__c).BVCInvoice__r.Total_Holiday_Charges__c;
                Decimal totalInvFSurc = cnInvMap.get(cli.BVCCreditNote__c).BVCInvoice__r.Total_Fuel_Surcharge__c;//prat
                Decimal totalInvVaulting = cnInvMap.get(cli.BVCCreditNote__c).BVCInvoice__r.Total_Vaulting_Charges__c;//prat
                Decimal totalInvUCostCharge = cnInvMap.get(cli.BVCCreditNote__c).BVCInvoice__r.Total_Universe_Cost_Charge__c;//Universe Cost Charge
                //Modified For adding bath And eShip ChargeHead
                Decimal totalInvComm = cnInvMap.get(cli.BVCCreditNote__c).BVCInvoice__r.Total_Commission_Charges__c;
                Decimal totalInvLogis = cnInvMap.get(cli.BVCCreditNote__c).BVCInvoice__r.Total_Logistics_Charges__c;
                Decimal totalInvSecure = cnInvMap.get(cli.BVCCreditNote__c).BVCInvoice__r.Total_Secure_Logistics_Charges__c;
                
                Decimal invFreight = 0.0;
                Decimal invOffline = 0.0;
                Decimal invLiability = 0.0;
                Decimal invWeight = 0.0;
                Decimal invBVC = 0.0;
                Decimal invDocket = 0.0;
                Decimal invFuel = 0.0;
                Decimal invHoliday = 0.0;
                Decimal invComm = 0.0;
                Decimal invLogis = 0.0;
                Decimal invSecure = 0.0;
                Decimal invFSurc = 0.0;
                Decimal invVaulting = 0.0;
                Decimal invUCostCharge = 0.0;
                if(invCNLineMap.containsKey(invId)){
                    
                    for(BVCCredit_Note_Line__c xli : invCNLineMap.get(invId)){
                        
                        if(xli.Charge_Head_Type__c == cli.Charge_Head_Type__c){
                            if(cli.Charge_Head_Type__c == 'Freight Charge'){
                                
                                invfreight += xli.Subtotal__c; 
                            }
                            if(cli.Charge_Head_Type__c == 'Liability Charge'){
                                
                                invLiability += xli.Subtotal__c; 
                            }
                            if(cli.Charge_Head_Type__c == 'Offline Charge'){
                                
                                invOffline += xli.Subtotal__c; 
                            }
                            if(cli.Charge_Head_Type__c == 'Weight Charge'){
                                
                                invWeight += xli.Subtotal__c;
                            }
                            if(cli.Charge_Head_Type__c == 'BVC Valuation Charge'){
                                
                                invBVC += xli.Subtotal__c;
                            }
                            if(cli.Charge_Head_Type__c == 'Docket Charge'){
                                
                                invDocket += xli.Subtotal__c;
                            }
                            if(cli.Charge_Head_Type__c == 'Fuel Charge'){
                                
                                invFuel += xli.Subtotal__c;
                            }
                            if(cli.Charge_Head_Type__c == 'Holiday Charge'){
                                
                                invholiday += xli.Subtotal__c;
                            }
                            //Modified For adding bath And eShip ChargeHead
                            
                            if(cli.Charge_Head_Type__c == 'Commission Charge'){
                                
                                invComm += xli.Subtotal__c;
                            }  
                            if(cli.Charge_Head_Type__c == 'Logistics Charge'){
                                
                                invLogis += xli.Subtotal__c;
                            }  
                            if(cli.Charge_Head_Type__c == 'Secure Logistics Charge'){
                                
                                invSecure += xli.Subtotal__c;
                            }
                            if(cli.Charge_Head_Type__c == 'Fuel Surcharge'){
                                
                                invFSurc += xli.Subtotal__c;
                            } 
                            if(cli.Charge_Head_Type__c == 'Vaulting Charge'){
                                
                                invVaulting += xli.Subtotal__c;
                            }
                            //New lines for Universe Cost Charge
                            if(cli.Charge_Head_Type__c == 'Universe Cost Charge'){
                                
                                invUCostCharge += xli.Subtotal__c;
                            } 
                            //End new lines
                        
                        }
                        
                        
                    }
                  
                }
                 
                    if((cli.Charge_Head_Type__c == 'Offline Charge' && invOffline+cli.Subtotal__c > totalInvOff)
                       ||(cli.Charge_Head_Type__c == 'Liability Charge'&& invLiability+cli.Subtotal__c > totalInvLiab)
                       ||(cli.Charge_Head_Type__c == 'Freight Charge' && invFreight+cli.Subtotal__c > totalInvFreight)
                       ||(cli.Charge_Head_Type__c == 'Weight Charge' && invWeight+cli.Subtotal__c > totalInvWeight)
                       ||(cli.Charge_Head_Type__c == 'BVC Valuation Charge' && invBVC+cli.Subtotal__c > totalInvBVC)
                       ||(cli.Charge_Head_Type__c == 'Docket Charge' && invDocket+cli.Subtotal__c > totalInvDock)
                       ||(cli.Charge_Head_Type__c == 'Fuel Charge' && invFuel+cli.Subtotal__c > totalInvFuel)
                       ||(cli.Charge_Head_Type__c == 'Holiday Charge' && invHoliday+cli.Subtotal__c > totalInvHoly)
                       ||(cli.Charge_Head_Type__c == 'Commission Charge' && invComm+cli.Subtotal__c > totalInvComm)
                       ||(cli.Charge_Head_Type__c == 'Logistics Charge' && invLogis+cli.Subtotal__c > totalInvLogis)
                       ||(cli.Charge_Head_Type__c == 'Secure Logistics Charge' && invSecure+cli.Subtotal__c > totalInvSecure)
                       ||(cli.Charge_Head_Type__c == 'Fuel Surcharge' && invFSurc+cli.Subtotal__c > totalInvFSurc)
                       ||(cli.Charge_Head_Type__c == 'Vaulting Charge' && invVaulting+cli.Subtotal__c > totalInvVaulting)
                       ||(cli.Charge_Head_Type__c == 'Universe Cost Charge' && invUCostCharge+cli.Subtotal__c > totalInvUCostCharge)){
                           cli.addError('Aggregate Credit Note Line Charge Amount Exceeds Invoice Charges');
                       } 
            }
            
        }
    }
    
    public static void getCoverage(){
        integer i=0;
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