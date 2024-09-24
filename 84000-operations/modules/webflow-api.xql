xquery version "3.1";

module namespace webflow="http://read.84000.co/webflow-api";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace section = "http://read.84000.co/section" at "../../84000-reading-room/modules/section.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace knowledgebase = "http://read.84000.co/knowledgebase" at "../../84000-reading-room/modules/knowledgebase.xql";
import module namespace functx = "http://www.functx.com";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace json="http://www.json.org";
declare namespace fn="http://www.w3.org/2005/xpath-functions";

declare variable $webflow:conf := doc(concat($common:data-path, '/local/webflow-api.xml'));
declare variable $webflow:json-serialization-parameters := 
    element { QName('http://www.w3.org/2010/xslt-xquery-serialization','serialization-parameters') }{
        element method { 
            attribute value { 'json' }
        }
    };

declare variable $webflow:html5-serialization-parameters := 
    element { QName('http://www.w3.org/2010/xslt-xquery-serialization','serialization-parameters') }{
        element method { 
            attribute value { 'html5' }
        },
        element media-type { 
            attribute value { 'text/html' }
        },
        element suppress-indentation { 
            attribute value { 'yes' }
        }
    };

declare function webflow:request($url as xs:anyURI, $method as xs:string, $request-body as element(hc:body)?) {
    
    <hc:request href="{ $url }" method="{ (upper-case($method)[. = ('GET','POST','PATCH')],'GET')[1] }">
        <hc:header name="Accept" value="application/json"/>
        <hc:header name="Content-type" value="application/json"/>
        <hc:header name="Authorization" value="{ $common:environment/eft:webflow-conf/eft:authorization/text() }"/>
        { $request-body }
    </hc:request>
    
};

declare function webflow:log-patch($item-id as xs:string){

    let $webflow-item := $webflow:conf//webflow:item[@id eq $item-id]
    let $attribute-updated := attribute updated { current-dateTime() }
    
    where $webflow-item
    return
        if($webflow-item[@updated]) then
            update replace $webflow-item/@updated with $attribute-updated
        else
            update insert $attribute-updated into $webflow-item
    
};

declare function webflow:publish-items($webflow-ids as xs:string*){

    for $item in $webflow:conf//webflow:item[@webflow-id = $webflow-ids]
    let $collection-id := $item/parent::webflow:collection/@webflow-id
    group by $collection-id
    
    let $data := 
        element data {
            $item/@webflow-id ! element itemIds {
                attribute json:array {'true'},
                string()
            }
        }
    let $request-body := <hc:body media-type="application/json" method="text">{ serialize($data, $webflow:json-serialization-parameters) }</hc:body>
    let $request := webflow:request(xs:anyURI(concat('https://api.webflow.com/v2/collections/', $collection-id, '/items/publish')), 'POST', $request-body)
    let $send-request := hc:send-request($request)
    
    return 
        $send-request[2] ! util:base64-decode(.) ! json-to-xml(.) ! fn:map ! element { 'publish-items' } { * }
        
};

