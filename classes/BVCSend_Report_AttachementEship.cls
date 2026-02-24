public class BVCSend_Report_AttachementEship {


    @InvocableMethod
    public static void createAnnexureAccount(list < id > Accid) {
        list < Account > acclst = [Select id from account where Id IN: Accid];
        boolean userInvokedMethod = True ;
        getShipmentDataOfAccount(acclst[0].id,userInvokedMethod);
    }
    public static void scheuler() {
        System.debug('scheuler Method Entry limit available ' + limits.getLimitHeapSize());
        System.debug('scheuler Method Entry Limit used ' + limits.getHeapSize());
		        boolean userInvokedMethod = false ;
        // The getShipmentDataOfAccount is a future method so limiting record size to 50 
        for (Account acc: [Select id from account where Customer_Category_Static__c =: 'ACR'
                and eSHIP_BVC_Contract__c != Null and eSHIP_BVC_Contract__r.Latest_Contract__c = True and eSHIP_BVC_Contract__r.BVC_Service__c ='eSHIP'
                limit 50
            ]) {
            getShipmentDataOfAccount(acc.Id,userInvokedMethod);
        }
        System.debug('scheuler Method Exit limit available ' + limits.getLimitHeapSize());
        System.debug('scheuler Method Exit Limit used ' + limits.getHeapSize());
    }


    @Future(callout = true)
   public static void getShipmentDataOfAccount(Id recordIds, Boolean userInvokedMethod) {
    System.debug('recordIds========' + recordIds);
    System.debug('userInvokedMethod========' + userInvokedMethod);
    System.debug('Method Entry - Heap Limit Available: ' + Limits.getLimitHeapSize());
    System.debug('Method Entry - Heap Limit Used: ' + Limits.getHeapSize());
    Account inputAcc = [SELECT Id, eSHIP_BVC_Contract__c FROM Account WHERE Id = :recordIds];
    System.debug('InputAcc=====' + inputAcc);
    String header = 'Customer Name, PAN Number,Contract No, Shipment Date,Docket No,Declared value,No Of Attempts,Payment Mode,Gross Weight in Gram,Net Weight in Gram, eSHIP Freight Charges, eSHIP Weight Charges,eSHIP Liability Charges, Total Fuel Surcharge,Additional Charges eSHIP,COD Charges eSHIP,Total Charges, BVC Product Code, Product Category,Shipment Type,Shipper Account: Customer Name,To City,From City,Consignee Name,Consignee Address \n';
    List<String> finalstr = new List<String>();
    Set<Id> shipmentIds = new Set<Id>();
    // Step 1: Query all relevant Shipments
    List<Shipment__c> shipmentList = [
        SELECT Id, Customer__c, Docket_No__c, Declared_Value__c, No_Of_Attempts__c, Payment_Mode__c,
               Total_Charge__c, Holiday_Charges__c, Fuel_Surcharge__c, Universe_Cost_Charge__c,
               Product_Code__c, Product_Description__c, Valuation_Charges__c,
               Shipper_Name_TMS__r.Name, Consignee_Name_TMS__r.Name, Offline_Charges__c,
               Origin_Address_City__c, Freight_Charges__c, Weight_Charges__c, Liability_Charges__c,
               Origin_Type__c, Destination_Address_City__c, Destination_Type__c, Insurance_By__c,
               Customer__r.Name, Customer__r.PAN_Number_of_Entity__c,Customer__r.BVC_Contract__r.Name,Customer__r.eSHIP_BVC_Contract__r.Name,
               Shipping_Note_Number__c, Shipment_Date__c, Shipment_Value__c,To_City__c,From_City__c,Product_Category__c,Shipment_Type__c,
               Gross_weight_in_Gram__c, Net_weight_in_Gram__c, Number_of_Packages__c,Consignee_Address_Eship__c,Consignee_Name_Eship__c	
        FROM Shipment__c
        WHERE Customer__c = :inputAcc.Id AND Id IN (
            SELECT Shipment__c
            FROM BVC_ACR_Consumption__c
             WHERE Consumtion_status_Static__c = 'Activated'
              AND Account__c = :inputAcc.Id
              AND BVC_Contract__c = :inputAcc.eSHIP_BVC_Contract__c
        )
    ];
    // Collect all shipment IDs
    for (Shipment__c ship : shipmentList) {
        shipmentIds.add(ship.Id);
    }
    // Step 2: Query related BVC_ACR_Consumption__c data
    Map<Id, BVC_ACR_Consumption__c> acrMap = new Map<Id, BVC_ACR_Consumption__c>();
    for (BVC_ACR_Consumption__c acr : [
        SELECT Shipment__c, Additional_Charges_eSHIP__c, COD_Charges_eSHIP__c
        FROM BVC_ACR_Consumption__c
        WHERE Shipment__c IN :shipmentIds
    ]) {
        acrMap.put(acr.Shipment__c, acr);
    }
    // Step 3: Construct CSV data
    for (Shipment__c ship : shipmentList) {
        BVC_ACR_Consumption__c acr = acrMap.get(ship.Id);
        String shipmentValues = '"' + String.join(new String[] {
            ship.Customer__r.Name,
            ship.Customer__r.PAN_Number_of_Entity__c,
            ship.Customer__r.eSHIP_BVC_Contract__r.Name,
            
            String.valueOf(ship.Shipment_Date__c),
            String.valueOf(ship.Docket_No__c),
            String.valueOf(ship.Declared_Value__c),
            String.valueOf(ship.No_Of_Attempts__c),
            String.valueOf(ship.Payment_Mode__c),
            
            String.valueOf(ship.Gross_weight_in_Gram__c),
            String.valueOf(ship.Net_weight_in_Gram__c),
            String.valueOf(ship.Freight_Charges__c != null ? ship.Freight_Charges__c : 0),
            String.valueOf(ship.Weight_Charges__c != null ? ship.Weight_Charges__c : 0),
            String.valueOf(ship.Liability_Charges__c != null ? ship.Liability_Charges__c : 0),
            
            String.valueOf(ship.Fuel_Surcharge__c != null ? ship.Fuel_Surcharge__c : 0),
            String.valueOf(acr != null && acr.Additional_Charges_eSHIP__c != null ? acr.Additional_Charges_eSHIP__c : 0),
            String.valueOf(acr != null && acr.COD_Charges_eSHIP__c != null ? acr.COD_Charges_eSHIP__c : 0),
            String.valueOf(ship.Total_Charge__c != null ? ship.Total_Charge__c : 0),
            
            ship.Product_Code__c,
            ship.Product_Category__c,
            ship.Shipment_Type__c,
            ship.Shipper_Name_TMS__r.Name,
           
            ship.To_City__c,
            ship.From_City__c,
            ship.Consignee_Name_Eship__c,
            ship.Consignee_Address_Eship__c
           
           
        }, '","') + '"';
        finalstr.add(shipmentValues);
    }
    System.debug('InputACC=========' + inputAcc);
    System.debug('Final CSV Rows Count: ' + finalstr.size());
    System.debug('Final CSV Content: ' + finalstr);
    System.debug('Method Exit - Heap Limit Available: ' + Limits.getLimitHeapSize());
    System.debug('Method Exit - Heap Limit Used: ' + Limits.getHeapSize());
    // Step 4: Create Attachment
    createAttachment(inputAcc, header + String.join(finalstr, '\n'), userInvokedMethod);
}
    
    
    Public static void createAttachment(Account acc, String csvData,Boolean userInvokedMethod) {
        System.debug('createAttachment Method Entry limit available ' + limits.getLimitHeapSize());
        System.debug('createAttachment Method Entry Limit used ' + limits.getHeapSize());

        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = 'Consumption Details ' + datetime.now().format('yyyy-MM-dd HH mm') + '.csv';
        conVer.FirstPublishLocationId = acc.id;
        conVer.VersionData = Blob.valueOf(csvData);

        If(conVer != Null) {
            try {
                insert conVer;

            } catch (exception ex) {
                system.debug(ex.getMessage());
            }

            System.debug('Line 52 ' + limits.getLimitHeapSize());
            System.debug('Line 53 ' + limits.getHeapSize());

        }
        csvData = null;
        updateAccountValuesAndFileLink(conVer,userInvokedMethod);
        System.debug('createAttachment Method exit limit available ' + limits.getLimitHeapSize());
        System.debug('createAttachment Method exit Limit used ' + limits.getHeapSize());
    }

    public static void updateAccountValuesAndFileLink(ContentVersion checkConverid,Boolean userInvokedMethod) {

        System.debug('updateAccountValuesAndFileLink Method Entry limit available ' + limits.getLimitHeapSize());
        System.debug('updateAccountValuesAndFileLink Method Entry Limit used ' + limits.getHeapSize());
        System.debug('Inside updateAccountValuesAndFileLink=======');
        Map < id, ContentDistribution > AccContentDistribution = new Map < id, ContentDistribution > ();
        List < BVC_ACR_Consumption__c   > filteredACRCon = new List < BVC_ACR_Consumption__c   > ();
        list < id > Getaccountstoupdate = new list < id > ();

        ContentDistribution newContentDistribution = [SELECT Id, ContentVersionId, ContentVersion.FirstPublishLocationId, ContentDownloadUrl FROM ContentDistribution WHERE ContentVersion.FirstPublishLocationId =: checkConverid.FirstPublishLocationId AND ContentVersionId =: checkConverid.id];

        account Accounts = [Select id, name, Owner.name, owner.email, Product_value_shipped_INR__c, Gross_Weight_GMS__c, Net_Weight_GMS__c, Total_Parcels_Shipped_activated__c, Balance_Amount__c, Consumed_Amount__c, Adjustment_Amount__c, Adjusted_Contract_Amount__c, Contract_Amount__c, Contract_Start_Date__c, BVC_Contract__r.name, Contract_End_Date__c, Email__c, PAN_Number_of_Entity__c, of_Contract_Consumption__c, BVC_Contract__c,eSHIP_BVC_Contract__c, Sales_Secondary_Owner__c, Ownerid,Original_Contract_Amount__c from account where eSHIP_BVC_Contract__c!= Null AND id =: checkConverid.FirstPublishLocationId];
		System.debug('Accounts======='+Accounts);
        Decimal Netweight = 0;
        Decimal Grossweight = 0;
        integer totalParcals = 0;
        Decimal totalshipmentvalue = 0;
        For(BVC_ACR_Consumption__c   ACRCON: [Select id, Net_Weight_GMS__c, Gross_Weight_GMS__c, Shipment_Value__c, BVC_Contract__c from BVC_ACR_Consumption__c where Status__c ='Valid'
            AND BVC_Contract__c =: Accounts.eSHIP_BVC_Contract__c]) {
            Netweight += (ACRCON.Net_Weight_GMS__c != Null ? ACRCON.Net_Weight_GMS__c : 0);
            Grossweight += (ACRCON.Gross_Weight_GMS__c != Null ? ACRCON.Gross_Weight_GMS__c : 0);
            totalshipmentvalue += (ACRCON.Shipment_Value__c != Null ? ACRCON.Shipment_Value__c : 0);
            totalParcals += 1;
        }

        Accounts.Net_Weight_GMS__c = (Netweight != null ? Netweight : 0);
        Accounts.Gross_Weight_GMS__c = (Grossweight != null ? Grossweight : 0);
        Accounts.Total_Parcels_Shipped_activated__c = (totalParcals != null ? totalParcals : 0);
        Accounts.Product_value_shipped_INR__c = (totalshipmentvalue != null ? totalshipmentvalue : 0);
        Accounts.Recent_ACR_Report_URL__c = newContentDistribution.ContentDownloadUrl;
        Accounts.Last_ACR_report_generated_date__c = date.today();

        If(Accounts != null) {
            // system.debug('accountstoupdate' + Accounts);
            Update Accounts; // Update the account with Net,GrossWeight , Total shipment,Totalshipmentvalue while sending ACR report to customer   

        }

        If(userInvokedMethod){
            SendEmailToCustomersIndividually(Accounts);
        }
        System.debug('updateAccountValuesAndFileLink Method Exit limit available ' + limits.getLimitHeapSize());
        System.debug('updateAccountValuesAndFileLink Method Exit Limit used ' + limits.getHeapSize());

    }

    // The Email is Sent via SendGrid intigration and being used ApexJobSchedules (Scheduled Manually via flow with help @apexclass : /acrMonthlyReportScheduleHelper/ by User when ever required)
     
    public static void SendEmailToCustomers() {
        System.debug('SendEmailToCustomers Method Entry limit available ' + limits.getLimitHeapSize());
        System.debug('SendEmailToCustomers Method Entry Limit used ' + limits.getHeapSize());

        For(account accountToEmail: [Select id,BVCContractStartDate__c,Contract_Start_Date_eSHIP_BVC__c,Adjustment_Amount_eSHIP__c,Adjusted_Contract_Amount_eSHIP__c,Consumed_Amount_eSHIP__c,Contract_End_Date_eSHIP__c,eSHIP_BVC_Contract__r.BVC_Service__c,BVC_Consumed_Amount__c,eSHIP_BVC_Contract__r.Latest_Contract__c, eSHIP_BVC_Contract__r.name, Owner.name, owner.email, Sales_Secondary_Owner__r.email, Contract_End_Date__c, Contract_Start_Date__c, name, PAN_Number_of_Entity__c, Contract_Amount__c, Adjustment_Amount__c, Adjusted_Contract_Amount__c, of_Contract_Consumption__c, Balance_Amount__c, Total_Parcels_Shipped_activated__c, Net_Weight_GMS__c, Gross_Weight_GMS__c, Product_value_shipped_INR__c, Recent_ACR_Report_URL__c,Original_Contract_Amount__c from account where Last_ACR_report_generated_date__c =: date.today() AND eSHIP_BVC_Contract__c != Null and eSHIP_BVC_Contract__r.Latest_Contract__c = True and eSHIP_BVC_Contract__r.BVC_Service__c ='eSHIP'  limit 1]) {
           system.debug('eship contract name' +accountToEmail.eSHIP_BVC_Contract__r.BVC_Service__c);
            system.debug('eship contract name' +accountToEmail.eSHIP_BVC_Contract__r.name);
            List < string > ToEmails = new List < string > ();
            List < string > ccEmails = new List < string > ();
            ccEmails.add('bvclinvoicesubmission@bvclogistics.com');

            For(Contact Cont: [SELECT Id, Email FROM Contact WHERE AccountId =: accountToEmail.id AND Email != null]) {
                ToEmails.add(cont.Email);
            }
            IF(accountToEmail.OwnerId != Null) {
                ccEmails.add(accountToEmail.owner.email);
            }
            If(accountToEmail.Sales_Secondary_Owner__c != Null) {
                ccEmails.add(accountToEmail.Sales_Secondary_Owner__r.email);
            }

            Date contractEndDate = accountToEmail.Contract_End_Date__c;
            Date contractStartDate = accountToEmail.BVCContractStartDate__c;
            Date todayDate = Date.today();
            Integer noOfAnnualContract;
             Integer   noOfAnnualContractConsumed;
            // Calculate the difference in days
            if(!test.isRunningTest()){
                noOfAnnualContract = contractEndDate.daysBetween(contractStartDate); 
                 noOfAnnualContractConsumed = todayDate.daysBetween(ContractStartDate);
            }
            
            Integer noOfBalanceDaysOfAnnualContract = ContractEndDate.daysBetween(todayDate);

            string body = 'Dear' + ' ' + accountToEmail.name + ',' + '<br/><br/>';
            body = body + 'The Detailed Annual Contract Report Link is attached for your reference.' + '<br/><br/><br/><br/>';
            body = body + accountToEmail.Recent_ACR_Report_URL__c + '<br/><br/><br/><br/>';
            body = body + 'The summary of Annual Contract is as below:' + '<br/><br/>';
            body = body + '<p>Customer Name                         :' + accountToEmail.Name + '<br/><br/>';
            body = body + 'PAN Number                               :' + accountToEmail.PAN_Number_of_Entity__c + '<br/><br/>';
            body = body + 'Account Owner                            :' + accountToEmail.Owner.name + '<br/><br/>';
            body = body + 'Annual Contract Number                   :' + accountToEmail.eSHIP_BVC_Contract__r.name + '<br/><br/>';
            body = body + 'Effective From                           :' + accountToEmail.Contract_Start_Date_eSHIP_BVC__c + '<br/><br/>';
            body = body + 'Effective Till                           :' + accountToEmail.Contract_End_Date_eSHIP__c + '<br/><br/>';
            body = body + 'No. of days of Annual Contract           :' + noOfAnnualContract + '<br/><br/>';
            body = body + 'No. of days of Annual Contract consumed  :' + noOfAnnualContractConsumed + '<br/><br/>';
            body = body + 'Balance No. of days of Annual Contract   :' + noOfBalanceDaysOfAnnualContract + '<br/><br/>';
            body = body + 'Annual Contract Amount                   :' + accountToEmail.Original_Contract_Amount__c + '<br/><br/>';
            body = body + 'Adjusted amount                          :' + accountToEmail.Adjustment_Amount_eSHIP__c + '<br/><br/>';
            body = body + 'Contract Adjusted amount                 :' + accountToEmail.Adjusted_Contract_Amount_eSHIP__c + '<br/><br/>';
            body = body + 'Consumed Amount                          :' + accountToEmail.Consumed_Amount_eSHIP__c + '<br/><br/>';
            body = body + '% Annual Contract consumed               :' + accountToEmail.of_Contract_Consumption__c + '%' + '<br/><br/>';
            body = body + 'ACR Contract Amount balance              :' + accountToEmail.Balance_Amount__c + '<br/><br/>';
            body = body + 'Number of parcels shipped                : ' + accountToEmail.Total_Parcels_Shipped_activated__c + '<br/><br/>';
            body = body + 'Net Weight shipped (Grams)               : ' + accountToEmail.Net_Weight_GMS__c + '<br/><br/>';
            body = body + 'Gross Weight shipped (Grams)             : ' + accountToEmail.Gross_Weight_GMS__c + '<br/><br/>';
            body = body + 'Product value shipped                    : ' + accountToEmail.Product_value_shipped_INR__c + '<br/><br/><br/><br/>';
            body = body + 'The BVC Standard Tariff as shown here below and shall be applicable right after the ACR expires, by date or consumption.' + '<br/><br/>';
            body = body + 'https://bvc2.file.force.com/sfc/dist/version/download/?oid=00D5g000003bGjW&ids=0685g00000JvOiH&d=%2Fa%2F5g000003jsBp%2Fp3iiRyEjobdIb5L1HVJdVb9l2PfUIxAh40thkIg.BnI&asPdf=false' + '<br/><br/><br/><br/>';
            body = body + 'For renewing your contract and for any clarifications, please feel free to get in touch with sales' + '<br/><br/>';
            body = body + 'Looking forward to a long standing relationship between BVC and ' + accountToEmail.Name + '<br/><br/>';
            body = body + 'Thanks and Regards' + ',' + '<br/><br/>';
            body = body + 'BVC Team' + '<br/><br/>';
            //body = body + User.Name + '<br/><br/>';
            //body = body + User.ST_Desig__c + '<br/><br/>';


            string subject = 'BVC Annual Contract Consumption Report Of' + '  ' + accountToEmail.name;
            sendGridEmailMessageForACR.sendGridEmailMessages(ToEmails,ccEmails,subject, body);
          //  sendGridEmailMessageForACR.sendGridEmailMessages(ccEmails, subject, body);
            
            accountToEmail.Last_ACR_report_sent_date__c = date.today();
            update accountToEmail;

            System.debug('SendEmailToCustomers Method exit limit available ' + limits.getLimitHeapSize());
            System.debug('SendEmailToCustomers Method exit Limit used ' + limits.getHeapSize());
        }
    }
    
 // Email Sent Via SingleEmailMessage from Salesforce to Customer via button on the customer Object

    public static void SendEmailToCustomersIndividually(Account accountToEmail) {
        List < Messaging.SingleEmailMessage > mailingService = new List < Messaging.SingleEmailMessage > ();
         EmailTemplate template;
        if(!Test.isrunningtest())
         template = [SELECT Id, Name FROM EmailTemplate WHERE Name = 'BVCACR Consumption Email V3'];
        
        ID conid;
        ACR_Contract_ID__mdt contactConfig = ACR_Contract_ID__mdt.getInstance('ACR_email_Contact_ID');
        if (contactConfig != null && !String.isEmpty(contactConfig.Contact_Id__c)) {
            conid = contactConfig.Contact_Id__c;
        } else {
            Contact con = [SELECT Id FROM Contact WHERE Email = 'annualcontractreport@bvclogistics.com'];
            conid = con.id;
        }

        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'annualcontractreport@bvclogistics.com'
            LIMIT 1
        ];
        list < id > Toadd = New List < id > ();
        For(Contact Cont: [SELECT Id FROM Contact WHERE AccountId =: accountToEmail.id AND Email != null]) {
            Toadd.add(Cont.id);
        }
        system.debug('Toadd+++++++'+Toadd);
        List < id > cclist = new list < id > ();
        cclist.add(conid);
        IF(accountToEmail.OwnerId != Null) {
            cclist.add(accountToEmail.OwnerId);
        }
        If(accountToEmail.Sales_Secondary_Owner__c != Null) {
            cclist.add(accountToEmail.Sales_Secondary_Owner__c);
        }
        Messaging.SingleEmailMessage mailToSend = new Messaging.SingleEmailMessage();
        if (!owea.isEmpty()) {
            mailToSend.setOrgWideEmailAddressId(owea[0].Id);
        }
        mailToSend.setTargetObjectId(Toadd[0]);
        mailToSend.setTemplateId(template.Id);
        mailToSend.setWhatId(accountToEmail.id);
        if (cclist != Null) {
            mailToSend.setCcAddresses(cclist);
        }
        if (Toadd != Null) {
            mailToSend.setToAddresses(Toadd);
        }
        mailingService.add(mailToSend);
        if (!mailingService.isEmpty()) {
            Messaging.sendEmail(mailingService);
        }
    }


}