xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace common = "http://read.84000.co/common" at "../../../modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../../modules/tei-content.xql";
import module namespace eft-json = "http://read.84000.co/json" at "../eft-json.xql";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:api-version := '0.2.0';
declare variable $local:response := request:get-data()/m:response;
declare variable $local:translation := $local:response/m:translation;
declare variable $local:text-id := $local:response/m:translation/@id;
declare variable $local:toh-key := $local:translation/m:source/@key;
declare variable $local:text-outline := $local:response/m:text-outline[@text-id eq $local:text-id];

declare function local:persistent-location($node as node()) as element() {

    if($node[ancestor-or-self::tei:*/preceding-sibling::tei:milestone[@xml:id]]) then
        $node/ancestor-or-self::tei:*[preceding-sibling::tei:milestone[@xml:id]][1]/preceding-sibling::tei:milestone[@xml:id][1]
    else 
        $node/ancestor-or-self::m:part[@id][1]

};

declare function local:parse-translation() {

    element translation {

        attribute api-version { $local:api-version },
        attribute url { concat('/translation/', $local:translation/m:source/@key,'.json?api-version=', $local:api-version) },
        attribute text-id { $local:translation/@id },
        attribute toh-key { $local:toh-key },
        attribute text-version { tei-content:strip-version-number($local:translation/m:publication/m:edition/text()[1]) },
        attribute html { $local:translation/@canonical-html },
        (:attribute debug { string-join($local:translation/m:part/@type, ' / ') },:)
        
        for $title in ($local:translation/m:titles/m:title, $local:translation/m:long-titles/m:title, $local:translation/m:source/m:toh)[normalize-space()]
        return
            element title { 
                attribute xml:lang { ($title/@xml:lang, 'en')[1] }, 
                attribute type { if($title/self::m:toh) then 'toh' else if($title/parent::m:titles) then 'main' else 'long' },
                $title/text()
            }
        ,
        
        $local:translation/m:source/m:isCommentaryOf,
        
        for $node at $text-node-index in (
            $local:translation/m:part[@type = ('translation')]/descendant::text()[normalize-space(.)][not(ancestor-or-self::*/@key) or ancestor-or-self::*[@key eq $local:toh-key]][not(ancestor::tei:note)][not(ancestor::tei:orig)][not(ancestor::tei:head[@type eq 'translation'])]
            | $local:translation/m:part[@type = ('translation')]/descendant::tei:ref[@cRef]
        )
        let $location := local:persistent-location($node)
        let $location-id := ($location/@xml:id, $location/@id)[. gt ''][1]
        let $location-milestone-pre-processed := $local:text-outline/m:pre-processed[@type eq 'milestones']/m:milestone[@id eq $location-id]
        let $location-milestone-part := $local:text-outline/m:pre-processed[@type eq 'parts']//m:part[@id eq ($location-milestone-pre-processed/@part-id, $location-id)[1]]
        let $location-group := ($node/ancestor-or-self::tei:div[1] | $node/ancestor-or-self::m:part[1])[1]
        group by $location-id
        order by $text-node-index[1] ascending
        return
            element translation { 
                attribute location-id { $location-id },
                $location-milestone-part[1][@prefix] ! attribute location-label { concat(@prefix, $location-milestone-pre-processed[1] ! concat('.', (@label, @index)[1])) },
                attribute location-group { ($location-group[1], $location-group[1])[1] ! (@xml:id, @id)[1] },
                ($location-group[1]/ancestor::tei:div[tei:head/@type = @type][1] | $location-group[1]/ancestor::m:part[tei:head/@type = @type][1])[1] ! attribute location-group-parent { (@xml:id, @id)[1] },
                attribute location-type { 
                    let $parent-node-name := local-name($node[1]/parent::tei:*)
                    return
                        if($node/ancestor::tei:lg) then
                            'line-group'
                        else if($parent-node-name eq 'p') then
                            'paragraph'
                        else if($parent-node-name eq 'head') then
                            'heading'
                        else
                            $parent-node-name
                },
                text {
                    replace(
                        replace(
                            replace(
                                string-join(
                                    $node ! 
                                        concat(
                                            if(parent::tei:head) then 
                                                replace(., '(^\s+|\s+$)', '') 
                                            else if(self::tei:ref) then 
                                                concat('[', @cRef, ']')
                                            else if(parent::tei:p | parent::tei:l) then 
                                                concat(., ' ')
                                            else ., 
                                            
                                            if(parent::tei:head) then 
                                                '. ' 
                                            else ()
                                        )
                                )
                            ,'[\r\n\t]', '')    (: Remove returns and tabs :)        
                        ,'\s+', ' ')            (: Condense other whitespace :) 
                    , '(^\s+|\s+$)', '')        (: Remove leading/trailing space :)
                }
            }
            
    }
};

local:parse-translation()



