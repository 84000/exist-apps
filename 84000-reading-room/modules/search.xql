xquery version "3.1" encoding "UTF-8";
(:
    Accepts the search parameter
    Returns search items xml
    --------------------------------------------------------
:)
module namespace search="http://read.84000.co/search";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace eft="http://read.84000.co/ns/1.0";
declare namespace tmx="http://www.lisa.org/tmx14";
declare namespace exist="http://exist.sourceforge.net/NS/exist";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";
import module namespace knowledgebase="http://read.84000.co/knowledgebase" at "knowledgebase.xql";
import module namespace entities="http://read.84000.co/entities" at "entities.xql";
import module namespace devanagari="http://read.84000.co/devanagari" at "devanagari.xql";
import module namespace kwic="http://exist-db.org/xquery/kwic";
import module namespace functx="http://www.functx.com";

declare variable $search:data-types := 
    <search-data xmlns="http://read.84000.co/ns/1.0">
        <type id="translations">Translations</type>
        <type id="knowledgebase">Knowledge Base</type>
        <type id="glossary">Glossary</type>
    </search-data>;

declare function search:search($search as xs:string, $first-record as xs:double, $max-records as xs:double) as element() {

    search:search($search, $search:data-types/m:type, '', $first-record, $max-records)
    
};

