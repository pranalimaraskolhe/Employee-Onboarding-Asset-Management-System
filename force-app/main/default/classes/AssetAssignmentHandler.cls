/*
Fires: AFTER INSERT on Employee__c
Purpose: When a new employee is created, find an available asset of type Laptop from their department pool and auto-assign it.
*/

public with sharing class AssetAssignmentHandler {
    public static void assignAssetsToNewEmployees(List<Employee__c> newEmployees) {

        Set<String> departments = new Set<String>();

        if(newEmployees!=null && !newEmployees.isEmpty()){
            for(Employee__c emp : newEmployees){
                if(emp.Department__c != null){
                    departments.add(emp.Department__c);
                }
            }
        }

        Map<String, List<IT_Asset__c>> deptAssetMap = new Map<String, List<IT_Asset__c>>();

        List<IT_Asset__c> assetLst = [SELECT  Id, Department_Pool__c, Status__c
                                      FROM IT_Asset__c
                                      WHERE Asset_Type__c = 'Laptop'
                                      AND Status__c = 'Available'
                                      AND Department_Pool__c IN :departments
                                      ];

        if(assetLst!=null && !assetLst.isEmpty()){
            for(IT_Asset__c asset : assetLst){
                if(!deptAssetMap.containskey(asset.Department_Pool__c)){
                    deptAssetMap.put(asset.Department_Pool__c, new List<IT_Asset__c>());
                }
                deptAssetMap.get(asset.Department_Pool__c).add(asset);
            }
        }

        List<IT_Asset__c> assetsToUpdate = new List<IT_Asset__c>();

        if(newEmployees!=null && !newEmployees.isEmpty()){
            for(Employee__c emp : newEmployees){
                String dept = emp.Department__c;
                if(dept!=null && deptAssetMap.containskey(dept) && !deptAssetMap.get(dept).isEmpty()){
                    IT_Asset__c asset = deptAssetMap.get(dept).remove(0);
                    asset.Status__c      = 'Assigned';
                    asset.Assigned_To__c = emp.Id;
                    asset.Assignment_Date__c = Date.today();
                    assetsToUpdate.add(asset);

                }
            }
        }

        if (!assetsToUpdate.isEmpty()) {
            update assetsToUpdate;
        }

    }
}