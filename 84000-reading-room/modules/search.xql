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

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";
import module namespace source="http://read.84000.co/source" at "source.xql";
import module namespace kwic="http://exist-db.org/xquery/kwic";
import module namespace functx="http://www.functx.com";

declare function search:search($request as xs:string, $first-record as xs:double, $max-records as xs:double) {
    
    (: For now only search translations :)
    (:let $translations := collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $tei-content:published-statuses]:)
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
                <near slop="20" occur="should">{ lower-case($request) }</near>
                <wildcard occur="should">{ concat(lower-case($request),'*') }</wildcard>
            </bool>
        </query>
    
    let $results := 
        for $result in 
            $teis//tei:teiHeader/tei:fileDesc//tei:title[ft:query(., $query, $options)]
                | $teis//tei:teiHeader/tei:fileDesc//tei:author[ft:query(., $query, $options)]
                | $teis//tei:teiHeader/tei:fileDesc//tei:edition[ft:query(., $query, $options)]
                | $teis//tei:teiHeader/tei:fileDesc//tei:sourceDesc[ft:query(., $query, $options)]
                | $teis//tei:text//tei:p[ft:query(., $query, $options)]
                | $teis//tei:text//tei:lg[ft:query(., $query, $options)]
                | $teis//tei:text//tei:ab[ft:query(., $query, $options)]
                | $teis//tei:text//tei:trailer[ft:query(., $query, $options)]
                | $teis//tei:front//tei:list/tei:head[ft:query(., $query, $options)]
                | $teis//tei:body//tei:list/tei:head[ft:query(., $query, $options)]
                | $teis//tei:back//tei:bibl[ft:query(., $query, $options)]
                | $teis//tei:back//tei:gloss[ft:query(., $query, $options)]
            order by ft:score($result) descending
         return 
            $result
    
    return
        <search xmlns="http://read.84000.co/ns/1.0" >
            <request>{ $request }</request>
            <results
                first-record="{ $first-record }"
                max-records="{ $max-records }"
                count-records="{ count($results) }">
            {
                if ($request) then
 
                    for $result in subsequence($results, $first-record, $max-records)
                    
                        let $document-uri := base-uri($result)
                        let $tei := doc($document-uri)
                        let $id := tei-content:id($tei)
                        let $tei-type := 
                            if($tei//tei:teiHeader/tei:fileDesc/@type eq 'section') then
                                'section'
                            else
                                'translation'
                        let $status := $tei//tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status
                        let $source-bibl := tei-content:source-bibl($tei, '')
                        let $key :=  if($source-bibl/@key) then $source-bibl/@key else ''
                        let $parent-id := $source-bibl/tei:idno[@parent-id]/@parent-id
                        let $ancestors := tei-content:ancestors($tei, $key, 1)
                        
                        let $expanded := util:expand($result, "expand-xincludes=no")
                        let $node-name := node-name($expanded)
                        
                        let $hash := 
                            if($expanded/@xml:id/string()) then 
                                $expanded/@xml:id/string() 
                            else if($expanded/@tid/string()) then
                                concat('node', '-', $expanded/@tid/string())
                            else
                                ''
                        
                        let $url := 
                            if($tei-type eq 'translation' and functx:is-a-number($status) and xs:integer($status) = $tei-content:published-statuses) then
                                concat($common:environment/m:url[@id eq 'reading-room']/text() ,'/translation/', $key, '.html', if($hash) then concat('#', $hash) else '')
                            else if($tei-type eq 'section') then
                                concat($common:environment/m:url[@id eq 'reading-room']/text() ,'/section/', $id, '.html')
                            else
                                concat($common:environment/m:url[@id eq 'reading-room']/text() ,'/section/', $parent-id, '.html', concat('#', $key))
                         
                         let $translation-status := $tei//tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status
                         
                    return
                        <item>
                            <source 
                                resource-id="{ $id }" 
                                url="{ $url }"
                                tei-type="{ $tei-type }"
                                node-type="{ $node-name }"
                                translation-status="{ $translation-status }">
                                <title>{ tei-content:title($tei) }</title>
                                { $ancestors }
                            </source>
                            <text>
                            {
                                common:search-result($expanded)
                            }
                            </text>
                        </item>
               else
                    ()
            }
            </results>
        </search>
};

declare function search:translation-search($request as xs:string, $volume-number as xs:integer, $page-number as xs:integer, $results-mode as xs:string) as node() {

    <translation-search xmlns="http://read.84000.co/ns/1.0">
        <request volume-number="{ $volume-number }" page-number="{ $page-number }">
        { 
            $request
        }
        </request>
        {
            source:ekangyur-page(source:ekangyur-volume-number($volume-number), $page-number, true())
        }
        {
            source:ekangyur-volumes()
        }
        <results mode="{ $results-mode }">
        {
        
            if ($request) then
                
                  
                let $source := collection($common:ekangyur-path)
                
                let $options :=
                    <options>
                        <default-operator>or</default-operator>
                        <phrase-slop>0</phrase-slop>
                        <leading-wildcard>no</leading-wildcard>
                        <filter-rewrite>yes</filter-rewrite>
                    </options>
                    
                let $query := 
                    <query>
                        <phrase>{ $request }</phrase>
                    </query>
                    
                let $translations := collection($common:translations-path)
                
                for $text in $source//tei:body//tei:p[ft:query(., $query)]
                
                    let $document-uri := base-uri($text)
                    let $document := doc($document-uri)
                    let $ekangyur-id := $document//tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type eq 'TBRC_TEXT_RID']/text()
                    let $ekangyur-volume := substring-before(substring-after($ekangyur-id, 'UT4CZ5369-I1KG9'), '-0000')
                    let $volume-number := source:translation-volume-number(xs:integer($ekangyur-volume))
                    let $volume-number-pad := functx:pad-integer-to-length($volume-number, 3)
                    let $translation-id := concat('UT22084-', $volume-number-pad)
                    
                    let $expanded := util:expand($text, "expand-xincludes=no")
                    let $ekangyur-page := xs:integer($expanded/@n)
                    
                    let $folio := source:translation-folio($volume-number, $ekangyur-page)
                    
                    let $translation := 
                        $translations[tei:TEI
                            [tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[substring(@xml:id, 1, 11) = $translation-id]]
                            [tei:text/tei:body//tei:div[@type='translation']//tei:ref[@cRef eq $folio]]
                        ][1]
                        
                    let $title := 
                        if($translation) then
                            tei-content:title($translation)
                        else
                            ''
                    let $en := 
                        if($translation) then
                            translation:folio-content($translation, $folio, 0)
                        else
                            ()
                    
                    order by ft:score($text) descending
                    
                    return
                        if(not($results-mode eq 'translations') or $translation) then
                            <item>
                                <source ekangyur-id="{ $ekangyur-id }" ekangyur-volume="{ $ekangyur-volume }" ekangyur-page="{ $ekangyur-page }" />
                                <text xml:lang="bo">
                                {
                                    common:search-result($expanded)
                                }
                                </text>
                                <translation translation-id="{ $translation-id }">
                                    <title>
                                    {
                                        $title
                                    }
                                    </title>
                                </translation>
                                <text xml:lang="en" folio="{ $folio }">
                                {
                                    common:search-result($en)
                                }
                                </text>
                            </item>
                        else
                            ()
             else
                ()
         
        }
        </results>
    </translation-search>

};