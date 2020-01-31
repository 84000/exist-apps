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
            let $alt-searches := 
                if($normalized-search eq 'a') then ('a','ā')
                else if($normalized-search eq 'd') then ('d','ḍ')
                else if($normalized-search eq 'h') then ('h','h','ḥ')
                else if($normalized-search eq 'i') then ('i','ī')
                else if($normalized-search eq 'l') then ('l','ḷ','ḹ')
                else if($normalized-search eq 'm') then ('m','ṃ','ṁ')
                else if($normalized-search eq 'n') then ('n','ṇ','ñ','ṅ')
                else if($normalized-search eq 'r') then ('r','ṛ','ṝ')
                else if($normalized-search eq 's') then ('s','ṣ','ś')
                else if($normalized-search eq 't') then ('t','ṭ')
                else if($normalized-search eq 'u') then ('u','ū')
                else $normalized-search
                
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

declare function glossary:glossary-items($term as xs:string, $lang as xs:string) as element() {

    <glossary
        xmlns="http://read.84000.co/ns/1.0"
        model-type="glossary-items">
        <key>{ $term }</key>
        {
            for $gloss in glossary:matching-gloss($term, $lang)
                
                let $translation := $gloss/ancestor::tei:TEI
                let $translation-title := tei-content:title($translation)
                let $translation-id := tei-content:id($translation)
                let $glossary-id := $gloss/@xml:id/string()
                let $uri := concat($common:environment/m:url[@id eq 'reading-room'], '/translation/', $translation-id, '.html#', $glossary-id)
                let $score := ft:score($gloss)
                
                order by $score descending
                
            return 
                <instance 
                    translation-id="{ $translation-id }"
                    uid="{ $glossary-id }"
                    uri="{ $uri }"
                    type="{ $gloss/@type }">
                    <term xml:lang="en">
                    {
                        $gloss/tei:term[not(@type)][@xml:lang eq 'en' or not(@xml:lang)]/text()[1] ! functx:capitalize-first(.) ! normalize-space(.)
                    }
                    </term>
                    {
                        for $term-alt-langs in $gloss/tei:term[@xml:lang = ('bo', 'Bo-Ltn', 'Sa-Ltn')][not(@type = ('definition','alternative'))]
                        return 
                            <term xml:lang="{ lower-case($term-alt-langs/@xml:lang) }">
                            {
                                if ($term-alt-langs[@xml:lang eq 'Bo-Ltn']/text()) then
                                    common:bo-ltn($term-alt-langs/text())
                                else
                                    $term-alt-langs/text() 
                            }
                            </term>
                    }
                    <definitions>
                    {
                        for $definition in $gloss/tei:term[@type = 'definition']
                        return
                            <definition>{ $definition/node() }</definition>
                    }
                    </definitions>
                    <alternatives>
                    {
                        for $alternative in $gloss/tei:term[@type = 'alternative']
                        return
                            element {'alternative'}
                            {
                                if($alternative/@xml:lang) then
                                    $alternative/@xml:lang
                                else 
                                    ()
                                ,
                                normalize-space(data($alternative))
                            }
                    }
                    </alternatives>
                    <translation>
                        <toh>{ $translation//tei:sourceDesc/tei:bibl[1]/tei:ref/text() }</toh>
                        <title>{ $translation-title }</title>
                        <authors>
                            {
                                for $author in $translation//tei:titleStmt/tei:author[not(@role = 'translatorMain')]
                                return 
                                    element author {
                                        $author/@ref,
                                        $author/text() ! normalize-space(.) 
                                    }
                            }
                            {
                                let $translator-main := $translation//tei:titleStmt/tei:author[@role = 'translatorMain'][1]
                                return
                                    element summary {
                                        $translator-main/@ref,
                                        $translator-main/text() ! concat(normalize-space(.), ' ') ! normalize-space(.) 
                                    }
                             }
                        </authors>
                        <editors>
                        {
                            for $editor in $translation//tei:titleStmt/tei:editor
                            return 
                                element editor {
                                    $editor/@ref,
                                    $editor/text() ! normalize-space(.) 
                                }
                        }
                        </editors>
                        <edition>{ $translation//tei:editionStmt/tei:edition[1]/text() ! concat(normalize-space(.), ' ') ! normalize-space(.) }</edition>
                    </translation>
                </instance>
        }
    </glossary>
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

declare function glossary:translation-glossary($tei as element(tei:TEI)) as element() {
    <glossary xmlns="http://read.84000.co/ns/1.0">
    {
        let $options := 
            <options>
                <default-operator>and</default-operator>
                <phrase-slop>0</phrase-slop>
                <leading-wildcard>no</leading-wildcard>
            </options>
            
        for $item in $tei//tei:back//*[@type='glossary']//tei:gloss
            let $query := glossary:item-query($item)
            (: glossary:ft-query(data($item/tei:term[@xml:lang eq 'en'][not(@type)] | $item/tei:term[not(@xml:lang)][not(@type)])) :)
        return
            <item 
                uid="{ $item/@xml:id/string() }" 
                type="{ $item/@type/string() }" 
                mode="{ $item/@mode/string() }">
                <term xml:lang="en">{ normalize-space(functx:capitalize-first(data($item/tei:term[@xml:lang eq 'en'][not(@type)] | $item/tei:term[not(@xml:lang)][not(@type)]))) }</term>
                {
                    for $item in $item/tei:term[@xml:lang = ('bo', 'Bo-Ltn', 'Sa-Ltn')][not(@type)]
                    return 
                        <term xml:lang="{ lower-case($item/@xml:lang) }">
                        { 
                            if ($item/@xml:lang eq 'Bo-Ltn') then
                                common:bo-ltn($item/text())
                            else
                                $item/text() 
                        }
                        </term>
                }
                <definitions>
                {
                    for $definition in $item/tei:term[@type = 'definition']
                    return
                        <definition>{ $definition/node() }</definition>
                }
                </definitions>
                <alternatives>
                {
                    for $alternative in $item/tei:term[@type = 'alternative']
                    return
                        <alternative xml:lang="{ lower-case($alternative/@xml:lang) }">
                        { 
                            normalize-space(data($alternative)) 
                        }
                        </alternative>
                }
                </alternatives>
                <passages>
                {
                    for $paragraph in 
                        $translation//tei:text//tei:p[ft:query(., $query, $options)]
                        | $translation//tei:text//tei:lg[ft:query(., $query, $options)]
                        | $translation//tei:text//tei:ab[ft:query(., $query, $options)]
                        | $translation//tei:text//tei:trailer[ft:query(., $query, $options)]
                    return
                        <passage tid="{ $paragraph/@tid }"/>
                }
                </passages>
            </item>
    }
    </glossary>
};
