public with sharing class CTLocationController {
   
    /**
     * Permet de recuperer 100 location ordonnéses en DESC selon le Status Update Date
     */
    public static List<Location__c> getRecentStatusChanges(){
        return [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c FROM Location__c ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];
    }

    /**
     * Permet de chercher la location via searchTerm
     */
    public static  List<Location__c> searchLocations (String searchTerm){

        searchTerm = searchTerm + '%';
        return [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
        FROM Location__c
            WHERE Name LIKE :searchTerm 
                OR Pincode__c LIKE :searchTerm  
                OR Address__c LIKE :searchTerm 
                    ORDER BY Status_Update_Date__c DESC NULLS LAST ];

    }

    /**
     * Permet de recuperer la location par Id
     */
    public static Location__c getLocationById(String locationId){
        List<Location__c> local = [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                    FROM Location__c
                        WHERE Id= :locationId];

        if(local != null && local.size() > 0){
            return local[0];
        }
        return null;
    }
    
    /**
     * Recupérer le count des locations selon le status
     * @return Map<String, Integer>
     */
    public static Map<String, Integer> getStatusCount(){
        Map<String, Integer> healthCountMap = new Map<String, Integer>();

        for (AggregateResult ar : [SELECT Status__c, COUNT(Id) total 
                                            FROM Location__c 
                                            GROUP BY Status__c]) {
        String status = String.valueOf(ar.get('Status__c'));

        Integer count = Integer.valueOf(ar.get('total'));
         healthCountMap.put(status, count);
        }
        return healthCountMap;
    }

}