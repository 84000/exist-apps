xquery version "3.1";

module namespace webflow="http://read.84000.co/webflow-api";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";

declare namespace eft="http://read.84000.co/ns/1.0";
declare namespace json="http://www.json.org";
declare namespace fn="http://www.w3.org/2005/xpath-functions";

declare function webflow:sites() as element(webflow:sites) {
    
    element { QName('http://read.84000.co/webflow-api','sites') } {
        
        try {
            
            (: curl --request GET --url https://api.webflow.com/v2/sites --header 'accept: application/json' --header 'authorization: XXX' :)
            
            let $request := 
                <hc:request href="https://api.webflow.com/v2/sites" method="GET">
                    <hc:header name="Accept" value="application/json"/>
                    <hc:header name="Authorization" value="{ $common:environment/eft:webflow-conf/eft:authorization/text() }"/>
                </hc:request>
            
            let $send-request := hc:send-request($request)
            
            return (
                $send-request[2] ! util:base64-decode(.) ! json-to-xml(.) ! fn:map/fn:array[@key eq 'sites']/fn:map ! element { 'site' } { * }
            )
                
        }
        catch * {
            ()
        }
    }
    
};