declare function search:search($search as xs:string, $data-types as element(m:type)*, $resource-id as xs:string, $first-record as xs:integer, $max-records as xs:integer) as element(m:tei-search) {
    
    (: Search translations, sections, knowledgebase and shared definitions :)
    let $translations-tei := collection($common:translations-path)//tei:TEI
    let $knowledgebase-tei := collection($common:knowledgebase-path)//tei:TEI
    let $sections-tei := collection($common:sections-path)//tei:TEI
    
    let $translation-render-status := $common:environment/m:render/m:status[@type eq 'translation']/@status-id
    let $article-render-status := $common:environment/m:render/m:status[@type eq 'article']/@status-id
    
    let $single-tei :=
        if($resource-id gt '') then
            tei-content:tei($resource-id, 'translation')
        else ()
    
    let $single-tei-type := 
        if($single-tei) then
            tei-content:type($single-tei)
        else ()
    
    let $single-render-status :=
        if($single-tei-type eq 'knowledgebase') then 
            $article-render-status
        else 
            $translation-render-status
    
    let $data-types-excluded := if($single-tei) then 'glossary' else ()
    let $data-types := $data-types[not(@id eq $data-types-excluded)]
    
    let $all := 
        if($single-tei) then
            $single-tei
        else (
            if($data-types[@id = ('translations','glossary')]) then
                $translations-tei
            else ()
            ,
            if($data-types[@id eq 'knowledgebase']) then (
                $knowledgebase-tei[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/@status = $article-render-status]
                | $sections-tei
            )
            else ()
        )
    
    let $published := 
        if($single-tei) then
            $single-tei[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/@status = $single-render-status]
        else (
            if($data-types[@id = ('translations','glossary')]) then
                $translations-tei[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/@status = $translation-render-status]
            else ()
            ,
            if($data-types[@id eq 'knowledgebase']) then (
                $knowledgebase-tei[tei:teiHeader/tei:fileDesc/tei:publicationStmt[tei:idno/@type = 'eft-kb-id'][tei:availability/@status = $article-render-status]]
                | $sections-tei[tei:teiHeader/tei:fileDesc/tei:publicationStmt[tei:idno/@type = 'eft-kb-id'][tei:availability/@status = $article-render-status]]
            )
            else ()
        )
    
    let $entities-definitions :=
        if(not($single-tei)) then
            $entities:entities//m:entity/m:content[@type eq 'glossary-definition']
        else ()
    
    let $options :=
        <options>
            <default-operator>or</default-operator>
            <phrase-slop>30</phrase-slop>
            <leading-wildcard>no</leading-wildcard>
            <filter-rewrite>yes</filter-rewrite>
        </options>
    
    (: Check the request to see if it's a phrase :)
    let $search-is-phrase := matches($search, '^\s*["“].+["”]\s*$')
    let $search-no-quotes := replace($search, '("|“|”|''|/)', '')
    (:let $search-is-bo := common:string-is-bo($search):)
    let $search-no-quotes :=
        if(devanagari:string-is-dev($search)) then
            devanagari:to-iast($search)
        else
            $search-no-quotes
    
    let $query := local:search-query($search-no-quotes, $search-is-phrase)
    
    (: All results from all sources :)
    let $results := (
        if($data-types[@id = ('translations','knowledgebase')]) then (
            (: Header content :)
            $all/tei:teiHeader/tei:fileDesc//tei:title[not(@xml:lang = ('bo', 'Sa-Ltn'))][ft:query(., $query, $options)]
            | $all/tei:teiHeader/tei:fileDesc//tei:title[ft:query(., concat('bo-titles:(', $search-no-quotes, ')'), map { "fields": ("bo-titles") })]
            | $all/tei:teiHeader/tei:fileDesc//tei:title[ft:query(., concat('sa-titles:(', $search-no-quotes, ')'), map { "fields": ("sa-titles") })]
            | $all/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key][ft:query(., $query, $options)]
            | $all/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[ft:query(., $query, $options)]
            ,
            (: Text content :)
            $published/tei:text//tei:p[ft:query(., $query, $options)][not(parent::tei:note[@type eq 'definition'])][not(@rend eq 'default-text')]
            | $published/tei:text//tei:label[ft:query(., $query, $options)]
            | $published/tei:text//tei:table[ft:query(., $query, $options)]
            | $published/tei:text//tei:head[ft:query(., $query, $options)]
            | $published/tei:text//tei:lg[ft:query(., $query, $options)]
            (: For now force tei:item/tei:p :)
            (:| $published/tei:text//tei:item[ft:query(., $query, $options)]:)
            | $published/tei:text//tei:ab[ft:query(., $query, $options)]
            | $published/tei:text//tei:trailer[ft:query(., $query, $options)]
            (: Back content :)
            | $published/tei:text/tei:back//tei:bibl[@key][ft:query(., $query, $options)][@xml:id][not(@rend eq 'default-text')]
        )
        else ()
        ,
        if($data-types[@id = ('translations','glossary')]) then (
            $published//tei:div[@type eq 'glossary'][not(@status eq 'excluded')]//tei:gloss/tei:term[not(@xml:lang = ('bo', 'Sa-Ltn'))][ft:query(., $query, $options)][parent::tei:gloss[not(@mode eq 'surfeit')]]
            | $published//tei:div[@type eq 'glossary'][not(@status eq 'excluded')]//tei:gloss/tei:term[ft:query(., concat('bo-terms:(', $search-no-quotes, ')'), map { "fields": ("bo-terms") })][parent::tei:gloss[not(@mode eq 'surfeit')]]
            | $published//tei:div[@type eq 'glossary'][not(@status eq 'excluded')]//tei:gloss/tei:term[ft:query(., concat('sa-terms:(', $search-no-quotes, ')'), map { "fields": ("sa-terms") })][parent::tei:gloss[not(@mode eq 'surfeit')]]
            | $published//tei:div[@type eq 'glossary'][not(@status eq 'excluded')]//tei:gloss/tei:note[ft:query(tei:p, $query, $options)][@type eq 'definition'][not(@rend eq 'override')][parent::tei:gloss[not(@mode eq 'surfeit')]]
        )
        else ()
        ,
        if($data-types[@id  eq 'glossary']) then
            $entities-definitions[ft:query(., $query, $options)]
        else ()
    )
    
    let $results-count := count($results)
    
    let $max-matches := 200
    
    let $results-triaged := 
        if($results-count gt $max-matches) then
            let $results-sorted := fn:sort($results, (), function($item) {-ft:score($item)})
            return
                subsequence($results, 1, $max-matches)
        else
            $results
    
    let $results-grouped := local:result-groups($results-triaged,(), $data-types, $first-record, $max-records, $max-matches, $search)
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'tei-search') } { 
            
            element request { 
                $single-tei ! local:result-header(.),
                element search { $search },
                $data-types,
                $query,
                $options
            },
            
            element results {
                
                attribute first-record { $first-record },
                attribute max-records { $max-records },
                attribute count-records { count($results-grouped) },
                attribute count-matches-all { $results-count },
                attribute count-matches-processed { count($results-triaged) },
                
                $results-grouped[descendant::m:match]
                    
            }
            
        }
    
};

