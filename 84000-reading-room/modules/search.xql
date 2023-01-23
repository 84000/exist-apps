xquery version "3.0" encoding "UTF-8";
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
import module namespace kwic="http://exist-db.org/xquery/kwic";
import module namespace functx="http://www.functx.com";

declare function search:search($request as xs:string, $first-record as xs:double, $max-records as xs:double) as element() {

    search:search($request, '', $first-record, $max-records)
    
};

declare function search:search($request as xs:string, $resource-id as xs:string, $first-record as xs:double, $max-records as xs:double) as element(m:search) {
    
    let $all := 
        if($resource-id gt '') then
            tei-content:tei($resource-id, 'translation')
        else (
            collection($common:translations-path)//tei:TEI
            | $knowledgebase:tei-render
        )
    
    let $published := $all[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $translation:published-status-ids]
    
    let $options :=
        <options>
            <default-operator>or</default-operator>
            <phrase-slop>0</phrase-slop>
            <leading-wildcard>no</leading-wildcard>
            <filter-rewrite>yes</filter-rewrite>
        </options>
    
    (: Interogate the request to see if it's a phrase :)
    let $request-is-phrase := matches($request, '^\s*["“].+["”]\s*$')
    let $request-no-quotes := replace($request, '("|“|”)', '')
    
    let $query := local:search-query($request-no-quotes, $request-is-phrase)
    
    let $results := 
        (: Header content :)
        $all/tei:teiHeader/tei:fileDesc//tei:title[ft:query(., $query, $options)]
        | $all/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[ft:query(., $query, $options)]
        | $all/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[ft:query(., $query, $options)]
        (: @tid content :)
        | $published/tei:text//tei:p[ft:query(., $query, $options)][@tid]
        | $published/tei:text//tei:label[ft:query(., $query, $options)][@tid]
        | $published/tei:text//tei:table[ft:query(., $query, $options)][@tid]
        | $published/tei:text//tei:head[ft:query(., $query, $options)][@tid]
        | $published/tei:text//tei:lg[ft:query(., $query, $options)][@tid]
        (: For now force tei:item/tei:p :)
        (:| $published/tei:text//tei:item[ft:query(., $query, $options)][@tid]:)
        | $published/tei:text//tei:ab[ft:query(., $query, $options)][@tid]
        | $published/tei:text//tei:trailer[ft:query(., $query, $options)][@tid]
        (: @xml:id content :)
        | $published/tei:text/tei:back//tei:bibl[ft:query(., $query, $options)][@xml:id]
        | $published/tei:text/tei:back//tei:gloss[ft:query(tei:term, $query, $options)][@xml:id][not(@mode eq 'surfeit')]
    
    let $result-groups := 
        for $result in $results
            let $score := ft:score($result)
            let $text-id := tei-content:id($result/ancestor::tei:TEI)
            group by $text-id
            let $sum-scores := sum($score)
            order by $sum-scores descending
        return
            element { QName('http://read.84000.co/ns/1.0', 'result-group') } { 
                
                attribute text-id { $text-id },
                attribute document-uri { base-uri($result[1]) },
                attribute score { $sum-scores },
                
                for $single in $result
                return
                    element result {
                        attribute score { ft:score($single) },
                        $single
                    }
                
            }
    
    return 
        (:if(true()) then <search xmlns="http://read.84000.co/ns/1.0">{$result-groups}</search> else:)
        element { QName('http://read.84000.co/ns/1.0', 'tei-search') } { 
        
            element request { 
            
                if($resource-id gt '') then (
                    
                    let $tei := tei-content:tei($resource-id, 'translation')
                    return
                        local:tei-header($tei)
                        
                )
                else ()
                ,
                
                $request
                
            },

            element results {
            
                attribute first-record { $first-record },
                attribute max-records { $max-records },
                attribute count-records { count($result-groups) },
                
                for $result-group in subsequence($result-groups, $first-record, $max-records)
                    
                    (: Get TEI :)
                    let $tei := tei-content:tei($result-group/@text-id, 'translation')
                    let $tei-header := local:tei-header($tei)
                    let $outline := translation:outline-cached($tei, ())
                    
                    (: Sort matches :)
                    let $results := 
                        for $result in $result-group/m:result
                            order by xs:float($result/@score) descending
                        return $result
                    
                    (: Max results :)
                    let $max-results := if($resource-id gt '') then 1000 else 10
                
                return
                    element item {
                    
                        attribute score { $result-group/@score },
                        attribute count-records { count($results) },
                            
                        (: Include header info :)
                        $tei-header,
                        
                        (: Take the top x matches :)
                        for $result in subsequence($results, 1, $max-results)
                        let $marked := common:mark-nodes($result/node(), $request-no-quotes, 'words')
                        return
                        
                            element match {
                                attribute score { $result/@score },
                                attribute node-name { local-name($result/node()) },
                                attribute node-type { $result/node()/@type },
                                attribute node-lang { $result/node()/@xml:lang },
                                attribute link { local:match-link($marked, $tei-header) },
                                $marked
                            }
                        ,
                        
                        (: Notes cache :)
                        if($results//tei:note[@place eq 'end'][@xml:id]) then
                            $outline/m:pre-processed[@type eq 'end-notes']
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
    (: Only search units with segments for both languages :)
    let $tm-units := $tmx/tmx:body/tmx:tu[tmx:tuv[@xml:lang eq 'bo']][tmx:tuv[@xml:lang eq 'en']]
    
    let $tei := collection($common:translations-path)//tei:TEI
    
    let $results :=
        for $result in (
            if($search-lang eq 'bo') then
                $tm-units[ft:query(tmx:tuv, concat('bo:(', $search, ')'), map { "fields": ("bo") })]
            else
                $tm-units[ft:query(tmx:tuv, concat('en:(', $search, ')'), map { "fields": ("en") })]
            ,
            if($include-glossary) then
                if($search-lang eq 'bo') then
                    $tei//tei:back//tei:gloss[ft:query(tei:term[@xml:lang eq 'bo'], $search)]
                else
                    $tei//tei:back//tei:gloss[ft:query(tei:term[not(@xml:lang) or @xml:lang eq 'en'][not(@type = ('definition','alternative'))], $search)]
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
            
                for $result in subsequence($results[local-name() = ('tu', 'gloss')], $first-record, $max-records)
                    
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
                        
                            (: Score :)
                            attribute score { $score },
                            
                            (: TEI source :)
                            local:tei-header($tei),
                            
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
                                        attribute location { concat('/translation/', $toh-key, '.html', if($location-id) then concat('#', $location-id) else '') },
                                        
                                        if($result-tmx/tmx:header[@creationtool = ('linguae-dharmae/84000')]) then
                                            element flag { attribute type { 'machine-alignment' } }
                                        else ()
                                        ,
                                        
                                        for $prop in $result/tmx:prop[@name = ('alternative-source')]
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
                                    
                                    let $result-bo := $result/tei:term[not(@type = ('definition','alternative'))][@xml:lang eq "bo"]
                                    return
                                    element tibetan {
                                        if($search-lang eq 'bo') then
                                            util:expand($result-bo)/node()
                                            (:common:mark-nodes($result-bo, $search, 'tibetan')/node():)
                                        else
                                            $result-bo/node()
                                    }, 
                                    
                                    let $result-en := $result/tei:term[not(@type = ('definition','alternative'))][not(@xml:lang) or @xml:lang eq "en"]
                                    return
                                    element translation { 
                                        if($search-lang eq 'en') then
                                            util:expand($result-en)/node()
                                            (:common:mark-nodes($result-en, $search, 'tibetan')/node():)
                                        else
                                            $result-en/node()
                                    },
                                    
                                    element wylie { 
                                        $result/tei:term[not(@type = ('definition','alternative'))][@xml:lang eq "Bo-Ltn"]/node()
                                    },
                                    element sanskrit { 
                                        $result/tei:term[not(@type = ('definition','alternative'))][@xml:lang eq "Sa-Ltn"]/node()
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

declare function local:tei-header($tei as element(tei:TEI)) as element() {

    let $tei-type := tei-content:type($tei)
    
    let $resource-id := tei-content:id($tei)
    
    let $trandlation-status := tei-content:translation-status($tei)
    
    let $trandlation-status-group := tei-content:translation-status-group($tei)
    
    let $link := 
        
        (: Knowledgebase :)
        if($tei-type eq 'knowledgebase') then
            concat('/knowledgebase/', $resource-id, '.html')

        (: Translation :)
        else
            (: Published :)
            if($trandlation-status-group eq 'published') then
                concat('/translation/', $resource-id, '.html')
            
            (: Un-published :)
            else
                let $first-bibl := $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[1]
                return
                    concat('/section/', $first-bibl/tei:idno/@parent-id, '.html', '#', $first-bibl/@key)
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'tei') }{
        
            attribute type { $tei-type },
            attribute resource-id { $resource-id },
            attribute link { $link },
            attribute translation-status { $trandlation-status },
            attribute translation-status-group { $trandlation-status-group },
            
            element titles {
                tei-content:title-set($tei, 'mainTitle') 
            },
            
            if($tei-type eq 'knowledgebase') then (
                knowledgebase:page($tei)
            )
            else (:if($tei-type eq 'translation') then :) (
            
                (: Add header :)
                translation:publication($tei),
                
                (: Add Toh :)
                for $toh-key in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
                return
                    (: Must group these in m:bibl to keep track of @key group :)
                    element bibl {
                        translation:toh($tei, $toh-key),
                        tei-content:ancestors($tei, $toh-key, 1)
                    }
            )
        }
};

declare function local:match-link($result as element()?, $tei-header as element(m:tei)?) as xs:string {
    
    (: Translation / Knowledge Base :)
    if($tei-header[@type = ('translation', 'knowledgebase')][@translation-status-group eq 'published']) then
        
        (: the match is in a note (the same match may have multiple matching notes) :)
        if($result[descendant::exist:match/ancestor::tei:note[@place eq 'end'][@xml:id]]) then
            concat(functx:substring-before-if-contains($tei-header/@link, '#'), '#', ($result/descendant::exist:match/ancestor::tei:note[@place eq 'end']/@xml:id)[1])
            
        (:Has an xml:id:)
        else if($result[@xml:id]) then
            concat(functx:substring-before-if-contains($tei-header/@link, '#'), '#', $result/@xml:id)
            
        (: Has an id :)
        else if($result[@tid]) then
            concat(functx:substring-before-if-contains($tei-header/@link, '#'), '#node-', $result/@tid)
        
        (: Toh / Scope :)
        else if(local-name($result) = ('ref', 'biblScope')) then
            concat(functx:substring-before-if-contains($tei-header/@link, '#'),'#toh')
        
        (: Author :)
        else if(local-name($result) = ('author', 'sponsor')) then
            concat(functx:substring-before-if-contains($tei-header/@link, '#'),'#acknowledgements')
        
        (: Default to the beginning of the page :)
        else
            $tei-header/@link
        
    (: Un-published :)
    else if ($tei-header[@type = ('translation')]) then
            
        (: Has an id that must be elaborated to work in the section/texts list :)
        if($result[@tid]) then
            concat(functx:substring-before-if-contains($tei-header/@link, '#'), '#', $tei-header/m:bibl[1]/@toh-key,'-node-', $result/@tid)
        
        (: Has a collapsed title in the section/texts list :)
        else if($result[local-name($result) eq 'title' and $result/@type eq 'otherTitle']) then
            concat(functx:substring-before-if-contains($tei-header/@link, '#'), '#', $tei-header/m:bibl[1]/@toh-key, '-title-variants')
        
        (: Default to the beginning of the page :)
        else
            $tei-header/@link
    
    (: Section :)
    else if($tei-header[@type eq 'section']) then
        
        (: Has an xml:id :)
        if($result[@xml:id]) then
            concat(functx:substring-before-if-contains($tei-header/@link, '#'),'#', $result/@xml:id)
        
        (: Has an id :)
        else if($result[@tid]) then
            concat(functx:substring-before-if-contains($tei-header/@link, '#'),'#node-', $result/@tid)
        
        (: Default to the beginning of the page :)
        else
            $tei-header/@link
    
    (: Default to the beginning of the page :)
    else
        $tei-header/@link
};

