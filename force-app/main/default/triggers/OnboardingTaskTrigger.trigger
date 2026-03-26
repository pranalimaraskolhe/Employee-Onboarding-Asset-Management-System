trigger OnboardingTaskTrigger on Onboarding_Task__c (after update) {
    if(trigger.isAfter){
        if(trigger.isUpdate){
            OnboardingTaskHandler.checkOnboardingCompletion(trigger.new, trigger.oldMap);
        }
    }
}