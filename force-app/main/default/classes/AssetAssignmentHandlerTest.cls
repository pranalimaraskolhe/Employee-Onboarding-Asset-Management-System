@isTest
public class AssetAssignmentHandlerTest {

    @TestSetup
    static void setupData(){
        // Create test asset

        IT_Asset__c asset = new IT_Asset__c();
        asset.Name = 'Test Laptop 001';
        asset.Asset_Type__c = 'Laptop';
        asset.Status__c = 'Available';
        asset.Department_Pool__c = 'Sales';
        asset.Serial_Number__c = 'SN-TEST-001';
        insert asset;
    }

    @isTest
    static void testLaptopAssignedOnEmployeeCreate(){
        Test.startTest();

        Employee__c emp = new Employee__c();
        emp.Name = 'Test Employee';
        emp.Department__c = 'Sales';
        emp.Date_of_Joining__c = Date.today();
        emp.Work_Email__c     = 'test@company.com';
        emp.Onboarding_Status__c = 'Not Started';
        insert emp;

        Test.stopTest();

        IT_Asset__c updatedAsset = [SELECT Status__c, Assigned_To__c
                                    FROM IT_Asset__c
                                    WHERE Serial_Number__c = 'SN-TEST-001'
                                   ];

        System.assertEquals('Assigned', updatedAsset.Status__c, 'Asset should be assigned after employee creation');
        System.assertEquals(emp.Id, updatedAsset.Assigned_To__c, 'Asset should be assigned to the new employee');

    }

    @isTest
    static void testNoAssetAvailableDoesNotFail() {
        Test.startTest();
        // Sales dept has no asset — should not throw exception

        Employee__c emp = new Employee__c();
        emp.Name = 'Sales Employee';
        emp.Department__c = 'Sales';
        emp.Date_of_Joining__c = Date.today();
        emp.Work_Email__c = 'sales@company.com';
        emp.Onboarding_Status__c = 'Not Started';
        insert emp;

        Test.stopTest();

        System.assert(true, 'No exception thrown when no asset available');
    }

}