public without sharing class MS_Helper 
{
    @AuraEnabled
	public static void testMethod1(String customerId)
    {
        System.debug('Sample Calsss Test');
        System.debug('Sample Calsss customerId :'+customerId);
    }
}