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
declare namespace exist="http://exist.sourceforge.net/NS/exist";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";
import module namespace kwic="http://exist-db.org/xquery/kwic";
import module namespace functx="http://www.functx.com";

declare function search:text-query($request as xs:string) as element() {
    
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

declare function search:search($request as xs:string, $first-record as xs:double, $max-records as xs:double) as element() {
    
    let $all := collection($common:tei-path)//tei:TEI
    
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
    
    let $result-groups := 
        for $result in $results
            let $score := ft:score($result)
            let $document-uri := base-uri($result)
            group by $document-uri
            let $sum-scores := sum($score)
            order by $sum-scores descending
        return
            <result-group xmlns="http://read.84000.co/ns/1.0" document-uri="{ $document-uri }" score="{ $sum-scores }"/>
        
    return 
        <search xmlns="http://read.84000.co/ns/1.0" >
            <request>{ $request }</request>
            <results
                first-record="{ $first-record }"
                max-records="{ $max-records }"
                count-records="{ count($result-groups) }">
                {
                    for $result-group in subsequence($result-groups, $first-record, $max-records)
                        
                        let $tei := doc($result-group/@document-uri)/tei:TEI
                        
                        let $tei-type := 
                            if($tei//tei:teiHeader/tei:fileDesc/@type = ('section', 'grouping', 'pseudo-section')) then
                                'section'
                            else
                                'translation'

                    return
                        <item score="{ $result-group/@score }">
                        {
                            search:source($tei-type, $tei)
                        }
                        {
                            for $result in $results
                                let $document-uri := base-uri($result)
                                where $document-uri eq $result-group/@document-uri
                            return
                                <match score="{ ft:score($result) }">
                                {
                                    attribute node-type { node-name($result) },
                                    $result/@*,
                                    (: util:expand($result) :)
                                    common:mark-nodes($result, $request)
                                }
                                </match>
                        }
                        </item>
                }
            </results>
        </search>
        
};

declare function search:source($tei-type as xs:string, $tei as node()) as element() {
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

declare function search:tm-search($request as xs:string, $lang as xs:string, $first-record as xs:double, $max-records as xs:double)  as element() {
    
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
    
    let $translations := collection($common:translations-path)
    
    let $results :=
        if ($request-bo) then
            for $result in 
                (
                    $translation-memory//tmx:tu[ft:query(tmx:tuv[@xml:lang eq 'bo']/tmx:seg, $query, $options)],
                    $translations//tei:back//tei:gloss[ft:query(tei:term[@xml:lang eq 'bo'], $query, $options)]
                )
                order by ft:score($result) descending
            return $result
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
                for $result in subsequence($results[local-name() = ('tu', 'gloss')], $first-record, $max-records)
                    
                    let $document-uri := base-uri($result)
                    let $document-uri-tokenized := tokenize($document-uri, '/')
                    let $file-name := $document-uri-tokenized[last()]
                    let $tei := 
                        if(local-name($result) eq 'tu') then
                            tei-content:tei(substring-before($file-name, '.xml'), 'translation')
                        else
                            doc($document-uri)/tei:TEI
                    let $expanded := util:expand($result, "expand-xincludes=no")
                    
                return
                    if($tei) then
                        <item>
                            { search:source('translation', $tei) }
                            { 
                                if(local-name($result) eq 'tu') then
                                    element match {
                                        attribute type { 'tm-unit' },
                                        attribute id { $result/tmx:prop[@name eq 'folio'] },
                                        element tibetan { $expanded/tmx:tuv[@xml:lang eq "bo"]/tmx:seg/node() },
                                        element translation { $result/tmx:tuv[@xml:lang eq "en"]/tmx:seg/node() }
                                    }
                                else
                                    element match {
                                        attribute type { 'glossary-term' },
                                        attribute id { $result/@xml:id },
                                        element tibetan { $expanded/tei:term[not(@type)][@xml:lang eq "bo"][exist:match] },
                                        element translation { $result/tei:term[not(@type)][not(@xml:lang) or @xml:lang eq "en"][1] },
                                        element sanskrit { $result/tei:term[not(@type)][@xml:lang eq "Sa-Ltn"][1] }
                                    }
                                     
                            }
                        </item>
                    else
                        ()
            }
            </results>
        </tm-search>

};
