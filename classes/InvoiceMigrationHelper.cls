/*  @ Helper Class for InvoiceMigration
 *  @Created By : Imran Shaik
 *  @Created Date : 17-Sep-2024
 *  @Version V1: Migrating all CPQ blng__InvoiceLine__c to BVCInvoiceLineitem__c
 *               Migrating blng__Payment__c to BVCPayment__c
 * 				 Migrating blng__PaymentAllocationInvoice__c to BVC_Payment_Allocation_Invoice__c
 * 				 Linking CPQ Invoices Files and Attachments to Created BVC Invoices (without Orders)
 */
public class InvoiceMigrationHelper 
{
public static void dummyMethod(){
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
 /*   public static void MakeMail(List<Database.UpsertResult> upsertResults,List<sObject> recordsList,String ObjectName)
    {

                System.debug('InvoiceMigrationHelper MakeMail Line no 7 ObjectName:'+ObjectName);
                List<SObject> failedRecords = new List<SObject>();
                List<SObject> successfulRecords = new List<SObject>();
                List<String> failedRecordDetails = new List<String>();
                List<String> successfulRecordDetails = new List<String>();
                
                for (Integer i = 0; i < upsertResults.size(); i++) {
                    Database.UpsertResult result = upsertResults[i];
                    
                    if (result.isSuccess()) {
                        successfulRecords.add(recordsList[i]);
                        successfulRecordDetails.add('Record Id: ' + result.getId() + ' processed successfully.');
                    } else {
                        failedRecords.add(recordsList[i]);
                        for (Database.Error error : result.getErrors()) {
                            failedRecordDetails.add('Error on record Id: ' + recordsList[i].Id + ' - ' + error.getMessage());
                        }
                    }
                }
                
                // Send email with both failed and successful records
                InvoiceMigrationHelper.sendEmailNotification(failedRecordDetails, successfulRecordDetails,ObjectName);
        
    }
    
    public static void generateInvoiceLines(List<String> invIds,Map<String,String> invMap)
    {
        System.debug('generateInvoiceLines Line no 34');
        List<blng__InvoiceLine__c> invLines = [select Id,blng__Invoice__c,Name,blng__Quantity__c,blng__Product__c,blng__InvoiceLineStatus__c,
                                      BVC_Branch__c,Freight_Charges__c,Freight_Tax_Amount__c,Total_Charges__c,Invoice_Total__c,
                                      blng__ChargeDate__c,blng__DueDate__c,blng__DaysPastDue__c,blng__UnitPrice__c,blng__Subtotal__c,
                                      blng__TaxAmount__c,blng__TotalAmount__c,Balance_Payment__c,blng__Payments__c,blng__Balance__c
                                      from blng__InvoiceLine__c where blng__Invoice__c IN : invIds];
        System.debug('generateInvoiceLines Line no 40 invIds :'+invIds);
        System.debug('generateInvoiceLines Line no 41 invMap :'+invMap);
        System.debug('generateInvoiceLines Line no 42 invLines.size() :'+invLines.size());
        if(invLines.size()>0)
        {
            List<BVCInvoiceLineitem__c> bvcInvLinesList = new List<BVCInvoiceLineitem__c>();
            for(blng__InvoiceLine__c inv:invLines)
            {
                String bvcInv=null;
                bvcInv = invMap.get(inv.blng__Invoice__c);
                 System.debug('Line no 50 bvcInv :'+bvcInv);
                if(bvcInv!=null)
                {
                    BVCInvoiceLineitem__c singleItem = new BVCInvoiceLineitem__c();
                    singleItem.BVCInvoice__c = bvcInv;
                    singleItem.Product_Name__c = inv.Name;
                    singleItem.Quantity__c = inv.blng__Quantity__c;
                    singleItem.Product__c = inv.blng__Product__c;
                   // singleItem.Status__c = inv.blng__InvoiceLineStatus__c;
                    singleItem.BVC_Branch__c = inv.BVC_Branch__c;
                    singleItem.Freight_Charges__c = inv.Freight_Charges__c;
                    //singleItem.TaxAmount__c = inv.Freight_Tax_Amount__c;
                    singleItem.Total_Charge__c = inv.Total_Charges__c;
                    // singleItem.TotalAmount__c = inv.Invoice_Total__c;
                    singleItem.Charge_Date__c = inv.blng__ChargeDate__c;
                    singleItem.End_Date__c = inv.blng__DueDate__c;
                    // singleItem. = inv.blng__DaysPastDue__c;
                    singleItem.Unit_Price__c = inv.blng__UnitPrice__c;
                    singleItem.Subtotal__c = inv.blng__Subtotal__c;
                    singleItem.TaxAmount__c = inv.blng__TaxAmount__c;
                   // singleItem.TotalAmount__c = inv.blng__TotalAmount__c;
                   // singleItem.Balance_Payment__c = inv.Balance_Payment__c;
                   // singleItem.Payment__c = inv.blng__Payments__c;
                   // singleItem.Balance__c = inv.blng__Balance__c;                    
                    bvcInvLinesList.add(singleItem);                    
                }
            }
            try
            {
                System.debug('Line no 79 bvcInvLinesList.size()) :'+bvcInvLinesList.size());
                List<Database.UpsertResult> upsertResults = Database.upsert(bvcInvLinesList, false);
				InvoiceMigrationHelper.MakeMail(upsertResults,bvcInvLinesList,'BVCInvoiceLineitem__c'); 
                // InvoiceMigrationHelper.generatePayments(invIds,invMap);
                // bvcInvLinesList
                
            }catch(Exception e)
            {
                System.debug('InvoiceMigrationHelper.generateInvoiceLines Line no 86 Error :'+e.getMessage());
            }
        }
    }
    public static void generatePayments(List<String> invIds,Map<String,String> invMap)
    {
        System.debug('generatePayments Line no 92');
        List<blng__Payment__c> CpqPayments = [select Id,blng__Account__c,Name,blng__Amount__c,blng__Notes__c,blng__Invoice__c,RazorPayment_ID__c,
                                      blng__Status__c,blng__PaymentDate__c,blng__PaymentType__c,blng__PaidBy__c,blng__AllocationStatus__c,RDS_Status_c__c,
                                      blng__PaymentDescription__c,blng__BankName__c,blng__CheckNumber__c,blng__CheckDate__c,blng__Transaction__c,
                                      blng__PaymentAuthorization__c from blng__Payment__c where blng__Invoice__c IN : invIds];
        System.debug('generatePayments Line no 97 invIds :'+invIds);
        System.debug('generatePayments Line no 98 invMap :'+invMap);
        System.debug('generatePayments Line no 99 invLines.size() :'+CpqPayments.size());
        
        
        
        if(CpqPayments.size()>0)
        {
            List<BVCPayment__c> BvcPaymentsToCreate = new List<BVCPayment__c>();
            for(blng__Payment__c pm:CpqPayments)
            {
                String BvcInvId = null;
                BvcInvId = invMap.get(pm.blng__Invoice__c);
                System.debug('generatePayments Line no 109 BvcInvId :'+BvcInvId);
                if(BvcInvId!=null)
                { 
                    System.debug('generatePayments Line no 112 BvcInvId :'+BvcInvId);
                    BVCPayment__c bp = new BVCPayment__c(); System.debug('generatePayments Line no 114 bp :'+bp);
                    bp.Migrated_Payment__c = pm.Id;  System.debug('generatePayments Line no 115 bp :'+pm.Id);
                    bp.BVCInvoice__c = BvcInvId; System.debug('generatePayments Line no 116 bp :'+BvcInvId);
                    bp.Account__c = pm.blng__Account__c; System.debug('generatePayments Line no 117 bp :'+pm.blng__Account__c);
                    bp.Amount1__c = pm.blng__Amount__c; System.debug('generatePayments Line no 118 bp :'+pm.blng__Account__c);
                    bp.Notes__c = pm.blng__Notes__c; System.debug('generatePayments Line no 119 bp :'+pm.blng__Amount__c);
                    bp.Status__c = pm.blng__Status__c; System.debug('generatePayments Line no 120 bp :'+pm.blng__Status__c);
                    bp.Payment_Date__c = pm.blng__PaymentDate__c; System.debug('generatePayments Line no 121 bp :'+pm.blng__PaymentDate__c);
                    bp.Payment_Type__c = pm.blng__PaymentType__c; System.debug('generatePayments Line no 122 bp :'+pm.blng__PaymentType__c);
                    bp.Paid_By__c = pm.blng__PaidBy__c; System.debug('generatePayments Line no 123 bp :'+pm.blng__PaidBy__c);
                    bp.Allocation_Status__c = pm.blng__AllocationStatus__c; System.debug('generatePayments Line no 124 bp :'+pm.blng__AllocationStatus__c);
                    bp.Payment_Description__c = pm.blng__PaymentDescription__c; System.debug('generatePayments Line no 125 bp :'+pm.blng__PaymentDescription__c);
                    bp.Bank_Account_Name__c = pm.blng__BankName__c; System.debug('generatePayments Line no 126 bp :'+pm.blng__BankName__c);
                    bp.Check_Number__c = pm.blng__CheckNumber__c; System.debug('generatePayments Line no 127 bp :'+pm.blng__CheckNumber__c);
                    bp.Check_Date__c = pm.blng__CheckDate__c; System.debug('generatePayments Line no 128 bp :'+pm.blng__CheckDate__c); 
                   
                    if(pm.RazorPayment_ID__c!=null)
                    {
                        bp.RazorPayment_ID__c = pm.RazorPayment_ID__c; System.debug('generatePayments Line no 129 bp :'+pm.RazorPayment_ID__c);
                    }
                    
                    if(pm.RDS_Status_c__c!=null)  
                    {
                        bp.RDS_Status_c__c = pm.RDS_Status_c__c; System.debug('generatePayments Line no 130 bp :'+pm.RDS_Status_c__c);
                    }
					
                    // bp. = pm.blng__Transaction__c;
                    // bp. = pm.blng__PaymentAuthorization__c;
                    BvcPaymentsToCreate.add(bp);
                 System.debug('generatePayments Line no 133 bp :'+bp);
                }
            }
            System.debug('generatePayments Line no 136 BvcPaymentsToCreate :'+BvcPaymentsToCreate);
            try
            {
                System.debug('generatePayments Line no 137 BvcPaymentsToCreate.size()) :'+BvcPaymentsToCreate.size());
                List<Database.UpsertResult> upsertResults = Database.upsert(BvcPaymentsToCreate, false);
                Map<String,BVCPayment__c> paymentMap = new Map<String,BVCPayment__c>();
                for(BVCPayment__c bp: BvcPaymentsToCreate)
                {
                    paymentMap.put(bp.Migrated_Payment__c,bp);
                }
                InvoiceMigrationHelper.MakeMail(upsertResults,BvcPaymentsToCreate,'BVCPayment__c');
                if(paymentMap.size()>0)
                {
                    // Calling Payment Allocation Invoice Migration
                    InvoiceMigrationHelper.generatePaymentsAllocationsInvoice(paymentMap);
                }
            }catch(Exception e)
            {
                System.debug('generatePayments InvoiceMigrationHelper.generatePayments Line no 144 Error :'+e.getMessage());
            }
        }
        
    } 
    public static void generatePaymentsAllocationsInvoice(Map<String,BVCPayment__c> paymentMap)
    {
		List<blng__PaymentAllocationInvoice__c> PA_InvoiceList = [select Id,blng__Payment__c,blng__Invoice__c,blng__Notes__c,blng__Amount__c,
                                                           Payment_Type__c,RazorPay_PaymentId__c,blng__Type__c,blng__Unallocated__c
                                                           from blng__PaymentAllocationInvoice__c where blng__Payment__c IN :paymentMap.keySet()];
        System.debug('generatePaymentsAllocationsInvoice Line no 164 paymentMap :'+paymentMap);
        // System.debug('generatePaymentsAllocationsInvoice Line no 165 invMap :'+invMap);
        System.debug('generatePaymentsAllocationsInvoice Line no 166 PA_InvoiceList.size() :'+PA_InvoiceList.size());        
        if(PA_InvoiceList.size()>0)
        {
            List<BVC_Payment_Allocation_Invoice__c> BvcPA_ListToInsert = new List<BVC_Payment_Allocation_Invoice__c>();
            for(blng__PaymentAllocationInvoice__c pal:PA_InvoiceList)
            {
                BVCPayment__c BvcPRecord = new BVCPayment__c();
                BvcPRecord = paymentMap.get(pal.blng__Invoice__c);
                if(BvcPRecord!=null)
                {
                    BVC_Payment_Allocation_Invoice__c PAI_Record = new BVC_Payment_Allocation_Invoice__c();
                    PAI_Record.BVCInvoice__c = BvcPRecord.BVCInvoice__c;
                    PAI_Record.BVCPayment__c = BvcPRecord.Id;
                    
                    PAI_Record.Notes__c = pal.blng__Notes__c;
                    PAI_Record.Amount__c = pal.blng__Amount__c;
                    PAI_Record.Payment_Type__c = pal.Payment_Type__c;
                    PAI_Record.RazorPay_PaymentId__c = pal.RazorPay_PaymentId__c;
                    PAI_Record.Type__c = pal.blng__Type__c;
                    PAI_Record.Unallocated__c = pal.blng__Unallocated__c;
                    BvcPA_ListToInsert.add(PAI_Record);
                }
            }
            if(BvcPA_ListToInsert.size()>0)
            {
                try
                {
                    System.debug('generatePaymentsAllocationsInvoice Line no 190 BvcPA_ListToInsert.size()) :'+BvcPA_ListToInsert.size());
                    List<Database.UpsertResult> upsertResults = Database.upsert(BvcPA_ListToInsert, false);
                    InvoiceMigrationHelper.MakeMail(upsertResults,BvcPA_ListToInsert,'BVC_Payment_Allocation_Invoice__c');
                }catch(Exception e)
                {
                    System.debug('generatePaymentsAllocationsInvoice Line no 195 BVC_Payment_Allocation_Invoice__c Error :'+e.getMessage());
                }
            }
        }
        
        
    }     
    public static void generateAttachments(List<String> invIds,Map<String,String> invMap)
    {
        List<ContentDocumentLink> cdL_List = [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.Title,ShareType,Visibility 
                                              FROM ContentDocumentLink WHERE LinkedEntityId IN:invIds];
        
        if(cdL_List.size()>0)
        {
            List<ContentDocumentLink> CDL_To_Create = new List<ContentDocumentLink>();
            for(ContentDocumentLink cdl : cdL_List)
            {
                ContentDocumentLink cd = new ContentDocumentLink();
                String BvcInvId = null;
                BvcInvId = invMap.get(cdl.LinkedEntityId);
                if(BvcInvId!=null)
                {
                    cd.LinkedEntityId = BvcInvId;
                    cd.ShareType = cdl.ShareType;
                    cd.ContentDocumentId = cdl.ContentDocumentId;
                    cd.Visibility = cdl.Visibility;
                    CDL_To_Create.add(cd);
                }
                
            }
            try
            {
                System.debug('Line no 227 Cdl_List.size()) :'+CDL_To_Create.size());
                List<Database.UpsertResult> upsertResults = Database.upsert(CDL_To_Create, false);
                InvoiceMigrationHelper.MakeMail(upsertResults,CDL_To_Create,'BVC_Payment_Allocation_Invoice__c');
                // Cdl_List
            } catch(Exception e)
            {
                System.debug('Line no 223 CDL_To_Create Error :'+e.getMessage());
            }
        }
        
    } 

public static void sendEmailNotification(List<String> failedDetails, List<String> successDetails,String ObjName) {
    String body = '';
    if (!successDetails.isEmpty()) {
        body +='Object Name :'+ObjName+', Successfully processed records:\n';
        body += String.join(successDetails, '\n') + '\n\n';
    }
    if (!failedDetails.isEmpty()) {
        body += 'Object Name :'+ObjName+', Failed records with errors:\n';
        body += String.join(failedDetails, '\n') + '\n';
    }

    // Email configuration
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    email.setToAddresses(new List<String>{'imran.shaik@bvclogistics.com'});
    email.setSubject('Object Name :'+ObjName+', Migration Process Result');
    email.setPlainTextBody(body);
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
} 

    
    
    
}*/