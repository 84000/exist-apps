xquery version "3.1";

module namespace sponsors="http://read.84000.co/sponsors";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $sponsors:sponsors := doc(concat($common:data-path, '/operations/sponsors.xml'));
declare variable $sponsors:texts := collection($common:translations-path);
declare variable $sponsors:prefixes := '(Dr\.|Prof\.)';

declare function sponsors:sponsors($include-acknowledgements as xs:boolean){
    let $sponsors-ordered := 
        for $sponsor in $sponsors:sponsors/m:sponsors/m:sponsor
        order by normalize-space(replace(concat($sponsor/m:name, ' ', $sponsor/m:internal-name), $sponsors:prefixes, ''))
        return $sponsor
    
    return
        <sponsors xmlns="http://read.84000.co/ns/1.0">
        {
            for $sponsor in $sponsors-ordered
            return
                sponsors:sponsor($sponsor/@xml:id, $include-acknowledgements)
         }
         </sponsors>
};

declare function sponsors:sponsor($id as xs:string, $include-acknowledgements as xs:boolean){
    let $sponsor := $sponsors:sponsors/m:sponsors/m:sponsor[@xml:id eq $id]
    return
        element { node-name($sponsor) } {
            $sponsor/@*,
            attribute start-letter { upper-case(substring(normalize-space(replace($sponsor/m:name, $sponsors:prefixes, '')), 1, 1)) },
            $sponsor/node(),
            if($include-acknowledgements) then
                sponsors:acknowledgements(concat('sponsors.xml#', $sponsor/@xml:id))
            else
                ()
        }
};

declare function sponsors:acknowledgements($uri as xs:string){
    
    let $query-options := 
        <options>
            <default-operator>and</default-operator>
            <phrase-slop>0</phrase-slop>
            <leading-wildcard>no</leading-wildcard>
        </options>
    
    let $sponsor-id := substring-after($uri, 'sponsors.xml#')
    
    return
        for $tei in $sponsors:texts//tei:TEI[tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:sponsor[@sameAs eq $uri]]
            let $translation-sponsor := $tei//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:sponsor[@sameAs eq $uri][1]
            let $sponsor-name := 
                if($translation-sponsor/text() gt '') then
                    $translation-sponsor/text()
                else
                    $sponsors:sponsors/m:sponsors/m:sponsor[@xml:id eq $sponsor-id]/m:name/text()
            
            let $query := 
                <query>
                    <phrase occur="must">{ lower-case($sponsor-name) }</phrase>
                </query>
            
            let $query-result := $tei//tei:front/tei:div[@type eq "acknowledgment"]/tei:p[ft:query(., $query, $query-options)]
            let $title := tei-content:title($tei)
            let $translation-id := tei-content:id($tei)
            let $translation-status := $tei//tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status
            let $sponsorship-status := $tei//tei:teiHeader/tei:fileDesc/tei:titleStmt/@sponsored
            
            for $toh-key in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
                let $toh := translation:toh($tei, $toh-key)
            return
                element m:acknowledgement {
                    attribute translation-id { $translation-id },
                    attribute translation-status {$translation-status},
                    attribute sponsorship-status {$sponsorship-status},
                    element m:title { text { $title } },
                    $toh,
                    element tei:div {
                        attribute type {'acknowledgment'},
                        util:expand($query-result, "expand-xincludes=no")
                    }
                }
};

declare function sponsors:sponsorship-statuses($selected-status as xs:string) as node() {
    <sponsorhip-statuses xmlns="http://read.84000.co/ns/1.0">
    {(
        element status 
        { 
            attribute value { '' },
            if ($selected-status = '') then attribute selected { 'selected' } else '',
            text { 'Not sponsored' }
        },
        element status 
        { 
            attribute value { 'full' },
            if ($selected-status = 'full') then attribute selected { 'selected' } else '',
            text { 'Fully sponsored' }
        },
        element status 
        { 
            attribute value { 'part' },
            if ($selected-status = 'part') then attribute selected { 'selected' } else '',
            text { 'Partly sponsored' }
        }
    )}
    </sponsorhip-statuses>
};

declare function sponsors:next-id() as xs:integer {
    max($sponsors:sponsors/m:sponsors/m:sponsor/@xml:id ! substring-after(., 'sponsor-') ! xs:integer(concat('0', .))) + 1
};

declare function sponsors:update($sponsor as node()?) as xs:string {
    
    let $sponsor-id :=
        if($sponsor/@xml:id) then
            $sponsor/@xml:id
        else
            concat('sponsor-', xs:string(sponsors:next-id()))
    
    let $sponsor-type := request:get-parameter('sponsor-type', '')
    let $name := request:get-parameter('name', '')
    let $internal-name := request:get-parameter('internal-name', '')
    let $country := request:get-parameter('country', '')
    
    let $new-value := 
        <sponsor xmlns="http://read.84000.co/ns/1.0" 
            type="{ $sponsor-type }"
            xml:id="{ $sponsor-id }">
            <name>{ $name }</name>
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
        </sponsor>
    
    let $parent := $sponsors:sponsors/m:sponsors
    
    let $update := common:update('sponsor', $sponsor, $new-value, $parent, ())
    
    return
        $new-value//@xml:id
        
};

declare function sponsors:delete($sponsor as node()){
    common:update('sponsor', $sponsor, (), (), ())
};
