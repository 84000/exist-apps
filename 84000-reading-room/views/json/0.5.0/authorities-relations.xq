xquery version "3.1";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace types = "http://read.84000.co/json-types/0.5.0" at "common/types.xql";
import module namespace helpers = "http://read.84000.co/json-helpers/0.5.0" at "common/helpers.xql";
import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:request-entity-id := if(request:exists()) then request:get-parameter('id', '') else 'entity-715';
declare variable $local:request-text-id := if(request:exists()) then request:get-parameter('text-id', '') else 'UT22084-066-009';
declare variable $local:request-tei := $local:request-text-id[. gt ''] ! tei-content:tei(., 'translation');
declare variable $local:request-store := if(request:exists()) then request:get-parameter('store', '') else '';
declare variable $local:text-xmlids := $local:request-tei//@xml:id;

declare variable $local:operations-data := collection(concat($common:data-path, '/operations'));
declare variable $local:entities := $local:operations-data//eft:entities;
declare variable $local:contributors := $local:operations-data//eft:contributors;
declare variable $local:sponsors := $local:operations-data//eft:sponsors;
declare variable $local:request-entity := 
    if($local:request-entity-id gt '') then 
        $local:operations-data/id($local:request-entity-id) 
    else if($local:text-xmlids) then 
        $local:operations-data//eft:instance[@id = $local:text-xmlids]/parent::*
    else ();

declare function local:entities() {
    
    for $entity at $entity-index in $local:entities/eft:entity
    where (not($local:request-entity-id gt '') and not($local:request-text-id gt '')) or count($entity except $local:request-entity) eq 0
    return (
    
        (: entity/relation :)
        for $relation in $entity/eft:relation
        let $relation-id := $relation/@id/string()
        let $relation-predicate := $relation/@predicate/string()
        let $target-entity := $local:operations-data/id($relation-id) 
        where $target-entity
        group by $relation-id, $relation-predicate
        return
            types:object-relation($entity/@xml:id, $relation-predicate, $relation-id)
    
    )
    
};

declare function local:contributors() {

    for $contributor at $entity-index in $local:contributors/eft:person
    where (not($local:request-entity-id gt '') and not($local:request-text-id gt '')) or count($contributor except $local:request-entity) eq 0
    return (
    
        $contributor/eft:institution/@id[. gt ''] ! types:object-relation($contributor/@xml:id, 'isMemberOf', .),
        
        $contributor/eft:team/@id[. gt ''] ! types:object-relation($contributor/@xml:id, 'isMemberOf', .)
        
    )
};

let $response := 
    element authorities-relations {
        
        attribute modelType { 'authorities-relations' },
        attribute apiVersion { $types:api-version },
        attribute url { concat('/rest/authorities-relations.json?', string-join((concat('api-version=', $types:api-version), $local:request-entity[@xml:id eq $local:request-entity-id] ! concat('id=', $local:request-entity-id), $local:request-tei ! concat('text-id=', $local:request-text-id)), '&amp;')) },
        attribute timestamp { current-dateTime() },
        
        local:entities(),
        local:contributors()
        
    }

return
    helpers:store($local:request-store, $response, concat($response/@modelType, '.json'), ())

        