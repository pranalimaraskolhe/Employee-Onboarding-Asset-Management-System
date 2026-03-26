public with sharing class OnboardingTrackerController {
    
    @AuraEnabled(cacheable=true)
    public static List<Onboarding_Task__c> getOnboardingTasks(Id employeeId) {

        return [SELECT Id, Task_Name__c, Category__c, Status__c, Due_Date__c, Assigned_Team__c, Completed_On__c 
                FROM Onboarding_Task__c 
                WHERE Employee__c =: employeeId
                ORDER BY Due_Date__c ASC 
                LIMIT 50
               ];
    }
}