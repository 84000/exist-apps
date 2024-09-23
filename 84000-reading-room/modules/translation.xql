xquery version "3.1";

module namespace translation = "http://read.84000.co/translation";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace webflow="http://read.84000.co/webflow-api";

import module namespace common = "http://read.84000.co/common" at "common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace sponsors = "http://read.84000.co/sponsors" at "sponsors.xql";
import module namespace contributors = "http://read.84000.co/contributors" at "contributors.xql";
import module namespace source = "http://read.84000.co/source" at "source.xql";
import module namespace glossary = "http://read.84000.co/glossary" at "glossary.xql";
import module namespace entities = "http://read.84000.co/entities" at "entities.xql";
import module namespace store = "http://read.84000.co/store" at "store.xql";
import module namespace functx = "http://www.functx.com";

(: View modes hold attributes that determine the display of a translation :)
declare variable $translation:view-modes := 
    <view-modes xmlns="http://read.84000.co/ns/1.0">
      <view-mode id="default"          client="browser"  cache="use-cache"  layout="full"      glossary="use-cache"  parts="count-sections"  annotation="none"   />
      <view-mode id="editor"           client="browser"  cache="suppress"   layout="expanded"  glossary="defer"      parts="all"             annotation="editor" />
      <view-mode id="json"             client="none"     cache="suppress"   layout="flat"      glossary="suppress"   parts="all"             annotation="none"   />
      <view-mode id="passage"          client="browser"  cache="suppress"   layout="flat"      glossary="use-cache"  parts="passage"         annotation="none"   />
      <view-mode id="editor-passage"   client="browser"  cache="suppress"   layout="flat"      glossary="no-cache"   parts="passage"         annotation="editor" />
      <view-mode id="json-passage"     client="none"     cache="suppress"   layout="flat"      glossary="use-cache"  parts="passage"         annotation="none"   />
      <view-mode id="outline"          client="none"     cache="suppress"   layout="flat"      glossary="suppress"   parts="outline"         annotation="none"   />
      <view-mode id="annotation"       client="browser"  cache="use-cache"  layout="expanded"  glossary="use-cache"  parts="all"             annotation="web"    />
      <view-mode id="txt"              client="none"     cache="use-cache"  layout="flat"      glossary="suppress"   parts="all"             annotation="none"   />
      <view-mode id="ebook"            client="ebook"    cache="use-cache"  layout="flat"      glossary="use-cache"  parts="all"             annotation="none"   />
      <view-mode id="pdf"              client="pdf"      cache="use-cache"  layout="flat"      glossary="suppress"   parts="all"             annotation="none"   />
      <view-mode id="app"              client="app"      cache="use-cache"  layout="flat"      glossary="use-cache"  parts="all"             annotation="none"   />
      <view-mode id="tests"            client="none"     cache="suppress"   layout="flat"      glossary="suppress"   parts="all"             annotation="none"   />
      <view-mode id="glossary-editor"  client="browser"  cache="suppress"   layout="full"      glossary="use-cache"  parts="glossary"        annotation="none"   />
      <view-mode id="glossary-check"   client="browser"  cache="suppress"   layout="flat"      glossary="no-cache"   parts="all"             annotation="none"   />
    </view-modes>;

