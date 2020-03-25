xquery version "3.1" encoding "UTF-8";
(:
    Returns the cumulative glossary xml
    -------------------------------------------------------------
:)
module namespace glossary="http://read.84000.co/glossary";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";
import module namespace functx="http://www.functx.com";

declare variable $glossary:translations := 
    collection($common:translations-path)//tei:TEI
        [tei:teiHeader/tei:fileDesc/tei:publicationStmt
            [@status = $tei-content:published-status-ids]
            (:[tei:idno/@xml:id = ("UT22084-031-002", "UT22084-066-018")] Restrict files for testing :)
        ];

declare variable $glossary:types := ('term', 'person', 'place', 'text');

declare function glossary:lookup-options() as element() {
    <options>
        <default-operator>or</default-operator>
        <phrase-slop>0</phrase-slop>
        <leading-wildcard>no</leading-wildcard>
        <filter-rewrite>yes</filter-rewrite>
    </options>
};

declare function glossary:lookup-query($string as xs:string) as element() {
    <query>
        <phrase occur="must">
            { $string }
        </phrase>
    </query>
};

declare function glossary:search-options() as element() {
    <options>
        <default-operator>or</default-operator>
        <phrase-slop>0</phrase-slop>
        <leading-wildcard>yes</leading-wildcard>
        <filter-rewrite>yes</filter-rewrite>
    </options>
};

declare function glossary:search-query($string as xs:string) as element() {
    <query>
        <bool>
            <near slop="20" occur="must">
                { $string }
            </near>
        </bool>
    </query>
};

declare function glossary:valid-type($type as xs:string) as xs:string {
    if(lower-case($type) = $glossary:types) then
        lower-case($type)
    else
        ''
};

declare function glossary:lang-field($valid-lang as xs:string) as xs:string {
    if($valid-lang eq 'Sa-Ltn-x') then
        'sa-term'
    else
        'full-term'
};

