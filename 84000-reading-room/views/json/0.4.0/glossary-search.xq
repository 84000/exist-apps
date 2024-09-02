xquery version "3.0";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";

import module namespace common = "http://read.84000.co/common" at "../../../modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../../modules/tei-content.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../../modules/translation.xql";
import module namespace glossary = "http://read.84000.co/glossary" at "../../../modules/glossary.xql";
import module namespace entities = "http://read.84000.co/entities" at "../../../modules/entities.xql";
import module namespace devanagari = "http://read.84000.co/devanagari" at "../../../modules/devanagari.xql";
import module namespace eft-json = "http://read.84000.co/json" at "../eft-json.xql";
import module namespace json-types = "http://read.84000.co/json-types" at "../types.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

(:
    Edge cases:
:)

declare variable $has-request := if(request:exists()) then 'request' else ();
declare variable $local:api-version :=    ($has-request ! request:get-attribute('api-version')[. gt ''],                                              '0.4.0')[1];
declare variable $local:input-string :=   ($has-request ! request:get-parameter('search', '')[. gt ''],                                               'Emptiness')[1];
declare variable $local:input-lang :=     ($has-request ! request:get-parameter('lang', '')[. = ('en','bo','Sa-Ltn')],                                'en')[1];
declare variable $local:result-page :=    ($has-request ! request:get-parameter('page', 1)[functx:is-a-number(.)] ! xs:integer(.) ! abs(.),            1)[1];
declare variable $local:items-per-page := ($has-request ! request:get-parameter('items-per-page', 10)[functx:is-a-number(.)] ! xs:integer(.) ! abs(.), 10)[1];

