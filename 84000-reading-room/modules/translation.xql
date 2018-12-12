xquery version "3.1";

module namespace translation="http://read.84000.co/translation";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace functx="http://www.functx.com";
import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace sponsors="http://read.84000.co/sponsors" at "sponsors.xql";
import module namespace contributors="http://read.84000.co/contributors" at "contributors.xql";
import module namespace download="http://read.84000.co/download" at "download.xql";

declare function translation:titles($tei as element()) as element() {
    <titles xmlns="http://read.84000.co/ns/1.0">
    {
        tei-content:title-set($tei, 'mainTitle')
    }
    </titles>
};

declare function translation:long-titles($tei as element()) as element() {
    <long-titles xmlns="http://read.84000.co/ns/1.0">
    {
        tei-content:title-set($tei, 'longTitle')
    }
    </long-titles>
};

declare function translation:title-variants($tei as element()) as element() {
    <title-variants xmlns="http://read.84000.co/ns/1.0">
    {
        for $title in $tei//tei:titleStmt/tei:title[not(@type eq 'mainTitle')]
        return
            <title xml:lang="{ $title/@xml:lang }">
            {
                $title/text()
            }
            </title>
    }
    </title-variants>
};

declare function translation:translation($tei as element()) as element() {
    <translation xmlns="http://read.84000.co/ns/1.0" sponsored="{ $tei//tei:titleStmt/@sponsored }">
        <contributors>
            {
                for $contributor in $tei//tei:titleStmt/tei:author[@role eq 'translatorMain']
                return 
                    element summary {
                        $contributor/@sameAs,
                        $contributor/node()
                    }
            }
            {
                for $contributor in $tei//tei:titleStmt/tei:author[not(@role eq 'translatorMain')] | $tei//tei:titleStmt/tei:editor | $tei//tei:titleStmt/tei:consultant
                return 
                    element { local-name($contributor) }
                    {
                        $contributor/@role,
                        $contributor/@sameAs,
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
                        $sponsor/@sameAs,
                        normalize-space($sponsor/text())
                    }
                    </sponsor>
            }
        </sponsors>
        <edition>{ $tei//tei:editionStmt/tei:edition[1]/node() }</edition>
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

declare function translation:toh-key($tei as node(), $resource-id as xs:string) as xs:string {
    
    let $bibl := tei-content:source-bibl($tei, $resource-id)
    
    return 
        if($bibl/@key)then
            $bibl/@key 
        else
            ''
};

declare function translation:toh-str($bibl as element()) as xs:string? {
    replace(lower-case($bibl/@key), '^toh', '')
};

declare function translation:toh-full($bibl as element()) as xs:string? {
    normalize-space(string-join($bibl/tei:ref//text(), ' +'))
};

declare function translation:toh($tei as element(), $resource-id as xs:string) as element() {
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

declare function translation:location($tei as element(), $resource-id as xs:string) as element() {
    let $bibl := tei-content:source-bibl($tei, $resource-id)
    return
        <location xmlns="http://read.84000.co/ns/1.0" key="{ $bibl/@key }" count-pages="{$bibl/tei:location/@count-pages}">
            <start volume="{ $bibl/tei:location/tei:start/@volume }" page="{ $bibl/tei:location/tei:start/@page }"/>
            <end volume="{ $bibl/tei:location/tei:end/@volume }" page="{ $bibl/tei:location/tei:end/@page }"/>
        </location>
};

declare function translation:filename($tei as element(), $resource-id as xs:string) as xs:string {

    let $diacritics  := 'āḍḥīḷḹṃṇñṅṛṝṣśṭūṁ'
    let $normalized := 'adhillmnnnrrsstum'
    
    let $toh-key := lower-case(translation:toh-key($tei, $resource-id))
    let $title := 
        replace(
            translate(
                lower-case(
                    tei-content:title($tei)     (: get title :)
                )                                       (: convert to lower case :)
            , $diacritics, $normalized)                 (: remove diacritics :)
        ,'[^a-zA-Z0-9\s]', ' ')                         (: remove non-alphanumeric, except spaces :)
    
    let $file-title := concat($toh-key, '_', '84000', ' ', $title)
    let $filename := replace($file-title, '\s', '-')    (: convert spaces to hyphen :)
    return
        $filename
};

declare function translation:version-str($tei as element()) as xs:string {
    let $edition := data($tei//tei:editionStmt/tei:edition[1])
    return
        replace(normalize-space(replace($edition, '[^a-z0-9\s\.]', ' ')), '\s', '-')
};

declare function translation:downloads($tei as element(), $resource-id as xs:string, $include as xs:string) as element() {
    
    let $file-name := translation:filename($tei, $resource-id)
    let $tei-version := translation:version-str($tei)
    
    return
        <downloads xmlns="http://read.84000.co/ns/1.0" tei-version="{ $tei-version }">
        {
            for $type in ('pdf', 'epub', 'azw3')
                let $stored-version := download:stored-version-str($resource-id, $type)
            return
                if(
                    ($include eq 'all')                                                                 (: return all types :)
                    or ($include eq 'any-version' and not($stored-version eq 'none'))                   (: return if there is any version :)
                    or ($include eq 'latest-version' and compare($stored-version, $tei-version) eq 0)   (: return only if it's the latest version :)
                ) then
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
                else
                    ()
        }
        </downloads>
};

declare function translation:summary($tei as element()) as element() {
    <summary xmlns="http://read.84000.co/ns/1.0" prefix="s">
    { 
        $tei//tei:front//tei:div[@type eq 'summary']/*[self::tei:p | self::tei:milestone | self::tei:lg ]/.
    }
    </summary>
};

declare function translation:acknowledgment($tei as element()) as element() {
    <acknowledgment xmlns="http://read.84000.co/ns/1.0" prefix="ac">
    { 
        $tei//tei:front//tei:div[@type='acknowledgment']/*[self::tei:p | self::tei:milestone | self::tei:lg ]/.
    }
    </acknowledgment>
};

declare function translation:preface($tei as element()) as element()* {
    <preface xmlns="http://read.84000.co/ns/1.0" prefix="pf">
    { 
        translation:nested-section($tei//tei:front/tei:div[@type eq 'preface'], 0, 'pf')
    }
    </preface>
};

declare function translation:nested-section($section as element()?, $nesting as xs:integer, $parent-id) as element()* {
    if($section) then
    (
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
        ],
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

declare function translation:introduction($tei as element()) as element() {
    <introduction xmlns="http://read.84000.co/ns/1.0" prefix="i">
    {
        translation:nested-section($tei//tei:front/tei:div[@type eq 'introduction'], 0, 'i')
    }
    </introduction>
};

declare function translation:prologue($tei as element()) as element() {
    <prologue xmlns="http://read.84000.co/ns/1.0" prefix="pl">
    { 
        translation:nested-section($tei//tei:body/tei:div[@type eq 'translation']/tei:div[@type eq 'prologue'], 0, 'p')
    }
    </prologue>
};

declare function translation:body($tei as element()) as element() {
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

declare function translation:colophon($tei as element()) as element() {
    <colophon xmlns="http://read.84000.co/ns/1.0" prefix="c">
    { 
        translation:nested-section($tei//tei:body/tei:div[@type eq 'translation']/tei:div[@type eq 'colophon'], 0, 'c')
    }
    </colophon>
};

declare function translation:appendix($tei as element()) as element() {
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

declare function translation:abbreviations($tei as element()) as element() {
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

declare function translation:notes($tei as element()) as element() {
    <notes xmlns="http://read.84000.co/ns/1.0" prefix="n">
    {
        for $note in $tei//tei:text//tei:note
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

declare function translation:bibliography($tei as element()) as element() {
    <bibliography xmlns="http://read.84000.co/ns/1.0" prefix="b">
    {
        for $section in $tei//tei:back/*[@type eq 'listBibl']/*[@type eq 'section']
        return
            translation:bibliography-section($section)
    }
    </bibliography>
};

declare function translation:glossary($tei as element()) as element() {
    <glossary xmlns="http://read.84000.co/ns/1.0" prefix="g">
    {
        for $gloss in $tei//tei:back//*[@type eq 'glossary']//tei:gloss
            let $main-term := $gloss/tei:term[not(@xml:lang) or @xml:lang eq 'en'][not(@type)][1]/text()
        return
            if($main-term) then
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
                                        common:app-text(concat('glossary.term-empty-', lower-case($item/@xml:lang)))
                                    else if ($item/@xml:lang eq 'Bo-Ltn') then
                                        common:bo-ltn($item/text())
                                    else
                                        $item/text() 
                                }
                                </term>
                     }
                     <sort-term>{ common:alphanumeric(common:normalized-chars($main-term)) }</sort-term>
                </item>
            else
                ()
    }
    </glossary>
};

declare function translation:word-count($tei as element()) as xs:integer {
    let $translated-text := 
        $tei//tei:text/tei:body/tei:div[@type eq "translation"]/*[
               self::tei:div[@type = ("section", "chapter", "prologue", "colophon")] 
               or self::tei:head[@type ne 'translation']
           ]//text()[count(ancestor::tei:note) eq 0]
    return
        common:word-count($translated-text)
};

declare function translation:glossary-count($tei as element()) as xs:integer {
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

declare function translation:folios($tei as node(), $resource-id as xs:string) as element() {
    
    let $translation-id := tei-content:id($tei)
    let $volume := translation:volume($tei, $resource-id)
    let $toh := translation:toh($tei, $resource-id)
    
    return
        <folios xmlns="http://read.84000.co/ns/1.0" volume="{ $volume }" toh-key="{ $toh/@key }">
        {
            for $folio in $tei//tei:body//*[@type eq 'translation']//tei:ref[not(@type)][not(@key) or @key eq $toh/@key][lower-case(substring(@cRef,1,2)) eq 'f.']
                
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

declare function translation:volume($tei as element(), $resource-id as xs:string) as xs:integer {
    let $bibl := tei-content:source-bibl($tei, $resource-id)
    return
        xs:integer($bibl/tei:location/tei:start/@volume)
};

declare function translation:folio-content($tei as element(), $folio as xs:string, $resource-id as xs:string) as element() {
    
    let $volume := translation:volume($tei, $resource-id)
    let $toh-key := translation:toh-key($tei, $resource-id)
    let $refs := $tei//tei:div[@type='translation']//tei:ref[not(@type)][not(@key) or @key eq $toh-key][@cRef]
    let $start-ref := $refs[lower-case(@cRef) eq lower-case($folio)]
    let $start-ref-index := functx:index-of-node($refs, $start-ref)
    let $end-ref := $refs[$start-ref-index + 1]
    
    (: collect all the nodes that can actually contain strings :)
    let $content := $tei//tei:body//tei:div[@type='translation']//tei:*[text() | tei:ref]
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

declare function translation:sponsors($tei as element(), $include-acknowledgements as xs:boolean) as element() {
    
    let $translation-sponsors := $tei//tei:titleStmt/tei:sponsor
    
    let $sponsor-ids := $translation-sponsors ! substring-after(./@sameAs, 'sponsors.xml#')
    
    let $sponsors := sponsors:sponsors($sponsor-ids, false(), false())
    
    let $acknowledgment := $tei//tei:front/tei:div[@type eq "acknowledgment"]
    
    return
        <sponsors xmlns="http://read.84000.co/ns/1.0" >
        {(
            $sponsors/m:sponsor,
            if($include-acknowledgements) then
                if($acknowledgment/tei:p and $sponsors/m:sponsor) then
                
                    let $sponsor-strings := 
                        for $sponsor in $sponsors/m:sponsor
                            let $translation-sponsor := $translation-sponsors[substring-after(@sameAs, 'sponsors.xml#') eq $sponsor/@xml:id]
                            let $sponsor-name := 
                                if($translation-sponsor/text() gt '') then
                                    $translation-sponsor/text()
                                else
                                    replace($sponsor/m:label, $sponsors:prefixes, '')
                        return
                            normalize-space(lower-case($sponsor-name))
                    
                    return
                        common:marked-section($acknowledgment, $sponsor-strings)
                else
                    $acknowledgment
             else
                ()
        )}
        </sponsors>
};

declare function translation:contributors($tei as element(), $include-acknowledgements as xs:boolean) as element() {
    
    let $translation-contributors := $tei//tei:titleStmt/tei:*[self::tei:author | self::tei:editor | self::tei:consultant]
    
    let $contributor-ids := $translation-contributors ! substring-after(./@sameAs, 'contributors.xml#')
    
    let $contributors := $contributors:contributors/m:contributors/m:person[@xml:id = $contributor-ids]
    
    let $acknowledgment := $tei//tei:front/tei:div[@type eq "acknowledgment"]
    
    return
        <contributors xmlns="http://read.84000.co/ns/1.0" >
        {(
            $contributors,
            if($include-acknowledgements) then
                if($acknowledgment/tei:p and $contributors) then
                    let $contributor-strings := 
                        for $contributor in $contributors
                            let $translation-contributor := $translation-contributors[substring-after(@sameAs, 'contributors.xml#') eq $contributor/@xml:id]
                            let $contributor-name := 
                                if($translation-contributor/text() gt '') then
                                    $translation-contributor/text()
                                else
                                    replace($contributor/m:label, $contributors:person-prefixes, '')
                        return
                            normalize-space(lower-case($contributor-name))
                    return
                        common:marked-section($acknowledgment, $contributor-strings)
                else
                    ()
            else
                ()
        )}
        </contributors>
};

declare function translation:update($tei as element()) as element()* {

    (# exist:batch-transaction #) {
    
        (: The updates have to follow in the correct order e.g. input-1, input-2... :)
        for $request-parameter in common:sort-trailing-number-in-string(request:get-parameter-names(), '-')
            
            (: Get the new value :)
            let $new-value := 
            
                (: Title node :)
                if(starts-with($request-parameter, 'title-text-')) then
                    let $title-index := substring-after($request-parameter, 'title-text-')
                    let $title-type := request:get-parameter(concat('title-type-', $title-index), '')
                    let $title-lang := request:get-parameter(concat('title-lang-', $title-index), '')
                    let $title-text := request:get-parameter(concat('title-text-', $title-index), '')
                    return
                        if($title-text gt '') then
                            element { QName("http://www.tei-c.org/ns/1.0", "title") }{
                                attribute type { $title-type },
                                attribute xml:lang { $title-lang },
                                text { $title-text }
                            }
                        else
                            ()
                
                (: Location :)
                else if(starts-with($request-parameter, 'location-')) then
                    let $toh-key := substring-after($request-parameter, 'location-')
                    return
                        element { QName("http://www.tei-c.org/ns/1.0", "location") }{
                            attribute count-pages { request:get-parameter(concat('count-pages-', $toh-key), '0') },
                            element start {
                                attribute volume { request:get-parameter(concat('start-volume-', $toh-key), '0') },
                                attribute page { request:get-parameter(concat('start-page-', $toh-key), '0') }
                            },
                            element end {
                                attribute volume { request:get-parameter(concat('end-volume-', $toh-key), '0') },
                                attribute page { request:get-parameter(concat('end-page-', $toh-key), '0') }
                            }
                        }
                
                (: Translator summary node may or may not exist :)
                else if($request-parameter eq 'translator-team-id') then
                    if($tei//tei:fileDesc/tei:titleStmt/tei:author[@role eq 'translatorMain'][1]) then
                        functx:add-or-update-attributes(
                            $tei//tei:fileDesc/tei:titleStmt/tei:author[@role eq 'translatorMain'][1], 
                            xs:QName('sameAs'), 
                            request:get-parameter('translator-team-id', '')
                        )
                     else
                        element { QName("http://www.tei-c.org/ns/1.0", "author") }{
                            attribute role { "translatorMain" },
                            attribute sameAs { request:get-parameter('translator-team-id', '') }
                        }
                
                (: Sponsor node :)
                else if(starts-with($request-parameter, 'sponsor-id-')) then
                    let $sponsor-index := substring-after($request-parameter, 'sponsor-id-')
                    let $sponsor-id := request:get-parameter(concat('sponsor-id-', $sponsor-index), '')
                    return
                        if($sponsor-id) then
                            element { QName("http://www.tei-c.org/ns/1.0", "sponsor") }{
                                attribute sameAs { $sponsor-id },
                                text { request:get-parameter(concat('sponsor-expression-', $sponsor-index), '') }
                            }
                        else
                            ()
                
                (: Contributor (author/editor node :)
                else if(starts-with($request-parameter, 'contributor-id-')) then
                    let $contributor-index := substring-after($request-parameter, 'contributor-id-')
                    let $contributor-id := request:get-parameter(concat('contributor-id-', $contributor-index), '')
                    let $contributor-type := request:get-parameter(concat('contributor-type-', $contributor-index), '')
                    let $contributor-type-tokenized := tokenize($contributor-type, '-')
                    let $contributor-node-name := $contributor-type-tokenized[1]
                    let $contributor-role := if(count($contributor-type-tokenized) eq 2) then $contributor-type-tokenized[2] else ''
                    return
                        if($contributor-id and $contributor-node-name and $contributor-role) then
                            element { QName("http://www.tei-c.org/ns/1.0", $contributor-node-name) }{
                                attribute role { $contributor-role },
                                attribute sameAs { $contributor-id },
                                text { request:get-parameter(concat('contributor-expression-', $contributor-index), '') }
                            }
                        else
                            ()
                
                (: Version :)
                else if($request-parameter eq 'text-version') then
                    element { QName("http://www.tei-c.org/ns/1.0", "editionStmt") }{
                        element { QName("http://www.tei-c.org/ns/1.0", "edition") }{
                            text { concat(normalize-space(request:get-parameter('text-version', '')), ' ') },
                            if(request:get-parameter('text-version-date', '')) then
                                element { QName("http://www.tei-c.org/ns/1.0", "date") } {
                                    request:get-parameter('text-version-date', '')
                                }
                            else 
                                ()
                        }
                    }
                
                (: Publication date :)
                else if($request-parameter eq 'publication-date') then
                    element { QName("http://www.tei-c.org/ns/1.0", "date") }{
                        text { request:get-parameter('publication-date', '') }
                    }
                
                (: 
                    Text nodes / attributes can be handled generically
                    - if zero set to '' 
                :)
                else if($request-parameter = ('translation-status')) then
                    if(request:get-parameter($request-parameter, '') eq '0') then
                        ''
                    else
                        request:get-parameter($request-parameter, '')
                
                (: Default to a string value :)
                else if(not(ends-with($request-parameter, '[]'))) then
                    request:get-parameter($request-parameter, '')
                else
                    ()
            
            (: Get the context so we can add :)
            let $parent :=
                if(starts-with($request-parameter, 'title-text-')) then
                    $tei//tei:fileDesc/tei:titleStmt
                else if(starts-with($request-parameter, 'location-')) then
                     $tei//tei:fileDesc/tei:sourceDesc/tei:bibl[@key eq substring-after($request-parameter, 'location-')]
                else if($request-parameter eq 'translation-status') then
                    $tei//tei:fileDesc/tei:publicationStmt
                else if($request-parameter eq 'sponsorship-status') then
                    $tei//tei:fileDesc/tei:titleStmt
                else if(starts-with($request-parameter, 'sponsor-id-')) then
                    $tei//tei:fileDesc/tei:titleStmt
                else if($request-parameter eq 'translator-team-id') then
                    $tei//tei:fileDesc/tei:titleStmt
                else if(starts-with($request-parameter, 'contributor-id-')) then
                    $tei//tei:fileDesc/tei:titleStmt
                else if($request-parameter eq 'publication-date') then
                    $tei//tei:fileDesc/tei:publicationStmt
                else if($request-parameter eq 'text-version') then
                    $tei//tei:fileDesc
                else
                    ()
            
            (: Get the existing value so we can compare :)
            let $existing-value := 
                if(starts-with($request-parameter, 'title-text-')) then
                    common:item-from-index($parent/tei:title, substring-after($request-parameter, 'title-text-'))
                else if(starts-with($request-parameter, 'location-')) then
                    $parent/tei:location
                else if($request-parameter eq 'translation-status') then
                    $parent/@status
                else if($request-parameter eq 'sponsorship-status') then
                    $parent/@sponsored
                else if(starts-with($request-parameter, 'sponsor-id-')) then
                    common:item-from-index($parent/tei:sponsor, substring-after($request-parameter, 'sponsor-id-'))
                else if($request-parameter eq 'translator-team-id') then
                    $parent/tei:author[@role eq 'translatorMain'][1]
                else if(starts-with($request-parameter, 'contributor-id-')) then
                    let $contributors := ($parent/tei:author[not(@role eq 'translatorMain')] | $parent/tei:editor | $parent/tei:consultant)
                    return
                        common:item-from-index($contributors, substring-after($request-parameter, 'contributor-id-'))
                else if($request-parameter eq 'publication-date') then
                    $parent/tei:date
                else if($request-parameter eq 'text-version') then
                    $parent/tei:editionStmt
                else
                    ()
            
            (: Specify a location to add it to if necessary :)
            let $insert-following :=
                if(starts-with($request-parameter, 'title-text-')) then
                    $parent//tei:title[last()]
                else if($request-parameter eq 'translator-team-id') then
                    $parent//tei:title[last()]
                else if(starts-with($request-parameter, 'contributor-id-')) then
                    let $contributors := ($parent/tei:author[not(@role eq 'translatorMain')] | $parent/tei:editor | $parent/tei:consultant)
                    return
                        $contributors[last()]
                else if(starts-with($request-parameter, 'sponsor-id-')) then
                    $parent//tei:sponsor[last()]
                else if($request-parameter eq 'publication-date') then
                    $parent/tei:idno[last()]
                else if($request-parameter eq 'text-version') then
                    $parent/tei:titleStmt
                else
                    ()
            
            return
                if($existing-value or $new-value) then
                    common:update($request-parameter, $existing-value, $new-value, $parent, $insert-following)
                    (:element update-debug {
                        element request-parameter { $request-parameter }, 
                        element existing-value { $existing-value }, 
                        element new-value { $new-value }, 
                        element parent { $parent }, 
                        element insert-following { $insert-following }
                    }:)
                else
                    ()
     }
};
