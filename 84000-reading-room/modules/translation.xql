xquery version "3.1";

module namespace translation="http://read.84000.co/translation";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace sponsors="http://read.84000.co/sponsors" at "sponsors.xql";
import module namespace contributors="http://read.84000.co/contributors" at "contributors.xql";
import module namespace download="http://read.84000.co/download" at "download.xql";
import module namespace source="http://read.84000.co/source" at "source.xql";
import module namespace functx="http://www.functx.com";

declare function translation:titles($tei as element(tei:TEI)) as element() {
    <titles xmlns="http://read.84000.co/ns/1.0">
    {
        tei-content:title-set($tei, 'mainTitle')
    }
    </titles>
};

declare function translation:long-titles($tei as element(tei:TEI)) as element() {
    <long-titles xmlns="http://read.84000.co/ns/1.0">
    {
        tei-content:title-set($tei, 'longTitle')
    }
    </long-titles>
};

declare function translation:title-variants($tei as element(tei:TEI)) as element() {
    <title-variants xmlns="http://read.84000.co/ns/1.0">
    {
        for $title in $tei//tei:titleStmt/tei:title[not(@type eq 'mainTitle')]
        return
            <title xml:lang="{ $title/@xml:lang }">
            {
                normalize-space($title/text())
            }
            </title>
    }
    </title-variants>
};

declare function translation:translation($tei as element(tei:TEI)) as element() {
    <translation xmlns="http://read.84000.co/ns/1.0">
        <contributors>
            {
                for $contributor in $tei//tei:titleStmt/tei:author[@role eq 'translatorMain']
                return 
                    element summary {
                        $contributor/@ref,
                        $contributor/node()
                    }
            }
            {
                for $contributor in $tei//tei:titleStmt/tei:author[not(@role eq 'translatorMain')] | $tei//tei:titleStmt/tei:editor | $tei//tei:titleStmt/tei:consultant
                return 
                    element { local-name($contributor) }
                    {
                        $contributor/@role,
                        $contributor/@ref,
                        normalize-space($contributor/text())
                    }
            }
        </contributors>
        <sponsors>
            {
                for $sponsor in $tei//tei:titleStmt/tei:sponsor
                return 
                    <sponsor>
                    {
                        $sponsor/@ref,
                        normalize-space($sponsor/text())
                    }
                    </sponsor>
            }
        </sponsors>
        <edition>
        { 
            $tei//tei:editionStmt/tei:edition[1]/node() 
        }
        </edition>
        <license img-url="{ $tei//tei:publicationStmt/tei:availability/tei:licence/tei:graphic/@url }">
        {
            $tei//tei:publicationStmt/tei:availability/tei:licence/tei:p
        }
        </license>
        <publication-statement>
        {
            $tei//tei:publicationStmt/tei:publisher/node()
        }
        </publication-statement>
        <publication-date>
        {
            $tei//tei:publicationStmt/tei:date/text()
        }
        </publication-date>
        <tantric-restriction>
        {
            $tei//tei:publicationStmt/tei:availability/tei:p[@type eq 'tantricRestriction']
        }
        </tantric-restriction>
    </translation>
};

declare function translation:toh-key($tei as element(tei:TEI), $resource-id as xs:string) as xs:string {
    
    let $bibl := tei-content:source-bibl($tei, $resource-id)
    
    return 
        if($bibl/@key)then
            $bibl/@key 
        else
            ''
};

declare function translation:toh-str($bibl as element(tei:bibl)) as xs:string? {
    replace(lower-case($bibl/@key), '^toh', '')
};

