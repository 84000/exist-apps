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

declare function sponsors:sponsors($sponsor-ids as xs:string*, $include-acknowledgements as xs:boolean, $include-internal-names as xs:boolean) as element() {

    let $sponsors-ordered := 
        for $sponsor in 
            if(not($sponsor-ids = 'all')) then
                $sponsors:sponsors/m:sponsors/m:sponsor[@xml:id = $sponsor-ids]
            else
                $sponsors:sponsors/m:sponsors/m:sponsor
        order by normalize-space(replace(concat($sponsor/m:label, ' ', $sponsor/m:internal-name), $sponsors:prefixes, ''))
        return $sponsor
    
    return
        <sponsors xmlns="http://read.84000.co/ns/1.0">
        {
            for $sponsor in $sponsors-ordered
            return
                sponsors:sponsor($sponsor/@xml:id, $include-acknowledgements, $include-internal-names)
         }
         </sponsors>
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
            if($include-internal-names) then
                $sponsor/m:internal-name
            else
                ()
            ,
            if($include-acknowledgements) then
                sponsors:acknowledgements(concat('sponsors.xml#', $sponsor/@xml:id))
            else
                ()
        }
};

declare function sponsors:acknowledgements($uri as xs:string) as element()* {
    
    for $tei in $sponsors:texts//tei:TEI[tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:sponsor/@ref eq $uri]
    
        let $translation-sponsor := $tei//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:sponsor[@ref eq $uri][1]
        
        let $sponsor-id := substring-after($uri, 'sponsors.xml#')
        
        let $sponsor-name := 
            if($translation-sponsor/text() gt '') then
                $translation-sponsor/text()
            else
                $sponsors:sponsors/m:sponsors/m:sponsor[@xml:id eq $sponsor-id]/m:label/text()
        
        let $acknowledgment := $tei//tei:front/tei:div[@type eq "acknowledgment"]
        
        let $mark-sponsor-name := normalize-space(lower-case(replace($sponsor-name, $sponsors:prefixes, '')))
        
        let $marked-paragraphs := common:mark-nodes($acknowledgment/tei:p, $mark-sponsor-name, 'phrase')
        
        let $title := tei-content:title($tei)
        let $translation-id := tei-content:id($tei)
        let $translation-status := tei-content:translation-status($tei)
        let $translation-status-group := tei-content:translation-status-group($tei)
        
        for $toh-key in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
            let $toh := translation:toh($tei, $toh-key)
        return
            element { QName('http://read.84000.co/ns/1.0', 'acknowledgement') } {
                attribute translation-id { $translation-id },
                attribute translation-status {$translation-status},
                attribute translation-status-group { $translation-status-group },
                element m:title { text { $title } },
                $toh,
                element { QName('http://www.tei-c.org/ns/1.0', 'div') } {
                    attribute type {'acknowledgment'},
                    $marked-paragraphs[exist:match]
                },
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
