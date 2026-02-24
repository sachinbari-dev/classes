// PeopleController.cls (Apex controller)
public with sharing class PeopleController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getPeopleList() {
        return [SELECT Id, Name,Email FROM Contact];
    }
}