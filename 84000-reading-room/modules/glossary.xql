xquery version "3.1" encoding "UTF-8";
(:
    Returns the cumulative glossary xml
    -------------------------------------------------------------
:)
module namespace glossary="http://read.84000.co/glossary";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";
import module namespace knowledgebase="http://read.84000.co/knowledgebase" at "knowledgebase.xql";
import module namespace entities="http://read.84000.co/entities" at "entities.xql";
import module namespace contributors="http://read.84000.co/contributors" at "contributors.xql";
import module namespace functx="http://www.functx.com";

declare variable $glossary:types := ('term', 'person', 'place', 'text');
declare variable $glossary:modes := ('match', 'marked');
declare variable $glossary:translation-render-status := $common:environment/m:render/m:status[@type eq 'translation']/@status-id/string();
declare variable $glossary:knowledgebase-render-status := $common:environment/m:render/m:status[@type eq 'article']/@status-id/string();

declare variable $glossary:tei := (
    (:collection(concat($common:data-path, '/tei/layout-checks'))//tei:TEI
        [tei:text/tei:back/tei:div[@type eq 'glossary']]
        [tei:teiHeader/tei:fileDesc/tei:publicationStmt
            [@status = $glossary:translation-render-status]
        ],:)
    $tei-content:translations-collection//tei:TEI
        [tei:text/tei:back/tei:div[@type eq 'glossary']]
        [tei:teiHeader/tei:fileDesc/tei:publicationStmt
            [@status = $glossary:translation-render-status]
        ],
    $tei-content:knowledgebase-collection//tei:TEI
        [tei:text/tei:back/tei:div[@type eq 'glossary']]
        [tei:teiHeader/tei:fileDesc/tei:publicationStmt
            [@status = $glossary:knowledgebase-render-status]
        ]
);

declare variable $glossary:view-modes := 
    <view-modes xmlns="http://read.84000.co/ns/1.0">
        <view-mode id="default" client="browser" layout="full" glossary="no-cache" parts="all" cache="use-cache"/>
        <view-mode id="editor"  client="browser" layout="full" glossary="no-cache" parts="all" cache="no-cache"/>
    </view-modes>;
    
declare variable $glossary:attestation-types :=
    <attestation-types xmlns="http://read.84000.co/ns/1.0">
        <attestation-type id="attestedSource" code="AS" >
            <label>Attested in source text</label>
            <description>This term is attested in the Sanskrit manuscript used as a source for this translation.</description>
            <appliesToLang xml:lang="Sa-Ltn" rend="note"/>
            <appliesToLang xml:lang="Bo-Ltn"/>
            <appliesToLang xml:lang="bo"/>
            <migrate id="sourceAttested"/>
        </attestation-type>
        <attestation-type id="attestedOther" code="AO">
            <label>Attested in other text</label>
            <description>This term is attested in other Sanskrit manuscripts of the Kangyur or Tengyur.</description>
            <appliesToLang xml:lang="Sa-Ltn" rend="note"/>
        </attestation-type>
        <attestation-type id="attestedDictionary" code="AD">
            <label>Attested in dictionary</label>
            <description>This term is attested in Tibetan-Sanskrit dictionaries.</description>
            <appliesToLang xml:lang="Sa-Ltn" rend="note"/>
        </attestation-type>
        <attestation-type id="attestedApproximate" code="AA">
            <label>Approximate attestation</label>
            <description>The attestation of this name is approximate. It is based on other names where Tibetan-Sanskrit relationship is attested in dictionaries or other manuscripts.</description>
            <appliesToLang xml:lang="Sa-Ltn" rend="note"/>
        </attestation-type>
        <attestation-type id="reconstructedPhonetic" code="RP">
            <label>Reconstruction from Tibetan phonetic rendering</label>
            <description>This term is a reconstruction based on the Tibetan phonetic rendering of the term.</description>
            <appliesToLang xml:lang="Sa-Ltn" rend="asterisk note"/>
            <migrate id="transliterationReconstruction"/>
        </attestation-type>
        <attestation-type id="reconstructedSemantic" code="RS">
            <label>Reconstruction from Tibetan semantic rendering</label>
            <description>This term is a reconstruction based on the semantics of the Tibetan translation.</description>
            <appliesToLang xml:lang="Sa-Ltn" rend="asterisk note"/>
            <migrate id="semanticReconstruction"/>
        </attestation-type>
        <attestation-type id="sourceUnspecified" code="SU" default="true">
            <label>Source Unspecified</label>
            <description>This term has been supplied from an unspecified source, which most often is a widely trusted dictionary.</description>
            <appliesToLang xml:lang="Sa-Ltn"/>
            <appliesToLang xml:lang="zh"/>
        </attestation-type>
    </attestation-types>;

