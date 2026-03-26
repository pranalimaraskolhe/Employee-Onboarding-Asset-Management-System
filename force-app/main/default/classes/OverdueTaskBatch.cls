/*
    This Scheduled Apex runs every night at midnight and marks tasks as Overdue if they have passed their due date and are not yet Completed. 
    It also sends an alert email to the assigned team.
*/

public with sharing class OverdueTaskBatch  implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, Status__c, Due_Date__c, Assigned_Team__c, Task_Name__c, Employee__r.Name 
                                         FROM Onboarding_Task__c 
                                         WHERE Status__c != 'Completed' 
                                         AND Status__c != 'Overdue' 
                                         AND Due_Date__c < TODAY ]);
    }

    public void execute(Database.BatchableCOntext bc, List<Onboarding_Task__c> tasks){
        List<Onboarding_Task__c> toUpdate = new List<Onboarding_Task__c>();

        if(tasks!=null && !tasks.isEmpty()){
            for(Onboarding_Task__c t : tasks){
                t.Status__c = 'Overdue';
                toUpdate.add(t);
            }
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;

            // Send alert emails using @future to avoid mixed DML

            Set<Id> ids = new Map<Id, Onboarding_Task__c>(toUpdate).keySet();
            // OnboardingEmailService.sendOverdueAlerts(ids);
            System.enqueueJob(new OverdueAlertEmailQueueable(ids));
        }

    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Overdue Task Batch completed.');
    }

}