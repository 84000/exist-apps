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
    <translation xmlns="http://read.84000.co/ns/1.0" sponsored="{ $translation//tei:titleStmt/@sponsored }">
        <authors>
            {
                for $author in $translation//tei:titleStmt/tei:author
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
            for $editor in $translation//tei:titleStmt/tei:editor
            return 
                <editor>{ normalize-space($editor/text()) }</editor>
        }
        </editors>
        <sponsors>
            {
                for $sponsor in $translation//tei:titleStmt/tei:sponsor
                return 
                    <sponsor>
                    {
                        $sponsor/@sameAs,
                        normalize-space($sponsor/text())
                    }
                    </sponsor>
            }
        </sponsors>
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
        <location xmlns="http://read.84000.co/ns/1.0" key="{ $bibl/@key }" count-pages="{$bibl/tei:location/@count-pages}">
            <start volume="{ $bibl/tei:location/tei:start/@volume }" page="{ $bibl/tei:location/tei:start/@page }"/>
            <end volume="{ $bibl/tei:location/tei:end/@volume }" page="{ $bibl/tei:location/tei:end/@page }"/>
        </location>
};

declare function translation:filename($translation as node(), $resource-id as xs:string) as xs:string {

    let $diacritics  := 'āḍḥīḷḹṃṇñṅṛṝṣśṭūṁ'
    let $normalized := 'adhillmnnnrrsstum'
    
    let $toh-key := lower-case(translation:toh-key($translation, $resource-id))
    let $title := 
        replace(
            translate(
                lower-case(
                    tei-content:title($translation)     (: get title :)
                )                                       (: convert to lower case :)
            , $diacritics, $normalized)                 (: remove diacritics :)
        ,'[^a-zA-Z0-9\s]', ' ')                         (: remove non-alphanumeric, except spaces :)
    
    let $file-title := concat($toh-key, '_', '84000', ' ', $title)
    let $filename := replace($file-title, '\s', '-')    (: convert spaces to hyphen :)
    return
        $filename
};

