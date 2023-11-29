xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace eft="http://read.84000.co/ns/1.0";
declare namespace bcrd="http://www.bcrdb.org/ns/1.0";
declare namespace tmx="http://www.lisa.org/tmx14";

import module namespace common="http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "/db/apps/84000-reading-room/modules/translation.xql";
import module namespace source="http://read.84000.co/source" at "/db/apps/84000-reading-room/modules/source.xql";
import module namespace update-tm="http://operations.84000.co/update-tm" at "/db/apps/84000-operations/modules/update-tm.xql";
import module namespace levenshtein="http://read.84000.co/xquery-levenshtein-distance" at "/db/apps/84000-reading-room/modules/levenshtein.xql";
import module namespace ewts = "http://tbrc.org/xquery/ewts2unicode";
import module namespace functx="http://www.functx.com";

declare variable $local:toh-key := 'toh20';
declare variable $local:tei := tei-content:tei($local:toh-key, 'translation');
declare variable $local:text-id := tei-content:id($local:tei);
declare variable $local:levenshtein-tolerance := 5;

declare function local:tm-units($bcrd-sentences as element(bcrd:sentence)*){
    
    for $sentence in $bcrd-sentences
    return 
        element { QName('http://www.lisa.org/tmx14', 'tu') }{

            element { QName('http://www.lisa.org/tmx14', 'prop') }{
                attribute type { 'bcrd:s_id' },
                text { $sentence/@s_id }
            },

            element { QName('http://www.lisa.org/tmx14', 'prop') }{
                attribute type { 'bcrd:type' },
                text { $sentence/@type }
            },
            
            element { QName('http://www.lisa.org/tmx14', 'prop') }{
                attribute type { 'eft:wylie-key' },
                text { string-join($sentence/bcrd:phrase ! string-join(text()) ! normalize-space(.) ! replace(., '(&#10;|\+)', '') ! translate(., 'āīū', 'AIU'), ' ') ! replace(., '\s', '-') }
            }
            
        }
};

declare function local:etext-phrases($etext-pages as element(eft:page)*) as element(eft:etext-phrase)* {
    
    let $text-nodes := $etext-pages/eft:language[@xml:lang eq "bo"]/tei:p/node()[. instance of text() or self::tei:milestone[@unit eq 'text']]
    let $toh-key-number := replace($local:toh-key, '^toh', '')
    let $start-node := $text-nodes[self::tei:milestone][@toh ! xs:string(.) eq $toh-key-number]
    let $index-of-text-start := functx:index-of-node($text-nodes, $start-node)
    let $end-node := $text-nodes[self::tei:milestone][position() gt $index-of-text-start]
    let $index-of-text-end := $end-node ! functx:index-of-node($text-nodes, .)
    
    return (
    
        (:element debug { 
            attribute toh-key-number { $toh-key-number },
            attribute index-of-text-start { $index-of-text-start },
            attribute index-of-text-end { $index-of-text-end },
            $start-node,
            $end-node
        },:)
    
        for $text-node in $text-nodes
        let $index-in-text := functx:index-of-node($text-nodes, $text-node)
        let $parent-page := $text-node/ancestor::eft:page
        where
            $index-in-text gt $index-of-text-start
            and $index-in-text lt ($index-of-text-end, count($text-nodes))[1]
            and $text-node[. instance of text()]
        return
            for $token at $index-of-token in tokenize(string-join($text-node), '\s+')[not(. = ('༄༅།',''))] ! normalize-space(.)
            return
                element { QName('http://read.84000.co/ns/1.0','etext-phrase') } {
                    (:attribute position { $index-in-text },:)
                    attribute folio-volume { $parent-page/@volume },
                    attribute folio-page-in-volume { $parent-page/@page-in-volume },
                    attribute folio-index-in-text { $parent-page/@page-in-text },
                    attribute folio-etext-key { $parent-page/@folio-in-etext },
                    if($index-of-token eq 1 and (count(($parent-page/descendant::text())[1] | $text-node) eq 1 or $index-in-text eq $index-of-text-start + 1)) then
                        attribute folio-change { $parent-page/@folio-in-etext }
                    else (),
                    attribute wylie-key { replace($token, '(^(༄༅+)?(་)?།+|(་)?།+$)', '') ! ewts:toWylie(.) ! replace(., '(^\s+|\+|\s+$)', '') ! replace(., '\s', '-') },
                    text { $token }
                }
    )
};