declare function local:result-groups($results as element()*, $result-groups as element()*, $data-types as element(m:type)*, $first-record as xs:integer, $max-records as xs:integer, $max-matches as xs:integer, $search as xs:string) as element()* {
    
    let $result-groups-count := count($result-groups)
    let $end-record := $first-record + ($max-records - 1)
    
    return
    if(not($results)) then
        $result-groups
    
    else
    
        (: Sort by score :)
        let $results-sorted := fn:sort($results, (), function($item) {-ft:score($item)})
        
        let $result-top := $results-sorted[1]
        
        let $group := 
            if($result-top[parent::m:entity]) then
                $result-top/parent::m:entity[1]
            else if($data-types[@id eq 'glossary'] and $result-top[parent::tei:gloss][@xml:id]) then
                $entities:entities//m:instance[@id = $result-top/parent::tei:gloss/@xml:id]/parent::m:entity[1]
            else
                $result-top/ancestor::tei:TEI
        
        (: Get results in this group :)
        let $results-in-group := 
            if($group[self::m:entity]) then
                ($results-sorted[parent::m:entity][count(parent::m:entity[1] | $group) eq 1] | $results-sorted[parent::tei:gloss/@xml:id = $group/m:instance/@id])
            else
                $results-sorted[ancestor::tei:TEI][count(ancestor::tei:TEI[1] | $group) eq 1]
        
        (: Get results not in this group :)
        let $results-not-in-group := $results-sorted except $results-in-group
        
        let $result-group-index := $result-groups-count + 1
        
        let $result-group :=
            element { QName('http://read.84000.co/ns/1.0', 'result') } { 
                
                attribute index { $result-group-index },
                
                if($result-group-index ge $first-record and $result-group-index le $end-record) then 
                
                    let $results-in-group-sorted := fn:sort($results-in-group, (), function($item) {-ft:score($item)})
                    
                    let $group-header := local:result-header($group)
                    
                    let $boost := 
                        if($group-header[@type eq 'entity']) then 1.5
                        else 1
                    
                    (: Show all results (max 1000) if this is the only group :)
                    let $max-matches :=
                        if($results-not-in-group) then 10
                        else $max-matches
                    
                    let $matches :=
                        
                        for $result-in-group in subsequence($results-in-group-sorted, 1, $max-matches)
                        
                        (: Get nearest id - required :)
                        let $nearest-id := 
                            if($group-header[not(@type eq 'entity')]) then
                                if($result-in-group/ancestor::tei:fileDesc) then
                                    if($result-in-group[self::tei:title] and $result-in-group[not(@type eq 'mainTitle')]) then 'other-titles'
                                    else if($result-in-group[self::tei:title]) then 'titles'
                                    else if($result-in-group[self::tei:author][@role]) then 'other-authors'
                                    else 'authors'
                                else if($result-in-group[parent::tei:gloss[@xml:id]]) then
                                    $result-in-group/parent::tei:gloss/@xml:id
                                else
                                    $result-in-group/ancestor-or-self::*[not(@xml:id)][preceding-sibling::tei:milestone[@xml:id]][1]/preceding-sibling::tei:milestone[@xml:id][1]/@xml:id
                            else 
                                $result-in-group/ancestor-or-self::*[@xml:id][1]/@xml:id
                        
                        let $nearest-id := 
                            if(not($nearest-id)) then
                                ($result-in-group/ancestor-or-self::*[@xml:id][1]/@xml:id, $result-in-group/ancestor-or-self::tei:div[@type][1]/@type)[1] 
                            else 
                                $nearest-id
                        
                        (: Get score :)
                        let $score := ft:score($result-in-group)[. gt 0] * $boost
                        
                        where $nearest-id
                        group by $nearest-id
                        order by max($score) descending
                        
                        return
                            element match {
                                attribute score { max($score) },
                                attribute nearest-id { $nearest-id },
                                attribute link { local:match-link($result-in-group[1], $nearest-id[1], $group-header) },
                                if($result-in-group[1][parent::tei:gloss[@xml:id]]) then
                                    $result-in-group[1]/parent::tei:gloss[@xml:id] ! common:mark-nodes(., $search, 'words')
                                else
                                    $result-in-group ! common:mark-nodes(., $search, 'words')
                            }
                    
                    return (
                    
                        attribute type { $group-header/@type },
                        attribute score { ft:score($result-top) * $boost },
                        attribute count-matches { count($matches) },
                        
                        $group-header,
                        
                        $matches,
                        
                        (: Notes cache :)
                        if(lower-case(local-name($group)) eq 'tei' and $results-in-group//tei:note[@place eq 'end'][@xml:id]) then
                            if($group-header[@type eq 'knowledgebase']) then
                                knowledgebase:outline($group)/m:pre-processed[@type eq 'end-notes']
                            else if($group-header[@type eq 'translation']) then
                                translation:outline-cached($group)/m:pre-processed[@type eq 'end-notes']
                            else ()
                        else ()
                    
                    )
                else ()
                
            }
        
        return 
            local:result-groups($results-not-in-group, ($result-groups, $result-group), $data-types, $first-record, $max-records, $max-matches, $search)
    
};

declare function search:tm-search($search as xs:string, $search-lang as xs:string, $first-record as xs:double, $max-records as xs:double, $include-glossary as xs:boolean, $exclude-tmx as element(tmx:tmx)?) as element(m:tm-search) {
    
    let $lang-map := map { 'bo':'bo', 'en':'en' }
    
    (: Convert bo-ltn to bo :)
    let $search := 
        if(lower-case($search-lang) = ('bo', 'bo-ltn') and not(common:string-is-bo($search))) then
            common:bo-from-wylie($search)
        else if(devanagari:string-is-dev($search)) then
            devanagari:to-iast($search)
        else
            $search
    
    let $search-lang :=
        if(lower-case($search-lang) = ('bo', 'bo-ltn')) then
            'bo'
        else
            lower-case($search-lang)
    
    let $tmx := collection(concat($common:data-path, '/translation-memory'))//tmx:tmx except $exclude-tmx
    let $tm-units := $tmx/tmx:body/tmx:tu
    
    let $tei := collection($common:translations-path)//tei:TEI
    
    let $results :=
        for $result in (
            let $search-regex := string-join(tokenize($search, '\s+(།\s*)?')[normalize-space(.)] ! normalize-space(.) ! replace(., '(^་|་$|&#8203;)', ''), ' OR ')
            let $matches := 
                (: Only search units with segments for both languages :)
                if($search-lang eq 'bo') then
                    $tm-units[ft:query(tmx:tuv, concat('bo:(', $search-regex, ')'), map { "fields": ("bo") })][tmx:tuv[@xml:lang eq 'en']]
                else
                    $tm-units[ft:query(tmx:tuv, concat('en:(', $search, ')'), map { "fields": ("en") })][tmx:tuv[@xml:lang eq 'bo']]
                return
                    local:some-matches($matches, 1)
            ,
            if($include-glossary) then
                if($search-lang eq 'bo') then
                    $tei//tei:back//tei:gloss[ft:query(tei:term[@xml:lang eq 'bo'], $search)]
                else
                    $tei//tei:back//tei:gloss[ft:query(tei:term[not(@xml:lang) or @xml:lang eq 'en'](:[not(@type eq 'translationAlternative')]:), $search)]
            else ()
        )
        let $score := ft:score($result)
        order by $score descending
        return 
            $result
    
    return (:if(true()) then element debug { $results } else:)
        element { QName('http://read.84000.co/ns/1.0', 'tm-search') } {
        
            attribute search-lang { $search-lang },
            
            element results {
            
                attribute first-record { $first-record },
                attribute max-records { $max-records },
                attribute count-records { count($results) },
                
                (:element debug {  $search-and },:)
            
                for $result at $index in subsequence($results[local-name() = ('tu', 'gloss')], $first-record, $max-records)
                    
                    let $score := ft:score($result)
                    
                    let $result-tmx := $result/ancestor::tmx:tmx[1]
                    
                    let $tei := 
                        if($result-tmx[tmx:header/@eft:text-id]) then
                            tei-content:tei($result-tmx/tmx:header/@eft:text-id, 'translation')
                        else
                            $result/ancestor::tei:TEI
                    
                    let $toh-key := translation:toh($tei, '')/@key
                    
                order by $score descending
                
                return
                    if($tei) then
                        element item { 
                            
                            attribute index { $index + ($first-record -1) },
                            
                            (: Score :)
                            attribute score { $score },
                            
                            (: TEI source :)
                            local:result-header($tei),
                            
                            (: Data :)
                            if(local-name($result) eq 'tu') then
                                
                                (: Translation memory result :)
                                
                                let $location-id := 
                                    if($result/tmx:prop[@type eq 'location-id']) then
                                        $result/tmx:prop[@type eq 'location-id']/text()
                                    else 
                                        (: The folio is a prop of the TM unit :)
                                        let $result-folio := $result/tmx:prop[@type eq 'folio']
                                        
                                        (: Get the full list of folios :)
                                        let $folio-refs-sorted := translation:folio-refs-sorted($tei, $toh-key)
                                        
                                        (: Get the position of this one :)
                                        let $folio := 
                                            if($result-folio[@m:cRef-volume]) then
                                                $folio-refs-sorted[lower-case(@cRef) eq lower-case($result-folio/text())][lower-case(@cRef-volume) eq lower-case($result-folio/@m:cRef-volume)][1]
                                            else
                                                $folio-refs-sorted[lower-case(@cRef) eq lower-case($result-folio/text())][1]
                                        return
                                            $folio/@xml:id
                                
                                return
                                    element match {
                                    
                                        attribute type { 'tm-unit' },
                                        attribute type-id { $result/@id },
                                        attribute location { concat('/translation/', $toh-key, '.html', if($location-id) then concat('#', $location-id) else '') },
                                        
                                        if($result-tmx/tmx:header[@creationtool = ('linguae-dharmae/84000')]) then
                                            element flag { attribute type { 'machine-alignment' } }
                                        else ()
                                        ,
                                        
                                        for $prop in $result/tmx:prop[@type = ('alternative-source','requires-attention')]
                                        return
                                            element flag { attribute type { $prop/@type/string() } }
                                        ,
                                        
                                        element tibetan { 
                                            if($search-lang eq 'bo') then
                                                ft:highlight-field-matches($result//tmx:tuv[@xml:lang eq "bo"], 'bo')/node()
                                            else
                                                $result//tmx:tuv[@xml:lang eq "bo"]/tmx:seg/node()
                                        },
                                        element translation { 
                                            if($search-lang eq 'en') then
                                                ft:highlight-field-matches($result//tmx:tuv[@xml:lang eq "en"], 'en')/node()
                                            else
                                                $result//tmx:tuv[@xml:lang eq "en"]/tmx:seg/node()
                                        }
                                        
                                    }
                                
                            else
                                
                                (: TEI glossary result :)
                                element match {
                                    
                                    attribute type { 'glossary-term' },
                                    
                                    (: Include surfeits, just don't link :)
                                    if($result[not(@mode eq 'surfeit')]) then
                                        attribute location { concat('/translation/', $toh-key, '.html#', $result/@xml:id) }
                                    else (),
                                    
                                    let $result-bo := $result/tei:term[@xml:lang eq "bo"]
                                    return
                                    element tibetan {
                                        if($search-lang eq 'bo') then
                                            util:expand($result-bo)/node()
                                            (:common:mark-nodes($result-bo, $search, 'tibetan')/node():)
                                        else
                                            $result-bo/node()
                                    }, 
                                    
                                    let $result-en := $result/tei:term[not(@type eq 'translationAlternative')][not(@xml:lang) or @xml:lang eq "en"]
                                    return
                                    element translation { 
                                        if($search-lang eq 'en') then
                                            util:expand($result-en)/node()
                                            (:common:mark-nodes($result-en, $search, 'tibetan')/node():)
                                        else
                                            $result-en/node()
                                    },
                                    
                                    element wylie { 
                                        $result/tei:term[@xml:lang eq "Bo-Ltn"]/node()
                                    },
                                    element sanskrit { 
                                        $result/tei:term[@xml:lang eq "Sa-Ltn"]/node()
                                    }
                                
                                }
                                
                        }
                    else
                        ()
            }
        }

};

(: Recurr search, lowering the threshold, until it finds something :)
declare function local:some-matches($matches as element(tmx:tu)*, $min-score as xs:float) as element(tmx:tu)* {
    
    let $matches-count-target := 10
    let $min-score-increment := 0.25
    
    let $matches-for-score := 
        for $match in $matches
        let $score := ft:score($match)
        where $score ge $min-score
        return
            $match
    
    return
        if(count($matches-for-score) lt $matches-count-target and $min-score - $min-score-increment gt 0) then
            local:some-matches($matches, $min-score - $min-score-increment)
        else 
            $matches-for-score
            
};

declare function local:search-query($request as xs:string, $search-as-phrase as xs:boolean?) as element() {
    
    (: In leiu of Lucene synonyms :)
    
    let $synonyms := 
        <synonyms xmlns="http://read.84000.co/ns/1.0">
            <synonym>
                <term>tohoku</term>
                <term>toh</term>
            </synonym>
        </synonyms>
    
    let $request-normalized := common:normalized-chars($request)
    
    let $request-tokenized := tokenize($request-normalized, '\s')[normalize-space(.)]
    
    return
        <query>
            {
                if($search-as-phrase) then
                    <phrase slop="1" occur="must">{ $request-normalized }</phrase>
                
                else (
                
                    <bool slop="100" min="{ if(count($request-tokenized) ge 2) then 2 else 1 }">{ $request-tokenized ! <term occur="should">{ . }</term>  }</bool>,
                    
                    for $synonym-term in $synonyms//eft:synonym[eft:term/text() = $request-tokenized]/eft:term[not(text() = $request-tokenized)]
                    let $synonym-terms := $synonym-term/parent::eft:synonym/eft:term/text()
                    return
                        for $synonym-token in $request-tokenized[. = $synonym-terms]
                        let $request-normalized-synonymous := replace($request-normalized, concat('(^|\s+)(', $synonym-token, ')(\s+|$)'), concat('$1', $synonym-term, '$3'), 'i')
                        let $request-normalized-synonymous-tokenized := tokenize($request-normalized-synonymous, '\s')[normalize-space(.)]
                        return 
                            <bool slop="100" min="{ if(count($request-normalized-synonymous-tokenized) ge 2) then 2 else 1 }">{ $request-normalized-synonymous-tokenized ! <term occur="should">{ . }</term>  }</bool>
                )
            }   
        </query>
};

declare function local:result-header($content as element()) as element() {
    
    let $type := 
        if(local-name($content) eq 'entity') then
            'entity'
        else if(lower-case(local-name($content)) eq 'tei') then
            tei-content:type($content)
        else ()
    
    (: What sort of link? :)
    let $render-type := 
        (: Article published :)
        if($type = ('knowledgebase', 'section') and $content[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/@status = $common:environment/m:render/m:status[@type eq 'article']/@status-id]) then
            'knowledgebase'
        
        (: Translation published :)
        else if($type eq 'translation' and $content[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/@status = $common:environment/m:render/m:status[@type eq 'translation']/@status-id]) then
            'translation'
        
        (: Default to section :)
        else if($type = ('translation', 'section')) then
            'section'
        
        else if($type eq 'entity') then 
            'glossary'
        
        else ()
    
    let $resource-id := 
        if(lower-case(local-name($content)) eq 'tei') then
            tei-content:id($content)
        else if(local-name($content) eq 'entity') then
            $content/@xml:id
        else ()
    
    let $target-resource-id :=
        if($type eq 'translation' and $render-type eq 'section') then
            $content//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:idno[@parent-id][1]/@parent-id
        else 
            $resource-id
    
    let $fragment-id := 
        if($type eq 'translation' and $render-type eq 'section') then
            $content//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key][1]/@key
        else ()
        
    let $page-link := concat('/', $render-type, '/', $target-resource-id, '.html', $fragment-id ! concat('#', .))
    
    where $type
    return
        element { QName('http://read.84000.co/ns/1.0', 'header') }{
        
            attribute type { $type },
            attribute resource-id { $resource-id },
            attribute link { $page-link },
            attribute render { $render-type },
            
            if(lower-case(local-name($content)) eq 'tei') then (
            
                attribute status { tei-content:publication-status($content) },
                attribute status-group { tei-content:publication-status-group($content) },
                
                (: Titles :)
                tei-content:title-set($content, 'mainTitle'),
                
                (: Add Toh keys :)
                (: Must group these in m:bibl to keep track of @key group :)
                for $toh-key in $content//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
                return 
                    element bibl {
                        translation:toh($content, $toh-key),
                        tei-content:ancestors($content, $toh-key, 1)
                    }
                ,
                
                if($render-type eq 'knowledgebase') then 
                    knowledgebase:page($content)
                
                else if($render-type eq 'translation') then 
                    translation:publication($content)
                 
                else ()
                
            )
            else 
                $content
                
        }
};

declare function local:match-link($match as element()*, $nearest-id as xs:string?, $header as element(m:header)?) as xs:string? {
    
    (: Handle some exceptions :)
    
    if($header[@render eq 'glossary']) then
        $header/@link (: Just use the link in the header :)
    
    else if($header[@render eq 'section'][@type eq 'translation'] and $nearest-id = ('other-titles')) then
        concat(functx:substring-before-if-contains($header/@link, '#'), '#title-variants-', $header/@resource-id)
    
    else if($header[@render eq 'section'][@type eq 'translation'] and $nearest-id = ('other-authors')) then
        concat(functx:substring-before-if-contains($header/@link, '#'), '#supplementary-roles-', $header/@resource-id)
    
    else if($header[@render eq 'translation'] and $nearest-id = ('authors', 'other-titles', 'other-authors')) then
        concat(functx:substring-before-if-contains($header/@link, '#'), '#titles')
    
    (: The match is in a note, so link to the note so it pops up (the same match may have multiple matching notes) :)
    else if($header[@render = ('translation', 'knowledgebase')] and $match[descendant::exist:match/ancestor::tei:note[@place eq 'end'][@xml:id]]) then
        concat(functx:substring-before-if-contains($header/@link, '#'), '#', ($match/descendant::exist:match/ancestor::tei:note[@place eq 'end']/@xml:id)[1])
    
    else if($header[@render eq 'section']) then
        $header/@link (: Just use the link in the header :)
    
    (: Default to link + nearest-id :)
    else
        concat(functx:substring-before-if-contains($header/@link, '#'), $nearest-id ! concat('#',.))
        
    };
