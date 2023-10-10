xquery version "3.1";

module namespace translation = "http://read.84000.co/translation";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";

import module namespace common = "http://read.84000.co/common" at "common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace sponsors = "http://read.84000.co/sponsors" at "sponsors.xql";
import module namespace contributors = "http://read.84000.co/contributors" at "contributors.xql";
import module namespace download = "http://read.84000.co/download" at "download.xql";
import module namespace source = "http://read.84000.co/source" at "source.xql";
import module namespace glossary = "http://read.84000.co/glossary" at "glossary.xql";
import module namespace entities = "http://read.84000.co/entities" at "entities.xql";
import module namespace functx = "http://www.functx.com";

(: view-modes hold attributes that determine the display :)
declare variable $translation:view-modes := 
    <view-modes xmlns="http://read.84000.co/ns/1.0">
      <view-mode id="default"           client="browser"  cache="use-cache"  layout="full"      glossary="use-cache"  parts="count-sections" annotation="none" />
      <view-mode id="editor"            client="browser"  cache="suppress"   layout="expanded"  glossary="defer"      parts="all"            annotation="editor" />
      <view-mode id="passage"           client="browser"  cache="suppress"   layout="flat"      glossary="use-cache"  parts="passage"        annotation="none" />
      <view-mode id="editor-passage"    client="browser"  cache="suppress"   layout="flat"      glossary="no-cache"   parts="passage"        annotation="editor" />
      <view-mode id="outline"           client="browser"  cache="suppress"   layout="flat"      glossary="suppress"   parts="outline"        annotation="none" />
      <view-mode id="annotation"        client="browser"  cache="use-cache"  layout="expanded"  glossary="use-cache"  parts="all"            annotation="web" />
      <view-mode id="txt"               client="none"     cache="use-cache"  layout="flat"      glossary="suppress"   parts="all"            annotation="none" />
      <view-mode id="ebook"             client="ebook"    cache="use-cache"  layout="flat"      glossary="use-cache"  parts="all"            annotation="none" />
      <view-mode id="pdf"               client="pdf"      cache="use-cache"  layout="flat"      glossary="suppress"   parts="all"            annotation="none" />
      <view-mode id="app"               client="app"      cache="use-cache"  layout="flat"      glossary="use-cache"  parts="all"            annotation="none" />
      <view-mode id="tests"             client="none"     cache="suppress"   layout="flat"      glossary="suppress"   parts="all"            annotation="editor" />
      <view-mode id="glossary-editor"   client="browser"  cache="suppress"   layout="full"      glossary="use-cache"  parts="glossary"       annotation="none" />
      <view-mode id="glossary-check"    client="browser"  cache="suppress"   layout="flat"      glossary="no-cache"   parts="all"            annotation="none" />
    </view-modes>;

declare variable $translation:status-statuses := $tei-content:text-statuses/m:status[@type eq 'translation'];
declare variable $translation:published-status-ids := $translation:status-statuses[@group = ('published')]/@status-id;
declare variable $translation:translated-status-ids := $translation:status-statuses[@group = ('translated')]/@status-id;
declare variable $translation:in-translation-status-ids := $translation:status-statuses[@group = ('in-translation')]/@status-id;
declare variable $translation:in-progress-status-ids := $translation:translated-status-ids | $translation:in-translation-status-ids;
declare variable $translation:marked-up-status-ids := $translation:status-statuses[@marked-up = 'true']/@status-id;
(: These maps should be merged? :)
declare variable $translation:type-prefixes := map {
        'summary':        's',
        'acknowledgment': 'ac',
        'preface':        'pf',
        'introduction':   'i',
        'translation':    'tr',
        'prologue':       'p',
        'colophon':       'c',
        'homage':         'h',
        'appendix':       'ap',
        'abbreviations':  'ab',
        'end-notes':      'n',
        'bibliography':   'b',
        'glossary':       'g',
        'citation-index': 'ci'
};
declare variable $translation:type-labels := map {
        'summary':        'Summary',
        'acknowledgment': 'Acknowledgements',
        'preface':        'Preface',
        'introduction':   'Introduction',
        'translation':    'The Translation',
        'prologue':       'Prologue',
        'colophon':       'Colophon',
        'homage':         'Homage',
        'appendix':       'Appendix',
        'abbreviations':  'Abbreviations',
        'end-notes':      'Notes',
        'bibliography':   'Bibliography',
        'glossary':       'Glossary',
        'citation-index': 'Citation Index'
};

(: Exclude any very common words from being single tokens :)
(: This could be better done by checking the text for occurrences :)
declare variable $translation:stopwords := (
    '', 'a',(:'about',:)'all','also','and','as','at','be',(:'because',:)'but','by','can','come','could',
    'day','do','even','find','first','for','from','get','give','go','have','he','her','here','him',
    'his','how','I','if','in','into','it','its','just','know','like','look','make','man','many',
    'me','more','my','new','no','not','now','of','on','one','only','or','other','our','out',(:'people',:)
    'say','see','she','so','some','take','tell','than','that','the','their','them','then','there',
    'these','they','thing',(:'think',:)'this','those','time','to','two','up','use','very','want','way',
    'we','well','what','when','which','who','will','with','would',(:'year',:)'you','your'
);

declare variable $translation:linked-data := collection(concat($common:data-path, '/config/linked-data'));

declare function translation:title($tei as element(tei:TEI), $source-key as xs:string?) as xs:string? {
    
    (: Validate the source-key :)
    let $source-bibl := tei-content:source-bibl($tei, $source-key)
    
    return (
        $tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq 'mainTitle'][@xml:lang eq 'en'][not(@key) or @key eq $source-bibl/@key] ! normalize-space(text()),
        $tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq 'mainTitle'][@xml:lang eq 'Sa-Ltn'][not(@key) or @key eq $source-bibl/@key] ! normalize-space(text()) ! concat(., ' (awaiting English title)')
    )[1]
    
};

declare function translation:title-element($tei as element(tei:TEI), $source-key as xs:string?) as element(m:title) {
    element { QName('http://read.84000.co/ns/1.0', 'title') } {
        translation:title($tei, $source-key)
    }
};

declare function local:title-set($tei as element(tei:TEI), $type as xs:string, $source-key as xs:string?) as element()* {
    
    (: Validate the source-key :)
    let $source-bibl := tei-content:source-bibl($tei, $source-key)
    
    let $titles := ($tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq $type][not(@key) or @key eq $source-bibl/@key])[normalize-space(text())]
    
    let $en := $titles[@xml:lang = ('eng', 'en')][1]
    let $bo-ltn := $titles[@xml:lang = ('Bo-Ltn', '')][1]
    let $bo := $titles[@xml:lang eq 'bo'][1]
    let $sa-ltn := $titles[@xml:lang eq 'Sa-Ltn'][1]
    
    return (
        element { QName('http://read.84000.co/ns/1.0', 'title') }{
            attribute xml:lang { 'en' },
            $en/@*[not(name(.) = ('xml:lang', 'type'))],
            $en/text() ! normalize-space(.)
        },
        element { QName('http://read.84000.co/ns/1.0', 'title') }{
            attribute xml:lang { 'bo' },
            $en/@*[not(name(.) = ('xml:lang', 'type'))],
            if(not($bo/text()) and $bo-ltn/text()) then
                common:bo-from-wylie($bo-ltn/text() ! normalize-space(.))
            else
                $bo/text() ! normalize-space(.)
        },
        element { QName('http://read.84000.co/ns/1.0', 'title') }{
            attribute xml:lang { 'Bo-Ltn' },
            $bo-ltn/@*[not(name(.) = ('xml:lang', 'type'))],
            $bo-ltn/text() ! normalize-space(.)
        },
        element { QName('http://read.84000.co/ns/1.0', 'title') }{
            attribute xml:lang { 'Sa-Ltn' },
            $sa-ltn/@*[not(name(.) = ('xml:lang', 'type'))],
            $sa-ltn/text() ! normalize-space(.)
        },
        if($source-bibl[@type eq 'chapter']) then
            let $parent-tei := $source-bibl/tei:idno/@parent-id ! tei-content:tei(., 'section')
            where $parent-tei
            return
                element { QName('http://read.84000.co/ns/1.0', 'parent') }{
                    tei-content:title-set($parent-tei, 'mainTitle')
                }
        else ()
    )
    
};

declare function translation:titles($tei as element(tei:TEI), $source-key as xs:string?) as element(m:titles) {
    element {QName('http://read.84000.co/ns/1.0', 'titles')} {
        local:title-set($tei, 'mainTitle', $source-key)
    }
};

declare function translation:long-titles($tei as element(tei:TEI), $source-key as xs:string?) as element(m:long-titles) {
    element {QName('http://read.84000.co/ns/1.0', 'long-titles')} {
        local:title-set($tei, 'longTitle', $source-key)
    }
};

declare function translation:title-variants($tei as element(tei:TEI), $source-key as xs:string?) as element(m:title-variants) {
    
    (: Validate the source-key :)
    let $source-bibl := tei-content:source-bibl($tei, $source-key)
    
    let $mainTitles := $tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq 'mainTitle'][not(@key) or @key eq $source-bibl/@key]
    
    return
        element {QName('http://read.84000.co/ns/1.0', 'title-variants')} {
            for $title in $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[not(@type eq 'shortcode')] except $mainTitles
            where $title[normalize-space(text())]
            return
                element {QName('http://read.84000.co/ns/1.0', 'title')} {
                    attribute xml:lang {$title/@xml:lang},
                    normalize-space($title/text())
                }
            ,
            for $note in 
                $tei/tei:teiHeader/tei:fileDesc/tei:notesStmt/tei:note[@type  = ('title','title-internal')]
                | $tei/tei:teiHeader/tei:fileDesc/tei:notesStmt/tei:note[@type eq 'updated'][@update eq 'title']
            return
                element {QName('http://read.84000.co/ns/1.0', 'note')} {
                    $note/@*,
                    $note/node()
                }
        }
    
};