declare variable $glossary:empty-term-placeholders := (common:local-text('glossary.term-empty-sa-ltn', 'en'), common:local-text('glossary.term-empty-bo-ltn', 'en'));

declare variable $glossary:stopwords-en := ("a", "an", "and", "are", "as", "at", "be", "but", "by","for", "if", "in", "into", "is", "it","no", "not", "of", "on", "or", "such","that", "the", "their", "then", "there", "these","they", "this", "to", "was", "will", "with");

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

declare function glossary:glossary-search($type as xs:string*, $lang as xs:string, $search as xs:string, $exclude-status as xs:string*) as element(tei:term)* {
    
    (: Combined glossary search :)
    let $valid-type := local:valid-type($type)
    let $valid-lang := common:valid-lang($lang)
    
    (: Transliterate :)
    let $search := 
        if($valid-lang eq 'Bo-Ltn' and common:string-is-bo($search)) then
            common:wylie-from-bo($search)
        else if($valid-lang eq 'bo' and not(common:string-is-bo($search))) then
            common:bo-from-wylie($search)
        else
            $search
    
    let $normalized-search := 
        if($valid-lang = ('en', '')) then
            replace(common:normalized-chars(lower-case($search)), '\-', ' ')
        else if($valid-lang eq 'Sa-Ltn') then
            common:alphanumeric(common:normalized-chars(lower-case($search)))
        else if($valid-lang eq 'Bo-Ltn') then
            common:normalized-chars(lower-case($search))
        else
            common:normalized-chars($search)
    
    where $normalized-search gt ''
    
    let $query :=
        <query>
        {
            if($valid-lang = ('Bo-Ltn', 'bo')) then
                <phrase>{ $normalized-search }</phrase>
            else
                <bool>
                {
                    (: wildcard is not ignoring stopwords :)
                    for $term in tokenize($normalized-search, '\s+')[not(. = $glossary:stopwords-en)]
                    return
                        <wildcard occur="must">{ $term }*</wildcard>
                }
                </bool>
        }
        </query>
    
    let $glossaries := $glossary:tei//tei:back/tei:div[@type eq 'glossary'][not(@status = $exclude-status)]
    
    let $terms :=
        if($valid-lang = ('en', '')) then
            $glossaries//tei:gloss/tei:term[ft:query(., $query)][not(@type = ('definition', 'alternative', 'translationAlternative'))][not(@xml:lang)]
        else
            $glossaries//tei:gloss/tei:term[ft:query(., $query)][not(@type = ('definition', 'alternative', 'translationAlternative'))][@xml:lang eq $valid-lang]
    
    for $term in $terms
    let $parent := 
        if(count($valid-type) gt 0) then
            $term/parent::tei:gloss[@xml:id][not(@mode eq 'surfeit')][@type = $valid-type]
        else
            $term/parent::tei:gloss[@xml:id][not(@mode eq 'surfeit')]
    where $parent
    return
        $term
};

declare function glossary:glossary-startletter($type as xs:string*, $lang as xs:string, $match-regex as xs:string, $exclude-status as xs:string*) as element(tei:term)* {
    
    (: Lookup terms by start letter :)
    let $valid-type := local:valid-type($type)
    let $valid-lang := common:valid-lang($lang)
    
    let $glossaries := $glossary:tei//tei:back/tei:div[@type eq 'glossary'][not(@status = $exclude-status)]
    
    let $terms :=
        if($valid-lang = ('en', '')) then
            $glossaries//tei:gloss/tei:term[matches(., $match-regex, 'i')][not(@type = ('definition', 'alternative', 'translationAlternative'))][not(@xml:lang)]
        else
            $glossaries//tei:gloss/tei:term[matches(., $match-regex, 'i')][not(@type = ('definition', 'alternative', 'translationAlternative'))][@xml:lang eq $valid-lang]
    
    for $term in $terms
    let $parent := 
        if(count($valid-type) gt 0) then
            $term/parent::tei:gloss[@xml:id][not(@mode eq 'surfeit')][@type = $valid-type]
        else
            $term/parent::tei:gloss[@xml:id][not(@mode eq 'surfeit')]
    where $parent
    return
        $term
};

