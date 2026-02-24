public with sharing class GenerateVSBagLabel {

    public class SPWrapper {
        public Secure_Packaging__c spRecord { get; set; }
        public String barcodeUrl { get; set; }

        public SPWrapper(Secure_Packaging__c sp) {
            this.spRecord = sp;
            this.barcodeUrl = 'https://www.webarcode.com/barcode/image.php?code=' +
                EncodingUtil.urlEncode(sp.Name, 'UTF-8') +
                '&type=C128B&xres=2&height=80&width=280&font=5&output=png&style=452';
        }
    }

    public List<Vault_Shipmet__c> vaultShipList { get; set; }
    public Map<Id, List<SPWrapper>> spMap { get; set; }

    public GenerateVSBagLabel() {
        spMap = new Map<Id, List<SPWrapper>>();
        vaultShipList = new List<Vault_Shipmet__c>();

        String singleId = ApexPages.currentPage().getParameters().get('id');
        String multipleIds = ApexPages.currentPage().getParameters().get('ids');
        Set<Id> idSet = new Set<Id>();

        if (String.isNotBlank(multipleIds)) {
            for (String s : multipleIds.split(',')) {
                if (String.isNotBlank(s)) {
                    idSet.add(s.trim());
                }
            }
        } else if (String.isNotBlank(singleId)) {
            idSet.add(singleId.trim());
        }

        if (idSet.isEmpty()) {
            return;
        }

        vaultShipList = [
            SELECT Id, Name, Customer__c, Customer__r.Name,
                   Shipping_Account__c, Shipping_Account__r.Name,
                   Billing_Account__c, Billing_Account__r.Name,
                   Number_of_Packages__c, Gross_Weight_Kgs__c,
                   Vault__c, Vault__r.Name, Hub__c, Hub__r.Name,
                   Secure_Bags__c
            FROM Vault_Shipmet__c
            WHERE Id IN :idSet
        ];

       
        for (Vault_Shipmet__c v : vaultShipList) {
            if (String.isNotBlank(v.Secure_Bags__c)) {
                List<String> bagNames = v.Secure_Bags__c.split(',');
                Set<String> cleanNames = new Set<String>();
                for (String b : bagNames) {
                    if (String.isNotBlank(b)) cleanNames.add(b.trim());
                }
                if (!cleanNames.isEmpty()) {
                    List<Secure_Packaging__c> bagList = [
                        SELECT Id, Name
                        FROM Secure_Packaging__c
                        WHERE Name IN :cleanNames
                    ];
                    List<SPWrapper> wrappers = new List<SPWrapper>();
                    for (Secure_Packaging__c sp : bagList) {
                        wrappers.add(new SPWrapper(sp));
                    }
                    spMap.put(v.Id, wrappers);
                } else {
                    spMap.put(v.Id, new List<SPWrapper>());
                }
            } else {
                spMap.put(v.Id, new List<SPWrapper>());
            }
        }
    }
}