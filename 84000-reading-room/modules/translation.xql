xquery version "3.1";

module namespace translation="http://read.84000.co/translation";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace functx="http://www.functx.com";
import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";


declare function translation:titles($translation as node()) as node()* {
    <titles xmlns="http://read.84000.co/ns/1.0">
    {
        tei-content:title-set($translation, 'mainTitle')
    }
    </titles>
};

declare function translation:long-titles($translation as node()) as node()* {
    <long-titles xmlns="http://read.84000.co/ns/1.0">
    {
        tei-content:title-set($translation, 'longTitle')
    }
    </long-titles>
};

declare function translation:title-variants($translation as node()) as node()* {
    <title-variants xmlns="http://read.84000.co/ns/1.0">
    {
        for $title in $translation//tei:titleStmt/tei:title[not(@type eq 'mainTitle')]
        return
            <title xml:lang="{ $title/@xml:lang }">
            {
                $title/text()
            }
            </title>
    }
    </title-variants>
};

declare function translation:translation($translation as node()) as node()* {
    <translation xmlns="http://read.84000.co/ns/1.0">
        <authors>
            {
                for $author in $translation//tei:titleStmt/tei:author[not(@role = 'translatorMain')]
                return 
                    <author>{ normalize-space($author/text()) }</author>
            }
            <summary>{ $translation//tei:titleStmt/tei:author[@role = 'translatorMain'][1]/node() }</summary>
        </authors>
        <editors>
        {
            for $editor in $translation//tei:titleStmt/tei:editor
            return 
                <editor>{ normalize-space($editor/text()) }</editor>
        }
        </editors>
        <edition>{ $translation//tei:editionStmt/tei:edition[1]/node() }</edition>
        <license img-url="{ $translation//tei:publicationStmt/tei:availability/tei:licence/tei:graphic/@url }">
        {
            $translation//tei:publicationStmt/tei:availability/tei:licence/tei:p
        }
        </license>
        <publication-statement>
        {
            $translation//tei:publicationStmt/tei:publisher/node()
        }
        </publication-statement>
        <publication-date>
        {
            $translation//tei:publicationStmt/tei:date/text()
        }
        </publication-date>
        <tantric-restriction>
        {
            $translation//tei:publicationStmt/tei:availability/tei:p[@type eq 'tantricRestriction']
        }
        </tantric-restriction>
    </translation>
};

declare function translation:toh-key($translation as node(), $resource-id as xs:string) as xs:string {
    
    let $bibl := tei-content:source-bibl($translation, $resource-id)
    
    return 
        if($bibl/@key)then
            $bibl/@key 
        else
            ''
};

declare function translation:toh($tei as node(), $resource-id as xs:string) as node() {
    (: Returns a toh meta-data for sorting grouping  :)
    let $bibl := tei-content:source-bibl($tei, $resource-id)
    let $bibls := $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl
    let $toh := replace(lower-case($bibl/@key), '^toh', '')
    let $full := normalize-space(string-join($bibl/tei:ref//text(), ' +'))
    return
        <toh xmlns="http://read.84000.co/ns/1.0" 
            key="{ $bibl/@key }"
            number="{ replace($toh, '^(\d+)([a-zA-Z]*)\-*(\d*)([a-zA-Z]*)', '$1') }"
            letter="{ replace($toh, '^(\d+)([a-zA-Z]*)\-*(\d*)([a-zA-Z]*)', '$2') }"
            chapter-number="{ replace($toh, '^(\d+)([a-zA-Z]*)\-*(\d*)([a-zA-Z]*)', '$3') }"
            chapter-letter="{ replace($toh, '^(\d+)([a-zA-Z]*)\-*(\d*)([a-zA-Z]*)', '$4') }">
            <base>{ $toh }</base>
            <full>{ $full }</full>
            <duplicates>
            {
                if(count($bibls) gt 1) then
                    concat(
                        'Toh ',
                        string-join(
                            for $bibl-i in $bibls
                            return
                                normalize-space(string-join(replace(lower-case($bibl-i/@key), '^toh', ''), ' +'))
                        , ' / ')
                    )
                else
                    $full
            }
            </duplicates>
        </toh>
};

declare function translation:location($tei as node(), $resource-id as xs:string) as node() {
    let $bibl := tei-content:source-bibl($tei, $resource-id)
    return
        <location xmlns="http://read.84000.co/ns/1.0">
            <start volume="{ $bibl/tei:location/tei:start/@volume }" page="{ $bibl/tei:location/tei:start/@page }"/>
            <end volume="{ $bibl/tei:location/tei:end/@volume }" page="{ $bibl/tei:location/tei:end/@page }"/>
        </location>
};

declare function translation:filename($translation as node(), $resource-id as xs:string) as xs:string {

    let $diacritics  := 'āḍḥīḷḹṃṇñṅṛṝṣśṭūṁ'
    let $normalized := 'adhillmnnnrrsstum'
    
    let $toh-key := translation:toh-key($translation, $resource-id)
    let $title := tei-content:title($translation)
    
    return
        replace(
            replace(
                translate(
                    lower-case(
                        string-join(($toh-key, '84000', $title), ' ')   (: toh / 84000 / title :)
                    )                                                   (: lower case :)
                 , $diacritics, $normalized)                            (: remove diacritics :)
            , '[^a-zA-Z0-9\s]', '')                                     (: remove non-alphanumeric :)
        , '\s', '-')                                                    (: convert spaces to - :)
};

declare function translation:downloads($translation as node(), $resource-id as xs:string) as node()* {
    let $filename := translation:filename($translation, $resource-id)
    return
        <downloads xmlns="http://read.84000.co/ns/1.0">
            {
                if(util:binary-doc-available(concat($common:data-path, '/pdf/', $resource-id ,'.pdf'))) then
                    <download type="pdf" url="{ concat('/data/pdf/', $resource-id ,'.pdf') }" filename="{ concat($filename, '.pdf') }" fa-icon-class="fa-file-pdf-o">
                        Download PDF
                    </download>
                else
                    ()
            }
            {
                if(util:binary-doc-available(concat($common:data-path, '/epub/', $resource-id ,'.epub'))) then
                    <download type="epub" url="{ concat('/data/epub/', $resource-id ,'.epub') }" filename="{ concat($filename, '.epub') }" fa-icon-class="fa-book">
                        Download EPUB
                    </download>
                else
                    ()
            }
            {
                if(util:binary-doc-available(concat($common:data-path, '/azw3/', $resource-id ,'.azw3'))) then
                    <download type="azw3" url="{ concat('/data/azw3/', $resource-id ,'.azw3') }" filename="{ concat($filename, '.azw3') }" fa-icon-class="fa-amazon">
                        Download AZW3 (Kindle)
                    </download>
                else
                    ()
            }
        </downloads>
};

declare function translation:summary($translation as node()) as node()* {
    <summary xmlns="http://read.84000.co/ns/1.0" prefix="s">
    { 
        $translation//tei:front//tei:div[@type='summary']/*[self::tei:p | self::tei:milestone | self::tei:lg ]/.
    }
    </summary>
};

declare function translation:acknowledgment($translation as node()) as node()* {
    <acknowledgment xmlns="http://read.84000.co/ns/1.0" prefix="ac" sponsored="{ $translation//tei:front//tei:div[@type='acknowledgment']/@sponsored }">
    { 
        $translation//tei:front//tei:div[@type='acknowledgment']/*[self::tei:p | self::tei:milestone | self::tei:lg ]/.
    }
    </acknowledgment>
};

declare function translation:nested-section($section as node()*) as node()* {
    if($section) then
        <nested-section xmlns="http://read.84000.co/ns/1.0">
            {
                $section/*[self::tei:head[not(lower-case(text()) = ("prologue", "colophon"))] | self::tei:p | self::tei:milestone | self::tei:ab | self::tei:lg | self::tei:lb | self::tei:q | self::tei:list | self::tei:trailer | self::tei:label ]
            }
            {
                for $sub-section in $section/tei:div[@type eq 'section']
                return
                    translation:nested-section($sub-section)
            }
        </nested-section>
    else 
        ()
};

declare function translation:introduction($translation as node()) as node()* {
    (: In the intro we flatten out the sections and only space by the heads :)
    <introduction xmlns="http://read.84000.co/ns/1.0" prefix="i">
    {
        translation:nested-section($translation//tei:front/tei:div[@type eq 'introduction'])
    }
    </introduction>
};

declare function translation:prologue($translation as node()) as node()* {
    <prologue xmlns="http://read.84000.co/ns/1.0" prefix="p">
    { 
        translation:nested-section($translation//tei:body/tei:div[@type='translation']/tei:div[@type='prologue' or tei:head/text()[lower-case(.) = "prologue"]])
    }
    </prologue>
};

declare function translation:body($translation as node()) as node()* {
    <body xmlns="http://read.84000.co/ns/1.0" prefix="tr">
        <honoration>{ data($translation//tei:body/tei:div[@type='translation']/tei:head[@type='titleHon']) }</honoration>
        <main-title>{ data($translation//tei:body/tei:div[@type='translation']/tei:head[@type='titleMain']) }</main-title>
        { 
            for $chapter at $chapter-index in $translation//tei:body//tei:div[@type='translation']/*[@type=('section', 'chapter')][not(tei:head/text()[lower-case(.) = "prologue"])]
            return
                <chapter chapter-index="{ $chapter-index }" prefix="{ $chapter-index }">
                    <title>
                    {
                        $chapter/tei:head[@type eq 'chapterTitle']/text()
                    }
                    </title>
                    <title-number>
                    {
                        if($chapter/tei:head[@type eq 'chapter']/text())then
                            $chapter/tei:head[@type eq 'chapter']/text()
                        else if($chapter/tei:head[@type eq 'chapterTitle']/text())then
                            concat('Chapter ', $chapter-index)
                        else
                            ()
                    }
                    </title-number>
                    {
                       $chapter/*[self::tei:p | self::tei:milestone | self::tei:ab | self::tei:lg | self::tei:lb | self::tei:q | self::tei:list | self::tei:trailer | self::tei:label ]/.
                    }
                </chapter>
        }
    </body>
};

declare function translation:colophon($translation as node()) as node()* {
    <colophon xmlns="http://read.84000.co/ns/1.0" prefix="c">
    { 
        translation:nested-section($translation//tei:body/tei:div[@type='translation']/tei:div[@type='colophon'])
    }
    </colophon>
};

declare function translation:appendix($translation as node()) as node()* {
    <appendix xmlns="http://read.84000.co/ns/1.0" prefix="ap">
    { 
        let $count-appendix := 
            count($translation//tei:back//*[@type='appendix']/*[@type = 'prologue' or tei:head[lower-case(text()) eq "appendix prologue"]])
            
        for $chapter at $chapter-index in $translation//tei:back//*[@type='appendix']/*[@type=('section', 'chapter', 'prologue')]
            let $chapter-number := xs:string($chapter-index - $count-appendix)
            let $chapter-class := 
                if($chapter/tei:head[lower-case(text()) eq "appendix prologue"])then
                    'p'
                else
                    $chapter-number
        return
            <chapter chapter-index="{ $chapter-class }" prefix="{ concat('ap', $chapter-class) }">
                <title>
                {
                    $chapter/tei:head[@type = ('section', 'chapter', 'prologue')]/text()
                }
                </title>
                {
                   $chapter/*[self::tei:p | self::tei:milestone | self::tei:ab | self::tei:lg | self::tei:lb | self::tei:q | self::tei:list | self::tei:trailer | self::tei:label ]/.
                }
            </chapter>
    }
    </appendix>
};

declare function translation:abbreviations($translation as node()) as node()* {
    <abbreviations xmlns="http://read.84000.co/ns/1.0" prefix="ab">
    {
        if($translation//tei:list[@type='abbreviations']/tei:head[text() and not(lower-case(text()) = ('abbreviations', 'abbreviations:'))])then
            <head>
            {
                $translation//tei:list[@type='abbreviations']/tei:head/text()
            }
            </head>
        else
            ()
    }
    {
        for $item in $translation//tei:list[@type='abbreviations']/tei:item[tei:abbr]
        return
            <item>
                <abbreviation>{ normalize-space($item/tei:abbr/text()) }</abbreviation>
                <explanation>{ $item/tei:expan/node() }</explanation>
            </item>
    }
    {
        if($translation//tei:list[@type='abbreviations']/tei:item[not(tei:abbr)]/text())then
            <foot>
            {
                $translation//tei:list[@type='abbreviations']/tei:item[not(tei:abbr)]/text()
            }
            </foot>
        else
            ()
    }
    </abbreviations>
};

declare function translation:notes($translation as node()) as node()* {
    <notes xmlns="http://read.84000.co/ns/1.0" prefix="n">
    {
        for $note in $translation//tei:text//tei:note
        return
            <note 
                index="{ $note/@index/string() }" 
                uid="{ $note/@xml:id/string() }">
            {  
                $note/node()
            }
            </note>
    }
    </notes>
};

declare function translation:bibliography-section($section as node()) as node()* {
    <nested-section xmlns="http://read.84000.co/ns/1.0">
        {
            if($section/tei:head[@type='section']/text())then
                <title>{ $section/tei:head[@type='section']/text() }</title>
            else
                ()
        }
        {
            for $item in $section/tei:bibl
            return
                <item>{ $item/node() }</item>
        }
        {
            for $sub-section in $section/tei:div[@type='section']
            return
                translation:bibliography-section($sub-section)
        }
    </nested-section>
};

declare function translation:bibliography($translation as node()) as node()* {
    <bibliography xmlns="http://read.84000.co/ns/1.0" prefix="b">
    {
        for $section in $translation//tei:back/*[@type='listBibl']/*[@type='section']
        return
            translation:bibliography-section($section)
    }
    </bibliography>
};

declare function translation:glossary($translation as node()) as node()* {
    <glossary xmlns="http://read.84000.co/ns/1.0" prefix="g">
    {
        for $gloss in $translation//tei:back//*[@type='glossary']//tei:gloss
        return
            <item 
                uid="{ $gloss/@xml:id/string() }" 
                type="{ $gloss/@type/string() }" 
                mode="{ $gloss/@mode/string() }">
                <term xml:lang="en">
                { 
                    normalize-space(functx:capitalize-first($gloss/tei:term[not(@xml:lang)][not(@type)][1]/text())) 
                }
                </term>
                {
                    for $item in $gloss/tei:term
                    return 
                        if($item[@type eq 'definition']) then
                            <definition>
                            { 
                                $item/node() 
                            }
                            </definition>
                        else if ($item[@type eq 'alternative']) then
                            <alternative xml:lang="{ lower-case($item/@xml:lang) }">
                            { 
                                normalize-space(string($item)) 
                            }
                            </alternative>
                        else if ($item[@xml:lang]) then
                            <term xml:lang="{ lower-case($item/@xml:lang) }">
                            {
                                if (not($item/text())) then
                                    common:app-text(concat('glossary.term-empty-', lower-case($item/@xml:lang)))
                                else if ($item/@xml:lang eq 'Bo-Ltn') then
                                    common:bo-ltn($item/text())
                                else
                                    $item/text() 
                            }
                            </term>
                        else 
                            ()
                 }
            </item>
    }
    </glossary>
};

declare function translation:word-count($translation as node()) as xs:integer {
    let $translated-text := 
        $translation//tei:text/tei:body/tei:div[@type = "translation"]/*[
            self::tei:div[@type = ("section", "chapter", "colophon")] 
            or self::tei:head[@type ne 'translation']
        ]//text()[not(ancestor::tei:note)]
    return
        common:word-count($translated-text)
};

declare function translation:glossary-count($translation as node()) as xs:integer {
    count($translation//*[@type='glossary']//tei:item)
};

declare function translation:title-listing($translation-title as xs:string*) as xs:string* {
    let $first-word := substring-before($translation-title, ' ')
    return
        if(lower-case($first-word) = ('the')) then
            concat(substring-after($translation-title, concat($first-word, ' ')), ', ', $first-word)
        else
            $translation-title
};

declare function translation:folios($translation as node(), $resource-id as xs:string) as node() {
    
    let $translation-id := tei-content:id($translation)
    let $volume := translation:volume($translation, $resource-id)
    let $toh := translation:toh($translation, $resource-id)
    
    return
        <folios xmlns="http://read.84000.co/ns/1.0" volume="{ $volume }" toh-key="{ $toh/@key }">
        {
            for $folio in $translation//tei:body//*[@type eq 'translation']//tei:ref[not(@type)][not(@key) or @key eq $toh/@key][lower-case(substring(@cRef,1,2)) eq 'f.']
                
                let $folio-ref := lower-case(string($folio/@cRef))
                let $page := substring-before(substring-after($folio-ref, 'f.'), '.')
                let $side := substring-after($folio-ref, concat($page,'.'))

            return
                <folio 
                    toh="{ $toh/m:base }" 
                    page="{ $page }" 
                    side="{ $side }"
                    id="{ $folio-ref }">
                    <url response="xml">
                    {
                        concat($common:environment/m:url[@id eq 'reading-room']/text(),'/translation/', $toh/@key, '.xml?folio=', $page, '.', $side)
                    }
                    </url>
                </folio>
                
        }
        </folios>
};

declare function translation:volume($translation as node(), $resource-id as xs:string) as xs:integer {
    let $bibl := tei-content:source-bibl($translation, $resource-id)
    return
        xs:integer($bibl/tei:location/tei:start/@volume)
};

declare function translation:folio-content($translation as node(), $folio as xs:string, $resource-id as xs:string) as node() {
    
    let $volume := translation:volume($translation, $resource-id)
    let $toh-key := translation:toh-key($translation, $resource-id)
    let $refs := $translation//tei:div[@type='translation']//tei:ref[not(@type)][not(@key) or @key eq $toh-key][@cRef]
    let $start-ref := $refs[lower-case(@cRef) eq lower-case($folio)]
    let $start-ref-index := functx:index-of-node($refs, $start-ref)
    let $end-ref := $refs[$start-ref-index + 1]
    
    let $content := $translation//tei:body//tei:div[@type='translation']/*[@type=('section', 'chapter', 'colophon')]/*
    let $start-passage := $content[.//$start-ref]
    let $end-passage := $content[.//$end-ref]
    let $start-passage-position := 
        if($start-passage) then
            functx:index-of-node($content, $start-passage)
        else
            1
    let $end-passage-position := 
        if($end-passage) then
            functx:index-of-node($content, $end-passage)
        else
            count($content)
    
    let $folio-content := $content[position() ge $start-passage-position and position() le $end-passage-position]
    let $folio-content-spaced := 
        for $node in 
            $folio-content//text()[not(ancestor::tei:note)]
            | $folio-content//tei:ref[@cRef][not(@key) or @key eq $toh-key][not(@type)]
        return
            (: Catch instances where the string ends in a punctuation mark. Assume a space has been dropped. Add a space to concat to the next string. :)
            if($node[self::text()] and substring($node, string-length($node), 1) = ('.',',','!','?','”',':',';')) then
                concat($node, ' ')
            else if($node[self::text()] and $node[parent::tei:head]) then
                concat($node, '. ')
            else
                $node
    
    return
        <folio-content 
            xmlns="http://read.84000.co/ns/1.0" 
            volume="{ $volume }" 
            start-ref="{ $start-ref/@cRef }" 
            end-ref="{ $end-ref/@cRef }">
        {
            $folio-content-spaced
        }
        </folio-content>
};

(:
declare function translation:id($translation as node()){
    $translation//tei:publicationStmt/tei:idno/@xml:id/string()
};

declare function translation:tei($resource-id) as node() {
    (:
        This is controls the method of looking up the resource-id 
        from the controller and finding the document.
        Current options: 
        1.  UT Number e.g. translation/UT22084-061-013.html
            For Tohoku variations this will default to the first.
        2.  Tohoku Number e.g. translation/toh739.html
            Will show variations for that Tohoku key.
    :)
    
    (: based on Tohoku number :)
    let $tei := collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key eq lower-case($resource-id)][1]
    
    return
        if(not($tei)) then
            (: Default to UT number :)
            collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno/@xml:id eq upper-case($resource-id)]
        else
            $tei
};

declare function translation:title($translation as node()) as xs:string* {
    normalize-space($translation//tei:fileDesc//tei:title[@type='mainTitle'][lower-case(@xml:lang) = ('eng', 'en')][1]/text())
};

declare function translation:source-bibl($translation as node(), $resource-id as xs:string) as node()* {
    if($translation//tei:sourceDesc/tei:bibl[@key eq lower-case($resource-id)]) then
        $translation//tei:sourceDesc/tei:bibl[@key eq lower-case($resource-id)]
    else
        $translation//tei:sourceDesc/tei:bibl[1]
};

declare function translation:source($translation as node(), $resource-id as xs:string) as node()* {
    
    let $bibl := translation:source-bibl($translation, $resource-id)
    
    return
        <source xmlns="http://read.84000.co/ns/1.0" key="{ $bibl/@key }">
            <toh>{ normalize-space(data($bibl/tei:ref)) }</toh>
            <series>{ normalize-space(data($bibl/tei:series)) }</series>
            <scope>{ normalize-space(data($bibl/tei:biblScope)) }</scope>
            <range>{ normalize-space(data($bibl/tei:citedRange)) }</range>
            <authors>
            {
                for $author in $bibl/tei:author
                return 
                    <author>{ normalize-space($author/text()) }</author>
            }
            </authors>
            <location>
                <start volume="{ $bibl/tei:location/tei:start/@volume }" page="{ $bibl/tei:location/tei:start/@page }"/>
                <end volume="{ $bibl/tei:location/tei:end/@volume }" page="{ $bibl/tei:location/tei:end/@page }"/>
            </location>
        </source>
};

declare function translation:summary($translation as node()) as node()* {
    <summary xmlns="http://read.84000.co/ns/1.0" prefix="s">
    { 
        $translation//tei:front//tei:div[@type='summary']/*[self::tei:p | self::tei:milestone | self::tei:lg ]/.
    }
    </summary>
};



declare function translation:folio-content($translation as node(), $folio as xs:string, $resource-id as xs:integer) as node() {
    
    let $translation-id := translation:id($translation)
    let $volume := translation:volume($translation-id)
    let $toh-key := translation:toh-key($translation, $resource-id)
    let $refs := $translation//tei:div[@type='translation']//tei:ref[not(@key) or @key eq $toh-key][not(@type)][@cRef]
    let $start-ref := $refs[@cRef eq $folio]
    let $start-ref-index := functx:index-of-node($refs, $start-ref)
    let $end-ref := $refs[$start-ref-index + 1]
    
    let $content := $translation//tei:body//tei:div[@type='translation']/*[@type=('section', 'chapter', 'colophon')]/*
    let $start-passage := $content[.//$start-ref]
    let $end-passage := $content[.//$end-ref]
    let $start-passage-position := 
        if($start-passage) then
            functx:index-of-node($content, $start-passage)
        else
            1
    let $end-passage-position := 
        if($end-passage) then
            functx:index-of-node($content, $end-passage)
        else
            count($content)
    
    let $folio-content := $content[position() ge $start-passage-position and position() le $end-passage-position]
    let $folio-content-spaced := 
        for $node in 
            $folio-content//text()[not(ancestor::tei:note)]
            | $folio-content//tei:ref[@cRef][not(@key) or @key eq $toh-key][not(@type)]
        return
            (: Catch instances where the string ends in a punctuation mark. Assume a space has been dropped. Add a space to concat to the next string. :)
            if($node[self::text()] and substring($node, string-length($node), 1) = ('.',',','!','?','”',':',';')) then
                concat($node, ' ')
            else if($node[self::text()] and $node[parent::tei:head]) then
                concat($node, '. ')
            else
                $node
    
    return
        <folio-content 
            xmlns="http://read.84000.co/ns/1.0" 
            volume="{ $volume }" 
            start-ref="{ $start-ref/@cRef }" 
            end-ref="{ $end-ref/@cRef }">
        {
            $folio-content-spaced
        }
        </folio-content>
};

declare function translation:update($translation as node(), $request-parameters as xs:string*){

for $request-parameter in $request-parameters

    let $node := 
        if($request-parameter eq 'title-en') then
            $translation//tei:titleStmt/tei:title[@type='mainTitle'][lower-case(@xml:lang)= ('eng', 'en')]
        else if($request-parameter eq 'title-bo') then
            $translation//tei:titleStmt/tei:title[@type='mainTitle'][lower-case(@xml:lang)='bo']
        else if($request-parameter eq 'title-sa') then
            $translation//tei:titleStmt/tei:title[@type='mainTitle'][lower-case(@xml:lang)='sa-ltn']
        else if($request-parameter eq 'title-long-en') then
            $translation//tei:titleStmt/tei:title[@type='longTitle'][lower-case(@xml:lang)= ('eng', 'en')]
        else if($request-parameter eq 'title-long-bo') then
            $translation//tei:titleStmt/tei:title[@type='longTitle'][lower-case(@xml:lang)='bo']
        else if($request-parameter eq 'title-long-bo-ltn') then
            $translation//tei:titleStmt/tei:title[@type='longTitle'][lower-case(@xml:lang)='bo-ltn']
        else if($request-parameter eq 'title-long-sa-ltn') then
            $translation//tei:titleStmt/tei:title[@type='longTitle'][lower-case(@xml:lang)='sa-ltn']
        else if($request-parameter eq 'toh') then
            $translation//tei:sourceDesc/tei:bibl/tei:ref
        else if($request-parameter eq 'series') then
            $translation//tei:sourceDesc/tei:bibl/tei:series
        else if($request-parameter eq 'scope') then    
            $translation//tei:sourceDesc/tei:bibl/tei:biblScope
        else if($request-parameter eq 'range') then
            $translation//tei:sourceDesc/tei:bibl/tei:citedRange
        else
            ()
            
    let $new-value := request:get-parameter($request-parameter, '')
    
    return
        if($new-value and $node) then
            <updated xmlns="http://read.84000.co/ns/1.0" node="{ $request-parameter }">
            {
                update replace $node/text() with $new-value 
            }
            </updated>
         else if($new-value) then
            <updated xmlns="http://read.84000.co/ns/1.0" node="{ $request-parameter }">
            {
            
                if($request-parameter eq 'title-en') then
                    update insert <title type='mainTitle' xml:lang='en' xmlns="http://www.tei-c.org/ns/1.0">{ $new-value }</title> 
                        into $translation//tei:titleStmt/tei:title
                else if($request-parameter eq 'title-bo') then
                    update insert <title type='mainTitle' xml:lang='bo' xmlns="http://www.tei-c.org/ns/1.0">{ $new-value }</title> 
                        into $translation//tei:titleStmt/tei:title
                else if($request-parameter eq 'title-sa') then
                    update insert <title type='mainTitle' xml:lang='Sa-Ltn' xmlns="http://www.tei-c.org/ns/1.0">{ $new-value }</title> 
                        into $translation//tei:titleStmt/tei:title
                else if($request-parameter eq 'title-long-en') then
                    update insert <title type='longTitle' xml:lang='en' xmlns="http://www.tei-c.org/ns/1.0">{ $new-value }</title> 
                        into $translation//tei:titleStmt/tei:title
                else if($request-parameter eq 'title-long-bo') then
                    update insert <title type='longTitle' xml:lang='bo' xmlns="http://www.tei-c.org/ns/1.0">{ $new-value }</title> 
                        into $translation//tei:titleStmt/tei:title
                else if($request-parameter eq 'title-long-bo-ltn') then
                    update insert <title type='longTitle' xml:lang='Bo-Ltn' xmlns="http://www.tei-c.org/ns/1.0">{ $new-value }</title> 
                        into $translation//tei:titleStmt/tei:title
                else if($request-parameter eq 'title-long-sa-ltn') then
                    update insert <title type='longTitle' xml:lang='Sa-Ltn' xmlns="http://www.tei-c.org/ns/1.0">{ $new-value }</title> 
                        into $translation//tei:titleStmt/tei:title
                else if($request-parameter eq 'toh') then
                    update insert <ref xmlns="http://www.tei-c.org/ns/1.0">{ $new-value }</ref> 
                        into $translation//tei:sourceDesc/tei:bibl
                else if($request-parameter eq 'series') then
                    update insert <series  xmlns="http://www.tei-c.org/ns/1.0">{ $new-value }</series> 
                        into $translation//tei:sourceDesc/tei:bibl
                else if($request-parameter eq 'scope') then    
                    update insert <biblScope  xmlns="http://www.tei-c.org/ns/1.0">{ $new-value }</biblScope> 
                        into $translation//tei:sourceDesc/tei:bibl
                else if($request-parameter eq 'range') then
                    update insert <citedRange  xmlns="http://www.tei-c.org/ns/1.0">{ $new-value }</citedRange> 
                        into $translation//tei:sourceDesc/tei:bibl
                else
                    ()
            }
            </updated>
         else if($request-parameter eq 'authors') then
            
            let $authours := $translation//tei:sourceDesc/tei:bibl/tei:author
            for $position in 1 to (count($authours) + 1)
                let $request-parameter-n := concat('author-', $position)
                let $new-value := request:get-parameter($request-parameter-n, 'not-posted')
                let $node := $authours[$position]
            return
                if($new-value != 'not-posted') then
                    if($new-value and $node) then 
                        <updated xmlns="http://read.84000.co/ns/1.0" node="{ $request-parameter-n }">
                        {
                            update replace $node/text() with $new-value
                        }
                        </updated>
                    else if($new-value) then
                        <updated xmlns="http://read.84000.co/ns/1.0" node="{ $request-parameter-n }">
                        {
                            update insert <author role="translatorTib" xmlns="http://www.tei-c.org/ns/1.0">{ $new-value }</author> 
                                into $translation//tei:sourceDesc/tei:bibl
                        }
                        </updated>
                    else if($node) then 
                        <updated xmlns="http://read.84000.co/ns/1.0" node="{ $request-parameter-n }">
                        {
                            update delete $node
                        }
                        </updated>
                    else
                        ()
                 else 
                    ()
                    
         else
            ()
            
};
:)