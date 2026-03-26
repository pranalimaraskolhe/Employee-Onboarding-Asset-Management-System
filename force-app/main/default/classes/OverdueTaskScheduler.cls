/*
    This Scheduled Apex runs every night at midnight and marks tasks as Overdue if they have passed their due date and are not yet Completed. 
    It also sends an alert email to the assigned team.
*/

public with sharing class OverdueTaskScheduler implements Schedulable{
    public static void execute(SchedulableContext sc) {
        OverdueTaskBatch batch = new OverdueTaskBatch();
        Database.executeBatch(batch, 200);
    }
}