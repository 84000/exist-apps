xquery version "3.1";

module namespace sponsors="http://read.84000.co/sponsors";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";
import module namespace sponsorship="http://read.84000.co/sponsorship" at "sponsorship.xql";

declare variable $sponsors:sponsors := doc(concat($common:data-path, '/operations/sponsors.xml'));
declare variable $sponsors:texts := collection($common:translations-path);
declare variable $sponsors:prefixes := '(Dr\.|Prof\.)';

declare function sponsors:sponsor-uri($sponsor-id as xs:string) as xs:string* {
    lower-case(concat('eft:', $sponsor-id))
};

declare function sponsors:sponsor-id($sponsor-uri as xs:string) as xs:string {
    lower-case(replace($sponsor-uri, '^eft:', '', 'i'))
};

declare function sponsors:sponsors($sponsor-ids as xs:string*, $include-internal-names as xs:boolean) as element() {

    let $sponsors-ordered := 
        for $sponsor in 
            if(not($sponsor-ids = 'all')) then
                $sponsors:sponsors/m:sponsors/m:sponsor[@xml:id = $sponsor-ids]
            else
                $sponsors:sponsors/m:sponsors/m:sponsor
        order by normalize-space(replace(concat($sponsor/m:label, ' ', $sponsor/m:internal-name), $sponsors:prefixes, ''))
        return $sponsor
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'sponsors') } {
            for $sponsor in $sponsors-ordered
            return
                sponsors:sponsor($sponsor/@xml:id, false(), $include-internal-names)
         }
};

declare function sponsors:sponsor($id as xs:string, $include-acknowledgements as xs:boolean, $include-internal-names as xs:boolean) as element() {
    let $sponsor := $sponsors:sponsors/m:sponsors/m:sponsor[@xml:id eq $id]
    return
        element { node-name($sponsor) } {
            $sponsor/@*,
            attribute start-letter { upper-case(substring(normalize-space(replace($sponsor/m:label, $sponsors:prefixes, '')), 1, 1)) },
            element sort-name { lower-case(replace($sponsor/m:label, concat($sponsors:prefixes, '\s+'), '')) },
            $sponsor/m:label,
            $sponsor/m:country,
            $sponsor/m:type,
            $sponsor/m:instance,
            if($include-internal-names) then
                $sponsor/m:internal-name
            else ()
            ,
            if($include-acknowledgements) then
                sponsors:acknowledgements(sponsors:sponsor-uri($sponsor/@xml:id)[1])
            else ()
        }
};

declare function sponsors:acknowledgements($uri as xs:string) as element()* {
    
    let $sponsor-id := sponsors:sponsor-id($uri)
    let $sponsor := $sponsors:sponsors/id($sponsor-id)[self::m:sponsor]
    
    for $tei in $sponsors:texts//tei:TEI[tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:sponsor[@xml:id = $sponsor/m:instance/@id]]
    return
        sponsors:acknowledgement($sponsor, $tei)
        
};

declare function sponsors:acknowledgement($sponsors as element(m:sponsor)*, $tei as element(tei:TEI)) as element()* {
    
    let $sponsorship := $tei/id($sponsors/m:instance/@id)[self::tei:sponsor]
    
    let $sponsor-names := distinct-values(($sponsorship ! string-join(text()), $sponsors/m:label ! string-join(text()) ! normalize-space(.) ! lower-case(.) ! replace(., $sponsors:prefixes, '') ! normalize-space(.)))
    
    let $acknowledgment := $tei//tei:front/tei:div[@type eq "acknowledgment"]/tei:p ! element { QName('http://www.tei-c.org/ns/1.0', 'p') } { string-join(.) }
    
    let $marked-paragraphs := common:mark-nodes($acknowledgment, $sponsor-names, 'phrase')
    
    let $title := tei-content:title-any($tei)
    let $translation-id := tei-content:id($tei)
    let $status := tei-content:publication-status($tei)
    let $status-group := tei-content:publication-status-group($tei)
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'acknowledgement') } {
            attribute translation-id { $translation-id },
            attribute status {$status},
            attribute status-group { $status-group },
            element m:title { text { $title } },
            translation:toh($tei, ''),
            (:$mark-sponsor-names ! element name { . },:)
            $marked-paragraphs(:[exist:match]:),
            sponsorship:text-status($translation-id, false())
        }
        
};

declare function sponsors:next-id() as xs:integer {
    max($sponsors:sponsors/m:sponsors/m:sponsor/@xml:id ! substring-after(., 'sponsor-') ! common:integer(.)) + 1
};

declare function sponsors:update($sponsor as element(m:sponsor)?) as xs:string {
    
    let $sponsor-id :=
        if($sponsor/@xml:id) then
            $sponsor/@xml:id
        else
            concat('sponsor-', xs:string(sponsors:next-id()))
    
    let $name := request:get-parameter('name', '')
    let $internal-name := request:get-parameter('internal-name', '')
    let $country := request:get-parameter('country', '')
    
    let $new-value := 
        <sponsor xmlns="http://read.84000.co/ns/1.0" 
            xml:id="{ $sponsor-id }">
            <label>{ $name }</label>
            {
                if($internal-name) then
                    <internal-name>{ $internal-name }</internal-name>
                else
                    ()
            }
            {
                if($country) then
                    <country>{ $country}</country>
                else
                    ()
            }
            {
                for $type in ('founding', 'matching-funds', 'sutra')
                return
                    if(request:get-parameter(concat($type, '-type'), '')) then
                        <type id="{ $type }"/>
                    else
                        ()
            }
        </sponsor>
    
    let $parent := $sponsors:sponsors/m:sponsors
    
    let $update-sponsor := common:update('sponsor', $sponsor, $new-value, $parent, ())
    
    return
        $new-value//@xml:id
        
};

declare function sponsors:delete($sponsor as element(m:sponsor)){
    common:update('sponsor', $sponsor, (), (), ())
};
