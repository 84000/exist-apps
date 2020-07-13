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
import module namespace entities="http://read.84000.co/entities" at "entities.xql";
import module namespace functx="http://www.functx.com";

declare variable $glossary:translations := 
    collection($common:translations-path)//tei:TEI
        [tei:teiHeader/tei:fileDesc/tei:publicationStmt
            [@status = $tei-content:published-status-ids]
            (:[tei:idno/@xml:id = ("UT22084-031-002", "UT22084-066-018")] Restrict files for testing :)
        ];

declare variable $glossary:types := ('term', 'person', 'place', 'text');
declare variable $glossary:modes := ('match', 'marked');

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

declare function glossary:sort-term($gloss as element(tei:gloss)) as xs:string? {
    $gloss/tei:term[not(@xml:lang) or @xml:lang eq 'en'][not(@type)][1]/text() ! lower-case(.) ! common:normalized-chars(.) ! common:alphanumeric(.)
};

declare function glossary:item($gloss as element(tei:gloss), $include-context as xs:boolean) as element(m:item) {
    
    element { QName('http://read.84000.co/ns/1.0', 'item') } {
        
        (: TO DO: revert this to @xml:id? Don't know why we rename the attribute here :)
        attribute uid { $gloss/@xml:id },
        
        $gloss/@mode,
        
        (: TO BE DEPRECATED - use entity types instead :)
        $gloss/@type,
        
        (: Sort term :)
        element sort-term {
            glossary:sort-term($gloss)
        },
        
        (: Terms and definition :)
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
        
        (: Include the cache :)
        $gloss/m:cache,
        
        (: Context :)
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
};

declare function glossary:glossary-items($term as xs:string, $lang as xs:string) as element(m:glossary) {

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

declare function glossary:similar-items($glossary-item as element(m:item)?, $search-string as xs:string?) as element(m:item)* {
    
    (: Potential matches for the passed glossary item :)
    
    if($glossary-item) then
    
        (: Get similar entities :)
        let $entity := entities:entities($glossary-item/@uid)/m:entity
        let $instance-ids := ($entity/m:instance/@id, $glossary-item/@uid) ! distinct-values(.)
        let $instance-items := glossary:items($instance-ids, false())
        let $instance-terms := ($instance-items//m:term[@xml:lang = ('bo', 'sa-ltn')] | $instance-items//m:alternatives[@xml:lang = ('bo', 'sa-ltn')]) ! distinct-values(.)
        let $exclude-ids := ($entities:entities/m:entities/m:entity[@xml:id = $entity/m:exclude/@id]/m:instance/@id, $glossary-item/@uid, $instance-ids) ! distinct-values(.)
        let $search-string := normalize-space($search-string)
        
        let $search-query :=
            <query>
                <bool>
                {
                    for $term in $instance-terms
                    let $normalized-term := common:alphanumeric(common:normalized-chars($term))
                    where $normalized-term gt ''
                    return
                        <phrase>{ $normalized-term }</phrase>
                    ,
                    if($search-string gt '') then
                        <phrase>{ $search-string }</phrase>
                    else ()
                }
                </bool>
            </query>
        
        for $similar-item in 
            $glossary:translations//tei:back//tei:gloss
                [not(@xml:id = $exclude-ids)]
                [tei:term[@xml:lang = ('bo', 'Sa-Ltn')]/ft:query(., $search-query, glossary:lookup-options())]
        
        order by ft:score($similar-item) descending
        return
             glossary:item($similar-item, true())
    else
        ()
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

declare function glossary:translation-data($tei as element(tei:TEI), $resource-id as xs:string) as element(m:translation) {
    
    (: Compile the translation data - we need text-id and toh-key :)
    let $source := tei-content:source($tei, $resource-id)
    let $toh-key := $source/@key
    
    let $translation-data := 
        <translation 
            xmlns="http://read.84000.co/ns/1.0" 
            id="{ tei-content:id($tei) }"
            status="{ tei-content:translation-status($tei) }"
            status-group="{ tei-content:translation-status-group($tei) }"
            page-url="{ translation:canonical-html($toh-key) }">
            {(
                translation:titles($tei),
                $source,
                translation:preface($tei),
                translation:introduction($tei),
                translation:prologue($tei),
                translation:homage($tei),
                translation:body($tei),
                translation:colophon($tei),
                translation:appendix($tei),
                translation:notes($tei),
                translation:glossary($tei)
            )}
        </translation>
    
    (: Parse the milestones :)
    let $translation-data := 
        transform:transform(
            $translation-data,
            doc(concat($common:app-path, "/xslt/milestones.xsl")), 
            <parameters/>
        )
    
    (: Parse the refs and pointers :)
    let $translation-data := 
        transform:transform(
            $translation-data,
            doc(concat($common:app-path, "/xslt/internal-refs.xsl")), 
            <parameters/>
        )
        
    return
        $translation-data
};


declare function glossary:filter($translation-milestones-internal-refs as element(m:translation), $filter as xs:string, $search as xs:string) as element(m:glossary) {
    
    let $text-id := $translation-milestones-internal-refs/@id
    let $tei := tei-content:tei($text-id, 'translation')
    
    let $entity-instance-ids := $entities:entities/m:entities/m:entity/m:instance/@id/string()
    
    (: Pre-defined filters :)
    let $tei-gloss :=
        if($filter eq 'missing-entities') then
            $tei//tei:back//tei:div[@type eq 'glossary']//tei:gloss[not(@xml:id = $entity-instance-ids)]
        else if($filter eq 'no-cache') then
            $tei//tei:back//tei:div[@type eq 'glossary']//tei:gloss[not(m:cache)]
        else if($filter eq 'blank-form') then
            ()
        else
            $tei//tei:back//tei:div[@type eq 'glossary']//tei:gloss
    
    (: Search :)
    let $tei-gloss := 
        if(normalize-space($search) gt '') then
            $tei-gloss[tei:term/ft:query(., glossary:search-query($search), glossary:search-options())]
        else
            $tei-gloss
    
    (: Expression filters :)
    let $translation-glossarized := 
        if($filter eq 'new-expressions') then
            transform:transform(
                $translation-milestones-internal-refs,
                doc(concat($common:app-path, "/xslt/glossarize.xsl")), 
                <parameters>
                    <param name="use-cache" value="false"/>
                </parameters>
            )
        else
            $translation-milestones-internal-refs
    
    return
        element { node-name($translation-glossarized/m:glossary) }{
            $translation-glossarized/m:glossary/@*,
            
            attribute filter { $filter },
            attribute text-id { $text-id },
            element search { $search },
            
            for $gloss in $tei-gloss
            
                let $search-score := if(normalize-space($search) gt '') then ft:score($gloss) else 1
                
                (: It seems to be significantly quicker to re-create the glossary-item than look it up :)
                let $glossary-item := glossary:item($gloss, false()) (: $translation-milestones-internal-refs/m:glossary/m:item[@uid = $gloss/@xml:id/string()] :)
                
                (: Expression items :)
                let $expression-items := 
                    if($filter eq 'new-expressions') then
                        glossary:expression-items($translation-glossarized, $glossary-item/@uid)
                    else
                        ()
                
            where 
                (: If filtering by new expressions, return where there are expression items not in the cache :)
                not($filter eq 'new-expressions') 
                or $expression-items[not(@nearest-xml-id = $gloss/m:cache/m:expression/@location)]
            
            order by 
                $search-score descending,
                $glossary-item/m:sort-term
                
            return
                element { node-name($glossary-item) }{
                    $glossary-item/@*,
                    $glossary-item/node(),
                    
                    (: Add this to save work later :)
                    if($filter eq 'new-expressions') then
                        element { QName('http://read.84000.co/ns/1.0', 'expressions') }{     
                            
                            (: Specify the context :)
                            attribute text-id { $translation-glossarized/@id },
                            attribute toh-key { $translation-glossarized/m:source/@key },
                            attribute reading-room-url { $common:environment/m:url[@id eq 'reading-room']/text() },
                            
                            (: Expression items :)
                            $expression-items
                        }
                    else ()
                }
        }
};

declare function glossary:expressions($translation-milestones-internal-refs as element(m:translation), $glossary-id as xs:string) as element(m:expressions) {

    let $translation-glossarized := 
        transform:transform(
            $translation-milestones-internal-refs,
            doc(concat($common:app-path, "/xslt/glossarize.xsl")), 
            <parameters>
                <param name="glossary-id" value="{ $glossary-id }"/>
                <param name="use-cache" value="false"/>
            </parameters>
        )
        
    return
    element { QName('http://read.84000.co/ns/1.0', 'expressions') }{     
    
        (: Specify the context :)
        attribute text-id { $translation-milestones-internal-refs/@id },
        attribute toh-key { $translation-milestones-internal-refs/m:source/@key },
        attribute reading-room-url { $common:environment/m:url[@id eq 'reading-room']/text() },
        
        (: Expression items :)
        glossary:expression-items($translation-glossarized, $glossary-id)
    }
};

declare function glossary:expression-items($translation-glossarized as element(m:translation), $glossary-id as xs:string) as element(m:item)* {

    for $match at $match-position in $translation-glossarized//tei:match[@glossary-id = $glossary-id]
    
        (: Expand to the node containing the match :)
        let $match-context := ($match/ancestor-or-self::*[@nearest-milestone][1], $match/ancestor-or-self::*[@uid][1])[1]
        
        (: Group by nearest id - either milestone or glossary id :)
        let $nearest-xml-id := ($match-context/@nearest-milestone, $match-context/@uid)[1]
        
        (: Get the nearest milestone :)
        let $preceding-ref := 
            if($match-context/preceding-sibling::*[descendant::tei:ref[@ref-index]]) then
                $match-context/preceding-sibling::*[descendant::tei:ref[@ref-index]][1]/descendant::tei:ref[@ref-index][1]
            else
                (: To do: find the preceding folio outside of the scope of this match-context :)
                ()
        
        group by $nearest-xml-id
        
        (: Retain the position :)
        order by $match-position[1]
    
    return
        
        (: Return an item per nearest milestone :)
        element { QName('http://read.84000.co/ns/1.0', 'item') }{
        
            attribute nearest-xml-id { $nearest-xml-id },
            
            (: Include the nearest milestone :)
            $translation-glossarized//tei:milestone[@xml:id eq $nearest-xml-id],
            
            (: Return the data - this needs grouping as a context may have multiple matches, but a milestone may have multiple contexts :)
            for $match-context-single at $context-position in $match-context
                group by $match-context-single
                order by $context-position[1]
            return
            
                (: It's a note :)
                if($match-context-single[self::m:note]) then
                    element m:notes {
                        attribute prefix { 'n' },
                        element m:note {
                            $match-context-single/@*,
                            $match-context-single/node()
                        }
                    }
                
                (: It's a glossary definition :)
                else if($match-context-single[self::m:item]) then
                    element m:glossary {
                        attribute prefix { 'g' },
                        element m:item {
                            $match-context-single/@*,
                            $match-context-single/node()
                        }
                    }
                
                (: It's something else :)
                else
                    element { node-name($match-context-single) } {
                        $match-context-single/@*,
                        
                        (: prepend the preceding source ref :)
                        if($context-position[1] eq 1) then (
                            $preceding-ref[1],
                            text { ' ... ' }
                        )
                        else ()
                        ,
                        $match-context-single/node()
                    }
        }

};

