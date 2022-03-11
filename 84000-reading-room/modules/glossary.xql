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

declare variable $glossary:tei := (
    collection($common:translations-path)//tei:TEI
        [tei:text/tei:back/tei:div[@type eq 'glossary']]
        [tei:teiHeader/tei:fileDesc/tei:publicationStmt
            [@status = $common:environment/m:render/m:status[@type eq 'translation']/@status-id]
        ],
    collection($common:knowledgebase-path)//tei:TEI
        [tei:text/tei:back/tei:div[@type eq 'glossary']]
        [tei:teiHeader/tei:fileDesc/tei:publicationStmt
            [@status = $common:environment/m:render/m:status[@type eq 'article']/@status-id]
        ]
);

declare variable $glossary:types := ('term', 'person', 'place', 'text');
declare variable $glossary:modes := ('match', 'marked');

declare variable $glossary:view-modes := 
    <view-modes xmlns="http://read.84000.co/ns/1.0">
        <view-mode id="default" client="browser" layout="full" glossary="no-cache" parts="all"/>,
        <view-mode id="editor"  client="browser" layout="full" glossary="no-cache" parts="all"/>
    </view-modes>;

declare variable $glossary:empty-term-placeholders := (common:local-text('glossary.term-empty-sa-ltn', 'en'), common:local-text('glossary.term-empty-bo-ltn', 'en'));

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

declare function glossary:glossary-search($type as xs:string*, $lang as xs:string, $search as xs:string) as element(tei:gloss)* {
    
    (: Search for terms :)
    let $valid-lang := common:valid-lang($lang)
    let $valid-type := local:valid-type($type)
    let $normalized-search := 
        if($valid-lang = ('en', '')) then
            replace(common:normalized-chars(lower-case($search)), '\-', ' ')
        else if($valid-lang eq 'Sa-Ltn') then
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
                $glossary:tei//tei:back//tei:gloss/tei:term[ft:query(., $query)][not(@type = ('definition', 'alternative'))][@xml:lang eq $valid-lang]
                
        (: Single character strings - do a regex :)
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
                    $glossary:tei//tei:back//tei:gloss/tei:term[matches(., $match-regex, 'i')][not(@type = ('definition', 'alternative'))][@xml:lang eq $valid-lang]
    
    return
        if(count($valid-type) gt 0) then
            $terms/parent::tei:gloss[@xml:id][@type = $valid-type]
        else
            $terms/parent::tei:gloss[@xml:id]
    
        
};

