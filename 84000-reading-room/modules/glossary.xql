xquery version "3.1" encoding "UTF-8";
(:
    Returns the cumulative glossary xml
    -------------------------------------------------------------
:)
module namespace glossary="http://read.84000.co/glossary";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

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

declare function local:lookup-options() as element() {
    <options>
        <default-operator>or</default-operator>
        <phrase-slop>0</phrase-slop>
        <leading-wildcard>no</leading-wildcard>
        <filter-rewrite>yes</filter-rewrite>
    </options>
};

declare function local:lookup-query($string as xs:string) as element() {
    <query>
        <phrase occur="must">
            { $string }
        </phrase>
    </query>
};

declare function local:search-options() as element() {
    <options>
        <default-operator>or</default-operator>
        <phrase-slop>0</phrase-slop>
        <leading-wildcard>yes</leading-wildcard>
        <filter-rewrite>yes</filter-rewrite>
    </options>
};

declare function local:search-query($string as xs:string) as element() {
    <query>
        <bool>
            <near slop="20" occur="must">{ $string }</near>
        </bool>
    </query>
};

declare function local:valid-type($type as xs:string) as xs:string {
    if(lower-case($type) = $glossary:types) then
        lower-case($type)
    else
        ''
};

declare function local:lang-field($valid-lang as xs:string) as xs:string {
    if($valid-lang eq 'Sa-Ltn-x') then
        'sa-term'
    else
        'full-term'
};

