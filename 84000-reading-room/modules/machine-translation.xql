xquery version "3.0";

module namespace machine-translation="http://read.84000.co/machine-translation";

declare namespace json="http://www.json.org";

declare variable $machine-translation:json-serialization-parameters := 
    element { QName('http://www.w3.org/2010/xslt-xquery-serialization','serialization-parameters') }{
        element method { 
            attribute value { 'json' }
        }
    };

declare function machine-translation:dharmamitra-translation($input-sentence as xs:string){
    
    element { QName('http://read.84000.co/ns/1.0','machine-translation') } {
    
        (:{"input_sentence": "", "level_of_explanation": 0, "language": "bo-en", "model": "NO"}:)
        
        let $request-body := 
            element body {
                element input_sentence { $input-sentence },
                element level_of_explanation { attribute json:literal {'true'}, 0 },
                element language {'bo-en'},
                element model {'NO'}
            }
        
        let $request := 
            <hc:request href="https://dharmamitra.org/api/translation/" method="POST">
                <hc:header name="Content-Type" value="application/json"/>
                <hc:body media-type="application/json" method="text">{ serialize($request-body, $machine-translation:json-serialization-parameters) }</hc:body>
            </hc:request>
        
        let $send-request := hc:send-request($request)
        let $response := $send-request[2] ! tokenize(., '"')[2] ! parse-xml(concat('<doc>',.,'</doc>'))/doc//text()
        return (
            (:$mt-request,:)
            element request-sentence { $input-sentence },
            $response[1] ! element response-sentence { normalize-space(.) },
            $response[2] ! element trailer { normalize-space(.) }
        )
    }
    
};