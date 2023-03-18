public with sharing class CTLocationTracingController {
    
    
    /**
     * permet de recuperer les visiteurs selon le id location
     */
    public static List<Location_Tracing__c> getVisitors(String locationId){
        return [SELECT Id, Person__c, Location__c, Visit_Date__c, Person__r.Token__c, Person__r.Health_Status__c  
                        FROM Location_Tracing__c 
                        WHERE Id =: locationId
                        ORDER BY Visit_Date__c DESC];
    }

    /**
     * Permet de recuperer les locations  par les personnes Id
     */
    public static List<Location_Tracing__c> getLocationsByPersonIds(Set<Id> personIds){
            return [SELECT Id, Person__c, Location__c 
            FROM Location_Tracing__c 
            WHERE Person__c IN :personIds
            AND Visit_Date__c = LAST_N_DAYS:10];
    }

    /**
     * Permet de recuperer les locations par les locations Id
     */
    public static List<Location_Tracing__c> getLocationsByLocationIds(Set<Id> locationIds){
        return [SELECT Id, Person__c, Location__c 
        FROM Location_Tracing__c 
        WHERE Location__c IN :locationIds
        AND   Person__r.Health_Status__c = 'Green'
        AND Visit_Date__c = LAST_N_DAYS:10];
    }

    /**
     * Permet de query les valeurs d'enregistrement depuis Location Tracing Object, trouver les enregistrements selon locationTraces et les enregistrements selectionnés 
     * ensuite retourner la liste des enregistrements dupliqués de Location Tracing 
     */
    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> newLocationTraces){

        // Enregistrer location ids uniques
        Set<Id> locationIds = new Set<Id>();

        // Enregistrer person ids uniques 
        Set<Id> personIds = new Set<Id>();

        for (Location_Tracing__c trace : newLocationTraces) {
            locationIds.add(trace.Location__c);
            personIds.add(trace.Person__c);
        }

        // map of location id, set of person ids 
        Map<Id, Set<Id>> mapOfExistingRecords = new Map<Id, Set<Id>>();

        //

        // query les enregistrements existents de location tracing
        List<Location_Tracing__c> existingRecords = [SELECT Id, Person__c, Location__c 
                                                        FROM Location_Tracing__c 
                                                        WHERE Location__c IN :locationIds
                                                        AND   Person__c   IN :personIds];
        
        // list of duplicate records 
        List<Location_Tracing__c> duplicates = new List<Location_Tracing__c>();

        if(existingRecords != null && existingRecords.size() > 0 ){
            for (Location_Tracing__c trace : existingRecords) {
                if(! mapOfExistingRecords.containsKey(trace.Location__c)){
                        mapOfExistingRecords.put(trace.Location__c, new Set<Id>());
                }
                //add personids to map set 
                mapOfExistingRecords.get(trace.Location__c).add(trace.Person__c);
            }

                // boucle sur les nouveaux enregistrements de location tracing records
                for (Location_Tracing__c trace : newLocationTraces) {
                    //premierement vérifier location id
                    //Si item est trouvé dans map, donc vérifier la personne dans le set
                    if(mapOfExistingRecords.containsKey(trace.Location__c) 
                            && mapOfExistingRecords.get(trace.Location__c).contains(trace.Person__c)){
                                duplicates.add(trace);
                            } 
                }

        }

        return duplicates;

    }

}