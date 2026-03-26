public class OverdueAlertEmailQueueable implements Queueable {
    private Set<Id> taskIds;
    
    public OverdueAlertEmailQueueable(Set<Id> taskIds) {
        this.taskIds = taskIds;
    }
    
    public void execute(QueueableContext context) {
        // Move your email logic here from sendOverdueAlerts
        List<Onboarding_Task__c> tasks = [SELECT Id, Task_Name__c, Assigned_Team__c,
                                          Due_Date__c, Employee__r.Name
                                          FROM Onboarding_Task__c
                                          WHERE Id IN :taskIds
                                          AND Assigned_Team__c != null
                                         ];
        
        List<Messaging.SingleEmailMessage> emails =  new List<Messaging.SingleEmailMessage>();
            
      /*  for (Onboarding_Task__c t : tasks) {
            Messaging.SingleEmailMessage mail = 
                new Messaging.SingleEmailMessage();
            mail.setToAddresses(
                new List<String>{ t.Assigned_Team__c}
            );
            mail.setSubject(
                'Overdue Task Alert: ' + t.Task_Name__c
            );
            mail.setPlainTextBody(
                'Task: ' + t.Task_Name__c + '\n' +
                'Employee: ' + t.Employee__r.Name + '\n' +
                'Due Date: ' + t.Due_Date__c + '\n' +
                'Assigned Team: ' + t.Assigned_Team__c
            );
            emails.add(mail);
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        } */

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