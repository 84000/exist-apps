xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";

import module namespace common = "http://read.84000.co/common" at "../../../modules/common.xql";
import module namespace source = "http://read.84000.co/source" at "../../../modules/source.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:api-version := '0.4.0';

declare variable $local:request-work := (request:get-parameter('work-id', '')[. = ('kangyur','tengyur')],'kangyur')[1];
declare variable $local:work-id := if($local:request-work eq 'tengyur') then $source:tengyur-work else $source:kangyur-work;
declare variable $local:source-data-path := source:etext-path($local:work-id);
declare variable $local:volumes-tei := collection($source:source-data-path)//tei:TEI;

declare variable $local:request-volume := request:get-parameter('volume', '')[functx:is-a-number(.)] ! xs:integer(.);

declare variable $local:request-folio-index := request:get-parameter('folio-index', '')[functx:is-a-number(.)] ! xs:integer(.);

declare variable $local:kangyur-supabase-id := '969fc689-0720-4876-a7a3-cc3753f88f96';
declare variable $local:tengyur-supabase-id := '538e53ee-a092-439d-a3fe-64b71abdf92d';

element source {
    
    attribute modelType { 'tibetan-source' },
    attribute apiVersion { $local:api-version },
    attribute url { concat('/source/', $local:request-work,'.json?', string-join(( $local:request-volume ! concat('volume=', .), $local:request-folio-index ! concat('folio-index=', .), concat('api-version=', $local:api-version)), '&amp;')) },
    element sourceWork_key { $local:request-work },
    element sourceWork_xmlId { $local:work-id },
    element sourceWork_UUID { ($local:request-work[. eq 'kangyur'] ! $local:kangyur-supabase-id, $local:tengyur-supabase-id)[1] },
    
    for $volume-number in 1 to count($local:volumes-tei)
    where not($local:request-volume) or $volume-number eq  $local:request-volume
    
    let $etext-volume := source:etext-volume-number($local:work-id, $volume-number)
    let $etext-id := source:etext-id($local:work-id, $etext-volume)
    let $tei := source:etext-volume($etext-id)
    let $folios := $tei/tei:text/tei:body//tei:p

    return
        
        for $folio at $folio-index in $folios
        where not($local:request-folio-index) or $folio-index eq $local:request-folio-index
        return
            element folio {
                element xmlID { string-join(($etext-id, 'side', $folio-index), '/') },
                element volume_number { attribute json:literal { true() }, $volume-number },
                (:element volume_folio_index { attribute json:literal { true() }, $folio-index },:)
                element folio_number { attribute json:literal { true() }, replace($folio/@data-orig-n, '^(\d+)(.+)$', '$1') },
                element side { replace($folio/@data-orig-n, '^(\d+)(.+)$', '$2') },
                element content {
                    let $lines := 
                        for $node in $folio/node()
                        return
                            if ($node instance of text()) then
                                $node 
                            else if($node[self::tei:milestone][@unit eq 'line'] and $node/preceding-sibling::text()) then
                                '__lb__'
                            else ()
                    return
                        normalize-space(string-join($lines)) ! replace(., '__lb__', '&#xA;')
                }
            }
    
}
