xquery version "3.1";

module namespace outline-text="http://read.84000.co/outline-text";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace o = "http://www.tbrc.org/models/outline";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace section="http://read.84000.co/section" at "section.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";

declare function outline-text:translation-id($text as node()) as xs:string* {
    $text/o:node[@type eq 'translation']/o:description[@type = 'text']/text()
};

declare function outline-text:translation($translation-id as xs:string, $outlines) as node()* {
    $outlines//o:node
        [@type = 'text']
        [
            o:node[@type = 'translation']
            [
                o:description[@type = 'text'][text() eq $translation-id]
            ]
        ]
        [1]
};

declare function outline-text:section($text-id as xs:string, $outlines) as node()* {
    
    let $nodes := 
        $outlines//o:node[@type = 'section'][o:node[@type = 'text']/o:node[@type = 'translation']/o:description[@type = 'text'][. = $text-id]]
        | $outlines//o:node[@type = 'section'][o:node[@type = 'text']/o:node[@type = 'chapter']/o:node[@type = 'translation']/o:description[@type = 'text'][. = $text-id]]
    
    return 
        if(count($nodes) > 0) then
            $nodes[1]
        else
            ()

};

declare function outline-text:translation-exists($resource-id as xs:string) as xs:boolean {

    exists(collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key eq lower-case($resource-id)])
    
};

declare function outline-text:titles($text as item()) as node() {

    <titles xmlns="http://read.84000.co/ns/1.0">
        <title xml:lang="en">
        { 
            $text/o:title[@lang = 'english'][not(@type) or @type = 'bibliographicalTitle'][1]/text()  
        }
        </title>
        <title xml:lang="bo">
        { 
            let $bo-ltn := $text/o:title[not(@lang) or @encoding eq "extendedWylie"][1]/text()
            return 
                if($bo-ltn) then
                    common:bo-title($bo-ltn)
                else
                    $text/o:title[@lang eq 'tibetan'][1]/text()
        }
        </title>
        <title xml:lang="bo-ltn">
        { 
            $text/o:title[not(@lang) or @encoding eq "extendedWylie"][1]/text() 
        }
        </title>
        <title xml:lang="sa-ltn">
        { 
            $text/o:title[@lang eq 'sanskrit'][1]/text() 
        }
        </title>
        { 
            if($text/@type = 'chapter') then
                <parent>
                {
                    outline-text:titles($text/..)
                }
                </parent>
            else
                ()
        }
    </titles>

};

declare function outline-text:toh-number($toh as xs:string) as xs:integer {
    number(
        replace(
            replace(
                replace($toh, '\-.+', '') (: Remove after - :)
            , '\(.+\)', '')                     (: Remove brackets :)
        , '[^0-9]', '')                         (: Remove non numeric :)
    )                                           (: Cast as number :)
};

declare function outline-text:toh($text as item()) as node() {

    let $toh-str := 
        normalize-space((
            $text/o:description/o:node/o:description[@type eq 'toh']/text()
             | $text/o:description[@type eq 'toh']/text()
             | $text/o:description[contains(., 'toh number')]/text()
        )[1])
    
    let $tohs := 
        if(contains($toh-str, '/')) then
            tokenize($toh-str, '/')
        else
            tokenize($toh-str, '\+')
    
    let $toh-first := 
        if(count($tohs))then
            $tohs[1]
        else
            $toh-str
    
    let $toh-base := 
        lower-case(
            replace(
                replace(
                    replace(
                        replace(
                            replace($toh-first, '[^0-9a-zA-Z\s\-\(\)]', '')         (: Remove all other characters :)
                        , '(\d+)([a-zA-Z]*)\s*\((\d+)([a-zA-Z]*)\)', '$1$2-$3$4')   (: Format into na-na :)
                    , '^0+', '')                                                    (: Remove leading zeros :)
                , '\-0+', '-')                                                      (: Remove zeros following - :)
           , '\s', '')                                                              (: Remove spaces :)
        )
    
    let $toh-number := outline-text:toh-number($toh-first)
    
    let $toh-base := 
        if($toh-number ge 846 and $toh-number le 1108)then
            xs:string($toh-number)
        else
            $toh-base
    
    let $toh-numbers := 
        for $toh-i in $tohs
            let $toh-i-number := outline-text:toh-number($toh-i)
            order by $toh-i-number
        return
            if($toh-i-number gt 0)then
                $toh-i-number
            else
                ()
    
    let $group := 
        if(count($toh-numbers) gt 1 and contains($toh-str, '/')) then
            string-join($toh-numbers, '/')
        else
            $toh-base
    
    let $toh-full := 
        for $toh at $toh-pos in $tohs
            return
                if($toh-pos eq 1) then
                    $toh-base
                else if(contains($toh-str, '/')) then
                    concat(' / ', $toh)
                else
                    concat(' + ', $toh)
    
    return
        <toh xmlns="http://read.84000.co/ns/1.0" 
            number="{ $toh-number }" 
            base="{ $toh-base }" 
            group="{ $group }" 
            source="{ $toh-str }">
        { 
            $toh-full
        }
        </toh>
};