declare function webflow:get-sites() as element(webflow:get-sites) {
    
    element { QName('http://read.84000.co/webflow-api','get-sites') } {
    
        try {
            
            (: curl --request GET --url https://api.webflow.com/v2/sites --header 'accept: application/json' --header 'authorization: XXX' :)
            
            let $request := webflow:request(xs:anyURI('https://api.webflow.com/v2/sites'), 'GET', ())
            
            let $send-request := hc:send-request($request)
            
            return (
                (:$request,:)
                $send-request[2] ! util:base64-decode(.) ! json-to-xml(.) ! fn:map/fn:array[@key eq 'sites']/fn:map ! element { 'site' } { * }
            )
            
        }
        catch * {
            ()
        }
    }
    
};

(: webflow:get-catalogue-sections('catalogue-sections') :)
declare function webflow:get-catalogue-sections($collection-id as xs:string) as element(webflow:get-catalogue-sections) {
    element { QName('http://read.84000.co/webflow-api','get-catalogue-sections') } {
    
        let $webflow-collection := $webflow:conf//webflow:collection[@id eq $collection-id]
        
        let $request := webflow:request(xs:anyURI(concat('https://api.webflow.com/v2/collections/', $webflow-collection/@webflow-id, '/items')), 'GET', ())
        
        let $send-request := hc:send-request($request)
        
        return (
            (:$webflow-collection,
            $request,:)
            $send-request[2] ! util:base64-decode(.) ! json-to-xml(.) ! fn:map ! element { 'catalogue-sections' } { * }
        )
        
    }
};

(: webflow:get-catalogue-section('O1JC114941JC14718') :)
declare function webflow:get-catalogue-section($section-id as xs:string) as element(webflow:get-catalogue-section) {
    
    element { QName('http://read.84000.co/webflow-api','get-catalogue-section') } {
    
        try {
            
            (: curl --request GET \
                 --url https://api.webflow.com/v2/collections/XXX/items/YYY \
                 --header 'accept: application/json' \
                 --header 'authorization: ZZZ'
            :)
            
            let $webflow-item := $webflow:conf//webflow:item[@id eq $section-id]
            let $webflow-collection := $webflow-item/parent::webflow:collection
            
            let $request := webflow:request(xs:anyURI(concat('https://api.webflow.com/v2/collections/', $webflow-collection/@webflow-id, '/items/', $webflow-item/@webflow-id)), 'GET', ())
            
            let $send-request := hc:send-request($request)
            
            return (
                (:$webflow-item,
                $request,:)
                $send-request[2] ! util:base64-decode(.) ! json-to-xml(.) ! fn:map ! element { 'catalogue-section' } { * }
            )
            
        }
        catch * {
            ()
        }
    }
    
};

(: webflow:patch-catalogue-section('O1JC114941JC14718') :)
declare function webflow:patch-catalogue-section($section-id as xs:string) as element(webflow:patch-catalogue-section) {
    
    element { QName('http://read.84000.co/webflow-api','patch-catalogue-section') } {
    
        try {
            
            (: curl --request PATCH \
                 --url https://api.webflow.com/v2/collections/XXX/items/YYY \
                 --header 'accept: application/json' \
                 --header 'authorization: ZZZ' \
                 --header 'content-type: application/json' \
                 --data '
                    {
                      "fieldData": {
                        "toh-first": 93,
                        "toh-last": 356
                      }
                    }
            ' :)
            
            let $tei := tei-content:tei($section-id, 'section')
            let $section := section:section-tree($tei, true(), 'descendants')
            let $publications-summary := $section/eft:translation-summary[@section-id eq $section-id]/eft:publications-summary[@grouping eq 'toh'][@scope eq 'descendant']
            
            let $abstract := section:abstract($tei)
            let $abstract-html := $abstract ! transform:transform(*, doc(concat($common:app-path, '/xslt/tei-to-xhtml.xsl')), <parameters/>)
            let $abstract-html-string := string-join($abstract-html ! serialize(., $webflow:html5-serialization-parameters)) ! normalize-space(.) ! replace(., concat('^',functx:escape-for-regex('&lt;!DOCTYPE html&gt;'),'\s*'), '')
            
            let $webflow-item := $webflow:conf//webflow:item[@id eq $section-id]
            let $webflow-collection := $webflow-item/parent::webflow:collection
            
            let $data := 
                element { QName('','data') } {
                    if($webflow-collection[@id eq 'catalogue-collections']) then
                        element fieldData {
                            element xmlid { $section-id },
                            ($section/eft:page/eft:titles/eft:title[@type eq 'articleTitle'][text()], $section/eft:titles/eft:title[@xml:lang eq 'en'][text()])[1] ! element name { string-join(text()) ! normalize-space(.) },
                            $section/eft:titles/eft:title[@xml:lang eq 'bo'][text()] ! element tibetan-title { string-join(text()) ! normalize-space(.) },
                            $section/eft:titles/eft:title[@xml:lang eq 'zh'][text()] ! element chinese-title { string-join(text()) ! normalize-space(.) },
                            $publications-summary/eft:texts/@total[string()] ! element texts-count { attribute json:literal {'true'}, xs:integer(.) },
                            $publications-summary/eft:texts/@published[string()] ! element texts-published { attribute json:literal {'true'}, xs:integer(.) },
                            $publications-summary/eft:texts/@translated[string()] ! element texts-in-progress { attribute json:literal {'true'}, xs:integer(.) + $publications-summary/eft:texts/@in-translation ! xs:integer(.) },
                            $publications-summary/eft:texts/@not-started[string()] ! element texts-not-begun { attribute json:literal {'true'}, xs:integer(.) },
                            $publications-summary/eft:pages/@total[string()] ! element pages-count { attribute json:literal {'true'}, xs:integer(.) },
                            $publications-summary/eft:pages/@published[string()] ! element pages-published { attribute json:literal {'true'}, xs:integer(.) },
                            $publications-summary/eft:pages/@in-translation[string()] ! element pages-in-progress { attribute json:literal {'true'}, xs:integer(.) },
                            $publications-summary/eft:pages/@translated[string()] ! element pages-awaiting-publication { attribute json:literal {'true'}, xs:integer(.) }(:,
                            $abstract-html-string ! element collection-description { . },
                            $webflow:conf//webflow:item[@id = $section/eft:section/@id] ! element subsections { attribute json:array {'true'}, @webflow-id/string() }:)
                        }
                    
                    else if($webflow-collection[@id eq 'catalogue-sections']) then
                        element fieldData {
                            element xmlid { $section-id },
                            ($section/eft:page/eft:titles/eft:title[@type eq 'articleTitle'][text()], $section/eft:titles/eft:title[@xml:lang eq 'en'][text()])[1] ! element name { string-join(text()) ! normalize-space(.) },
                            $section/eft:titles/eft:title[@xml:lang eq 'bo'][text()] ! element tibetan-title { string-join(text()) ! normalize-space(.) },
                            $section/eft:titles/eft:title[@xml:lang eq 'Sa-Ltn'][text()] ! element sanskrit-title { string-join(text()) ! normalize-space(.) },
                            element toh-first { attribute json:literal {'true'}, min($section/descendant-or-self::eft:section/@toh-number-first[string()] ! xs:integer(.)) },
                            element toh-last { attribute json:literal {'true'}, max($section/descendant-or-self::eft:section/@toh-number-last[string()] ! xs:integer(.)) },
                            $publications-summary/eft:texts/@total[string()] ! element texts-stats { attribute json:literal {'true'}, xs:integer(.) },
                            $publications-summary/eft:texts/@published[string()] ! element texts-published { attribute json:literal {'true'}, xs:integer(.) },
                            $publications-summary/eft:texts/@translated[string()] ! element texts-in-progress { attribute json:literal {'true'}, xs:integer(.) + $publications-summary/eft:texts/@in-translation ! xs:integer(.) },
                            $publications-summary/eft:texts/@not-started[string()] ! element texts-not-begun { attribute json:literal {'true'}, xs:integer(.) }(:,
                            $abstract-html-string ! element section-description { . },
                            $webflow:conf//webflow:item[@id = $section/eft:section/@id] ! element subsections { attribute json:array {'true'}, @webflow-id/string() }:)
                        }
                    
                    else ()
                }
            
            where $tei and $webflow-item and $data[fieldData]
            return
                let $data-json := serialize($data, $webflow:json-serialization-parameters)
                
                let $request-body := <hc:body media-type="application/json" method="text">{ $data-json }</hc:body>
                
                let $request := webflow:request(xs:anyURI(concat('https://api.webflow.com/v2/collections/', $webflow-collection/@webflow-id, '/items/', $webflow-item/@webflow-id)), 'PATCH', $request-body)
                
                let $send-request := hc:send-request($request)
                
                let $response := $send-request[2] ! util:base64-decode(.) ! json-to-xml(.) ! fn:map
                
                where $response/fn:map[@key eq 'fieldData']
                return (
                    (:$section:)
                    (:$data:)
                    (:$request:)
                    $response ! element { 'catalogue-section' } { * },
                    
                    (: Publish the items :)
                    webflow:publish-items($webflow-item/@webflow-id),
                    
                    (: Log timestamp of update :)
                    webflow:log-patch($webflow-item/@id)
                    
                )
            
        }
        catch * {
            ()
        }
    }
    
};

(: webflow:get-texts() :)
declare function webflow:get-texts() as element(webflow:get-texts) {
    element { QName('http://read.84000.co/webflow-api','get-texts') } {
    
        let $webflow-collection := $webflow:conf//webflow:collection[@id eq 'texts']
        
        let $request := webflow:request(xs:anyURI(concat('https://api.webflow.com/v2/collections/', $webflow-collection/@webflow-id, '/items')), 'GET', ())
        
        let $send-request := hc:send-request($request)
        
        return (
            (:$webflow-collection,
            $request,:)
            $send-request[2] ! util:base64-decode(.) ! json-to-xml(.) ! fn:map ! element { 'texts' } { * }
        )
        
    }
};

(: webflow:get-text('toh52') :)
declare function webflow:get-text($source-key as xs:string) as element(webflow:get-text) {
    
    element { QName('http://read.84000.co/webflow-api','get-text') } {
    
        try {
            
            let $webflow-item := $webflow:conf//webflow:item[@id eq $source-key]
            let $webflow-collection := $webflow-item/parent::webflow:collection
            
            let $request := webflow:request(xs:anyURI(concat('https://api.webflow.com/v2/collections/', $webflow-collection/@webflow-id, '/items/', $webflow-item/@webflow-id)), 'GET', ())
            
            let $send-request := hc:send-request($request)
            
            return (
                (:$webflow-item,
                $request,:)
                $send-request[2] ! util:base64-decode(.) ! json-to-xml(.) ! fn:map ! element { 'text' } { * }
            )
            
        }
        catch * {
            ()
        }
    }
    
};

(: webflow:patch-text('toh21') :)
declare function webflow:patch-text($source-key as xs:string) as element(webflow:patch-text)? {
    
    let $tei := tei-content:tei($source-key, 'translation')
    where $tei
    return
    element { QName('http://read.84000.co/webflow-api','patch-text') } {
    
        try {
                    
            let $data := 
                element data {
                    element fieldData {
                        webflow:text-data($tei, $source-key)/*[. gt ''][not(@seed-data)]
                    }
                }
            
            (:return if(true()) then $data else:)
            
            let $webflow-item := $webflow:conf//webflow:item[@id eq $source-key]
            let $webflow-collection := $webflow-item/parent::webflow:collection
            
            where $tei and $webflow-item
            return
                let $data-json := serialize($data, $webflow:json-serialization-parameters)
                
                let $request-body := <hc:body media-type="application/json" method="text">{ $data-json }</hc:body>
                
                let $request := webflow:request(xs:anyURI(concat('https://api.webflow.com/v2/collections/', $webflow-collection/@webflow-id, '/items/', $webflow-item/@webflow-id)), 'PATCH', $request-body)
                
                let $send-request := hc:send-request($request)
                
                let $response := $send-request[2] ! util:base64-decode(.) ! json-to-xml(.) ! fn:map
                
                return (
                
                    (:$data:)
                    (:$request:)
                    (:$send-request:)
                    (:$response/fn:map[@key eq 'fieldData'],:)
                    
                    $response ! element { 'text' } { * },
                    
                    if($response/fn:map[@key eq 'fieldData'])  then (
                    
                        (: Publish the items :)
                        webflow:publish-items($webflow-item/@webflow-id),
                        
                        (: Log timestamp of update :)
                        webflow:log-patch($webflow-item/@id)
                    
                    )
                    else ()
                )
            
        }
        catch * {
            ()
        }
    }
    
};

declare function webflow:text-data($tei as element (tei:TEI), $source-key as xs:string) as element(fieldData) {
    
    let $tei-bibl := $tei/tei:teiHeader//tei:sourceDesc/tei:bibl[@key eq $source-key]
    let $text-toh := translation:toh($tei, $source-key)
    let $titles := translation:titles($tei, $source-key)
    let $title-variants := translation:title-variants($tei, $source-key)
    let $summary := translation:summary($tei)
    let $summary-html := $summary ! transform:transform(., doc(concat($common:app-path, '/xslt/tei-to-xhtml.xsl')), <parameters/>)
    let $summary-html-string := $summary-html ! string-join(descendant::xhtml:p ! serialize(., $webflow:html5-serialization-parameters)) ! normalize-space(.) ! replace(., concat('^',functx:escape-for-regex('&lt;!DOCTYPE html&gt;'),'\s*'), '')
    let $source := tei-content:source($tei, $source-key)
    let $source-location := tei-content:location($tei-bibl)
    let $source-start-volume := min($source-location/eft:volume/@number ! xs:integer(.))
    let $publication-status := translation:publication-status($tei-bibl, ())
    
    (:'Published', 'Partially Published', 'In Progress', 'Application Pending', 'Not Begun':)
    let $status-label := 
        if($publication-status[@status-group eq 'published']) then
            if($publication-status[not(@status-group eq 'published')]) then
                'Partially Published'
            else
                'Published'
        else if ($publication-status[@status-group = ('translated', 'in-translation')]) then
            'In Progress'
        else if ($publication-status[@status-group eq 'in-application']) then
            'Application Pending'
        else
            'Not Begun'
    
    return
        element { QName('', 'webflow-text-data') } {
            element slug { 
                attribute seed-data { 'true' },
                translation:filename($tei, $source-key) 
            },
            element name { 
                ($titles/eft:title[@xml:lang eq 'en'])[1] ! normalize-space(string-join(text())) 
            },
            element tibetan-title {
                ($titles/eft:title[@xml:lang eq 'bo'])[1] ! normalize-space(string-join(text()))
            },
            element sanskrit-title {
                ($titles/eft:title[@xml:lang eq 'Sa-Ltn'])[1] ! normalize-space(string-join(text()))
            },
            element chinese-title {
                ($titles/eft:title[@xml:lang eq 'zh'][text()], $title-variants/eft:title[@xml:lang eq 'zh'][text()])[1] ! normalize-space(string-join(text()))
            },
            element toh-key {
                $source-key
            },
            element toh-first {
                attribute json:literal { 'true' },
                $text-toh/@number[. gt ''][functx:is-a-number(.)] ! xs:integer(.)
            },
            element toh-append {
                $text-toh/@letter[. gt '']
            },
            element toh-chapter { 
                attribute json:literal { 'true' }, 
                $text-toh/@chapter-number[. gt ''][functx:is-a-number(.)] ! xs:integer(.)
            },
            element toh-bibliography-references { 
                ($text-toh/eft:duplicates/eft:full/text(), $text-toh/eft:full/text())[1] 
            },
            element start-volume { 
                attribute json:literal { 'true' }, 
                $source-start-volume 
            },
            element start-page { 
                attribute json:literal { 'true' }, 
                $source-location/eft:volume[@number ! xs:integer(.) eq $source-start-volume]/@start-page ! xs:integer(.) 
            },
            element total-pages-of-the-dege-kangyur { 
                attribute json:literal { 'true' }, 
                sum($publication-status/@count-pages ! xs:integer(.)) 
            },
            element text-status-2 { 
                $status-label 
            },
            element pages-published { 
                attribute json:literal { 'true' }, 
                sum($publication-status[@status-group eq 'published']/@count-pages ! xs:integer(.)) 
            },
            element published-date { 
                string-join($tei/tei:teiHeader//tei:publicationStmt/tei:date/text()) ! normalize-space(.)
            },
            element section-description { 
                attribute seed-data { 'true' },
                $summary-html-string
            },
            element card-short-description { 
                attribute seed-data { 'true' },
                $summary-html-string
            },
            (:element in-popular-themes {
                attribute seed-data { 'true' },
                ()
            },
            element available-sponsor-a-sutra { 
                false()
            },:)
            element reading-room-link {
                $publication-status[@status-group eq 'published'] ! concat('https://84000.co/translation/', $source-key)
            },
            element download-epub-link-2 {
                $publication-status[@status-group eq 'published'] ! concat('https://84000.co/translation/', $source-key, '.epub')
            },
            element download-pdf-link-2 {
                $publication-status[@status-group eq 'published'] ! concat('https://84000.co/translation/', $source-key, '.pdf')
            },
            element open-in-the-84000-app-link {
                $publication-status[@status eq '1'] ! concat('https://app.84000.co/translation/', $source-key, '.html')
            },
            
            element tibetan-source-author { 
            
                let $source-authors := $source/eft:attribution[@role = ('author-contested', 'author')]
                where count($source-authors) gt 0
                return
                    serialize(
                        element { QName('','p') } {
                        
                            if($source-authors[@role eq 'author-contested']) then
                                'Attributed to '
                            else
                                'By '
                            ,
                            
                            for $source-author at $index in $source-authors
                            return (
                                if($index gt 1) then
                                    if($source-author[@role eq 'author-contested']) then ' or '
                                    else if($index lt count($source-author)) then ', '
                                    else ', and '
                                else ()
                                ,
                                element span { 
                                    if($source-author[@role eq 'author-contested']) then attribute class { 'contested' } else (),
                                    common:html-lang($source-author/@xml:lang) ! attribute lang { . },
                                    $source-author/text()
                                } 
                            )
                            
                        }
                    )
                
            },
            
            element tibetan-source-translator {
            
                let $source-translators := $source/eft:attribution[@role eq 'translator']
                where count($source-translators) gt 0
                return
                    element { QName('','div') } {
                        attribute class { 'translators' },
                        element p { 'Translated into Tibetan by' },
                        element ul { 
                            for $source-translator in $source-translators
                            return
                                element li { 
                                    common:html-lang($source-translator/@xml:lang) ! attribute lang { . },
                                    $source-translator/text()
                                } 
                        }
                    } ! serialize(.)
                
            }
            
        }
        
};

(: webflow:get-articles() :)
declare function webflow:get-articles() as element(webflow:get-articles) {
    element { QName('http://read.84000.co/webflow-api','get-articles') } {
    
        let $webflow-collection := $webflow:conf//webflow:collection[@id eq 'articles']
        
        let $request := webflow:request(xs:anyURI(concat('https://api.webflow.com/v2/collections/', $webflow-collection/@webflow-id, '/items')), 'GET', ())
        
        let $send-request := hc:send-request($request)
        
        return (
            (:$webflow-collection,
            $request,:)
            $send-request[2] ! util:base64-decode(.) ! json-to-xml(.) ! fn:map ! element { 'articles' } { * }
        )
        
    }
};

(: webflow:get-article('kangyur') :)
declare function webflow:get-article($article-id as xs:string) as element(webflow:get-article) {
    
    element { QName('http://read.84000.co/webflow-api','get-article') } {
    
        try {
            
            let $webflow-item := $webflow:conf//webflow:item[@id eq $article-id]
            let $webflow-collection := $webflow-item/parent::webflow:collection
            
            let $request := webflow:request(xs:anyURI(concat('https://api.webflow.com/v2/collections/', $webflow-collection/@webflow-id, '/items/', $webflow-item/@webflow-id)), 'GET', ())
            
            let $send-request := hc:send-request($request)
            
            return (
                (:$webflow-item,
                $request,:)
                $send-request[2] ! util:base64-decode(.) ! json-to-xml(.) ! fn:map ! element { 'article' } { * }
            )
            
        }
        catch * {
            ()
        }
    }
    
};

(: webflow:patch-article('kangyur') :)
declare function webflow:patch-article($article-id as xs:string) as element(webflow:patch-article) {
    
    element { QName('http://read.84000.co/webflow-api','patch-article') } {
    
        try {
            
            let $tei := tei-content:tei($article-id, 'knowledgebase')
            
            let $abstract := knowledgebase:abstract($tei)
            let $abstract-html := $abstract ! transform:transform(*, doc(concat($common:app-path, '/xslt/tei-to-xhtml.xsl')), <parameters/>)
            let $abstract-html-string := string-join($abstract-html ! serialize(., $webflow:html5-serialization-parameters)) ! normalize-space(.) ! replace(., concat('^',functx:escape-for-regex('&lt;!DOCTYPE html&gt;'),'\s*'), '')
            
            let $article := knowledgebase:article($tei)
            let $article-html := $article ! transform:transform(., doc(concat($common:app-path, '/xslt/tei-to-xhtml.xsl')), <parameters/>)
            let $article-html-string := string-join(serialize($article-html, $webflow:html5-serialization-parameters)) ! normalize-space(.) ! replace(., concat('^',functx:escape-for-regex('&lt;!DOCTYPE html&gt;'),'\s*'), '')
            
            let $webflow-item := $webflow:conf//webflow:item[@id eq $article-id]
            let $webflow-collection := $webflow-item/parent::webflow:collection
            
            let $data := 
                element { QName('','data') } {
                    element fieldData {
                        ($tei//tei:titleStmt/tei:title[@type eq 'articleTitle'][text()], $tei//tei:titleStmt/tei:title[@type eq 'mainTitle'][@xml:lang eq 'en'])[1] ! element name { string-join(text()) ! normalize-space(.) },
                        ($tei//tei:titleStmt/tei:title[@xml:lang eq 'bo'])[1] ! element tibetan-title { string-join(text()) ! normalize-space(.) },
                        ($tei//tei:titleStmt/tei:title[@xml:lang eq 'Sa-Ltn'])[1] ! element sanskrit-title { string-join(text()) ! normalize-space(.) },
                        element brief-description { $abstract-html-string },
                        element body-of-the-article { $article-html-string },
                        element first-published { $tei/tei:publicationStmt/tei:date/text() },
                        element last-updated { tei-content:last-modified($tei) }
                    }
                }
            
            where $tei and $webflow-item and $data[fieldData]
            return
                let $data-json := serialize($data, $webflow:json-serialization-parameters)
                
                let $request-body := <hc:body media-type="application/json" method="text">{ $data-json }</hc:body>
                
                let $request := webflow:request(xs:anyURI(concat('https://api.webflow.com/v2/collections/', $webflow-collection/@webflow-id, '/items/', $webflow-item/@webflow-id)), 'PATCH', $request-body)
                
                let $send-request := hc:send-request($request)
                
                let $response := $send-request[2] ! util:base64-decode(.) ! json-to-xml(.) ! fn:map
                
                where $response/fn:map[@key eq 'fieldData']
                return (
                    (:$article-html:)
                    (:$data:)
                    (:$request:)
                    $response ! element { 'article' } { * },
                    
                    (: Publish the items :)
                    webflow:publish-items($webflow-item/@webflow-id),
                    
                    (: Log timestamp of update :)
                    webflow:log-patch($webflow-item/@id)
                    
                )
            
        }
        catch * {
            ()
        }
    }
    
};

declare function webflow:translation-updates($tei as element(tei:TEI)) {
    
    let $api-status := translation:api-status($tei)
    let $execute-options := 
        <option>
            <workingDir>/{ $common:environment//eft:env-vars/eft:var[@id eq 'home']/text() }/</workingDir>
        </option>
    
    for $api-call in $api-status/eft:api-call[@type eq 'webflow-api'][@linked eq 'true'][@publish eq 'true']
    return (
    
        util:log('info', concat('webflow-translation-updates:', $api-call/@target-call, '(', $api-call/@source, ')')),
        
        if($api-call[@target-call eq 'patch-text']) then
            webflow:patch-text($api-call/@source)
        else if($api-call[@target-call eq 'patch-catalogue-section']) then
            webflow:patch-catalogue-section($api-call/@source)
        else ()
        ,
        
        process:execute(('sleep', '0.5'), $execute-options) ! ()
        
    )
};
