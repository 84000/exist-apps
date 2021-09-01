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
import module namespace knowledgebase="http://read.84000.co/knowledgebase" at "knowledgebase.xql";
import module namespace entities="http://read.84000.co/entities" at "entities.xql";
import module namespace functx="http://www.functx.com";

declare variable $glossary:tei := 
    collection($common:tei-path)//tei:TEI
        [tei:text/tei:back/tei:div[@type eq 'glossary']]
        [tei:teiHeader/tei:fileDesc/tei:publicationStmt
            [@status = $common:environment/m:render/m:status[@type eq 'translation']/@status-id]
        ];

declare variable $glossary:types := ('term', 'person', 'place', 'text');
declare variable $glossary:modes := ('match', 'marked');

declare variable $glossary:view-modes := 
    <view-modes xmlns="http://read.84000.co/ns/1.0">
        <view-mode id="default" client="browser" layout="full" glossary="no-cache" parts="all"/>,
        <view-mode id="editor"  client="browser" layout="full" glossary="no-cache" parts="all"/>
    </view-modes>;

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

declare function local:valid-type($type as xs:string*) as xs:string* {
    $type[lower-case(.) = $glossary:types]
};

declare function local:lang-field($valid-lang as xs:string) as xs:string {
    if($valid-lang eq 'Sa-Ltn-x') then
        'sa-term'
    else
        'full-term'
};

declare function glossary:glossary-search($type as xs:string*, $lang as xs:string, $search as xs:string) as element(m:gloss)* {
    
    (: Search for terms :)
    let $valid-lang := common:valid-lang($lang)
    let $valid-type := local:valid-type($type)
    let $normalized-search := 
        if($valid-lang eq 'Sa-Ltn') then
            common:alphanumeric(common:normalized-chars(lower-case($search)))
        else
            common:normalized-chars(lower-case($search))
    
    where $normalized-search gt ''
    return
    let $query :=
        <query>
        {
            if($valid-lang eq 'Bo-Ltn') then
                <phrase>{ $normalized-search }</phrase>
            else
                <bool>
                {
                    for $term in tokenize($normalized-search, '\s+')
                    return
                        <wildcard occur="must">{ $term }*</wildcard>
                }
                </bool>
        }
        </query>
    
    
    let $terms :=
        (: Longer strings - do a search :)
        if(string-length($normalized-search) gt 1) then
            if($valid-lang = ('en', '')) then
                $glossary:tei//tei:back//tei:gloss/tei:term[ft:query(., $query)][not(@type = ('definition', 'alternative'))][not(@xml:lang)]
            else
                $glossary:tei//tei:back//tei:gloss/tei:term[ft:query(., $query)][not(@type = ('definition', 'alternative'))][@xml:lang = $valid-lang]
        (: Single char strings - do a regex :)
        else
            let $match-regex :=
                if($valid-lang eq 'en') then
                    concat('^(The\s+|A\s+|An\s+)?(', string-join(common:letter-variations($normalized-search), '|'), ')')
                else if($valid-lang eq 'Sa-Ltn') then
                    concat('^\s*(', string-join(common:letter-variations($normalized-search), '|'), ')')
                else
                    concat('^\s*', $normalized-search, '')
            return
                if($valid-lang = ('en', '')) then
                    $glossary:tei//tei:back//tei:gloss/tei:term[matches(., $match-regex, 'i')][not(@type = ('definition', 'alternative'))][not(@xml:lang)]
                else
                    $glossary:tei//tei:back//tei:gloss/tei:term[matches(., $match-regex, 'i')][not(@type = ('definition', 'alternative'))][@xml:lang = $valid-lang]
    
    return 
        if(count($valid-type) gt 0) then
            $terms/parent::tei:gloss[@xml:id][@type = $valid-type]
        else
            $terms/parent::tei:gloss[@xml:id]
    
        
};