declare function translation:toh-full($bibl as element(tei:bibl)) as xs:string? {
    normalize-space(string-join($bibl/tei:ref//text(), ' +'))
};

declare function translation:toh($tei as element(tei:TEI), $resource-id as xs:string) as element() {
    (: Returns a toh meta-data for sorting grouping  :)
    let $bibl := tei-content:source-bibl($tei, $resource-id)
    let $bibls := $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl
    let $toh-str := translation:toh-str($bibl)
    let $full := translation:toh-full($bibl)
    return
        <toh xmlns="http://read.84000.co/ns/1.0" 
            key="{ $bibl/@key }"
            number="{ replace($toh-str, '^(\d+)([a-zA-Z]*)\-*(\d*)([a-zA-Z]*)', '$1') }"
            letter="{ replace($toh-str, '^(\d+)([a-zA-Z]*)\-*(\d*)([a-zA-Z]*)', '$2') }"
            chapter-number="{ replace($toh-str, '^(\d+)([a-zA-Z]*)\-*(\d*)([a-zA-Z]*)', '$3') }"
            chapter-letter="{ replace($toh-str, '^(\d+)([a-zA-Z]*)\-*(\d*)([a-zA-Z]*)', '$4') }">
            <base>{ $toh-str }</base>
            <full>{ $full }</full>
            {
                if(count($bibls) gt 1) then
                    
                    let $duplicates := 
                        for $sibling in $bibls[@key ne $bibl/@key]
                        return
                            <duplicate key="{ $sibling/@key }">
                                <base>{ translation:toh-str($sibling) }</base>
                                <full>{ translation:toh-full($sibling) }</full>
                            </duplicate>
                            
                    return
                        <duplicates>
                        {
                            $duplicates,
                            <full>
                            {
                                concat('Toh ', string-join(($toh-str, $duplicates/m:base/text()), ' / '))
                            }
                            </full>
                        }
                        </duplicates>
                else
                    ()
            }
        </toh>
};

declare function translation:location($tei as element(tei:TEI), $resource-id as xs:string) as element() {
    let $bibl := tei-content:source-bibl($tei, $resource-id)
    return
        tei-content:location($bibl)
};

declare function translation:filename($tei as element(tei:TEI), $resource-id as xs:string) as xs:string {

    let $diacritics  := 'āḍḥīḷḹṃṇñṅṛṝṣśṭūṁ'
    let $normalized := 'adhillmnnnrrsstum'
    
    let $toh-key := lower-case(translation:toh-key($tei, $resource-id))
    let $title := 
        replace(
            translate(
                lower-case(
                    tei-content:title($tei)             (: get title :)
                )                                       (: convert to lower case :)
            , $diacritics, $normalized)                 (: remove diacritics :)
        ,'[^a-zA-Z0-9\s]', ' ')                         (: remove non-alphanumeric, except spaces :)
    
    let $file-title := concat($toh-key, '_', '84000', ' ', $title)
    let $filename := replace($file-title, '\s', '-')    (: convert spaces to hyphen :)
    return
        $filename
};

(: Just the version number part of the edition :)
declare function translation:version-number-str($tei as element(tei:TEI)) as xs:string {
    (: Remove all but the numbers and points :)
    replace($tei//tei:editionStmt/tei:edition/text()[1],'[^0-9\.]','')
};

(: Just the version number part of the edition :)
declare function translation:version-number($tei as element(tei:TEI)) as xs:integer* {
    (: Remove all but the numbers and points :)
    let $version-number-str := translation:version-number-str($tei)
    
    (: Split the numbers :)
    let $version-number-split := tokenize($version-number-str, '\.')
    
    return (
        if(count($version-number-split) gt 0 and functx:is-a-number($version-number-split[1])) then
            xs:integer($version-number-split[1])
        else
            0
        ,
        if(count($version-number-split) gt 1 and functx:is-a-number($version-number-split[2])) then
            xs:integer($version-number-split[2])
        else if ($version-number-split[1] gt 0) then
            0
        else
            1
        ,
        if(count($version-number-split) gt 2 and functx:is-a-number($version-number-split[3])) then
            xs:integer($version-number-split[3])
        else
            0
    )
};

(: Increment specific parts of the version number :)
declare function translation:version-number-str-increment($tei as element(tei:TEI), $part as xs:string) as xs:string {
    
    let $version-number := translation:version-number($tei)
    
    return string-join((
        if($part eq 'major') then
            $version-number[1] + 1
        else
            $version-number[1]
        ,
        if($part eq 'minor') then
            $version-number[2] + 1
        else if($part eq 'major') then
            0
        else
            $version-number[2]
        ,
        if($part eq 'revision') then
            $version-number[3] + 1
        else if($part = ('major', 'minor')) then
            0
        else
            $version-number[3]
    ), '.')
};

(: Just the date part of the edition :)
declare function translation:version-date($tei as element(tei:TEI)) as xs:string {
    (: Remove all but the numbers :)
    replace($tei//tei:editionStmt/tei:edition/tei:date/text(),'[^0-9]','')
};

(: The full version string :)
declare function translation:version-str($tei as element(tei:TEI)) as xs:string {
    replace(
        replace(
            normalize-space(
                string-join(
                    $tei//tei:editionStmt/tei:edition//text()   (: Get all text :)
                , ' ')                                          (: Make sure they don't concatenate :)
            )                                                   (: Normalize the whitespace :)
        , '[^a-zA-Z0-9\s\.]', '')                               (: Remove all but the alpanumeric, points and spaces :)
    , '\s', '-')                                                (: Replace the spaces with hyphens :)
};

declare function translation:downloads($tei as element(tei:TEI), $resource-id as xs:string, $include as xs:string) as element() {
    
    let $file-name := translation:filename($tei, $resource-id)
    let $tei-version := translation:version-str($tei)
    
    return
        <downloads xmlns="http://read.84000.co/ns/1.0" tei-version="{ $tei-version }" resource-id="{ $resource-id }">
        {
            for $type in ('pdf', 'epub', 'azw3')
                let $stored-version := download:stored-version-str($resource-id, $type)
                where (
                    ($include eq 'all')                                                                 (: return all types :)
                    or ($include eq 'any-version' and not($stored-version eq 'none'))                   (: return if there is any version :)
                    or ($include eq 'latest-version' and compare($stored-version, $tei-version) eq 0)   (: return only if it's the latest version :)
                )
            return
                element download {
                    attribute type { $type },
                    attribute url { concat('/data/', $file-name ,'.', $type) },
                    attribute version { $stored-version },
                    attribute fa-icon-class {
                        if($type eq 'epub') then
                            'fa-book'
                        else if($type eq 'azw3') then
                            'fa-amazon'
                        else if($type eq 'pdf') then
                            'fa-file-pdf-o'
                        else
                            ''
                    },
                    text {
                        if($type eq 'epub') then
                            'Download EPUB'
                        else if($type eq 'azw3') then
                            'Download AZW3 (Kindle)'
                        else if($type eq 'pdf') then
                            'Download PDF'
                        else
                            ''
                    }
                }
        }
        </downloads>
};

declare function translation:summary($tei as element(tei:TEI)) as element() {
    translation:summary($tei, '')
};

declare function translation:summary($tei as element(tei:TEI), $lang as xs:string) as element() {
    let $valid-lang := common:valid-lang($lang)
    let $valid-lang :=
        if($valid-lang eq '') then
            'en'
        else
            $valid-lang
    return
        <summary xmlns="http://read.84000.co/ns/1.0" prefix="s" xml:lang="{ $valid-lang }">
        { 
            if($valid-lang eq 'en') then
                $tei//tei:front//tei:div[@type eq 'summary'][not(@xml:lang) or @xml:lang = 'en']/*[self::tei:p | self::tei:milestone | self::tei:lg ]/.
            else
                $tei//tei:front//tei:div[@type eq 'summary'][@xml:lang = $valid-lang]/*[self::tei:p | self::tei:milestone | self::tei:lg ]/.
        }
        </summary>
};

declare function translation:acknowledgment($tei as element(tei:TEI)) as element() {
    <acknowledgment xmlns="http://read.84000.co/ns/1.0" prefix="ac">
    { 
        $tei//tei:front//tei:div[@type='acknowledgment']/*[self::tei:p | self::tei:milestone | self::tei:lg ]/.
    }
    </acknowledgment>
};

declare function translation:preface($tei as element(tei:TEI)) as element()* {
    <preface xmlns="http://read.84000.co/ns/1.0" prefix="pf">
    { 
        translation:nested-section($tei//tei:front/tei:div[@type eq 'preface'], 0, 'pf')
    }
    </preface>
};

declare function translation:nested-section($section as element()?, $nesting as xs:integer, $parent-id) as element()* {
    if($section) then
    (
        (: Add direct children :)
        $section/*[
            self::tei:head
            | self::tei:p
            | self::tei:milestone
            | self::tei:ab
            | self::tei:lg
            | self::tei:lb
            | self::tei:q
            | self::tei:list
            | self::tei:trailer
            | self::tei:label
            | self::tei:seg
            | self::tei:table
        ],
        (: Add subsections :)
        for $sub-section at $position in $section/tei:div[@type = ('section', 'chapter')]
            let $section-id := concat($parent-id, '-', $position)
        return
            element tei:div {
                attribute type { $sub-section/@type },
                attribute nesting { $nesting },
                attribute section-id { $section-id },
                translation:nested-section($sub-section, $nesting + 1, $section-id)
            }
    )
    else 
        ()
};

declare function translation:introduction($tei as element(tei:TEI)) as element() {
    <introduction xmlns="http://read.84000.co/ns/1.0" prefix="i">
    {
        translation:nested-section($tei//tei:front/tei:div[@type eq 'introduction'], 0, 'i')
    }
    </introduction>
};

declare function translation:prologue($tei as element(tei:TEI)) as element() {
    <prologue xmlns="http://read.84000.co/ns/1.0" prefix="pl">
    { 
        translation:nested-section($tei//tei:body/tei:div[@type eq 'translation']/tei:div[@type eq 'prologue'], 0, 'p')
    }
    </prologue>
};

declare function translation:body($tei as element(tei:TEI)) as element() {
    <body xmlns="http://read.84000.co/ns/1.0" prefix="tr">
        <honoration>{ data($tei//tei:body/tei:div[@type eq 'translation']/tei:head[@type eq 'titleHon']) }</honoration>
        <main-title>{ data($tei//tei:body/tei:div[@type eq 'translation']/tei:head[@type eq 'titleMain']) }</main-title>
        { 
            for $chapter at $chapter-index in $tei//tei:body//tei:div[@type eq 'translation']/tei:div[@type = ('section', 'chapter')]
            return
                <chapter chapter-index="{ $chapter-index }" prefix="{ $chapter-index }">
                    <title>
                    {
                        attribute tid { $chapter/tei:head[@type = ('chapterTitle', 'section')]/@tid }
                    }
                    { 
                        $chapter/tei:head[@type = ('chapterTitle', 'section')]/text() 
                    }
                    </title>
                    <title-number>
                    {
                        attribute tid { $chapter/tei:head[@type eq 'chapter']/@tid }
                    }
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
                        (: parse chapter nesting but exclude <head>s in the root as we've already processed them :)
                        translation:nested-section(
                            <div xmlns="http://www.tei-c.org/ns/1.0">
                            {
                                $chapter/@*, 
                                $chapter/*[not(self::tei:head)] 
                            }
                            </div>,
                            0,
                            $chapter-index
                        )
                    }
                </chapter>
        }
    </body>
};

declare function translation:colophon($tei as element(tei:TEI)) as element() {
    <colophon xmlns="http://read.84000.co/ns/1.0" prefix="c">
    { 
        translation:nested-section($tei//tei:body/tei:div[@type eq 'translation']/tei:div[@type eq 'colophon'], 0, 'c')
    }
    </colophon>
};

declare function translation:appendix($tei as element(tei:TEI)) as element() {
    <appendix xmlns="http://read.84000.co/ns/1.0" prefix="ap">
    { 
        let $count-prologue := count($tei//tei:back//*[@type eq 'appendix']/*[@type eq 'prologue'])
            
        for $chapter at $chapter-index in $tei//tei:back//*[@type eq 'appendix']/*[@type = ('section', 'chapter', 'prologue')]
            let $chapter-number := xs:string($chapter-index - $count-prologue)
            let $chapter-class := 
                if($chapter/@type eq 'prologue')then
                    'p'
                else
                    $chapter-number
        return
            <chapter chapter-index="{ $chapter-class }" prefix="{ concat('ap', $chapter-class) }">
                <title>
                {
                    attribute tid { $chapter/tei:head/@tid }
                }
                { 
                    $chapter/tei:head[@type = ('section', 'chapter', 'prologue')]/text()
                }
                </title>
                {
                    translation:nested-section(
                        <div xmlns="http://www.tei-c.org/ns/1.0">
                        {
                            $chapter/@*, 
                            $chapter/*[not(self::tei:head)] 
                        }
                        </div>,
                        0,
                        concat('ap', $chapter-class)
                    )
                }
            </chapter>
    }
    </appendix>
};

declare function translation:abbreviations($tei as element(tei:TEI)) as element() {
    <abbreviations xmlns="http://read.84000.co/ns/1.0" prefix="ab">
    {
        for $section in $tei//tei:back/tei:div[@type eq 'notes']/tei:*
        return
            translation:abbreviation-section($section)
    }
    </abbreviations>
};

declare function translation:abbreviation-section($section as element()) as element()? {
    
    if(local-name($section) eq 'div') then
        element { QName('http://read.84000.co/ns/1.0', 'section') } {
            for $head in $section/tei:head
            return
                element title {
                    $head/node()
                }
            ,
            for $sub-section in ($section/tei:div | $section/tei:list)
            return
                translation:abbreviation-section($sub-section)
        }
    else if(local-name($section) eq 'list') then
        element { QName('http://read.84000.co/ns/1.0', 'list') } {
            for $head in $section/tei:head[@type eq 'abbreviations']
            return
                element head {
                    $head/node()
                }
            ,
            for $description in $section/tei:head[@type eq 'description']
            return
                element description {
                    $description/node()
                }
            ,
            for $item in $section/tei:item[tei:abbr]
            return
                element item {
                    element abbreviation { $item/tei:abbr/node() },
                    element explanation { $item/tei:expan/node() }
                }
            ,
            for $footer in $section/tei:item[not(tei:abbr)]
            return
                element foot { 
                    $footer/node()
                }
        }
     else
        ()
};

declare function translation:notes($tei as element(tei:TEI)) as element() {
    <notes xmlns="http://read.84000.co/ns/1.0" prefix="n">
    {
        for $note in $tei//tei:text//tei:note[@place eq 'end']
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

declare function translation:bibliography-section($section as element()) as element() {
    <section xmlns="http://read.84000.co/ns/1.0">
        {
            if($section/tei:head[@type='section']/text())then
                <title>{ $section/tei:head[@type eq 'section']/text() }</title>
            else
                ()
        }
        {
            for $item in $section/tei:bibl
            return
                <item id="{ $item/@xml:id }">{ $item/node() }</item>
        }
        {
            for $sub-section in $section/tei:div[@type eq 'section']
            return
                translation:bibliography-section($sub-section)
        }
    </section>
};

declare function translation:bibliography($tei as element(tei:TEI)) as element() {
    <bibliography xmlns="http://read.84000.co/ns/1.0" prefix="b">
    {
        for $section in $tei//tei:back/*[@type eq 'listBibl']/*[@type eq 'section']
        return
            translation:bibliography-section($section)
    }
    </bibliography>
};

declare function translation:glossary($tei as element(tei:TEI)) as element() {
    <glossary xmlns="http://read.84000.co/ns/1.0" prefix="g">
    {
        for $gloss in $tei//tei:back//tei:div[@type eq 'glossary']//tei:gloss
            let $main-term := $gloss/tei:term[not(@xml:lang) or @xml:lang eq 'en'][not(@type)][1]/text()
        where $main-term
        return
            <item 
                uid="{ $gloss/@xml:id/string() }" 
                type="{ $gloss/@type/string() }" 
                mode="{ $gloss/@mode/string() }">
                <term xml:lang="en">{ functx:capitalize-first(normalize-space($main-term)) }</term>
                {
                    for $item in $gloss/tei:term[(@xml:lang and not(@xml:lang eq 'en')) or @type](:[not(text() eq $main-term)]:)
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
                        else
                            <term xml:lang="{ if($item/@xml:lang) then lower-case($item/@xml:lang) else 'en' }">
                            {
                                if (not($item/text())) then
                                    common:local-text(concat('glossary.term-empty-', lower-case($item/@xml:lang)), 'en')
                                else if ($item/@xml:lang eq 'Bo-Ltn') then 
                                    common:bo-ltn($item/text())
                                else 
                                    $item/text() 
                            }
                            </term>
                 }
                 <sort-term>{ common:alphanumeric(common:normalized-chars($main-term)) }</sort-term>
            </item>
    }
    </glossary>
};

declare function translation:word-count($tei as element(tei:TEI)) as xs:integer {
    let $translated-text := 
        $tei//tei:text/tei:body/tei:div[@type eq "translation"]/*[
               self::tei:div[@type = ("section", "chapter", "prologue", "colophon")] 
               or self::tei:head[@type ne 'translation']
           ]//text()[normalize-space() and not(ancestor::tei:note)]
    return
        if($translated-text and not($translated-text = '')) then
            common:word-count($translated-text)
        else
            0
};

declare function translation:glossary-count($tei as element(tei:TEI)) as xs:integer {
    count($tei//*[@type='glossary']//tei:item)
};

declare function translation:title-listing($translation-title as xs:string*) as xs:string* {
    let $first-word := substring-before($translation-title, ' ')
    return
        if(lower-case($first-word) = ('the')) then
            concat(substring-after($translation-title, concat($first-word, ' ')), ', ', $first-word)
        else
            $translation-title
};

declare function translation:start-volume($tei as element(tei:TEI), $resource-id as xs:string) as xs:integer {
    tei-content:source-bibl($tei, $resource-id)/tei:location/tei:volume[1]/@number/xs:integer(.)
};

declare function translation:count-volume-pages($location as element(m:location)) as xs:integer {
    sum($location/m:volume ! (xs:integer(@end-page) - (xs:integer(@start-page) - 1)))
};

declare function translation:folio-refs($tei as element(tei:TEI), $resource-id as xs:string){
    let $toh-key := translation:toh-key($tei, $resource-id)
    return
        $tei//tei:body//tei:ref[@type eq 'folio'][not(@rend) or not(@rend eq 'hidden')][not(@key) or @key eq $toh-key][not(ancestor::tei:note)]
};

declare function translation:folios($tei as element(tei:TEI), $resource-id as xs:string) as element() {
    
    let $location := translation:location($tei, $resource-id)
    let $work := $location/@work
    let $reading-room-path := $common:environment/m:url[@id eq 'reading-room']/text()
    let $folio-refs := translation:folio-refs($tei, $resource-id)
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'folios') } {
            attribute toh-key { $location/@key },
            attribute count-pages { translation:count-volume-pages($location) },
            attribute count-refs { count($folio-refs) },
            for $volume in $location/m:volume
                let $volume-number := xs:integer($volume/@number)
                let $preceding-volumes := $location/m:volume[xs:integer(@number) lt $volume-number]
                let $pages-in-preceding-volumes := sum($preceding-volumes ! (xs:integer(@end-page) - (xs:integer(@start-page) - 1)))
                let $count-title-pages := count($preceding-volumes) + 1
                let $count-trailing-pages := count($preceding-volumes[xs:integer(@end-page) mod 2 ne 0])
                
                let $etext-volume-number := source:etext-volume-number($work, $volume-number)
                let $etext-id := source:etext-id($work, $etext-volume-number)
                let $etext-volume := source:etext-volume($etext-id)
                
            return
                for $page-in-volume at $page-index in xs:integer($volume/@start-page) to xs:integer($volume/@end-page)
                    let $page-in-text := $pages-in-preceding-volumes + $page-index
                    let $tei-folio := $folio-refs[$page-in-text]/@cRef
                    let $folio-in-volume := concat('F.', source:page-to-folio($page-in-volume))
                    let $folio-consecutive := concat('F.', source:page-to-folio($page-in-text + $count-title-pages + $count-trailing-pages))
                return
                    element folio {
                        attribute volume { $volume-number },
                        attribute page-in-volume { $page-in-volume },
                        attribute page-in-text { $page-in-text },
                        attribute tei-folio { $tei-folio },
                        attribute folio-in-volume { $folio-in-volume },
                        attribute folio-consecutive { $folio-consecutive },
                        element url {
                            attribute format { 'xml' },
                            attribute xml:lang { 'bo' },
                            text { concat($reading-room-path,'/source/', $location/@key, '.xml?page=', $page-in-text) }
                        },
                        element url {
                            attribute format { 'html' },
                            attribute xml:lang { 'bo' },
                            text { concat($reading-room-path,'/source/', $location/@key, '.html?page=', $page-in-text) }
                        },
                        element url {
                            attribute format { 'xml' },
                            attribute xml:lang { 'en' },
                            text { concat($reading-room-path,'/translation/', $location/@key, '.xml?page=', $page-in-text) }
                        }
                   }
            }
};

declare function translation:folio-content($tei as element(tei:TEI), $resource-id as xs:string, $page as xs:integer) as element()* {
    
    (: Get all the <ref/>s in the doc :)
    let $refs := translation:folio-refs($tei, $resource-id)
    (: Locate the <ref/> we are interested in :)
    let $start-ref := $refs[$page]
    (: Locate the next <ref/> after that :)
    let $end-ref := $refs[$page + 1]
    (: Get all sections that may have a <ref/>. They must be siblings so get direct children of section. :)
    let $translation-paragraphs := $tei//tei:body//tei:div[@type='translation']//tei:div[@type = ('prologue', 'section', 'chapter')]/*[self::tei:head | self::tei:p | self::tei:ab | self::tei:q | self::tei:lg | self::tei:list| self::tei:table | self::tei:trailer]
    
    (: Find the container of the start <ref/> and it's index :)
    let $start-ref-paragraph := $start-ref/ancestor::*[. = $translation-paragraphs]
    let $start-ref-paragraph-index := 
        if($start-ref-paragraph) then
            functx:index-of-node($translation-paragraphs, $start-ref-paragraph)
        else
            0
    
    (: Find the container of the end <ref/> and it's index :)
    let $end-ref-paragraph :=  if($end-ref) then $end-ref/ancestor::*[. = $translation-paragraphs] else $translation-paragraphs[last()]
    let $end-ref-paragraph-index := functx:index-of-node($translation-paragraphs, $end-ref-paragraph)
    (: Get paragraphs including and between these 2 points :)
    let $folio-paragraphs := 
        if($start-ref-paragraph) then
            $translation-paragraphs[position() ge $start-ref-paragraph-index and position() le $end-ref-paragraph-index]
        else
            ()
    
    (: Convert the content to text and <ref/>s only :)
    let $folio-content-spaced := 
        for $node in $folio-paragraphs//text()[not(ancestor::tei:note)] | $folio-paragraphs//tei:ref[@cRef = $refs/@cRef]
        return
            (: Catch instances where the string ends in a punctuation mark. Assume a space has been dropped. Add a space to concat to the next string. :)
            if($node[not(self::tei:ref)] and substring($node, string-length($node), 1) = ('.',',','!','?','”',':',';')) then
                concat($node, ' ')
            else if($node[not(self::tei:ref)] and $node[parent::tei:head]) then
                concat($node, '. ')
            else
                $node
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'folio-content') } {
            attribute start-ref { $start-ref/@cRef },
            attribute end-ref { $end-ref/@cRef },
            $folio-content-spaced
        }
};

declare function translation:source-link-id($page as xs:integer){
    concat('source-link-', $page)
};

declare function translation:sponsors($tei as element(tei:TEI), $include-acknowledgements as xs:boolean) as element() {
    
    let $translation-sponsors := $tei//tei:titleStmt/tei:sponsor
    
    let $sponsor-ids := $translation-sponsors ! substring-after(./@ref, 'sponsors.xml#')
    
    let $sponsors := sponsors:sponsors($sponsor-ids, false(), false())
    
    let $acknowledgment := $tei//tei:front/tei:div[@type eq "acknowledgment"]
    
    return
        <sponsors xmlns="http://read.84000.co/ns/1.0">
        {(
            $sponsors/m:sponsor,
            if($include-acknowledgements) then
            
                (: Use the label from the entities file unless it's specified in the tei :)
                let $sponsor-strings := 
                    for $translation-sponsor in $translation-sponsors
                        let $translation-sponsor-text := $translation-sponsor
                        let $translation-sponsor-id := substring-after($translation-sponsor/@ref, 'sponsors.xml#')
                        let $sponsor-label-text := $sponsors/m:sponsor[@xml:id eq $translation-sponsor-id]/m:label
                    return
                        if($translation-sponsor-text gt '') then
                            $translation-sponsor-text
                        else if($sponsor-label-text gt '') then
                            $sponsor-label-text
                        else
                            ()
                
                let $count-sponsor-strings := count($sponsor-strings)
                
                let $marked-paragraphs := 
                    if($acknowledgment/tei:p and $sponsor-strings) then
                        let $mark-sponsor-strings := $sponsor-strings ! normalize-space(lower-case(replace(., $sponsors:prefixes, '')))
                        return
                            common:mark-nodes($acknowledgment/tei:p, $mark-sponsor-strings)
                    else
                        ()
                
                return
                    element tei:div {
                        attribute type { 'acknowledgment' },
                        if($marked-paragraphs/exist:match) then
                            $marked-paragraphs[exist:match]
                        else if($sponsor-strings) then
                            (
                                attribute generated { true() },
                                element tei:p {
                                    text { 'Sponsored by ' },
                                        for $sponsor-string at $position  in $sponsor-strings
                                        return
                                        (
                                            element exist:match {
                                                text { $sponsor-string }
                                            },
                                            text { if($position eq $count-sponsor-strings) then  '.' else ', ' }
                                        )
                                }
                            )
                        else
                            ()
                    }
             else
                ()
        )}
        </sponsors>
};

declare function translation:contributors($tei as element(tei:TEI), $include-acknowledgements as xs:boolean) as element() {
    
    let $translation-contributors := $tei//tei:titleStmt/tei:*[self::tei:author | self::tei:editor | self::tei:consultant]
    
    let $contributor-ids := $translation-contributors ! substring-after(./@ref, 'contributors.xml#')
    
    let $contributors := $contributors:contributors/m:contributors/m:person[@xml:id = $contributor-ids]
    
    let $acknowledgment := $tei//tei:front/tei:div[@type eq "acknowledgment"]
    
    return
        <contributors xmlns="http://read.84000.co/ns/1.0" >
        {(
            $contributors,
            if($include-acknowledgements) then
                
                (: Use the label from the entities file unless it's specified in the tei :)
                let $contributor-strings := 
                    for $translation-contributor in $translation-contributors
                        let $contributor := $contributors[@xml:id eq substring-after($translation-contributor/@ref, 'contributors.xml#')]
                    return 
                        if($translation-contributor/text()) then
                            $translation-contributor
                        else
                            $contributor/m:label
                
                let $marked-paragraphs := 
                    if($acknowledgment/tei:p and $contributor-strings) then
                        let $mark-contributor-strings := $contributor-strings ! normalize-space(lower-case(replace(., $contributors:person-prefixes, '')))
                        return
                            common:mark-nodes($acknowledgment/tei:p, $mark-contributor-strings)
                    else
                        ()
                
                return
                    element tei:div {
                        attribute type { 'acknowledgment' },
                       $marked-paragraphs[exist:match]
                    }
               
            else
                ()
        )}
        </contributors>
};
