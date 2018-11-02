xquery version "3.1";

module namespace translation="http://read.84000.co/translation";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace functx="http://www.functx.com";
import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace sponsors="http://read.84000.co/sponsors" at "sponsors.xql";
import module namespace translators="http://read.84000.co/translators" at "translators.xql";
import module namespace download="http://read.84000.co/download" at "download.xql";

declare function translation:titles($tei as node()) as node()* {
    <titles xmlns="http://read.84000.co/ns/1.0">
    {
        tei-content:title-set($tei, 'mainTitle')
    }
    </titles>
};

declare function translation:long-titles($tei as node()) as node()* {
    <long-titles xmlns="http://read.84000.co/ns/1.0">
    {
        tei-content:title-set($tei, 'longTitle')
    }
    </long-titles>
};

declare function translation:title-variants($tei as node()) as node()* {
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

declare function translation:translation($tei as node()) as node()* {
    <translation xmlns="http://read.84000.co/ns/1.0" sponsored="{ $tei//tei:titleStmt/@sponsored }">
        <authors>
            {
                for $author in $tei//tei:titleStmt/tei:author
                return 
                    element {
                        if($author/@role eq 'translatorMain') then
                            'summary'
                        else
                            'author'
                    }
                    {
                        $author/@sameAs,
                        $author/node()
                    }
            }
        </authors>
        <editors>
        {
            for $editor in $tei//tei:titleStmt/tei:editor
            return 
                <editor>{ normalize-space($editor/text()) }</editor>
        }
        </editors>
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
        <location xmlns="http://read.84000.co/ns/1.0" key="{ $bibl/@key }" count-pages="{$bibl/tei:location/@count-pages}">
            <start volume="{ $bibl/tei:location/tei:start/@volume }" page="{ $bibl/tei:location/tei:start/@page }"/>
            <end volume="{ $bibl/tei:location/tei:end/@volume }" page="{ $bibl/tei:location/tei:end/@page }"/>
        </location>
};

declare function translation:filename($tei as node(), $resource-id as xs:string) as xs:string {

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

declare function translation:version-str($tei as node()) as xs:string {
    let $edition := data($tei//tei:editionStmt/tei:edition[1])
    return
        replace(normalize-space(replace($edition, '[^a-z0-9\s\.]', ' ')), '\s', '-')
};

declare function translation:downloads($tei as node(), $resource-id as xs:string, $include as xs:string) as node()* {
    
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
                    or ($include eq 'any-version' and $stored-version gt '0')                           (: return if there is any version :)
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

declare function translation:summary($tei as node()) as node()* {
    <summary xmlns="http://read.84000.co/ns/1.0" prefix="s">
    { 
        $tei//tei:front//tei:div[@type eq 'summary']/*[self::tei:p | self::tei:milestone | self::tei:lg ]/.
    }
    </summary>
};

declare function translation:acknowledgment($tei as node()) as node()* {
    <acknowledgment xmlns="http://read.84000.co/ns/1.0" prefix="ac">
    { 
        $tei//tei:front//tei:div[@type='acknowledgment']/*[self::tei:p | self::tei:milestone | self::tei:lg ]/.
    }
    </acknowledgment>
};

declare function translation:preface($tei as node()) as node()* {
    <preface xmlns="http://read.84000.co/ns/1.0" prefix="pf">
    { 
        translation:nested-section($tei//tei:front/tei:div[@type eq 'preface'], 0, 'pf')
    }
    </preface>
};

declare function translation:nested-section($section as node()*, $nesting as xs:integer, $parent-id) as node()* {
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
            <div xmlns="http://www.tei-c.org/ns/1.0">
            { attribute type { $sub-section/@type } }
            { attribute nesting { $nesting } }
            { attribute section-id { $section-id } }
            {
                translation:nested-section($sub-section, $nesting + 1, $section-id)
            }
            </div>
    )
    else 
        ()
};

declare function translation:introduction($tei as node()) as node()* {
    <introduction xmlns="http://read.84000.co/ns/1.0" prefix="i">
    {
        translation:nested-section($tei//tei:front/tei:div[@type eq 'introduction'], 0, 'i')
    }
    </introduction>
};

declare function translation:prologue($tei as node()) as node()* {
    <prologue xmlns="http://read.84000.co/ns/1.0" prefix="p">
    { 
        translation:nested-section($tei//tei:body/tei:div[@type eq 'translation']/tei:div[@type eq 'prologue'], 0, 'p')
    }
    </prologue>
};

declare function translation:body($tei as node()) as node()* {
    <body xmlns="http://read.84000.co/ns/1.0" prefix="tr">
        <honoration>{ data($tei//tei:body/tei:div[@type eq 'translation']/tei:head[@type eq 'titleHon']) }</honoration>
        <main-title>{ data($tei//tei:body/tei:div[@type eq 'translation']/tei:head[@type eq 'titleMain']) }</main-title>
        { 
            for $chapter at $chapter-index in $tei//tei:body//tei:div[@type eq 'translation']/tei:div[@type = ('section', 'chapter')]
            return
                <chapter chapter-index="{ $chapter-index }" prefix="{ $chapter-index }">
                    <title>
                    {
                        attribute tid { $chapter/tei:head/@tid }
                    }
                    { 
                        $chapter/tei:head[@type = ('chapterTitle', 'section')]/text() 
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

declare function translation:colophon($tei as node()) as node()* {
    <colophon xmlns="http://read.84000.co/ns/1.0" prefix="c">
    { 
        translation:nested-section($tei//tei:body/tei:div[@type eq 'translation']/tei:div[@type eq 'colophon'], 0, 'c')
    }
    </colophon>
};

declare function translation:appendix($tei as node()) as node()* {
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
                        $chapter-number
                    )
                }
            </chapter>
    }
    </appendix>
};

declare function translation:abbreviations($tei as node()) as node()* {
    <abbreviations xmlns="http://read.84000.co/ns/1.0" prefix="ab">
    {
        if($tei//tei:list[@type='abbreviations']/tei:head/text())then
            <head>{$tei//tei:list[@type='abbreviations']/tei:head/text()}</head>
        else
            ()
    }
    {
        for $item in $tei//tei:list[@type='abbreviations']/tei:item[tei:abbr]
        return
            <item>
                <abbreviation>{ normalize-space($item/tei:abbr/text()) }</abbreviation>
                <explanation>{ $item/tei:expan/node() }</explanation>
            </item>
    }
    {
        if($tei//tei:list[@type='abbreviations']/tei:item[not(tei:abbr)]/text())then
            <foot>{ $tei//tei:list[@type='abbreviations']/tei:item[not(tei:abbr)]/text() }</foot>
        else
            ()
    }
    </abbreviations>
};

declare function translation:notes($tei as node()) as node()* {
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

declare function translation:bibliography-section($section as node()) as node()* {
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

declare function translation:bibliography($tei as node()) as node()* {
    <bibliography xmlns="http://read.84000.co/ns/1.0" prefix="b">
    {
        for $section in $tei//tei:back/*[@type eq 'listBibl']/*[@type eq 'section']
        return
            translation:bibliography-section($section)
    }
    </bibliography>
};

declare function translation:glossary($tei as node()) as node()* {
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

declare function translation:word-count($tei as node()) as xs:integer {
    let $translated-text := 
        $tei//tei:text/tei:body/tei:div[@type eq "translation"]/*[
            self::tei:div[@type = ("section", "chapter", "colophon")] 
            or self::tei:head[@type ne 'translation']
        ]//text()[not(ancestor::tei:note)]
    return
        common:word-count($translated-text)
};

declare function translation:glossary-count($tei as node()) as xs:integer {
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

declare function translation:folios($tei as node(), $resource-id as xs:string) as node() {
    
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

declare function translation:volume($tei as node(), $resource-id as xs:string) as xs:integer {
    let $bibl := tei-content:source-bibl($tei, $resource-id)
    return
        xs:integer($bibl/tei:location/tei:start/@volume)
};

declare function translation:folio-content($tei as node(), $folio as xs:string, $resource-id as xs:string) as node() {
    
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

declare function translation:sponsors($tei as node(), $include-acknowledgements as xs:boolean) as node() {
    
    let $sponsors := 
        for $translation-sponsor in $tei//tei:titleStmt/tei:sponsor
        return 
            $sponsors:sponsors/m:sponsors/m:sponsor[@xml:id eq substring-after($translation-sponsor/@sameAs, 'sponsors.xml#')]
    
    let $acknowledgment := $tei//tei:front/tei:div[@type eq "acknowledgment"]
    
    return
        <sponsors xmlns="http://read.84000.co/ns/1.0" >
        {(
            $sponsors,
            if($include-acknowledgements and $acknowledgment/tei:p) then
                let $query-options := 
                    <options>
                        <default-operator>and</default-operator>
                        <phrase-slop>0</phrase-slop>
                        <leading-wildcard>no</leading-wildcard>
                    </options>
                return
                    let $query := 
                        <query>
                        {
                            for $sponsor in $sponsors
                                let $translation-sponsor := $tei//tei:titleStmt/tei:sponsor[substring-after(@sameAs, 'sponsors.xml#') eq $sponsor/@xml:id]
                                let $sponsor-name := 
                                    if($translation-sponsor/text() gt '') then
                                        $translation-sponsor/text()
                                    else
                                        $sponsor/m:name/text()
                            return
                                <phrase occur="should">{ lower-case($sponsor-name) }</phrase>
                        }
                        </query>
                    
                    let $query-result := $acknowledgment/tei:p[ft:query(., $query, $query-options)]
                    let $expanded := 
                        if($query-result) then
                            util:expand($query-result, "expand-xincludes=no")
                        else
                            $acknowledgment/tei:p
                    
                    return
                        element tei:div {
                            attribute type { "acknowledgment" },
                            $expanded
                        }
            else
                ()
        )}
        </sponsors>
};


declare function translation:translators($tei as node(), $include-acknowledgements as xs:boolean) as node() {
    
    let $translators := 
        for $translation-translators in $tei//tei:titleStmt/tei:author
        return 
            $translators:translators/m:translators/m:translator[@xml:id eq substring-after($translation-translators/@sameAs, 'translators.xml#')]
    return
        <translators xmlns="http://read.84000.co/ns/1.0" >
        {(
            $translators,
            if($include-acknowledgements) then
                let $query-options := 
                    <options>
                        <default-operator>and</default-operator>
                        <phrase-slop>0</phrase-slop>
                        <leading-wildcard>no</leading-wildcard>
                    </options>
                return
                    let $query := 
                        <query>
                        {
                            for $translator in $translators
                                let $translation-translator := $tei//tei:titleStmt/tei:author[substring-after(@sameAs, 'translators.xml#') eq $translator/@xml:id]
                                let $translator-name := 
                                    if($translation-translator/text() gt '') then
                                        $translation-translator/text()
                                    else
                                        $translator/m:name/text()
                            return
                                <phrase>{ lower-case($translator-name) }</phrase>
                        }
                        </query>
                    let $query-result := $tei//tei:front/tei:div[@type eq "acknowledgment"]/tei:p[ft:query(., $query, $query-options)]
                    let $expanded := 
                        if($query-result) then
                            util:expand($query-result, "expand-xincludes=no")
                        else
                            $tei//tei:front/tei:div[@type eq "acknowledgment"]/tei:p
                        
                    return
                    (
                        $query,
                        element tei:div {
                            $tei//tei:front/tei:div[@type eq "acknowledgment"]/@*,
                            $expanded
                        }
                    )
            else
                ()
        )}
        </translators>
};

declare function translation:update($tei as node(), $request-parameters as xs:string*) {

    for $request-parameter in $request-parameters
        
        (: Get the new value :)
        let $new-value := 
        
            (: Title node :)
            if($request-parameter eq 'title-zh') then
                <title xmlns="http://www.tei-c.org/ns/1.0" type='otherTitle' xml:lang='zh'>{ 
                    request:get-parameter('title-zh', '') 
                }</title>
            
            (: Location :)
            else if(starts-with($request-parameter, 'location-')) then
                let $toh-key := substring-after($request-parameter, 'location-')
                return
                    <location xmlns="http://www.tei-c.org/ns/1.0" count-pages="{ request:get-parameter(concat('count-pages-', $toh-key), '0') }">
                        <start volume="{ request:get-parameter(concat('start-volume-', $toh-key), '0') }" page="{ request:get-parameter(concat('start-page-', $toh-key), '0') }"/>
                        <end volume="{ request:get-parameter(concat('end-volume-', $toh-key), '0') }" page="{ request:get-parameter(concat('end-page-', $toh-key), '0') }"/>
                    </location>
            
            (: Translator summary node may or may not exist :)
            else if($request-parameter eq 'translator-team-id') then
                if($tei//tei:fileDesc/tei:titleStmt/tei:author[@role eq 'translatorMain'][1]) then
                    functx:add-or-update-attributes(
                        $tei//tei:fileDesc/tei:titleStmt/tei:author[@role eq 'translatorMain'][1], 
                        xs:QName('sameAs'), 
                        request:get-parameter('translator-team-id', '')
                    )
                 else
                    <author xmlns="http://www.tei-c.org/ns/1.0" role="translatorMain" sameAs="{ request:get-parameter('translator-team-id', '') }"/>
            
            (: Sponsor node :)
            else if(starts-with($request-parameter, 'sponsor-id-') and ($request-parameter ne 'sponsor-id-0' or request:get-parameter('sponsor-id-0', '') gt '')) then
                let $sponsor-index := substring-after($request-parameter, 'sponsor-id-')
                let $sponsor-id := request:get-parameter(concat('sponsor-id-', $sponsor-index), '')
                return
                    if($sponsor-id) then
                        <sponsor xmlns="http://www.tei-c.org/ns/1.0" sameAs="{ $sponsor-id }">{
                            request:get-parameter(concat('sponsor-expression-', $sponsor-index), '')
                        }</sponsor>
                    else
                        ()
            
            (: Author node :)
            else if(starts-with($request-parameter, 'translator-id-') and ($request-parameter ne 'translator-id-0' or request:get-parameter('translator-id-0', '') gt '')) then
                let $translator-index := substring-after($request-parameter, 'translator-id-')
                let $translator-id := request:get-parameter(concat('translator-id-', $translator-index), '')
                return
                    if($translator-id) then
                        <author xmlns="http://www.tei-c.org/ns/1.0" role="translatorEng" sameAs="{ $translator-id }">{
                            request:get-parameter(concat('translator-expression-', $translator-index), '')
                        }</author>
                    else
                        ()
            
            (: Set to '' if zero :)
            else if($request-parameter = ('translation-status')) then
                if(request:get-parameter('translation-status', '') eq '0') then
                    ''
                else
                    request:get-parameter('translation-status', '')
            
            (: Default to a string value :)
            else
                request:get-parameter($request-parameter, '')
        
        (: Get the context so we can add :)
        let $parent :=
            if($request-parameter eq 'title-zh') then
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
            else if(starts-with($request-parameter, 'translator-id-')) then
                $tei//tei:fileDesc/tei:titleStmt
            else
                ()
        
        (: Get the existing value so we can compare :)
        let $existing-value := 
            if($request-parameter eq 'title-zh') then
                $parent/tei:title[@type='otherTitle'][lower-case(@xml:lang) eq 'zh']
            else if(starts-with($request-parameter, 'location-')) then
                $parent/tei:location
            else if($request-parameter eq 'translation-status') then
                $parent/@status
            else if($request-parameter eq 'sponsorship-status') then
                $parent/@sponsored
            else if(starts-with($request-parameter, 'sponsor-id-')) then
                $parent/tei:sponsor[xs:integer(substring-after($request-parameter, 'sponsor-id-'))]
            else if($request-parameter eq 'translator-team-id') then
                $parent/tei:author[@role eq 'translatorMain'][1]
            else if(starts-with($request-parameter, 'translator-id-')) then
                $parent/tei:author[not(@role eq 'translatorMain')][xs:integer(substring-after($request-parameter, 'translator-id-'))]
            else
                ()
        
        (: Specify a location to add it to if necessary :)
        let $insert-following :=
            if($request-parameter eq 'title-zh') then
                $parent//tei:title[last()]
            else if($request-parameter eq 'translator-team-id') then
                $parent//tei:title[last()]
            else if(starts-with($request-parameter, 'translator-id-')) then
                $parent//tei:author[last()]
            else
                ()
        
        return
            
            common:update($request-parameter, $existing-value, $new-value, $parent, $insert-following) 

};
