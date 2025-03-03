xquery version "3.1";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace json-types = "http://read.84000.co/json-types/0.5.0" at "common/types.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:request-text-id := if(request:exists()) then request:get-parameter('text-id', '') else 'UT22084-066-009';

declare variable $local:operations-data := collection(concat($common:data-path, '/operations'));
declare variable $local:entities := $local:operations-data//eft:entities;
declare variable $local:contributors := $local:operations-data//eft:contributors;
declare variable $local:request-text := $tei-content:translations-collection/id($local:request-text-id);

element creators {
    
    attribute modelType { 'creators' },
    attribute apiVersion { $json-types:api-version },
    attribute url { concat('/rest/creators.json?', string-join((concat('api-version=', $json-types:api-version), $local:request-text ! concat('text-id=', $local:request-text-id)), '&amp;')) },
    attribute timestamp { current-dateTime() },
    
    let $teis := $tei-content:translations-collection//tei:TEI
    let $count-teis := count($teis)
    for $tei at $tei-index in $teis
    let $text-id := tei-content:id($tei)
    where not($local:request-text-id gt '') or $text-id eq $local:request-text-id
    return (
        util:log('INFO', concat('Creators: ', $text-id, ' (', $tei-index, '/', $count-teis, ')')),
        for $attribution in 
            $tei//tei:titleStmt/tei:author | 
            $tei//tei:titleStmt/tei:editor | 
            $tei//tei:titleStmt/tei:consultant | 
            $tei//tei:titleStmt/tei:sponsor |
            $tei//tei:sourceDesc/tei:bibl/tei:author |
            $tei//tei:sourceDesc/tei:bibl/tei:editor
        
        let $attribution-text := json-types:normalize-text($attribution)
        let $entity := ($local:operations-data//eft:instance[range:eq(@id, $attribution/@xml:id)]/parent::eft:*)[1]
        let $entity-names := $entity ! json-types:distinct-names(., 'en')
        let $entity-name-attribution := $entity-names[eft:content/text() eq $attribution-text]
        let $entity-name := ($entity-name-attribution, $entity-names)[1]
        let $name-id := ($entity-name/@xmlId, string-join(('error', $attribution-text), ':'))[1]
        let $attribution-type :=
            if($attribution[local-name(.) = ('sponsor')]) then
                concat('contribution-', local-name($attribution))
            else if($attribution[local-name(parent::*) eq 'titleStmt'][@role]) then
                concat('contribution-', $attribution/@role)
            else if($attribution[local-name(parent::*) eq 'bibl'][@role]) then
                concat('attribution-', $attribution/@role)
            else
                ($attribution/@role, string-join(('error', $attribution-text), ':'))[1]
        
        where $entity
        return (
            (:$entity-name,:)
            json-types:creator($attribution/@xml:id, $entity/@xml:id, $name-id, $text-id, $attribution-type)
        )
    )
}