declare function translation:version-str($translation as node()) as xs:string {
    let $edition := data($translation//tei:editionStmt/tei:edition[1])
    return
        replace(normalize-space(replace($edition, '[^a-z0-9\s\.]', ' ')), '\s', '-')
};

declare function translation:downloads($translation as node(), $resource-id as xs:string, $include as xs:string) as node()* {
    
    let $file-name := translation:filename($translation, $resource-id)
    let $tei-version := translation:version-str($translation)
    
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

declare function translation:summary($translation as node()) as node()* {
    <summary xmlns="http://read.84000.co/ns/1.0" prefix="s">
    { 
        $translation//tei:front//tei:div[@type='summary']/*[self::tei:p | self::tei:milestone | self::tei:lg ]/.
    }
    </summary>
};

declare function translation:acknowledgment($translation as node()) as node()* {
    let $acknowledgment := $translation//tei:front//tei:div[@type='acknowledgment']
    return
        <acknowledgment xmlns="http://read.84000.co/ns/1.0" prefix="ac">
        { 
            $acknowledgment/*[self::tei:p | self::tei:milestone | self::tei:lg ]/.
        }
        </acknowledgment>
};

declare function translation:nested-section($section as node()*) as node()* {
    if($section) then
        <nested-section xmlns="http://read.84000.co/ns/1.0">
            {
                $section/*[self::tei:head | self::tei:p | self::tei:milestone | self::tei:ab | self::tei:lg | self::tei:lb | self::tei:q | self::tei:list | self::tei:trailer | self::tei:label ]
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
        translation:nested-section($translation//tei:body/tei:div[@type='translation']/tei:div[@type eq 'prologue'])
    }
    </prologue>
};

declare function translation:body($translation as node()) as node()* {
    <body xmlns="http://read.84000.co/ns/1.0" prefix="tr">
        <honoration>{ data($translation//tei:body/tei:div[@type eq 'translation']/tei:head[@type eq 'titleHon']) }</honoration>
        <main-title>{ data($translation//tei:body/tei:div[@type eq 'translation']/tei:head[@type eq 'titleMain']) }</main-title>
        { 
            for $chapter at $chapter-index in $translation//tei:body//tei:div[@type eq 'translation']/tei:div[@type = ('section', 'chapter')]
            return
                <chapter chapter-index="{ $chapter-index }" prefix="{ $chapter-index }">
                    <title>{ $chapter/tei:head[@type = ('chapterTitle', 'section')]/text() }</title>
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
            count($translation//tei:back//*[@type='appendix']/*[@type = 'prologue'])
            
        for $chapter at $chapter-index in $translation//tei:back//*[@type='appendix']/*[@type=('section', 'chapter', 'prologue')]
            let $chapter-number := xs:string($chapter-index - $count-appendix)
            let $chapter-class := 
                if($chapter/@type eq 'prologue')then
                    'p'
                else
                    $chapter-number
        return
            <chapter chapter-index="{ $chapter-class }" prefix="{ concat('ap', $chapter-class) }">
                <title>{ $chapter/tei:head[@type = ('section', 'chapter', 'prologue')]/text() }</title>
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
        if($translation//tei:list[@type='abbreviations']/tei:head/text())then
            <head>{$translation//tei:list[@type='abbreviations']/tei:head/text()}</head>
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
            <foot>{ $translation//tei:list[@type='abbreviations']/tei:item[not(tei:abbr)]/text() }</foot>
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
                <item id="{ $item/@xml:id }">{ $item/node() }</item>
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
            let $main-term := $gloss/tei:term[not(@xml:lang)][not(@type)][1]/text()
        return
            <item 
                uid="{ $gloss/@xml:id/string() }" 
                type="{ $gloss/@type/string() }" 
                mode="{ $gloss/@mode/string() }">
                <term xml:lang="en">{ functx:capitalize-first(normalize-space($main-term)) }</term>
                {
                    for $item in $gloss/tei:term[not(text() eq $main-term)]
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

declare function translation:sponsors($translation as node(), $include-acknowledgements as xs:boolean) as node() {
    
    let $sponsors := 
        for $translation-sponsor in $translation//tei:titleStmt/tei:sponsor
        return 
            $sponsors:sponsors/m:sponsors/m:sponsor[@xml:id eq substring-after($translation-sponsor/@sameAs, 'sponsors.xml#')]
    
    let $acknowledgment := $translation//tei:front/tei:div[@type eq "acknowledgment"]
    
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
                                let $translation-sponsor := $translation//tei:titleStmt/tei:sponsor[substring-after(@sameAs, 'sponsors.xml#') eq $sponsor/@xml:id]
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


declare function translation:translators($translation as node(), $include-acknowledgements as xs:boolean) as node() {
    
    let $translators := 
        for $translation-translators in $translation//tei:titleStmt/tei:author
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
                                let $translation-translator := $translation//tei:titleStmt/tei:author[substring-after(@sameAs, 'translators.xml#') eq $translator/@xml:id]
                                let $translator-name := 
                                    if($translation-translator/text() gt '') then
                                        $translation-translator/text()
                                    else
                                        $translator/m:name/text()
                            return
                                <phrase>{ lower-case($translator-name) }</phrase>
                        }
                        </query>
                    let $query-result := $translation//tei:front/tei:div[@type eq "acknowledgment"]/tei:p[ft:query(., $query, $query-options)]
                    let $expanded := 
                        if($query-result) then
                            util:expand($query-result, "expand-xincludes=no")
                        else
                            $translation//tei:front/tei:div[@type eq "acknowledgment"]/tei:p
                        
                    return
                    (
                        $query,
                        element tei:div {
                            $translation//tei:front/tei:div[@type eq "acknowledgment"]/@*,
                            $expanded
                        }
                    )
            else
                ()
        )}
        </translators>
};

declare function translation:update($translation as node(), $request-parameters as xs:string*) {

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
                if($translation//tei:fileDesc/tei:titleStmt/tei:author[@role eq 'translatorMain'][1]) then
                    functx:add-or-update-attributes(
                        $translation//tei:fileDesc/tei:titleStmt/tei:author[@role eq 'translatorMain'][1], 
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
                $translation//tei:fileDesc/tei:titleStmt
            else if(starts-with($request-parameter, 'location-')) then
                 $translation//tei:fileDesc/tei:sourceDesc/tei:bibl[@key eq substring-after($request-parameter, 'location-')]
            else if($request-parameter eq 'translation-status') then
                $translation//tei:fileDesc/tei:publicationStmt
            else if($request-parameter eq 'sponsorship-status') then
                $translation//tei:fileDesc/tei:titleStmt
            else if(starts-with($request-parameter, 'sponsor-id-')) then
                $translation//tei:fileDesc/tei:titleStmt
            else if($request-parameter eq 'translator-team-id') then
                $translation//tei:fileDesc/tei:titleStmt
            else if(starts-with($request-parameter, 'translator-id-')) then
                $translation//tei:fileDesc/tei:titleStmt
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

(:
declare function translation:xupdate($translation-id as xs:string, $request-parameters as xs:string*) {
    
    
    let $xpath-translation := concat("//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno/@xml:id eq '", $translation-id, "']")
    let $translations := collection($common:translations-path)
    let $translation := util:eval(concat("$translations" , $xpath-translation))
    
    (: /tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type eq 'longTitle'][last()] :)
    
    let $mods :=
        <xupdate:modifications 
            version="1.0"
            xmlns:xupdate="http://www.xmldb.org/xupdate"
            xmlns:tei="http://www.tei-c.org/ns/1.0">
            {
                for $request-parameter in $request-parameters
                return
                    if($request-parameter eq "title-zh") then
                        let $xpath-node := "/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type eq 'otherTitle'][lower-case(@xml:lang) eq 'zh'][1]"
                        let $current := util:eval(concat("$translation" , $xpath-node))
                        let $new := 
                            <title xmlns="http://www.tei-c.org/ns/1.0" type="otherTitle" xml:lang="zh">
                            { request:get-parameter("title-zh", '') }
                            </title>
                        return
                            if($current and $current ne $new) then
                                translation:xupdate(
                                    $xpath-translation,
                                    $xpath-node,
                                    "",
                                    "",
                                    $new
                                 )
                             else
                                ()
                    else
                        ()
            }
        </xupdate:modifications>
        
     return
        xmldb:update(concat("xmldb:exist://", $common:translations-path), $mods)
};

declare function translation:xupdate($xpath-locate as xs:string, $xpath-update as xs:string, $xpath-remove as xs:string, $xpath-insert-after as xs:string, $insert-node as node()){
    (
        if($xpath-update) then
            <xupdate:update 
                xmlns:xupdate="http://www.xmldb.org/xupdate" 
                select="{concat($xpath-locate, $xpath-update)}">
                { $insert-node }
            </xupdate:update>
        else
            ()
        ,
        if($xpath-remove) then
            <xupdate:remove 
                xmlns:xupdate="http://www.xmldb.org/xupdate" 
                select="{concat($xpath-locate, $xpath-remove)}"/>
        else
            ()
        ,
        if($xpath-insert-after) then
            <xupdate:insert-after 
                xmlns:xupdate="http://www.xmldb.org/xupdate" 
                select="{concat($xpath-locate, $xpath-insert-after)}">
                { $insert-node }
            </xupdate:insert-after>
        else
            ()
    )
};
:)

(:
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