declare function local:search() as element()* {

    (: Transliterate :)
    let $search-string := 
        if(lower-case($local:input-lang) eq 'bo' and not(common:string-is-bo($local:input-string))) then
            common:bo-from-wylie($local:input-string)
        else if(lower-case($local:input-lang) eq 'sa-ltn' and devanagari:string-is-dev($local:input-string)) then
            devanagari:to-iast($local:input-string)
        else
            $local:input-string
    
    (: Normalize :)
    let $search-string := 
        if(lower-case($local:input-lang) eq 'en') then
            lower-case($search-string) ! common:normalized-chars(.) ! replace(., '\-', ' ')
        else if(lower-case($local:input-lang) eq 'sa-ltn') then
            lower-case($search-string) ! replace(., 'sh', 'ś', 'i') ! common:normalized-chars(.) ! common:alphanumeric(.)
        else
            common:normalized-chars($search-string)

    
    (: Select TEI glossaries :)
    let $glossaries := $glossary:tei//tei:back/tei:div[@type eq 'glossary'][not(@status = 'excluded')]
    
    let $field := 
        if($local:input-lang eq 'bo') then 'bo-terms'
        else 'full-terms'
    
    (:let $search-regex := 
        if($local:input-lang eq 'bo') then
            string-join(tokenize($search-string, '\s+(།\s*)?')[normalize-space(.)] ! normalize-space(.) ! replace(., '(^་|་$|&#8203;)', ''), ' OR ')
        else
            functx:escape-for-regex($search-string):)
    
    (: Select matching terms :)
    let $matching-terms :=
        if(lower-case($local:input-lang) eq 'bo') then
            $glossaries//tei:gloss/tei:term[@xml:lang eq 'bo'][ft:query(., concat($field, ':(', $search-string, ')'), map { "fields": ($field) })]
        else if(lower-case($local:input-lang) eq 'sa-ltn') then
            $glossaries//tei:gloss/tei:term[@xml:lang eq 'Sa-Ltn'][ft:query(., concat($field, ':(', $search-string, ')'), map { "fields": ($field) })]
        else
            $glossaries//tei:gloss/tei:term[not(@type eq 'translationAlternative')][not(@xml:lang)][ft:query(., concat($field, ':(', $search-string, ')'), map { "fields": ($field) })]
    
    (: Select parent glosses :)
    let $glosses := $matching-terms/parent::tei:gloss[@xml:id][not(@mode eq 'surfeit')]
    
    (: Select entities :)
    let $matching-instances := $entities:entities//eft:instance[@id = $glosses/@xml:id][not(eft:flag[@type eq 'requires-attention'])]
    let $entities := 
        for $matching-instance in $matching-instances | $matching-instances
        let $entity := $matching-instance/parent::eft:entity
        let $entity-id := $entity/@xml:id
        group by $entity-id
            let $matching-instance-count := count($matching-instance)
            order by $matching-instance-count descending
            return
                $entity[1]

    (: Select subset of enities :)
    let $start-item := (($local:result-page - 1) * $local:items-per-page) + 1
    let $end-item := $start-item + ($local:items-per-page - 1)
    let $count-items := count($entities)
    let $count-pages := ceiling($count-items div $local:items-per-page)
    let $entities := subsequence($entities, $start-item, $local:items-per-page)
    
    return 
        element results {
            
            element itemsCount { attribute json:literal { true() }, $count-items },
            element pagesCount { attribute json:literal { true() }, $count-pages },
            element searchString { $search-string },
            
            for $entity at $index in $entities
            (: Parse all the glosses related to this entity :)
            let $entity-glosses :=
                for $instance in $entity/eft:instance
                let $gloss := $glosses/id($instance/@id)
                let $gloss-tei := $gloss/ancestor::tei:TEI
                where $gloss-tei
                let $text-id := tei-content:id($gloss-tei)
                return
                    element gloss {
                    
                        attribute json:array { true() },
                        
                        $gloss/@*,
                        
                        attribute text-id { $text-id },
                        
                        for $term in $gloss/tei:term[normalize-space(text())][not(@type eq 'translationAlternative')]
                        let $matching-term := $matching-terms[. is $term]
                        let $matching-term-index := $matching-term ! functx:index-of-node($matching-terms, .)
                        let $term-value := string-join($term/text()) ! normalize-space(.) 
                        where $term-value
                        return
                            element term {
                            
                                $term/@*,
                                
                                $matching-term-index ! attribute matching-term-index { $matching-term-index },
                                
                                element value { $term-value }
                                
                            }
                        (:,
                        
                        $gloss/tei:note[@type eq 'definition'] ! element definition { @rend, string-join(tei:p ! string-join(text()) ! normalize-space(.), ' ') ! element value { . } },
                        
                        $gloss-tei ! tei-content:titles-all(.),
                        
                        for $source-key in $gloss-tei//tei:sourceDesc/tei:bibl/@key
                        return
                            translation:toh($gloss-tei, $source-key):)
                        
                    }
            
            return 
                element item {
                
                    attribute json:array { true() },
                    
                    for $lang in ('En', 'Bo', 'Sa')
                    let $lang-terms := 
                        if($lang eq 'Sa') then
                            $entity-glosses/term[@xml:lang eq 'Sa-Ltn']
                        else if($lang eq 'Bo') then
                            $entity-glosses/term[@xml:lang eq 'bo']
                        else 
                            $entity-glosses/term[not(@xml:lang)]
                    
                    return
                        for $term in $lang-terms
                        let $term-text := $term/value/text()
                        let $text-id := $term/parent::gloss/@text-id/string()
                        group by $term-text
                        let $term-1 := $term[1]
                        let $matching-term := $term-1[@matching-term-index] ! $matching-terms[$term-1/@matching-term-index ! xs:integer(.)]
                        return
                            element { concat('term', $lang) } {
                                attribute json:array { true() },
                                $term-1/value,
                                if($matching-term) then
                                    element match { string-join( ft:highlight-field-matches($matching-term, $field)/node() ! (if(self::exist:match) then element mark { node() } else .) ! serialize(.) ) ! normalize-space(.) }
                                else ()
                                
                            }
                    ,
                    
                    element entity {
                        $entity/@xml:id ! attribute xmlId { string() },
                        element label { ($entity/eft:label[@xml:lang eq 'en'],$entity/eft:label)[1] ! string-join(text()) ! normalize-space(.) },
                        element countTexts { attribute json:literal { true() }, count(distinct-values($entity-glosses/@text-id)) },
                        $entity/eft:content[@type eq 'glossary-definition'] ! element definition { attribute rend { 'shared' }, string-join(descendant::text()) ! normalize-space(.) ! element value { . } }(:,
                        $glosses:)
                    }
                    
                }
            
        }
};

element glossary-search {

    attribute modelType { 'glossary-search' },
    attribute apiVersion { $local:api-version },
    attribute search { $local:input-string },
    attribute lang { $local:input-lang },
    element page { attribute json:literal { true() }, $local:result-page },
    element itemsPerPage { attribute json:literal { true() }, $local:items-per-page },
    element url { concat('/glossary/search.json?', string-join(('api-version=' || $local:api-version, 'search=' || $local:input-string, 'lang=' || $local:input-lang, 'page=' || $local:result-page, 'items-per-page=' || $local:items-per-page), '&amp;')) },
    
    local:search()
    
}
