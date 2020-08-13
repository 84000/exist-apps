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

declare function contributors:persons($include-acknowledgements as xs:boolean, $count-contributions as xs:boolean) as element(m:contributor-persons) {
    
    let $contributors := 
        for $contributor in $contributors:contributors/m:contributors/m:person
        order by normalize-space(replace($contributor/m:label, $contributors:person-prefixes, ''))
        return $contributor
    
    return
        <contributor-persons xmlns="http://read.84000.co/ns/1.0">
        {
            for $contributor in $contributors
            return
                contributors:person($contributor/@xml:id, $include-acknowledgements, $count-contributions)
        }
        </contributor-persons>
};

declare function contributors:person($id as xs:string, $include-acknowledgements as xs:boolean, $count-contributions as xs:boolean) as element(m:person) {
    
    let $contributor := $contributors:contributors/m:contributors/m:person[@xml:id eq $id]
    let $contributor-uri := concat('contributors.xml#', $contributor/@xml:id)

    return
        element { node-name($contributor) } {
            $contributor/@*,
            attribute start-letter { upper-case(substring(normalize-space(replace($contributor/m:label, $contributors:person-prefixes, '')), 1, 1)) },
            if($count-contributions) then
                let $contributions :=
                    $contributors:texts//tei:TEI[
                        descendant::tei:author[@ref eq $contributor-uri][parent::tei:titleStmt]
                        | descendant::tei:editor[@ref eq $contributor-uri][parent::tei:titleStmt]
                        | descendant::tei:consultant[@ref eq $contributor-uri][parent::tei:titleStmt]
                    ]
                return
                    attribute count-contributions { count($contributions) }
            else ()
            ,
            $contributor/*,
            element sort-name { replace($contributor/m:label, concat($contributors:person-prefixes, '\s(.*)'), '$2, $1') },
            if($include-acknowledgements) then
                contributors:acknowledgements($contributor-uri)
            else
                ()
        }
};

declare function contributors:acknowledgements($contributor-uri as xs:string) as element(m:acknowledgement)* {
    
    (: Loop through texts to which this person has contributed :)
    for $tei in 
        $contributors:texts//tei:TEI[
            descendant::tei:author[@ref eq $contributor-uri][parent::tei:titleStmt]
            | descendant::tei:editor[@ref eq $contributor-uri][parent::tei:titleStmt]
            | descendant::tei:consultant[@ref eq $contributor-uri][parent::tei:titleStmt]
        ]
        
        (: Get their expression in this text :)
        let $translation-contributor := (
            $tei//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author[@ref eq $contributor-uri]
            | $tei//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor[@ref eq $contributor-uri]
            | $tei//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:consultant[@ref eq $contributor-uri]
        )[1]
        
        let $id := substring-after($contributor-uri, 'contributors.xml#')
        
        let $contributor-name := 
            if($translation-contributor/text()) then
                $translation-contributor/text()
            else
                $contributors:contributors/m:contributors/m:person[@xml:id eq $id]/m:label/text()
        
        let $acknowledgment := $tei//tei:front/tei:div[@type eq "acknowledgment"]
        
        let $mark-contributor-name := normalize-space(lower-case(replace($contributor-name, $contributors:person-prefixes, '')))
        
        let $marked-paragraphs := common:mark-nodes($acknowledgment/tei:p, $mark-contributor-name, 'phrase')
        
    return
        local:acknowledgement($tei, $marked-paragraphs[exist:match], $translation-contributor)
};

declare function local:acknowledgement($tei as element(tei:TEI), $paragraphs as element()*, $contribution as element()?) as element(m:acknowledgement)* {

    element m:acknowledgement {
        attribute translation-id { tei-content:id($tei) },
        attribute translation-status { tei-content:translation-status($tei) },
        attribute translation-status-group { tei-content:translation-status-group($tei) },
        element m:title { text { tei-content:title($tei) } },
        translation:toh($tei, ''),
        element m:contribution {
            attribute node-name { local-name($contribution) },
            $contribution/@role,
            $contribution/@ref,
            normalize-space($contribution/text())
        },
        element tei:div {
            attribute type {'acknowledgment'},
            $paragraphs
        }
    }
    
};

declare function contributors:teams($include-hidden as xs:boolean, $include-acknowledgements as xs:boolean, $include-persons as xs:boolean) as element(m:contributor-teams){
    
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
                    local:acknowledgement($tei, element tei:p { $acknowledgement }, ())
            else
                (),
            if($include-persons) then
                $contributors:contributors/m:contributors/m:person[m:team/@id eq $id]
            else
                ()
        }
};

declare function contributors:regions($include-stats as xs:boolean) as element(m:contributor-regions) {
    
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

declare function contributors:institutions($include-persons as xs:boolean) as element(m:contributor-institutions) {
    
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

declare function contributors:institution-types($include-stats as xs:boolean) as element(m:contributor-institution-types) {

    let $institution-types := 
        for $institution-type in $contributors:contributors/m:contributors/m:institution-type
            let $institution-type-id := $institution-type/@id
            let $institution-type-institutions-ids := $contributors:contributors/m:contributors/m:institution[@institution-type-id eq $institution-type-id]/@xml:id ! string()
            let $contributors := $contributors:contributors/m:contributors/m:person[m:institution/@id = $institution-type-institutions-ids]
        return
            element { node-name($institution-type) } {
                $institution-type/@*,
                $institution-type/*,
                if($include-stats) then
                    element affiliated-contributors {
                        for $contributor in $contributors
                        return (
                            element contributor {
                                attribute id { $contributor/@xml:id }
                            }
                         )
                     }
                else
                    ()
            }
    
    let $affiliated-contributors-count := count( distinct-values($institution-types//m:contributor/@id) )
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'contributor-institution-types') } {
            attribute affiliated-contributors-count { $affiliated-contributors-count },
            if($include-stats) then
                for $institution-type in $institution-types
                    let $institution-type-id := $institution-type/@id
                    let $contributors-count := count($institution-type//m:contributor)
                    let $contributors-percent := xs:integer(($contributors-count div $affiliated-contributors-count) * 100)
                    let $affiliated-to-other-ids := $institution-types[not(@id eq $institution-type-id)]//m:contributor/@id
                    let $contributors-this-type-only-count := count($institution-type//m:contributor[not(@id = $affiliated-to-other-ids)])
                    let $contributors-this-type-only-percent := xs:integer(($contributors-this-type-only-count div $affiliated-contributors-count) * 100)
                return
                    element { node-name($institution-type) } {
                        $institution-type/@*,
                        attribute contributors-count { $contributors-count },
                        attribute contributors-percent { $contributors-percent },
                        attribute contributors-this-type-only-count { $contributors-this-type-only-count },
                        attribute contributors-this-type-only-percent { $contributors-this-type-only-percent },
                        $institution-type/node()(:,
                        $affiliated-to-other-ids[. = ($institution-type//m:contributor/@id ! string())] ! string():)
                    }
            else
                $institution-types
        }
};

declare function local:next-id() as xs:integer {
    max($contributors:contributors/m:contributors/m:person/@xml:id ! substring-after(., 'person-') ! common:integer(.)) + 1
};

declare function contributors:update-person($person as element(m:person)?) as xs:string {
    
    let $person-id :=
        if($person/@xml:id) then
            $person/@xml:id
        else
            concat('person-', xs:string(local:next-id()))
    
    let $request-parameter-names := common:sort-trailing-number-in-string(request:get-parameter-names(), '-')
    
    let $new-value := 
        <person xmlns="http://read.84000.co/ns/1.0" 
            xml:id="{ $person-id }">{
            
                $common:line-ws,
                <label>{  request:get-parameter('name', '') }</label>,
                
                for $request-parameter-name in $request-parameter-names
                return
                    if(starts-with($request-parameter-name, 'institution-id-') and request:get-parameter($request-parameter-name, '') gt '') then (
                        $common:line-ws,
                        <institution id="{ request:get-parameter($request-parameter-name, '') }"/>
                    )
                    else if(starts-with($request-parameter-name, 'team-id-') and request:get-parameter($request-parameter-name, '') gt '') then (
                        $common:line-ws,
                        <team id="{ request:get-parameter($request-parameter-name, '') }"/>
                    )
                    else if($request-parameter-name eq 'affiliation[]') then
                        for $affiliation in request:get-parameter('affiliation[]', '')
                        return (
                            $common:line-ws,
                            <affiliation type="{ $affiliation }"/>
                        )
                    else
                        ()
                 ,
                 $common:node-ws
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

declare function local:next-institution-id() as xs:integer {
    max($contributors:contributors/m:contributors/m:institution/@xml:id ! substring-after(., 'institution-') ! common:integer(.)) + 1
};

declare function contributors:update-institution($institution as element(m:institution)?) as xs:string {
    
    let $institution-id :=
        if($institution/@xml:id) then
            $institution/@xml:id
        else
            concat('institution-', xs:string(local:next-institution-id()))
    
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