declare variable $translation:status-statuses := $tei-content:text-statuses/m:status[@type eq 'translation'];
declare variable $translation:published-status-ids := $translation:status-statuses[@group = ('published')]/@status-id;
declare variable $translation:translated-status-ids := $translation:status-statuses[@group = ('translated')]/@status-id;
declare variable $translation:in-translation-status-ids := $translation:status-statuses[@group = ('in-translation')]/@status-id;
declare variable $translation:in-progress-status-ids := $translation:translated-status-ids | $translation:in-translation-status-ids;
declare variable $translation:marked-up-status-ids := $translation:status-statuses[@marked-up = 'true']/@status-id;
declare variable $translation:type-labels := map {
    'summary':        map {'prefix':'s', 'label':'Summary'},
    'acknowledgment': map {'prefix':'ac','label':'Acknowledgements'},
    'preface':        map {'prefix':'pf','label':'Preface'},
    'introduction':   map {'prefix':'i', 'label':'Introduction'},
    'translation':    map {'prefix':'tr','label':'The Translation'},
    'prelude':        map {'prefix':'pl','label':'Prelude'},
    'prologue':       map {'prefix':'p', 'label':'Prologue'},
    'colophon':       map {'prefix':'c', 'label':'Colophon'},
    'homage':         map {'prefix':'h', 'label':'Homage'},
    'appendix':       map {'prefix':'ap','label':'Appendix'},
    'abbreviations':  map {'prefix':'ab','label':'Abbreviations'},
    'end-notes':      map {'prefix':'n', 'label':'Notes'},
    'bibliography':   map {'prefix':'b', 'label':'Bibliography'},
    'glossary':       map {'prefix':'g', 'label':'Glossary'},
    'citation-index': map {'prefix':'ci','label':'Citation Index'}
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

declare variable $translation:file-groups := ('translation-html','translation-files','source-html','glossary-html','glossary-files','publications-list');

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
        if($source-bibl[@type eq 'chapter'] and $type eq 'mainTitle') then
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
            for $title in $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[not(@type eq 'shortcode')] except $mainTitles[@xml:lang = ('eng','en','Bo-Ltn','bo','Sa-Ltn','')]
            where $title[normalize-space(text())]
            return
                element {QName('http://read.84000.co/ns/1.0', 'title')} {
                    attribute xml:lang { $title/@xml:lang },
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
            
            let $contribution-id := ($fileDesc/tei:titleStmt/tei:author[@role eq 'translatorMain'][@xml:id])[1]/@xml:id
            let $contributor-id := ($contributors:contributors//m:team[m:instance/@id = $contribution-id])[1]/@xml:id
            where $contributor-id
            return
                contributors:team($contributor-id, false(), false())
            ,
            
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
    let $location := translation:location($tei, $bibl/@key)
    let $text-pages := translation:count-volume-pages($location)
    let $last-modified := tei-content:last-modified($tei)
    
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
                        if($sponsored) then attribute sponsored { $text-id } else (),
                        attribute last-modified { $last-modified }
                    }
            
            let $blocks-pages := sum($blocks-statuses/@count-pages ! xs:integer(.))
            let $remainder-pages := $text-pages - $blocks-pages
            
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
                        if($sponsored) then attribute sponsored { $text-id } else (),
                        attribute last-modified { $last-modified }
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
                    attribute count-pages { $text-pages - translation:unpublished-pages($tei) },
                    if($bibl-first) then attribute bibl-first { $bibl/@key } else (),
                    if($sponsored) then attribute sponsored { $text-id } else (),
                    attribute last-modified { $last-modified }
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
    
    (: Generate a human readable filename for a text :)
    
    let $source-key := translation:source-key($tei, $source-key)! lower-case(.)
    let $title := translation:title($tei, $source-key)
    let $title-normalized :=
    replace( 
        replace(
            common:normalized-chars(
                lower-case(
                    $title                  (: title :)
                )                           (: convert to lower case :)
            )                               (: remove diacritics :)
        , '[^a-zA-Z0-9\s]', ' ')            (: remove non-alphanumeric, except spaces :)
    , '(^\s+|\s+$)', '')                    (: remove leading and trailing spaces :)
    
    let $file-title :=  concat($source-key, '_', '84000', ' ', $title-normalized)
    let $filename :=    replace($file-title, '\s+', '-') (: convert spaces to hyphen :)
    return
        $filename

};

declare function translation:canonical-html($source-key as xs:string, $part-id as xs:string?, $commentary-id as xs:string?) as xs:string {

    (: This must point to the distribution server - files generated on other servers must point to the canonical page :)
    (: Maintain the legacy canonical html url for now :)
    (:concat('https://read.84000.co', concat('/translation/', $resource-id, '.html', string-join($url-parameters[. gt ''], '&amp;')[. gt ''] ! concat('?', .))):)
    translation:href($source-key, $part-id, $commentary-id, (), (), 'https://84000.co')
    
};

declare function translation:downloads($tei as element(tei:TEI), $source-key as xs:string, $include as xs:string) as element(m:downloads) {
    
    let $tei-version := tei-content:version-str($tei)
    let $tei-timestamp := tei-content:last-modified($tei)
    let $download-file-name := translation:filename($tei, $source-key)
    let $translation-files := translation:files($tei, 'translation-files', $source-key)
    
    return
        element {QName('http://read.84000.co/ns/1.0', 'downloads')} {
        
            attribute resource-id { $source-key },
            attribute tei-version { $tei-version },
            attribute tei-timestamp { $tei-timestamp },
            
            for $file in $translation-files/m:file
            (:let $resource-id := if($file/@type eq 'cache') then tei-content:id($tei) else $source-key:)
            let $file-collection := $file/@target-folder
            let $file-source-tokens := tokenize($file/@source, '/')
            let $glossary-locations := if(matches($file-source-tokens[last()], '\.glossary\-locations\.xml$', 'i')) then true() else false()
            let $stored-version-str := store:stored-version-str($file-collection, $file/@target-file)
            where (
                ($include eq 'all')                                        (: return all types :)
                or ($include eq 'any-version' and $file/@timestamp gt '')  (: return if there is any version :)
                or ($include eq 'latest-version' and $file/@up-to-date)    (: return only if it's the latest version :)
            )
            return
                element download {
                    attribute type { if($glossary-locations) then 'cache' else $file/@type },
                    attribute version { $stored-version-str },
                    attribute timestamp { $file/@timestamp },
                    if(not($glossary-locations)) then (
                        attribute url { $file/@source },
                        attribute download-url { string-join((subsequence($file-source-tokens, 1, count($file-source-tokens)-1), replace($file-source-tokens[last()], '^[^\.]*\.', concat($download-file-name, '.'), 'i')),'/') },
                        attribute filename { $download-file-name }   
                    )
                    else 
                        attribute url { replace($file/@source, '\.glossary\-locations\.xml$', '.cache', 'i') }
                }
        }
};

declare function translation:files($tei as element(tei:TEI)) as element(m:files) {
    translation:files($tei, $translation:file-groups, ())
};

declare function translation:files($tei as element(tei:TEI), $groups as xs:string*, $source-key as xs:string?) as element(m:files) {
    
    let $text-id := tei-content:id($tei)
    let $tei-timestamp := tei-content:last-modified($tei)
    let $publication-status-group := tei-content:publication-status-group($tei)
    
    (: Get outline with citation index to check for incoming quotes :)
    let $parts := 
        if($groups = 'translation-html') then
            translation:parts($tei, 'citation-index', $translation:view-modes/m:view-mode[@id eq 'default'], ())
        else ()
    let $commentary-keys := $parts[@type eq 'citation-index'] ! translation:commentary-keys($tei, tei:ptr)
    
    let $source-bibls := 
        if($source-key) then
            $tei//tei:sourceDesc/tei:bibl[@key eq $source-key]
        else 
            $tei//tei:sourceDesc/tei:bibl[@key]
    
    let $glossary-ids := 
        if($publication-status-group eq 'published' and $groups = ('glossary-html','glossary-files')) then
            $tei/tei:text/tei:back/tei:div[@type eq 'glossary'][not(@status eq 'excluded')]//tei:gloss[not(@mode eq 'surfeit')]/@xml:id
        else ()
    
    let $attribution-ids := 
        if($groups = ('glossary-html','glossary-files')) then
            $source-bibls ! tei-content:source($tei, @key)/m:attribution/@xml:id
        else ()
    
    let $entities := translation:entities((), distinct-values(($glossary-ids, $attribution-ids)))
    
    let $translation-single-page := translation:single-page($tei)
    
    return
    
        element {QName('http://read.84000.co/ns/1.0', 'files')} {
            
            attribute tei-version { tei-content:version-str($tei) },
            attribute tei-timestamp { $tei-timestamp },
            attribute glossary-locations-timestamp { xmldb:last-modified($glossary:cached-locations-path, concat($text-id, '.xml')) },
            
            for $bibl in $source-bibls
            
            let $source-key := $bibl/@key
            let $source-folios := translation:folio-refs-sorted($tei, $source-key)
            
            return (
                
                if($publication-status-group eq 'published') then (
                    
                    (: Generate pdfs and epubs first so that they can be referenced in the HTML :)
                    if($groups = 'translation-files') then (
                    
                        (: PDF :)
                        local:generated-file(
                            'pdf',
                            'translation-files',
                            concat('/translation/', $source-key, '.pdf'),
                            concat($common:static-content-path, '/translation/', $source-key),
                            concat($source-key, '.pdf'),
                            $tei-timestamp
                        ),
                        
                        (: EPUB :)
                        local:generated-file(
                            'epub',
                            'translation-files',
                            concat('/translation/', $source-key, '.epub'),
                            concat($common:static-content-path, '/translation/', $source-key),
                            concat($source-key, '.epub'),
                            $tei-timestamp
                        )
                        
                    )
                    else (),
                    
                    if($groups = 'translation-html') then (
                        
                        for $commentary-key in ('_none', $commentary-keys)
                        return (
                        
                            (: Single page / skeleton translation HTML :)
                            local:generated-file(
                                'html', 
                                'translation-html',
                                concat('/translation/', $source-key, '.html', $commentary-key[not(. eq '_none')] ! concat('?commentary=', .)),
                                concat($common:static-content-path, '/translation/', $source-key, $commentary-key[not(. eq '_none')] ! concat('/commentary-', .)),
                                concat('index', '.html'),
                                $tei-timestamp
                            ),
                            
                            (: Translation parts :)
                            for $part in ($parts[@content-status eq 'preview'] | $parts[@type eq 'translation']/m:part[@content-status eq 'preview'] | $parts[@type eq 'citation-index'][not($translation-single-page)])
                            return
                                local:generated-file(
                                    'html', 
                                    'translation-html',
                                    concat('/translation/', $source-key, '.html?part=', $part/@id, $commentary-key[not(. eq '_none')] ! concat('&amp;commentary=', .)),
                                    concat($common:static-content-path, '/translation/', $source-key, $commentary-key[not(. eq '_none')] ! concat('/commentary-', .)),
                                    concat($part/@id, '.html'),
                                    $tei-timestamp
                                )
                            
                        )
                        
                    )
                    else ()
                    ,
                    
                    if($groups = 'source-html') then (
                        
                        local:generated-file(
                            'xml',
                            'source-html',
                            '/source/sitemap.xml',
                            concat($common:static-content-path, '/source'),
                            'sitemap.xml',
                            $tei-timestamp
                        ),
                        
                        (: Source HTML :)
                        for $folio in $source-folios
                        return
                            local:generated-file(
                                'html',
                                'source-html',
                                concat('/source/', $source-key, '.html?ref-index=', $folio/@index-in-resource),
                                concat($common:static-content-path, '/source/', $source-key),
                                concat('folio-', $folio/@index-in-resource, '.html'),
                                $tei-timestamp
                            )
                        
                        
                    )
                    else ()
                    
                )
                
                (: If not published generate text stub :)
                else if($groups = 'translation-html') then 
                    local:generated-file(
                        'html', 
                        'translation-html',
                        concat('/translation/', $source-key, '.html'),
                        concat($common:static-content-path, '/translation/', $source-key),
                        concat('index', '.html'),
                        $tei-timestamp
                    )
                
                else ()
                ,
                
                if($groups = 'translation-files') then (
                    
                    (: RDF :)
                    local:generated-file(
                        'rdf',
                        'translation-files',
                        concat('/translation/', $source-key, '.rdf'),
                        concat($common:static-content-path, '/rdf/translation'),
                        concat($source-key, '.rdf'),
                        $tei-timestamp
                    )
                
                )
                else ()
                
            ),
            
            if($groups = 'translation-files') then (
            
                (: JSON :)
                local:generated-file(
                    'json',
                    'translation-files',
                    concat('/translation/', $text-id, '.json?api-version=0.4.0&amp;annotate=false'),
                    concat($common:static-content-path, '/json/translation'),
                    concat($text-id, '.json'),
                    $tei-timestamp
                ),
                
                (: Glossary cached locations :)
                if($publication-status-group eq 'published') then 
                    local:generated-file(
                        'xml',
                        'translation-files',
                        concat('/translation/', $text-id, '.glossary-locations.xml'),
                        $glossary:cached-locations-path,
                        concat($text-id, '.xml'),
                        $tei-timestamp,
                        'manual'
                    )
                else ()
                
            )
            else ()
            ,
            
            if($entities[m:entity]) then (
                
                if($groups = 'glossary-html') then (
                    
                    local:generated-file(
                        'xml',
                        'glossary-html',
                        '/glossary/sitemap.xml',
                        concat($common:static-content-path, '/glossary/named-entities'),
                        'sitemap.xml',
                        $tei-timestamp
                    ),
                    
                    (: Glossary HTML :)
                    for $entity in $entities/m:entity
                    return
                        local:generated-file(
                            'html',
                            'glossary-html',
                            concat('/glossary/', $entity/@xml:id, '.html'),
                            concat($common:static-content-path, '/glossary/named-entities'),
                            concat($entity/@xml:id, '.html'),
                            $tei-timestamp
                        )
                    
                )
                else ()
                ,
                
                (: Glossary files :)
                (:if($glossary-ids and $groups = 'glossary-files') then (
                
                    let $glossary-files := glossary:downloads()
                    for $glossary-file in $glossary-files/m:download
                    return 
                        local:generated-file(
                            $glossary-file/@type,
                            'glossary-files',
                            $glossary-file/@url,
                            concat($common:static-content-path, '/glossary/combined'),
                            concat('84000-glossary', $glossary-file/@lang-key ! concat('-',.), '.', $glossary-file/@type),
                            $tei-timestamp,
                            'scheduled'
                        )
                        
                )
                else ()
                ,:)
                
                if($groups = 'publications-list') then (
                    
                    local:generated-file(
                        'xml',
                        'publications-list',
                        '/translation/sitemap.xml',
                        concat($common:static-content-path, '/translation'),
                        'sitemap.xml',
                        $tei-timestamp
                    ),
                    
                    (: Publication manifest files :)
                    local:generated-file(
                        'json',
                        'publications-list',
                        '/.well-known/apple-app-site-association',
                        concat($common:static-content-path, '/mobile-app'),
                        'apple-app-site-association.json',
                        $tei-timestamp
                    ),
                    
                    local:generated-file(
                        'json',
                        'publications-list',
                        '/section/all-translated.json?api-version=0.2.0',
                        concat($common:static-content-path, '/catalogue'),
                        'all-translated.json',
                        $tei-timestamp
                    ),
                    
                    local:generated-file(
                        'json',
                        'publications-list',
                        '/section/lobby.json?api-version=0.2.0',
                        concat($common:static-content-path, '/catalogue'),
                        'lobby.json',
                        $tei-timestamp
                    ),
                    
                    local:generated-file(
                        'txt',
                        'publications-list',
                        '/robots-public.txt',
                        concat($common:static-content-path, '/catalogue'),
                        'robots.txt',
                        $tei-timestamp
                    )
                    
                )
                else ()
                
                (:for $bibl in $tei//tei:sourceDesc/tei:bibl[@key]
                let $source-key := $bibl/@key
                let $catalogue-sections := tei-content:ancestors($tei, $source-key, 1)
                return (
                    (\: Section HTML :\)
                    for $section in $catalogue-sections/descendant-or-self::m:parent[@type eq 'section'][not(@id eq 'LOBBY')]
                    let $section-webflow-item := $webflow-api-config//webflow:item[@id eq $section/@id]
                    return
                        element file {
                            attribute type { 'json' },
                            attribute group {'publication-files'},
                            attribute source { concat('/section/', $section/@id, '.json') },
                            attribute target { concat($section/@id, '.json') },
                            attribute timestamp { 'none' }
                        }
                ):)
                
            )
            else ()
        }
    
};

declare function local:generated-file($file-type as xs:string, $file-group as xs:string, $source-url as xs:string, $target-folder as xs:string, $target-file as xs:string, $tei-timestamp as xs:dateTime) as element(m:file) {

    local:generated-file($file-type, $file-group, $source-url, $target-folder, $target-file, $tei-timestamp, ())

};

declare function local:generated-file($file-type as xs:string, $file-group as xs:string, $source-url as xs:string, $target-folder as xs:string, $target-file as xs:string, $tei-timestamp as xs:dateTime, $action as xs:string?) as element(m:file) {
    
    let $target := string-join(($target-folder, $target-file), '/')
    
    let $file-timestamp := (:file:directory-list($target-folder, $target-file)/file:file[1]/@modified:)
        if($file-type = $store:binary-types) then
            if(util:binary-doc-available($target)) then 
                xmldb:last-modified($target-folder, $target-file)
            else ()
        else
            if(doc-available($target)) then 
                xmldb:last-modified($target-folder, $target-file) 
            else ()
    
    let $file-up-to-date := ($file-timestamp ! xs:dateTime(.) ge $tei-timestamp)
    
    return
      element { QName('http://read.84000.co/ns/1.0','file') } {
          attribute type { $file-type },
          attribute group { $file-group },
          attribute source { $source-url },
          attribute target-folder { $target-folder },
          attribute target-file { $target-file },
          attribute timestamp { $file-timestamp },
          if($file-up-to-date) then attribute up-to-date { true() } else (),
          if($action = ('scheduled','manual')) then attribute action { $action } else (),
          if(not($file-up-to-date) and not($action = ('scheduled','manual'))) then attribute publish { true() } else ()
      }
};

declare function translation:api-status($tei as element(tei:TEI)) as element(m:api-status) {
    
    let $text-id := tei-content:id($tei)
    let $tei-timestamp := tei-content:last-modified($tei)
    let $webflow-api-config := doc(concat($common:data-path, '/local/webflow-api.xml'))
    
    return
        element {QName('http://read.84000.co/ns/1.0', 'api-status')} {
            
            attribute tei-version { tei-content:version-str($tei) },
            attribute tei-timestamp { tei-content:last-modified($tei) },
            
            for $bibl in $tei//tei:sourceDesc/tei:bibl[@key]
            let $source-key := $bibl/@key
            let $text-webflow-item := $webflow-api-config//webflow:item[@id eq $source-key]
            let $catalogue-sections := tei-content:ancestors($tei, $source-key, 1)
            return (
                
                (: Texts :)
                element api-call {
                    attribute type { 'webflow-api' },
                    attribute group {'translation'},
                    attribute source { $source-key },
                    (:attribute target { $text-webflow-item ! concat('https://api.webflow.com/v2/collections/', parent::webflow:collection/@webflow-id, '/items/', @webflow-id) },:)
                    attribute target-call { 'patch-text' },
                    attribute linked { if($text-webflow-item) then true() else false() },
                    attribute timestamp { ($text-webflow-item/@updated, 'none')[1] },
                    if($text-webflow-item/@updated[xs:dateTime(.) ge $tei-timestamp]) then attribute up-to-date { true() }
                    else attribute publish { true() }
                },
            
                (: Sections :)
                for $section in $catalogue-sections/descendant-or-self::m:parent[@type eq 'section'][not(@id eq 'LOBBY')]
                let $section-webflow-item := $webflow-api-config//webflow:item[@id eq $section/@id]
                return
                    element api-call {
                        attribute type { 'webflow-api' },
                        attribute group {'catalogue-section'},
                        attribute source { $section/@id },
                        (:attribute target { $section-webflow-item ! concat('https://api.webflow.com/v2/collections/', parent::webflow:collection/@webflow-id, '/items/', @webflow-id) },:)
                        attribute target-call { 'patch-catalogue-section' },
                        attribute linked { if($section-webflow-item) then true() else false() },
                        attribute timestamp { ($section-webflow-item/@updated, 'none')[1] },
                        if($section-webflow-item/@updated[xs:dateTime(.) ge $tei-timestamp]) then attribute up-to-date { true() }
                        else attribute publish { true() }
                    }
            )
            
        }
    
};

declare function translation:single-page($tei as element(tei:TEI)) as xs:boolean {

    if(count($tei/tei:text/tei:body/tei:div[@type eq 'translation']/tei:div[@type = ('section', 'chapter')]) le 1) then
        true()
    else
        false()

};

declare function translation:commentary-keys($tei as element(tei:TEI), $inbound-pointers as element(tei:ptr)*) as xs:string* {
    
    let $other-tei := local:other-tei($tei, true(), ())
    let $commentary-tei := $other-tei/id($inbound-pointers/@xml:id)/ancestor::tei:TEI
    return
        $commentary-tei//tei:sourceDesc/tei:bibl/@key
        
};

declare function translation:parts($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?, $part as xs:string?) as element(m:part)* {
    
    (: Get the parts of a translation :)
    
    let $passage-id :=
        if($view-mode[@parts eq 'all']) then
            'all'
        else if( $view-mode[@parts eq 'count-sections'] and translation:single-page($tei)) then
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
    
    let $glossary :=
        if($status-render) then 
            (: Derive relevant glossary ids from other content :)
            let $glossary-ids := ($summary, $acknowledgment, $preface, $introduction, $body, $appendix, $abbreviations, $bibliography)[@glossarize eq 'mark']//@xml:id
            return
                translation:glossary($tei, $passage-id, $view-mode, $glossary-ids)
        else ()
    
    let $end-notes :=
        if($status-render) then 
            (: Derive relevant notes ids from other content :)
            let $end-note-ids := ($summary, $acknowledgment, $preface, $introduction, $body, $appendix, $abbreviations, $bibliography)//tei:note[@place eq 'end']/@xml:id
            return
                translation:end-notes($tei, $passage-id, $view-mode, $end-note-ids)
        else ()
    
    let $citation-index :=
        if($status-render) then 
            translation:citation-index($tei, $passage-id, $view-mode, $body//@xml:id)
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

declare function translation:passage($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?) as element(m:part)* {
    
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
    
    let $part:=
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
    
    (: Include relevant notes :)
    let $notes := 
        if(not($chapter-part/@type eq 'end-notes')) then 
            translation:end-notes($tei, $passage-id, $view-mode, $part//tei:note[@place eq "end"]/@xml:id)
        else ()
    
    (: Include relevant glossary entries :)
    let $glosses :=
        if(not($chapter-part/@type eq 'glossary')) then
            if($view-mode[@glossary eq 'no-cache']) then
                translation:glossary($tei, $passage-id, $view-mode, ())
            else if($view-mode[@glossary eq 'use-cache']) then
                translation:glossary($tei, $passage-id, $view-mode, $part//@xml:id)
            else ()
        else ()
    
    let $citation-index := translation:citation-index($tei, $passage-id, $view-mode, $part//@xml:id)
    
    where $chapter-part
    return (
        $part,
        $notes,
        $glosses,
        $citation-index
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
                element { QName('http://read.84000.co/ns/1.0', 'text-outline') } {
                    
                    attribute text-id { $text-id },
                    attribute tei-timestamp { $tei-timestamp },
                    attribute app-version { $app-version },
                    
                    tei-content:titles-all($tei),
                    $tei//tei:sourceDesc/tei:bibl[@key] ! translation:toh($tei, .),
                    
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

declare function local:other-tei($tei as element(tei:TEI), $published-only as xs:boolean?, $commentary-key as xs:string?) as element(tei:TEI)* {
    
    let $text-id := tei-content:id($tei)
    let $render-status-ids := $common:environment/m:render/m:status[@type eq 'translation']/@status-id
    
    return (
    
        (: Published TEI :)
        if($published-only) then
            $tei-content:translations-collection//tei:TEI
                [tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability
                    [range:eq(@status, $render-status-ids)]
                ]
        else
            $tei-content:translations-collection//tei:TEI
        ,
        
        (: Test TEI if appropriate :)
        if($text-id = ('UT22084-000-000', 'UT23703-000-000') or $commentary-key = ('toh00', 'toh00a', 'toh00c')) then
            collection(concat($common:tei-path, '/layout-checks'))//tei:TEI
        else ()
        
    ) except $tei
};

declare function translation:outlines-related($tei as element(tei:TEI), $parts as element(m:part)*, $commentary-key as xs:string?) as element(m:text-outline)* {
    
    let $text-id := tei-content:id($tei)
    
    let $other-tei := local:other-tei($tei, true(), $commentary-key)
    
    (: Text that this text points to :)
    let $outbound-ids := $parts//tei:ptr/@target[matches(., '^(toh[0-9a-z\-]+\.html)?#')] ! replace(., '^#(end\-note\-)?', '')
    let $outbound-id-chunks := common:ids-chunked($outbound-ids)
    let $outbound-teis :=
        for $key in map:keys($outbound-id-chunks)
        for $outbound-location in $other-tei/id(map:get($outbound-id-chunks, $key))
        let $outbound-tei := $outbound-location/ancestor::tei:TEI
        return
            $outbound-tei
    
    (: Texts that point to this text :)
    let $tei-ids := ($parts//m:part/@id, $parts//@xml:id)
    let $inbound-id-targets := $tei-ids ! concat('#',.)
    let $inbound-id-targets-chunks := common:ids-chunked($inbound-id-targets)
    let $inbound-teis :=
        for $key in map:keys($inbound-id-targets-chunks)
        for $inbound-location in $other-tei/tei:text//tei:ptr[range:eq(@target, map:get($inbound-id-targets-chunks, $key))]
        let $inbound-tei := $inbound-location/ancestor::tei:TEI
        return
            $inbound-tei
    
    return 
        ($outbound-teis | $inbound-teis) ! translation:outline-cached(.)
    
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
        
        (:$output-ids ! element output-id { . },:)
        
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
                $part/*
            
            else ()
        
        (: Glossary :)
        else if($type eq 'glossary') then 
        
            (: Just the specified ids :)
            if($content-directive = ('preview', 'passage')) then 
                $part/id($output-ids)
            
            (: Return all :)
            else if($content-directive eq 'complete') then
                $part/*
            
            else ()
        
        (: Citation Index :)
        else if($type eq 'citation-index') then 
            
            (: Return all :)
            $part/*
            
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
                                local:part($node, $content-directive, $node/@type, $node/@prefix, (), $output-ids, $nesting, $section-index, ())
                            else ()
                        
                        else
                            local:part($node, $content-directive, $node/@type, $node/@prefix, (), $output-ids, $nesting, $section-index, $preview)
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
                        for $following-sibling in $node/following-sibling::*[not(self::tei:milestone)]
                        let $preceding-milestone := $following-sibling/preceding-sibling::tei:*[self::tei:milestone][1]
                        where count($preceding-milestone | $node) eq 1
                        return
                            $following-sibling
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
            $translation:type-labels($root-part/@type)('prefix')
            (:map:get($translation:type-prefixes, $root-part/@type):)
        else ()
    
    let $chapter-prefix :=
        (: If there's an @prefix then let it override the chapter index :)
        if ($chapter/@prefix gt '') then 
            $chapter/@prefix
        else if ($chapter/@type = ('prelude', 'prologue', 'colophon', 'homage')) then 
            $translation:type-labels($chapter/@type)('prefix')
            (:map:get($translation:type-prefixes, $chapter/@type):)
        else 
            functx:index-of-node($root-part/tei:div[not(@type = ('prelude', 'prologue', 'colophon', 'homage'))], $chapter)
    
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
        if($passage-id = ($summary/@xml:id, 'summary','front','all')) then
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
        translation:part($summary, $content-directive, $type, $translation:type-labels($type)('prefix'), text { $translation:type-labels($type)('label') }, $passage-id)

};

declare function translation:acknowledgment($tei as element(tei:TEI)) as element()? {
    translation:acknowledgment($tei, 'acknowledgment', ())
};

declare function translation:acknowledgment($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?) as element(m:part)? {
    
    let $type := 'acknowledgment'
    let $acknowledgment := $tei/tei:text/tei:front/tei:div[@type eq $type]
    where $acknowledgment
    
    let $content-directive := 
        if($passage-id = ($acknowledgment/@xml:id, 'acknowledgment','front','all')) then
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
        translation:part($acknowledgment, $content-directive, $type, $translation:type-labels($type)('prefix'), text { $translation:type-labels($type)('label') }, $passage-id)
};

declare function translation:preface($tei as element(tei:TEI)) as element(m:part)? {
    translation:preface($tei, 'preface', ())
};

declare function translation:preface($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?) as element(m:part)? {
    
    let $type := 'preface'
    let $preface := $tei/tei:text/tei:front/tei:div[@type eq $type]
    where $preface
    
    let $content-directive := 
        if($passage-id = ($preface/@xml:id, 'preface','front','all')) then
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
        translation:part($preface, $content-directive, $type, $translation:type-labels($type)('prefix'), text { $translation:type-labels($type)('label') }, $passage-id)
};

declare function translation:introduction($tei as element(tei:TEI)) as element(m:part)? {
    translation:introduction($tei, 'introduction', ())
};

declare function translation:introduction($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?) as element(m:part)? {
    
    let $type := 'introduction'
    let $introduction := $tei/tei:text/tei:front/tei:div[@type eq $type]
    where $introduction
    
    let $content-directive := 
        if($passage-id = ($introduction/@xml:id, 'introduction','front','all')) then
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
        translation:part($introduction, $content-directive, $type, $translation:type-labels($type)('prefix'), text { $translation:type-labels($type)('label') }, $passage-id)
};

declare function translation:body($tei as element(tei:TEI)) as element(m:part)? {
    translation:body($tei, 'body', (), ())
};

declare function translation:body($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?, $chapter-id as xs:string?) as element(m:part)? {
    
    let $translation := $tei//tei:body/tei:div[@type eq 'translation']
    let $parts := $translation/tei:div[@type = ('section', 'chapter', 'prelude', 'prologue', 'colophon', 'homage')]
    let $count-chapters := count($parts[@type = ('section', 'chapter')])
    
    where $translation
    return
        element {QName('http://read.84000.co/ns/1.0', 'part')} {
            $translation/@type,
            attribute id { ($translation/@xml:id, $translation/@type)[1] },
            attribute nesting { 0 },
            attribute section-index { 1 },
            attribute glossarize { 'mark' },
            attribute prefix { $translation:type-labels($translation/@type)('prefix') },
            
            $translation/tei:head[@type = ('translation', 'titleHon', 'titleMain', 'titleCatalogueSection', 'sub')],
            
            for $part at $section-index in $parts
                
                (: If chapter requested, then only that chapter :)
                where not($chapter-id) or $part/@xml:id eq $chapter-id
                
                (: If there's no section header derive one :)
                let $part-title :=
                    if ($part/@type = ('prologue', 'prelude', 'colophon', 'homage') and not($part/tei:head[@type = $part/@type])) then
                        text { $translation:type-labels($part/@type)('label') }
                    
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
        if($passage-id = ($appendix/@xml:id, 'appendix', 'back', 'all')) then
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
    
    let $prefix := $translation:type-labels('appendix')('prefix')
    
    where $appendix
    return
        
        element { QName('http://read.84000.co/ns/1.0', 'part') } {
            $appendix/@type,
            attribute id { ($appendix/@xml:id, $appendix/@type)[1] },
            attribute nesting { 0 },
            attribute section-index { 1 },
            attribute content-status { $content-directive },
            attribute glossarize { 'mark' },
            attribute prefix { $prefix },
            
            $appendix/tei:head[@type eq 'appendix'],
            $appendix/tei:head[@type eq 'titleMain'],
            element {QName('http://www.tei-c.org/ns/1.0', 'head')} {
                attribute type { 'supplementary' },
                $translation:type-labels('appendix')('label')
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
    let $text-id := tei-content:id($tei)
    let $abbreviations-part := $tei/tei:text/tei:back/tei:div[@type eq 'notes']
    
    let $abbreviations := 
        element { QName('http://www.tei-c.org/ns/1.0', 'div') } {
        
            attribute type { $type },
            attribute xml:id { ($abbreviations-part/@xml:id, $type)[1] },
            
            element { QName('http://www.tei-c.org/ns/1.0', 'head') } {
                attribute type { $type },
                text { $translation:type-labels($type)('label')}
            },
            
            (: If the abbreviations don't have a section container then add one :)
            if($abbreviations-part/tei:div[@type eq "section"]) then
                $abbreviations-part/*
            else
                element { QName('http://www.tei-c.org/ns/1.0', 'div') } {
                    attribute type { 'section' },
                    attribute xml:id { concat($text-id, '-notes-', '1') },
                    $abbreviations-part/*
                }
            
        }
    
    let $content-directive := 
        if($passage-id = ($abbreviations-part/@xml:id, 'abbreviations', 'back', 'all')) then
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
        translation:part($abbreviations, $content-directive, $type, $translation:type-labels($type)('prefix'), (), ())

};

declare function translation:end-notes($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?, $note-ids as xs:string*) as element(m:part)? {
    
    let $type := 'end-notes'
    let $text-id := tei-content:id($tei)
    let $end-notes-part-id := concat($text-id, '-', $type)
    let $end-notes := 
        element { QName('http://www.tei-c.org/ns/1.0', 'div') } {
            attribute type { $type },
            attribute xml:id { $end-notes-part-id },
            $tei/tei:text//tei:note[@place eq 'end'][@xml:id]
        }
    
    where $end-notes[tei:note]
    
    let $content-directive := 
        if($passage-id = ($end-notes//@xml:id, $end-notes-part-id, 'end-notes', 'back', 'all')) then
            'complete'
        else if($view-mode[@parts = ('passage')]) then
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
        translation:part($end-notes, $content-directive, $type, $translation:type-labels($type)('prefix'), text { $translation:type-labels($type)('label') }, distinct-values(($passage-id, $top-note-ids, $preview-note-ids)))

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
        translation:part($bibliography, $content-directive, $type, $translation:type-labels($type)('prefix'), text { $translation:type-labels($type)('label') }, ())

};

declare function translation:glossary($tei as element(tei:TEI)) as element(m:part)? {
    translation:glossary($tei, 'glossary', (), ())
};

declare function translation:glossary($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?, $location-ids as xs:string*) as element(m:part)? {
    
    let $type := 'glossary'
    let $glossary-part := $tei/tei:text/tei:back/tei:div[@type eq $type]
    let $glossary := 
        element { QName('http://www.tei-c.org/ns/1.0', 'div') } {
            attribute type { $type },
            attribute xml:id { ($glossary-part/@xml:id, $type)[1] },
            $glossary-part/tei:list[@type eq $type]/tei:item/tei:gloss[@xml:id][not(@mode eq 'surfeit')]
        }
    
    (:let $content-directive := local:content-directive($glossary, ($type, 'back'), $passage-id, $view-mode, 'preview'):)
    let $content-directive := 
        if($view-mode[@glossary = ('no-cache')]) then
            'complete'
        else if($view-mode[@parts = ('glossary')]) then
            'complete'
        else if($passage-id = ($glossary-part/@xml:id, 'glossary', 'back', 'all')) then
            'complete'
        else if($view-mode[@parts = ('passage')]) then
             'passage'
        else if($view-mode[@parts eq 'outline']) then
            'empty'
        else
            'preview'
    
    (: Get first 3 for preview :)
    let $top-gloss := 
        (: Ensure we don't call for outline-cached for view-mode=outline as it leads to recursion :)
        if($content-directive eq 'preview' and not($view-mode[@parts eq 'outline'])) then
            translation:outline-cached($tei)/m:pre-processed[@type eq 'glossary']/m:gloss[@index = ('1','2','3')]/@id
        else ()
    
    (: Get based on location-ids :)
    let $location-cache-gloss := 
        if($content-directive = ('preview', 'passage') and not($view-mode[@parts eq 'outline'])) then
            let $glossary-cached-locations := glossary:cached-locations($tei, (), false())
            where $glossary-cached-locations
            return
                local:related-glossary-ids(distinct-values(($passage-id, $location-ids)), $glossary-cached-locations)
        else ()
    
    where $glossary[tei:gloss]
    return 
        translation:part($glossary, $content-directive, $type, $translation:type-labels($type)('prefix'), text { $translation:type-labels($type)('label') }, distinct-values(($passage-id, $top-gloss, $location-cache-gloss)))
        
};

declare function local:related-glossary-ids($location-ids as xs:string*, $glossary-cached-locations as element(m:glossary-cached-locations)) as xs:string* {
    
    (: Get glossary entries referenced in locations :)
    let $related-glossary-ids := 
        let $location-id-chunks := common:ids-chunked(distinct-values($location-ids))
        for $key in map:keys($location-id-chunks)
        let $location-ids := $location-id-chunks($key)
        return
            $glossary-cached-locations/m:gloss[range:eq(m:location/@id, $location-ids)]/@id
    
    return 
        (: Check for more glossaries referenced in these glossaries :)
        if($related-glossary-ids[not(. = $location-ids)]) then
            local:related-glossary-ids(($location-ids, $related-glossary-ids), $glossary-cached-locations)
        
        (: Return glossary ids :)
        else 
            $related-glossary-ids
    
};

declare function translation:citation-index($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?, $location-ids as xs:string*) as element(m:part)? {

    let $type := 'citation-index'
    let $text-id := tei-content:id($tei)
    let $citation-index-part-id := concat($text-id, '-', $type)
    
    let $content-directive := 
        if($passage-id = ($citation-index-part-id, 'citation-index', 'back', 'all')) then
            'complete'
        else if($view-mode[@parts = ('passage')]) then
            'passage'
        else if($view-mode[@parts eq 'outline']) then
            'empty'
        else
            'preview'
    
    (: Do other texts reference this one? :)
    (: It's a bit slow to do this for every text :)
    let $inbound-id-targets := $tei/tei:text/tei:body//@xml:id ! concat('#',.)
    let $inbound-id-targets-chunks := common:ids-chunked($inbound-id-targets)
    let $other-tei := local:other-tei($tei, true(), ())
    let $inbound-pointers :=
        for $key in map:keys($inbound-id-targets-chunks)
        let $inbound-id-targets := map:get($inbound-id-targets-chunks, $key)
        return
            $other-tei//tei:ptr[@type eq 'quote-ref'][range:eq(@target, $inbound-id-targets)][@xml:id][ancestor::tei:q]
    
    (: ~ Alternative query is slower
    let $other-tei := local:other-tei($tei, true(), ())
    let $inbound-pointer-ids := $other-tei/tei:text//tei:ptr[@type eq 'quote-ref'][@xml:id][ancestor::tei:q]/@target ! replace(., '^#', '')
    let $inbound-pointers :=
        for $target in $tei/id($inbound-pointer-ids)
        return
            $other-tei/tei:text//tei:ptr[range:eq(@target, concat('#', $target/@xml:id))][@type eq 'quote-ref'][@xml:id][ancestor::tei:q]:)
    
    let $citation-index := 
        element { QName('http://www.tei-c.org/ns/1.0', 'div') } {
        
            attribute type { $type },
            attribute xml:id { $citation-index-part-id },
            
            (: Return all :)
            if($content-directive eq 'complete') then
                $inbound-pointers
            
            (: Return those relevant to the passage :)
            else if($content-directive = ('passage','preview')) then
                let $location-refs := $location-ids ! concat('#',.)
                return (
                
                    $inbound-pointers[@target = $location-refs],
                    
                    (: Ensure at least one to trigger the part. The actual preview is handled in the view. :)
                    if($content-directive eq 'preview') then
                        $inbound-pointers[1]
                    else ()
                    
                )
                
            else ()
        }
    
    where not($content-directive eq 'none') and $inbound-pointers (: and false() Disable this while incomplete :)
    return
        translation:part($citation-index, $content-directive, $type, $translation:type-labels($type)('prefix'), text { $translation:type-labels($type)('label') }, ())

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
            let $part := $tei/id($folio/@xml:id)/ancestor::tei:div[@type][not(@type eq 'translation')][last()]
            return 
                element { QName('http://read.84000.co/ns/1.0', 'folio-ref') } {
                    attribute id { $folio/@xml:id },
                    attribute part-id { ($part/@xml:id, $part/@type)[1]/string() },
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
    sum($location/m:volume[@start-page][@end-page] ! ((@end-page ! xs:integer(.) - @start-page ! xs:integer(.)) + 1))
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
            element { node-name($ref) } {
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
    let $location := translation:location($tei, $source-key)
    let $count-pages := translation:count-volume-pages($location)
    return
        (: If the page has a folio use the sort index :)
        if($ref[@index-in-sort]) then
            $ref/@index-in-sort ! xs:integer(.)
        (: If the index has no folio, but is in range use the input :)
        else if($index-in-resource le $count-pages) then
            $index-in-resource
        else 0

};

declare function translation:folios($tei as element(tei:TEI), $source-key as xs:string) as element(m:folios) {
    
    let $location := translation:location($tei, $source-key)
    let $work := $location/@work
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
                            text {concat('/source/', $location/@key, '.xml?ref-index=', $folio-ref/@index-in-resource)}
                        },
                        element url {
                            attribute format {'html'},
                            attribute xml:lang {'bo'},
                            text {concat('/source/', $location/@key, '.html?ref-index=', $folio-ref/@index-in-resource)}
                        },
                        element url {
                            attribute format {'xml'},
                            attribute xml:lang {'en'},
                            text {concat('/translation/', $location/@key, '.xml?ref-index=', $folio-ref/@index-in-resource)}
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
            attribute count-refs { count($refs) },
            attribute start-ref { $start-ref/@cRef },
            attribute end-ref { $end-ref/@cRef },
            
            (: Collect relevant locations :)
            for $paragraph in $folio-paragraphs
            let $location-ids := (
                if($paragraph[ancestor-or-self::tei:*/preceding-sibling::tei:milestone[@xml:id]]) then
                    $paragraph/ancestor-or-self::tei:*[preceding-sibling::tei:milestone[@xml:id]][1]/preceding-sibling::tei:milestone[@xml:id][1]/@xml:id
                else 
                    $paragraph/ancestor-or-self::m:part[@id][1]/@id
                | $paragraph/descendant::tei:milestone/@xml:id
            )
            return
                $location-ids ! element location { attribute id { . } }
            ,
            
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
    
    (: Get sponsors for text :)
    let $sponsorship := $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:sponsor
    let $sponsors := $sponsors:sponsors//m:instance[@id = $sponsorship/@xml:id]/parent::m:sponsor
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'sponsors') } {
            
            $sponsors ! sponsors:sponsor(@xml:id, false(), false()),
            
            if ($include-acknowledgements) then
                
                (: Get acknowledgement for this text only :)
                sponsors:acknowledgement($sponsors, $tei)
                
                (:(\: Use the label from the entities file unless it's specified in the tei :\)
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
                    }:)
            else ()
        
        }
};

declare function translation:contributors($tei as element(tei:TEI), $include-acknowledgements as xs:boolean) as element(m:contributors) {
    
    let $contributions := $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:*[local-name(.) = ('author','editor','consultant')](:[not(@role eq 'translatorMain')]:)
    
    let $contributors := $contributors:contributors//m:instance[@id = $contributions/@xml:id]/parent::*[self::m:person | self::m:team]
    
    return
        element {QName('http://read.84000.co/ns/1.0', 'contributors')} {(
        
            $contributors,
            
            if ($include-acknowledgements) then
                
                contributors:acknowledgement($contributors, $tei)
                
            else ()
                
        )}
};

declare function translation:replace-text($source-key as xs:string) as element(m:replace-text) {
    element { QName('http://read.84000.co/ns/1.0', 'replace-text')} {
        element value {
            attribute key { '#CurrentDateTime' },
            text { format-dateTime(current-dateTime(), '[h].[m01][Pn] on [FNn], [D1o] [MNn] [Y0001]') }
        },
        element value {
            attribute key { '#canonicalHTML' },
            text { translation:canonical-html($source-key, (), ()) }
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
    let $render-status-ids := $common:environment/m:render/m:status[@type eq 'translation']/@status-id
    let $published := collection($common:tei-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/@status = $render-status-ids]
    
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
            attribute part-id { $quote-part-id },
            attribute ptr-index { functx:index-of-node($quote//tei:ptr[@type eq 'quote-ref'], $quote-ref) },
            
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
                            attribute target { string-join($ellipsis-text-stripped ! tokenize(., '[^\p{L}\p{N}]+')[normalize-space(.) gt ''] ! functx:escape-for-regex(.), '[^\p{L}\p{N}]+') },
                            
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
                                        '(^|[^\p{L}\p{N}]+)'
                                        
                                    )
                                    (: Add subsequent strings :)
                                    else (
                                    
                                        $highlight/@target,
                                        
                                        (: Ensure there's a word break, or it's the end :)
                                        '([^\p{L}\p{N}]+|$)',
                                        
                                        (: If it has an ellipsis so allow any other text in between, unless it's the last string :)
                                        if($index lt $count-highlights) then (
                                        
                                            if($highlight[@ellipsis]) then '(.*([^\p{L}\p{N}]+|$))?' else ()
                                            
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
                                        
                                        '(^|[^\p{L}\p{N}]+)'
                                        
                                    )
                                    else ()
                                    ,
                                    (: Add preceding strings :)
                                    if($index lt $count-highlights) then (
                                        
                                        (: Target string :)
                                        $highlight/@target,
                                        
                                        (: Ensure there's a word break, or it's the end :)
                                        '([^\p{L}\p{N}]+|$)',
                                        
                                        (: It has an ellipsis so allow any other text in between :)
                                        if($highlight[@ellipsis]) then '(.*([^\p{L}\p{N}]+|$))?' else ()
                                        
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

declare function translation:cache-key($tei as element(tei:TEI), $archive-path as xs:string?){
    let $tei-timestamp := tei-content:last-modified($tei)
    let $entities-timestamp := entities:last-modified()
    where $tei-timestamp instance of xs:dateTime and $entities-timestamp instance of xs:dateTime
    return 
        lower-case(
            string-join((
                $archive-path[. gt ''] ! replace(., '[^a-zA-Z0-9]', '-'),
                $tei-timestamp ! format-dateTime(., "[Y0001]-[M01]-[D01]-[H01]-[m01]-[s01]"),
                $entities-timestamp ! format-dateTime(., "[Y0001]-[M01]-[D01]-[H01]-[m01]-[s01]"),
                $common:app-version ! replace(., '\.', '-')
            ),'-')
        )
};

declare function translation:href($source-key as xs:string, $part-id as xs:string?, $commentary-id as xs:string?, $url-parameters as xs:string*, $fragment as xs:string?) as xs:string {
    translation:href($source-key, $part-id, $commentary-id, $url-parameters, $fragment, ())
};

declare function translation:href($source-key as xs:string, $part-id as xs:string?, $commentary-id as xs:string?, $url-parameters as xs:string*, $fragment as xs:string?, $host as xs:string?) as xs:string {
    concat($host, '/', string-join(('translation', $source-key, ($part-id, $commentary-id[. gt ''] ! '')[1], $commentary-id), '/'), string-join($url-parameters[. gt ''], '&amp;')[. gt ''] ! concat('?', .), $fragment ! concat('#', .))
};

