public with sharing class CTPersonController {
    public static String getToken(String mobileNo){
        Blob value = Blob.valueOf(mobileNo);
        Blob hash = Crypto.generateDigest('MD5', value);

        //récuperer la valeur de hash blob
        return EncodingUtil.base64Encode(hash);
        
    }

    /**
     * Permet de recuperer 100 contacts avec un health status change 
     */
    public static List<Person__c> getRecentHealthChanges(){
        return [SELECT Name, Id, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c FROM Person__c  ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];
    }

    /**
     * Permet de recupérer les contacts avec le name, mobile et status update égalent au mot de recherche searchTerm
     **/

    public static List<Person__c> searchPeople(String searchTerm){
        searchTerm = searchTerm + '%';
        return [SELECT Name, Id, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
            FROM Person__c 
            WHERE Name LIKE :searchTerm 
                OR Mobile__c LIKE :searchTerm  
                OR Token__c LIKE :searchTerm 
                    ORDER BY Status_Update_Date__c DESC NULLS LAST ];
    }

    /**
     * Permet trouver une personne selon son Id
     */
    public static Person__c getPersonById(String personId){
        List<Person__c> people = [SELECT Name, Id, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
                    FROM Person__c
                        WHERE Id= :personId];

        if(people != null && people.size() > 0){
            return people[0];
        }
        return null;
    }

    /**
     * recuperer people selon leur health status
     * @return Map<String, Integer>
     */
    public static Map<String, Integer>  getHealthStatusCount(){
        
        Map<String, Integer> healthCountMap = new Map<String, Integer>();
         
        for(AggregateResult ar : [SELECT Health_Status__c, COUNT(Id) total 
                                        FROM Person__c 
                                        GROUP BY Health_Status__c ]){

        String healthStatus = String.valueOf(ar.get('Health_Status__c'));

        Integer count = Integer.valueOf(ar.get('total'));

        healthCountMap.put(healthStatus, count);        
    }
    return healthCountMap;

}


}