xquery version "3.1";

module namespace outline="http://read.84000.co/outline";

declare namespace o = "http://www.tbrc.org/models/outline";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace section="http://read.84000.co/section" at "section.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";
import module namespace functx="http://www.functx.com";

(:
declare variable $outline:outlines := collection($common:outlines-path);
declare variable $outline:kangyur := collection($common:outlines-path)//o:outline[@RID eq "O1JC11494"];

declare function outline:outline() {
    
    <outline xmlns="http://read.84000.co/ns/1.0" outlines-path="{ $common:outlines-path }">
        <section id="lobby" parent-id="">
            <title xml:lang="en">{ data($outline:outlines/o:outline[@RID = 'lobby']/o:title) }</title>
            <contents>{ $outline:outlines/o:outline[@RID = 'lobby']/o:description[@type = "contents"]/node()  }</contents>
            <sections>
            {
                for $section in $outline:outlines/o:outline[@RID = 'lobby']/o:node
                return
                    <section id="{ $section/@RID }"/>
            }
            </sections>
        </section>
        <section id="all-translated" parent-id="">
            <title xml:lang="en">{ data($outline:outlines/o:outline[@RID = 'all-translated']/o:title) }</title>
            <contents>{ $outline:outlines/o:outline[@RID = 'all-translated']/o:description[@type = "contents"]/node()  }</contents>
            <sections>
            {
                for $section in $outline:outlines/o:outline[@RID = 'all-translated']/o:node
                return
                    <section id="{ $section/@RID }"/>
            }
            </sections>
        </section>
        {
            for $section in $outline:outlines/o:outline | $outline:outlines/o:outline//o:node[@type = "section" or @type = "text"]
            return
                if($section/o:node[@type = ("section", "text", "chapter")]) then
                    <section id="{ $section/@RID }" parent-id="{ $section/../@RID }">
                        <title xml:lang="en">
                        { 
                            section:title($section, 'en')
                        }
                        </title>
                        { 
                            section:ancestors($section, 1)
                        }
                        <contents>
                        { 
                            $section/o:description[@type = "contents"]/node() 
                        }
                        </contents>
                        <sections>
                        {
                            for $section in $section/o:node[@type = "section"]
                            return
                                <section id="{ $section/@RID }"/>
                        }
                        </sections>
                        <texts 
                            count-child-texts="{ section:count-child-texts($section) }" 
                            count-descendant-texts="{ section:count-descendant-texts($section) }" 
                            count-descendant-translated="{ section:count-descendant-translated($section) }"
                            count-descendant-inprogress="{ section:count-descendant-inprogress($section) }">
                        {
                            for $text in $section/o:node[@type = "text"] | $section/o:node[@type = "chapter"]
                            return
                                <child-text type="{ $text/@type }" id="{ $text/@RID }" count-chapters="{ count($text/o:node[@type = "chapter"]) }"/>
                        }
                        </texts>
                    </section>
                else 
                    ()
            }
    </outline>
};

declare variable $outline:text-statuses := doc(concat($common:data-path, '/operations/config.xml'))/m:operations-config/m:text-statuses;

declare function outline:text-statuses($group as xs:string, $selected as xs:string*) as node() {
    <text-statuses xmlns="http://read.84000.co/ns/1.0" >
    {
        for $status in 
            if($group gt '') then
                $outline:text-statuses/m:status[@group eq $group]
            else
                $outline:text-statuses/m:status
        return 
            element { 'status' } 
            { 
                $status/@*,
                if ($status/@status-id = $selected) then attribute { 'selected' } { 'selected' } else '',
                $status/text()
                
            }
    }
    </text-statuses>
};

declare function outline:summary() as node() {

    let $operations-texts := doc(concat($common:data-path, '/operations/texts.xml'))/m:texts
    let $published-statuses := outline:text-statuses('published', ())/m:status/@status-id
    let $translated-statuses := outline:text-statuses('translated', ())/m:status/@status-id
    let $in-translation-statuses := outline:text-statuses('in-translation', ())/m:status/@status-id
    
    let $all-texts := 
        for $text in $outline:kangyur//o:node[@type = ("text", "chapter")][not(o:node[@type = "chapter"])]
            let $toh := outline-text:toh($text)
            let $operations-text := $operations-texts/m:text[@toh eq $toh/text()][1]
        return
            <text xmlns="http://read.84000.co/ns/1.0">
                { outline-text:location($text, $outline:kangyur) }
                { $operations-text }
            </text>
    
    let $all-text-count := count($all-texts)
    let $published-text-count := count($all-texts[m:text/@status = $published-statuses])
    let $translated-text-count := count($all-texts[m:text/@status = $translated-statuses])
    let $in-translation-text-count := count($all-texts[m:text/@status = $in-translation-statuses])
    let $commissioned-text-count := count($all-texts[m:text/@status gt ''])
    let $sponsored-text-count := count($all-texts[m:text/@sponsored = ('full', 'part')])
    let $not-started-text-count := $all-text-count - $commissioned-text-count
    
    let $all-page-count := 
        sum(
            for $count in $outline:kangyur//o:volumes/o:volume/@count-pages
            return $count - $outline:kangyur//o:volumes/@title-pages-per-volume
        )
    let $published-page-count := sum($all-texts[m:text/@status = $published-statuses]/m:location[@count-pages != '?']/@count-pages)
    let $translated-page-count := sum($all-texts[m:text/@status = $translated-statuses]/m:location[@count-pages != '?']/@count-pages)
    let $in-translation-page-count := sum($all-texts[m:text/@status = $in-translation-statuses]/m:location[@count-pages != '?']/@count-pages)
    let $commissioned-page-count := sum($all-texts[m:text/@status  gt '']/m:location[@count-pages != '?']/@count-pages)
    let $sponsored-page-count := sum($all-texts[m:text/@sponsored = ('full', 'part')]/m:location[@count-pages != '?']/@count-pages)
    let $not-started-page-count := $all-page-count - $commissioned-page-count
    
    return 
        <summary xmlns="http://read.84000.co/ns/1.0">
            <texts 
                count="{ $all-text-count }" 
                published="{ $published-text-count }" 
                translated="{ $translated-text-count }" 
                in-translation="{ $in-translation-text-count }" 
                sponsored="{ $sponsored-text-count }" 
                commissioned="{ $commissioned-text-count }" 
                not-started="{ $not-started-text-count }"/>
            <pages 
                count="{ $all-page-count }" 
                published="{ $published-page-count }" 
                translated="{ $translated-page-count }" 
                in-translation="{ $in-translation-page-count }" 
                sponsored="{ $sponsored-page-count }" 
                commissioned="{ $commissioned-page-count }" 
                not-started="{ $not-started-page-count }"/>
        </summary>
};

declare function outline:texts($status as xs:string*, $sort as xs:string, $range as xs:string, $filter as xs:string) as node() {

    let $operations-texts := doc(concat($common:data-path, '/operations/texts.xml'))/m:texts
    
    let $all-texts := 
        for $text in $outline:kangyur//o:node[@type = ("text", "chapter")][not(o:node[@type = "chapter"])]
            let $toh := outline-text:toh($text)
            let $operations-text := $operations-texts/m:text[@toh eq $toh/text()][1]
        return
            <text xmlns="http://read.84000.co/ns/1.0" type="{ $text/@type }" id="{ $text/@RID }">
                { $toh }
                { outline-text:titles($text) }
                { outline-text:location($text, $outline:kangyur) }
                { outline-text:status($text) }
                { $operations-text }
            </text>
    
    let $status-texts := 
        if(count($status) eq 0 or (count($status) eq 1 and $status[1] eq '')) then
            $all-texts
        else if(count($status) eq 1 and $status[1] eq '0') then 
            $all-texts[not(m:text/@status) or m:text/@status eq '']
        else
            $all-texts[m:text/@status = $status]
    
    let $page-size-ranges :=
        <page-size-ranges xmlns="http://read.84000.co/ns/1.0">
            <range id="1" min="0" max="99"/>
            <range id="2" min="100" max="149"/>
            <range id="3" min="150" max="199"/>
            <range id="4" min="200" max="10000"/>
        </page-size-ranges>
        
    let $selected-range := $page-size-ranges//m:range[xs:string(@id) eq $range]
    
    let $range-texts := 
        if($selected-range) then
            $status-texts[m:location/@count-pages[. >= xs:integer($selected-range/@min)][. <= xs:integer($selected-range/@max)]]
        else
            $status-texts
    
    let $texts := 
        if($filter eq 'sponsored')then
            $range-texts[m:text/@sponsored = ('full', 'part')]
        else if($filter eq 'fully-sponsored')then
            $range-texts[m:text/@sponsored = ('full')]
        else if($filter eq 'part-sponsored')then
            $range-texts[m:text/@sponsored = ('part')]
        else if($filter eq 'not-sponsored')then
            $range-texts[not(m:text/@sponsored) or m:text/@sponsored eq '']
        else
            $range-texts
            
    let $texts-count := count($texts)
    let $texts-pages-count := sum($texts/m:location/@count-pages)
    
    return 
        <progress xmlns="http://read.84000.co/ns/1.0">
            {
                $page-size-ranges
            }
            <texts 
                count="{ $texts-count }" 
                count-pages="{ $texts-pages-count }"  
                sort="{ $sort }" 
                range="{ $range }" 
                filter="{ $filter }">
            { 
                if($sort = ('toh', '')) then
                    for $text in $texts
                        order by if($text/m:toh/@number eq '0') then 1 else 0, xs:integer($text/m:toh/@number), $text/text()
                    return $text
                else if($sort eq 'status') then
                    for $text in $texts
                        order by if ($text/m:text/@status gt '') then $text/m:text/@status else '4'
                    return $text
                else if($sort eq 'longest') then
                    for $text in $texts
                        order by xs:integer($text/m:location/@count-pages) descending
                    return $text
                else if($sort eq 'shortest') then
                    for $text in $texts
                        order by xs:integer($text/m:location/@count-pages)
                    return $text
                else
                    $texts
            }
            </texts>
        </progress>
};

declare function outline:volumes(){

    let $title-pages := 3
    let $ekangyur := collection('/db/apps/eKangyur/data')
    return
        <outline:volumes title-pages-per-volume="{ $title-pages }" >
        {
            for $doc in $ekangyur//tei:TEI
            let $ekangyur-id := $doc//tei:publicationStmt//tei:idno[@type = 'TBRC_TEXT_RID']/text()
            let $title := $doc//tei:titleStmt/tei:title/text() 
            let $volume := xs:integer(substring-before(substring-after($title, '['),']'))
            let $count-pages := max($doc//tei:p/@n)
            order by $volume
            return 
                <outline:volume 
                    number="{ $volume }" 
                    count-pages="{ $count-pages }" 
                    ekangyur-id="{ $ekangyur-id  }" >
                    { $title }
                </outline:volume>
        }
        </outline:volumes>
  
};
:)
