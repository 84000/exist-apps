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

declare variable $xhtml-xsl := doc(concat($common:app-path, "/xslt/tei-to-xhtml.xsl"));

declare function local:simple-paragraphs($paragraphs as element()*) as element()* {
    for $paragraph in $paragraphs/*
    return
        if($paragraph[text()[normalize-space()]]) then
            element {
                if(local-name($paragraph) = ('head')) then
                    local-name($paragraph)
                else
                    'paragraph'
                
            } { $paragraph/data() }
        else
            local:simple-paragraphs($paragraph)
};

declare function local:section($section as element()*) as element()* {
    element section {
        attribute id { $section/@id },
        attribute url { concat('/section/', $section/@id, '.json') },
        eft-json:titles($section/m:titles/m:title),
        <abstract>{ eft-json:tei-to-escaped-xhtml($section/m:abstract/*, $xhtml-xsl) }</abstract>,
        <warning>{ eft-json:tei-to-escaped-xhtml($section/m:warning/*, $xhtml-xsl) }</warning>,
        if($section/m:about)then
            <about>{ eft-json:tei-to-escaped-xhtml($section/m:about/*, $xhtml-xsl) }</about>
        else
            (),
        local:stats($section/m:text-stats/m:stat),
        eft-json:parent-sections($section/m:parent),
        local:child-texts($section/m:texts/m:text),
        local:child-sections($section/m:section)
    }
};

declare function local:child-sections($children as element()*) as element()* {
    for $child in $children
    order by xs:integer($child/@sort-index)
    return
        local:section($child)
};

declare function local:stats($stats as element()*) {
    for $stat in $stats
    return
        element { 'stat' } {
            element { $stat/@type } {
                attribute json:literal {'true'},
                $stat/@value/number()
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
            attribute id { $text/@resource-id },
            attribute translation-status { $text/@status-group },
            attribute canonical-html { $text/@canonical-html },
            eft-json:titles($text/m:titles/m:title),
            <title-variants>{ eft-json:titles($text/m:title-variants/m:title) }</title-variants>,
            $text/m:toh,
            eft-json:parent-sections($text/m:parent),
            $text/m:downloads/m:download[not(@type = ('rdf', 'cache'))],
            if($text/m:part[@type eq 'summary'][tei:p])then
                <summary>{ eft-json:tei-to-escaped-xhtml($text/m:part[@type eq 'summary']/tei:p, $xhtml-xsl) }</summary>
            else ()
        }
};

let $response := request:get-data()/m:response
let $request := $response/m:request
let $section := $response/m:section
let $api-version := '0.1.0'

return
    <section>
    {
        attribute api-version { $api-version },
        attribute url { 
            concat(
                '/section/', $section/@id, '.json',
                '?published-only=', xs:boolean($request/@published-only),
                '&amp;child-texts-only=', xs:boolean($request/@child-texts-only),
                '&amp;api-version=', $api-version
            ) 
       },
        local:section($section)
    }
    </section>
   
    