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

declare variable $local:request-entity-id := if(request:exists()) then request:get-parameter('id', '') else '';
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
    
        (: entity/content[@type="glossary-notes" :)
        $entity/eft:content[@type eq 'glossary-notes'][descendant::text()[normalize-space()]] ! types:annotation($entity/@xml:id, 'contentGlossaryNotes', helpers:normalize-text(.), @timestamp ! xs:dateTime(.), @user),
        
        (: entity/content[@type="preferred-translation"] :)
        (:$entity/eft:content[@type eq 'preferred-translation'][descendant::text()[normalize-space()]] ! json-types:annotation($entity/@xml:id, 'contentPreferredTranslation', json-types:normalize-text(.), @timestamp ! xs:dateTime(.), @user),:)
        
        (: entity/flag :)
        for $instance in $entity/eft:instance
        let $instance-id := $instance/@id/string()
        let $instance-type := $instance/@type/string()
        group by $instance-id, $instance-type
        return (
            
            for $flag in $instance/eft:flag
            return
                if($flag[@type eq 'requires-attention']) then
                    types:annotation($instance-id, 'flagRequiresAttention', (), $flag/@timestamp ! xs:dateTime(.), $flag/@user)
                else if($flag[@type eq 'hidden']) then
                    types:annotation($instance-id, 'flagHidden', (), $flag/@timestamp ! xs:dateTime(.), $flag/@user)
                else
                    types:annotation($instance-id, concat('flag', $flag/@type), (), $flag/@timestamp ! xs:dateTime(.), $flag/@user)
            
        )
    )
    
};

declare function local:teams() {

    for $team at $entity-index in $local:contributors/eft:team
    where (not($local:request-entity-id gt '') and not($local:request-text-id gt '')) or count($team except $local:request-entity) eq 0
    return (
    
        $team[@rend eq 'hidden'] ! types:annotation($team/@xml:id, 'rendHidden', (), (), ())
        
    )
   
};

let $response :=
    element authorities-annotations {
        
        attribute modelType { 'authorities-annotations' },
        attribute apiVersion { $types:api-version },
        attribute url { concat('/rest/authorities-annotations.json?', string-join((concat('api-version=', $types:api-version), $local:request-entity[@xml:id eq $local:request-entity-id] ! concat('id=', $local:request-entity-id), $local:request-tei ! concat('text-id=', $local:request-text-id)), '&amp;')) },
        attribute timestamp { current-dateTime() },
        
        local:entities(),
        local:teams()
        
    }

return
    if($local:request-store eq 'store') then
        helpers:store($response, concat($response/@modelType, '.json'), ())
    else
        $response
        