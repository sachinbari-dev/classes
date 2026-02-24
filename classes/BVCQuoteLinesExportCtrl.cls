/*Class      : BVCQuoteLinesExportCtrl
 *Author     : Sanket.pisal@bvclogistics.com
 *Date       : November 2025
 */
public with sharing class BVCQuoteLinesExportCtrl {

    public Id quoteId { get; set; }

    public BVCQuoteLinesExportCtrl() {
        quoteId = ApexPages.currentPage().getParameters().get('id');
    }

    // Helper method to avoid nulls
    private String n(Object val) {
        return (val == null) ? '0' : String.valueOf(val);
    }

    public String getCsvData() {

        List<BVCQuoteLineItem__c> lines = [
            SELECT Id, Name, Product__r.Name, Quantity__c,
                   All_Risk_Liability__c, Fidelity_Liability__c,Offline_Charge_Discount_Percent__c,
                   All_Risk_Liability_Discount_Percent__c,Indirect_Location_Discount_Percent__c,
                   Discount_Percent__c,ST_Minimum_Percent__c,Remote_Location_Discount_Percent__c,
                   Rate_UOM__c,Subrogation_Liability_Discount_Percent__c,Fuel_Surcharge_Discount_Percent__c,
                   Universe_Cost_Charge_Discount_Percent__c,Max_Discount__c,Package_Type__c,Product_Code__c,
                   Gross_Weight_Slabs__c,Net_Unit_Price__c,Rate_Amount__c,Minimum_Freight__c,
                   Offline_Charge__c,Remote_Location__c,Indirect_Location__c,Fuel_Surcharge__c,
                   Liability_Coverage__c,Universe_Cost_Charge__c,Subrogation_Liability__c,ST_Rate_Discount__c,
                   Fidelity_Liability_Discount_Percent__c
            FROM BVCQuoteLineItem__c
            WHERE BVCQuote__c = :quoteId
            ORDER BY CreatedDate ASC
        ];

        if (lines.isEmpty()) {
            return 'NO_DATA';
        }

        String header = 'Name,Product,Max Discount,Package type,Net Unit Price,Rate Amount,Rate UOM,Rate Discount,Minimun Freight,Minimun Freight (%),Fuel Surcharge,Fuel Surcharge (%),Universe Cost Charge,Universe Cost Charge (%),All Risk Liability,All Risk Liablity (%),Fidelity Liability,Fidelity Liability (%),Subrogation Liability,Subrogation Liability (%),Offline Charge,Offline Charge (%),Remote Location,Remote Location (%),Indirect Location,Indirect Location (%)\n';
        String csvBody = '';

        for (BVCQuoteLineItem__c line : lines) {
            csvBody += '"' + n(line.Name) + '","' +
                        n(line.Product__r.Name) + '","' +
                        n(line.Max_Discount__c) + '","' +
                        n(line.Package_Type__c) + '","' +
                        n(line.Net_Unit_Price__c) + '","' +
                        n(line.Rate_Amount__c) + '","' +
                        n(line.Rate_UOM__c) + '","' +
                        n(line.ST_Rate_Discount__c) + '","' +
                        n(line.Minimum_Freight__c) + '","' +
                        n(line.ST_Minimum_Percent__c) + '","' +
                        n(line.Fuel_Surcharge__c) + '","' +
                        n(line.Fuel_Surcharge_Discount_Percent__c) + '","' +
                        n(line.Universe_Cost_Charge__c) + '","' +
                        n(line.Universe_Cost_Charge_Discount_Percent__c) + '","' +
                        n(line.All_Risk_Liability__c) + '","' +
                        n(line.All_Risk_Liability_Discount_Percent__c) + '","' +
                        n(line.Fidelity_Liability__c) + '","' +
                        n(line.Fidelity_Liability_Discount_Percent__c) + '","' +
                        n(line.Subrogation_Liability__c) + '","' +
                        n(line.Subrogation_Liability_Discount_Percent__c) + '","' +
                        n(line.Offline_Charge__c) + '","' +
                        n(line.Offline_Charge_Discount_Percent__c) + '","' +
                        n(line.Remote_Location__c) + '","' +
                        n(line.Remote_Location_Discount_Percent__c) + '","' +
                        n(line.Indirect_Location__c) + '","' +
                        n(line.Indirect_Location_Discount_Percent__c) + '"\n';
        }

        return header + csvBody;
    }
}