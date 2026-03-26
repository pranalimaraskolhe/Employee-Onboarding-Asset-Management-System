trigger AssetAssignmentTrigger on Employee__c (after insert) {
    if(trigger.isAfter){
        if(trigger.isInsert){
            AssetAssignmentHandler.assignAssetsToNewEmployees(trigger.new);
        }
    }
}