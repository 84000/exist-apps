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
import module namespace functx = "http://www.functx.com";

(: 
    View modes hold attributes that determine the display. 
    Some displays require more data 
:)
declare variable $translation:view-modes := 
    <view-modes xmlns="http://read.84000.co/ns/1.0">
      <view-mode id="default"           client="browser"  layout="full"            glossary="use-cache"       parts="count-sections"/>,
      <view-mode id="editor"            client="browser"  layout="expanded"        glossary="defer-no-cache"  parts="all"/>,
      <view-mode id="annotation"        client="browser"  layout="expanded-fixed"  glossary="defer"           parts="all"/>,
      <view-mode id="txt"               client="none"     layout="expanded-fixed"  glossary="suppress"        parts="all"/>,
      <view-mode id="ebook"             client="ebook"    layout="expanded-fixed"  glossary="use-cache"       parts="all"/>,
      <view-mode id="pdf"               client="none"     layout="expanded-fixed"  glossary="suppress"        parts="all"/>,
      <view-mode id="app"               client="app"      layout="expanded-fixed"  glossary="use-cache"       parts="all"/>,
      <view-mode id="tests"             client="none"     layout="expanded-fixed"  glossary="suppress"        parts="all"/>,
      <view-mode id="glossary-editor"   client="none"     layout="expanded-fixed"  glossary="no-cache"        parts="all"/>,
      <view-mode id="ajax-part"         client="ajax"     layout="part-only"       glossary="use-cache"       parts="part"/>,
      <view-mode id="passage"           client="ajax"     layout="part-only"       glossary="use-cache"       parts="passage"/>,
      <view-mode id="passage-no-cache"  client="ajax"     layout="part-only"       glossary="no-cache"        parts="passage"/>
    </view-modes>;

declare function translation:titles($tei as element(tei:TEI)) as element() {
    element {QName('http://read.84000.co/ns/1.0', 'titles')} {
        tei-content:title-set($tei, 'mainTitle')
    }
};

declare function translation:long-titles($tei as element(tei:TEI)) as element() {
    element {QName('http://read.84000.co/ns/1.0', 'long-titles')} {
        tei-content:title-set($tei, 'longTitle')
    }
};

declare function translation:title-variants($tei as element(tei:TEI)) as element() {
    element {QName('http://read.84000.co/ns/1.0', 'title-variants')} {
        for $title in $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[not(@type eq 'mainTitle')]
        return
            element {QName('http://read.84000.co/ns/1.0', 'title')} {
                attribute xml:lang {$title/@xml:lang},
                normalize-space($title/text())
            }
    }
};