declare function glossary:glossary-flagged($flag-type as xs:string*, $glossary-type as xs:string*) as element(tei:gloss)* {
    
    (: Return flagged entries :)
    
    let $flag := $entities:flags//m:flag[@id eq $flag-type]
    
    let $flagged-instances := 
        if($flag[@id eq 'entity-definition']) then
            $entities:entities//m:entity[m:content[@type eq 'glossary-definition'][node()]]/m:instance
        else
            $entities:entities//m:flag[@type eq $flag/@id]/parent::m:instance
    
    let $valid-glossary-type := local:valid-type($glossary-type)
    
    return $glossary:tei//tei:gloss/id($flagged-instances/@id)[not(@mode eq 'surfeit')][@type = $valid-glossary-type]
    
};

(:declare function glossary:glossary-terms($type as xs:string?, $lang as xs:string, $search as xs:string, $include-count as xs:boolean) as element(m:glossary)* {
    
    let $valid-lang := common:valid-lang($lang)
    let $valid-type := local:valid-type($type)
    
    let $normalized-search := common:alphanumeric(common:normalized-chars($search))
    
    let $terms := 

        (\: Search for term - all languages and types :\)
        if($type eq 'search') then
            if($normalized-search gt '') then
                $glossary:tei//tei:back//tei:gloss[@xml:id]/tei:term
                    [not(@type eq 'definition')]
                    [ft:query(., local:search-query($normalized-search), local:search-options())]
            else ()
        
        (\: Look-up terms based on letter, type and lang :\)
        else if($valid-type and $normalized-search gt '') then
            
            (\: this shouldn't be necessary if collation were working!?? :\)
            let $alt-searches := common:letter-variations($normalized-search)
            let $regex := concat('^(\d*\s+|The\s+|A\s+)?(', string-join($alt-searches, '|'), ').*')
            
            return
                if($valid-lang = ('en', '')) then
                    $glossary:tei//tei:back//tei:gloss[@xml:id][@type = $valid-type]/tei:term
                       [matches(., $regex, 'i')]
                       [not(@xml:lang) or @xml:lang eq 'en']
                       [not(@type = ('definition','alternative','translationAlternative'))]
                else
                    $glossary:tei//tei:back//tei:gloss[@xml:id][@type = $valid-type]/tei:term
                        [matches(., $regex, 'i')]
                        [@xml:lang eq $valid-lang]
                        [not(@type = ('definition','alternative','translationAlternative'))]
        
        (\: All terms for type and lang :\)
        else if($valid-type) then
            if($valid-lang = ('en', '')) then
                $glossary:tei//tei:back//tei:gloss[@xml:id][@type = $valid-type]/tei:term
                    [not(@xml:lang) or @xml:lang eq 'en']
                    [not(@type = ('definition','alternative','translationAlternative'))]
            else
                $glossary:tei//tei:back//tei:gloss[@xml:id][@type = $valid-type]/tei:term
                    [@xml:lang eq $valid-lang]
                    [not(@type = ('definition','alternative','translationAlternative'))]
        
        (\: All terms for cumulative glossary :\)
        else if($type eq 'all') then
            $glossary:tei//tei:back//tei:gloss[@xml:id]/tei:term
                [not(@type = ('definition','alternative', translationAlternative'))]
        
        (\: All terms for lang only :\)
        else
            if($valid-lang = ('en', '')) then
                $glossary:tei//tei:back//tei:gloss[@xml:id]/tei:term
                    [not(@xml:lang) or @xml:lang eq 'en']
                    [not(@type = ('definition','alternative','translationAlternative'))]
            else
                $glossary:tei//tei:back//tei:gloss[@xml:id]/tei:term
                    [@xml:lang eq $valid-lang]
                    [not(@type = ('definition','alternative','translationAlternative'))]
    
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
                                , '\-­'(\: soft-hyphen :\), '')
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
        
};:)

(:declare function glossary:matching-gloss($term as xs:string, $lang as xs:string) as element(tei:gloss)* {
    
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
            
};:)

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
        $gloss/@type,
        
        (: Sort term :)
        glossary:sort-term($gloss),
        
        (: Terms and definition :)
        for $term in ($gloss/tei:term | $gloss/tei:p[@type eq 'definition'])
        return 
             if($term[not(@type = ('definition','alternative','translationAlternative'))][not(@xml:lang) or @xml:lang eq 'en']) then
                element { QName('http://read.84000.co/ns/1.0', 'term') } {
                    attribute xml:lang { 'en' },
                    $term/@type,
                    $term/@status,
                    $term/text() ! normalize-space(.)
                }
                
            else if($term[@xml:lang][not(@xml:lang eq 'en')][not(@type = ('definition','alternative','translationAlternative'))]) then
                element { QName('http://read.84000.co/ns/1.0', 'term') } {
                    $term/@xml:lang,
                    $term/@type,
                    $term/@status,
                    if (not($term[text()])) then
                        common:local-text(concat('glossary.term-empty-', lower-case($term/@xml:lang)), 'en')
                    else if ($term[@xml:lang eq 'Bo-Ltn']) then 
                        $term/text() ! common:bo-ltn(.)
                    else 
                        $term/text() ! normalize-unicode(.) ! normalize-space(.) ! replace(.,'&#160;+$','')
                }
            
            else if ($term[@type = ('alternative','translationAlternative')]) then
                element { QName('http://read.84000.co/ns/1.0', 'alternative') } {
                    $term/@xml:lang,
                    normalize-space(data($term))
                }
            
            else if($term[@type eq 'definition']) then
                element { QName('http://read.84000.co/ns/1.0', 'definition') } {
                    attribute glossarize { 'mark' },
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
            let $title := tei-content:title-any($tei)
            
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

    let $sort-term := $gloss/tei:term[not(@xml:lang) or @xml:lang eq 'en'][not(@type = ('definition','alternative','translationAlternative'))][1]/data() ! normalize-space(.) ! lower-case(.) ! common:normalized-chars(.) ! common:alphanumeric(.)
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

(:declare function glossary:matching-entries($term as xs:string, $lang as xs:string) as element(m:glossary) {
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
};:)

(:declare function glossary:cumulative-glossary($chunk as xs:integer) as element() {

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
        
};:)

declare function local:distinct-terms($terms as element(tei:term)*) as xs:string* {
    for $term in $terms
    let $term-text := string-join($term/text(), '') ! normalize-space(.)
    where $term-text
    let $term-text-sort := common:normalized-chars(lower-case($term-text))
    let $term-text-starred := concat($glossary:attestation-types//m:attestation-type[@id eq $term/@type or m:migrate[@id eq $term/@type]][contains(@rend, 'asterisk')] ! '*', $term-text)
    let $term-text-sort-starred := concat($star, $term-text-sort)
    group by $term-text-sort-starred
    order by $term-text-sort[1]
    return 
        $term-text-starred[1]
};

(:declare function local:concat-terms($terms as element(tei:term)*) as xs:string {
    string-join( local:concat-terms($terms), '; ')
};:)

(:declare function local:term-star($term as element(tei:term)) as xs:string {
    if($term[@type = ('reconstruction', 'semanticReconstruction','transliterationReconstruction')]) then '*' else ''
};:)

declare function glossary:cache-combined-xml($request-xml as element(m:request), $cache-key as xs:string) as xs:boolean {
    
    (: This needs generating in a different way as it exceeds the limit for output in exist :)
    
    let $entities := $entities:entities/m:entity
    let $glossaries := $glossary:tei//tei:back/tei:div[@type eq 'glossary'][not(@status = 'excluded')]
    
    let $terms :=
        for $entity at $index in $entities
        (:where $index le 100:)
        let $glossary-entries := $glossaries//id($entity/m:instance[not(m:flag)]/@id)[not(@mode eq 'surfeit')]
        where $glossary-entries
        (: Get unique terms :)
        return 
            for $term-wy in $glossary-entries/tei:term[@xml:lang eq 'Bo-Ltn']
            let $term-wy-text := normalize-space(string-join($term-wy/text(),''))
            where $term-wy-text
            group by $term-wy-text
            order by $term-wy-text
            let $term-glosses := $term-wy/parent::tei:gloss
            return
                element { QName('http://read.84000.co/ns/1.0', 'term') } {
                    
                    (: TO DO: Create endpoints for these uris :)
                    attribute entity { concat('http://purl.84000.co/resource/core/', $entity/@xml:id) },
                    
                    attribute href { concat($common:environment/m:url[@id eq 'reading-room'],'/glossary/', $entity/@xml:id, '.html') },
                    
                    attribute sort-key { replace(common:normalized-chars(lower-case($term-wy-text)), '[^a-z0-9\s]', '') },
                    
                    (: Re-generate the tibetan from wylie as we can't be sure which terms match :)
                    text{ common:ws(2) } ,
                    element tibetan { common:bo-term($term-wy-text) },
                    
                    text{ common:ws(2) } ,
                    element wylie { $term-wy-text },
                    
                    (: Merge entries :)
                    distinct-values($term-glosses/@type) ! ( text{ common:ws(2) }, element type { concat('eft:', .) } ),
                    local:distinct-terms($term-glosses/tei:term[not(@xml:lang)][not(@type)][normalize-space(text())]) ! ( text{ common:ws(2) }, element translation { . } ),
                    local:distinct-terms($term-glosses/tei:term[@xml:lang eq 'Sa-Ltn'][normalize-space(text())]) ! ( text{ common:ws(2) }, element sanskrit { lower-case(.) } ),
                    local:distinct-terms($term-glosses/tei:term[@xml:lang eq 'zh'][normalize-space(text())]) ! ( text{ common:ws(2) }, element chinese { . } ),
                    
                    (: Definition :)
                    $entity/m:content[@type eq 'glossary-definition'][descendant::text()[normalize-space()]] ! ( text{ common:ws(2) }, element definition { string-join(descendant::text() ! normalize-space(.), '') } ),
                    
                    (: Details of individual entries :)
                    (: Provisionally add gloss id :)
                    for $gloss in $term-glosses
                    
                    let $tei := $gloss/ancestor::tei:TEI
                    let $text-id := tei-content:id($tei)
                    let $bibls := $tei[1]/tei:teiHeader//tei:bibl
                    group by $text-id
                    return ( 
                        text{ common:ws(2) }, 
                        
                        element ref {
                        
                            for $bibl in $tei[1]/tei:teiHeader//tei:bibl
                            let $toh := translation:toh($tei[1], $bibl/@key)
                            order by $toh/m:base/text()
                            return (
                                text{ common:ws(3) }, 
                                
                                (: Toh number :)
                                element toh {
                                    $toh/@key,
                                    $toh/m:base/text()
                                },
                                
                                (: Glossary links :)
                                $gloss ! ( text{ common:ws(3) }, element link { attribute href { translation:canonical-html($toh/@key, ()) || '#' || @xml:id } } )
                                
                            ),
                            
                            (: Titles :)
                            tei-content:title-set($tei[1], 'mainTitle')//m:title ! ( text{ common:ws(3) }, . ),
                            
                            (: Authors :)
                            $tei[1]//tei:titleStmt/tei:author[@role eq "translatorEng"] !  ( text{ common:ws(3) }, element translator { attribute uri { concat('http://purl.84000.co/resource/core/eft:', contributors:contributor-id(@ref)) }, normalize-space(text()) } ),
                            
                            (: Definition :)
                            $gloss/tei:*[@type eq 'definition'][descendant::text()[normalize-space()]] !  ( text{ common:ws(3) }, element definition { string-join(descendant::text() ! normalize-space(.), '') } ),
                            
                            text{ common:ws(2) }
                            
                        }
                    )
                    
                    ,
                    text{ common:ws(1) }
                    
                }
                
    (: Save file with just the terms :)
    let $glossary-combined := 
        element { QName('http://read.84000.co/ns/1.0', 'glossary-combined') } {
        
            attribute created { current-dateTime() },
            attribute app-version { $common:app-version },
            attribute count-entites { count($entities) },
            
            (: Terms sorted :)
            for $term in $terms
            order by $term/@sort-key
            return ( text{ common:ws(1) } , $term )
            ,
            
            text{ $common:chr-nl }
        }
    
    let $cache-put := common:cache-put($request-xml, $glossary-combined, $cache-key)
    
    return 
        true()
            
};

declare function glossary:spreadsheet-data($request-xml as element(m:request), $cache-key as xs:string) as element(m:spreadsheet-data) {
    
    let $glossary-combined := common:cache-get($request-xml, $cache-key)//m:glossary-combined
    where $glossary-combined
    return
    element { QName('http://read.84000.co/ns/1.0', 'spreadsheet-data') } {
    
        attribute key { concat('84000-glossary-', format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]'))},
        
        for $term in $glossary-combined/m:term
        return
            element row {
                element Tibetan { $term/m:tibetan/string() },
                element Wylie { $term/m:wylie/string() },
                element Type { string-join($term/m:type, '; ') },
                element Translation { string-join($term/m:translation, '; ') },
                element Sanskrit { string-join($term/m:sanskrit, '; ') },
                element Chinese { string-join($term/m:chinese, '; ') },
                element Definition { 
                    attribute width { '80' }, 
                    string-join($term/m:definition, '; ')
                },
                element Tohs { string-join($term/m:ref/m:toh , '; ') },
                if($term[@href]) then
                    element Link { 
                        attribute width { '40' }, 
                        $term/@href/string() 
                    }
                else ()
            }
            
    }
    
};

declare function glossary:combined-txt($request-xml as element(m:request), $cache-key as xs:string, $key as xs:string?) as text()* {
    
    let $glossary-combined := common:cache-get($request-xml, $cache-key)//m:glossary-combined
    where $glossary-combined
    return
        for $term at $position in $glossary-combined/m:term
        where $term/m:tibetan[text()]
        return (
            
            if($position gt 1) then text { '&#10;' } else (),
            text { 
                concat(
                    if($key eq 'wy') then $term/m:wylie/text() else $term/m:tibetan/text(), '&#9;',
                    if($term/m:type[text()]) then concat('Type: ', string-join($term/m:type, '; '), ' / ') else (),
                    if($term/m:translation[text()]) then concat('Translated: ', string-join($term/m:translation, '; '), ' / ') else (),
                    if($term/m:sanskrit[text()]) then concat('Sanskrit: ', string-join($term/m:sanskrit, '; '), ' / ') else (),
                    if($term/m:chinese[text()]) then concat('Chinese: ', string-join($term/m:chinese, '; '), ' / ') else (),
                    if($term/m:definition[text()]) then concat('Definition: ', string-join($term/m:definition, '; '), ' / ') else (),
                    if($term[@href]) then
                        concat('Link: ', $term/@href/string())
                    else ()
                    (:concat('Tohs: ', string-join($term/m:ref/m:toh, '; '), ' / '),:)
                    (:concat('Translators: ', string-join($term/m:ref/m:translator, '; ')):)
                )
            }
    
        )
};

declare function glossary:item-count($tei as element(tei:TEI)) as xs:integer {

    count($tei//tei:back//tei:div[@type eq 'glossary']//tei:item)
    
};

(:declare function glossary:item-query($gloss as element(tei:gloss)) as element() {
    <query>
        <bool>
        {
            for $term in 
                $gloss/tei:term[@xml:lang eq 'en'][not(@type = ('definition','alternative','translationAlternative'))] 
                | $gloss/tei:term[not(@xml:lang)][not(@type = ('definition','alternative','translationAlternative'))]
                | $gloss/tei:term[@type = ('alternative','translationAlternative')]
            let $term-str := normalize-space(data($term))
            return (
                <phrase>{ $term-str }</phrase>,
                <phrase>{ $term-str }s</phrase>
            )
        }
        </bool>
    </query>
};:)

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
                translation:titles($tei, $source/@key),
                translation:long-titles($tei, $source/@key),
                $source,
                translation:toh($tei, $source/@key),
                translation:publication($tei),
                translation:parts($tei, 'all', $translation:view-modes/m:view-mode[@id eq 'glossary-check'], ())
            }
    
    (: Include caches - do not call glossary:cache(), this causes a recursion problem :)
    let $glossary-cache := glossary:cache($tei, false())/m:glossary-cache
    
    let $text-outline := translation:outline-cached($tei)
    
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
                $text-outline,
                $glossary-cache,
                $replace-text
            )
        )
        
};

declare function glossary:filter($tei as element(tei:TEI), $resource-type as xs:string, $filter as xs:string, $search as xs:string) as element(tei:gloss)* {
    
    (: Glossary cache (on) :)
    let $glossary-cache := glossary:cache($tei, false())/m:glossary-cache/m:gloss
    
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
        
        (: Entries using entity definitions :)
        else if($filter eq 'entity-definition') then
            let $instances-entity-definition := $entities:entities//m:entity[m:content[@type eq 'glossary-definition'][node()]]/m:instance
            return
                $tei//tei:back//tei:div[@type eq 'glossary']//id($instances-entity-definition[@use-definition = ('both','append','prepend','override')]/@id)/self::tei:gloss
                | $tei//tei:back//tei:div[@type eq 'glossary']//id($instances-entity-definition/@id)/self::tei:gloss[not(tei:*[@type eq 'definition'][node()])]
        
        (: Entities with only one entry :)
        else if($filter = ('shared-entities', 'exclusive-entities')) then
            let $entities-single-instance := $entities:entities//m:entity[count(m:instance) eq 1]
            return
                if($filter eq 'exclusive-entities') then
                    $tei//tei:back//tei:div[@type eq 'glossary']//id($entities-single-instance/m:instance/@id)/self::tei:gloss
                else
                    let $entities-multiple-instances := $entities:entities//m:entity[m:instance] except $entities-single-instance
                    return
                        $tei//tei:back//tei:div[@type eq 'glossary']//id($entities-multiple-instances/m:instance/@id)/self::tei:gloss
        
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
        if($entities:flags//m:flag[@id eq $filter][not(@type eq 'computed')]) then
            for $gloss in $tei-gloss
            let $entity-flagged := $entities:entities//m:instance[@id eq $gloss/@xml:id]/m:flag[@type = $filter]
            where $entity-flagged
            return $gloss
        else
            $tei-gloss
    
    (: Filter by search term :)
    let $tei-gloss := 
        if(normalize-space($search) gt '') then
            $tei-gloss[ft:query(tei:term[not(@type eq 'definition')], local:search-query($search), local:search-options())]
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
    where not($glossary-matches/ancestor::xhtml:*[@data-location-id][1][not(@data-location-id eq $location/@id)])
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
    
    (: Select the nearest parent with a data-location-id :)
    let $expression-container := $expression/ancestor-or-self::xhtml:*[@data-location-id][1]
    
    let $location-id := $expression-container/@data-location-id
    
    group by $location-id
    order by $sort-index[1]
    return
        element { QName('http://read.84000.co/ns/1.0', 'location') } {
        
            attribute id { $location-id[1] },
            attribute sort-index { $sort-index[1] },
            
            element preceding-ref {
                if($expression-container[descendant::xhtml:a[@data-ref]]) then
                    $expression-container/descendant::xhtml:a[@data-ref][1]
                else
                    $expression-container/ancestor-or-self::xhtml:div[preceding-sibling::xhtml:div[descendant::xhtml:a[@data-ref]]][1]/preceding-sibling::xhtml:div[descendant::xhtml:a[@data-ref]][1]/descendant::xhtml:a[@data-ref][last()]
            },
            
            element preceding-bookmark {
                if($expression-container[descendant::xhtml:a[@data-bookmark]]) then
                    $expression-container/descendant::xhtml:a[@data-bookmark][1]
                else
                    $expression-container/ancestor-or-self::xhtml:div[preceding-sibling::xhtml:div[descendant::xhtml:a[@data-bookmark]]][1]/preceding-sibling::xhtml:div[descendant::xhtml:a[@data-bookmark]][1]/descendant::xhtml:a[@data-bookmark][1]
            },
            
            $expression-container
            
        }

};

declare function glossary:cache($tei as element(tei:TEI), $create-if-unavailable as xs:boolean?) as element(m:cache)? {
    
    let $text-id := tei-content:id($tei)
    let $cache-collection := concat($common:data-path, '/', 'cache')
    let $cache-file := concat($text-id, '.cache')
    let $cache-uri := concat($cache-collection, '/', $cache-file)
    let $cache := doc($cache-uri)/m:cache[m:glossary-cache]
    let $cache-empty := <cache xmlns="http://read.84000.co/ns/1.0"><glossary-cache/></cache>
    
    let $cache := 
        if(not(doc-available($cache-uri))) then 
            if($create-if-unavailable and $tei/tei:text//tei:div) then 
                let $cache-create := xmldb:store($cache-collection, $cache-file, $cache-empty, 'application/xml')
                let $set-permissions := (
                    sm:chown(xs:anyURI($cache-uri), 'admin'),
                    sm:chgrp(xs:anyURI($cache-uri), 'tei'),
                    sm:chmod(xs:anyURI($cache-uri), 'rw-rw-r--')
                )
                return
                    doc($cache-uri)/m:cache
            else 
                $cache-empty
        else 
            $cache
    
    return
        $cache
};

declare function glossary:glossary-cache($tei as element(tei:TEI), $refresh-locations as xs:string*, $create-if-unavailable as xs:boolean?) as element(m:glossary-cache) {
    
    let $glossary-cache := glossary:cache($tei, $create-if-unavailable)/m:glossary-cache
    
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
            let $tei-glossary := $tei//tei:back//tei:list[@type eq 'glossary']/tei:item/tei:gloss[@xml:id][not(@mode eq 'surfeit')]
            
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

declare function glossary:pre-processed($tei as element(tei:TEI)) as element(m:pre-processed) {
    
    let $start-time := util:system-dateTime()
    
    let $text-id := tei-content:id($tei)
    
    (: TEI glossary items :)
    let $tei-glossary-sorted :=
        for $gloss in $tei//tei:back//tei:list[@type eq 'glossary']/tei:item/tei:gloss[@xml:id][not(@mode eq 'surfeit')]
        let $sort-term := glossary:sort-term($gloss)
        order by $sort-term/text()
        return 
            element { QName('http://read.84000.co/ns/1.0', 'gloss') } {
                attribute id { $gloss/@xml:id },
                attribute word-count { $sort-term/@word-count },
                attribute letter-count { $sort-term/@letter-count }
            }
    
    let $glosses :=
        for $gloss at $index in $tei-glossary-sorted
        return
            element { QName('http://read.84000.co/ns/1.0', 'gloss') } {
                $gloss/@*,
                attribute index { $index }
            }
    
    let $end-time := util:system-dateTime()
    
    return
        tei-content:pre-processed(
            $text-id,
            'glossary',
            functx:total-seconds-from-duration($end-time - $start-time),
            $glosses
        )
};

declare function glossary:downloads() as element(m:downloads) {

    element { QName('http://read.84000.co/ns/1.0', 'downloads') } {
    
        attribute resource-id { 'glossary-combined' },
        
        for $type in ('xml', 'xlsx', 'txt', 'dict')
        let $keys := if($type = ('txt', 'dict')) then ('bo', 'wy') else ('')
        for $key in $keys
        return
            let $request := 
                element { QName('http://read.84000.co/ns/1.0', 'request')} {
                    attribute model { 'glossary-download' },
                    attribute resource-suffix { $type },
                    $key[. gt ''] ! attribute key { $key }
                }
            let $latest-key := common:cache-key-latest($request)
            where $latest-key
            return
                element download {
                    attribute type { $type },
                    attribute url { '/glossary/search.html' },
                    attribute download-url { concat('/glossary-download', '.', $type, $key[. gt ''] ! concat('?key=', $key)) },
                    attribute filename { concat($latest-key, $key[. gt ''] ! concat('-', $key), '.', $type, $type[. eq 'dict'] ! '.zip') },
                    attribute last-modified { common:cache-last-modified($request, $latest-key) },
                    (:$latest-key ! attribute latest-key { $latest-key }:)
                    if($type eq 'xml') then
                        text { 'The complete combined glossary as XML' }
                    else if($type eq 'xlsx') then
                        text { 'As Microsoft Excel spreadsheet' }
                    else if($type eq 'txt') then
                        if($key eq 'bo') then
                            text { 'As text (compatible with OmegaT) with Tibetan script key' }
                        else if($key eq 'wy') then
                            text { 'As text (compatible with OmegaT) with Wylie key' }
                        else ()
                    else if($type eq 'dict') then
                        if($key eq 'bo') then
                            text { 'As dict format for GoldenDict / StarDict with Tibetan script key' }
                        else if($key eq 'wy') then
                            text { 'As dict format for GoldenDict / StarDict with Wylie key' }
                        else ()
                    else ()
                }
    
    }

};