declare function glossary:glossary-terms($type as xs:string?, $lang as xs:string, $search as xs:string, $include-count as xs:boolean) as element() {
    
    let $valid-lang := common:valid-lang($lang)
    let $valid-type := local:valid-type($type)
    let $empty-term-placeholders := (common:local-text('glossary.term-empty-sa-ltn', 'en'), common:local-text('glossary.term-empty-bo-ltn', 'en'))
    
    let $normalized-search := common:alphanumeric(common:normalized-chars($search))
    
    let $terms := 
        
        (: Search for term - all languages and types :)
        if($type eq 'search' and $normalized-search gt '') then
            $glossary:tei//tei:back//tei:gloss[@xml:id]/tei:term
                [not(@type eq 'definition')]
                [ft:query(., local:search-query($normalized-search), local:search-options())]
        
        (: Look-up terms based on letter, type and lang :)
        else if($valid-type and $normalized-search gt '') then
            
            (: this shouldn't be necessary if collation were working!?? :)
            let $alt-searches := common:letter-variations($normalized-search)
            
            return
                if($valid-lang = ('en', '')) then
                    $glossary:tei//tei:back//tei:gloss[@xml:id][@type = $valid-type]/tei:term
                       [not(@xml:lang) or @xml:lang eq 'en']
                       [not(@type = ('definition','alternative'))]
                       [matches(., concat('^(\d*\s+|The\s+|A\s+)?(', string-join($alt-searches, '|'), ').*'), 'i')]
                else
                    $glossary:tei//tei:back//tei:gloss[@xml:id][@type = $valid-type]/tei:term
                        [@xml:lang eq $valid-lang]
                        [not(@type = ('definition','alternative'))]
                        [matches(., concat('^(\d*\s+|The\s+|A\s+)?(', string-join($alt-searches, '|'), ').*'), 'i')]
        
        (: All terms for type and lang :)
        else if($valid-type) then
            if($valid-lang = ('en', '')) then
                $glossary:tei//tei:back//tei:gloss[@xml:id][@type = $valid-type]/tei:term
                    [not(@xml:lang) or @xml:lang eq 'en']
                    [not(@type = ('definition','alternative'))]
            else
                $glossary:tei//tei:back//tei:gloss[@xml:id][@type = $valid-type]/tei:term
                    [@xml:lang eq $valid-lang]
                    [not(@type = ('definition','alternative'))]
        
        (: All terms for cumulative glossary :)
        else if($type eq 'all') then
            $glossary:tei//tei:back//tei:gloss[@xml:id]/tei:term
                [not(@type = ('definition','alternative'))]
        
        (: All terms for lang only :)
        else
            if($valid-lang = ('en', '')) then
                $glossary:tei//tei:back//tei:gloss[@xml:id]/tei:term
                    [not(@xml:lang) or @xml:lang eq 'en']
                    [not(@type = ('definition','alternative'))]
            else
                $glossary:tei//tei:back//tei:gloss[@xml:id]/tei:term
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
            $glossary:tei//tei:back//tei:gloss[@xml:id]/tei:term
                [not(@type eq 'definition')]
                [not(@xml:lang) or @xml:lang eq 'en']
                [ft:query-field(
                    'full-term',
                    local:lookup-query($term),
                    local:lookup-options()
                )]/parent::tei:gloss
        else if($valid-lang gt '') then
            $glossary:tei//tei:back//tei:gloss[@xml:id]/tei:term
                [not(@type eq 'definition')]
                [ft:query-field(
                    'full-term',
                    local:lookup-query($term),
                    local:lookup-options()
                )]/parent::tei:gloss
        else
            $glossary:tei//tei:back//tei:gloss[@xml:id]/tei:term
                [not(@type eq 'definition')]
                [ft:query-field(
                    'full-term',
                    local:lookup-query($term),
                    local:lookup-options()
                )]/parent::tei:gloss
            
};

declare function glossary:items($glossary-ids as xs:string*, $include-context as xs:boolean) as element(m:item)* {
    
    for $gloss in $glossary:tei//tei:back//id($glossary-ids)
    where $gloss/self::tei:gloss
    return
        local:glossary-item($gloss, $include-context)
    
};

declare function local:glossary-item($gloss as element(tei:gloss), $include-context as xs:boolean) as element(m:item) {
    
    (: This needs updating - use m:entry and optimise :)
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
                element { QName('http://read.84000.co/ns/1.0', 'term') } {
                    attribute xml:lang { 'en' },
                    $term/@type,
                    functx:capitalize-first(normalize-space($term/text()))
                }
            else if($term[@xml:lang][not(@xml:lang eq 'en')][not(@type = ('definition','alternative'))]) then
                element { QName('http://read.84000.co/ns/1.0', 'term') } {
                    $term/@xml:lang,
                    $term/@type,
                    if (not($term[text()])) then
                        common:local-text(concat('glossary.term-empty-', lower-case($term/@xml:lang)), 'en')
                    else if ($term/@xml:lang eq 'Bo-Ltn') then 
                        common:bo-ltn($term/text())
                    else 
                        normalize-space($term/text())
                }
            else if ($term[@type eq 'alternative']) then
                element { QName('http://read.84000.co/ns/1.0', 'alternative') } {
                    $term/@xml:lang,
                    normalize-space(data($term)) 
                }
            else if($term[@type eq 'definition']) then
                element { QName('http://read.84000.co/ns/1.0', 'definition') } {
                    $term/node()
                }
            else ()
        ,
        
        (: Include the context :)
        if($include-context) then
        
            let $tei := $gloss/ancestor::tei:TEI
            let $fileDesc := $tei/tei:teiHeader/tei:fileDesc
            let $translation-id := tei-content:id($tei)
            let $type := tei-content:type($tei)
            let $title := tei-content:title($tei)
            
            return
                element { QName('http://read.84000.co/ns/1.0', 'text') } {
                
                    attribute id { $translation-id },
                    attribute type { $type },
                    attribute uri { concat($common:environment/m:url[@id eq 'reading-room'], '/', $type,'/', $translation-id, '.html#', $gloss/@xml:id/string()) },
                    
                    element title { $title },
                    
                    element edition {
                        $fileDesc/tei:editionStmt/tei:edition[1]/text() ! concat(normalize-space(.), ' ') ! normalize-space(.) 
                    },
                    
                    if($type eq 'translation') then (
                    
                        element toh {
                            $fileDesc/tei:sourceDesc/tei:bibl[1]/tei:ref/text()
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
                        }
                        
                    )
                    else ()
                    
                }
        else
            ()
     }
};