declare function glossary:glossary-terms($type as xs:string*, $lang as xs:string, $search as xs:string, $include-count as xs:boolean) as element() {
    
    let $valid-lang := common:valid-lang($lang)
    let $valid-type := glossary:valid-type($type)
    let $empty-term-placeholders := (common:local-text('glossary.term-empty-sa-ltn', 'en'), common:local-text('glossary.term-empty-bo-ltn', 'en'))
    
    let $normalized-search := common:alphanumeric(common:normalized-chars($search))
    
    let $terms := 
        
        (: Search for term - all languages and types :)
        if($type eq 'search' and $normalized-search gt '') then
            $glossary:translations//tei:back//tei:gloss/tei:term
                [not(@type eq 'definition')]
                [ft:query(., glossary:search-query($normalized-search), glossary:search-options())]
        
        (: Look-up terms based on letter, type and lang :)
        else if($valid-type gt '' and $normalized-search gt '') then
            
            (: this shouldn't be necessary if collation were working!?? :)
            let $alt-searches := common:letter-variations($normalized-search)
                
            return
                if($valid-lang = ('en', '')) then
                    $glossary:translations//tei:back//tei:gloss[@type = $valid-type]/tei:term
                       [not(@xml:lang) or @xml:lang eq 'en']
                       [not(@type = ('definition','alternative'))]
                       [matches(., concat('^(\d*\s+|The\s+|A\s+)?(', string-join($alt-searches, '|'), ').*'), 'i')]
                else
                    $glossary:translations//tei:back//tei:gloss[@type = $valid-type]/tei:term
                        [@xml:lang eq $valid-lang]
                        [not(@type = ('definition','alternative'))]
                        [matches(., concat('^(\d*\s+|The\s+|A\s+)?(', string-join($alt-searches, '|'), ').*'), 'i')]
        
        (: All terms for type and lang :)
        else if($valid-type gt '') then
            if($valid-lang = ('en', '')) then
                $glossary:translations//tei:back//tei:gloss[@type = $valid-type]/tei:term
                    [not(@xml:lang) or @xml:lang eq 'en']
                    [not(@type = ('definition','alternative'))]
            else
                $glossary:translations//tei:back//tei:gloss[@type = $valid-type]/tei:term
                    [@xml:lang eq $valid-lang]
                    [not(@type = ('definition','alternative'))]
        
        (: All terms for cumulative glossary :)
        else if($type eq 'all') then
            $glossary:translations//tei:back//tei:gloss/tei:term
                [not(@type = ('definition','alternative'))]
        
        (: All terms for lang only :)
        else
            if($valid-lang = ('en', '')) then
                $glossary:translations//tei:back//tei:gloss/tei:term
                    [not(@xml:lang) or @xml:lang eq 'en']
                    [not(@type = ('definition','alternative'))]
            else
                $glossary:translations//tei:back//tei:gloss/tei:term
                    [@xml:lang eq $valid-lang]
                    [not(@type = ('definition','alternative'))]
    
    return
        <glossary
            xmlns="http://read.84000.co/ns/1.0"
            model-type="glossary-terms"
            type="{ $valid-type }"
            lang="{ $valid-lang }"
            search="{ $normalized-search }">
        {
            for $term in $terms[normalize-space()][not(text() = $empty-term-placeholders)]
                
                let $normalized-term := 
                    normalize-space(
                        replace(
                            common:normalized-chars(
                                normalize-unicode(
                                    replace(
                                        normalize-space(
                                            $term
                                        )
                                    , '\-­'(: soft-hyphen :), '')
                                , 'NFC')
                            )
                        , '[^a-zA-Z\s]', '')
                    )
                
                group by $normalized-term
                
                let $matches := 
                    if($include-count) then
                        glossary:matching-gloss($term[1], if(not($term[1]/@xml:lang)) then 'en' else $term[1]/@xml:lang)
                    else
                        ()
                
                let $score := ft:score($term[1])
                
                order by $normalized-term
                where $normalized-term gt ''
            return
                <term start-letter="{ substring($normalized-term, 1, 1) }" count-items="{ count($matches) }" score="{ $score }">
                    <main-term xml:lang="{ if(not($term[1]/@xml:lang)) then 'en' else $term[1]/@xml:lang }">{ normalize-space($term[1]) }</main-term>
                    <normalized-term>{ $normalized-term }</normalized-term>
                </term>
                
        }
        </glossary>
        
};

declare function glossary:matching-gloss($term as xs:string, $lang as xs:string) as element()* {
    
    let $valid-lang := common:valid-lang($lang)
    
    return
        if($valid-lang eq 'en') then
            $glossary:translations//tei:back//tei:gloss/tei:term
                [not(@type eq 'definition')]
                [not(@xml:lang) or @xml:lang eq 'en']
                [ft:query-field(
                    'full-term',
                    glossary:lookup-query($term),
                    glossary:lookup-options()
                )]/parent::tei:gloss
        else if($valid-lang gt '') then
            $glossary:translations//tei:back//tei:gloss/tei:term
                [not(@type eq 'definition')]
                [ft:query-field(
                    'full-term',
                    glossary:lookup-query($term),
                    glossary:lookup-options()
                )]/parent::tei:gloss
        else
            $glossary:translations//tei:back//tei:gloss/tei:term
                [not(@type eq 'definition')]
                [ft:query-field(
                    'full-term',
                    glossary:lookup-query($term),
                    glossary:lookup-options()
                )]/parent::tei:gloss
            
};

declare function glossary:items($glossary-ids as xs:string*, $include-context as xs:boolean) as element(m:item)* {
    
    for $gloss in $glossary:translations//tei:back//tei:gloss[@xml:id = $glossary-ids]
    return
        glossary:item($gloss, $include-context)     
};

declare function glossary:item($gloss as element(tei:gloss)) as element(m:item) {
    glossary:item($gloss, false())
};

declare function glossary:item($gloss as element(tei:gloss), $include-context as xs:boolean) as element(m:item) {
(
    <item xmlns="http://read.84000.co/ns/1.0"
        uid="{ $gloss/@xml:id/string() }" 
        type="{ $gloss/@type/string() }" 
        mode="{ $gloss/@mode/string() }">
        {
            element { QName('http://read.84000.co/ns/1.0','sort-term') }{
                common:alphanumeric(
                    common:normalized-chars(
                        $gloss/tei:term[not(@xml:lang) or @xml:lang eq 'en'][not(@type)][1]/text()
                    )
                )
            },
            for $term in $gloss/tei:term
            return 
                 if($term[not(@type)][not(@xml:lang) or @xml:lang eq 'en']) then
                    <term xml:lang="en">
                    { 
                        functx:capitalize-first(
                            normalize-space(
                                $term/text()
                            )
                        ) 
                    }
                    </term>
                else if($term[not(@type)][@xml:lang][not(@xml:lang eq 'en')]) then
                    <term xml:lang="{ lower-case($term/@xml:lang) }">
                    {
                        if (not($term/text())) then
                            common:local-text(
                                concat('glossary.term-empty-', lower-case($term/@xml:lang)), 
                                'en'
                            )
                        else if ($term/@xml:lang eq 'Bo-Ltn') then 
                            common:bo-ltn(
                                $term/text()
                             )
                        else 
                            normalize-space(
                                $term/text()
                            )
                    }
                    </term>
                else if ($term[@type eq 'alternative']) then
                    <alternative xml:lang="{ lower-case($term/@xml:lang) }">
                    { 
                        normalize-space(
                            data($term)
                        ) 
                    }
                    </alternative>
                else if($term[@type eq 'definition']) then
                    <definition>
                    { 
                        $term/node() 
                    }
                    </definition>
                else
                    ()
            ,
            if($include-context) then
            
                let $tei := $gloss/ancestor::tei:TEI
                let $translation-id := tei-content:id($tei)
                
                return
                    <text 
                        id="{ $translation-id }"
                        uri="{ concat($common:environment/m:url[@id eq 'reading-room'], '/translation/', $translation-id, '.html#', $gloss/@xml:id/string()) }">
                        <toh>
                        {
                            $tei//tei:sourceDesc/tei:bibl[1]/tei:ref/text()
                        }
                        </toh>
                        <title>
                        {   
                            tei-content:title($tei)
                        }
                        </title>
                        <authors>
                        {
                            for $author in $tei//tei:titleStmt/tei:author[not(@role = 'translatorMain')]
                            return 
                                element author {
                                    $author/@ref,
                                    $author/text() ! normalize-space(.) 
                                }
                            ,
                            let $translator-main := $tei//tei:titleStmt/tei:author[@role = 'translatorMain'][1]
                            return
                                element summary {
                                    $translator-main/@ref,
                                    $translator-main/text() ! concat(normalize-space(.), ' ') ! normalize-space(.) 
                                }
                         }
                        </authors>
                        <editors>
                        {
                            for $editor in $tei//tei:titleStmt/tei:editor
                            return 
                                element editor {
                                    $editor/@ref,
                                    $editor/text() ! normalize-space(.) 
                                }
                        }
                        </editors>
                        <edition>
                        {
                            $tei//tei:editionStmt/tei:edition[1]/text() ! concat(normalize-space(.), ' ') ! normalize-space(.) 
                        }
                        </edition>
                    </text>
            else
                ()
         }
    </item>
)
};

declare function glossary:glossary-items($term as xs:string, $lang as xs:string) as element() {

    <glossary
        xmlns="http://read.84000.co/ns/1.0"
        model-type="glossary-items">
        <key>{ $term }</key>
        {
            for $gloss in glossary:matching-gloss($term, $lang)
                order by ft:score($gloss) descending
            return 
                glossary:item($gloss, true())
        }
    </glossary>
};

declare function glossary:similar-items($glossary-items as element(m:item)*) as element(m:item)* {
    
    (: Potential matches for the passed glossary items :)
    
    let $search-query :=
        <query>
            <bool>
            {
                for $term in $glossary-items//m:term[not(@type = 'definition')]
                return
                    <phrase>
                    {
                        common:alphanumeric(
                            common:normalized-chars(
                                $term
                             )
                         )
                    }
                    </phrase>
            }
            </bool>
        </query>
    
    let $request-ids := $glossary-items/@uid
    
    for $similar-item in 
        $glossary:translations//tei:back//tei:gloss
            (: Exclude items in request :)
            [not(@xml:id = $request-ids)]
            (: Search for similar items :)
            [
                tei:term
                    [not(@type eq 'definition')]
                    [ft:query(., $search-query, glossary:search-options())]
            ]
    order by ft:score($similar-item) descending
    return
         glossary:item($similar-item, true())
};

declare function glossary:cumulative-glossary($chunk as xs:integer) as element() {

    let $cumulative-terms := glossary:glossary-terms('all', '', '', false())//m:term
    let $count := count($cumulative-terms)
    let $chunk-length := 5000
    let $first := (($chunk - 1) * $chunk-length) + 1
    let $last := if((($first + $chunk-length) - 1) gt $count) then $count else ($first + $chunk-length) - 1
    
    return
        <cumulative-glossary xmlns="http://read.84000.co/ns/1.0" 
            terms-count="{ $count }" 
            chunk="{ $chunk }" first-listing="{ $first }" last-listing="{ $last }">
            <disclaimer>
            {
                common:local-text('cumulative-glossary.disclaimer', 'en')
            }
            </disclaimer>
            {
                for $term at $position in subsequence($cumulative-terms, $first, $chunk-length)
                return
                    <term listing-number="{ ($first + $position) - 1 }">
                    {
                        glossary:glossary-items($term/m:main-term, $term/m:main-term/@xml:lang)/*
                    }
                    </term>
            }
        </cumulative-glossary>
        
};

declare function glossary:item-count($tei as element(tei:TEI)) as xs:integer {

    count($tei//tei:back//tei:div[@type eq 'glossary']//tei:item)
    
};

declare function glossary:item-query($gloss as element(tei:gloss)) as element() {
    <query>
        <bool>
        {
            for $term in 
                $gloss/tei:term[@xml:lang eq 'en'][not(@type)] 
                | $gloss/tei:term[not(@xml:lang)][not(@type)]
                | $gloss/tei:term[@type = 'alternative']
            let $term-str := normalize-space(data($term))
            return 
                (
                    <phrase>{ $term-str }</phrase>,
                    <phrase>{ $term-str }s</phrase>
                )
        }
        </bool>
    </query>
};

