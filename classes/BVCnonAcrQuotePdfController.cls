public class BVCnonAcrQuotePdfController {
    
    public Id quoteId { get; set; }
    public static List<BVCQuote__c> BVCQuoteList {get;set;}
   
      
    public static List<BVCQuoteLineItem__c> VaLBVCQuoteLineItemList1 {get;set;}
    public static List<BVCQuoteLineItem__c> ValBVCQuoteLineItemList2 {get;set;}
    public static List<BVCQuoteLineItem__c> ValBVCQuoteLineItemList3 {get;set;}
    public static List<BVCQuoteLineItem__c> ValBVCQuoteLineItemList4 {get;set;}
    
    public static List<BVCQuoteLineItem__c> SilLBVCQuoteLineItemList1 {get;set;}
    public static List<BVCQuoteLineItem__c> SilBVCQuoteLineItemList2 {get;set;}
    public static List<BVCQuoteLineItem__c> SilBVCQuoteLineItemList3 {get;set;}
    public static List<BVCQuoteLineItem__c> SilBVCQuoteLineItemList4 {get;set;}
    
    public static List<BVCQuoteLineItem__c> VaLBVCQuoteLineItemList5 {get;set;}
    public static List<BVCQuoteLineItem__c> ValBVCQuoteLineItemList6 {get;set;}
    public static List<BVCQuoteLineItem__c> ValBVCQuoteLineItemList7 {get;set;}
    public static List<BVCQuoteLineItem__c> ValBVCQuoteLineItemList8 {get;set;}
    
    public static List<BVCQuoteLineItem__c> SilLBVCQuoteLineItemList5 {get;set;}
    public static List<BVCQuoteLineItem__c> SilBVCQuoteLineItemList6 {get;set;}
    public static List<BVCQuoteLineItem__c> SilBVCQuoteLineItemList7 {get;set;}
    public static List<BVCQuoteLineItem__c> SilBVCQuoteLineItemList8 {get;set;}
    
    public static List<BVCQuoteLineItem__c> VaLBVCQuoteLineItemList9 {get;set;}
    public static List<BVCQuoteLineItem__c> ValBVCQuoteLineItemList10 {get;set;}
    public static List<BVCQuoteLineItem__c> ValBVCQuoteLineItemList11 {get;set;}
    public static List<BVCQuoteLineItem__c> ValBVCQuoteLineItemList12 {get;set;}
    
    public static List<BVCQuoteLineItem__c> SilLBVCQuoteLineItemList9 {get;set;}
    public static List<BVCQuoteLineItem__c> SilBVCQuoteLineItemList10 {get;set;}
    public static List<BVCQuoteLineItem__c> SilBVCQuoteLineItemList11 {get;set;}
    public static List<BVCQuoteLineItem__c> SilBVCQuoteLineItemList12 {get;set;}
    
 
    Public BVCnonAcrQuotePdfController(){
        
        String quoteID = ApexPages.currentPage().getParameters().get('id');
        
        String currentDate = String.valueOf(Date.today()).removeEnd(' 00:00:00');
        String fileName = 'NON ACR ORDER FORM ' + currentDate + '.pdf';
        fileName = fileName.replace('_', ''); 
        
        ApexPages.currentPage().getHeaders().put('content-disposition', 'inline; filename="' + fileName + '"');
        
         system.debug('@@@@@@@ ::'+quoteID);
        BVCQuoteList = new List<BVCQuote__c>();
        if(string.isNotBlank(quoteID)){
             BVCQuote__c bvcquote = new BVCQuote__c();
            
            bvcquote =[SELECT Id, Name, Account_Email_ID__c, Owner.name,owner.email,owner.phone,Quote_sent_date_add_30__c,BVC_Entity__r.id,BVC_Entity__r.name,
                       BVC_Authorized_Signatory__r.name,BVC_Billing_Entity_Address_Line_1__c,BVC_Billing_Entity_Address_Line_2__c,                     
                       BVC_Billing_Entity_City__c,BVC_Billing_Entity_Pincode__c,BVC_Billing_Entity_State__c,BVC_Billing_Entity_Country__c,KYC_Indicator_for_Domestic_Flag__c, 
                       Customer_Authorized_Signatory__r.name,Business_Type__c, Base_Quote__c, Sales_Rep__c, Exhibition__c, Status__c,
                       Create_Order__c, Account__c, Decision_Maker_Email_Id__c, BVC_Service__c, Ordered__c, 
                       Primary__c, eSHIP_legacy__c, Primary_Contact__c, Type__c, Shipment__c, Quick_Calculate_BVC__c, Personal_Contract_Status__c,
                       Contract_Signed__c, Customer_PAN__c, Customer_Name_As_Per_Pan__c, Evaluator__c, Bill_To_GSTIN__c, Decision_Maker__c, 
                       Customer_Authorized_Signatory_Full_Name__c, Customer_Authorized_Signatory__c, Customer_Billing_Frequency__c, 
                       Customer_Authorized_Signatory_Designatio__c, Billing_Address__c,Billing_Address__r.name, Bill_To_Trade_Name__c, Bill_To_Street__c, Bill_To_Postal_Code__c,
                       Bill_To_City__c, Bill_To_State__c, Bill_To_Country__c, BVC_Branch__c, BVC_LegalEntity__c, BVC_Entity__c, 
                       BVC_Billing_Entity_GSTIN__c, BVC_Billing_Entity_PAN__c, BVC_Authorized_Signatory__c, BVC_Authorized_Signatory_Designation__c, 
                       BVC_Care_Email__c, BVC_Care_Phone_Number__c, Start_Date__c, End_Date__c, Quote_Sent_Date__c, Contract_Signed_Date__c,
                       Subscription_Term__c, Credit_Limit__c, Payment_Terms__c, Notes__c, Net_Amount__c, Subrogation_End_Date__c,
                       Subrogation_Start_Date__c, No_Of_Attempts__c, Max_Discount_on_QuoteLine__c, BVC_Price_Slab__c, Tariff_Plan__c, Customized__c, 
                       Is_Shipment__c, Approval_Stage__c, Approval_Flag__c,Document_Date__c, Account_Name__c FROM BVCQuote__c where ID =:quoteID LIMIT 1];
            
               BVCQuoteList.add(bvcquote);
            system.debug('BVCQuoteList@@@'+ BVCQuoteList);
            
              
          
            
            // 0-1 kg
            VaLBVCQuoteLineItemList1 = new List<BVCQuoteLineItem__c>();
            ValBVCQuoteLineItemList2 = new List<BVCQuoteLineItem__c>();
            ValBVCQuoteLineItemList3 = new List<BVCQuoteLineItem__c>();
            ValBVCQuoteLineItemList4 = new List<BVCQuoteLineItem__c>();
            
            SilLBVCQuoteLineItemList1 = new List<BVCQuoteLineItem__c>();
            SilBVCQuoteLineItemList2 = new List<BVCQuoteLineItem__c>();
            SilBVCQuoteLineItemList3 = new List<BVCQuoteLineItem__c>();  
            SilBVCQuoteLineItemList4 = new List<BVCQuoteLineItem__c>(); 
            
            //1.01-20 Kg
            VaLBVCQuoteLineItemList5 = new List<BVCQuoteLineItem__c>();
            ValBVCQuoteLineItemList6= new List<BVCQuoteLineItem__c>();
            ValBVCQuoteLineItemList7 = new List<BVCQuoteLineItem__c>();
            ValBVCQuoteLineItemList8 = new List<BVCQuoteLineItem__c>();
            
            SilLBVCQuoteLineItemList5 = new List<BVCQuoteLineItem__c>();
            SilBVCQuoteLineItemList6 = new List<BVCQuoteLineItem__c>();
            SilBVCQuoteLineItemList7 = new List<BVCQuoteLineItem__c>();  
            SilBVCQuoteLineItemList8 = new List<BVCQuoteLineItem__c>(); 
            
            //20.01+
            VaLBVCQuoteLineItemList9 = new List<BVCQuoteLineItem__c>();
            ValBVCQuoteLineItemList10 = new List<BVCQuoteLineItem__c>();
            ValBVCQuoteLineItemList11 = new List<BVCQuoteLineItem__c>();
            ValBVCQuoteLineItemList12 = new List<BVCQuoteLineItem__c>();
            
            SilLBVCQuoteLineItemList9 = new List<BVCQuoteLineItem__c>();
            SilBVCQuoteLineItemList10 = new List<BVCQuoteLineItem__c>();
            SilBVCQuoteLineItemList11 = new List<BVCQuoteLineItem__c>();  
            SilBVCQuoteLineItemList12 = new List<BVCQuoteLineItem__c>(); 
            
           
            
            List<BVCQuoteLineItem__c> bvcQuoyeLine = [SELECT Id, Name, BVCQuote__c,BVCQuote__r.id, Gross_Weight_Slabs__c, Package_Type__c, Rate_Amount__c,
                                                      Minimum_Freight__c, Liability_Coverage__c, Fuel_Surcharge__c, Fidelity_Liability__c,
                                                      Subrogation_Liability__c, UOM_Percentage__c, Rate_UOM__c, Customer_Product_Category__c,
                                                      Universe_Cost_Charge__c, Product_Name__c, Product_Code__c, Max_Slab_Rate__c,
                                                      Slab_3_Rate__c, Slab_4_Rate__c, Slab_5_Rate__c,Offline_Charge__c,Indirect_Location__c,Remote_Location__c,
                                                      All_Risk_Liability__c
                                                      FROM BVCQuoteLineItem__c where BVCQuote__r.id =:quoteID ];
            
            for(BVCQuoteLineItem__c bvcLn : bvcQuoyeLine){
                
                //0-1 kg
                if(bvcLn.Product_Name__c =='ValSHIP Within City(0-1)'){
                    VaLBVCQuoteLineItemList1.add(bvcLn);
                    system.debug('VaLBVCQuoteLineItemList1'+ VaLBVCQuoteLineItemList1);
                    
                }
                if(bvcLn.Product_Name__c =='ValSHIP Within Region (0-1)'){
                    ValBVCQuoteLineItemList2.add(bvcLn); 
                    system.debug('ValBVCQuoteLineItemList2'+ValBVCQuoteLineItemList2);
                      
                }
                 if(bvcLn.Product_Name__c =='Valship Metro To Metro (0-1)'){
                    ValBVCQuoteLineItemList3.add(bvcLn); 
                      system.debug('ValBVCQuoteLineItemList3'+ValBVCQuoteLineItemList3);
                     
                }
                  if(bvcLn.Product_Name__c =='Valship Rest of India(0-1)'){
                    ValBVCQuoteLineItemList4.add(bvcLn);  
                      system.debug('ValBVCQuoteLineItemList4'+ValBVCQuoteLineItemList4);
                    
                }
                
                if(bvcLn.Product_Name__c =='SilverSHIP Within City (0-1)'){
                    SilLBVCQuoteLineItemList1.add(bvcLn); 
                    system.debug('SilLBVCQuoteLineItemList1'+SilLBVCQuoteLineItemList1);
                     
                }
                 if(bvcLn.Product_Name__c =='SilverSHIP Within Region (0-1)'){
                    SilBVCQuoteLineItemList2.add(bvcLn); 
                     system.debug('SilBVCQuoteLineItemList2'+SilBVCQuoteLineItemList2);
                      
                }
                 if(bvcLn.Product_Name__c =='SilverSHIP Metro To Metro (0-1)'){
                    SilBVCQuoteLineItemList3.add(bvcLn);  
                      system.debug('SilBVCQuoteLineItemList3'+SilBVCQuoteLineItemList3);
                     
                }
                 if(bvcLn.Product_Name__c =='SilverSHIP Rest of India(0-1)'){
                    SilBVCQuoteLineItemList4.add(bvcLn);  
                      system.debug('SilBVCQuoteLineItemList4'+SilBVCQuoteLineItemList4);
                     
                }
                
                //1.01-20 Kg
                
                 if( bvcLn.Product_Name__c =='ValSHIP Within City(1-20)'){
                    VaLBVCQuoteLineItemList5.add(bvcLn);
                   system.debug('VaLBVCQuoteLineItemList5'+VaLBVCQuoteLineItemList5);
                    
                }
                if( bvcLn.Product_Name__c =='ValSHIP Within Region-(1-20)'){
                    ValBVCQuoteLineItemList6.add(bvcLn); 
                     system.debug('ValBVCQuoteLineItemList6'+ValBVCQuoteLineItemList6);
                      
                }
                 if( bvcLn.Product_Name__c =='Valship Metro To Metro (1-20)'){
                    ValBVCQuoteLineItemList7.add(bvcLn); 
                      system.debug('ValBVCQuoteLineItemList7'+ValBVCQuoteLineItemList7);
                     
                }
                  if( bvcLn.Product_Name__c =='Valship Rest of India(1-20)'){
                    ValBVCQuoteLineItemList8.add(bvcLn); 
                       system.debug('ValBVCQuoteLineItemList8'+ValBVCQuoteLineItemList8);
                    
                }
                
                   if( bvcLn.Product_Name__c =='SilverSHIP Within City (1-20)'){
                    SilLBVCQuoteLineItemList5.add(bvcLn);  
                       system.debug('SilLBVCQuoteLineItemList5'+SilLBVCQuoteLineItemList5);
                     
                }
                 if( bvcLn.Product_Name__c =='SilverSHIP Within Region (1-20)'){
                    SilBVCQuoteLineItemList6.add(bvcLn);  
                     system.debug('SilBVCQuoteLineItemList6'+SilBVCQuoteLineItemList6);
                      
                }
                 if( bvcLn.Product_Name__c =='SilverSHIP Metro To Metro (1-20)'){
                    SilBVCQuoteLineItemList7.add(bvcLn);  
                      system.debug('SilBVCQuoteLineItemList7'+SilBVCQuoteLineItemList7);
                     
                }
                 if( bvcLn.Product_Name__c =='SilverSHIP Rest of India (1-20)'){
                    SilBVCQuoteLineItemList8.add(bvcLn); 
                      system.debug('SilBVCQuoteLineItemList8'+SilBVCQuoteLineItemList8);
                     
                }
                
                 //20.01+ kg
                
                 if( bvcLn.Product_Name__c =='ValSHIP Within City(20-25)'){
                    VaLBVCQuoteLineItemList9.add(bvcLn);
                      system.debug('VaLBVCQuoteLineItemList9'+VaLBVCQuoteLineItemList9);
                    
                }
                if( bvcLn.Product_Name__c =='ValSHIP Within Region (20-25)'){
                    ValBVCQuoteLineItemList10.add(bvcLn); 
                     system.debug('ValBVCQuoteLineItemList10'+ValBVCQuoteLineItemList10);
                      
                }
                 if( bvcLn.Product_Name__c =='Valship Metro To Metro (20-25)'){
                    ValBVCQuoteLineItemList11.add(bvcLn); 
                      system.debug('ValBVCQuoteLineItemList11'+ValBVCQuoteLineItemList11);
                     
                }
                  if( bvcLn.Product_Name__c =='Valship Rest of India(20-25)'){
                    ValBVCQuoteLineItemList12.add(bvcLn);  
                        system.debug('ValBVCQuoteLineItemList12'+ValBVCQuoteLineItemList12);
                    
                }
                
                   if( bvcLn.Product_Name__c =='SilverSHIP Within City (20-25)'){
                    SilLBVCQuoteLineItemList9.add(bvcLn); 
                       system.debug('SilLBVCQuoteLineItemList9'+SilLBVCQuoteLineItemList9);
                     
                }
                 if( bvcLn.Product_Name__c =='SilverSHIP Within Region (20-25)'){
                    SilBVCQuoteLineItemList10.add(bvcLn);  
                      system.debug('SilBVCQuoteLineItemList10'+SilBVCQuoteLineItemList10);
                }
                 if( bvcLn.Product_Name__c =='SilverSHIP Metro To Metro (20-25)'){
                    SilBVCQuoteLineItemList11.add(bvcLn); 
                      system.debug('SilBVCQuoteLineItemList11'+SilBVCQuoteLineItemList11);
                     
                }
                 if( bvcLn.Product_Name__c =='SilverSHIP Rest of India (20-25)'){
                    SilBVCQuoteLineItemList12.add(bvcLn);  
                     system.debug('SilBVCQuoteLineItemList12'+SilBVCQuoteLineItemList12);
                     
                }
                
                
            }   
        }
    }
    
      
    
   
}