declare function translation:publication($tei as element(tei:TEI)) as element(m:publication) {
    let $fileDesc := $tei/tei:teiHeader/tei:fileDesc
    return
        element {QName('http://read.84000.co/ns/1.0', 'publication')} {
            
            $fileDesc/tei:titleStmt/tei:author[@role eq 'translatorMain'][1][@xml:id] ! contributors:contributor-id(.) ! contributors:team(., false(), false()),
            
            element contributors {
                for $contributor in $fileDesc/tei:titleStmt/tei:author[@role eq 'translatorMain']
                return
                    element summary {
                        $contributor/@xml:id,
                        common:normalize-space($contributor/node())
                    }
                ,
                for $contributor in $fileDesc/tei:titleStmt/tei:author[not(@role eq 'translatorMain')] | $fileDesc/tei:titleStmt/tei:editor | $fileDesc/tei:titleStmt/tei:consultant
                return
                    element {local-name($contributor)} {
                        $contributor/@role,
                        $contributor/@xml:id,
                        normalize-space($contributor/text())
                    }
            },
            element sponsors {
                for $sponsor in $fileDesc/tei:titleStmt/tei:sponsor
                return
                    element sponsor {
                        $sponsor/@xml:id,
                        normalize-space($sponsor/text())
                    }
            },
            element edition {
                $fileDesc/tei:editionStmt/tei:edition[1]/node()
            },
            element license {
                attribute img-url {$fileDesc/tei:publicationStmt/tei:availability/tei:licence/tei:graphic/@url},
                common:normalize-space($fileDesc/tei:publicationStmt/tei:availability/tei:licence/tei:p)
            },
            element publication-statement {
                common:normalize-space($fileDesc/tei:publicationStmt/tei:publisher/node())
            },
            element publication-date {
                normalize-space($fileDesc/tei:publicationStmt/tei:date/text())
            },
            element tantric-restriction {
                common:normalize-space($fileDesc/tei:publicationStmt/tei:availability/tei:p[@type eq 'tantricRestriction'])
            }
        }
};

