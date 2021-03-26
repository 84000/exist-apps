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
import module namespace kwic="http://exist-db.org/xquery/kwic";
import module namespace functx="http://www.functx.com";

declare function search:search($request as xs:string, $first-record as xs:double, $max-records as xs:double) as element() {

    search:search($request, '', $first-record, $max-records)
    
};

declare function search:search($request as xs:string, $resource-id as xs:string, $first-record as xs:double, $max-records as xs:double) as element() {
    
    let $all := 
        if($resource-id gt '') then
            tei-content:tei($resource-id, 'translation') (: Note, this needs fixing when we search section data!!! :)
        else
            collection($common:translations-path)//tei:TEI
    
    let $published := $all[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $tei-content:published-status-ids]
    
    let $options :=
        <options>
            <default-operator>or</default-operator>
            <phrase-slop>0</phrase-slop>
            <leading-wildcard>no</leading-wildcard>
            <filter-rewrite>yes</filter-rewrite>
        </options>
    
    (: Interogate the request to see if it's a phrase :)
    let $request-is-phrase := matches($request, '^["“].+["”]$')
    let $request-no-quotes := replace($request, '("|“|”)', '')
    
    let $query := local:search-query($request-no-quotes, $request-is-phrase)
    
    let $results := 
        $all/tei:teiHeader/tei:fileDesc//tei:title[ft:query(., $query, $options)]
        | $all/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[ft:query(., $query, $options)]
        | $all/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[ft:query(., $query, $options)]
        | $published/tei:text//tei:head[ft:query(., $query, $options)]
        | $published/tei:text//tei:p[ft:query(., $query, $options)]
        | $published/tei:text//tei:lg[ft:query(., $query, $options)]
        | $published/tei:text//tei:ab[ft:query(., $query, $options)]
        | $published/tei:text//tei:trailer[ft:query(., $query, $options)]
        | $published/tei:text/tei:back//tei:bibl[ft:query(., $query, $options)]
        | $published/tei:text/tei:back//tei:gloss[ft:query(., $query, $options)]
    
    let $result-groups := 
        for $result in $results
            let $score := ft:score($result)
            let $document-uri := base-uri($result)
            group by $document-uri
            let $sum-scores := sum($score)
            order by $sum-scores descending
        return
            <result-group xmlns="http://read.84000.co/ns/1.0" document-uri="{ $document-uri }" score="{ $sum-scores }">
            { 
                for $one-result in $result
                return
                    <result score="{ ft:score($one-result) }">
                    {
                        $one-result
                    }
                    </result>
                
            }
            </result-group>
    
    return 
        <search xmlns="http://read.84000.co/ns/1.0" >
            <request>{ $request }</request>
            {
                if($resource-id gt '') then
                    <translation id="{ tei-content:id($all[1]) }">
                    {
                        translation:toh($all[1], $resource-id),
                        translation:titles($all[1])
                    }
                    </translation>
                else
                    ()
            }
            <results
                first-record="{ $first-record }"
                max-records="{ $max-records }"
                count-records="{ count($result-groups) }">
                {
                    $query,
                    for $result-group in subsequence($result-groups, $first-record, $max-records)
                        
                        let $tei := doc($result-group/@document-uri)/tei:TEI
                        let $tei-header := local:tei-header($tei)
                        let $results := $result-group/m:result
                        
                        let $max-tei-records :=
                            if($resource-id gt '') then
                                1000
                            else
                                10
                    
                    return
                        <item 
                            score="{ $result-group/@score }" 
                            count-records="{ count($results) }">
                        {
                            
                            (: Include the tei header :)
                            $tei-header,
                            
                            (: First sort matches :)
                            let $results :=
                                for $result in $results
                                    order by xs:float($result/@score) descending
                                return $result
                            
                            (: Take the top x matches :)
                            for $result in subsequence($results, 1, $max-tei-records)
                            
                                let $expanded := common:mark-nodes($result/node(), $request-no-quotes, 'words')
                                
                                (:let $expanded :=
                                    if(not($expanded//exist:match)) then
                                        util:expand($result, "expand-xincludes=yes")
                                    else
                                        $expanded:)
                            
                            return
                                <match score="{ $result/@score }">
                                {
                                    attribute node-name { local-name($result/node()) },
                                    attribute node-type { $result/node()/@type },
                                    attribute node-lang { $result/node()/@xml:lang },
                                    (:$result/@*,:)
                                    attribute link { local:match-link($result/node(), $tei-header) },
                                    $expanded
                                }
                                </match>
                            ,
                            
                            (: Notes cache :)
                            if($results//tei:note[@place eq 'end'][@xml:id]) then
                                translation:notes-cache($tei, false(), false())
                            else ()
                        }
                        </item>
                }
            </results>
        </search>
        
};

declare function search:tm-search($request as xs:string, $lang as xs:string, $first-record as xs:double, $max-records as xs:double)  as element() {
    
    let $request-bo := 
        if(lower-case($lang) eq 'bo') then
            $request
        else if(lower-case($lang) eq 'bo-ltn') then
            common:bo-from-wylie($request)
        else
            ''
    
    let $request-bo-ltn := 
        if(lower-case($lang) eq 'bo-ltn') then
            $request
        else if(lower-case($lang) eq 'bo') then
            common:wylie-from-bo($request)
        else
            ''
    
    let $search :=
        if(lower-case($lang) = ('bo', 'bo-ltn')) then
            $request-bo
        else
            $request
    
    let $search-lang := 
        if(lower-case($lang) = ('bo', 'bo-ltn')) then
            'bo'
        else
            'en'
    
    let $options :=
        <options>
            <default-operator>or</default-operator>
            <phrase-slop>200</phrase-slop>
            <leading-wildcard>no</leading-wildcard>
            <filter-rewrite>yes</filter-rewrite>
        </options>
    
    let $query := 
        if($search-lang eq 'bo') then
            <query>
            {
                for $phrase in tokenize(normalize-space($search), '\s+')
                where not($phrase = ('།'))
                return
                    <near ordered="no">{ $phrase }</near>
            }
            </query>
        else
            <query>
                <bool>
                { 
                    for $term in tokenize(normalize-space($search), '\s+')
                    return
                        <term>{ $term }</term>
                }
                </bool>
            </query>
    
    let $translation-memory := collection(concat($common:data-path, '/translation-memory'))
    
    let $translations := collection($common:translations-path)
    
    let $results :=
        for $result in (
            if($search-lang eq 'bo') then
                $translation-memory//tmx:tu[ft:query-field('tmx-bo', $query, $options)]
            else
                $translation-memory//tmx:tu[ft:query-field('tmx-en', $query, $options)]
            ,
            if($search-lang eq 'bo') then
                $translations//tei:back//tei:gloss[ft:query(tei:term[@xml:lang eq 'bo'], $query, $options)]
            else
                $translations//tei:back//tei:gloss[ft:query(tei:term[not(@xml:lang) or @xml:lang eq 'en'][not(@type = ('definition','alternative'))], $query, $options)]
        )
            let $score := ft:score($result)
            order by $score descending
            (:where $score ge 5:)
        return 
            $result
            
    return 
        <tm-search xmlns="http://read.84000.co/ns/1.0">
            <request lang="{ $lang }">{ $request }</request>
            <search lang="{ $search-lang }">{ $search }</search>
            <results
                first-record="{ $first-record }"
                max-records="{ $max-records }"
                count-records="{ count($results) }">
            {
                for $result in subsequence($results[local-name() = ('tu', 'gloss')], $first-record, $max-records)
                    
                    let $score := ft:score($result)
                    
                    let $tei := 
                        if(local-name($result) eq 'tu') then
                            let $tmx := $result/ancestor::tmx:tmx
                            let $translation-id := $tmx/tmx:header/@eft:text-id
                            return
                                if($translation-id) then
                                    tei-content:tei($translation-id, 'translation')
                                else
                                    ()
                        else
                            $result/ancestor::tei:TEI
                    
                    let $expanded := util:expand($result, "expand-xincludes=no")
                    
                    let $expanded :=
                        if(not($expanded//exist:match)) then
                            if($lang eq 'bo') then
                                common:mark-nodes($result, $search, 'tibetan')
                            else
                                common:mark-nodes($result, $search, 'words')
                        else
                            $expanded
                    
                    let $toh-key := translation:toh($tei, '')/@key
                    
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
                                
                                (: The folio is a prop of the TM unit :)
                                let $result-folio := $result/tmx:prop[@name eq 'folio']
                                
                                (: Get the full list of folios :)
                                let $folio-refs-sorted := translation:folio-refs-sorted($tei, $toh-key)
                                
                                (: Get the position of this one :)
                                let $folio := 
                                    if($result-folio[@cRef-volume]) then
                                        $folio-refs-sorted[lower-case(@cRef) eq lower-case($result-folio/text())][lower-case(@cRef-volume) eq lower-case($result-folio/@cRef-volume)][1]
                                    else
                                        $folio-refs-sorted[lower-case(@cRef) eq lower-case($result-folio/text())][1]
                                
                                return
                                    element match {
                                        attribute type { 'tm-unit' },
                                        attribute location { concat('/translation/', $toh-key, '.html', if($folio[@xml:id]) then concat('#', $folio/@xml:id) else '') },
                                        element tibetan { $expanded/tmx:tuv[@xml:lang eq "bo"]/tmx:seg/node() },
                                        element translation { $expanded/tmx:tuv[@xml:lang eq "en"]/tmx:seg/node() }
                                    }
                                
                            else
                                
                                (: TEI glossary result :)
                                
                                element match {
                                    attribute type { 'glossary-term' },
                                    attribute location { concat('/translation/', $toh-key, '.html#', $result/@xml:id) },
                                    element tibetan { ($expanded/tei:term[not(@type = ('definition','alternative'))][@xml:lang eq "bo"][exist:match], $expanded/tei:term[not(@type = ('definition','alternative'))][@xml:lang eq "bo"])[1] }, 
                                    element translation { ($expanded/tei:term[not(@type = ('definition','alternative'))][not(@xml:lang) or @xml:lang eq "en"][not(@type = ('definition','alternative'))][exist:match], $expanded/tei:term[not(@type = ('definition','alternative'))][not(@xml:lang) or @xml:lang eq "en"][not(@type = ('definition','alternative'))])[1] },
                                    element wylie { ($expanded/tei:term[not(@type = ('definition','alternative'))][@xml:lang eq "Bo-Ltn"][exist:match], $expanded/tei:term[not(@type = ('definition','alternative'))][@xml:lang eq "Bo-Ltn"])[1] },
                                    element sanskrit { ($expanded/tei:term[not(@type = ('definition','alternative'))][@xml:lang eq "Sa-Ltn"][exist:match], $expanded/tei:term[not(@type = ('definition','alternative'))][@xml:lang eq "Sa-Ltn"])[1] }
                                }
                        }
                    else
                        ()
            }
            </results>
        </tm-search>

};

(: ~ Don't use this!!!
     Markup will interfere with glossary!??
:)
(:declare function search:search-translation($tei as element(tei:TEI), $searches as xs:string*) as element(tei:TEI) {

    let $options :=
        <options>
            <default-operator>or</default-operator>
            <phrase-slop>0</phrase-slop>
            <leading-wildcard>no</leading-wildcard>
            <filter-rewrite>yes</filter-rewrite>
        </options>
    
    let $query := 
        <query>
            <bool>
            {
                for $search in $searches
                return
                (
                    <near slop="20" occur="should">{ common:normalized-chars($search) }</near>,
                    <wildcard occur="should">{ concat(common:normalized-chars($search),'*') }</wildcard>
                )
            }
            </bool>
        </query>
    
    let $result := 
        $tei/tei:teiHeader/tei:fileDesc//tei:title[ft:query(., $query, $options)]
        | $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[ft:query(., $query, $options)]
        | $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[ft:query(., $query, $options)]
        | $tei/tei:text//tei:head[ft:query(., $query, $options)]
        | $tei/tei:text//tei:p[ft:query(., $query, $options)]
        | $tei/tei:text//tei:lg[ft:query(., $query, $options)]
        | $tei/tei:text//tei:ab[ft:query(., $query, $options)]
        | $tei/tei:text//tei:trailer[ft:query(., $query, $options)]
        | $tei/tei:back//tei:bibl[ft:query(., $query, $options)]
        | $tei/tei:back//tei:gloss[ft:query(., $query, $options)]
    
    for $tei in $result
        group by $ancestor := $tei/ancestor::tei:TEI
    return util:expand($ancestor)
};:)

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

    let $tei-type := 
        if($tei//tei:teiHeader/tei:fileDesc/@type = ('section', 'grouping', 'pseudo-section')) then
            'section'
        else
            'translation'
    
    let $resource-id := tei-content:id($tei)
    
    let $trandlation-status := tei-content:translation-status($tei)
    
    let $trandlation-status-group := tei-content:translation-status-group($tei)
    
    let $link := 
        
        (: Translation :)
        if($tei-type eq 'translation') then
            
            (: Published :)
            if($trandlation-status-group eq 'published') then
                concat('/translation/', $resource-id, '.html')
            
            (: Un-published :)
            else
                let $first-bibl := $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[1]
                return
                    concat('/section/', $first-bibl/tei:idno/@parent-id, '.html', '#', $first-bibl/@key)
        
        (: Section :)
        else if($tei-type eq 'section') then
            concat('/section/', $resource-id, '.html')
        
        else
            ''
    
    return
        <tei xmlns="http://read.84000.co/ns/1.0"
            type="{ $tei-type }" 
            resource-id="{ $resource-id }" 
            link="{ $link }"
            translation-status="{ $trandlation-status }"
            translation-status-group="{ $trandlation-status-group }">
            <titles>
            { 
                tei-content:title-set($tei, 'mainTitle') 
            }
            </titles>
            {
                if($tei-type eq 'translation') then
                (
                    (: Add header :)
                    translation:publication($tei),
                    
                    (: Add Toh :)
                    for $toh-key in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
                    return
                        (: Must group these in m:bibl to keep track of @key group :)
                        element bibl {
                            attribute toh-key { $toh-key },
                            attribute canonical-html { translation:canonical-html($toh-key, '') },
                            translation:toh($tei, $toh-key),
                            tei-content:ancestors($tei, $toh-key, 1)
                        }
                )
                else
                    (: Must group these in m:bibl to keep track of @key group :)
                    element bibl {
                        attribute toh-key { $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key },
                        tei-content:ancestors($tei, '', 1)
                    }
            }
        </tei>
};

declare function local:match-link($result as element(), $search-tei as element()) as xs:string {
    
    (: Translation :)
    if($search-tei/@type eq 'translation') then
    
        (: Published :)
        if($search-tei/@translation-status-group eq 'published') then
            
            (:Has an xml:id:)
            if($result/@xml:id) then
                concat(functx:substring-before-if-contains($search-tei/@link, '#'), '#', $result/@xml:id)
                
            (: Has an id :)
            else if($result/@tid) then
                concat(functx:substring-before-if-contains($search-tei/@link, '#'), '#node-', $result/@tid)
            
            (: Toh / Scope :)
            else if(local-name($result) = ('ref', 'biblScope')) then
                concat(functx:substring-before-if-contains($search-tei/@link, '#'),'#toh')
            
            (: Author :)
            else if(local-name($result) = ('author', 'sponsor')) then
                concat(functx:substring-before-if-contains($search-tei/@link, '#'),'#acknowledgements')
            
            (: Default to the beginning of the page :)
            else
                $search-tei/@link
        
        (: Un-published :)
        else
            
            (: Has an id that must be elaborated to work in the section/texts list :)
            if($result/@tid) then
                concat(functx:substring-before-if-contains($search-tei/@link, '#'), '#', $search-tei/m:bibl[1]/@toh-key,'-node-', $result/@tid)
            
            (: Has a collapsed title in the section/texts list :)
            else if($result[local-name($result) eq 'title' and $result/@type eq 'otherTitle']) then
                concat(functx:substring-before-if-contains($search-tei/@link, '#'), '#', $search-tei/m:bibl[1]/@toh-key, '-title-variants')
            
            (: Default to the beginning of the page :)
            else
                $search-tei/@link
    
    (: Section :)
    else if($search-tei/@type eq 'section') then
        
        (: Has an xml:id :)
        if($result/@xml:id) then
            concat(functx:substring-before-if-contains($search-tei/@link, '#'),'#', $result/@xml:id)
        
        (: Has an id :)
        else if($result/@tid) then
            concat(functx:substring-before-if-contains($search-tei/@link, '#'),'#node-', $result/@tid)
        
        (: Default to the beginning of the page :)
        else
            $search-tei/@link
    
    (: Default to the beginning of the page :)
    else
        $search-tei/@link
};