declare function glossary:glossary-terms($type as xs:string*, $lang as xs:string, $search as xs:string, $include-count as xs:boolean) as element() {
    
    let $valid-lang := common:valid-lang($lang)
    let $valid-type := local:valid-type($type)
    let $empty-term-placeholders := (common:local-text('glossary.term-empty-sa-ltn', 'en'), common:local-text('glossary.term-empty-bo-ltn', 'en'))
    
    let $normalized-search := common:alphanumeric(common:normalized-chars($search))
    
    let $terms := 
        
        (: Search for term - all languages and types :)
        if($type eq 'search' and $normalized-search gt '') then
            $glossary:translations//tei:back//tei:gloss[@xml:id]/tei:term
                [not(@type eq 'definition')]
                [ft:query(., local:search-query($normalized-search), local:search-options())]
        
        (: Look-up terms based on letter, type and lang :)
        else if($valid-type gt '' and $normalized-search gt '') then
            
            (: this shouldn't be necessary if collation were working!?? :)
            let $alt-searches := common:letter-variations($normalized-search)
                
            return
                if($valid-lang = ('en', '')) then
                    $glossary:translations//tei:back//tei:gloss[@xml:id][@type = $valid-type]/tei:term
                       [not(@xml:lang) or @xml:lang eq 'en']
                       [not(@type = ('definition','alternative'))]
                       [matches(., concat('^(\d*\s+|The\s+|A\s+)?(', string-join($alt-searches, '|'), ').*'), 'i')]
                else
                    $glossary:translations//tei:back//tei:gloss[@xml:id][@type = $valid-type]/tei:term
                        [@xml:lang eq $valid-lang]
                        [not(@type = ('definition','alternative'))]
                        [matches(., concat('^(\d*\s+|The\s+|A\s+)?(', string-join($alt-searches, '|'), ').*'), 'i')]
        
        (: All terms for type and lang :)
        else if($valid-type gt '') then
            if($valid-lang = ('en', '')) then
                $glossary:translations//tei:back//tei:gloss[@xml:id][@type = $valid-type]/tei:term
                    [not(@xml:lang) or @xml:lang eq 'en']
                    [not(@type = ('definition','alternative'))]
            else
                $glossary:translations//tei:back//tei:gloss[@xml:id][@type = $valid-type]/tei:term
                    [@xml:lang eq $valid-lang]
                    [not(@type = ('definition','alternative'))]
        
        (: All terms for cumulative glossary :)
        else if($type eq 'all') then
            $glossary:translations//tei:back//tei:gloss[@xml:id]/tei:term
                [not(@type = ('definition','alternative'))]
        
        (: All terms for lang only :)
        else
            if($valid-lang = ('en', '')) then
                $glossary:translations//tei:back//tei:gloss[@xml:id]/tei:term
                    [not(@xml:lang) or @xml:lang eq 'en']
                    [not(@type = ('definition','alternative'))]
            else
                $glossary:translations//tei:back//tei:gloss[@xml:id]/tei:term
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
            $glossary:translations//tei:back//tei:gloss[@xml:id]/tei:term
                [not(@type eq 'definition')]
                [not(@xml:lang) or @xml:lang eq 'en']
                [ft:query-field(
                    'full-term',
                    local:lookup-query($term),
                    local:lookup-options()
                )]/parent::tei:gloss
        else if($valid-lang gt '') then
            $glossary:translations//tei:back//tei:gloss[@xml:id]/tei:term
                [not(@type eq 'definition')]
                [ft:query-field(
                    'full-term',
                    local:lookup-query($term),
                    local:lookup-options()
                )]/parent::tei:gloss
        else
            $glossary:translations//tei:back//tei:gloss[@xml:id]/tei:term
                [not(@type eq 'definition')]
                [ft:query-field(
                    'full-term',
                    local:lookup-query($term),
                    local:lookup-options()
                )]/parent::tei:gloss
            
};

declare function glossary:items($glossary-ids as xs:string*, $include-context as xs:boolean) as element(m:item)* {
    
    for $gloss in 
        if(count($glossary-ids) gt 0) then
            $glossary:translations//tei:back//tei:gloss[@xml:id = $glossary-ids]
        else
            ()
    return
        local:glossary-item($gloss, $include-context)     
};

declare function glossary:sort-term($gloss as element(tei:gloss)) as element(m:sort-term)? {

    let $sort-term := $gloss/tei:term[not(@xml:lang) or @xml:lang eq 'en'][not(@type = ('definition','alternative'))][1]/text() ! normalize-space(.) ! lower-case(.) ! common:normalized-chars(.) ! common:alphanumeric(.)
    let $terms-en := $gloss/tei:term[not(@xml:lang) or @xml:lang eq 'en'][not(@type = ('definition'))]/text() ! normalize-space(.)
    let $term-word-count := max($terms-en ! count(tokenize(., '\s+')))
    let $term-letter-count := max($terms-en ! string-length(.))
    return
        element { QName('http://read.84000.co/ns/1.0', 'sort-term') } {
            attribute word-count { $term-word-count },
            attribute letter-count { $term-letter-count },
            text { $sort-term }
        }
        
};

declare function local:glossary-item($gloss as element(tei:gloss), $include-context as xs:boolean) as element(m:item) {
    
    element { QName('http://read.84000.co/ns/1.0', 'item') } {
        
        attribute id { $gloss/@xml:id },
        $gloss/@mode,
        
        (: TO BE DEPRECATED - use entity types instead :)
        $gloss/@type,
        
        (: Sort term :)
        glossary:sort-term($gloss),
        
        (: Terms and definition :)
        for $term in $gloss/tei:term
        return 
             if($term[not(@type = ('definition','alternative'))][not(@xml:lang) or @xml:lang eq 'en']) then
                element term {
                    attribute xml:lang { 'en' },
                    $term/@type,
                    text {
                        functx:capitalize-first(
                            normalize-space($term/text())
                        )
                    }
                }
            else if($term[not(@type = ('definition','alternative'))][@xml:lang][not(@xml:lang eq 'en')]) then
                element term {
                    $term/@xml:lang,
                    $term/@type,
                    text {
                        if (not($term[text()])) then
                            common:local-text(concat('glossary.term-empty-', lower-case($term/@xml:lang)), 'en')
                        else if ($term/@xml:lang eq 'Bo-Ltn') then 
                            common:bo-ltn($term/text())
                        else 
                            normalize-space($term/text())
                    }
                }
            else if ($term[@type eq 'alternative']) then
                element alternative {
                    $term/@xml:lang,
                    text {
                        normalize-space(data($term)) 
                    }
                }
            else if($term[@type eq 'definition']) then
                element definition {
                    $term/node()
                }
            else
                ()
        ,
        
        (: Include the context :)
        if($include-context) then
        
            let $tei := $gloss/ancestor::tei:TEI
            let $fileDesc := $tei/tei:teiHeader/tei:fileDesc
            let $translation-id := tei-content:id($tei)
            
            return
                element { QName('http://read.84000.co/ns/1.0', 'text') } {
                    attribute id { $translation-id },
                    attribute uri { concat($common:environment/m:url[@id eq 'reading-room'], '/translation/', $translation-id, '.html#', $gloss/@xml:id/string()) },
                    element toh {
                        $fileDesc/tei:sourceDesc/tei:bibl[1]/tei:ref/text()
                    },
                    element title {   
                        tei-content:title($tei)
                    },
                    element authors {
                        for $author in $fileDesc/tei:titleStmt/tei:author[not(@role = 'translatorMain')]
                        return 
                            element author {
                                $author/@ref,
                                $author/text() ! normalize-space(.) 
                            }
                        ,
                        let $translator-main := $fileDesc/tei:titleStmt/tei:author[@role = 'translatorMain'][1]
                        return
                            element summary {
                                $translator-main/@ref,
                                $translator-main/text() ! concat(normalize-space(.), ' ') ! normalize-space(.) 
                            }
                    },
                    element editors {
                        for $editor in $fileDesc/tei:titleStmt/tei:editor
                        return 
                            element editor {
                                $editor/@ref,
                                $editor/text() ! normalize-space(.) 
                            }
                    },
                    element edition {
                        $fileDesc/tei:editionStmt/tei:edition[1]/text() ! concat(normalize-space(.), ' ') ! normalize-space(.) 
                    }
                }
        else
            ()
     }
};

declare function glossary:matching-items($term as xs:string, $lang as xs:string) as element(m:glossary) {
    <glossary
        xmlns="http://read.84000.co/ns/1.0"
        model-type="glossary-items">
        <key>{ $term }</key>
        {
            for $gloss in glossary:matching-gloss($term, $lang)
                order by ft:score($gloss) descending
            return 
                local:glossary-item($gloss, true())
        }
    </glossary>
};

declare function glossary:similar-items($glossary-item as element(m:item)?, $search-string as xs:string?) as element(m:item)* {
    
    (: Potential matches for the passed glossary item :)
    
    if($glossary-item) then
    
        (: Get similar entities :)
        let $entity := entities:entities($glossary-item/@xml:id)/m:entity
        let $instance-ids := ($entity/m:instance/@id, $glossary-item/@xml:id) ! distinct-values(.)
        let $instance-items := glossary:items($instance-ids, false())
        let $instance-terms := ($instance-items//m:term[@xml:lang = ('bo', 'Sa-Ltn')] | $instance-items//m:alternatives[@xml:lang = ('bo', 'Sa-Ltn')]) ! distinct-values(.)
        let $exclude-ids := ($entities:entities/m:entities/m:entity[@xml:id = $entity/m:exclude/@id]/m:instance/@id, $glossary-item/@xml:id, $instance-ids) ! distinct-values(.)
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
                [tei:term[@xml:lang = ('bo', 'Sa-Ltn')]/ft:query(., $search-query, local:lookup-options())]
        
        order by ft:score($similar-item) descending
        return
             local:glossary-item($similar-item, true())
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
                        glossary:matching-items($term/m:main-term, $term/m:main-term/@xml:lang)/*
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
                $gloss/tei:term[@xml:lang eq 'en'][not(@type = ('definition','alternative'))] 
                | $gloss/tei:term[not(@xml:lang)][not(@type = ('definition','alternative'))]
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

declare function glossary:translation-data($tei as element(tei:TEI), $resource-id as xs:string, $test-glossary-ids as xs:string*) as element(m:response) {
    
    (: The translation data for a glossary query - we need text-id and toh-key :)
    let $source := tei-content:source($tei, $resource-id)
    
    return
        common:response(
            'translation',
            $common:app-id,
            (
                (: Include request parameters :)
                element { QName('http://read.84000.co/ns/1.0', 'request')} {
                    attribute resource-id { $resource-id },
                    attribute resource-suffix { 'html' },
                    attribute doc-type { 'html' },
                    attribute part { 'all' },
                    attribute view-mode { 'glossary-editor' },
                    
                    (: Glossary ids to test :)
                    for $test-glossary-id in $test-glossary-ids
                    return
                        element test-glossary {
                            attribute id { $test-glossary-id }
                        }
                    
                },
                
                (: Compile all the translation data :)
                element { QName('http://read.84000.co/ns/1.0', 'translation')} {
                    attribute id { tei-content:id($tei) },
                    attribute status { tei-content:translation-status($tei) },
                    attribute status-group { tei-content:translation-status-group($tei) },
                    attribute relative-html { translation:relative-html($source/@key, '') },
                    attribute canonical-html { translation:canonical-html($source/@key, '') },
                    
                    (: Parts relevant to glossary :)
                    translation:titles($tei),
                    translation:long-titles($tei),
                    $source,
                    translation:publication($tei),
                    translation:parts($tei, 'all'),
            
                    (: Include caches - not glossary :)
                    translation:notes-cache($tei, false()),
                    translation:milestones-cache($tei, false()),
                    translation:folios-cache($tei, false()),
                    $tei/m:glossary-cache
                },
                
                (: Calculated strings :)
                element { QName('http://read.84000.co/ns/1.0', 'replace-text')} {
                    element value {
                        attribute key { '#CurrentDateTime' },
                        text { format-dateTime(current-dateTime(), '[h].[m01][Pn] on [FNn], [D1o] [MNn] [Y0001]') }
                    },
                    element value {
                        attribute key { '#LinkToSelf' },
                        text { translation:local-html($source/@key, '') }
                    },
                    element value {
                        attribute key { '#canonicalHTML' },
                        text { translation:canonical-html($source/@key, '') }
                    }
                }
            )
        )

};

declare function glossary:filter($tei as element(tei:TEI), $resource-id as xs:string, $filter as xs:string, $search as xs:string) as element(m:part) {
    
    let $entity-instance-ids := $entities:entities/m:entities/m:entity/m:instance/@id/string()
    
    (: Pre-defined filters :)
    let $tei-gloss :=
        if($filter eq 'missing-entities') then
            $tei//tei:back//tei:div[@type eq 'glossary']//tei:gloss[not(@xml:id = $entity-instance-ids)]
        else if($filter eq 'no-cache') then
            $tei//tei:back//tei:div[@type eq 'glossary']//tei:gloss[not(@xml:id = $tei/m:glossary-cache/m:gloss[m:location]/@id)]
        else if($filter eq 'blank-form') then
            ()
        else
            $tei//tei:back//tei:div[@type eq 'glossary']//tei:gloss[@xml:id]
    
    (: Search :)
    let $tei-gloss := 
        if(normalize-space($search) gt '') then
            $tei-gloss[tei:term/ft:query(., local:search-query($search), local:search-options())]
        else
            $tei-gloss
    
    (: Expression filters :)
    (: Get the glossarized html :)
    let $translation-data := glossary:translation-data($tei, $resource-id, 'all')
    
    let $translation-html := 
        if($filter = ('new-expressions', 'no-expressions')) then
            transform:transform(
                $translation-data,
                doc(concat($common:app-path, "/views/html/translation.xsl")), 
                <parameters/>
            )
        else
            ()
    
    (: Seperate the glossary from the translation data :)
    let $glossary := $translation-data/m:translation/m:part[@type eq 'glossary']
    
    (: Return the glossary - filtered :)
    return
        element { node-name($glossary) }{
        
            $glossary/@*,
            attribute filter { $filter },
            attribute text-id { tei-content:id($tei) },
            element search { $search },
            
            for $gloss in $tei-gloss
            
                let $search-score := if(normalize-space($search) gt '') then ft:score($gloss) else 1
                
                (: It seems to be significantly quicker to re-create the glossary-item than look it up :)
                let $glossary-item := local:glossary-item($gloss, false()) (: $glossary/m:item[@xml:id = $gloss/@xml:id/string()] :)
                
                (: Expression locations :)
                let $expression-locations := 
                    if($filter = ('new-expressions', 'no-expressions')) then
                        glossary:expression-locations($translation-html, $glossary-item/@id)
                    else
                        ()
            
            where 
                (: If filtering by new expressions, return where there are expression locations not in the cache :)
                not($filter = ('new-expressions', 'no-expressions')) 
                or ($filter eq 'new-expressions' and $expression-locations[not(@id = $tei/m:glossary-cache/m:gloss[@id eq $glossary-item/@id]/m:location/@id)])
                or ($filter eq 'no-expressions' and not($expression-locations))
            
            order by 
                $search-score descending,
                $glossary-item/m:sort-term
            
            return
                element { node-name($glossary-item) }{
                    $glossary-item/@*,
                    $glossary-item/node(),
                    
                    (: Add expressions to save work later :)
                    if($expression-locations) then
                        element { QName('http://read.84000.co/ns/1.0', 'expressions') }{     
                            $expression-locations
                        }
                    else ()
                }
        }
};

declare function glossary:expressions($tei as element(tei:TEI), $resource-id as xs:string, $glossary-ids as xs:string*) as element(m:expressions) {
    
    let $translation-data := glossary:translation-data($tei, $resource-id, $glossary-ids)
    
    let $translation-html := 
        transform:transform(
            $translation-data,
            doc(concat($common:app-path, "/views/html/translation.xsl")), 
            <parameters/>
        )
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'expressions') }{
            glossary:expression-locations($translation-html, $glossary-ids)
        }
};

declare function glossary:expression-locations($translation-html as element(xhtml:html), $glossary-ids as xs:string*) as element()* {
    
    (: Get and elements with the match :)
    (: Also get the nearest preceding milestone if there isn't one :)
    (: Also get the nearest preceding ref :)
    for $expression-location at $sort-index in 
        if(count($glossary-ids[not(. = 'all')]) gt 0) then
            $translation-html/descendant::xhtml:*[@data-glossary-id = $glossary-ids]/ancestor-or-self::xhtml:*[@data-nearest-id][1]
        else
            $translation-html/descendant::xhtml:*[@data-glossary-id]/ancestor-or-self::xhtml:*[@data-nearest-id][1]
    
    let $location := $expression-location/@data-nearest-id
    
    group by $location
    order by $sort-index[1]
    return
        element { QName('http://read.84000.co/ns/1.0', 'location') } {
        
            attribute id { $location[1] },
            attribute sort-index { $sort-index[1] },
            
            element preceding-ref {
                $expression-location[1]/preceding-sibling::xhtml:div[descendant::xhtml:a[@data-ref]][1]/descendant::xhtml:a[@data-ref][1]
            },
            
            element preceding-bookmark {
                if(not($expression-location[descendant::xhtml:a[@data-bookmark]])) then
                    $expression-location/preceding-sibling::xhtml:div[descendant::xhtml:a[@data-bookmark]][1]/descendant::xhtml:a[@data-bookmark][1]
                else 
                    ()
            },
            
            $expression-location
        }
        

};

