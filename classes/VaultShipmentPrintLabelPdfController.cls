public with sharing class VaultShipmentPrintLabelPdfController {

    public class VaultShipmentWrapper {
        public Vault_Shipmet__c shipment { get; set; }

        public String BillingAccount { get; set; }
        public String BillingAddress { get; set; }
        public String ShippingAccount { get; set; }
        public String ShippingAddress { get; set; }
        public String ExhibitionName { get; set; }
        public String NewExhibitionName { get; set; }
        public String HubName { get; set; }
        public String AuthPerIdDetails { get; set; }
        public String AuthPerName { get; set; }
        public List<String> SBList { get; set; }
        public String SecureBagsCommaSeparated { get; set; } 

        public Integer D { get; set; }
        public Integer M { get; set; }
        public Integer Y { get; set; }

        public Boolean isLast { get; set; }

        public VaultShipmentWrapper(Vault_Shipmet__c s, Boolean last) {
            shipment = s;
            isLast = last;

            BillingAccount = s.Billing_Account__r != null ? s.Billing_Account__r.Name : '';
            BillingAddress = s.Billing_Address__r != null ? s.Billing_Address__r.Name : 'No Billing Address';
            ShippingAccount = s.Shipping_Account__r != null ? s.Shipping_Account__r.Name : '';
            ShippingAddress = s.Stall_Details_Shipping_Address__r != null ? s.Stall_Details_Shipping_Address__r.Name : 'No Shipping Address';
            ExhibitionName = s.Exhibition_Name__r != null ? s.Exhibition_Name__r.Name : '';
            NewExhibitionName = s.New_Exhibition_Name__c;
            HubName = s.Hub__r != null ? s.Hub__r.Name : '';

            AuthPerIdDetails = s.Authorised_Person_ID_Details__c;
            AuthPerName = s.Authorised_Person_Name__c;

            SBList = String.isNotBlank(s.Secure_Bags__c)
                ? s.Secure_Bags__c.split(',')
                : new List<String>();

         
            SecureBagsCommaSeparated = (SBList != null && !SBList.isEmpty())
                ? String.join(SBList, ', ')
                : '';

            D = s.CreatedDate.day();
            M = s.CreatedDate.month();
            Y = s.CreatedDate.year();
        }
    }

    public List<VaultShipmentWrapper> wrappedList { get; set; }
    public List<Integer> twoCopies { get; set; }

    public VaultShipmentPrintLabelPdfController() {
        wrappedList = new List<VaultShipmentWrapper>();
        twoCopies = new List<Integer>{1,2};

        String singleId = ApexPages.currentPage().getParameters().get('id');
        String multipleIds = ApexPages.currentPage().getParameters().get('ids');
        Set<Id> idSet = new Set<Id>();

        if (String.isNotBlank(multipleIds)) {
            for (String s : multipleIds.split(',')) {
                if (String.isNotBlank(s)) idSet.add(s.trim());
            }
        } else if (String.isNotBlank(singleId)) {
            idSet.add(singleId.trim());
        }

        if (idSet.isEmpty()) return;

        List<Vault_Shipmet__c> shipmentList = [
            SELECT Id, Name, Product_Description__c, Number_of_Packages__c,
                   Net_Weight_in_Kgs__c, Gross_Weight_Kgs__c, Product_Value__c,
                   Insurance_by_BVC__c, Billing_Account__r.Name,
                   Shipping_Account__r.Name, Exhibition_Name__r.Name,
                   New_Exhibition_Name__c, Hub__r.Name, BarcodeUrl__c,
                   Authorised_Person_ID_Details__c, Authorised_Person_Name__c,
                   Billing_Address__r.Name, Stall_Details_Shipping_Address__r.Name,
                   Secure_Bags__c, CreatedDate
            FROM Vault_Shipmet__c
            WHERE Id IN :idSet
        ];

        for (Integer i = 0; i < shipmentList.size(); i++) {
            wrappedList.add(new VaultShipmentWrapper(
                shipmentList[i],
                i == shipmentList.size() - 1
            ));
        }
    }
}