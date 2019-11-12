xquery version "3.1";

module namespace contributors="http://read.84000.co/contributors";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $contributors:contributors := doc(concat($common:data-path, '/operations/contributors.xml'));
declare variable $contributors:texts := collection($common:translations-path);
declare variable $contributors:person-prefixes := '(Dr\.|Prof\.|Ven\.)';
declare variable $contributors:team-prefixes := '(Dr\.|The|Prof\.)';
declare variable $contributors:institution-prefixes := '(The|University\sof)';

declare function contributors:persons($include-acknowledgements as xs:boolean) as element() {
    
    let $contributors := 
        for $contributor in $contributors:contributors/m:contributors/m:person
        order by normalize-space(replace($contributor/m:label, $contributors:person-prefixes, ''))
        return $contributor
    
    return
        <contributor-persons xmlns="http://read.84000.co/ns/1.0">
        {
            for $contributor in $contributors
            return
                contributors:person($contributor/@xml:id, $include-acknowledgements)
        }
        </contributor-persons>
};

declare function contributors:person($id as xs:string, $include-acknowledgements as xs:boolean) as element() {
    
    let $contributor := $contributors:contributors/m:contributors/m:person[@xml:id eq $id]
    
    return
        element { node-name($contributor) } {
            $contributor/@*,
            attribute start-letter { upper-case(substring(normalize-space(replace($contributor/m:label, $contributors:person-prefixes, '')), 1, 1)) },
            $contributor/*,
            element sort-name { replace($contributor/m:label, concat($contributors:person-prefixes, '\s(.*)'), '$2, $1') },
            if($include-acknowledgements) then
                contributors:acknowledgements(concat('contributors.xml#', $contributor/@xml:id))
            else
                ()
        }
};

declare function contributors:acknowledgements($uri as xs:string){
    
    for $tei in 
        $contributors:texts//tei:TEI[
            tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/@ref = $uri
            or tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor/@ref = $uri
            or tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:consultant/@ref = $uri
        ]
        
        let $translation-contributor := (
            $tei//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author[@ref eq $uri]
            | $tei//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor[@ref eq $uri]
            | $tei//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:consultant[@ref eq $uri]
        )[1]
        
        let $id := substring-after($uri, 'contributors.xml#')
        
        let $contributor-name := 
            if($translation-contributor/text()) then
                $translation-contributor/text()
            else
                $contributors:contributors/m:contributors/m:person[@xml:id eq $id]/m:label/text()
        
        let $acknowledgment := $tei//tei:front/tei:div[@type eq "acknowledgment"]
        
        let $mark-contributor-name := normalize-space(lower-case(replace($contributor-name, $contributors:person-prefixes, '')))
        
        let $marked-paragraphs := common:mark-nodes($acknowledgment/tei:p, $mark-contributor-name, true())
        
    return
        contributors:acknowledgement($tei, $marked-paragraphs[exist:match])
};

declare function contributors:acknowledgement($tei as element(tei:TEI), $paragraphs as element()*) as element()* {

    let $title := tei-content:title($tei)
    let $translation-id := tei-content:id($tei)
    let $translation-status := tei-content:translation-status($tei)
    let $translation-status-group := tei-content:translation-status-group($tei)
    
    for $toh-key in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
        let $toh := translation:toh($tei, $toh-key)
    return
        element m:acknowledgement {
            attribute translation-id { $translation-id },
            attribute translation-status {$translation-status},
            attribute translation-status-group { $translation-status-group },
            element m:title { text { $title } },
            $toh,
            element tei:div {
                attribute type {'acknowledgment'},
                $paragraphs
            }
        }
};

declare function contributors:teams($include-hidden as xs:boolean, $include-acknowledgements as xs:boolean, $include-persons as xs:boolean) as element(){
    
    let $teams := 
        if($include-hidden) then
            $contributors:contributors/m:contributors/m:team
        else
            $contributors:contributors/m:contributors/m:team[not(@rend eq 'hidden')]
    
    let $teams := 
        for $team in $teams
        order by normalize-space(replace($team/m:label/text(), $contributors:team-prefixes,''))
        return $team
    
    return
        <contributor-teams xmlns="http://read.84000.co/ns/1.0">
        {
            for $team in $teams
            return
                contributors:team($team/@xml:id, $include-acknowledgements, $include-persons)
        }
        </contributor-teams>
};

declare function contributors:team($id as xs:string, $include-acknowledgements as xs:boolean, $include-persons as xs:boolean) as element() {
    
    let $team := $contributors:contributors/m:contributors/m:team[@xml:id eq $id]
    let $team-id := concat('contributors.xml#', $team/@xml:id)
    
    return
        element { node-name($team) } {
            $team/@*,
            attribute start-letter { upper-case(substring(normalize-space(replace($team/m:label, $contributors:team-prefixes, '')), 1, 1)) },
            $team/* ,
            element sort-name { replace($team/m:label, concat($contributors:team-prefixes, '\s(.*)'), '$2, $1') },
            if($include-acknowledgements) then
                for $tei in $contributors:texts//tei:TEI[tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author[@ref eq $team-id]]
                    let $acknowledgement := $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:*[@ref eq concat('contributors.xml#', $team/@xml:id)]
                return
                    contributors:acknowledgement($tei, element tei:p { $acknowledgement })
            else
                (),
            if($include-persons) then
                $contributors:contributors/m:contributors/m:person[m:team/@id eq $id]
            else
                ()
        }
};

declare function contributors:regions($include-stats as xs:boolean) as element() {
    
    let $region-ids := $contributors:contributors/m:contributors/m:region/@id
    let $regions-institution-xmlids := $contributors:contributors/m:contributors/m:institution[@region-id = $region-ids]/@xml:id
    let $contributor-count := count($contributors:contributors/m:contributors/m:person[m:institution/@id = $regions-institution-xmlids])
    
    return
        <contributor-regions xmlns="http://read.84000.co/ns/1.0">
        {
            for $region in $contributors:contributors/m:contributors/m:region
                let $region-institution-xmlids := $contributors:contributors/m:contributors/m:institution[@region-id eq $region/@id]/@xml:id
            return
                element { node-name($region) } {
                    $region/@*,
                    $region/*,
                    if($include-stats) then
                        let $region-contributor-count := count($contributors:contributors/m:contributors/m:person[m:institution/@id = $region-institution-xmlids])
                        return
                            (
                                element stat {
                                    attribute type {'contributor-count' },
                                    attribute value { $region-contributor-count }
                                },
                                element stat {
                                    attribute type {'contributor-percentage' },
                                    attribute value { xs:integer(($region-contributor-count div $contributor-count) * 100) }
                                }
                            )
                    else
                        ()
                }
        }
        </contributor-regions>
};

declare function contributors:institutions($include-persons as xs:boolean) as element() {
    
    let $institutions := 
        for $institution in $contributors:contributors/m:contributors/m:institution
        order by normalize-space(replace($institution/m:label/text(), $contributors:institution-prefixes,''))
        return $institution
    
    return
        <contributor-institutions xmlns="http://read.84000.co/ns/1.0">
        {
            for $institution in $institutions
            return
                element { node-name($institution) } {
                    $institution/@*,
                    attribute start-letter { upper-case(substring(normalize-space(replace($institution/m:label/text(), $contributors:institution-prefixes, '')), 1, 1)) },
                    $institution/*,
                    element sort-name { replace($institution/m:label/text(), concat($contributors:institution-prefixes, '\s(.*)'), '$2, $1') },
                    if($include-persons) then
                        $contributors:contributors/m:contributors/m:person[m:institution/@id eq $institution/@xml:id]
                    else
                        ()
                 }
        }
        </contributor-institutions>
};

declare function contributors:institution-types($include-stats as xs:boolean) as element() {

    let $institution-type-ids := $contributors:contributors/m:contributors/m:institution-type/@id
    let $institution-types-institutions-xmlids := $contributors:contributors/m:contributors/m:institution[@institution-type-id = $institution-type-ids]/@xml:id
    let $contributors-count := count($contributors:contributors/m:contributors/m:person[m:institution/@id = $institution-types-institutions-xmlids])
    
    return
        <contributor-institution-types xmlns="http://read.84000.co/ns/1.0">
        {
            for $institution-type in $contributors:contributors/m:contributors/m:institution-type
                let $institution-type-institution-xmlids := $contributors:contributors/m:contributors/m:institution[@institution-type-id eq $institution-type/@id]/@xml:id
            return
                element { node-name($institution-type) } {
                    $institution-type/@*,
                    $institution-type/*,
                    if($include-stats) then
                        let $institution-type-contributor-count := count($contributors:contributors/m:contributors/m:person[m:institution/@id = $institution-type-institution-xmlids])
                        return
                            (
                                element stat {
                                    attribute type {'contributor-count' },
                                    attribute value { $institution-type-contributor-count }
                                },
                                element stat {
                                    attribute type {'contributor-percentage' },
                                    attribute value { xs:integer(($institution-type-contributor-count div $contributors-count) * 100) }
                                }
                            )
                    else
                        ()
                }
        }
        </contributor-institution-types>
};

declare function contributors:next-id() as xs:integer {
    max($contributors:contributors/m:contributors/m:person/@xml:id ! substring-after(., 'person-') ! common:integer(.)) + 1
};

declare function contributors:update-person($person as element(m:person)?) as xs:string {
    
    let $person-id :=
        if($person/@xml:id) then
            $person/@xml:id
        else
            concat('person-', xs:string(contributors:next-id()))
    
    let $request-parameter-names := common:sort-trailing-number-in-string(request:get-parameter-names(), '-')
    
    let $new-value := 
        <person xmlns="http://read.84000.co/ns/1.0" 
            xml:id="{ $person-id }">
            <label>{  request:get-parameter('name', '') }</label>
            {
                for $request-parameter-name in $request-parameter-names
                return
                    if(starts-with($request-parameter-name, 'institution-id-') and request:get-parameter($request-parameter-name, '') gt '') then
                        <institution id="{ request:get-parameter($request-parameter-name, '') }"/>
                    else
                        ()
                ,
                for $request-parameter-name in $request-parameter-names
                return
                    if(starts-with($request-parameter-name, 'team-id-') and request:get-parameter($request-parameter-name, '') gt '') then
                        <team id="{ request:get-parameter($request-parameter-name, '') }"/>
                    else
                        ()
            }
        </person>
    
    let $parent := $contributors:contributors/m:contributors
    
    let $update := common:update('contributor-person', $person, $new-value, $parent, ())
    
    return
        $new-value//@xml:id
        
};

declare function contributors:delete($person as element(m:person)) as element()? {
    common:update('contributor-person', $person, (), (), ())
};

declare function contributors:next-team-id() as xs:integer {
    max($contributors:contributors/m:contributors/m:team/@xml:id ! substring-after(., 'team-') ! common:integer(.)) + 1
};

declare function contributors:update-team($team as element(m:team)?) as xs:string {
    
    let $team-id :=
        if($team/@xml:id) then
            $team/@xml:id
        else
            concat('team-', xs:string(contributors:next-team-id()))
    
    let $new-value := 
        element { QName('http://read.84000.co/ns/1.0', 'team') } {
            attribute xml:id { $team-id },
            if(request:get-parameter('hidden', '') eq '1') then
                attribute rend { 'hidden' }
            else
                ()
            ,
            element { QName('http://read.84000.co/ns/1.0', 'label') } {
                text { request:get-parameter('name', '') }
            }
        }
    
    let $parent := $contributors:contributors/m:contributors
    
    let $update := common:update('contributor-team', $team, $new-value, $parent, $parent/m:team[last()])
    
    return
        $new-value//@xml:id
};

declare function contributors:next-institution-id() as xs:integer {
    max($contributors:contributors/m:contributors/m:institution/@xml:id ! substring-after(., 'institution-') ! common:integer(.)) + 1
};

declare function contributors:update-institution($institution as element(m:institution)?) as xs:string {
    
    let $institution-id :=
        if($institution/@xml:id) then
            $institution/@xml:id
        else
            concat('institution-', xs:string(contributors:next-institution-id()))
    
    let $new-value := 
        <institution 
            xmlns="http://read.84000.co/ns/1.0" 
            xml:id="{ $institution-id }" 
            institution-type-id="{ request:get-parameter('institution-type-id', '') }" 
            region-id="{ request:get-parameter('region-id', '') }">
            <label>
            {
                request:get-parameter('name', '')
            }
            </label>
        </institution>
    
    let $parent := $contributors:contributors/m:contributors
    
    let $update := common:update('contributor-institution', $institution, $new-value, $parent, $parent/m:institution[last()])
    
    return
        $new-value//@xml:id
};
