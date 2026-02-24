public class UpdateLinehaulNamesOnSecureBag {

    @InvocableMethod
    public static void updateLinehaulNames(List<Id> bagsId) {
        List<Secure_Bag__c> bags = [SELECT Id, Linehaul_Tracking__r.Name,Linehaul_Tracking__r.Linehaul_Name__c,Master_AWB__c, Linehaul_Names__c FROM Secure_Bag__c WHERE Id IN :bagsId];

        for (Secure_Bag__c bg : bags) {
            String linehaulName = bg.Linehaul_Tracking__r.Name;

            if (String.isNotBlank(linehaulName)) {
                // Split existing Linehaul Names into a Set
                Set<String> existingLinehaulNames = new Set<String>();
                if (String.isNotBlank(bg.Linehaul_Names__c)) {
                    existingLinehaulNames.addAll(bg.Linehaul_Names__c.split(','));
                }

                // Add the new Linehaul Tracking name to the Set
                existingLinehaulNames.add(linehaulName);

                // Join the Set elements into a comma-separated string
                bg.Linehaul_Names__c = String.join(new List<String>(existingLinehaulNames), ',');
                bg.Master_AWB__c = bg.Linehaul_Tracking__r.Linehaul_Name__c;
            }
        }

        update bags;
    }
}