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

declare function search:search($request as xs:string, $first-record as xs:double, $max-records as xs:double) {
    
    let $teis := collection($common:tei-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno/@xml:id]
    
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
                <near slop="20" occur="should">{ common:normalized-chars($request) }</near>
                <wildcard occur="should">{ concat(common:normalized-chars($request),'*') }</wildcard>
            </bool>
        </query>
    
    let $results :=
        for $result in 
            $teis//tei:teiHeader/tei:fileDesc//tei:title[ft:query(., $query, $options)]
                | $teis//tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:ref[ft:query(., $query, $options)]
                | $teis//tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblScope[ft:query(., $query, $options)]
                | $teis//tei:text//tei:p[ft:query(., $query, $options)]
                | $teis//tei:text//tei:lg[ft:query(., $query, $options)]
                | $teis//tei:text//tei:ab[ft:query(., $query, $options)]
                | $teis//tei:text//tei:trailer[ft:query(., $query, $options)]
                | $teis//tei:front//tei:list/tei:head[ft:query(., $query, $options)]
                | $teis//tei:body//tei:list/tei:head[ft:query(., $query, $options)]
                | $teis//tei:back//tei:bibl[ft:query(., $query, $options)]
                | $teis//tei:back//tei:gloss[ft:query(., $query, $options)]
            
            let $document-uri := base-uri($result)
            group by $document-uri
            let $scores := 
                for $single in $result
                return
                    ft:score($single)
            order by sum($scores) descending
         
         return 
            <result-group xmlns="http://read.84000.co/ns/1.0" document-uri="{ $document-uri }">
            {
               util:expand($result, "expand-xincludes=no")
            }
            </result-group>
    
    return 
        <search xmlns="http://read.84000.co/ns/1.0" >
            <request>{ $request }</request>
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
                        <item>
                            {
                                search:source($tei-type, $tei)
                            }
                            {
                                for $node in $result-group/*
                                return
                                    <match>
                                    {
                                        attribute node-type { node-name($node) },
                                        $node/@*,
                                        $node/node()
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