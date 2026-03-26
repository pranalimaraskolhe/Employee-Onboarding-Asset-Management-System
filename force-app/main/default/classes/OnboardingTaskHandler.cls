/*
    Fires: AFTER UPDATE on Onboarding_Task__c
    Purpose: When all onboarding tasks for an employee are Completed, auto-update the Employee Onboarding_Status__c to Completed and send a completion email.
*/

public with sharing class OnboardingTaskHandler {
    public static void checkOnboardingCompletion(List<Onboarding_Task__c> newTasks, Map<Id, Onboarding_Task__c> oldMap){

        // Step 1: Collect Employee IDs where a task just became Completed

        Set<Id> changedEmployeeIds = new Set<Id>();

        if(newTasks!=null && !newTasks.isEmpty()){
            for(Onboarding_Task__c task : newTasks){
                Onboarding_Task__c oldTask = oldMap.get(task.Id);
                Boolean justCompleted = task.Status__c == 'Completed' && oldTask.Status__c != 'Completed';
                if(justCompleted && task.Employee__c!=null){
                    changedEmployeeIds.add(task.Employee__c);
                }
            }
        }

        if (changedEmployeeIds.isEmpty()) return;

        // Step 2: For each employee, check if ALL tasks are completed
        // One SOQL with aggregate to count non-completed tasks

        Map<Id, Integer> pendingCountMap = new Map<Id, Integer>();

        AggregateResult[] res = [SELECT Employee__c empId, COUNT(Id) cnt
                                 FROM Onboarding_Task__c
                                 WHERE Employee__c IN : changedEmployeeIds
                                 AND Status__c != 'Completed'
                                 GROUP BY Employee__c
                                ];

        for(AggregateResult ar : res){
            pendingCountMap.put((Id) ar.get('empId'), (Integer) ar.get('cnt'));
        }
        
        // Step 3: Employees with zero pending tasks are fully onboarded

        List<Employee__c> toComplete = new List<Employee__c>();
        Set<Id> completedEmpIds = new Set<Id>();

        if(changedEmployeeIds!=null && !changedEmployeeIds.isEmpty()){
            for(Id empId : changedEmployeeIds){
                if(!pendingCountMap.containsKey(empId)){
                    Employee__c emp = new Employee__c();
                    emp.Id = empId;
                    emp.Onboarding_Status__c = 'Completed';
                    toComplete.add(emp);

                    completedEmpIds.add(empId);
                }
            }
        }

        // Step 4: DML and async email outside loops

        if (!toComplete.isEmpty()) {
            update toComplete;
            OnboardingEmailService.sendCompletionEmails(completedEmpIds);
        }

    }
}