declare function translation:publication($tei as element(tei:TEI)) as element() {
    let $fileDesc := $tei/tei:teiHeader/tei:fileDesc
    return
        element {QName('http://read.84000.co/ns/1.0', 'publication')} {
            element contributors {
                for $contributor in $fileDesc/tei:titleStmt/tei:author[@role eq 'translatorMain']
                return
                    element summary {
                        $contributor/@ref,
                        common:normalize-space($contributor/node())
                    }
                ,
                for $contributor in $fileDesc/tei:titleStmt/tei:author[not(@role eq 'translatorMain')] | $fileDesc/tei:titleStmt/tei:editor | $fileDesc/tei:titleStmt/tei:consultant
                return
                    element {local-name($contributor)} {
                        $contributor/@role,
                        $contributor/@ref,
                        normalize-space($contributor/text())
                    }
            },
            element sponsors {
                for $sponsor in $fileDesc/tei:titleStmt/tei:sponsor
                return
                    element sponsor {
                        $sponsor/@ref,
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

declare function translation:toh-key($tei as element(tei:TEI), $resource-id as xs:string) as xs:string {
    
    let $bibl := tei-content:source-bibl($tei, $resource-id)
    
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
    normalize-space(string-join($bibl/tei:ref//text(), ' +'))
};

declare function translation:toh($tei as element(tei:TEI), $resource-id as xs:string) as element() {

    (: Returns a toh meta-data for sorting grouping  :)
    let $bibl := tei-content:source-bibl($tei, $resource-id)
    let $bibls := $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl
    let $toh-str := translation:toh-str($bibl)
    let $full := translation:toh-full($bibl)
    
    return
        element {QName('http://read.84000.co/ns/1.0', 'toh')} {
            attribute key {$bibl/@key},
            attribute number {replace($toh-str, '^(\d+)([a-zA-Z]*)\-*(\d*)([a-zA-Z]*)', '$1')},
            attribute letter {replace($toh-str, '^(\d+)([a-zA-Z]*)\-*(\d*)([a-zA-Z]*)', '$2')},
            attribute chapter-number {replace($toh-str, '^(\d+)([a-zA-Z]*)\-*(\d*)([a-zA-Z]*)', '$3')},
            attribute chapter-letter {replace($toh-str, '^(\d+)([a-zA-Z]*)\-*(\d*)([a-zA-Z]*)', '$4')},
            element base {$toh-str},
            element full {$full},
            
            let $count-bibls := count($bibls)
                where $count-bibls gt 1
            
            return
                
                let $duplicates :=
                for $sibling in $bibls[@key ne $bibl/@key]
                return
                    element duplicate {
                        attribute key {$sibling/@key},
                        element base {translation:toh-str($sibling)},
                        element full {translation:toh-full($sibling)}
                    }
                
                return
                    element duplicates {
                        $duplicates,
                        element full {
                            concat('Toh ', string-join(($toh-str, $duplicates/m:base/text()), ' / '))
                        }
                    }
        }
};

declare function translation:location($tei as element(tei:TEI), $resource-id as xs:string) as element() {
    let $bibl := tei-content:source-bibl($tei, $resource-id)
    return
        tei-content:location($bibl)
};

declare function translation:filename($tei as element(tei:TEI), $resource-id as xs:string) as xs:string {
    
    (: Generate a filename for a text :)
    
    let $toh-key := lower-case(translation:toh-key($tei, $resource-id))
    let $title :=
    replace(
        common:normalized-chars(
            lower-case(
                tei-content:title($tei) (: get title :)
            )                           (: convert to lower case :)
        )                               (: remove diacritics :)
    , '[^a-zA-Z0-9\s]', ' ')            (: remove non-alphanumeric, except spaces :)
    
    let $file-title :=  concat($toh-key, '_', '84000', ' ', $title)
    let $filename :=    replace($file-title, '\s+', '-') (: convert spaces to hyphen :)
    return
        $filename

};

declare function translation:relative-html($resource-id as xs:string, $condition as xs:string?) as xs:string {

    concat('/translation/', $resource-id, '.html', if($condition gt '') then concat('?id=', $condition) else '')
    
};

declare function translation:local-html($resource-id as xs:string) as xs:string {

    concat($common:environment/m:url[@id eq 'reading-room'], translation:relative-html($resource-id, ()))
    
};

declare function translation:canonical-html($resource-id as xs:string, $condition as xs:string?) as xs:string {

    (: This must point to the distribution server - files generated on other servers must point to the canonical page :)
    concat('https://read.84000.co', translation:relative-html($resource-id, $condition))
    
};

declare function translation:downloads($tei as element(tei:TEI), $resource-id as xs:string, $include as xs:string) as element() {
    
    let $file-name := translation:filename($tei, $resource-id)
    let $tei-version := tei-content:version-str($tei)
    let $text-id := tei-content:id($tei)
    
    return
        element {QName('http://read.84000.co/ns/1.0', 'downloads')} {
        
            attribute tei-version {$tei-version},
            attribute resource-id {$resource-id},
            
            for $type in ('html', 'pdf', 'epub', 'azw3', 'rdf', 'cache')
            
            let $resource-id :=
                if ($type eq 'cache') then
                    $text-id
                else
                    $resource-id
            
            let $stored-version :=
                if ($type eq 'html') then
                    $tei-version
                else
                    download:stored-version-str($resource-id, $type)
            
            let $path :=
                if ($type = ('html', 'cache')) then
                    '/translation'
                else
                    '/data'
            
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
                    if(not($type = ('html', 'cache'))) then (
                        attribute download-url { concat($path, '/', $file-name, '.', $type) },
                        attribute filename { $file-name }
                    )
                    else ()
                }
        }
};

declare function translation:parts($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?) as element(m:part)* {
    
    (: Get the parts of a translation :)
    
    let $passage-id :=
        if($view-mode[@parts eq 'all']) then
            'all'
        else if( $view-mode[@parts eq 'count-sections'] and count($tei/tei:text/tei:body/tei:div[@type eq 'translation']/tei:div[@type = ('section', 'chapter')]) le 1) then
            'all'
        else
            $passage-id
    
    (: Get the status so we can evaluate the render status :)
    let $status-id := tei-content:translation-status($tei)
    
    return (
    
        (: Always include summary :)
        translation:summary($tei, $passage-id, $view-mode, ''),
        
        (: Only include these parts if the text has a render status :)
        if($common:environment/m:render-translation/m:status[@status-id = $status-id]) then (
            
            translation:acknowledgment($tei, $passage-id, $view-mode),
            
            translation:preface($tei, $passage-id, $view-mode),
            
            translation:introduction($tei, $passage-id, $view-mode),
            
            translation:body($tei, $passage-id, $view-mode),
            
            translation:appendix($tei, $passage-id, $view-mode),
            
            translation:abbreviations($tei, $passage-id, $view-mode),
            
            translation:end-notes($tei, $passage-id, $view-mode),
            
            translation:bibliography($tei, $passage-id, $view-mode),
            
            translation:glossary($tei, $passage-id, $view-mode)
            
        )
        else ()
    )
};

declare function translation:part($part as element(tei:div)?, $render as xs:string, $type as xs:string, $prefix as xs:string, $label as node()*, $passage-id as xs:string?) as element(m:part) {
    local:part($part, $render, $type, $prefix, $label, $passage-id, 0, 1)
};

declare function local:part($part as element(tei:div)?, $render as xs:string, $type as xs:string, $prefix as xs:string?, $label as node()*, $passage-id as xs:string?, $nesting as xs:integer, $section-index as xs:integer) as node()* {
    
    (: Get heading :)
    let $titles := local:part-title($part, $type, $label)
    
    return
        
        (: Return a section :)
        if ($titles) then
            element {QName('http://read.84000.co/ns/1.0', 'part')} {
                attribute type { $type },
                attribute id { ($part/@xml:id, $type)[1] },
                attribute nesting { $nesting },
                attribute section-index { $section-index },
                attribute render { $render },
                if($prefix) then
                    attribute prefix { $prefix }
                else (),
                if($type = ('summary', 'introduction', 'translation', 'appendix', 'glossary')) then
                    attribute glossarize { 'true' }
                else (),
                
                $titles,
                
                local:part-content($part, $render, $type, (), $passage-id, $nesting, $section-index)
            }
            
        (: If there's no header - move down the tree without adding a section :)
        else
            local:part-content($part, $render, $type, (), $passage-id, $nesting - 1, $section-index)

};

declare function local:part-title($part as element(tei:div)?, $type as xs:string, $label as node()*) as element()* {
    
    let $chapter-title := $part/tei:head[@type eq 'chapterTitle'][text()][1]
    let $section-title := $part/tei:head[@type eq $part/@type][text()][1]
    
    return
        if ($chapter-title) then (
            element {QName('http://www.tei-c.org/ns/1.0', 'head')} {
                attribute type { $type },
                attribute tid { $chapter-title/@tid },
                $chapter-title/text()
            },
            if ($section-title) then
                element {QName('http://read.84000.co/ns/1.0', 'title-supp')} {
                    $section-title/@tid,
                    $section-title/text()
                }
            else ()
        )
        else if ($section-title) then
            element {QName('http://www.tei-c.org/ns/1.0', 'head')} {
                attribute type { $type },
                attribute tid { $section-title/@tid },
                $section-title/text()
            }
        else if ($label) then
            element {QName('http://www.tei-c.org/ns/1.0', 'head')} {
                attribute type { $type },
                $label
            }
         else ()
};

declare function local:part-content($content as element(tei:div)?, $render as xs:string, $type as xs:string, $prefix as xs:string?, $passage-id as xs:string?, $nesting as xs:integer, $section-index as xs:integer) as node()* {

    (: No structure in end-notes :)
    if($type eq 'end-notes' and $render = ('persist', 'show', 'collapse', 'hide')) then
        $content
    
    (: No structure in glossary :)
    else if($type eq 'glossary' and $render = ('persist', 'show', 'collapse', 'hide')) then
        $content
    
    else
        (: Parse <div/>s to return structure and content where required :)
        for $node at $node-index in $content/*
        return
            
            (: It's a section - create a new section :)
            if ($node[self::tei:div[@type = ('chapter', 'section')]]) then
                
                let $section-index := functx:index-of-node($content/tei:div[@type = ('chapter', 'section')], $node)
                return
                    local:part($node, $render, $node/@type, $prefix, (), $passage-id, $nesting + 1, $section-index)
            
            (: Node already included this in section-titles - so skip it :)
            else if ($node[self::tei:head[@type = ($type, 'chapterTitle', 'listBibl', 'notes')]]) then
                ()
            
            (: Full, collapsed or hidden rendering - return all nodes (except the above)  :)
            else if ($render = ('persist', 'show', 'collapse', 'hide')) then
                $node
            
            (: Passage only - return only specified node  :)
            else if ($render eq 'passage') then 
                let $passage := $node/descendant-or-self::tei:*[@tid eq substring-after($passage-id, 'node-')]
                return
                if($passage) then (
                    $node/ancestor-or-self::*[preceding-sibling::tei:milestone[@xml:id]][1]/preceding-sibling::tei:milestone[@xml:id][1],
                    $passage
                )
                else ()
            
            (: Partial rendering - return some nodes (except the above) :)
            else if ($render eq 'preview' and ($nesting eq 0 or $section-index eq 1)) then 
                if ($node-index le 8) then
                    if(string-length(string-join(data($node/preceding-sibling::tei:*))) lt 500) then
                        $node
                    else ()
                else ()
                
            (: 'none' or unspecified $render :)
            else ()

};

declare function local:passage-in-content($content as element()*, $passage-id as xs:string?) as element()? {
    
    if(starts-with($passage-id, 'node-')) then
        $content//tei:*[@tid eq substring-after($passage-id, 'node-')][1]
    else 
        $content//tei:*[@xml:id eq $passage-id][1]
        
};

declare function translation:summary($tei as element(tei:TEI)) as element()? {
    translation:summary($tei, 'summary', (), '')
};

declare function local:render($content as element()*, $show-ids as xs:string*, $passage-id as xs:string?, $view-mode as element(m:view-mode)?, $default as xs:string) as xs:string {
    
    (: ~ Possible values for render 
        - show          All content + show
        - collapse      All content + collapsed
        - preview       Partial content + collapsed
        - hide          All content + hidden
        - empty         No content + hidden
        - passage       Only include the passage specified by passage-id + hidden
    :)
    
    if($passage-id = $show-ids) then 
        'show'
    else if($passage-id = ('all')) then 
        'collapse'
    else if($view-mode[@parts = ('passage')]) then 
        if(local:passage-in-content($content, $passage-id)) then
            'passage'
        else
            'empty'
    else if($view-mode[@parts = ('part')]) then 
        if(local:passage-in-content($content, $passage-id)) then
            'show'
        else
            'empty'
    else if(local:passage-in-content($content, $passage-id)) then
        'show'
    else
        $default
    
};

declare function translation:summary($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?, $lang as xs:string) as element()? {
    
    let $valid-lang := common:valid-lang($lang)
    let $summary := $tei/tei:text/tei:front/tei:div[@type eq 'summary']
    
    let $summary :=
        if (not($valid-lang = ('en', ''))) then
            $summary[@xml:lang = $valid-lang]
        else
            $summary[not(@xml:lang) or @xml:lang = 'en']
    
    where $summary
    
    let $render := local:render($summary, ('summary', 'front'), $passage-id, $view-mode, 'collapse')
    
    return
        translation:part($summary, $render, 'summary', 's', text {'Summary'}, $passage-id)

};

declare function translation:acknowledgment($tei as element(tei:TEI)) as element()? {
    translation:acknowledgment($tei, 'acknowledgment', ())
};

declare function translation:acknowledgment($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?) as element()? {
    
    let $acknowledgment := $tei/tei:text/tei:front/tei:div[@type eq 'acknowledgment']
    where $acknowledgment
    
    let $render := local:render($acknowledgment, ('acknowledgment', 'front'), $passage-id, $view-mode, 'collapse')
        
    return
        translation:part($acknowledgment, $render, 'acknowledgment', 'ac', text {'Acknowledgements'}, $passage-id)
};

declare function translation:preface($tei as element(tei:TEI)) as element()? {
    translation:preface($tei, 'preface', ())
};

declare function translation:preface($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?) as element()? {
    
    let $preface := $tei/tei:text/tei:front/tei:div[@type eq 'preface']
    where $preface
    
    let $render := local:render($preface, ('preface', 'front'), $passage-id, $view-mode, 'preview')

    return
        translation:part($preface, $render, 'preface', 'pf', text {'Preface'}, $passage-id)
};

declare function translation:introduction($tei as element(tei:TEI)) as element()? {
    translation:introduction($tei, 'introduction', ())
};

declare function translation:introduction($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?) as element()? {
    
    let $introduction := $tei/tei:text/tei:front/tei:div[@type eq 'introduction']
    where $introduction
    
    let $render := local:render($introduction, ('introduction', 'front'), $passage-id, $view-mode, 'preview')

    return
        translation:part($introduction, $render, 'introduction', 'i', text {'Introduction'}, $passage-id)
};

declare function translation:body($tei as element(tei:TEI)) as element()? {
    translation:body($tei, 'body', ())
};

declare function translation:body($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?) as element()? {
    
    let $translation := $tei/tei:text/tei:body/tei:div[@type eq 'translation']
    let $head := ($translation/tei:head[@type eq 'titleMain'][text()], $translation/tei:head[@type eq 'titleHon'][text()])[1]
    let $count-chapters := count($translation/tei:div[@type = ('section', 'chapter')])
    
    where $translation
    return
        element {QName('http://read.84000.co/ns/1.0', 'part')} {
            $translation/@type,
            attribute id { 'translation' },
            attribute nesting { 0 },
            attribute section-index { 1 },
            attribute render { local:render($translation, ('body-title', 'body'), $passage-id, $view-mode, 'persist') },
            attribute glossarize { 'true' },
            attribute prefix { 'tr' },
            
            (: Title shown in the navigation :)
            element {QName('http://www.tei-c.org/ns/1.0', 'head')} {
                attribute type {'translation'},
                attribute tid {$head/@tid},
                $head/text()
            },
            
            element honoration {
                data($translation/tei:head[@type eq 'titleHon'])
            },
            element main-title {
                data($translation/tei:head[@type eq 'titleMain'])
            },
            element sub-title {
                data($translation/tei:head[@type eq 'sub'])
            },
            
            for $chapter at $section-index in $translation/tei:div[@type = ('section', 'chapter', 'prologue', 'colophon', 'homage')]
            
                let $chapter-title := $chapter/tei:head[@type = $chapter/@type][text()][1]
                let $chapter-title :=
                    if (not($chapter-title) and $count-chapters eq 1) then
                        text {'The Translation'}
                    else ()
                
                (: If there's an @prefix then let it override the chapter index :)
                let $chapter-prefix :=
                    if ($chapter[@prefix]) then $chapter/@prefix
                    else if ($chapter[@type eq 'prologue']) then 'p'
                    else if ($chapter[@type eq 'colophon']) then 'c'
                    else if ($chapter[@type eq 'homage']) then 'h'
                    else functx:index-of-node($translation/tei:div[@type = ('section', 'chapter')], $chapter)
                
                let $render-default := if($chapter/@type = ('colophon', 'homage')) then 'collapse' else 'preview'
                let $render := local:render($chapter, ($chapter/@xml:id, 'body'), $passage-id, $view-mode, $render-default)
            
            return
                local:part($chapter, $render, $chapter/@type, $chapter-prefix, $chapter-title, $passage-id, 0, $section-index)
        }

};

declare function translation:appendix($tei as element(tei:TEI)) as element()? {
    translation:appendix($tei, 'appendix', ())
};

declare function translation:appendix($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?) as element()? {
    
    let $appendix := $tei/tei:text/tei:back/tei:div[@type eq 'appendix'][1]
    let $part-title := $appendix/tei:head[@type eq 'appendix'][text()][1]
    let $main-title := $appendix/tei:head[@type eq 'titleMain'][text()][1]
    
    where $appendix
    
    let $render := local:render($appendix, ('appendix', 'back'), $passage-id, $view-mode, 'preview')

    return
        
        element { QName('http://read.84000.co/ns/1.0', 'part') } {
            $appendix/@type,
            attribute id { 'appendix' },
            attribute nesting { 0 },
            attribute section-index { 1 },
            attribute render { $render },
            attribute glossarize { 'true' },
            attribute prefix { 'ap' },
            element title-supp {
                'Appendix'
            },
            element { QName('http://www.tei-c.org/ns/1.0', 'head') } {
                attribute type { 'appendix' },
                $part-title/@tid,
                $part-title/text()
            },
            element title-text {
                $main-title/@tid,
                $main-title/text()
            },
            
            for $chapter at $chapter-index in $appendix/tei:div[@type = ('section', 'chapter', 'prologue')]
            
            (: If there's an @prefix then let it override the chapter index :)
            let $chapter-prefix :=
                if ($chapter[@prefix]) then
                    $chapter/@prefix
                else if ($chapter[@type eq 'prologue']) then
                    'p'
                else
                    functx:index-of-node($appendix/tei:div[@type = ('section', 'chapter')], $chapter)

            return
                local:part($chapter, $render, $chapter/@type, concat('ap', $chapter-prefix), (), $passage-id, 0, $chapter-index)
        }

};

declare function translation:abbreviations($tei as element(tei:TEI)) as element()? {
    translation:abbreviations($tei, 'abbreviations', ())
};

declare function translation:abbreviations($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?) as element()? {
    
    let $abbreviations := 
        element { QName('http://www.tei-c.org/ns/1.0', 'div') } {
            $tei/tei:text/tei:back/tei:div[@type eq 'notes']/tei:list[@type eq "abbreviations"]
            | $tei/tei:text/tei:back/tei:div[@type eq 'notes']/tei:div[@type eq "section"][tei:list[@type eq "abbreviations"]]
        }
    where $abbreviations//tei:list[@type eq "abbreviations"]
    
    let $render := local:render($abbreviations, ('abbreviations', 'back'), $passage-id, $view-mode, 'collapse')

    return
        translation:part($abbreviations, $render, 'abbreviations', 'ab', text {'Abbreviations'}, ())

};

declare function translation:end-notes($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?) as element()? {
    
    let $end-notes := 
        element { QName('http://www.tei-c.org/ns/1.0', 'div') } {
            $tei/tei:text//tei:note[@place eq 'end'][@xml:id]
        }
    
    where $end-notes[tei:note]
    
    let $render := local:render($end-notes, ('end-notes', 'back'), $passage-id, $view-mode, 'collapse')

    return
        translation:part($end-notes, $render, 'end-notes', 'n', text {'Notes'}, ())

};

declare function translation:bibliography($tei as element(tei:TEI)) as element()? {
    translation:bibliography($tei, 'bibliography', ())
};

declare function translation:bibliography($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?) as element()? {
    
    let $bibliography := $tei/tei:text/tei:back/tei:div[@type eq 'listBibl']
    where $bibliography//tei:bibl
    
    let $render := local:render($bibliography, ('bibliography', 'back'), $passage-id, $view-mode, 'collapse')
    
    return
        translation:part($bibliography, $render, 'bibliography', 'b', text {'Bibliography'}, ())

};

declare function translation:glossary($tei as element(tei:TEI)) as element()? {
    translation:glossary($tei, 'glossary', ())
};

declare function translation:glossary($tei as element(tei:TEI), $passage-id as xs:string?, $view-mode as element(m:view-mode)?) as element()? {
    
    let $glossary := 
        element { QName('http://www.tei-c.org/ns/1.0', 'div') } {
            $tei/tei:text/tei:back//tei:list[@type eq 'glossary']/tei:item/tei:gloss[@xml:id]
        }
    
    where $glossary[tei:gloss]
    
    let $render := 
        if($passage-id = ('glossary', 'back')) then 
            'show'
        else if($passage-id = ('all')) then 
            'collapse'
        else if($view-mode[@parts = ('passage', 'part')]) then 
            'hide'
        else
            'collapse'
    
    return
        translation:part($glossary, $render, 'glossary', 'g', text {'Glossary'}, ())

};

declare function translation:cache($tei as element(tei:TEI), $create-if-unavailable as xs:boolean?) as element(m:cache) {
    
    let $text-id := tei-content:id($tei)
    let $cache-collection := concat($common:data-path, '/', 'cache')
    let $cache-file := concat($text-id, '.cache')
    let $cache-uri := concat($cache-collection, '/', $cache-file)
    let $cache := doc($cache-uri)/m:cache
    let $cache-empty := <cache xmlns="http://read.84000.co/ns/1.0"/>
    
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

declare function translation:notes-cache($tei as element(tei:TEI), $refresh as xs:boolean?, $create-if-unavailable as xs:boolean?) as element(m:notes-cache) {
    
    let $cache := translation:cache($tei, $create-if-unavailable)
    
    return
        if($cache[m:notes-cache] and not($refresh)) then
            $cache/m:notes-cache
        else
            
            let $start-time := util:system-dateTime()
            
            let $end-notes :=
                for $note at $index in $tei/tei:text//tei:note[@place eq 'end'][@xml:id]
                    let $part := $note/ancestor::tei:div[@type][not(@type eq 'translation')][last()]
                return (
                    common:ws(2),
                    element { QName('http://read.84000.co/ns/1.0', 'end-note') } {
                        attribute id { $note/@xml:id },
                        attribute part-id { ($part/@xml:id, $part/@type)[1] },
                        attribute index { $index }
                    }
                )
            
            let $end-time := util:system-dateTime()
            
            return
                element { QName('http://read.84000.co/ns/1.0', 'notes-cache') } {
                
                    attribute timestamp { current-dateTime() },
                    attribute seconds-to-build { functx:total-seconds-from-duration($end-time - $start-time) },
                    
                    $end-notes,
                    
                    common:ws(1)
                }
};

declare function translation:milestones-cache($tei as element(tei:TEI), $refresh as xs:boolean?, $create-if-unavailable as xs:boolean?) as element(m:milestones-cache) {
    
    let $cache := translation:cache($tei, $create-if-unavailable)
    
    return
        if($cache[m:milestones-cache] and not($refresh)) then
            $cache/m:milestones-cache
        else
            
            let $start-time := util:system-dateTime()
            
            let $milestones := 
                for $part in 
                    $tei/tei:text/tei:front/tei:div[@type]
                    | $tei/tei:text/tei:body/tei:div[@type eq 'translation']/tei:div[@type]
                    | $tei/tei:text/tei:back/tei:div[@type]
                    for $milestone at $index in $part//tei:milestone[@xml:id]
                    return (
                        common:ws(2),
                        element { QName('http://read.84000.co/ns/1.0', 'milestone') } {
                            attribute id { $milestone/@xml:id },
                            attribute part-id { ($part/@xml:id, $part/@type)[1] },
                            attribute index { $index }
                        }
                    )
                    
            let $end-time := util:system-dateTime()
            
            return
                element { QName('http://read.84000.co/ns/1.0', 'milestones-cache') } {
                
                    attribute timestamp { current-dateTime() },
                    attribute seconds-to-build { functx:total-seconds-from-duration($end-time - $start-time) },
                    
                    $milestones,
                    
                    common:ws(1)
                }
};

declare function translation:folios-cache($tei as element(tei:TEI), $refresh as xs:boolean?, $create-if-unavailable as xs:boolean?) as element(m:folios-cache) {

    let $cache := translation:cache($tei, $create-if-unavailable)
    
    return
        if($cache[m:folios-cache] and not($refresh)) then
            $cache/m:folios-cache
        else
        
            let $start-time := util:system-dateTime()
            
            let $folio-refs :=
                for $bibl in $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@key]
                let $resource-id := $bibl/@key
                let $folios-for-toh := translation:folio-refs-sorted($tei, $resource-id)
                return
                    for $folio in $folios-for-toh
                    return (
                        common:ws(2),
                        element { QName('http://read.84000.co/ns/1.0', 'folio-ref') } {
                            attribute id { $folio/@xml:id },
                            attribute resource-id { $resource-id },
                            $folio/@index-in-resource,
                            $folio/@index-in-sort,
                            if($folio[@cRef-volume]) then
                                $folio/@cRef-volume
                            else ()
                        }
                    )
            
            let $end-time := util:system-dateTime()
            
            return
            element { QName('http://read.84000.co/ns/1.0', 'folios-cache') } {
            
                attribute timestamp { current-dateTime() },
                attribute seconds-to-build { functx:total-seconds-from-duration($end-time - $start-time) },
                
                $folio-refs,
                
                common:ws(1)
                
            }
};

declare function translation:glossary-cache($tei as element(tei:TEI), $refresh-ids as xs:string*, $create-if-unavailable as xs:boolean?) as element(m:glossary-cache) {
    
    let $cache := translation:cache($tei, $create-if-unavailable)
    
    return
        (: If there is one and there's nothing to refresh, just return the cache :)
        if($cache[m:glossary-cache] and count($refresh-ids) eq 0) then
            $cache/m:glossary-cache
            
        (: Build the cache :)
        else
            
            let $start-time := util:system-dateTime()
            
            (: Existing cache :)
            let $glossary-cache := $cache/m:glossary-cache
            
            (: TEI glossary items :)
            let $tei-glossary := $tei//tei:back//tei:list[@type eq 'glossary']/tei:item/tei:gloss[@xml:id]
            
            let $resource-id := translation:toh-key($tei, '')
            
            (: Glossary expressions :)
            let $glossary-expressions :=
                (: We can optimise by passing 'all' instead of all the ids :)
                if($refresh-ids = 'all') then 
                    glossary:expressions($tei, $resource-id, 'all')
                else if (count($tei-glossary[@xml:id = $refresh-ids]) gt 0) then
                    glossary:expressions($tei, $resource-id, $refresh-ids)
                else
                    ()
            
            (: Sort glossaries :)
            let $glossary-sorted :=
                for $gloss in $tei-glossary
                let $sort-term := glossary:sort-term($gloss)
                order by $sort-term/text()
                return $gloss
            
            (: Process all glossaries :)
            let $glosses :=
                for $gloss at $index in $glossary-sorted
                    let $gloss-id := $gloss/@xml:id
                group by $gloss-id
                    let $sort-term := glossary:sort-term($gloss[1])
                return 
                    (: If we processed it then add it with the new $glossary-expressions :)
                    if ($refresh-ids = 'all' or $gloss-id = $refresh-ids) then (
                        common:ws(2),
                        element { QName('http://read.84000.co/ns/1.0', 'gloss') } {
                            attribute id { $gloss-id },
                            attribute index { $index },
                            attribute timestamp { current-dateTime() },
                            $sort-term/@word-count ,
                            $sort-term/@letter-count ,
                            
                            for $location in $glossary-expressions/m:location[descendant::xhtml:*[@data-glossary-id eq $gloss-id]]
                            let $location-id := $location/@id
                            group by $location-id
                            order by $location[1]/@sort-index ! xs:integer(.)
                            return (
                                common:ws(3),
                                element location {
                                    attribute id { $location/@id }
                                }
                            ),
                            common:ws(2)
                        }
                    )
                    (: Otherwise copy the existing cache :)
                    else (
                        common:ws(2),
                        
                        let $existing-cache := $glossary-cache/m:gloss[@id eq $gloss-id]
                        return
                            element { QName('http://read.84000.co/ns/1.0', 'gloss') } {
                                attribute id { $gloss-id },
                                attribute index { $index },
                                $sort-term/@word-count ,
                                $sort-term/@letter-count ,
                                $existing-cache/@*[not(name(.) = ('id', 'index', 'word-count', 'letter-count', 'priority'))],
                                $existing-cache/node()
                            }
                            
                    )
            
            let $end-time := util:system-dateTime()
            
            return
                element { QName('http://read.84000.co/ns/1.0', 'glossary-cache') } {
                
                    attribute timestamp { current-dateTime() },
                    
                    if($refresh-ids = 'all') then
                        attribute seconds-to-build { functx:total-seconds-from-duration($end-time - $start-time) }
                    else
                        $glossary-cache/@seconds-to-build
                    ,
                    
                    $glosses,
                    
                    common:ws(1)
                }
};

declare function translation:word-count($tei as element(tei:TEI)) as xs:integer {
    let $translated-text :=
    $tei/tei:text/tei:body/tei:div[@type eq "translation"]/*[
    self::tei:div[@type = ("section", "chapter", "prologue", "homage", "colophon")]
    or self::tei:head[@type ne 'translation']
    ]//text()[normalize-space() and not(ancestor::tei:note)]
    return
        if ($translated-text and not($translated-text = '')) then
            common:word-count($translated-text)
        else
            0
};

declare function translation:glossary-count($tei as element(tei:TEI)) as xs:integer {
    count($tei/tei:text/tei:back/tei:div[@type eq 'glossary']//tei:gloss[@xml:id])
};

declare function translation:title-listing($translation-title as xs:string*) as xs:string* {
    let $first-word := substring-before($translation-title, ' ')
    return
        if (lower-case($first-word) = ('the')) then
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

declare function translation:folio-refs($tei as element(tei:TEI), $resource-id as xs:string) as element(tei:ref)* {
    
    (: Get the relevant folio refs refs :)
    translation:refs($tei, $resource-id, ('folio'))

};

declare function translation:refs($tei as element(tei:TEI), $resource-id as xs:string, $types as xs:string*) as element(tei:ref)* {
    
    (: Get the relevant refs :)
    let $toh-key := translation:toh-key($tei, $resource-id)
    return
        $tei/tei:text/tei:body//tei:ref[@type = $types][not(@rend) or not(@rend = ('hidden'))][not(@key) or @key eq $toh-key][not(ancestor::tei:note)]

};

declare function translation:folio-refs-sorted($tei as element(tei:TEI), $resource-id as xs:string) as element(tei:ref)* {
    
    (: 
        This returns a set of folios for the text with additional detail
        e.g. the volume of each folio based on its proximity to a <ref type="volume"/>
        and it's index in the folio refs.
        Based on this folio index x can be mapped to a page in a volume
        e.g. Toh340 ref-index=620 (F.3.a) can be mapped to Volume 74 page 5.
    :)
    
    (: Get the relevant refs :)
    let $refs-for-resource :=
        for $ref at $index-in-resource in translation:refs($tei, $resource-id, ('folio', 'volume'))
        return
            element {node-name($ref)} {
                $ref/@*,
                attribute index-in-resource {$index-in-resource},
                if ($ref[@type = ('volume')]) then
                    attribute sort-volume {replace($ref/@cRef, '\D', '')}
                else
                    ()
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
                else
                    0,
                    if (count($cref-tokenized) gt 1) then
                        number(replace($cref-tokenized[2], '\D', ''))
                    else
                        0,
                    if (count($cref-tokenized) gt 2) then
                        $cref-tokenized[3]
                    else
                        ''
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

declare function translation:folio-sort-index($tei as element(tei:TEI), $resource-id as xs:string, $index-in-resource as xs:integer) as xs:integer? {
    
    (: Convert the index of the folio in the resource into the index of the folio when sorted :)
    let $refs-sorted := translation:folio-refs-sorted($tei, $resource-id)
    let $ref := $refs-sorted[xs:integer(@index-in-resource) eq $index-in-resource]
    return
        xs:integer($ref/@index-in-sort)

};

declare function translation:folios($tei as element(tei:TEI), $resource-id as xs:string) as element(m:folios) {
    
    let $location := translation:location($tei, $resource-id)
    let $work := $location/@work
    let $reading-room-path := $common:environment/m:url[@id eq 'reading-room']/text()
    let $folio-refs := translation:folio-refs-sorted($tei, $resource-id)
    (:let $folio-refs := translation:folio-refs($tei, $resource-id):)
    
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
                let $folio-ref := $folio-refs[xs:integer(@index-in-sort) eq $page-in-text]
                (:let $folio-ref := $folio-refs[$page-in-text]:)
                
                return
                    element folio {
                        
                        attribute volume {$volume-number},
                        attribute page-in-volume {$page-in-volume},
                        attribute page-in-text {$page-in-text},
                        attribute ref-id {$folio-ref/@xml:id},
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

declare function translation:folio-content($tei as element(tei:TEI), $resource-id as xs:string, $index-in-resource as xs:integer) as element()* {
    
    (: Get all the <ref/>s in the doc :)
    let $refs := translation:folio-refs($tei, $resource-id)
    let $start-ref := $refs[$index-in-resource]
    let $end-ref := $refs[$index-in-resource + 1]
    
    (: Get all sections that may have a <ref/>. They must be siblings so get direct children of section. :)
    let $translation-paragraphs := $tei/tei:text/tei:body//tei:div[@type = 'translation']//tei:div[@type = ('prologue', 'homage', 'section', 'chapter', 'colophon')]/tei:*[self::tei:head | self::tei:p | self::tei:ab | self::tei:q | self::tei:lg | self::tei:list | self::tei:table | self::tei:trailer]
    
    (: Find the container of the start <ref/> and it's index :)
    let $start-ref-paragraph := $start-ref/ancestor::*[. = $translation-paragraphs][1]
    let $start-ref-paragraph-index :=
        if ($start-ref-paragraph) then
            functx:index-of-node($translation-paragraphs, $start-ref-paragraph)
        else
            0
        
        (: Find the container of the end <ref/> and it's index :)
    let $end-ref-paragraph := $end-ref/ancestor::*[. = $translation-paragraphs][1]
    let $end-ref-paragraph-index :=
        if ($end-ref-paragraph) then
            functx:index-of-node($translation-paragraphs, $end-ref-paragraph)
        else
            count($translation-paragraphs)
        
        (: Get paragraphs including and between these 2 points :)
    let $folio-paragraphs :=
        if ($start-ref-paragraph) then
            $translation-paragraphs[position() ge $start-ref-paragraph-index and position() le $end-ref-paragraph-index]
        else
            ()
        
    return
        element {QName('http://read.84000.co/ns/1.0', 'folio-content')} {
            attribute start-ref {$start-ref/@cRef},
            attribute end-ref {$end-ref/@cRef},
            
            (: Convert the content to text and <ref/>s only :)
            for $node in $folio-paragraphs//text()[not(ancestor::tei:note)] | $folio-paragraphs//tei:ref[@cRef = ($start-ref/@cRef, $end-ref/@cRef)]
            return
                (: Catch instances where the string ends in a punctuation mark. Assume a space has been dropped. Add a space to concat to the next string. :)
                if($node[self::tei:ref]) then
                    $node
                else 
                    let $text := normalize-space($node)
                    return (
                        text { $text },
                        if (substring($text, string-length($text), 1) = ('.', ',', '!', '?', '”', ':', ';')) then 
                            text { ' ' }
                        else ()
                    )
        }
};

declare function translation:sponsors($tei as element(tei:TEI), $include-acknowledgements as xs:boolean) as element() {
    
    let $translation-sponsors := $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:sponsor
    
    let $sponsor-ids := $translation-sponsors ! substring-after(./@ref, 'sponsors.xml#')
    
    let $sponsors := sponsors:sponsors($sponsor-ids, false(), false())
    
    let $acknowledgment := $tei/tei:text/tei:front/tei:div[@type eq "acknowledgment"]
    
    return
        element {QName('http://read.84000.co/ns/1.0', 'sponsors')} {
            (
            $sponsors/m:sponsor,
            if ($include-acknowledgements) then
                
                (: Use the label from the entities file unless it's specified in the tei :)
                let $sponsor-strings :=
                for $translation-sponsor in $translation-sponsors
                let $translation-sponsor-text := $translation-sponsor
                let $translation-sponsor-id := substring-after($translation-sponsor/@ref, 'sponsors.xml#')
                let $sponsor-label-text := $sponsors/m:sponsor[@xml:id eq $translation-sponsor-id]/m:label
                return
                    if ($translation-sponsor-text gt '') then
                        $translation-sponsor-text
                    else
                        if ($sponsor-label-text gt '') then
                            $sponsor-label-text
                        else
                            ()
                
                let $count-sponsor-strings := count($sponsor-strings)
                
                let $marked-paragraphs :=
                if ($acknowledgment/tei:p and $sponsor-strings) then
                    let $mark-sponsor-strings := $sponsor-strings ! normalize-space(lower-case(replace(., $sponsors:prefixes, '')))
                    return
                        common:mark-nodes($acknowledgment/tei:p, $mark-sponsor-strings, 'phrase')
                else
                    ()
                
                return
                    element tei:div {
                        attribute type {'acknowledgment'},
                        if ($marked-paragraphs/exist:match) then
                            $marked-paragraphs[exist:match]
                        else
                            if ($sponsor-strings) then
                                (
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
                            else
                                ()
                    }
            else
                ()
            )
        }
};

declare function translation:contributors($tei as element(tei:TEI), $include-acknowledgements as xs:boolean) as element() {
    
    let $translation-contributors := $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:*[self::tei:author | self::tei:editor | self::tei:consultant]
    
    let $contributor-ids := $translation-contributors ! substring-after(./@ref, 'contributors.xml#')
    
    let $contributors := $contributors:contributors/m:contributors/m:person[@xml:id = $contributor-ids]
    
    let $acknowledgment := $tei/tei:text/tei:front/tei:div[@type eq "acknowledgment"]
    
    return
        element {QName('http://read.84000.co/ns/1.0', 'contributors')} {
            (
            $contributors,
            if ($include-acknowledgements) then
                
                (: Use the label from the entities file unless it's specified in the tei :)
                let $contributor-strings :=
                for $translation-contributor in $translation-contributors
                let $contributor := $contributors[@xml:id eq substring-after($translation-contributor/@ref, 'contributors.xml#')]
                return
                    if ($translation-contributor/text()) then
                        $translation-contributor
                    else
                        $contributor/m:label
                
                let $marked-paragraphs :=
                if ($acknowledgment/tei:p and $contributor-strings) then
                    let $mark-contributor-strings := $contributor-strings ! normalize-space(lower-case(replace(., $contributors:person-prefixes, '')))
                    return
                        common:mark-nodes($acknowledgment/tei:p, $mark-contributor-strings, 'phrase')
                else
                    ()
                
                return
                    element tei:div {
                        attribute type {'acknowledgment'},
                        $marked-paragraphs[exist:match]
                    }
            
            else
                ()
            )
        }
};

declare function translation:status-updates($tei as element()) as element(m:status-updates) {
    
    element {QName('http://read.84000.co/ns/1.0', 'status-updates')} {
        
        let $translation-status := tei-content:translation-status($tei)
        let $tei-version-number-str := tei-content:version-number-str($tei)
        
        (: Returns notes of status updates :)
        for $status-update in $tei/tei:teiHeader//tei:notesStmt/tei:note[@update = ('text-version', 'translation-status')]
        let $status-update-version-number-str := replace($status-update/@value, '[^0-9\.]', '')
        return
            element {QName('http://read.84000.co/ns/1.0', 'status-update')} {
                $status-update/@update,
                $status-update/@value,
                $status-update/@date-time,
                $status-update/@user,
                attribute days-from-now {days-from-duration(xs:dateTime($status-update/@date-time) - current-dateTime())},
                if ($status-update[@update eq 'translation-status'] and $status-update[@value eq $translation-status]) then
                    attribute current-status {true()}
                else
                    ()
                ,
                if ($status-update[@update eq 'text-version'] and $status-update-version-number-str eq $tei-version-number-str) then
                    attribute current-version {true()}
                else
                    ()
                ,
                $status-update/text()
            }
    }
};

