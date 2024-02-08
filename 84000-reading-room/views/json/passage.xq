xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";

import module namespace common = "http://read.84000.co/common" at "../../modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../modules/tei-content.xql";
import module namespace eft-json = "http://read.84000.co/json" at "eft-json.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:api-version := '0.1.0';
declare variable $local:response := request:get-data()/m:response;
declare variable $local:translation := $local:response/m:translation;
declare variable $local:text-id := $local:response/m:translation/@id;
declare variable $local:toh-key := $local:translation/m:source/@key;
declare variable $local:passage-id := $local:response/m:request/@passage-id;
declare variable $local:xslt := doc(concat($common:app-path, "/xslt/tei-to-xhtml.xsl"));

declare function local:parse-nodes($nodes as node()*) as node()* {
    for $node in $nodes
    return (
    
        if(functx:node-kind($node) eq 'text') then
            $node[normalize-space(.) gt ''] ! element value { . }
        
        else
            element { local-name($node) } {
                for $attr in $node/@*
                return
                    element { local-name($attr) } {
                        if(functx:is-a-number($attr/string())) then
                            attribute json:literal {'true'}
                        else ()
                        ,
                        $attr/string()
                    }
                ,
                if($node[node()]) then
                    if($node[node()[not(functx:node-kind(.) eq 'text')]]) then
                        local:parse-nodes($node/node())
                    else
                        string-join($node/node()) ! normalize-space(.) ! element value { . }
                else ()
            }
        ,
        
        let $parse-nodes :=
            if($node[parent::tei:note[@type eq 'definition'][not(@rend eq 'override')]]) then
                $node[node()]
            else ()
        
        let $parse-xml :=
            if($parse-nodes) then
                element { node-name($local:response) } {
                    $local:response/@*,
                    element part {
                        attribute id { $node/ancestor-or-self::*[@xml:id][1]/@xml:id },
                        attribute type { 'apply-templates' },
                        attribute glossarize { 'mark' },
                        $parse-nodes
                    },
                    $local:response/*
                }
            else ()
        
        where $parse-xml
        return (
            (:$parse-xml,:)
            (:$parse-xml/m:part[@type eq 'apply-templates'],:)
            (:$parse-xml/m:translation/m:part[@type eq 'glossary'],:)
            transform:transform($parse-xml, $local:xslt, <parameters/>) ! element html-content {serialize(.)}
        )
        
    )
};

declare function local:parse-passage() {

    element response {

        attribute api-version { $local:api-version },
        attribute url { concat('/passage/', $local:translation/m:source/@key,'.json?passage-id=', $local:passage-id, '&amp;api-version=', $local:api-version) },
        attribute text-id { $local:translation/@id },
        attribute toh-key { $local:toh-key },
        attribute text-version { tei-content:strip-version-number($local:translation/m:publication/m:edition/text()[1]) },
        attribute html { concat('/passage/', $local:translation/m:source/@key,'.html?passage-id=', $local:passage-id) },
        
        (:$local:response/m:request,:)
        
        $local:translation/id($local:passage-id) ! local:parse-nodes(.)
        
    }
};

local:parse-passage()