declare function glossary:sort-term($gloss as element(tei:gloss)) as element(m:sort-term) {

    let $sort-term := $gloss/tei:term[not(@xml:lang) or @xml:lang eq 'en'][not(@type = ('definition','alternative'))][1]/data() ! normalize-space(.) ! lower-case(.) ! common:normalized-chars(.) ! common:alphanumeric(.)
    let $terms-en := $gloss/tei:term[not(@xml:lang) or @xml:lang eq 'en'][not(@type = ('definition'))]/data() ! normalize-space(.)
    let $term-word-count := max($terms-en ! count(tokenize(., '\s+')))
    let $term-letter-count := max($terms-en ! string-length(.))
    return
        element { QName('http://read.84000.co/ns/1.0', 'sort-term') } {
            attribute word-count { if($term-word-count) then $term-word-count else 0 },
            attribute letter-count { if($term-letter-count) then $term-letter-count else 0 },
            text { $sort-term }
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

declare function glossary:xml-response($tei as element(tei:TEI), $resource-id as xs:string, $resource-type as xs:string, $test-glossary-ids as xs:string*) as element(m:response) {
    
    common:response(
        $resource-type,
        $common:app-id,
        (
        
            (: Include request parameters :)
            element { QName('http://read.84000.co/ns/1.0', 'request')} {
                attribute resource-id { $resource-id },
                attribute resource-suffix { 'html' },
                attribute doc-type { 'html' },
                attribute part { 'all' },
                
                (: View mode :)
                if($resource-type eq 'knowledgebase') then 
                    $knowledgebase:view-modes/m:view-mode[@id eq 'glossary-check']
                else
                    $translation:view-modes/m:view-mode[@id eq 'glossary-check']
                ,
                
                (: Glossary ids to test :)
                for $test-glossary-id in $test-glossary-ids
                return
                    element test-glossary {
                        attribute id { $test-glossary-id }
                    }
                
            },
        
            if($resource-type eq 'knowledgebase') then
            
                (: Knowledgebase data for a glossary query :)
                element { QName('http://read.84000.co/ns/1.0', 'knowledgebase') } {
                
                    knowledgebase:page($tei),
                    knowledgebase:publication($tei),
                    knowledgebase:taxonomy($tei),
                    knowledgebase:article($tei),
                    knowledgebase:bibliography($tei),
                    knowledgebase:end-notes($tei),
                    knowledgebase:glossary($tei)
                    
                }
                
            else
            
                (: Translation data for a glossary query :)
                let $source := tei-content:source($tei, $resource-id)
                return
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
                    translation:toh($tei, $source/@key),
                    translation:publication($tei),
                    translation:parts($tei, 'all', $translation:view-modes/m:view-mode[@id eq 'glossary-check'])
                    
                }
            ,
            
            element { QName('http://read.84000.co/ns/1.0', 'replace-text')} {
                element value {
                    attribute key { '#CurrentDateTime' },
                    text { format-dateTime(current-dateTime(), '[h].[m01][Pn] on [FNn], [D1o] [MNn] [Y0001]') }
                },
                element value {
                    attribute key { '#LinkToSelf' },
                    text { concat($common:environment/m:url[@id eq 'reading-room'], '/', $resource-type, '/', $resource-id, '.html') }
                },
                element value {
                    attribute key { '#canonicalHTML' },
                    text { concat('https://read.84000.co', '/', $resource-type, '/', $resource-id, '.html') }
                }
            },
            
            (: Include caches - do not call glossary:cache(), this causes a recursion problem :)
            tei-content:cache($tei, false())/m:*
        )
    )
};

declare function glossary:filter($tei as element(tei:TEI), $resource-id as xs:string, $resource-type as xs:string, $filter as xs:string, $search as xs:string) as element(m:part) {
    
    let $glossary-cache := glossary:cache($tei, (), false())
    
    (: Pre-defined filters :)
    let $tei-gloss :=
        if($filter eq 'missing-entities') then
            let $entity-instance-ids := $entities:entities//m:entity/m:instance/@id/string()
            return
                $tei//tei:back//tei:div[@type eq 'glossary']//tei:gloss[not(@xml:id = $entity-instance-ids)]
        else if($filter eq 'no-cache') then
            $tei//tei:back//tei:div[@type eq 'glossary']//tei:gloss[not(@xml:id = $glossary-cache/m:gloss[m:location]/@id)]
        else if($filter eq 'blank-form') then
            ()
        else if($entities:flags//m:flag[@id eq $filter]) then
            let $entity-instance-ids := $entities:entities//m:entity[m:flag[@type eq $filter]]/m:instance/@id/string()
            return
                $tei//tei:back//tei:div[@type eq 'glossary']//tei:gloss[@xml:id = $entity-instance-ids]
        else
            $tei//tei:back//tei:div[@type eq 'glossary']//tei:gloss[@xml:id]
    
    (: Search :)
    let $tei-gloss := 
        if(normalize-space($search) gt '') then
            $tei-gloss[tei:term[ft:query(., local:search-query($search), local:search-options())]]
        else
            $tei-gloss
    
    let $xml-response := glossary:xml-response($tei, $resource-id, $resource-type, 'all')
    
    (: Expression filters :)
    (: Get the glossarized html :)
    let $html := 
        if($filter = ('new-expressions', 'no-expressions')) then
            transform:transform(
                $xml-response,
                doc(concat($common:app-path, "/views/html/", $resource-type, ".xsl")), 
                <parameters/>
            )
        else ()
    
    (: Seperate the glossary from the translation data :)
    let $glossary := $xml-response//m:part[@type eq 'glossary']
    
    (: Return the glossary - filtered :)
    return
        element { QName('http://read.84000.co/ns/1.0', 'part') }{
        
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
                        glossary:expression-locations($html, $glossary-item/@id)
                    else()
            
            where 
                (: If filtering by new expressions, return where there are expression locations not in the cache :)
                not($filter = ('new-expressions', 'no-expressions')) 
                or ($filter eq 'new-expressions' and $expression-locations[not(@id = $glossary-cache/m:gloss[@id eq $glossary-item/@id]/m:location/@id)])
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

declare function glossary:expressions($tei as element(tei:TEI), $resource-id as xs:string, $resource-type as xs:string, $glossary-ids as xs:string*) as element(m:expressions) {
    
    let $html := 
        transform:transform(
            glossary:xml-response($tei, $resource-id, $resource-type, $glossary-ids),
            doc(concat($common:app-path, "/views/html/", $resource-type, ".xsl")), 
            <parameters/>
        )
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'expressions') }{
            attribute text-id { tei-content:id($tei) },
            attribute resource-id { $resource-id },
            glossary:expression-locations($html, $glossary-ids)
        }
};

declare function glossary:expression-locations($translation-html as element(xhtml:html), $glossary-ids as xs:string*) as element()* {
    
    (: Get and elements with the match :)
    (: Also get the nearest preceding milestone if there isn't one :)
    (: Also get the nearest preceding ref :)
    for $expression at $sort-index in 
        if(count($glossary-ids[not(. = 'all')]) gt 0) then
            $translation-html/descendant::xhtml:*[@data-glossary-id = $glossary-ids]
        else
            $translation-html/descendant::xhtml:*[@data-glossary-id]
    
    let $expression-location := $expression/ancestor-or-self::xhtml:*[@data-passage-id][1]
    
    let $expression-location := 
        if(not($expression-location)) then
            $expression/ancestor-or-self::xhtml:*[@id][1]
        else
            $expression-location
    
    let $location := ($expression-location/@data-passage-id, $expression-location/@id)[1]
    
    group by $location
    order by $sort-index[1]
    return
        element { QName('http://read.84000.co/ns/1.0', 'location') } {
        
            attribute id { $location[1] },
            attribute sort-index { $sort-index[1] },
            
            element preceding-ref {
                $expression-location/preceding-sibling::xhtml:div[descendant::xhtml:a[@data-ref]][1]/descendant::xhtml:a[@data-ref][last()]
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

declare function glossary:cache($tei as element(tei:TEI), $refresh-ids as xs:string*, $create-if-unavailable as xs:boolean?) as element(m:glossary-cache) {
    
    let $cache := tei-content:cache($tei, $create-if-unavailable)
    
    return
        (: If there is one and there's nothing to refresh, just return the cache :)
        if($cache[m:glossary-cache] and count($refresh-ids) eq 0) then
            $cache/m:glossary-cache
            
        (: Build the cache :)
        else
            
            let $start-time := util:system-dateTime()
            
            (: Existing cache :)
            let $glossary-cache := $cache/m:glossary-cache
            
            (: TEI glossary items :)
            let $tei-glossary := $tei//tei:back//tei:list[@type eq 'glossary']/tei:item/tei:gloss[@xml:id]
            
            let $resource-id := tei-content:id($tei)
            let $resource-type := tei-content:type($tei)
            
            (: Glossary expressions :)
            let $glossary-expressions :=
                (: We can optimise by passing 'all' instead of all the ids :)
                if($refresh-ids = 'all') then 
                    glossary:expressions($tei, $resource-id, $resource-type, 'all')
                else if (count($tei-glossary[@xml:id = $refresh-ids]) gt 0) then
                    glossary:expressions($tei, $resource-id, $resource-type, $refresh-ids)
                else ()
            
            (: Sort glossaries :)
            let $glossary-sorted :=
                for $gloss in $tei-glossary
                let $sort-term := glossary:sort-term($gloss)
                order by $sort-term/text()
                return $gloss
            
            (: Process all glossaries :)
            let $glosses :=
                for $gloss at $index in $glossary-sorted
                    let $gloss-id := $gloss/@xml:id
                group by $gloss-id
                    let $sort-term := glossary:sort-term($gloss[1])
                return 
                    (: If we processed it then add it with the new $glossary-expressions :)
                    if ($refresh-ids = 'all' or $gloss-id = $refresh-ids) then (
                        common:ws(2),
                        element { QName('http://read.84000.co/ns/1.0', 'gloss') } {
                            attribute id { $gloss-id },
                            attribute index { $index },
                            attribute timestamp { current-dateTime() },
                            $sort-term/@word-count ,
                            $sort-term/@letter-count ,
                            
                            for $location in $glossary-expressions/m:location[descendant::xhtml:*[@data-glossary-id eq $gloss-id]]
                            let $location-id := $location/@id
                            group by $location-id
                            order by $location[1]/@sort-index ! xs:integer(.)
                            return (
                                common:ws(3),
                                element location {
                                    attribute id { $location/@id }
                                }
                            ),
                            common:ws(2)
                        }
                    )
                    
                    (: Otherwise copy the existing cache :)
                    else (
                        common:ws(2),
                        
                        let $existing-cache := $glossary-cache/m:gloss[@id eq $gloss-id]
                        return
                            element { QName('http://read.84000.co/ns/1.0', 'gloss') } {
                                attribute id { $gloss-id },
                                attribute index { $index },
                                $sort-term/@word-count ,
                                $sort-term/@letter-count ,
                                $existing-cache/@*[not(name(.) = ('id', 'index', 'word-count', 'letter-count', 'priority'))],
                                $existing-cache/node()
                            }
                            
                    )
            
            let $end-time := util:system-dateTime()
            
            return
                element { QName('http://read.84000.co/ns/1.0', 'glossary-cache') } {
                
                    attribute timestamp { current-dateTime() },
                    
                    if($refresh-ids = 'all') then
                        attribute seconds-to-build { functx:total-seconds-from-duration($end-time - $start-time) }
                    else
                        $glossary-cache/@seconds-to-build
                    ,
                    
                    $glosses,
                    
                    common:ws(1)
                }
};

