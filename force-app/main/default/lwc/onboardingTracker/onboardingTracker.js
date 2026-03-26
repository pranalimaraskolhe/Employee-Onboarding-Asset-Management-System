import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getOnboardingTasks  from '@salesforce/apex/OnboardingTrackerController.getOnboardingTasks';

const FIELDS = ['Employee__c.RecordType.DeveloperName'];

export default class OnboardingTracker extends LightningElement {
    @api recordId;
    @track tasks = [];
    @track isLoading = true;
    @track isFullTime = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS})
    wiredRecord({ data, error }) {
        if (data) {
            const recType = data.fields.RecordType?.value?.fields?.DeveloperName?.value;
            this.isFullTime = recType === 'Full_Time';
        } else if (error) {
            console.error('Error fetching record type:', error);
        }
    }

    columns = [
        { label: 'Task', fieldName: 'Task_Name__c'},
        { label: 'Category', fieldName: 'Category__c'},
        { label: 'Assigned To', fieldName: 'Assigned_Team__c'},
        { label: 'Due Date', fieldName: 'Due_Date__c', type: 'date'},
        { label: 'Status', fieldName: 'Status__c',
            cellAttributes: {
                class : { fieldName: 'statusClass'}
            }
        }
    ];

    @wire (getOnboardingTasks, { employeeId: '$recordId'})
    wiredTasks({ data, error }) {
        this.isLoading = false;
        if (data){
            this.tasks = data.map(t => ({
                ...t,
                statusClass: t.Status__c === 'Completed' ? 'slds-text-color_success' : t.Status__c === 'Overdue' ? 'slds-text-color_error' : ''
            }));
        } else if (error) {
            console.error('Error loading tasks:', error);
        }
    }

    get totalCount() {
        return this.tasks.length;
    }

    get completedCount(){
        return this.tasks.filter(t => t.Status__c === 'Completed').length;
    }

    get progressPercent(){
        return this.totalCount > 0 ? Math.round((this.completedCount / this.totalCount) * 100) : 0;
    }

    get hasTasks() {
         return this.tasks.length > 0;
    }
}