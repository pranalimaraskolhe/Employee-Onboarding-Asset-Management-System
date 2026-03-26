/*
    Fires: AFTER UPDATE on Onboarding_Task__c
    Purpose: When all onboarding tasks for an employee are Completed, auto-update the Employee Onboarding_Status__c to Completed and send a completion email.

*/

public with sharing class OnboardingEmailService {

    @future
    public static void sendCompletionEmails(Set<Id> employeeIds){
        List<Employee__c> employees  = [SELECT Id, Name, Work_Email__c, Manager__r.Name, Date_of_Joining__c, Employee_ID__c 
                                        FROM Employee__c 
                                        WHERE Id IN : employeeIds
                                        AND Work_Email__c != null];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        if(employees!=null && !employees.isEmpty()){
            for(Employee__c emp : employees){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{ emp.Work_Email__c});
                mail.setSubject('Onboarding Complete - Welcome to the Team, ' + emp.Name + '!');
                mail.setPlainTextBody(
                    'Dear ' + emp.Name + ',\n\n' +
                    'Congratulations! Your onboarding process is now complete.\n' +
                    'Employee ID: ' + emp.Employee_ID__c + '\n' +
                    'Manager: ' + emp.Manager__r.Name + '\n\n' +
                    'Welcome aboard!\n\nHR & IT Team'
                );

                emails.add(mail);
            }

            if(!emails.isEmpty()){
                Messaging.sendEmail(emails);
            }
        }
    }

        @future
        public static void sendOverdueAlerts(Set<Id> taskIds) {
            // Similar pattern: query tasks, build and send emails to team

            List<Onboarding_Task__c> tasks = [SELECT Id, Status__c, Due_Date__c, Assigned_Team__c, Task_Name__c, Employee__r.Name
                                              FROM Onboarding_Task__c
                                              WHERE Id IN : taskIds
                                              AND Assigned_Team__c != null];


            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

            if(tasks!=null && !tasks.isEmpty()){
                for(Onboarding_Task__c t : tasks){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{ t.Assigned_Team__c});
                    mail.setSubject('Overdue Task Alert - ' + t.Task_Name__c);
                    mail.setPlainTextBody(
                        'Dear Team,\n\n' +
                        'The following task is overdue:\n\n' +
                        'Task Name: ' + t.Task_Name__c + '\n' +
                        'Employee: ' + t.Employee__r.Name + '\n' +
                        'Due Date: ' + t.Due_Date__c + '\n\n' +
                        'Please take action to complete this task.\n\n' +   
                        'Best regards,\nHR & IT Team'
                    );

                    emails.add(mail);

                }


                if(!emails.isEmpty()){
                    Messaging.sendEmail(emails);
                }
            }

        }
}