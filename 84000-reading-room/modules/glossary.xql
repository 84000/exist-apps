xquery version "3.1" encoding "UTF-8";
(:
    Returns the cumulative glossary xml
    -------------------------------------------------------------
:)
module namespace glossary="http://read.84000.co/glossary";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";
import module namespace functx="http://www.functx.com";

declare variable $glossary:translations := collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = $tei-content:published-statuses];

(: tei:gloss @types ('term', 'person', 'place', 'text') :)

declare function glossary:ft-options() as node() {
    <options>
        <default-operator>or</default-operator>
        <phrase-slop>0</phrase-slop>
        <leading-wildcard>no</leading-wildcard>
        <filter-rewrite>yes</filter-rewrite>
    </options>
};

declare function glossary:ft-query($string as xs:string) as node() {
    <query>
        <phrase occur="must">{ $string }</phrase>
    </query>
};

declare function glossary:valid-lang($lang) as xs:string {
    if(lower-case($lang) eq 'bo-ltn') then
        'Bo-Ltn'
    else if(lower-case($lang) eq 'sa-ltn') then
        'Sa-Ltn'
    else if(lower-case($lang) eq 'bo') then
        'bo'
    else
        'en'
};

declare function glossary:glossary-terms($type as xs:string*, $lang as xs:string) as node() {
    
    let $valid-lang := glossary:valid-lang($lang)
    
    let $terms := distinct-values($glossary:translations//tei:back//tei:gloss[@type = $type]/tei:term[@xml:lang eq $valid-lang or ($valid-lang eq 'en' and  not(@xml:lang))][not(@type = ('definition','alternative'))]/text() ! lower-case(.) ! normalize-space(.))
    
    return
        <glossary
            xmlns="http://read.84000.co/ns/1.0"
            model-type="glossary-terms"
            type="{ $type }"
            lang="{ $lang }">
        {
            for $main-term in $terms
                
                let $normalized-term := common:alphanumeric(common:normalized-chars($main-term))
                let $start-letter := substring($normalized-term, 1, 1)
                
                let $matches := $glossary:translations//tei:back//tei:gloss/tei:term[not(@type eq 'definition')][ft:query(., glossary:ft-query($main-term), glossary:ft-options())]
                
                order by $normalized-term
            
            return
                <term start-letter="{ $start-letter }" count-items="{ count($matches) }">
                    <main-term>{ $main-term }</main-term>
                    <normalized-term>{ $normalized-term }</normalized-term>
                </term>
                
        }
        </glossary>
        
};

declare function glossary:cumulative-glossary() as node() {

    <cumulative-glossary
        xmlns="http://read.84000.co/ns/1.0"
        model-type="cumulative-glossary"
        timestamp="{ current-dateTime() }"
        app-id="{ $common:app-id }">
        <disclaimer>
        {
            common:app-text('cumulative-glossary.disclaimer')
        }
        </disclaimer>
        {
            let $terms := distinct-values($glossary:translations//tei:back//tei:gloss/tei:term[(@xml:lang eq 'en' or not(@xml:lang))][not(@type = ('definition','alternative'))]/text() ! normalize-space(.))
            
            return
                for $main-term in $terms
                
                    let $normalized-term := common:alphanumeric(common:normalized-chars($main-term))
                    let $glossary-items := glossary:glossary-items($main-term)
                    
                    order by $normalized-term
                
                return
                    <term>
                        <term>{ $main-term }</term>
                        <items>{ $glossary-items//m:item }</items>
                    </term>
                
        }
    </cumulative-glossary>
        
};

declare function glossary:glossary-items($normalized-term as xs:string) as node() {
    
    let $terms := $glossary:translations//tei:back//tei:gloss/tei:term[not(@type eq 'definition')][ft:query(., glossary:ft-query($normalized-term), glossary:ft-options())]
    
    return
        <glossary
            xmlns="http://read.84000.co/ns/1.0"
            model-type="glossary-items">
            <term>{ $normalized-term }</term>
            {
                for $term in $terms
                    
                    let $translation := $term/ancestor::tei:TEI
                    let $gloss := $term/parent::tei:gloss
                    let $translation-title := tei-content:title($translation)
                    let $translation-id := tei-content:id($translation)
                    let $glossary-id := $gloss/@xml:id/string()
                    let $uri := concat('http://read.84000.co/translation/', $translation-id, '.html#', $glossary-id)
                    
                    order by ft:score($term) descending
                    
                return 
                    <item 
                        translation-id="{ $translation-id }"
                        uid="{ $glossary-id }"
                        uri="{ $uri }"
                        type="{ $gloss/@type }">
                        <translation>
                            <toh>{ $translation//tei:sourceDesc/tei:bibl[1]/tei:ref/text() }</toh>
                            <title>{ $translation-title }</title>
                            <authors>
                                {
                                    for $author in $translation//tei:titleStmt/tei:author[not(@role = 'translatorMain')]
                                    return 
                                        element author {
                                            $author/@sameAs,
                                            $author/text() ! normalize-space(.) 
                                        }
                                }
                                {
                                    let $translator-main := $translation//tei:titleStmt/tei:author[@role = 'translatorMain'][1]
                                    return
                                        element summary {
                                            $translator-main/@sameAs,
                                            $translator-main/text() ! concat(normalize-space(.), ' ') ! normalize-space(.) 
                                        }
                                 }
                            </authors>
                            <editors>
                            {
                                for $editor in $translation//tei:titleStmt/tei:editor
                                return 
                                    <editor>{ normalize-space($editor/text()) }</editor>
                            }
                            </editors>
                            <edition>{ $translation//tei:editionStmt/tei:edition[1]/text() ! concat(normalize-space(.), ' ') ! normalize-space(.) }</edition>
                        </translation>
                        <term xml:lang="en">{ $gloss/tei:term[not(@type)][@xml:lang eq 'en' or not(@xml:lang)]/text()[1] ! functx:capitalize-first(.) ! normalize-space(.) }</term>
                        {
                            for $term-alt-langs in $gloss/tei:term[@xml:lang = ('bo', 'Bo-Ltn', 'Sa-Ltn')][not(@type = ('definition','alternative'))]
                            return 
                                <term xml:lang="{ lower-case($term-alt-langs/@xml:lang) }">
                                { 
                                    if ($term-alt-langs/@xml:lang eq 'Bo-Ltn') then
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
                    </item>
            }
        </glossary>
};

declare function glossary:item-count($translation as node()) as xs:integer {

    count($translation//tei:back//tei:div[@type eq 'glossary']//tei:item)
    
};

declare function glossary:item-query($item as node()) as node(){
    <query>
        <bool>
        {
            for $term in 
                $item/tei:term[@xml:lang eq 'en'][not(@type)] 
                | $item/tei:term[not(@xml:lang)][not(@type)]
                | $item/tei:term[@type = 'alternative']
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

declare function glossary:translation-glossary($translation as node()) as node()* {
    <glossary xmlns="http://read.84000.co/ns/1.0">
    {
        let $options := 
            <options>
                <default-operator>and</default-operator>
                <phrase-slop>0</phrase-slop>
                <leading-wildcard>no</leading-wildcard>
            </options>
            
        for $item in $translation//tei:back//*[@type='glossary']//tei:gloss
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
