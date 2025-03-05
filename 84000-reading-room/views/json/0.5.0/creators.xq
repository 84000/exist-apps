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

declare variable $local:request-text-id := if(request:exists()) then request:get-parameter('text-id', '') else 'UT23703-093-001';
declare variable $local:request-tei := $local:request-text-id[. gt ''] ! tei-content:tei(., 'translation');
declare variable $local:request-store := if(request:exists()) then request:get-parameter('store', '') else '';
declare variable $local:entities := collection(concat($common:data-path, '/operations'))//eft:entities;
declare variable $local:contributors := collection(concat($common:data-path, '/operations'))//eft:contributors;
declare variable $local:sponsors := collection(concat($common:data-path, '/operations'))//eft:sponsors;
declare variable $local:teis := $tei-content:translations-collection//tei:TEI;
declare variable $local:count-teis := count($local:teis);

declare function local:instance($instance-id as xs:string) as element(eft:instance)? {
    let $instance := $local:contributors//eft:instance[@id eq $instance-id]
    let $instance := 
        if(not($instance)) then
            $local:sponsors//eft:instance[@id eq $instance-id]
        else
            $instance
    return
        if(not($instance)) then
            $local:entities//eft:instance[@id eq $instance-id]
        else
            $instance
};

declare function local:creators($tei as element(tei:TEI), $tei-index as xs:integer) as element(eft:creator)* {

    let $text-id := tei-content:id($tei)
    let $attributions := 
        $tei//tei:titleStmt/tei:author | 
        $tei//tei:titleStmt/tei:editor | 
        $tei//tei:titleStmt/tei:consultant | 
        $tei//tei:titleStmt/tei:sponsor |
        $tei//tei:sourceDesc/tei:bibl/tei:author |
        $tei//tei:sourceDesc/tei:bibl/tei:editor
    where (not($local:request-text-id gt '') or count($tei | $local:request-tei) eq 1) and $attributions
    return
        try {
            
            (:util:log('INFO', concat('Creators: ', $text-id, ' (', $tei-index, '/', $local:count-teis, ')')),:)
            
            for $attribution in $attributions
            let $instance := $attribution/@xml:id ! local:instance(.)
            let $entity := ($instance/parent::eft:*)[1]
            let $entity-names := $entity ! types:distinct-names(., 'en')
            let $attribution-text := helpers:normalize-text($attribution)
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
                else if($attribution[local-name(.) eq 'author'][local-name(parent::*) eq 'bibl']) then
                    concat('attribution-', 'author')
                else
                    ($attribution/@role, string-join(('error', $attribution-text), ':'))[1]
            
            where $entity
            return (
                (:$entity-name,:)
                types:creator($attribution/@xml:id, $entity/@xml:id, $name-id, $text-id, $attribution-type)
            )
            
        }
        catch * {
            util:log('ERROR', 'json/0.5.0/creators:'|| $text-id)
        }
        
};

let $response :=
    element creators {
        
        attribute modelType { 'creators' },
        attribute apiVersion { $types:api-version },
        attribute url { concat('/rest/creators.json?', string-join((concat('api-version=', $types:api-version), $local:request-tei ! concat('text-id=', $local:request-text-id)), '&amp;')) },
        attribute timestamp { current-dateTime() },
        
        for $tei at $tei-index in $local:teis
        return
            local:creators($tei, $tei-index)
            
    }

return
    if($local:request-store eq 'store') then
        helpers:store($response, concat($response/@modelType, '.json'), ())
    else
        $response