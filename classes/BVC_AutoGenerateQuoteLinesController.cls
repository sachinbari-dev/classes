public class BVC_AutoGenerateQuoteLinesController {
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getFinanceContacts(Id accountId) {
        if (accountId == null) {
            return new List<Contact>();
        }
        
        // Fetch contacts related to the account with Role = 'Finance'
        return [
            SELECT Id, Name 
            FROM Contact 
            WHERE AccountId = :accountId 
           AND Active_status__c = true // Adjust this field if needed
        ];
    }
    
    
    @AuraEnabled
    public static String checkExistingQuote(String AcId, String BusinessType, String bvcService,String priceSlab) {
        /*
        List<BVCQuote__c> existingQuoteList = new List<BVCQuote__c>();
        if(BusinessType=='ACR')
        {
                existingQuoteList = [
                SELECT Id, Account__c,Account__r.Name, Business_Type__c, BVC_Service__c,BVC_Price_Slab__c
                FROM BVCQuote__c
                WHERE Account__c = :AcId AND Business_Type__c = :BusinessType AND BVC_Price_Slab__c=:priceSlab 
                and (Status__c='Draft' OR Status__c='In Review')
            ];
        }
        else 
        {
            existingQuoteList = [
            SELECT Id, Account__c, Business_Type__c, BVC_Service__c
            FROM BVCQuote__c
            WHERE Account__c = :AcId AND Business_Type__c = :BusinessType AND BVC_Service__c = :bvcService
        ];
        }
        System.debug('existingQuoteList:'+existingQuoteList);
        return existingQuoteList.size() > 0 ? 'have quotes' : 'no quotes';
		*/
        return 'no quotes';
    }
    @AuraEnabled			
    public static String cloneBVC_Quotes(String acId, String BusinessType,
                                         String BranchId, String BVCService, Date StartDate,
                                         Boolean Primary, String exbhId, String priceSlab,String PaymentId,
                                         Id DecisionMaker, Id AuthorizedSignatory, Id Evaluator,
                                         Decimal manualPriceSlab,String TariffPlan,String PackageAmount,
                                         String QuoteType,String IsPaymentCollected,Date SubrogationStartDate,
                                         Date SubrogationEndDate,String InsuranceBy,Boolean CreatedThroughAutomation) {
        System.debug('Inside BVC QUote');
        BVCQuote__c createdQuote;
        String recordTypeId;
        String StringResultMessage;                                     
       System.debug('56 priceSlab :'+priceSlab);
       System.debug('56 BVCService :'+BVCService);
       // return 'success';                                    
        if (BusinessType != null) {
            BVC_Base_Quote_Settings1__c baseQuote;
            if (BusinessType == 'ACR') {
                recordTypeId = Schema.SObjectType.BVCQuote__c.getRecordTypeInfosByName().get('ACR').getRecordTypeId();
            } else if (BusinessType == 'Non ACR' &&  BVCService == 'ValSHIP') {
                baseQuote = [SELECT Id, Base_QuoteId__c, Quote_Business_Type__c,BVC_Service__c FROM BVC_Base_Quote_Settings1__c WHERE Quote_Business_Type__c = 'Non ACR' AND BVC_Service__c ='ValSHIP' LIMIT 1];
                recordTypeId = Schema.SObjectType.BVCQuote__c.getRecordTypeInfosByName().get('Non ACR').getRecordTypeId();
            } else  {
                
                baseQuote = [SELECT Id, Base_QuoteId__c, Quote_Business_Type__c,BVC_Service__c FROM BVC_Base_Quote_Settings1__c WHERE Quote_Business_Type__c = 'Non ACR'AND BVC_Service__c ='ExhibiSHIP' LIMIT 1];
                recordTypeId = Schema.SObjectType.BVCQuote__c.getRecordTypeInfosByName().get('Non ACR').getRecordTypeId();
            }
            System.debug('69 baseQuote :'+baseQuote);
            if (baseQuote != null && baseQuote.Base_QuoteId__c != null) {
                Id QuoteToClone = baseQuote.Base_QuoteId__c;
                QuoteCloneWithLine cloner = new QuoteCloneWithLine(QuoteToClone, 'BVCQuoteLineItems__r');
                BVCQuote__c beforeClone = (BVCQuote__c) cloner.clone;
                beforeClone.RecordTypeId = recordTypeId;
                beforeClone.Account__c = acId;
                beforeClone.Business_Type__c = BusinessType;
                beforeClone.BVC_Branch__c = BranchId;
                beforeClone.BVC_Service__c = BVCService;
                beforeClone.Start_Date__c = StartDate;
                beforeClone.Quote_Type__c = QuoteType;
                beforeClone.Subrogation_Start_Date__c = SubrogationStartDate;
                beforeClone.Subrogation_End_Date__c = SubrogationEndDate;
                beforeClone.Is_the_Payment_Collected__c = IsPaymentCollected;
                beforeClone.Payment_Id__c	= PaymentId;
                beforeClone.Primary__c = Primary;
                beforeClone.Exhibition__c = exbhId;
                beforeClone.Status__c = 'Draft';
                beforeClone.Tariff_Plan__c=TariffPlan;
                beforeClone.Package_Amount__c=PackageAmount;  
                beforeClone.Insurance_By__c = InsuranceBy;
                beforeClone.Created_through_Automation__c = True ;
                // Set the new fields
                beforeClone.Decision_Maker__c = DecisionMaker;
                beforeClone.Customer_Authorized_Signatory__c = AuthorizedSignatory;
                beforeClone.Evaluator__c = Evaluator;
                beforeClone.OwnerId = UserInfo.getUserId();
                try {
                    Id clonedQuoteId = cloner.save();
                    System.debug('98 clonedQuoteId :'+clonedQuoteId);
                    createdQuote = [SELECT Id, Name FROM BVCQuote__c WHERE Id = :clonedQuoteId LIMIT 1];
                    StringResultMessage  = 'Success,'+createdQuote.Id;
                } catch (Exception e) {                  
                    System.debug('error'+'103 cloned Quote Error '+e.getMessage());
                    StringResultMessage  = 'Error,'+e.getMessage();
                }
            }
        } 
        System.debug('73 priceSlab:'+priceSlab);
        if ((BusinessType != null && BusinessType == 'ACR' && (priceSlab != null || priceSlab != '' )) || Test.isRunningTest()  ) {
            List<ST_ACR_Standard_Price__c> acrList = [
                SELECT Id, ST_Product__c, ST_Rate_Amount__c, Product__c, Product_Code__c, ST_ACR_Package_Amount__c,
                ST_Minimum_Freight__c, ST_Liability_Coverage__c, ST_Rate_UOM__c, ST_Offline_Charge__c,
                Subrogation_Liability__c, All_Risk_Liability__c, Fidelity_Liability__c,
                Remote_Location__c, ST_ACR_Package_Type__c, Indirect_Location__c, Fuel_Surcharge__c,
                ST_Freight_on_Invoice_Value__c, Universe_Cost_Charge__c
                FROM ST_ACR_Standard_Price__c
                WHERE ST_ACR_Package_Type__c = :priceSlab order by Product__c
            ];
           // System.debug('acrList :'+acrList[0]);
            if (acrList.size() > 0) {
                BVCQuote__c bvcQuote = new BVCQuote__c();
                bvcQuote.Start_Date__c = StartDate;
                bvcQuote.Account__c = acId;
                bvcQuote.RecordTypeId = recordTypeId;
                bvcQuote.Business_Type__c = BusinessType;
                bvcQuote.BVC_Branch__c = BranchId;
                
                if(BVCService=='ExhibiSHIP')
                { bvcQuote.BVC_ExhibiSHIP_Price_Slab__c=priceSlab; }
                else
                { bvcQuote.BVC_Price_Slab__c = priceSlab; }  
               // bvcQuote.BVC_ExhibiSHIP_Price_Slab__c = priceSlab;
                
                bvcQuote.BVC_Service__c = BVCService;
                bvcQuote.Exhibition__c = exbhId;
                bvcQuote.Primary__c = Primary;
                bvcQuote.Status__c = 'Draft';
                bvcQuote.Quote_Type__c = QuoteType;
                bvcQuote.Subrogation_Start_Date__c = SubrogationStartDate;
                bvcQuote.Subrogation_End_Date__c = SubrogationEndDate;
                bvcQuote.Is_the_Payment_Collected__c = IsPaymentCollected;
                bvcQuote.Payment_Id__c = PaymentId;
                bvcQuote.Insurance_By__c= InsuranceBy;   
                bvcQuote.Created_through_Automation__c = True;
                // Set the new fields
                bvcQuote.Decision_Maker__c = DecisionMaker;
                bvcQuote.Customer_Authorized_Signatory__c = AuthorizedSignatory;
                bvcQuote.Evaluator__c = Evaluator;
                bvcQuote.Tariff_Plan__c=TariffPlan;
                bvcQuote.Package_Amount__c=PackageAmount;  
                try {
                    insert bvcQuote;
                    createdQuote = [SELECT Id, Name FROM BVCQuote__c WHERE Id = :bvcQuote.Id LIMIT 1];
                    if (BVCService != null && (BVCService == 'SilverSHIP' || BVCService == 'ValSHIP' || BVCService =='eSHIP' || BVCService =='ExhibiSHIP')) {
                        List<BVCQuoteLineItem__c> qlList = new List<BVCQuoteLineItem__c>();
                        for (ST_ACR_Standard_Price__c sp : acrList) {
                            BVCQuoteLineItem__c qlItem = new BVCQuoteLineItem__c();
                            qlItem.BVCQuote__c = bvcQuote.Id;
                            qlItem.Product__c = sp.ST_Product__c;
                            qlItem.Quantity__c = 1;
                            qlItem.Rate_Amount__c = sp.ST_Rate_Amount__c;
                            qlItem.Minimum_Freight__c = sp.ST_Minimum_Freight__c;
                            qlItem.Product_Code__c = sp.Product_Code__c;
                            qlItem.Subrogation_Liability__c = sp.Subrogation_Liability__c;
                            qlItem.All_Risk_Liability__c = sp.All_Risk_Liability__c;
                            qlItem.Fidelity_Liability__c = sp.Fidelity_Liability__c;
                            qlItem.Offline_Charge__c = sp.ST_Offline_Charge__c;
                            qlItem.Remote_Location__c = sp.Remote_Location__c;
                            qlItem.Indirect_Location__c = sp.Indirect_Location__c;
                            qlItem.Fuel_Surcharge__c = sp.Fuel_Surcharge__c;
                            qlItem.Freight_on_Invoice_Value__c = sp.ST_Freight_on_Invoice_Value__c;
                            qlItem.Universe_Cost_Charge__c = sp.Universe_Cost_Charge__c;
                            qlItem.Product_Name__c = sp.Product__c;
                            qlItem.ACR_Standard_Price__c = sp.Id;
                            qlItem.Rate_UOM__c = sp.ST_Rate_UOM__c;
                            
                            if(BVCService=='ExhibiSHIP')
                            {
                               qlItem.BVC_ExhibiSHIP_Price_Slab__c = sp.ST_ACR_Package_Type__c; 
                            }
                            else
                            {
                               qlItem.Package_Type__c = sp.ST_ACR_Package_Type__c; 
                            }
                            
                            if(manualPriceSlab>=2000000)
                            {
                                qlItem.Net_Unit_Price__c = manualPriceSlab;
                            }
                            else 
                            {
                                qlItem.Net_Unit_Price__c = sp.ST_ACR_Package_Amount__c;
                            }                            
                            qlItem.Liability_Coverage__c = sp.ST_Liability_Coverage__c;
                            qlList.add(qlItem);
                        }
                        if (qlList.size() > 0) {
                            try {
                                // insert qlList;
                                System.debug('134 qlList'+qlList);
                                Database.SaveResult[] saveResultList  = Database.insert(qlList, false);
                                for (Database.SaveResult sr : saveResultList) {
                                    for(Database.Error err : sr.getErrors()) {                                        
                                        System.debug('The following error has occurred.');                                                            
                                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    }
                                }
                                
								StringResultMessage = 'Success,'+createdQuote.Id;
                            } catch (Exception e) {
								StringResultMessage = 'Error,'+e.getMessage();
                            }
                        }
                    }
                } catch (Exception e) {
                    StringResultMessage = 'Error,'+e.getMessage();
                }
            } else {
                System.debug('No Slabs found with ' + priceSlab);
                StringResultMessage = 'Error,'+'No Slabs found with ' + priceSlab;
            }
        }
       System.debug('234 Returning StringResultMessage: ' + StringResultMessage);                                          
   return StringResultMessage;     
 }
}