declare function outline-text:title-variants($text as item()) as node()* {
    
    let $titles := outline-text:titles($text)
    let $variants := $text/o:title[not(text() = $titles/m:title/text())]
    
    return
        if($variants) then
            <title-variants  xmlns="http://read.84000.co/ns/1.0">
            {
                for $variant in $variants
                return 
                    <title xml:lang="{ common:xml-lang($variant) }">{ $variant/text() }</title> 
            }
            </title-variants>
        else
            ()
        
};

declare function outline-text:status($text as item()) as node() {
    <outline-status 
        xmlns="http://read.84000.co/ns/1.0"
        translation-id="{ outline-text:translation-id($text) }">
    { 
        outline-text:status-str($text) 
    }
    </outline-status >
};

declare function outline-text:status-str($text as item()) as xs:string* {
    
    switch ($text/o:node[@type = 'translation']/o:description[@type = 'status']/text()) 
        case "completed" 
            return 
                if(outline-text:translation-exists(concat('toh', outline-text:toh($text)/text()))) then 
                    "available" 
                else 
                    "missing"
        case "inProcess" 
            return
                "in-translation"
        default 
            return
                "not-started" 
    
};

declare function outline-text:ancestors($text as item()*) {
    
    let $text-id := outline-text:translation-id($text)
    let $outlines := collection($common:outlines-path)
    let $parent := outline-text:section($text-id, $outlines)
    return
        if($parent/@RID) then
            <parent xmlns="http://read.84000.co/ns/1.0" id="{ $parent/@RID }" nesting="1">
                <title xml:lang="en">{ section:title($parent, "en") }</title>
                { 
                    section:ancestors($parent, 2) 
                }
            </parent>
        else
            ()
    
};

declare function outline-text:location($text as item(), $outline as node()) as node()* {
    
    let $title-pages-per-volume := $outline//o:volumes/@title-pages-per-volume
    let $start := $text/o:location[not(@type) or @type = "page"][1]
    let $end := $text/o:location[not(@type) or @type = "page"][2]
    let $start-vol := xs:integer($start/@vol)
    let $end-vol := xs:integer($end/@vol)
    let $start-page := if($start/@page) then xs:integer($start/@page) else 0  
    let $start-page-adjusted := $start-page - $title-pages-per-volume
    let $end-page := if($end/@page) then xs:integer($end/@page) else 0 
    let $end-page-adjusted := $end-page - $title-pages-per-volume
    
    let $end-page-cumulative := 
        if($start-vol < $end-vol) then
            sum(
                for $count in $outline//o:volumes/o:volume[xs:integer(@number) > ($start-vol - 1)][xs:integer(@number) < ($end-vol)]/@count-pages
                return $count - $title-pages-per-volume
            ) + $end-page-adjusted
        else
            $end-page-adjusted
    
    let $count-pages := xs:integer($end-page-cumulative - ($start-page-adjusted - 1))
    
    return
        <location xmlns="http://read.84000.co/ns/1.0" count-pages="{ $count-pages }">
            <start volume="{ $start-vol }" page="{ $start-page }"/>
            <end volume="{ $end-vol }" page="{ $end-page }"/>
        </location>
    
};

declare function outline-text:text($text as item()*, $translated as xs:boolean, $ancestors as xs:boolean) {
    
    let $toh := outline-text:toh($text)
    let $resource-id := concat('toh', lower-case($toh/@base))
    let $status-str := outline-text:status-str($text) 
    
    let $translation := 
        if ($status-str eq 'completed' and $resource-id) then
            translation:tei($resource-id)
        else
            ()
    
    let $toh-key := 
        if ($translation) then
            translation:toh-key($translation, $resource-id)
        else
            ''
    
    return
        <text xmlns="http://read.84000.co/ns/1.0" type="{ $text/@type }" resource-id="{ $resource-id }">
        {
            outline-text:titles($text)
        }
        {
            outline-text:title-variants($text)
        }
        {
            if($ancestors) then
                outline-text:ancestors($text)
            else
                ()
        }
        { 
            $toh 
        }
        { 
            if ($translation) then
                translation:summary($translation)
            else
                <summary>
                {
                    $text/o:node[@type = 'translation']/o:description[@type = 'summary']/text() 
                }
                </summary>
        }
        <outline-status>
        {
            $status-str
        }
        </outline-status>
        <chapters boolean="{$ancestors}">
            {
                let $chapters := 
                    if($translated) then
                        $text/o:node[@type = "chapter"][./o:node[@type = 'translation']/o:description[@type = 'status']/text() eq 'completed']
                    else
                        $text/o:node[@type = "chapter"]
                    
                for $chapter in $chapters
                return
                    outline-text:text($chapter, $translated, $ancestors)
            }
        </chapters>
        {
            if($translation and $toh-key) then
                translation:downloads($translation, $toh-key)
            else
                ()
        }
        </text>
};