declare function glossary:glossary-flagged($flag-type as xs:string*, $glossary-type as xs:string*) as element(tei:gloss)* {
    
    let $flag := $entities:flags//m:flag[@id eq $flag-type]
    let $flagged-instances := $entities:entities//m:flag[@type eq $flag/@id]/parent::m:instance
    let $valid-glossary-type := local:valid-type($glossary-type)
    return
        subsequence($glossary:tei//tei:gloss/id($flagged-instances/@id)[@type = $valid-glossary-type], 1, 1000)
        
};

declare function glossary:glossary-terms($type as xs:string?, $lang as xs:string, $search as xs:string, $include-count as xs:boolean) as element(m:glossary)* {
    
    let $valid-lang := common:valid-lang($lang)
    let $valid-type := local:valid-type($type)
    
    let $normalized-search := common:alphanumeric(common:normalized-chars($search))
    
    let $terms := 

        (: Search for term - all languages and types :)
        if($type eq 'search') then
            if($normalized-search gt '') then
                $glossary:tei//tei:back//tei:gloss[@xml:id]/tei:term
                    [not(@type eq 'definition')]
                    [ft:query(., local:search-query($normalized-search), local:search-options())]
            else ()
        
        (: Look-up terms based on letter, type and lang :)
        else if($valid-type and $normalized-search gt '') then
            
            (: this shouldn't be necessary if collation were working!?? :)
            let $alt-searches := common:letter-variations($normalized-search)
            let $regex := concat('^(\d*\s+|The\s+|A\s+)?(', string-join($alt-searches, '|'), ').*')
            
            return
                if($valid-lang = ('en', '')) then
                    $glossary:tei//tei:back//tei:gloss[@xml:id][@type = $valid-type]/tei:term
                       [matches(., $regex, 'i')]
                       [not(@xml:lang) or @xml:lang eq 'en']
                       [not(@type = ('definition','alternative'))]
                else
                    $glossary:tei//tei:back//tei:gloss[@xml:id][@type = $valid-type]/tei:term
                        [matches(., $regex, 'i')]
                        [@xml:lang eq $valid-lang]
                        [not(@type = ('definition','alternative'))]
        
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
        element { QName('http://read.84000.co/ns/1.0','glossary') } {
        
            attribute model { "glossary-terms" },
            attribute type { $valid-type },
            attribute lang { $valid-lang },
            attribute search { $normalized-search },

            for $term in $terms[normalize-space()][not(text() = $glossary:empty-term-placeholders)]
            
            let $normalized-term := 
                normalize-space(
                    replace(
                        common:normalized-chars(
                            normalize-unicode(
                                replace(
                                    normalize-space(lower-case($term))
                                , '\-­'(: soft-hyphen :), '')
                            , 'NFC')
                        )
                    , '[^a-zA-Z\s]', '')
                )
            
            group by $normalized-term
            
            let $matches := 
                if($include-count) then
                    glossary:matching-gloss($term[1], ($term[1]/@xml:lang/string(), 'en')[1])
                else ()
            
            let $score := ft:score($term[1])
            
            order by $normalized-term
            where $normalized-term gt ''
            return
                element term {
                    attribute start-letter { substring($normalized-term, 1, 1) },
                    attribute count-items { count($matches) },
                    attribute score { $score },
                    element main-term {
                        attribute xml:lang { ($term[1]/@xml:lang/string(), 'en')[1] },
                        normalize-space($term[1])
                    },
                    element normalized-term {
                        $normalized-term
                    }
                }
                
        }
        
};

declare function glossary:matching-gloss($term as xs:string, $lang as xs:string) as element(tei:gloss)* {
    
    let $valid-lang := common:valid-lang($lang)
    let $matches := 
        if($valid-lang eq 'en') then
            $glossary:tei//tei:back//tei:gloss/tei:term[ft:query-field('full-term', local:lookup-query($term), local:lookup-options())][not(@type eq 'definition')][not(@xml:lang) or @xml:lang eq 'en']
        else if($valid-lang gt '') then
            $glossary:tei//tei:back//tei:gloss/tei:term[ft:query-field('full-term', local:lookup-query($term), local:lookup-options())][not(@type eq 'definition')][@xml:lang eq $valid-lang]
        else
            $glossary:tei//tei:back//tei:gloss/tei:term[ft:query-field('full-term', local:lookup-query($term), local:lookup-options())][not(@type eq 'definition')]
    
    return
        $matches/parent::tei:gloss
            
};

declare function glossary:entries($glossary-ids as xs:string*, $include-context as xs:boolean) as element(m:entry)* {
    
    for $gloss in $glossary:tei//id($glossary-ids)
    where $gloss/self::tei:gloss
    return
        glossary:glossary-entry($gloss, $include-context)
    
};

declare function glossary:glossary-entry($gloss as element(tei:gloss), $include-context as xs:boolean) as element(m:entry) {
    
    (: This needs optimising :)
    element { QName('http://read.84000.co/ns/1.0', 'entry') } {
        
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
                    $term/@status,
                    normalize-space($term/text())
                }
            else if($term[@xml:lang][not(@xml:lang eq 'en')][not(@type = ('definition','alternative'))]) then
                element { QName('http://read.84000.co/ns/1.0', 'term') } {
                    $term/@xml:lang,
                    $term/@type,
                    $term/@status,
                    if (not($term[text()])) then
                        common:local-text(concat('glossary.term-empty-', lower-case($term/@xml:lang)), 'en')
                    else if ($term[@xml:lang eq 'Bo-Ltn']) then 
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
        else ()
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

declare function glossary:matching-entries($term as xs:string, $lang as xs:string) as element(m:glossary) {
    <glossary
        xmlns="http://read.84000.co/ns/1.0"
        model="glossary-items">
        <key>{ $term }</key>
        {
            for $gloss in glossary:matching-gloss($term, $lang)
                order by ft:score($gloss) descending
            return 
                glossary:glossary-entry($gloss, true())
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
                        glossary:matching-entries($term/m:main-term, $term/m:main-term/@xml:lang)/*
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
    
    let $request := 
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
            (: If none, or none matching, then it tests all :)
            for $test-glossary-id in $test-glossary-ids
            return
                element test-glossary {
                    attribute id { $test-glossary-id }
                }
            
        }
    
    let $resource := 
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
    
    (: Include caches - do not call glossary:cache(), this causes a recursion problem :)
    let $cache := tei-content:cache($tei, false())/m:*
    
    let $replace-text :=
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
        }
    
    return
        common:response(
            $resource-type,
            $common:app-id,
            (
                $request,
                $resource,
                $cache,
                $replace-text
            )
        )
        
};

declare function glossary:filter($tei as element(tei:TEI), $resource-type as xs:string, $filter as xs:string, $search as xs:string) as element(tei:gloss)* {
    
    (: Glossary cache (on) :)
    let $glossary-cache := tei-content:cache($tei, false())/m:glossary-cache/m:gloss
    
    (: Pre-defined filters :)
    let $tei-gloss :=
    
        (: Entries with no assigned entity :)
        if($filter eq 'missing-entities') then
            let $glosses-with-instances := $tei//tei:back//tei:div[@type eq 'glossary']//id($entities:entities//m:entity/m:instance/@id)/self::tei:gloss
            return
                $tei//tei:back//tei:div[@type eq 'glossary']//tei:gloss except $glosses-with-instances
        
        (: Filter by glossary type :)
        else if($filter = ('check-terms', 'check-people', 'check-places', 'check-texts')) then
            let $type :=
                if($filter eq 'check-terms') then 'eft-term'
                else if ($filter eq 'check-people') then 'eft-person'
                else if ($filter eq 'check-places') then 'eft-place'
                else 'eft-text'
            let $entities-with-type := $entities:entities//m:type[@type = $type]/parent::m:entity
            return
                $tei//tei:back//tei:div[@type eq 'glossary']//id($entities-with-type/m:instance/@id)/self::tei:gloss
        
        (: No locations in the cache :)
        else if($filter eq 'no-locations') then
            let $cache-with-locations := $glossary-cache[m:location]
            let $gloss-with-locations := $tei//tei:back//tei:div[@type eq 'glossary']//id($cache-with-locations/@id)/self::tei:gloss
            return
                $tei//tei:back//tei:div[@type eq 'glossary']//tei:gloss except $gloss-with-locations
        
        (: New locations in this version :)
        else if($filter eq 'new-locations') then
            let $tei-version := tei-content:version-str($tei)
            let $glossary-cache-new-locations := $glossary-cache[m:location/@initial-version eq $tei-version]
            return
                $tei//tei:back//tei:div[@type eq 'glossary']//id($glossary-cache-new-locations/@id)/self::tei:gloss
        
        (: Locations from other version :)
        else if($filter eq 'cache-behind') then
            let $tei-version := tei-content:version-str($tei)
            let $glossary-cache-current := $glossary-cache[@tei-version eq $tei-version]
            let $glossary-cache-outdate := $glossary-cache[m:location] except $glossary-cache-current
            return
                $tei//tei:back//tei:div[@type eq 'glossary']//id($glossary-cache-outdate/@id)/self::tei:gloss
        
        
        (: Blank form - no records required :)
        else if($filter eq 'blank-form') then
            ()
        
        (: Default to all :)
        else
            $tei//tei:back//tei:div[@type eq 'glossary']//tei:gloss[@xml:id]
    
    (: $filter matches a flag :)
    let $tei-gloss :=
        if($entities:flags//m:flag[@id eq $filter]) then
            for $gloss in $tei-gloss
            let $entity-flagged := $entities:entities//m:instance[@id eq $gloss/@xml:id]/m:flag[@type = $filter]
            where $entity-flagged
            return $gloss
        else
            $tei-gloss
    
    (: Filter by search term :)
    let $tei-gloss := 
        if(normalize-space($search) gt '') then
            $tei-gloss[tei:term[ft:query(., local:search-query($search), local:search-options())]]
        else
            $tei-gloss
    
    (: Return the filtered glossary-part :)
    for $gloss in $tei-gloss
    
        let $search-score := if(normalize-space($search) gt '') then ft:score($gloss) else 1
        let $sort-term := glossary:sort-term($gloss)
        
    order by 
        $search-score descending,
        $sort-term
    
    return 
        $gloss
        
};

declare function glossary:locations($locations as element(m:location)*, $glossary-id as xs:string) as element(m:location)* {
    (: Filter out locations containing this glossary match but have a higher nested location :)
    for $location in $locations[descendant::xhtml:*[@data-glossary-id eq $glossary-id]]
    let $glossary-matches := $location/descendant::xhtml:*[@data-glossary-id eq $glossary-id]
    where not($glossary-matches/ancestor::xhtml:*[@data-passage-id][1][not(@data-passage-id eq $location/@id)])
    return
        $location
};

declare function glossary:locations($tei as element(tei:TEI), $resource-id as xs:string, $resource-type as xs:string, $glossary-ids as xs:string*) as element(m:locations) {
    
    let $html := 
        transform:transform(
            glossary:xml-response($tei, $resource-id, $resource-type, $glossary-ids),
            doc(concat($common:app-path, "/views/html/", $resource-type, ".xsl")), 
            <parameters/>
        )
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'locations') }{
            attribute text-id { tei-content:id($tei) },
            attribute resource-id { $resource-id },
            local:instance-locations($html, $glossary-ids)
        }
};

declare function local:instance-locations($translation-html as element(xhtml:html), $glossary-ids as xs:string*) as element()* {
    
    (: Get and elements with the match :)
    (: Also get the nearest preceding milestone if there isn't one :)
    (: Also get the nearest preceding ref :)
    
    (: Select any node with a data-glossary-id :)
    for $expression at $sort-index in $translation-html/descendant::xhtml:*[@data-glossary-id = $glossary-ids]
    
    (: Select the nearest parent with a data-passage-id :)
    let $expression-container := $expression/ancestor-or-self::xhtml:*[@data-passage-id][1]
    
    let $expression-container := 
        if(not($expression-container)) then
            $expression/ancestor-or-self::xhtml:*[@id][1]
        else
            $expression-container
    
    let $location-id := ($expression-container/@data-passage-id, $expression-container/@id)[1]
    
    group by $location-id
    order by $sort-index[1]
    return
        element { QName('http://read.84000.co/ns/1.0', 'location') } {
        
            attribute id { $location-id[1] },
            attribute sort-index { $sort-index[1] },
            
            element preceding-ref {
                $expression-container/preceding-sibling::xhtml:div[descendant::xhtml:a[@data-ref]][1]/descendant::xhtml:a[@data-ref][last()]
            },
            
            element preceding-bookmark {
                if(not($expression-container[descendant::xhtml:a[@data-bookmark]])) then
                    $expression-container/preceding-sibling::xhtml:div[descendant::xhtml:a[@data-bookmark]][1]/descendant::xhtml:a[@data-bookmark][1]
                else 
                    ()
            },
            
            $expression-container
            
        }

};

declare function glossary:cache($tei as element(tei:TEI), $refresh-locations as xs:string*, $create-if-unavailable as xs:boolean?) as element(m:glossary-cache) {
    
    let $glossary-cache := tei-content:cache($tei, $create-if-unavailable)/m:glossary-cache
    
    return
        (: If there is one and there's nothing to refresh, just return the cache :)
        if($glossary-cache and count($refresh-locations) eq 0) then
            $glossary-cache

        (: Build the cache :)
        else
        
            (: Meta data :)
            let $resource-id := tei-content:id($tei)
            let $resource-type := tei-content:type($tei)
            let $tei-version := tei-content:version-str($tei)
            
            (: TEI glossary items :)
            let $tei-glossary := $tei//tei:back//tei:list[@type eq 'glossary']/tei:item/tei:gloss[@xml:id]
            
            (: Get glossary instances, if valid ids have been requested :)
            let $glossary-locations := 
                if($tei-glossary/id($refresh-locations)) then
                    glossary:locations($tei, $resource-id, $resource-type, $refresh-locations)
                else ()
            
            (: Sort glossaries :)
            let $tei-glossary-sorted :=
                for $gloss in $tei-glossary
                let $sort-term := glossary:sort-term($gloss)
                order by $sort-term/text()
                return $gloss
            
            let $cache-glosses := 
                for $gloss at $index in $tei-glossary-sorted
                let $sort-term := glossary:sort-term($gloss)
                let $existing-cache := $glossary-cache/m:gloss[range:eq(@id, $gloss/@xml:id)][1]
                let $gloss-refresh-locations := $gloss[@xml:id = $refresh-locations]
                let $cache-locations :=
                
                    (: If we processed it then add it with the new $glossary-instances :)
                    if ($gloss-refresh-locations) then
                    
                        let $gloss-locations := $glossary-locations/m:location[descendant::xhtml:*[@data-glossary-id eq $gloss/@xml:id]]
                        
                        for $location in glossary:locations($gloss-locations, $gloss/@xml:id)
                        let $location-id := $location/@id
                        let $existing-cache-location := $existing-cache/m:location[@id eq $location-id]
                        group by $location-id
                        order by $location[1]/@sort-index ! xs:integer(.)
                        return
                            if($existing-cache-location) then
                                $existing-cache-location
                            else
                                element { QName('http://read.84000.co/ns/1.0', 'location') } {
                                    attribute id { $location/@id },
                                    (: Add initial-version so we can track what's new :)
                                    attribute initial-version { $tei-version }
                                }
                    
                    (: Otherwise copy the existing locations :)
                    else
                        $existing-cache/m:location
                        
                return 
                
                    element { QName('http://read.84000.co/ns/1.0', 'gloss') } {
                    
                        attribute id { $gloss/@xml:id },
                        attribute index { $index },
                        attribute word-count { $sort-term/@word-count },
                        attribute letter-count { $sort-term/@letter-count },
                        
                        if($gloss-refresh-locations) then (
                            attribute tei-version { $tei-version },
                            attribute timestamp { current-dateTime() }
                        )
                        else (
                            $existing-cache/@tei-version,
                            $existing-cache/@timestamp
                        ),
                        
                        (:$cache-locations:)
                        if($cache-locations) then (
                            for $cache-location in $cache-locations
                            return (
                                common:ws(3),
                                $cache-location
                            ),
                            common:ws(2)
                        )
                        else ()
                    }
            
            return
                element { QName('http://read.84000.co/ns/1.0', 'glossary-cache') } {
                
                    $glossary-cache/@*,
                    (:$cache-glosses:)
                    if($cache-glosses) then (
                        for $cache-gloss in $cache-glosses
                        return (
                            common:ws(2),
                            $cache-gloss
                        ),
                        common:ws(1)
                    )
                    else ()
                }
                
};
