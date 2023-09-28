xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace json="http://www.json.org";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace common = "http://read.84000.co/common" at "../../modules/common.xql";
import module namespace eft-json = "http://read.84000.co/json" at "eft-json.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:response := request:get-data()/m:response;
declare variable $local:request := $local:response/m:request;
declare variable $local:section := $local:response/m:section;
declare variable $local:environment := $local:response/m:environment;
declare variable $local:api-version := '0.3.0';
declare variable $local:xhtml-xsl := doc(concat($common:app-path, "/xslt/tei-to-xhtml.xsl"));

declare function local:section($section as element()*) as element()* {
    element section {
    
        attribute id { $section/@id },
        attribute url { concat('/section/', $section/@id, '.json') },
        
        if($section/m:page[@kb-id] and $local:environment/m:render/m:status[@type eq 'article'][@status-id eq $section/m:page/@status]) then
            attribute article-url { concat($local:environment/m:url[@id eq 'reading-room'], '/knowledgebase/', $section/m:page/@kb-id, '.html') }
        else (),
        
        eft-json:titles($section/m:titles/m:title),
        
        $section/m:abstract ! <abstract>{ eft-json:tei-to-escaped-xhtml(*, $local:xhtml-xsl) }</abstract>,
        $section/m:warning ! <warning>{ eft-json:tei-to-escaped-xhtml(*, $local:xhtml-xsl) }</warning>,
        $section/m:about ! <about>{ eft-json:tei-to-escaped-xhtml(*, $local:xhtml-xsl) }</about>,
        
        local:filters($section),
        local:stats($local:section//m:translation-summary[@section-id eq $section/@id]/m:publications-summary),
        
        local:child-texts($section/m:texts/m:text),
        local:child-sections($section/m:section),
        eft-json:parent-sections($section/m:parent)
        
    }
};

declare function local:child-sections($children as element()*) as element()* {
    for $child in $children
    order by xs:integer($child/@sort-index)
    return
        local:section($child)
};

declare function local:stats($groups as element(m:publications-summary)*) {
    for $stat in $groups/*
    return
        element { 'stat' } {
            attribute count-of { $stat ! local-name(.) },
            $stat/parent::*/@*,
            element { 'values' } {
                for $value in $stat/@*
                return
                  element { $value ! local-name(.) } {
                      attribute json:literal {'true'},
                      $value/number()
                  }
           }
        }
};

declare function local:child-texts($texts as element()*) {
    for $text in $texts
    order by 
        xs:integer($text/m:toh/@number), 
        $text/m:toh/@letter, 
        if(functx:is-a-number($text/m:toh/@chapter-number)) then xs:integer($text/m:toh/@chapter-number) else 9999, 
        $text/m:toh/@chapter-letter
    return
        element { 'text' } {
        
            attribute id { $text/@id },
            attribute key { $text/@resource-id },
            attribute translation-status { $text/@status-group },
            attribute canonical-html { $text/@canonical-html },
            
            eft-json:titles($text/m:titles/m:title),
            
            element title-variants { 
                eft-json:titles($text/m:title-variants/m:title) 
            },
            
            $text/m:toh,
            
            $text/m:downloads/m:download[not(@type = ('rdf', 'cache'))],
            
            if($text/m:part[@type eq 'summary'][tei:p])then
                element summary { 
                    eft-json:tei-to-escaped-xhtml($text/m:part[@type eq 'summary']/tei:p, $local:xhtml-xsl) 
                }
            else ()
            ,
            
            eft-json:parent-sections($text/m:parent)
            
        }
};

declare function local:filters($section as element(m:section)) as element(m:filters)* {
    for $group in $section/m:filters/tei:div[@type eq "filter"][@xml:id][m:display]
    return
        element { QName('http://json.84000.co/ns/1.0', 'group') } {
            attribute id { $group/@xml:id },
            element label {
                $group/tei:head/data()
            },
            element description {
                eft-json:tei-to-escaped-xhtml($group/tei:p, $local:xhtml-xsl) 
            },
            eft-json:copy-nodes($group/m:filter)
        }
};

element { 'section' } {
    attribute api-version { $local:api-version },
    attribute url { 
        concat(
            '/section/', $local:section/@id, '.json',
            '?published-only=', xs:boolean($local:request/@published-only),
            '&amp;child-texts-only=', xs:boolean($local:request/@child-texts-only),
            '&amp;api-version=', $local:api-version
        )
    },
    local:section($local:section)
}
   
    