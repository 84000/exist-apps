xquery version "3.1";

module namespace webflow="http://read.84000.co/webflow-api";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace section = "http://read.84000.co/section" at "../../84000-reading-room/modules/section.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace functx = "http://www.functx.com";

declare namespace eft="http://read.84000.co/ns/1.0";
declare namespace json="http://www.json.org";
declare namespace fn="http://www.w3.org/2005/xpath-functions";

declare variable $webflow:conf := doc(concat($common:data-path, '/local/webflow-api.xml'));
declare variable $webflow:json-serialization-parameters := 
    element { QName('http://www.w3.org/2010/xslt-xquery-serialization','serialization-parameters') }{
        element method { 
            attribute value { 'json' }
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

declare function webflow:get-sites() as element(webflow:sites) {
    
    element { QName('http://read.84000.co/webflow-api','sites') } {
    
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
                $webflow-item,
                $request,
                $send-request[2] ! util:base64-decode(.) ! json-to-xml(.) ! fn:map ! element { 'catalogue-section' } { * }
            )
            
        }
        catch * {
            ()
        }
    }
    
};

declare function webflow:patch-catalogue-section($section-id as xs:string) as element(webflow:patch-catalogue-section) {
    
    element { QName('http://read.84000.co/webflow-api','patch-catalogue-section') } {
    
        (:try {:)
            
            (: curl --request PATCH \
                 --url https://api.webflow.com/v2/collections/XXX/items/YYY \
                 --header 'accept: application/json' \
                 --header 'authorization: ZZZ' \
                 --header 'content-type: application/json' \
                 --data '
                    {
                      "fieldData": {
                        "toh-first": "93",
                        "toh-last": "356"
                      }
                    }
            ' :)
            
            let $tei := tei-content:tei($section-id, 'section')
            let $section := section:section-tree($tei, true(), 'descendants')
            let $publications-summary := $section/eft:translation-summary[@section-id eq $section-id]/eft:publications-summary[@grouping eq 'toh'][@scope eq 'descendant']
            
            let $data := 
                element data {
                    element fieldData {
                        $section/eft:titles/eft:title[@xml:lang eq 'en'][text()] ! element name { string-join(text()) ! normalize-space(.) },
                        $section/eft:titles/eft:title[@xml:lang eq 'bo'][text()] ! element tibetan-title { string-join(text()) ! normalize-space(.) },
                        $section/eft:titles/eft:title[@xml:lang eq 'Sa-Ltn'][text()] ! element sanskrit-title { string-join(text()) ! normalize-space(.) },
                        $section/eft:abstract[*] ! element section-description { string-join(descendant::text()) ! normalize-space(.) },
                        element toh-first { attribute json:literal {'true'}, min($section/descendant-or-self::eft:section/@toh-number-first[string()] ! xs:integer(.)) },
                        element toh-last { attribute json:literal {'true'}, max($section/descendant-or-self::eft:section/@toh-number-last[string()] ! xs:integer(.)) },
                        $publications-summary/eft:texts/@total[string()] ! element texts-stats { attribute json:literal {'true'}, xs:integer(.) },
                        $publications-summary/eft:texts/@published[string()] ! element texts-published { attribute json:literal {'true'}, xs:integer(.) },
                        $publications-summary/eft:texts/@translated[string()] ! element texts-in-progress { attribute json:literal {'true'}, xs:integer(.) + $publications-summary/eft:texts/@in-translation ! xs:integer(.) },
                        $publications-summary/eft:texts/@not-started[string()] ! element texts-not-begun { attribute json:literal {'true'}, xs:integer(.) }
                    }
                }
            
            let $webflow-item := $webflow:conf//webflow:item[@id eq $section-id]
            let $webflow-collection := $webflow-item/parent::webflow:collection
            
            let $data-json := serialize($data, $webflow:json-serialization-parameters)
            
            let $request-body := <hc:body media-type="application/json" method="text">{ $data-json }</hc:body>
            
            let $request := webflow:request(xs:anyURI(concat('https://api.webflow.com/v2/collections/', $webflow-collection/@webflow-id, '/items/', $webflow-item/@webflow-id)), 'PATCH', $request-body)
            
            let $send-request := hc:send-request($request)
            
            return (
                (:$section,:)
                (:$data,:)
                (:$request,:)
                $send-request[2] ! util:base64-decode(.) ! json-to-xml(.) ! fn:map ! element { 'catalogue-section' } { * },
                (: Log timestamp of update :)
                webflow:log-patch($webflow-item/@id)
            )
            
        (:}
        catch * {
            ()
        }:)
    }
    
};

