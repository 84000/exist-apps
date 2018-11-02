xquery version "3.0" encoding "UTF-8";
(:
    Accepts the search parameter
    Returns search items xml
    --------------------------------------------------------
:)
module namespace search="http://read.84000.co/search";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tmx="http://www.lisa.org/tmx14";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";
import module namespace kwic="http://exist-db.org/xquery/kwic";
import module namespace functx="http://www.functx.com";

declare function search:text-query($request as xs:string) {
    
    (: In leiu of Lucene synonyms :)
    
    let $synonyms := 
        <synonyms xmlns="http://read.84000.co/ns/1.0">
            <synonym>
                <term>tohoku</term>
                <term>toh</term>
            </synonym>
        </synonyms>
        
    let $request-normalized := common:normalized-chars($request)
    
    let $request-tokenized := tokenize(common:normalized-chars($request-normalized), '\s')
    
    return
        <query>
            <bool>
                <near slop="20" occur="should">{ $request-normalized }</near>
                <wildcard occur="should">{ concat($request-normalized,'*') }</wildcard>
                {
                    for $request-token in $request-tokenized
                        for $synonym in $synonyms//m:synonym[m:term/text() = $request-token]/m:term[not(text() = $request-token)]
                        let $request-synonym := replace($request-normalized, $request-token, $synonym)
                        return
                        (
                            <near slop="20" occur="should">{ $request-synonym }</near>,
                            <wildcard occur="should">{ concat($request-synonym,'*') }</wildcard>
                        )
                }
            </bool>
        </query>
};

declare function search:search($request as xs:string, $first-record as xs:double, $max-records as xs:double) {
    
    let $all := collection($common:tei-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno/@xml:id]
    let $translated := $all[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $tei-content:published-statuses]
    
    let $options :=
        <options>
            <default-operator>or</default-operator>
            <phrase-slop>0</phrase-slop>
            <leading-wildcard>no</leading-wildcard>
            <filter-rewrite>yes</filter-rewrite>
        </options>
    
    let $query := search:text-query($request)
    
    let $results :=
        for $result in 
            $all//tei:teiHeader/tei:fileDesc//tei:title[ft:query(., $query, $options)]
                | $all//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[ft:query(., $query, $options)]
                | $all//tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[ft:query(., $query, $options)]
                | $translated//tei:text//tei:head[ft:query(., $query, $options)]
                | $translated//tei:text//tei:p[ft:query(., $query, $options)]
                | $translated//tei:text//tei:lg[ft:query(., $query, $options)]
                | $translated//tei:text//tei:ab[ft:query(., $query, $options)]
                | $translated//tei:text//tei:trailer[ft:query(., $query, $options)]
                | $translated//tei:back//tei:bibl[ft:query(., $query, $options)]
                | $translated//tei:back//tei:gloss[ft:query(., $query, $options)]
            
            let $scores := ft:score($result)
            
            let $document-uri := base-uri($result)
            group by $document-uri
            
            let $sum-scores := sum($scores)
            order by $sum-scores descending
         
         return 
            <result-group xmlns="http://read.84000.co/ns/1.0" document-uri="{ $document-uri }" sum-scores="{ $sum-scores }">
            {
                for $single in $result
                return
                    <match score="{ ft:score($single) }">
                    {
                        util:expand($single, "expand-xincludes=no")
                    }
                    </match>
            }
            </result-group>
    
    return 
        <search xmlns="http://read.84000.co/ns/1.0" >
            <request>{ $request }</request>
            { $query }
            <results
                first-record="{ $first-record }"
                max-records="{ $max-records }"
                count-records="{ count($results) }">
            {
                if ($request) then
 
                    for $result-group in subsequence($results, $first-record, $max-records)
                        
                        let $tei := doc($result-group/@document-uri)
                        let $tei-type := 
                            if($tei//tei:teiHeader/tei:fileDesc/@type = ('section', 'grouping', 'pseudo-section')) then
                                'section'
                            else
                                'translation'
                                
                        let $first-bibl := tei-content:source-bibl($tei, '')
                        let $first-bibl-key :=  if($first-bibl/@key) then $first-bibl/@key else ''

                    return
                        <item score="{ $result-group/@sum-scores }">
                        {
                            search:source($tei-type, $tei)
                        }
                        {
                            for $match in $result-group/m:match
                            order by $match/@score descending
                            return
                                <match>
                                {
                                    attribute node-type { node-name($match/*) },
                                    attribute score { $match/@score },
                                    $match/*/@*,
                                    $match/*/node()
                                }
                                </match>
                        }
                        </item>
               else
                    ()
            }
            </results>
        </search>(::)
};

declare function search:source($tei-type as xs:string, $tei as node()) as node() {
    <source xmlns="http://read.84000.co/ns/1.0"
        tei-type="{ $tei-type }" 
        resource-id="{ tei-content:id($tei) }" 
        translation-status="{ $tei//tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status }">
        <title>{ tei-content:title($tei) }</title>
        {
            if($tei-type eq 'translation') then
                translation:translation($tei)
            else
                ()
        }
        { 
            if($tei-type eq 'translation') then
                for $toh-key in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
                return
                    <bibl>
                        { translation:toh($tei, $toh-key) }
                        { tei-content:ancestors($tei, $toh-key, 1) }
                    </bibl>
                    
            else
                <bibl>
                    { tei-content:ancestors($tei, '', 1) }
                </bibl>
        }
    </source>
};

declare function search:tm-search($request as xs:string, $lang as xs:string, $first-record as xs:double, $max-records as xs:double) as node() {
    
    let $request-bo := 
        if($lang eq 'bo') then
            $request
        else
            common:bo-from-wylie($request)
    
    let $request-bo-ltn := 
        if($lang eq 'bo-ltn') then
            $request
        else
            common:wylie-from-bo($request)
    
    let $options :=
        <options>
            <default-operator>or</default-operator>
            <phrase-slop>0</phrase-slop>
            <leading-wildcard>no</leading-wildcard>
            <filter-rewrite>yes</filter-rewrite>
        </options>
    
    let $query := 
        <query>
        { 
            for $phrase in tokenize(normalize-space($request-bo), '།')
            return
                <phrase>{ $phrase }</phrase>
        }
        </query>
    
    let $translation-memory := collection(concat($common:data-path, '/translation-memory'))
    
    let $results :=
        if ($request-bo) then
            for $tu in $translation-memory//tmx:tu[ft:query(tmx:tuv[@xml:lang eq 'bo']/tmx:seg, $query, $options)]
                order by ft:score($tu) descending
            return $tu
        else
            ()
    
    return
        <tm-search xmlns="http://read.84000.co/ns/1.0">
            <request lang="{ $lang }">{ $request }</request>
            <request-bo>{ $request-bo }</request-bo>
            <request-bo-ltn>{ $request-bo-ltn }</request-bo-ltn>
            <results
                first-record="{ $first-record }"
                max-records="{ $max-records }"
                count-records="{ count($results) }">
            {
                for $tu in subsequence($results, $first-record, $max-records)
                    
                    let $document-uri := base-uri($tu)
                    let $document-uri-tokenized := tokenize($document-uri, '/')
                    let $file-name := $document-uri-tokenized[last()]
                    let $translation-id := substring-before($file-name, '.xml')
                    let $tei := tei-content:tei($translation-id, 'translation')
                    
                return
                    if($tei) then
                        <item>
                            { search:source('translation', $tei) }
                            { util:expand($tu, "expand-xincludes=no") }
                        </item>
                    else
                        ()
            }
            </results>
        </tm-search>

};