declare function translation:publication-status($bibl as element(tei:bibl), $sponsorship-text-ids as xs:string*) as element(m:publication-status)* {

    let $tei := $bibl/ancestor::tei:TEI
    let $text-id := tei-content:id($tei)
    let $sponsored := if($sponsorship-text-ids = $text-id) then true() else false()
    let $bibl-first := if(not($bibl/preceding-sibling::tei:bibl)) then true() else false()
    order by $text-id
    return (
        
        (: Status per translation block :)
        if($tei//tei:bibl[@type eq 'translation-blocks']/tei:citedRange[@status]) then (
            
            let $blocks-statuses := 
                for $block at $block-index in $tei//tei:bibl[@type eq 'translation-blocks']/tei:citedRange[@status]
                where $block[@status] and $translation:status-statuses[@status-id eq $block/@status]
                return
                    element { QName('http://read.84000.co/ns/1.0','publication-status') } {
                        attribute text-id { $text-id },
                        attribute toh-key { $bibl/@key },
                        attribute block-index { $block-index },
                        attribute block-id { $block/@xml:id },
                        attribute status { $block/@status },
                        attribute status-group { $translation:status-statuses[@status-id eq $block/@status]/@group ! string() },
                        attribute count-pages { translation:chapter-block-pages($block) },
                        if($bibl-first) then attribute bibl-first { $bibl/@key } else (),
                        if($sponsored) then attribute sponsored { $text-id } else ()
                    }
            
            let $blocks-pages := sum($blocks-statuses/@count-pages ! xs:integer(.))
            let $remainder-pages := $bibl/tei:location/@count-pages ! xs:integer(.) - $blocks-pages
            
            return (
                
                (: Return blocks :)
                $blocks-statuses,
                
                (: Add any remainder as not-started :)
                if($remainder-pages gt 0) then
                    element { QName('http://read.84000.co/ns/1.0','publication-status') } {
                        attribute text-id { $text-id },
                        attribute toh-key { $bibl/@key },
                        attribute block-index { count($blocks-statuses) + 1 },
                        attribute block-id { 'remainder' },
                        attribute status { 0 },
                        attribute status-group { $translation:status-statuses[@status-id eq '0']/@group ! string() },
                        attribute count-pages { $remainder-pages },
                        if($bibl-first) then attribute bibl-first { $bibl/@key } else (),
                        if($sponsored) then attribute sponsored { $text-id } else ()
                    }
                else ()
                
            )
        )
        
        (: Simple status per text :)
        else
            let $status := ($tei//tei:publicationStmt/tei:availability/@status[. gt ''], '0')[1]
            return
                element { QName('http://read.84000.co/ns/1.0','publication-status') } {
                    attribute text-id { $text-id },
                    attribute toh-key { $bibl/@key },
                    attribute block-index { 1 },
                    attribute block-id { $text-id },
                    attribute status { $status },
                    attribute status-group { $translation:status-statuses[@status-id eq $status]/@group ! string() },
                    attribute count-pages { $bibl/tei:location/@count-pages ! xs:integer(.) - translation:unpublished-pages($tei) },
                    if($bibl-first) then attribute bibl-first { $bibl/@key } else (),
                    if($sponsored) then attribute sponsored { $text-id } else ()
                }
            
    )
};

declare function translation:chapter-block($chapter as element(tei:div)) as element(tei:citedRange)? {
    let $chapter-decls := $chapter/@decls
    where $chapter-decls
    return
        $chapter/ancestor::tei:TEI[1]/id($chapter-decls ! replace(., '^#', ''))[self::tei:citedRange]
};

declare function translation:chapter-block-pages($chapter-block as element(tei:citedRange)) as xs:integer? {
    $chapter-block[@unit eq 'page'][@from][@to] ! (xs:integer(@to) - (xs:integer(@from) - 1))
};

declare function translation:unpublished-pages($tei as element(tei:TEI)) as xs:integer {
    sum($tei//tei:bibl[@type eq 'translation-blocks']/tei:citedRange[@status][not(@status = $translation:published-status-ids)] ! translation:chapter-block-pages(.))
};

declare function translation:source-key($tei as element(tei:TEI), $source-key as xs:string) as xs:string {
    
    let $bibl := tei-content:source-bibl($tei, $source-key)
    
    return
        if ($bibl/@key) then
            $bibl/@key
        else
            ''
};

declare function translation:toh-str($bibl as element(tei:bibl)) as xs:string? {
    replace(lower-case($bibl/@key), '^toh', '')
};

declare function translation:toh-full($bibl as element(tei:bibl)) as xs:string? {
    normalize-space(string-join($bibl/tei:ref//text()[normalize-space(.)], ' +'))
};

declare function translation:toh($tei as element(tei:TEI), $source-key as xs:string) as element(m:toh) {

    (: Returns a toh meta-data for sorting grouping  :)
    let $bibl := tei-content:source-bibl($tei, $source-key)
    let $toh-str := translation:toh-str($bibl)
    let $full := translation:toh-full($bibl)
    
    let $duplicates := 
        for $sibling in $tei//tei:sourceDesc/tei:bibl[@key][not(@key eq $bibl/@key)]
        return
            element { QName('http://read.84000.co/ns/1.0', 'duplicate') } {
                attribute key { $sibling/@key },
                element base { translation:toh-str($sibling) },
                element full { translation:toh-full($sibling) }
            }
    
    let $linked-data-refs := $translation:linked-data//m:text[range:eq(@key, $bibl/@key)]/m:ref
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'toh') } {
            attribute key { $bibl/@key },
            attribute number { replace($toh-str, '^(\d+)([a-zA-Z]*)\-*(\d*)([a-zA-Z]*)', '$1') },
            attribute letter { replace($toh-str, '^(\d+)([a-zA-Z]*)\-*(\d*)([a-zA-Z]*)', '$2') },
            attribute chapter-number { replace($toh-str, '^(\d+)([a-zA-Z]*)\-*(\d*)([a-zA-Z]*)', '$3') },
            attribute chapter-letter { replace($toh-str, '^(\d+)([a-zA-Z]*)\-*(\d*)([a-zA-Z]*)', '$4') },
            element base { $toh-str },
            element full { $full },
            
            $linked-data-refs,
            
            if($duplicates) then
                element duplicates {
                    $duplicates,
                    element full { concat('Toh ', string-join(($toh-str, $duplicates/m:base/text()), ' / ')) }
                }
            else ()
        }
};

declare function translation:location($tei as element(tei:TEI), $source-key as xs:string) as element(m:location) {
    let $bibl := tei-content:source-bibl($tei, $source-key)
    return
        tei-content:location($bibl)
};

declare function translation:filename($tei as element(tei:TEI), $source-key as xs:string) as xs:string {
    
    (: Generate a filename for a text :)
    
    let $source-key := translation:source-key($tei, $source-key)! lower-case(.)
    let $title := translation:title($tei, $source-key)
    let $title-normalized :=
    replace(
        common:normalized-chars(
            lower-case(
                $title                  (: title :)
            )                           (: convert to lower case :)
        )                               (: remove diacritics :)
    , '[^a-zA-Z0-9\s]', ' ')            (: remove non-alphanumeric, except spaces :)
    
    let $file-title :=  concat($source-key, '_', '84000', ' ', $title-normalized)
    let $filename :=    replace($file-title, '\s+', '-') (: convert spaces to hyphen :)
    return
        $filename

};

declare function translation:relative-html($resource-id as xs:string, $condition as xs:string*) as xs:string {

    concat('/translation/', $resource-id, '.html', if(count($condition[. gt '']) gt 0) then concat('?', string-join($condition, '&amp;')) else '')
    
};

declare function translation:local-html($resource-id as xs:string) as xs:string {

    concat($common:environment/m:url[@id eq 'reading-room'], translation:relative-html($resource-id, ()))
    
};

declare function translation:canonical-html($resource-id as xs:string, $condition as xs:string*) as xs:string {

    (: This must point to the distribution server - files generated on other servers must point to the canonical page :)
    concat('https://read.84000.co', translation:relative-html($resource-id, $condition))
    
};

declare function translation:downloads($tei as element(tei:TEI), $resource-id as xs:string, $include as xs:string) as element(m:downloads) {
    
    let $tei-version := tei-content:version-str($tei)
    let $file-name := translation:filename($tei, $resource-id)
    
    return
        element {QName('http://read.84000.co/ns/1.0', 'downloads')} {
        
            attribute tei-version { $tei-version },
            attribute resource-id { $resource-id },
            
            (: Only return download elements if $include defined :)
            let $types :=
                if($include gt '')then
                    ('html', 'pdf', 'epub', 'rdf', 'cache', 'json')
                else ()
            
            for $type in $types
                
                let $resource-id := if ($type eq 'cache') then tei-content:id($tei) else $resource-id
                
                let $stored-version := if ($type = ('pdf', 'epub', 'rdf', 'cache')) then download:stored-version-str($resource-id, $type) else $tei-version
                
                let $path := if ($type = ('html', 'cache', 'json')) then '/translation' else '/data'
                
            where (
                ($include eq 'all')                                                                 (: return all types :)
                or ($include eq 'any-version' and not($stored-version eq 'none'))                   (: return if there is any version :)
                or ($include eq 'latest-version' and compare($stored-version, $tei-version) eq 0)   (: return only if it's the latest version :)
            )
            return
                element download {
                    attribute type { $type },
                    attribute version { $stored-version },
                    attribute url { concat($path, '/', $resource-id, '.', $type) },
                    if(not($type = ('html', 'cache', 'json'))) then (
                        attribute download-url { concat($path, '/', $file-name, '.', $type) },
                        attribute filename { $file-name }
                    )
                    else ()
                }
        }
};

declare function translation:parts($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?, $part as xs:string?) as element(m:part)* {
    
    (: Get the parts of a translation :)
    
    let $passage-id :=
        if($view-mode[@parts eq 'all']) then
            'all'
        else if( $view-mode[@parts eq 'count-sections'] and count($tei/tei:text/tei:body/tei:div[@type eq 'translation']/tei:div[@type = ('section', 'chapter')]) le 1) then
            'all'
        else
            $passage-id
    
    (: Get the status :)
    let $status-id := tei-content:publication-status($tei)
    
    (: Evaluate if we are rendering this status :)
    let $status-render := $common:environment/m:render/m:status[@type eq 'translation'][@status-id = $status-id]
    
    (: Always return summary :)
    let $summary := 
        if(not($part) or $part eq 'summary') then
            translation:summary($tei, $passage-id, $view-mode, '')
        else ()
        
    let $acknowledgment :=
        if($status-render and (not($part) or $part eq 'acknowledgment')) then 
            translation:acknowledgment($tei, $passage-id, $view-mode)
        else ()
    
    let $preface :=
        if($status-render and (not($part) or $part eq 'preface')) then 
            translation:preface($tei, $passage-id, $view-mode)
        else ()
    
    let $introduction :=
        if($status-render and (not($part) or $part eq 'introduction')) then 
            translation:introduction($tei, $passage-id, $view-mode)
        else ()
    
    let $body :=
        if($status-render and (not($part) or $part eq 'body')) then 
            translation:body($tei, $passage-id, $view-mode, ())
        else ()
   
    let $appendix :=
        if($status-render and (not($part) or $part eq 'appendix')) then 
            translation:appendix($tei, $passage-id, $view-mode)
        else ()
        
    let $abbreviations :=
        if($status-render and (not($part) or $part eq 'abbreviations')) then 
            translation:abbreviations($tei, $passage-id, $view-mode)
        else ()
    
    let $bibliography :=
        if($status-render and (not($part) or $part eq 'bibliography')) then 
            translation:bibliography($tei, $passage-id, $view-mode)
        else ()
    
    let $end-notes :=
        if($status-render) then 
            (: Derive relevant notes ids from other content :)
            let $end-note-ids := ($summary, $acknowledgment, $preface, $introduction, $body, $appendix, $abbreviations, $bibliography)//tei:note[@place eq 'end']/@xml:id
            return
                translation:end-notes($tei, $passage-id, $view-mode, $end-note-ids)
        else ()
    
    let $glossary :=
        if($status-render) then 
            (: Derive relevant glossary ids from other content :)
            let $glossary-ids := ($summary, $acknowledgment, $preface, $introduction, $body, $appendix, $abbreviations, $bibliography)[@glossarize eq 'mark']//@xml:id
            return
                translation:glossary($tei, $passage-id, $view-mode, $glossary-ids)
        else ()
        
    let $citation-index :=
        if($status-render) then 
            translation:citation-index($passage-id, $view-mode)
        else ()
    
    (: Parts are displayed in the order returned here :)
    return (
        $summary,
        $acknowledgment,
        $preface,
        $introduction,
        $body,
        $appendix,
        $abbreviations,
        $end-notes,
        $bibliography,
        $glossary,
        $citation-index
    )
    
};

declare function translation:passage($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?) (:as element(m:part)*:) {
    
    let $passage := $tei//id($passage-id)
    let $passage-num := replace($passage-id, '^node\-', '')[functx:is-a-number(.)] ! xs:integer(.)
    
    let $passage := 
        if(not($passage) and $passage-num) then 
            $tei//*[range:eq(@tid, $passage-num)]
        else 
            $passage
    
    let $chapter-part := $passage/ancestor-or-self::tei:div[not(@type eq 'translation')][@type][last()]
    (:let $chapter-prefix := translation:chapter-prefix($chapter-part):)
    (:let $root-part := $chapter-part/ancestor-or-self::tei:div[@type][last()]:)
    
    where $chapter-part
    return (
    
        if($chapter-part/@type eq 'summary') then
            translation:summary($tei, $passage-id, $view-mode, '')
        else if($chapter-part/@type eq 'acknowledgment') then
            translation:acknowledgment($tei, $passage-id, $view-mode)
        else if($chapter-part/@type eq 'preface') then
            translation:preface($tei, $passage-id, $view-mode)
        else if($chapter-part/@type eq 'introduction') then
            translation:introduction($tei, $passage-id, $view-mode)
        else if($chapter-part/@type eq 'appendix') then
            translation:appendix($tei, $passage-id, $view-mode)
        else if($chapter-part/@type eq 'abbreviations') then
            translation:abbreviations($tei, $passage-id, $view-mode)
        else if($chapter-part/@type eq 'end-notes') then
            translation:end-notes($tei, $passage-id, $view-mode, ())
        else if($chapter-part/@type eq 'bibliography') then
            translation:bibliography($tei, $passage-id, $view-mode)
        else if($chapter-part/@type eq 'glossary') then
            translation:glossary($tei, $passage-id, $view-mode, ())
        else 
            translation:body($tei, $passage-id, $view-mode, $chapter-part/@xml:id)
        ,
        
        (: Include relevant notes :)
        if(not($chapter-part/@type eq 'end-notes')) then
            translation:end-notes($tei, $passage-id, $view-mode, $passage//tei:note[@place eq "end"]/@xml:id)
        else ()
        ,
        
        (: Include relevant glossary entries :)
        if(not($chapter-part/@type eq 'glossary')) then
            if($view-mode[@glossary eq 'no-cache']) then
                translation:glossary($tei, $passage-id, $view-mode, ())
            else if($view-mode[@glossary eq 'use-cache']) then
                translation:glossary($tei, $passage-id, $view-mode, $passage//@xml:id)
            else ()
        else ()
        ,
        
        translation:citation-index($passage-id, $view-mode)
        
    )

};

declare function translation:outline-cached($tei as element(tei:TEI)) as element(m:text-outline)* {
    
    let $text-id := tei-content:id($tei)
    let $tei-timestamp := tei-content:last-modified($tei)
    let $app-version := replace($common:app-version, '\.', '-')
    let $tei-archived := matches(base-uri($tei), concat('^', functx:escape-for-regex($common:archive-path)), 'i')
    
    let $request := 
        element { QName('http://read.84000.co/ns/1.0', 'request')} {
            attribute model { 'text-outline' },
            attribute resource-suffix { 'xml' },
            attribute resource-id { $text-id }
        }
    
    let $cache-key := 
        if($tei-timestamp instance of xs:dateTime) then
            lower-case(format-dateTime($tei-timestamp, "[Y0001]-[M01]-[D01]-[H01]-[m01]-[s01]") || '-' || $app-version)
        else ()
    
    let $cache := 
        if(not($tei-archived)) then
            common:cache-get($request, $cache-key, false())
        else ()
    
    return
        (: From cache :)
        if($cache/m:text-outline) then (
            (:util:log('info',concat('outline-cache-get:',$text-id, '/', $cache-key)),:)
            $cache/m:text-outline
        )
        
        (: Generate and cache :)
        else
            
            let $outline := 
                element {QName('http://read.84000.co/ns/1.0', 'text-outline')} {
                    
                    attribute text-id { $text-id },
                    attribute tei-timestamp { $tei-timestamp },
                    attribute app-version { $app-version },
                    
                    local:parts-pre-processed($tei),
                    tei-content:milestones-pre-processed($tei),
                    tei-content:end-notes-pre-processed($tei),
                    local:folio-refs-pre-processed($tei),
                    local:quotes-pre-processed($tei),
                    glossary:pre-processed($tei)
                    
                }
            
            let $store := 
                if(not($tei-archived)) then
                    common:cache-put($request, $outline, $cache-key)
                else ()
            
            return (
                (:util:log('info',concat('outline-cache-put:',$text-id, '/', $cache-key)),:)
                $outline
             )
    
};

declare function local:parts-pre-processed($tei as element(tei:TEI)) as element(m:pre-processed) {
    
    let $text-id := tei-content:id($tei)
    let $start-time := util:system-dateTime()
    let $parts := translation:parts($tei, (), $translation:view-modes/m:view-mode[@id eq 'outline'], ())
    let $end-time := util:system-dateTime()
    return
        tei-content:pre-processed(
            $text-id,
            'parts',
            functx:total-seconds-from-duration($end-time - $start-time),
            $parts
        )
        
};

declare function translation:outlines-related($tei as element(tei:TEI), $parts as element(m:part)*, $commentary-key as xs:string?) as element(m:text-outline)* {
    
    let $text-id := tei-content:id($tei)
    
    let $published-tei := (
    
        (: Published TEI :)
        $tei-content:translations-collection//tei:TEI
            [tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability
                [range:eq(@status, $common:environment/m:render/m:status[@type eq 'translation']/@status-id)]
            ]
        ,
        
        (: Test TEI if appropriate :)
        if($text-id = ('UT22084-000-000', 'UT23703-000-000') or $commentary-key = ('toh00', 'toh00a', 'toh00c')) then
            collection(concat($common:tei-path, '/layout-checks'))//tei:TEI
        else ()
        
    ) except $tei
    
    (: Text that this text points to :)
    let $outgoing-ids := $parts//tei:ptr/@target[matches(., '^#')] ! replace(., '^#(end\-note\-)?', '')
    let $outgoing-id-chunks := common:ids-chunked($outgoing-ids)
    let $outgoing-teis :=
        for $key in map:keys($outgoing-id-chunks)
        for $outgoing-location in $published-tei/id(map:get($outgoing-id-chunks, $key))
        let $outgoing-tei := $outgoing-location/ancestor::tei:TEI
        return
            $outgoing-tei
    
    (: Texts that point to this text :)
    let $internal-ids := ($parts//m:part/@id, $parts//@xml:id)
    let $incoming-id-targets := $internal-ids ! concat('#',.)
    let $incoming-id-targets-chunks := common:ids-chunked($incoming-id-targets)
    let $incoming-teis :=
        for $key in map:keys($incoming-id-targets-chunks)
        for $incoming-location in $published-tei/tei:text//tei:ptr[range:eq(@target, map:get($incoming-id-targets-chunks, $key))]
        let $incoming-tei := $incoming-location/ancestor::tei:TEI
        return
            $incoming-tei
    
    return 
        ($outgoing-teis | $incoming-teis) ! translation:outline-cached(.)
    
};

declare function translation:merge-parts($pre-processed as element(m:pre-processed), $merge-parts as element(m:part)*) as element(m:part)* {
    
    for $outline-part in $pre-processed/m:part
    return 
        if($outline-part[@id eq 'translation']) then 
            element { node-name($outline-part) } {
                $outline-part/@*,
                $outline-part/*[not(self::m:part)],
                for $chapter in $outline-part/m:part
                return 
                    ($merge-parts[@id eq 'translation']/m:part[@id eq $chapter/@id], $chapter)[1]
             }
        else
            ($merge-parts[@id eq $outline-part/@id], $outline-part)[1]
    
};

declare function translation:part($part as element(tei:div)?, $content-directive as xs:string, $type as xs:string, $prefix as xs:string, $label as node()*, $output-ids as xs:string*) as element(m:part) {
    local:part($part, $content-directive, $type, $prefix, $label, $output-ids, 0, 1, ())
};

declare function local:part($part as element(tei:div)?, $content-directive as xs:string, $type as xs:string, $prefix as xs:string?, $label as node()*, $output-ids as xs:string*, $nesting as xs:integer, $section-index as xs:integer, $preview as node()*) as element(m:part) {
    
    (: Return a part :)
    element { QName('http://read.84000.co/ns/1.0', 'part') } {
    
        attribute type { $type },
        attribute id { ($part/@xml:id, $type)[1] },
        attribute nesting { $nesting },
        attribute section-index { $section-index },
        attribute content-status { $content-directive },
        
        if($prefix) then
            attribute prefix { $prefix }
        else (),
        
        if($part/ancestor-or-self::tei:div[@rend eq 'ignoreGlossary']) then 
            attribute glossarize { 'suppress' }
        else if($part/ancestor-or-self::tei:div[@type = ('summary', 'introduction', 'translation', 'appendix', 'end-notes', 'glossary')]) then
            attribute glossarize { 'mark' }
        else (),
        
        if($part/@ref) then
            attribute ref { $part/@ref }
        else (),
        
        let $chapter-titles := $part/tei:head[@type eq 'chapterTitle'][text()]
        let $section-titles := $part/tei:head[@type eq $part/@type][text()]
        return
            
            (: Normalize head :)
            if ($chapter-titles) then (
                for $chapter-title in $chapter-titles
                return
                   element {QName('http://www.tei-c.org/ns/1.0', 'head')} {
                       attribute type { $type },
                       $chapter-title/@*[not(local-name(.) = ('type'))],
                       $chapter-title/node()
                   }
                ,
                for $section-title in $section-titles
                return
                   element {QName('http://www.tei-c.org/ns/1.0', 'head')} {
                       attribute type { 'supplementary' },
                       $section-title/@*[not(local-name(.) = ('type'))],
                       $section-title/node()
                   }
            )
            else if ($section-titles) then
                for $section-title in $section-titles
                return
                    element {QName('http://www.tei-c.org/ns/1.0', 'head')} {
                        attribute type { $type },
                        $section-title/@*[not(local-name(.) = ('type'))],
                        $section-title/node()
                    }
            else if ($label) then
                element {QName('http://www.tei-c.org/ns/1.0', 'head')} {
                    attribute type { $type },
                    $label
                }
             else ()
        ,
        
        (: Filter content :)
        (: End-notes :)
        if($type eq 'end-notes') then
        
            (: Just the specified ids :)
            if($content-directive = ('preview', 'passage')) then 
                $part/id($output-ids)
            
            (: Return all :)
            else if($content-directive eq 'complete') then
                $part
            
            else ()
        
        (: Glossary :)
        else if($type eq 'glossary') then 
        
            (: Just the specified ids :)
            if($content-directive = ('preview', 'passage')) then 
                $part/id($output-ids)
            
            (: Return all :)
            else if($content-directive eq 'complete') then
                $part
            
            else ()
            
        (: Other content :)
        else
            
            (: evaluate if there's enough in this part for a preview :)
            (: evaluate all sections in the root, or the first section in sub-divs :)
            
            let $output-nums := ($output-ids ! replace(., '^node\-', ''))[functx:is-a-number(.)] ! xs:integer(.)
            let $part-sections := $part/tei:div[@type = ('chapter', 'section')]
            
            let $preview := 
                if($content-directive eq 'preview' and not($preview)) then
                    tei-content:preview-nodes($part//text(), 1, ())
                else
                    $preview
            
            (: Parse <div/>s to return structure and content where required :)
            for $node in $part/*
            return
                
                (: It's a section - create a new section :)
                if ($node[local-name(.) eq 'div'][@type = ('chapter', 'section')]) then
                    
                    let $section-index := functx:index-of-node($part-sections, $node)
                    let $nesting :=
                        if($part/tei:head[@type eq $part/@type][text()]) then
                            $nesting + 1
                        else 
                            $nesting
                    
                    return (
                        
                        (: If the requested passage is no longer in scope then skip it :)
                        if($content-directive eq 'passage') then
                            
                            if(
                                $node/ancestor-or-self::*[@xml:id = $output-ids]
                                | $node/descendant::*[@xml:id = $output-ids]
                                | $node/descendant::*[range:eq(@tid, $output-nums)]
                            ) then
                                local:part($node, $content-directive, $node/@type, (), (), $output-ids, $nesting, $section-index, ())
                            else ()
                        
                        else
                            local:part($node, $content-directive, $node/@type, (), (), $output-ids, $nesting, $section-index, $preview)
                    )
                
                (: Head already included this in section-titles - so skip it :)
                else if ($node[local-name(.) eq 'head'][@type = ($type, 'chapterTitle', 'listBibl', 'notes')]) then
                    ()
                
                (: Full, collapsed or hidden rendering - return all nodes (except the above)  :)
                else if ($content-directive eq 'complete') then
                    $node
                
                (: Passage only - return only specified node  :)
                else if ($content-directive eq 'passage') then 
                    
                    (: Test for section :)
                    if($part/ancestor::tei:div[@xml:id = $output-ids]) then
                        $node
                    
                    (: Test for milestone :)
                    else if($node[self::tei:milestone][@xml:id = $output-ids]) then (
                        $node,
                        (: And the trailing content :)
                        $node/following-sibling::*[not(self::tei:milestone)][preceding-sibling::tei:*[1][@xml:id = $output-ids]]
                    )
                    
                    (: Test for @tid :)
                    else if($node/descendant-or-self::*[range:eq(@tid, $output-nums)]) then (
                        (: Return the preceding milestone :)
                        (:$passage/ancestor-or-self::*[preceding-sibling::tei:milestone[@unit eq 'chunk'][@xml:id]][1]/preceding-sibling::tei:milestone[@unit eq 'chunk'][@xml:id][1],:)
                        (: Bizarre fix required here - milestone name not selecting :)
                        $node/ancestor-or-self::*[preceding-sibling::tei:milestone[@unit eq 'chunk'][@xml:id]][1]/preceding-sibling::tei:*[@unit eq 'chunk'][@xml:id][1],
                        (: And the passage :)
                        $node
                    )
                    else ()
                    
                (: Partial rendering - return some nodes :)
                else if ($content-directive eq 'preview' and count($preview) gt 0) then (
                
                    (:element debug { attribute count-preview { count($preview) }, attribute count-text { count($node//text()) },  $preview },:)
                    if(count($node//text() | $preview) lt (count($node//text()) + count($preview))) then (
                        $node/preceding-sibling::*[1][self::tei:milestone | self::tei:lb]
                        | $node/preceding-sibling::*[2][self::tei:milestone | self::tei:lb][following-sibling::*[1][self::tei:milestone | self::tei:lb]],
                        $node
                    )
                    else ()
                    
                )
                (: 'none', 'unpublished' or unspecified $content-directive :)
                else ()
            
    }

};

declare function local:passage-in-content($content as element()*, $passage-id as xs:string?, $exclude-notes as xs:boolean?) as element()? {
    
    if(starts-with($passage-id, 'node-')) then
        let $passage-num := replace($passage-id, '^node\-', '')[functx:is-a-number(.)] ! xs:integer(.)
        where $passage-num gt 0
        return
            $content//*[range:eq(@tid, $passage-num)][1]
    
    else if($exclude-notes) then
        $content/id($passage-id)[1][not(self::tei:note)]
        
    else 
        $content/id($passage-id)[1]
        
};

declare function translation:chapter-prefix($chapter as element(tei:div)) as xs:string? {
    
    let $root-part := $chapter/ancestor-or-self::tei:div[@type][last()]
    
    let $root-prefix :=
        if($root-part/@type = ('appendix')) then
            map:get($translation:type-prefixes, $root-part/@type)
        else ()
    
    let $chapter-prefix :=
        (: If there's an @prefix then let it override the chapter index :)
        if ($chapter/@prefix gt '') then 
            $chapter/@prefix
        else if ($chapter/@type = ('prologue', 'colophon', 'homage')) then 
            map:get($translation:type-prefixes, $chapter/@type)
        else 
            functx:index-of-node($root-part/tei:div[not(@type = ('prologue', 'colophon', 'homage'))], $chapter)
    
    return
        concat($root-prefix, $chapter-prefix)
        
};

declare function translation:summary($tei as element(tei:TEI)) as element(m:part)? {
    translation:summary($tei, 'summary', (), '')
};

declare function translation:summary($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?, $lang as xs:string) as element(m:part)? {
    
    let $type := 'summary'
    let $valid-lang := common:valid-lang($lang)
    let $summary := $tei/tei:text/tei:front/tei:div[@type eq $type]
    
    let $summary :=
        if (not($valid-lang = ('en', ''))) then
            $summary[@xml:lang = $valid-lang]
        else
            $summary[not(@xml:lang) or @xml:lang = 'en']
    
    where $summary
    
    let $content-directive := 
        if($passage-id = ('summary','front','all')) then
            'complete'
        else if($view-mode[@parts = ('passage')]) then
            if(local:passage-in-content($summary, $passage-id, true())) then
                'passage'
            else
                'empty'
        else if($view-mode[@parts eq 'outline']) then
            'empty'
        else
            'complete'
    
    return
        translation:part($summary, $content-directive, $type, map:get($translation:type-prefixes, $type), text { map:get($translation:type-labels, $type) }, $passage-id)

};

declare function translation:acknowledgment($tei as element(tei:TEI)) as element()? {
    translation:acknowledgment($tei, 'acknowledgment', ())
};

declare function translation:acknowledgment($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?) as element(m:part)? {
    
    let $type := 'acknowledgment'
    let $acknowledgment := $tei/tei:text/tei:front/tei:div[@type eq $type]
    where $acknowledgment
    
    let $content-directive := 
        if($passage-id = ('acknowledgment','front','all')) then
            'complete'
        else if($view-mode[@parts = ('passage')]) then
            if(local:passage-in-content($acknowledgment, $passage-id, true())) then
                'passage'
            else
                'empty'
        else if($view-mode[@parts eq 'outline']) then
            'empty'
        else
            'complete'
    
    return
        translation:part($acknowledgment, $content-directive, $type, map:get($translation:type-prefixes, $type), text { map:get($translation:type-labels, $type) }, $passage-id)
};

declare function translation:preface($tei as element(tei:TEI)) as element(m:part)? {
    translation:preface($tei, 'preface', ())
};

declare function translation:preface($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?) as element(m:part)? {
    
    let $type := 'preface'
    let $preface := $tei/tei:text/tei:front/tei:div[@type eq $type]
    where $preface
    
    let $content-directive := 
        if($passage-id = ('preface','front','all')) then
            'complete'
        else if($view-mode[@parts = ('passage')]) then
            if(local:passage-in-content($preface, $passage-id, true())) then
                'passage'
            else
                'empty'
        else if($view-mode[@parts eq 'outline']) then
            'empty'
        else
            'preview'

    return
        translation:part($preface, $content-directive, $type, map:get($translation:type-prefixes, $type), text { map:get($translation:type-labels, $type) }, $passage-id)
};

declare function translation:introduction($tei as element(tei:TEI)) as element(m:part)? {
    translation:introduction($tei, 'introduction', ())
};

declare function translation:introduction($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?) as element(m:part)? {
    
    let $type := 'introduction'
    let $introduction := $tei/tei:text/tei:front/tei:div[@type eq $type]
    where $introduction
    
    let $content-directive := 
        if($passage-id = ('introduction','front','all')) then
            'complete'
        else if($view-mode[@parts = ('passage')]) then
            if(local:passage-in-content($introduction, $passage-id, true())) then
                'passage'
            else
                'empty'
        else if($view-mode[@parts eq 'outline']) then
            'empty'
        else
            'preview'

    return
        translation:part($introduction, $content-directive, $type, map:get($translation:type-prefixes, $type), text { map:get($translation:type-labels, $type) }, $passage-id)
};

declare function translation:body($tei as element(tei:TEI)) as element(m:part)? {
    translation:body($tei, 'body', (), ())
};

declare function translation:body($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?, $chapter-id as xs:string?) as element(m:part)? {
    
    let $translation := $tei/tei:text/tei:body/tei:div[@type eq 'translation']
    let $parts := $translation/tei:div[@type = ('section', 'chapter', 'prologue', 'colophon', 'homage')]
    let $count-chapters := count($translation/tei:div[@type = ('section', 'chapter')])
    
    where $translation
    return
        element {QName('http://read.84000.co/ns/1.0', 'part')} {
            $translation/@type,
            attribute id { 'translation' },
            attribute nesting { 0 },
            attribute section-index { 1 },
            attribute glossarize { 'mark' },
            attribute prefix { map:get($translation:type-prefixes, $translation/@type) },
            
            $translation/tei:head[@type = ('translation', 'titleHon', 'titleMain', 'sub')],
            
            for $part at $section-index in $parts
                
                (: If chapter requested, then only that chapter :)
                where not($chapter-id) or $part/@xml:id eq $chapter-id
                
                (: If there's no section header derive one :)
                let $part-title :=
                    if ($part/@type = ('prologue', 'colophon', 'homage') and not($part/tei:head[@type = $part/@type])) then
                        text { map:get($translation:type-labels, $part/@type) }
                    
                    else ()
                
                let $part-prefix := translation:chapter-prefix($part)
                let $chapter-block := translation:chapter-block($part)
                
                let $content-directive := 
                    if($view-mode[@parts eq 'outline']) then
                        'empty'
                    else if($chapter-block[@status] and not($common:environment/m:render/m:status[@type eq 'translation'][@status-id eq $chapter-block/@status])) then
                        'unpublished'
                    else if($passage-id = ($part/@xml:id, 'body', 'all')) then
                        'complete'
                    else if($view-mode[@parts = ('passage')]) then
                        if(local:passage-in-content($part, $passage-id, true())) then
                            'passage'
                        else
                            'empty'
                    else if($part/@type = ('colophon', 'homage')) then
                        'complete'
                    else
                        'preview'
                
            return 
                local:part($part, $content-directive, $part/@type, $part-prefix, $part-title, $passage-id, 0, $section-index, ())

        }

};

declare function translation:appendix($tei as element(tei:TEI)) as element(m:part)? {
    translation:appendix($tei, 'appendix', ())
};

declare function translation:appendix($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?) as element(m:part)? {
    
    let $appendix := $tei/tei:text/tei:back/tei:div[@type eq 'appendix'][1]
    
    let $content-directive := 
        if($passage-id = ('appendix', 'back', 'all')) then
            'complete'
        else if($view-mode[@parts = ('passage')]) then
            if(local:passage-in-content($appendix, $passage-id, true())) then
                'passage'
            else
                'empty'
        else if($view-mode[@parts eq 'outline']) then
            'empty'
        else
            'preview'
    
    let $prefix := map:get($translation:type-prefixes, 'appendix')
    
    where $appendix
    return
        
        element { QName('http://read.84000.co/ns/1.0', 'part') } {
            $appendix/@type,
            attribute id { 'appendix' },
            attribute nesting { 0 },
            attribute section-index { 1 },
            attribute content-status { $content-directive },
            attribute glossarize { 'mark' },
            attribute prefix { $prefix },
            
            $appendix/tei:head[@type eq 'appendix'],
            $appendix/tei:head[@type eq 'titleMain'],
            element {QName('http://www.tei-c.org/ns/1.0', 'head')} {
                attribute type { 'supplementary' },
                map:get($translation:type-labels, 'appendix')
            },
            
            for $chapter at $chapter-index in $appendix/tei:div[@type = ('section', 'chapter', 'prologue')]
            let $chapter-prefix := translation:chapter-prefix($chapter)
            return
                local:part($chapter, $content-directive, $chapter/@type, $chapter-prefix, (), $passage-id, 1, $chapter-index, ())
        }

};

declare function translation:abbreviations($tei as element(tei:TEI)) as element(m:part)? {
    translation:abbreviations($tei, 'abbreviations', ())
};

declare function translation:abbreviations($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?) as element(m:part)? {
    
    let $type := 'abbreviations'
    
    let $abbreviations := 
        element { QName('http://www.tei-c.org/ns/1.0', 'div') } {
        
            attribute type { $type },
            
            element { QName('http://www.tei-c.org/ns/1.0', 'head') } {
                attribute type { $type },
                text { map:get($translation:type-labels, $type) }
            },
            
            if($tei/tei:text/tei:back/tei:div[@type eq 'notes']/tei:list[@type eq $type]) then
                element { QName('http://www.tei-c.org/ns/1.0', 'div') } {
                    attribute type { 'section' },
                    $tei/tei:text/tei:back/tei:div[@type eq 'notes']/tei:list[@type eq $type]
                }
            else
                $tei/tei:text/tei:back/tei:div[@type eq 'notes']/tei:div[@type eq "section"][tei:list[@type eq $type]]
            
        }
    
    let $content-directive := 
        if($passage-id = ('abbreviations', 'back', 'all')) then
            'complete'
        else if($view-mode[@parts = ('passage')]) then
            if(local:passage-in-content($abbreviations, $passage-id, true())) then
                'passage'
            else
                'empty'
        else if($view-mode[@parts eq 'outline']) then
            'empty'
        else
            'complete'
    
    where $abbreviations[descendant::tei:list[@type eq $type]]
    return
        translation:part($abbreviations, $content-directive, $type, map:get($translation:type-prefixes, $type), (), ())

};

declare function translation:end-notes($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?, $note-ids as xs:string*) as element(m:part)? {
    
    let $type := 'end-notes'
    let $end-notes := 
        element { QName('http://www.tei-c.org/ns/1.0', 'div') } {
            attribute type { $type },
            $tei/tei:text//tei:note[@place eq 'end'][@xml:id]
        }
    
    where $end-notes[tei:note]
    
    let $content-directive := 
        if($passage-id = ('end-notes', 'back', 'all')) then
            'complete'
        else if($view-mode[@parts = ('passage')]) then
            if(local:passage-in-content($end-notes, $passage-id, false())) then
                'passage'
            else
                'passage'
        else if($view-mode[@parts eq 'outline']) then
            'empty'
        else
            'preview'
    
    (: Get first 8 for preview :)
    let $top-note-ids := 
        (: Ensure we don't call for outline-cached for view-mode=outline as it leads to recursion :)
        if($content-directive eq 'preview' and not($view-mode[@id eq 'outline'])) then
            translation:outline-cached($tei)/m:pre-processed[@type eq 'end-notes']/m:end-note[@index = ('1','2','3','4','5','6','7','8')]/@id
        else ()
    
    let $preview-note-ids :=
        if($content-directive = ('preview', 'passage')) then
            $note-ids
        else ()
    
    return
        translation:part($end-notes, $content-directive, $type, map:get($translation:type-prefixes, $type), text { map:get($translation:type-labels, $type) }, ($passage-id, $top-note-ids, $preview-note-ids))

};

declare function translation:bibliography($tei as element(tei:TEI)) as element(m:part)? {
    translation:bibliography($tei, 'bibliography', ())
};

declare function translation:bibliography($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?) as element(m:part)? {
    
    let $type := 'bibliography'
    let $bibliography := $tei/tei:text/tei:back/tei:div[@type eq 'listBibl']
    where $bibliography//tei:bibl
    
    let $content-directive := 
        if($passage-id = ('bibliography', 'back', 'all')) then
            'complete'
        else if($view-mode[@parts = ('passage')]) then
            if(local:passage-in-content($bibliography, $passage-id, true())) then
                'passage'
            else
                'empty'
        else if($view-mode[@parts eq 'outline']) then
            'empty'
        else
            'complete'
    
    return
        translation:part($bibliography, $content-directive, $type, map:get($translation:type-prefixes, $type), text { map:get($translation:type-labels, $type)}, ())

};

declare function translation:glossary($tei as element(tei:TEI)) as element(m:part)? {
    translation:glossary($tei, 'glossary', (), ())
};

declare function translation:glossary($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?, $location-ids as xs:string*) as element(m:part)? {
    
    let $type := 'glossary'
    let $glossary := 
        element { QName('http://www.tei-c.org/ns/1.0', 'div') } {
            attribute type { $type },
            $tei/tei:text/tei:back//tei:list[@type eq $type]/tei:item/tei:gloss[@xml:id][not(@mode eq 'surfeit')]
        }
    
    (:let $content-directive := local:content-directive($glossary, ($type, 'back'), $passage-id, $view-mode, 'preview'):)
    let $content-directive := 
        if($view-mode[@glossary = ('no-cache')]) then
            'complete'
        else if($view-mode[@parts = ('glossary')]) then
            'complete'
        else if($passage-id = ('glossary', 'back', 'all')) then
            'complete'
        else if($view-mode[@parts = ('passage')]) then
            if(local:passage-in-content($glossary, $passage-id, true())) then
                'passage'
            else
                'passage'
        else if($view-mode[@parts eq 'outline']) then
            'empty'
        else
            'preview'
    
    (: Get first 3 for preview :)
    let $top-gloss := 
        (: Ensure we don't call for outline-cached for view-mode=outline as it leads to recursion :)
        if($content-directive eq 'preview' and not($view-mode[@id eq 'outline'])) then
            translation:outline-cached($tei)/m:pre-processed[@type eq 'glossary']/m:gloss[@index = ('1','2','3')]/@id
        else ()
    
    (: Get based on location-ids :)
    let $location-cache-gloss := 
        if($content-directive = ('preview', 'passage')) then
            let $location-id-chunks := common:ids-chunked($location-ids)
            let $glossary-locations-cache := 
                if(not($view-mode[@id eq 'outline'])) then
                    glossary:glossary-cache($tei, (), false())
                else ()
            for $key in map:keys($location-id-chunks)
            return
                $glossary-locations-cache/m:gloss[m:location/@id = map:get($location-id-chunks, $key)]/@id
        else ()
    
    where $glossary[tei:gloss]
    return 
        translation:part($glossary, $content-directive, $type, map:get($translation:type-prefixes, $type), text { map:get($translation:type-labels, $type) }, distinct-values(($passage-id, $top-gloss, $location-cache-gloss)))
        
};

declare function translation:citation-index($passage-id as xs:string?, $view-mode as element(m:view-mode)?) as element(m:part)? {

    let $type := 'citation-index'
    let $citation-index := 
        element { QName('http://www.tei-c.org/ns/1.0', 'div') } {
            attribute type { $type }
            (:,element p { 'Passages this text that are quoted in other texts.' }:)
        }
    
    let $content-directive := 
        if($passage-id = ('citation-index', 'back', 'all')) then
            'complete'
        else if($view-mode[@parts = ('passage')]) then
            'none'
        else if($view-mode[@parts eq 'outline']) then
            'none'
        else
            'preview'
    
    where not($content-directive eq 'none') (: and false() Disable this while incomplete :)
    return
        translation:part($citation-index, $content-directive, $type, map:get($translation:type-prefixes, $type), text { map:get($translation:type-labels, $type) }, ())

};

declare function local:folio-refs-pre-processed($tei as element(tei:TEI)) as element(m:pre-processed) {
    
    let $start-time := util:system-dateTime()
    
    let $text-id := tei-content:id($tei)
    
    let $folio-refs :=
        for $bibl in $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key]
        let $source-key := $bibl/@key
        let $folios-for-toh := translation:folio-refs-sorted($tei, $source-key)
        return
            for $folio in $folios-for-toh
            return 
                element { QName('http://read.84000.co/ns/1.0', 'folio-ref') } {
                    attribute id { $folio/@xml:id },
                    attribute source-key { $source-key },
                    $folio/@index-in-resource,
                    $folio/@index-in-sort,
                    if($folio[@cRef-volume]) then
                        $folio/@cRef-volume
                    else ()
                }
    
    let $end-time := util:system-dateTime()
    
    return
        tei-content:pre-processed(
            $text-id,
            'folio-refs',
            functx:total-seconds-from-duration($end-time - $start-time),
            $folio-refs
        )
        
};

declare function translation:word-count($tei as element(tei:TEI)) as xs:integer {
    let $translated-text :=
    $tei/tei:text/tei:body/tei:div[@type eq "translation"]/*[
    self::tei:div[@type = ("section", "chapter", "prologue", "homage", "colophon")]
    or self::tei:head[@type ne 'translation']
    ]//text()[normalize-space()][not(ancestor::tei:note)][not(ancestor::tei:orig)]
    return
        if ($translated-text and not($translated-text = '')) then
            common:word-count($translated-text)
        else
            0
};

declare function translation:glossary-count($tei as element(tei:TEI)) as xs:integer {
    count($tei/tei:text/tei:back/tei:div[@type eq 'glossary']//tei:gloss[@xml:id][not(@mode eq 'surfeit')])
};

declare function translation:title-listing($translation-title as xs:string*) as xs:string* {
    let $first-word := substring-before($translation-title, ' ')
    return
        if (lower-case($first-word) = ('the')) then
            concat(substring-after($translation-title, concat($first-word, ' ')), ', ', $first-word)
        else
            $translation-title
};

declare function translation:start-volume($tei as element(tei:TEI), $source-key as xs:string) as xs:integer {
    tei-content:source-bibl($tei, $source-key)/tei:location/tei:volume[1]/@number/xs:integer(.)
};

declare function translation:count-volume-pages($location as element(m:location)) as xs:integer {
    sum($location/m:volume ! (xs:integer(@end-page) - (xs:integer(@start-page) - 1)))
};

declare function translation:folio-refs($tei as element(tei:TEI), $source-key as xs:string) as element(tei:ref)* {
    
    (: Get the relevant folio refs refs :)
    translation:refs($tei, $source-key, ('folio'))

};

declare function translation:refs($tei as element(tei:TEI), $source-key as xs:string, $types as xs:string*) as element(tei:ref)* {
    
    (: Validate the source-key :)
    let $source-key := translation:source-key($tei, $source-key)
    
    return
        $tei/tei:text/tei:body//tei:ref[@type = $types][not(@key) or @key eq $source-key][not(ancestor::tei:note)][not(ancestor::tei:orig)]
        (:$tei/tei:text/tei:body//tei:ref[@type = $types][not(@rend) or not(@rend = ('hidden'))][not(@key) or @key eq $source-key][not(ancestor::tei:note)][not(ancestor::tei:orig)]:)

};

declare function translation:folio-refs-sorted($tei as element(tei:TEI), $source-key as xs:string) as element(tei:ref)* {
    
    (: 
        This returns a set of folios for the text with additional detail
        e.g. the volume of each folio based on its proximity to a <ref type="volume"/>
        and it's index in the folio refs.
        Based on this folio index x can be mapped to a page in a volume
        e.g. Toh340 ref-index=620 (F.3.a) can be mapped to Volume 74 page 5.
    :)
    
    (: Get the relevant refs :)
    let $refs-for-resource :=
        for $ref at $index-in-resource in translation:refs($tei, $source-key, ('folio', 'volume'))
        return
            element {node-name($ref)} {
                $ref/@*,
                attribute index-in-resource {$index-in-resource},
                if ($ref[@type = ('volume')]) then
                    attribute sort-volume {replace($ref/@cRef, '\D', '')}
                else ()
                ,
                $ref/node()
            }
        
        (: Get the volume refs :)
    let $volume-refs := $refs-for-resource[@type = ('volume')]
    
    (: Add sort attributes to the folio refs :)
    let $folio-refs :=
        for $ref at $index-of-folio-in-resource in $refs-for-resource[@type = ('folio')]
            let $preceding-volume-refs := $volume-refs[@index-in-resource ! xs:integer(.) lt $ref/@index-in-resource ! xs:integer(.)]
            let $preceding-volume-ref-index := xs:integer(max(($preceding-volume-refs/@index-in-resource ! xs:integer(.), 0)))
            let $preceding-volume-ref := $volume-refs[@index-in-resource ! xs:integer(.) eq $preceding-volume-ref-index]
            let $cref-tokenized := tokenize($ref/@cRef, '\.')
                order by
                    if ($preceding-volume-ref) then
                        number($preceding-volume-ref/@sort-volume)
                    else 0,
                    if (count($cref-tokenized) gt 1) then
                        number(replace($cref-tokenized[2], '\D', ''))
                    else 0,
                    if (count($cref-tokenized) gt 2) then
                        $cref-tokenized[3]
                    else ''
            
            return
                element {node-name($ref)} {
                    $ref/@*[not(name(.) = ('index-in-resource', 'cRef-volume'))],
                    attribute index-in-resource {$index-of-folio-in-resource},
                    attribute cRef-volume {$preceding-volume-ref/@cRef},
                    $ref/node()
                }
        
        (: Return sorted with the sort index stored :)
    return
        for $ref at $index-in-sort in $folio-refs
            order by number($ref/@index-in-resource)
        return
            element {node-name($ref)} {
                $ref/@*,
                attribute index-in-sort {$index-in-sort},
                $ref/node()
            }
};

declare function translation:folio-sort-index($tei as element(tei:TEI), $source-key as xs:string, $index-in-resource as xs:integer) as xs:integer? {
    
    (: Convert the index of the folio in the resource into the index of the folio when sorted :)
    let $refs-sorted := translation:folio-refs-sorted($tei, $source-key)
    let $ref := $refs-sorted[xs:integer(@index-in-resource) eq $index-in-resource]
    return
        (: If the page has a folio use the sort index :)
        if($ref[@index-in-sort]) then
            $ref/@index-in-sort ! xs:integer(.)
        (: If the index has no folio, but is in range use the input :)
        else if($tei//tei:sourceDesc/tei:bibl[@key eq $source-key]/tei:location[@count-pages ! xs:integer(.) ge $index-in-resource]) then
            $index-in-resource
        else 0

};

declare function translation:folios($tei as element(tei:TEI), $source-key as xs:string) as element(m:folios) {
    
    let $location := translation:location($tei, $source-key)
    let $work := $location/@work
    let $reading-room-path := $common:environment/m:url[@id eq 'reading-room']/text()
    let $folio-refs := translation:folio-refs-sorted($tei, $source-key)
    
    return
        element {QName('http://read.84000.co/ns/1.0', 'folios')} {
            
            attribute toh-key {$location/@key},
            attribute count-pages {translation:count-volume-pages($location)},
            attribute count-refs {count($folio-refs)},
            
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
                let $folio-ref := $folio-refs[@index-in-sort ! xs:integer(.) eq $page-in-text]
                (:let $folio-ref := $folio-refs[$page-in-text]:)
                
                return
                    element folio {
                        
                        attribute volume {$volume-number},
                        attribute page-in-volume {$page-in-volume},
                        attribute page-in-text {$page-in-text},
                        attribute ref-id {$folio-ref/@xml:id},
                        $folio-ref/@rend,
                        attribute sort-index {
                            if ($folio-ref) then
                                $folio-ref/@index-in-sort
                            else
                                0
                        },
                        attribute resource-index {
                            if ($folio-ref) then
                                $folio-ref/@index-in-resource
                            else
                                0
                        },
                        attribute tei-folio {
                            if ($folio-ref) then
                                $folio-ref/@cRef
                            else
                                ''
                        },
                        attribute folio-in-volume {concat('F.', source:page-to-folio($page-in-volume))},
                        attribute folio-consecutive {concat('F.', source:page-to-folio($page-in-text + $count-title-pages + $count-trailing-pages))},
                        
                        element url {
                            attribute format {'xml'},
                            attribute xml:lang {'bo'},
                            text {concat($reading-room-path, '/source/', $location/@key, '.xml?ref-index=', $folio-ref/@index-in-resource)}
                        },
                        element url {
                            attribute format {'html'},
                            attribute xml:lang {'bo'},
                            text {concat($reading-room-path, '/source/', $location/@key, '.html?ref-index=', $folio-ref/@index-in-resource)}
                        },
                        element url {
                            attribute format {'xml'},
                            attribute xml:lang {'en'},
                            text {concat($reading-room-path, '/translation/', $location/@key, '.xml?ref-index=', $folio-ref/@index-in-resource)}
                        }
                        
                    }
        }
};

declare function translation:folio-content($tei as element(tei:TEI), $source-key as xs:string, $index-in-resource as xs:integer) as element(m:folio-content) {
    
    (: Get all the <ref/>s in the doc :)
    let $refs := translation:folio-refs($tei, $source-key)
    let $start-ref := $refs[$index-in-resource]
    let $end-ref := $refs[$index-in-resource + 1]
    
    (: Get all sections that may have a <ref/>. They must be siblings so get direct children of section. :)
    let $translation-paragraphs := $tei/tei:text/tei:body//tei:div[@type = 'translation']//tei:div[@type = ('prologue', 'homage', 'section', 'chapter', 'colophon')]/tei:*[self::tei:head | self::tei:p | self::tei:ab | self::tei:q | self::tei:lg | self::tei:list | self::tei:table | self::tei:trailer]
    
    (: Find the container of the start <ref/> and it's index :)
    let $start-ref-paragraph := $translation-paragraphs[count($start-ref) eq 1 and count(descendant::* | $start-ref) eq count(descendant::*)]
    let $start-ref-paragraph-index :=
        if ($start-ref-paragraph) then
            functx:index-of-node($translation-paragraphs, $start-ref-paragraph)
        else 0
        
    (: Find the container of the end <ref/> and it's index :)
    let $end-ref-paragraph := $translation-paragraphs[count($end-ref) eq 1 and count(descendant::* | $end-ref) eq count(descendant::*)]
    let $end-ref-paragraph-index :=
        if ($end-ref-paragraph) then
            functx:index-of-node($translation-paragraphs, $end-ref-paragraph)
        else
            count($translation-paragraphs)
        
    (: Get paragraphs including and between these 2 points :)
    let $folio-paragraphs :=
        if ($start-ref-paragraph) then
            $translation-paragraphs[position() ge $start-ref-paragraph-index and position() le $end-ref-paragraph-index]
        else ()
    
    return
        element {QName('http://read.84000.co/ns/1.0', 'folio-content')} {
        
            attribute ref-index { $index-in-resource },
            attribute source-key { $source-key },
            attribute count-refs { ($tei//tei:sourceDesc/tei:bibl[@key eq $source-key]/tei:location/@count-pages ! xs:integer(.), 0)[1] },
            attribute start-ref { $start-ref/@cRef },
            attribute end-ref { $end-ref/@cRef },
            
            (: Convert the content to text and <ref/>s only :)
            for $node in 
                $folio-paragraphs//text()[not(ancestor::tei:note)][not(ancestor::tei:orig)]
                | $folio-paragraphs//tei:ref[count(. | $start-ref) eq 1]
                | $folio-paragraphs//tei:ref[count(. | $end-ref) eq 1]
            return 
                (: Catch instances where the string ends in a punctuation mark. Assume a space has been dropped. Add a space to concat to the next string. :)
                if($node[self::tei:ref]) then
                    $node
                else 
                    let $text := normalize-space($node)
                    return (
                        text { $text },
                        if ( matches($text, '\W$', '')) then text { ' ' } else ()
                    )
            
        }
};

declare function translation:sponsors($tei as element(tei:TEI), $include-acknowledgements as xs:boolean) as element(m:sponsors) {
    
    let $translation-sponsors := $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:sponsor
    
    let $sponsor-ids := $sponsors:sponsors//m:instance[@id = $translation-sponsors/@xml:id]/parent::m:sponsor/@xml:id
    
    let $sponsors := sponsors:sponsors($sponsor-ids, false(), false())
    
    let $acknowledgment := $tei/tei:text/tei:front/tei:div[@type eq "acknowledgment"]
    
    return
        element {QName('http://read.84000.co/ns/1.0', 'sponsors')} {
            $sponsors/m:sponsor,
            if ($include-acknowledgements) then
                
                (: Use the label from the entities file unless it's specified in the tei :)
                let $sponsor-strings :=
                    for $translation-sponsor in $translation-sponsors
                        let $translation-sponsor-text := $translation-sponsor
                        let $translation-sponsor-id := $sponsors:sponsors//m:instance[@id eq $translation-sponsor/@xml:id]/parent::m:sponsor/@xml:id
                        let $sponsor-label-text := $sponsors/m:sponsor[@xml:id eq $translation-sponsor-id]/m:label
                    return
                        if ($translation-sponsor-text gt '') then
                            $translation-sponsor-text
                        else
                            if ($sponsor-label-text gt '') then
                                $sponsor-label-text
                            else ()
                
                let $count-sponsor-strings := count($sponsor-strings)
                
                let $marked-paragraphs :=
                    if ($acknowledgment/tei:p and $sponsor-strings) then
                        let $mark-sponsor-strings := $sponsor-strings ! normalize-space(lower-case(replace(., $sponsors:prefixes, '')))
                        return
                            common:mark-nodes($acknowledgment/tei:p, $mark-sponsor-strings, 'phrase')
                    else ()
                
                return
                    element tei:div {
                        attribute type {'acknowledgment'},
                        if ($marked-paragraphs/exist:match) then
                            $marked-paragraphs[exist:match]
                        else
                            if ($sponsor-strings) then (
                                attribute generated {true()},
                                element tei:p {
                                    text {'Sponsored by '},
                                    for $sponsor-string at $position in $sponsor-strings
                                    return
                                        (
                                        element exist:match {
                                            text {$sponsor-string}
                                        },
                                        text {
                                            if ($position eq $count-sponsor-strings) then
                                                '.'
                                            else
                                                ', '
                                        }
                                        )
                                }
                            )
                            else ()
                    }
            else ()
        
        }
};

declare function translation:contributors($tei as element(tei:TEI), $include-acknowledgements as xs:boolean) as element(m:contributors) {
    
    let $translation-contributors := $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:*[local-name(.) = ('author','editor','consultant')](:[not(@role eq 'translatorMain')]:)
    
    let $contributors := $contributors:contributors//m:instance[@id = $translation-contributors/@xml:id]/parent::*[self::m:person | self::m:team]
    
    let $acknowledgment := $tei/tei:text/tei:front/tei:div[@type eq "acknowledgment"]
    
    return
        element {QName('http://read.84000.co/ns/1.0', 'contributors')} {(
        
            $contributors,
            
            if ($include-acknowledgements) then
                
                (: Use the label from the entities file unless it's specified in the tei :)
                let $contributor-strings :=
                    for $translation-contributor in $translation-contributors
                    return
                        if ($translation-contributor[text()]) then
                            $translation-contributor/text()
                        else 
                            $contributors[m:instance/@id = $translation-contributor/@xml:id]/m:label/text()
                
                let $marked-paragraphs :=
                    if ($acknowledgment/tei:p and $contributor-strings) then
                        let $mark-contributor-strings := $contributor-strings ! normalize-space(lower-case(replace(., $contributors:person-prefixes, '')))
                        return
                            common:mark-nodes($acknowledgment/tei:p, $mark-contributor-strings, 'phrase')
                    else ()
                
                return
                    element tei:div {
                        attribute type {'acknowledgment'},
                        $marked-paragraphs[exist:match]
                    }
            
            else ()
                
        )}
};

declare function translation:replace-text($resource-id as xs:string) as element(m:replace-text) {
    element { QName('http://read.84000.co/ns/1.0', 'replace-text')} {
        element value {
            attribute key { '#CurrentDateTime' },
            text { format-dateTime(current-dateTime(), '[h].[m01][Pn] on [FNn], [D1o] [MNn] [Y0001]') }
        },
        element value {
            attribute key { '#LinkToSelf' },
            text { translation:local-html($resource-id) }
        },
        element value {
            attribute key { '#canonicalHTML' },
            text { translation:canonical-html($resource-id, '') }
        },
        element value {
            attribute key { '#commsSiteUrl' },
            text { $common:environment/m:url[@id eq 'communications-site'][1]/text() }
        }
    }
};

declare function translation:entities($entity-ids as xs:string*, $instance-ids as xs:string*) as element(m:entities) {
    
    let $instance-id-chunks := common:ids-chunked($instance-ids)
    let $instance-entities :=
        for $key in map:keys($instance-id-chunks)
        return
            $entities:entities//m:instance[range:eq(@id, map:get($instance-id-chunks, $key))]/parent::m:entity
    
    let $entities := $entities:entities/id($entity-ids)/self::m:entity | $instance-entities
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'entities') }{
            $entities,
            element related { entities:related($entities, false(), 'knowledgebase', 'requires-attention', 'excluded') }
        }
    
};

declare function local:quotes-pre-processed($tei as element(tei:TEI)) as element(m:pre-processed) {
    
    let $text-id := tei-content:id($tei)
    
    let $start-time := util:system-dateTime()
    
    let $quotes := local:quotes($tei)
    
    let $end-time := util:system-dateTime()
    
    return
        tei-content:pre-processed(
            $text-id,
            'quotes',
            functx:total-seconds-from-duration($end-time - $start-time),
            $quotes
        )
        
};

declare function local:quotes($tei as element(tei:TEI)) as element(m:quote)* {
    
    (: Local text :)
    let $this-toh := translation:toh($tei, '')
    let $this-text-type := tei-content:type($tei)
    let $this-text-titles := tei-content:titles-all($tei)/m:title
    let $quote-refs := $tei/tei:text//tei:ptr[@type eq 'quote-ref'][@xml:id][@target][ancestor::tei:q]
    let $quote-ref-target-ids := $quote-refs/@target ! replace(., '^#', '')
    
    (: Texts to cross-reference :)
    let $published := collection($common:tei-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/@status = $common:environment/m:render/m:status[@type eq 'translation']/@status-id]
    
    for $source-tei in $published/id($quote-ref-target-ids)/ancestor::tei:TEI
    let $source-text-id := $source-tei ! tei-content:id(.)
    let $source-text-toh := $source-tei ! translation:toh(., '')
    let $source-text-type := $source-tei ! tei-content:type(.)
    let $source-text-titles := tei-content:titles-all($source-tei)/m:title
    
    return 
        for $source-location in $source-tei/id($quote-ref-target-ids)
        let $source-location-id-target := concat('#', $source-location/@xml:id)
        let $source-part-id := $source-location/ancestor-or-self::tei:div[not(@type eq 'translation')][@xml:id][last()]/@xml:id
        return 
            (: Loop through refs :)
            for $part in  $tei//tei:div[@type eq 'translation']/tei:div[@xml:id]
            for $quote-ref in $part//tei:ptr[@target eq $source-location-id-target]
            where $quote-ref[@type eq 'quote-ref']
            return 
                local:quote($quote-ref, $part/@xml:id, $this-toh, $this-text-type, $this-text-titles, $source-location, $source-part-id, $source-text-toh, $source-text-type, $source-text-titles)
};

declare function local:quote($quote-ref as element(tei:ptr), $quote-part-id as xs:string, $quote-text-toh as element(m:toh), $quote-text-type as xs:string, $quote-text-titles as element(m:title)*, $source-location as element(), $source-part-id as xs:string, $source-text-toh as element(m:toh), $source-text-type as xs:string, $source-text-titles as element(m:title)*) as element(m:quote)? {
    
    let $quote-ref-parent := ($quote-ref/parent::tei:orig | $quote-ref/parent::tei:p | $quote-ref/parent::tei:q)(:$quote-ref/parent::tei:*:)
    let $quote := $quote-ref/ancestor::tei:q[1]
    
    where $quote
    return
        element { QName('http://read.84000.co/ns/1.0', 'quote') } {
            
            (: Properties of the quote :)
            attribute id { $quote-ref/@xml:id },
            attribute target { $quote-ref/@target },
            attribute resource-id { $quote-text-toh/@key },
            attribute resource-type { $quote-text-type },
            attribute part { $quote-part-id },
            
            (: Title of the quoting text :)
            element text-shortcode { ($quote-text-titles[@type eq 'shortcode']/text(), $quote-text-toh ! concat('t', @number, @letter) ! upper-case(.))[1] },
            element text-title { ($quote-text-titles[@type eq 'mainTitle'][@xml:lang eq 'en']/text(), $quote-text-titles[@type eq 'mainTitle']/text())[1] },
            $quote-text-toh,
            
            (: Properties of the quoted text :)
            element source {
            
                attribute resource-id { $source-text-toh/@key },
                attribute resource-type { $source-text-type },
                attribute location-id { $source-location/@xml:id },
                attribute location-part { $source-part-id },
                
                element text-shortcode { ($source-text-titles[@type eq 'shortcode']/text(), $source-text-toh ! concat('t', @number, @letter) ! upper-case(.))[1] },
                element text-title { ($source-text-titles[@type eq 'mainTitle'][@xml:lang eq 'en']/text(), $source-text-titles[@type eq 'mainTitle']/text())[1] },
                $source-text-toh
                
            },
            
            (: Include quote :)
            $quote,
            
            (: Get the quoted text, either the quote text or defined in tei:orig :)
            let $quoted-texts := 
                if($quote-ref[@rend eq 'substring']) then
                    $quote-ref-parent/descendant::text()[normalize-space()][not(ancestor::tei:note)]
                else ()
            
            (: Remove square brackets from quote, although not from orig, those can be manually removed, or added if the source has square brackets :)
            let $quoted-texts := 
                if($quoted-texts and $quote-ref-parent[not(self::tei:orig)]) then
                    $quoted-texts ! replace(., '[\[\]]', '', 'i')
                else 
                    $quoted-texts
            
            (: Normalize highlights, removing leading and trailing punctuation :)
            (: Split based on ellipses, but remember which are split this way :)
            let $highlights := 
                for $quoted-text in $quoted-texts
                return
                
                    let $ellipsis-texts := $quoted-text ! tokenize(., '…') ! normalize-space(.) ! lower-case(.) ! replace(., '^([\.\(\),!?—;:’"”“]\s*)+', '') ! replace(., '(\s*[\.\(\),!?—;:’"”“])+$', '') ! .[not(. = $translation:stopwords)]
                    let $count-ellipsis-texts := count($ellipsis-texts)
                    
                    for $ellipsis-text at $index in $ellipsis-texts
                    
                    (: Extract occurrence number for disambiguation [2] :)
                    let $occurrence :=
                        if(matches($ellipsis-text, '(.*)\[(\d+)\]$', 'i')) then 
                            replace($ellipsis-text, '(.*)\[(\d+)\]$', '$2', 'i')
                        else 1
                    
                    let $ellipsis-text-stripped := replace($ellipsis-text, '(.*)\[(\d+)\]$', '$1', 'i')
                    
                    return
                        element { QName('http://read.84000.co/ns/1.0', 'highlight') } { 
                        
                            (: Build the target regex, remove occurrence, split by word, escape and rejoin enforcing a word break :)
                            attribute target { string-join($ellipsis-text-stripped ! tokenize(., '[^\p{L}]+')[normalize-space(.) gt ''] ! functx:escape-for-regex(.), '[^\p{L}]+') },
                            
                            (: Test if it's been split by an ellipsis :)
                            if($index lt $count-ellipsis-texts) then
                                attribute ellipsis { true() }
                            else (),
                            
                            attribute occurrence { $occurrence },
                            
                            attribute string-length { string-length($ellipsis-text-stripped) },
                            
                            $ellipsis-text
                            
                        }
            
            let $count-highlights := count($highlights)
            where $count-highlights gt 0
            return (
                
                element highlight {
                
                    $highlights[1]/@*,
                    
                    attribute index { 1 },
                    
                    let $regex-following :=
                        string-join((
                            
                            (: There are following highlights so make sure there's a word break :)
                            if($count-highlights gt 1) then (
                                
                                (: All the other text nodes that need to follow :)
                                for $highlight at $index in $highlights
                                return (
                                    
                                    (: Join the target string to the regex :)
                                    if($index eq 1) then (
                                        
                                        (: It doesn't have an ellipsis so it must be the first from the start :)
                                        if($highlight[@ellipsis]) then () else '^',
                                        
                                        (: Ensure there's a word break, or it's the start :)
                                        '(^|[^\p{L}]+)'
                                        
                                    )
                                    (: Add subsequent strings :)
                                    else (
                                    
                                        $highlight/@target,
                                        
                                        (: Ensure there's a word break, or it's the end :)
                                        '([^\p{L}]+|$)',
                                        
                                        (: If it has an ellipsis so allow any other text in between, unless it's the last string :)
                                        if($index lt $count-highlights) then (
                                        
                                            if($highlight[@ellipsis]) then '(.*([^\p{L}]+|$))?' else ()
                                            
                                        )
                                        else ()
                                        
                                    )
                                    
                                )
                                
                            )
                            else()
                            
                        ))
                        
                    where $regex-following gt ''
                    return
                        attribute regex-following { $regex-following }
                    ,
                    
                    $highlights[1]/text()
                    
                }
                ,
                
                if($count-highlights gt 1) then
                    
                    element highlight {
                        
                        $highlights[last()]/@*,
                        
                        attribute index { 2 },
                        
                        let $regex-preceding :=
                            string-join((
                                
                                (: All the other text nodes that need to precede :)
                                for $highlight at $index in $highlights
                                return (
                                    
                                    (: Ensure there's a word break, or it's the start :)
                                    if($index eq 1) then(
                                        
                                        '(^|[^\p{L}]+)'
                                        
                                    )
                                    else ()
                                    ,
                                    (: Add preceding strings :)
                                    if($index lt $count-highlights) then (
                                        
                                        (: Target string :)
                                        $highlight/@target,
                                        
                                        (: Ensure there's a word break, or it's the end :)
                                        '([^\p{L}]+|$)',
                                        
                                        (: It has an ellipsis so allow any other text in between :)
                                        if($highlight[@ellipsis]) then '(.*([^\p{L}]+|$))?' else ()
                                        
                                    )
                                    else ()
                                
                                ),
                                (: Join the regex string to the target string, ensure it's the end :)
                                 '$'
                                
                            ))
                        
                        where $regex-preceding gt ''
                        return
                            attribute regex-preceding { $regex-preceding }
                        ,
                        
                        $highlights[last()]/text()
                        
                    }
                
                else ()
            )
        }
};
