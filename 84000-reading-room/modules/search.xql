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
import module namespace kwic="http://exist-db.org/xquery/kwic";
import module namespace functx="http://www.functx.com";

declare variable $search:data-types := 
    <search-data xmlns="http://read.84000.co/ns/1.0">
        <type id="translations">Translations</type>
        <type id="knowledgebase">Knowledge Base</type>
        <type id="glossary">Glossary</type>
    </search-data>;

declare function search:search($request as xs:string, $first-record as xs:double, $max-records as xs:double) as element() {

    search:search($request, $search:data-types/m:type, '', $first-record, $max-records)
    
};

declare function search:search($request as xs:string, $data-types as element(m:type)*, $resource-id as xs:string, $first-record as xs:double, $max-records as xs:double) as element(m:tei-search) {
    
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
                $knowledgebase-tei[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/@status = $article-render-status]
                | $sections-tei[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/@status = $article-render-status]
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
            <phrase-slop>0</phrase-slop>
            <leading-wildcard>no</leading-wildcard>
            <filter-rewrite>yes</filter-rewrite>
        </options>
    
    (: Check the request to see if it's a phrase :)
    let $request-is-phrase := matches($request, '^\s*["“].+["”]\s*$')
    let $request-no-quotes := replace($request, '("|“|”)', '')
    
    let $query := local:search-query($request-no-quotes, $request-is-phrase)
    
    let $results := (
        (: Header content :)
        if($data-types[@id = ('translations','knowledgebase')]) then (
            $all/tei:teiHeader/tei:fileDesc//tei:title[ft:query(., $query, $options)]
            | $all/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key][ft:query(., $query, $options)]
            | $all/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[ft:query(., $query, $options)]
            (: Text content :)
            | $published/tei:text//tei:p[not(parent::tei:gloss)][ft:query(., $query, $options)]
            | $published/tei:text//tei:label[ft:query(., $query, $options)]
            | $published/tei:text//tei:table[ft:query(., $query, $options)]
            | $published/tei:text//tei:head[ft:query(., $query, $options)]
            | $published/tei:text//tei:lg[ft:query(., $query, $options)]
            (: For now force tei:item/tei:p :)
            (:| $published/tei:text//tei:item[ft:query(., $query, $options)]:)
            | $published/tei:text//tei:ab[ft:query(., $query, $options)]
            | $published/tei:text//tei:trailer[ft:query(., $query, $options)]
            (: Back content :)
            | $published/tei:text/tei:back//tei:bibl[@key][ft:query(., $query, $options)][@xml:id]
        )
        else ()
        ,
        if($data-types[@id = ('translations','glossary')]) then
            $published/tei:text/tei:back//tei:gloss[ft:query(node(), $query, $options)][@xml:id][not(@mode eq 'surfeit')][ancestor::tei:div[@type eq 'glossary'][not(@status eq 'excluded')]]
        else ()
        ,
        if($data-types[@id  eq 'glossary']) then
            $entities-definitions[ft:query(., $query, $options)]
        else ()
    )
    
    let $results-groups := (
    
        (: Group text results together :)
        if($data-types[@id = ('translations','knowledgebase')]) then
        
            for $result in $results[not(ancestor-or-self::*[@rend eq 'default-text'])]
            
            let $tei := $result/ancestor::tei:TEI[1]
            let $group-id := $tei ! tei-content:id(.)
            
            where $group-id
            group by $group-id
            return
                element { QName('http://read.84000.co/ns/1.0', 'results-group') } { 
                    
                    attribute id { $group-id },
                    attribute type { tei-content:type($tei[1]) },
                    attribute document-uri { base-uri($tei[1]) },
                    
                    for $single at $index in $result
                    
                    (: Get nearest id - required :)
                    let $nearest-id :=
                        if($single/ancestor::tei:fileDesc) then
                            if($single[self::tei:title] and $single[not(@type eq 'mainTitle')]) then 'other-titles'
                            else if($single[self::tei:title]) then 'titles'
                            else if($single[self::tei:author][@role]) then 'other-authors'
                            else 'authors'
                        else
                            $single/ancestor-or-self::*[not(@xml:id)][preceding-sibling::tei:milestone[@xml:id]][1]/preceding-sibling::tei:milestone[@xml:id][1]/@xml:id
                    
                    let $nearest-id := if(not($nearest-id)) then ($single/ancestor-or-self::*[@xml:id][1]/@xml:id, $single/ancestor-or-self::tei:div[@type][1]/@type)[1] else $nearest-id
                    
                    (: Get score :)
                    let $score := ft:score($single)[. gt 0]
                    
                    where $nearest-id
                    group by $nearest-id
                    
                    (: Set a score for the group :)
                    let $score-calc := max($score)
                    return
                        element result {
                            attribute score { $score-calc },
                            attribute nearest-id { $nearest-id },
                            $single
                        }
                    
                }
                
        else ()
        ,
        
        (: Group glossaries together :)
        if(not($single-tei) and $data-types[@id  eq 'glossary']) then
            
            for $result in $results[self::tei:gloss or parent::m:entity][not(ancestor-or-self::*[@rend eq 'default-text'])]
            
            let $entity :=
                (: Glossary entry in a text :)
                if($result[self::tei:gloss]) then 
                    $entities:entities//m:instance[@id eq $result/@xml:id]/parent::m:entity[1]
                (: Entity definition :)
                else
                    $result/parent::m:entity[1]
            
            let $group-id := $entity/@xml:id
            
            where $group-id
            group by $group-id
            return
                element { QName('http://read.84000.co/ns/1.0', 'results-group') } { 
                    
                    attribute id { $group-id },
                    attribute type { 'entity' },
                    
                    for $single at $index in $result
                    
                    (: Get nearest id - required :)
                    let $nearest-id := $single/ancestor-or-self::*[@xml:id][1]/@xml:id
                    
                    (: Get score, boost glossary a bit :)
                    let $score := ft:score($single)[. gt 0] * 1.5
                    
                    where $nearest-id
                    group by $nearest-id
                    
                    (: Set a score for the group :)
                    let $score-calc := max($score)
                    return
                        element result {
                            attribute score { $score-calc },
                            attribute nearest-id { $nearest-id },
                            $single
                        }
                    
                }
                
        else ()
    )
    
    let $results-groups :=
        for $results-group in $results-groups
        order by max($results-group/m:result/@score ! xs:float(.)) descending
        return
            $results-group
    
    return 
        (:if(true()) then element { QName('http://read.84000.co/ns/1.0', 'tei-search') } { $results-groups } else:)
        
        element { QName('http://read.84000.co/ns/1.0', 'tei-search') } { 
        
            element request { 
                $single-tei ! local:result-header(.),
                $request
            },

            element results {
            
                attribute first-record { $first-record },
                attribute max-records { $max-records },
                attribute count-records { count($results-groups) },
                
                (: Pagination :)
                for $results-group in subsequence($results-groups, $first-record, $max-records)
                
                let $container := 
                    if($results-group[@type = ('knowledgebase','translation','section')]) then
                        tei-content:tei($results-group/@id, $results-group/@type)
                    else
                        $entities:entities/id($results-group/@id)[self::m:entity]
                
                let $header := local:result-header($container)
                
                (: Sort matches :)
                let $results := 
                    for $result in $results-group/m:result
                    order by $result/@score ! xs:float(.) descending
                    return
                        $result
                
                (: Max results :)
                let $max-results := if($single-tei) then 1000 else 10
                
                where $header
                return
                    element result {
                        
                        attribute type { $results-group/@type },
                        attribute score { max($results/@score) },
                        attribute count-matches { count($results) },
                        
                        (: Include header info :)
                        $header,
                        
                        (: Take the top x matches :)
                        for $match in subsequence($results, 1, $max-results)
                        let $marked := common:mark-nodes($match/node(), $request-no-quotes, 'words')
                        return
                            element match {
                                $match/@*,
                                attribute link { local:match-link($match, $header) },
                                $marked
                            }
                        ,
                        
                        (: Notes cache :)
                        if($results//tei:note[@place eq 'end'][@xml:id]) then
                            if($results-group[@type eq 'knowledgebase']) then
                                knowledgebase:outline($container)/m:pre-processed[@type eq 'end-notes']
                            else if($results-group[@type eq 'translation']) then
                                translation:outline-cached($container)/m:pre-processed[@type eq 'end-notes']
                            else ()
                        else ()
                        
                    }
                
            }
        
        }
        
};

declare function search:tm-search($search as xs:string, $search-lang as xs:string, $first-record as xs:double, $max-records as xs:double, $include-glossary as xs:boolean)  as element() {
    
    let $lang-map := map { 'bo':'bo', 'en':'en' }
    
    (: Convert bo-ltn to bo :)
    let $search := 
        if(lower-case($search-lang) = ('bo', 'bo-ltn') and not(common:string-is-bo($search))) then
            common:bo-from-wylie($search)
        else
            $search
    
    let $search-lang :=
        if(lower-case($search-lang) = ('bo', 'bo-ltn')) then
            'bo'
        else
            lower-case($search-lang)
    
    let $tmx := collection(concat($common:data-path, '/translation-memory'))//tmx:tmx
    let $tm-units := $tmx/tmx:body/tmx:tu
    
    let $tei := collection($common:translations-path)//tei:TEI
    
    let $results :=
        for $result in (
            (: Only search units with segments for both languages :)
            if($search-lang eq 'bo') then
                $tm-units[ft:query(tmx:tuv, concat('bo:(', $search, ')'), map { "fields": ("bo") })][tmx:tuv[@xml:lang eq 'en']]
            else
                $tm-units[ft:query(tmx:tuv, concat('en:(', $search, ')'), map { "fields": ("en") })][tmx:tuv[@xml:lang eq 'bo']]
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
            
            element results {
            
                attribute first-record { $first-record },
                attribute max-records { $max-records },
                attribute count-records { count($results) },
            
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
                                    if($result/tmx:prop[@name eq 'location-id']) then
                                        $result/tmx:prop[@name eq 'location-id']/text()
                                    else 
                                        (: The folio is a prop of the TM unit :)
                                        let $result-folio := $result/tmx:prop[@name eq 'folio']
                                        
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
                                        
                                        for $prop in $result/tmx:prop[@name = ('alternative-source','requires-attention')]
                                        return
                                            element flag { attribute type { $prop/@name/string() } }
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
    
    let $request-tokenized := tokenize($request-normalized, '\s')
    
    return
        <query>
            <bool>
            {
                if($search-as-phrase) then
                    <phrase slop="1" occur="must">{ $request-normalized }</phrase>
                else (
                    <near slop="20" occur="should">{ $request-normalized }</near>,
                    <wildcard occur="should">{ concat($request-normalized,'*') }</wildcard>,
                    for $request-token in $request-tokenized
                        for $synonym in $synonyms//eft:synonym[eft:term/text() = $request-token]/eft:term[not(text() = $request-token)]
                            let $request-synonym := replace($request-normalized, $request-token, $synonym)
                        return (
                            <near slop="20" occur="should">{ $request-synonym }</near>,
                            <wildcard occur="should">{ concat($request-synonym,'*') }</wildcard>
                        )
                
                )
            }   
            </bool>
        </query>
};

declare function local:result-header($content as element()) as element() {
    
    let $type := 
        if(lower-case(local-name($content)) eq 'tei') then
            tei-content:type($content)
        else if(local-name($content) eq 'entity') then
            'entity'
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

declare function local:match-link($result as element(m:result)*, $header as element(m:header)?) as xs:string? {
    
    (: Handle some exceptions :)
    
    if($header[@render eq 'glossary']) then
        () (: Just use the link in the header :)
    
    else if($header[@render eq 'section'][@type eq 'translation'] and $result[@nearest-id = ('other-titles')]) then
        concat(functx:substring-before-if-contains($header/@link, '#'), '#title-variants-', $header/@resource-id)
    
    else if($header[@render eq 'section'][@type eq 'translation'] and $result[@nearest-id = ('other-authors')]) then
        concat(functx:substring-before-if-contains($header/@link, '#'), '#supplementary-roles-', $header/@resource-id)
    
    else if($header[@render eq 'translation'] and $result[@nearest-id = ('authors', 'other-titles', 'other-authors')]) then
        concat(functx:substring-before-if-contains($header/@link, '#'), '#titles')
    
    (: The match is in a note, so link to the note so it pops up (the same match may have multiple matching notes) :)
    else if($header[@render = ('translation', 'knowledgebase')] and $result[descendant::exist:match/ancestor::tei:note[@place eq 'end'][@xml:id]]) then
        concat(functx:substring-before-if-contains($header/@link, '#'), '#', ($result/descendant::exist:match/ancestor::tei:note[@place eq 'end']/@xml:id)[1])
    
    (: Default to link + nearest-id :)
    else
        concat(functx:substring-before-if-contains($header/@link, '#'), $result/@nearest-id ! concat('#',.))
        
    };
