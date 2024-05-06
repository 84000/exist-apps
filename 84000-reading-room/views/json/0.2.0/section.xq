xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace mjson = "http://json.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace json="http://www.json.org";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace common = "http://read.84000.co/common" at "../../../modules/common.xql";
import module namespace eft-json = "http://read.84000.co/json" at "../eft-json.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:response := request:get-data()/m:response;
declare variable $local:request := $local:response/m:request;
declare variable $local:section := $local:response/m:section;
declare variable $local:api-version := (request:get-attribute('api-version'),'0.2.0')[1];
declare variable $local:xhtml-xsl := doc(concat($common:app-path, "/xslt/tei-to-xhtml.xsl"));

declare function local:section($section as element(m:section)) as element(mjson:section) {
    element { QName('http://json.84000.co/ns/1.0', 'section') } {
    
        attribute id { $section/@id },
        attribute url { concat('/section/', $section/@id, '.json') },
        
        eft-json:titles($section/m:titles/m:title),
        
        if($section/m:abstract[*])then
            element abstract { 
                eft-json:tei-to-escaped-xhtml($section/m:abstract/*, $local:xhtml-xsl) 
            }
        else (),
        
        if($section/m:warning[*])then
            element warning { 
                eft-json:tei-to-escaped-xhtml($section/m:warning/*, $local:xhtml-xsl) 
            }
        else (),
        
        if($section/m:about[*])then
            element about { 
                eft-json:tei-to-escaped-xhtml($section/m:about/*, $local:xhtml-xsl)
            }
        else (),
        
        local:filters($section),
        local:stats($local:section//m:translation-summary[@section-id eq $section/@id]/m:publications-summary),
        eft-json:parent-sections($section/m:parent),
        local:child-texts($section/m:texts/m:text),
        local:child-sections($section/m:section)
        
    }
};

declare function local:stats($publications-summary as element(m:publications-summary)*) {
    
    for $type-element in ($publications-summary/m:texts, $publications-summary/m:pages)
    let $type := if(local-name($type-element) eq 'texts') then 'count' else 'sum-pages'
    
    for $grouping in ((:'text', :)'toh')
    for $grouping-element in $type-element[parent::*/@grouping eq $grouping]
    for $scope in ('children', 'descendant')
    for $scope-element in $grouping-element[parent::*/@scope eq $scope]
    
    let $scope-str := if($scope eq 'descendant') then 'descendants' else $scope
    
    for $stat in $scope-element/@*
    let $stat-name := local-name($stat)
    let $status := if($stat-name eq 'total') then 'text' else $stat-name
      
    where not($stat-name = ('sponsored', 'not-started'))
    return (
        element stat {
            element type { string-join(($type, $status, $scope-str), '-') },
            element value { 
                attribute json:literal {'true'},
                $stat/number()
            }
        },
        if($status eq 'in-translation') then
            element stat {
                element type { string-join(($type, 'in-progress', $scope-str), '-') },
                element value { 
                    attribute json:literal {'true'},
                    sum(($scope-element/@translated/number(), $scope-element/@in-translation/number()))
                }
            }
        else ()
    )
    
};

declare function local:child-sections($children as element(m:section)*) as element(mjson:section)* {
    for $child in $children
    order by xs:integer($child/@sort-index)
    return
        local:section($child)
};

declare function local:child-texts($texts as element(m:text)*) as element(mjson:text)* {
    for $text in $texts
    order by 
        xs:integer($text/m:toh/@number), 
        $text/m:toh/@letter, 
        if(functx:is-a-number($text/m:toh/@chapter-number)) then xs:integer($text/m:toh/@chapter-number) else 9999, 
        $text/m:toh/@chapter-letter
    
    return
        element { QName('http://json.84000.co/ns/1.0', 'text') } {
            
            attribute id { $text/@id },
            attribute key { $text/@resource-id },
            attribute translation-status { $text/@status-group },
            attribute canonical-html { $text/@canonical-html },
            
            eft-json:titles($text/m:titles/m:title),
            
            element title-variants { 
                eft-json:titles($text/m:title-variants/m:title) 
            },
            
            eft-json:copy-nodes($text/m:toh),
            eft-json:copy-nodes($text/m:source/m:location),
            eft-json:parent-sections($text/m:parent),
            
            $text/m:downloads/m:download[not(@type = ('rdf', 'cache'))],
            
            if($text/m:part[@type eq 'summary'][tei:p])then
                element summary { 
                    eft-json:tei-to-escaped-xhtml($text/m:part[@type eq 'summary']/tei:p, $local:xhtml-xsl) 
                }
            else ()
            
        }
};

declare function local:filters($section as element(m:section)) as element(mjson:filters)* {
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

element { QName('http://json.84000.co/ns/1.0', 'section-json') } {
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