declare function local:tmx-bo-segments($tm-units as element(tmx:tu)*, $tm-units-index as xs:integer, $etext-phrases as element(eft:etext-phrase)*, $text-version as xs:string?) as element(tmx:tu)* {
    
    if($tm-units-index le count($tm-units)) then (
    
        let $tm-unit := $tm-units[$tm-units-index]
        let $tm-unit-wylie-key := $tm-unit/tmx:prop[@type eq 'eft:wylie-key']
        let $tm-unit-phrases := local:tm-unit-phrases($tm-unit-wylie-key, $etext-phrases, 1)
        
        return (
        
            element { node-name($tm-unit) } {
                
                attribute id { concat($local:text-id, '-TU-', $tm-units-index)},
                
                $text-version ! (
                    common:ws(3),
                    element { QName('http://www.lisa.org/tmx14', 'prop') }{
                        attribute type { 'revision' },
                        text { . }
                    }
                ),
                
                (: Values from segment :)
                $tm-unit/@*,
                for $element in $tm-unit/*[@type = ('bcrd:s_id', 'bcrd:type')]
                return (
                    common:ws(3),
                    $element
                ),
                
                (:  Values from etext :)
                if($tm-unit-phrases) then (
                    
                    distinct-values($tm-unit-phrases/@folio-index-in-text) ! (
                        common:ws(3),
                        element { QName('http://www.lisa.org/tmx14', 'prop') }{
                            attribute type { 'folio-index' },
                            text { . }
                        }
                    ),
                    distinct-values($tm-unit-phrases/@folio-etext-key) ! (
                        common:ws(3),
                        element { QName('http://www.lisa.org/tmx14', 'prop') }{
                            attribute type { 'folio-label' },
                            text { . }
                        }
                    ),
                    
                    common:ws(3),
                    element tuv {
                        attribute xml:lang { 'bo' },
                        (:attribute debug { string-join($tm-unit-phrases/@wylie-key, '-') },:)
                        (:attribute debug { levenshtein:levenshtein-distance($etext-phrases[1]/@wylie-key, 'd--' || substring($tm-unit-wylie-key, 1, string-length($etext-phrases[1]/@wylie-key)) || 'sdff') div string-length($tm-unit-wylie-key) },:)
                        element seg { string-join($tm-unit-phrases ! concat(@folio-change ! concat('{{folio:', string(),'}}'), text()), ' ') }
                    }
                    
                )
                else ()
                ,
                common:ws(2)
            },
            
            local:tmx-bo-segments($tm-units, $tm-units-index + 1, subsequence($etext-phrases, count($tm-unit-phrases) + 1), $text-version)
            
        )
        
    )
    else ()
};

declare function local:tm-unit-phrases($tm-unit-wylie-key, $etext-phrases as element(eft:etext-phrase)*, $etext-phrases-index as xs:integer)  as element(eft:etext-phrase)* {
     if($etext-phrases-index le count($etext-phrases) and string-length($tm-unit-wylie-key) gt 0) then (
        let $etext-phrase := $etext-phrases[$etext-phrases-index]
        let $etext-phrase-wylie-key := $etext-phrase/@wylie-key
        let $etext-phrase-regex := concat('^(\-)?', functx:escape-for-regex($etext-phrase-wylie-key), '(\-)?')
        return
            if(matches($tm-unit-wylie-key, $etext-phrase-regex, 'i')) then (
                $etext-phrase,
                local:tm-unit-phrases(replace($tm-unit-wylie-key, $etext-phrase-regex, '', 'i'), $etext-phrases, $etext-phrases-index + 1)
            )
            else if(levenshtein:levenshtein-distance($etext-phrase-wylie-key, substring($tm-unit-wylie-key, 1, string-length($etext-phrase-wylie-key))) le $local:levenshtein-tolerance) then (
                $etext-phrase,
                local:tm-unit-phrases(substring($tm-unit-wylie-key, string-length($etext-phrase-wylie-key) + 1), $etext-phrases, $etext-phrases-index + 1)
            )
            else ()
     )
     else ()
};

let $text-version := tei-content:version-str($local:tei)
let $tei-location := translation:location($local:tei, $local:toh-key)
let $etext := source:etext-full($tei-location)

let $text-refs := doc(concat($common:data-path, '/config/linked-data/text-refs.xml'))
let $bcrd-ref := $text-refs//eft:text[@key eq $local:toh-key]/eft:ref[@type eq 'bcrd-resource']
let $bcrd-resource-path := concat('/db/apps/84000-data/BCRDCORPUS/', $bcrd-ref/@value, '.xml')
let $bcrd-resource := doc($bcrd-resource-path)

(:return if(true()) then $etext/eft:page/eft:language[@xml:lang eq "bo"]/tei:p/node()[. instance of text() or self::tei:milestone[@unit eq 'text']] ! concat('[', position(), ']', .) else :)

let $tm-units := local:tm-units($bcrd-resource//bcrd:sentence)
let $etext-phrases := local:etext-phrases($etext/eft:page)

let $tmx-bo-segments := local:tmx-bo-segments($tm-units, 1, $etext-phrases, $text-version)

let $tmx := 
    element { QName('http://www.lisa.org/tmx14', 'tmx') } {
        
        namespace {'eft'} {'http://read.84000.co/ns/1.0'},
        namespace {'tei'} {'http://www.tei-c.org/ns/1.0'},
        namespace {'bcrd'} {'http://www.bcrdb.org/ns/1.0'},
        
        attribute version { '1.4b' },
        common:ws(1),
        element header {
            attribute creationtool { '84000-tm-editor' },
            attribute creationtoolversion { $common:app-version },
            attribute datatype { 'PlainText' },
            attribute segtype { 'block' },
            attribute adminlang { 'en-us' },
            attribute srclang { 'bo' },
            attribute eft:text-id { $local:text-id },
            attribute eft:text-version { ($text-version, 'undefined') },
            attribute eft:source-ref { $etext/eft:page[1]/@etext-id }
        },
        common:ws(1),
        element body {
            for $tmx-bo-segment in $tmx-bo-segments
            return (
                common:ws(2),
                $tmx-bo-segment
            ),
            common:ws(1)
        },
        common:ws(0)
    }

let $filename := concat(update-tm:filename($local:tei, ''), '.tmx')

return (
    (:$etext,:)
    (:$etext-phrases,:)
    $tmx,
    update-tm:store-tmx($tmx, $filename)
)