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
import module namespace translation="http://read.84000.co/translation" at "translation.xql";
import module namespace source="http://read.84000.co/source" at "source.xql";
import module namespace kwic="http://exist-db.org/xquery/kwic";
import module namespace functx="http://www.functx.com";

declare function search:search($request) {
    
    let $translations := collection($common:translations-path)
    
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
    
    return
    
        <search xmlns="http://read.84000.co/ns/1.0">
            <request>{ $request }</request>
            <results>
            {
                if ($request) then
 
                    for $text in 
                        $translations//tei:teiHeader/tei:fileDesc//tei:title[ft:query(., $query, $options)]
                        | $translations//tei:teiHeader/tei:fileDesc//tei:author[ft:query(., $query, $options)]
                        | $translations//tei:teiHeader/tei:fileDesc//tei:edition[ft:query(., $query, $options)]
                        | $translations//tei:teiHeader/tei:fileDesc//tei:sourceDesc[ft:query(., $query, $options)]
                        | $translations//tei:text//tei:p[ft:query(., $query, $options)]
                        | $translations//tei:text//tei:lg[ft:query(., $query, $options)]
                        | $translations//tei:text//tei:ab[ft:query(., $query, $options)]
                        | $translations//tei:text//tei:trailer[ft:query(., $query, $options)]
                        | $translations//tei:front//tei:list/tei:head[ft:query(., $query, $options)]
                        | $translations//tei:body//tei:list/tei:head[ft:query(., $query, $options)]
                        | $translations//tei:back//tei:bibl[ft:query(., $query, $options)]
                        | $translations//tei:back//tei:gloss[ft:query(., $query, $options)]
 
                    let $document-uri := base-uri($text)
                    let $translation := doc($document-uri)
                    let $translation-id := translation:id($translation)
                    let $expanded := util:expand($text, "expand-xincludes=no")
                    let $node-name := node-name($expanded)
                    (: let $uid := $expanded/@xml:id/string() :)
                    let $uid := if($expanded/@xml:id/string()) then $expanded/@xml:id/string() else concat('node', '-', $expanded/@tid/string())
                    
                    order by ft:score($text) descending
                    
                    return
                        <item>
                            <source 
                                translation-id="{ $translation-id }" 
                                url="{
                                    if($uid) then
                                        concat($common:environment/m:reading-room-path ,'/translation/', $translation-id, '.html', '#', $uid)
                                    else
                                        concat('/translation/', $translation-id, '.html')
                                }"
                                type="{ $node-name }"
                                >
                            { 
                                $translation//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='mainTitle'][lower-case(@xml:lang)='en'][1]/text() 
                            }
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
                            translation:title($translation)
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