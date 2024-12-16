xquery version "3.1";

module namespace contributors="http://read.84000.co/contributors";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";
import module namespace functx="http://www.functx.com";

declare variable $contributors:contributors := doc(concat($common:data-path, '/operations/contributors.xml'));
declare variable $contributors:contributor-types := doc(concat($common:data-path, '/config/contributor-types.xml'));
declare variable $contributors:texts := collection($common:translations-path);
declare variable $contributors:person-prefixes := '(Dr\.|Prof\.|Ven\.|Rev\.)';
declare variable $contributors:team-prefixes := '(Dr\.|The|Prof\.)';
declare variable $contributors:institution-prefixes := '(The|University\s+of)';

declare function contributors:contributor-uri($contributor-id as xs:string) as xs:string* {
    lower-case(concat('eft:', $contributor-id))
};

declare function contributors:contributor-id($contributor-uri as xs:string) as xs:string {
    lower-case(replace($contributor-uri, '^eft:', '', 'i'))
};

declare function contributors:persons() as element(m:contributor-persons) {
    
    element { QName('http://read.84000.co/ns/1.0', 'contributor-persons') } {
        for $contributor in $contributors:contributors/m:contributors/m:person
        let $person := contributors:person($contributor/@xml:id, false())
        order by $person/m:sort-name
        return
            $person
    }
    
};

declare function contributors:person($person-id as xs:string, $include-acknowledgements as xs:boolean) as element(m:person) {
    
    let $contributor := $contributors:contributors/id(lower-case($person-id))[self::m:person]
    
    where $contributor
    return
        element { node-name($contributor) } {
        
            $contributor/@*,
            attribute start-letter { upper-case(substring(normalize-space(replace($contributor/m:label, $contributors:person-prefixes, '')), 1, 1)) },
            attribute count-contributions { count($contributor/m:instance[@type eq 'translation-contribution']) },
            
            $contributor/*,
            element sort-name { lower-case(replace($contributor/m:label, concat($contributors:person-prefixes, '\s+'), '')) },
            if($include-acknowledgements) then
                local:acknowledgements($contributor)
            else ()
            
        }
        
};

declare function local:acknowledgements($contributor as element()) as element(m:acknowledgement)* {
    
    (: Loop through texts to which this person has contributed :)
    for $tei in $contributors:texts/id($contributor/m:instance[@type eq 'translation-contribution']/@id)/ancestor::tei:TEI
    let $text-id := tei-content:id($tei)
    group by $text-id
    return
        contributors:acknowledgement($contributor, $tei[1])
        
};

declare function contributors:acknowledgement($contributors as element()*, $tei as element(tei:TEI)) as element(m:acknowledgement) {
    
    let $contributions := $tei/id($contributors/m:instance[@type eq 'translation-contribution']/@id)[self::tei:author | self::tei:editor | self::tei:consultant]
    
    let $contributor-names := distinct-values(($contributions ! string-join(descendant::text(), ' '), $contributors/m:label ! string-join(text()) ! normalize-space(.) ! lower-case(.) ! replace(., $contributors:person-prefixes, '') ! normalize-space(.)))
    
    let $acknowledgment := $tei//tei:front/tei:div[@type eq "acknowledgment"]
    
    let $marked-paragraphs := common:mark-nodes($acknowledgment/tei:p, $contributor-names, 'phrase')
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'acknowledgement') } {
            attribute translation-id { tei-content:id($tei) },
            attribute status { tei-content:publication-status($tei) },
            attribute status-group { tei-content:publication-status-group($tei) },
            element title { tei-content:title-any($tei) },
            translation:toh($tei, ''),
            for $contribution in $contributions
            return
                element contribution {
                    attribute node-name { local-name($contribution) },
                    $contribution/@role,
                    $contribution/@xml:id,
                    string-join($contribution/text()) ! normalize-space(.)
                }
            ,
            $marked-paragraphs
        }
    
};

declare function contributors:teams($include-hidden as xs:boolean, $include-persons as xs:boolean) as element(m:contributor-teams) {
    
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
        element { QName('http://read.84000.co/ns/1.0', 'contributor-teams') } {
            for $team in $teams
            return
                contributors:team($team/@xml:id, false(), $include-persons)
        }
};

declare function contributors:team($team-id as xs:string, $include-acknowledgements as xs:boolean, $include-persons as xs:boolean) as element(m:team)? {
    
    let $team-id := lower-case($team-id)
    let $team := $contributors:contributors/id($team-id)
    
    let $team-texts := 
        if($include-acknowledgements or $include-persons) then
            $contributors:texts/id($team/m:instance/@id)[self::tei:author]/ancestor::tei:TEI
        else ()
    
    where $team
    return
        element { node-name($team) } {
        
            $team/@*[not(local-name() = ('start-letter', 'sort-name'))],
            attribute start-letter { upper-case(substring(normalize-space(replace($team/m:label, $contributors:team-prefixes, '')), 1, 1)) },
            element sort-name { lower-case(replace($team/m:label, concat($contributors:team-prefixes, '\s+'), '')) },
            $team/*,
            
            if($include-acknowledgements) then
                for $tei in $team-texts
                let $text-id := tei-content:id($tei)
                group by $text-id
                return
                    contributors:acknowledgement($team, $tei[1])
                    
            else (),
            if($include-persons) then
                
                let $contributor-types := $contributors:contributor-types//m:contributor-type
                
                (: Sort by role :)
                for $person in $contributors:contributors/m:contributors/m:person[m:team/@id = $team/@xml:id]
                let $person-roles := $team-texts/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:*[@xml:id = $person/m:instance/@id]/@role/string()
                let $person-top-role := min($contributor-types[@role/string() = $person-roles] ! functx:index-of-node($contributor-types, .))
                (: Push no role to last :)
                let $sort-value := ($person-top-role, count($contributor-types))[1]
                order by $sort-value ascending
                return 
                    element { node-name($person) } {
                        $person/@*,
                        attribute sort-value { $sort-value },
                        $person/*
                    }
                    
            else ()
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
                    element sort-name { lower-case(replace($institution/m:label, concat($contributors:institution-prefixes, '\s+'), '')) },
                    $institution/*,
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

declare function contributors:next-person-id() as xs:integer {
    max($contributors:contributors/m:contributors/m:person/@xml:id ! substring-after(., 'person-') ! common:integer(.)) + 1
};

declare function contributors:update-person($person as element(m:person)?) as xs:string {
    
    let $parent := $contributors:contributors/m:contributors
    
    let $person-id :=
        if($person[@xml:id]) then
            $person/@xml:id
        else
            concat('person-', xs:string(contributors:next-person-id()))
    
    let $request-parameter-names := common:sort-trailing-number-in-string(request:get-parameter-names(), '-')
    
    let $new-value := 
        element { QName('http://read.84000.co/ns/1.0', 'person') } {
        
            attribute xml:id { $person-id },
            attribute timestamp { current-dateTime() },
            
            $common:line-ws,
            
            element label {  
                text { request:get-parameter('name', '') }
            },
            
            for $request-parameter-name in $request-parameter-names
            return
                if(starts-with($request-parameter-name, 'institution-id-') and request:get-parameter($request-parameter-name, '') gt '') then (
                    $common:line-ws,
                    element institution { 
                        attribute id { request:get-parameter($request-parameter-name, '') } 
                    }
                )
                else if(starts-with($request-parameter-name, 'team-id-') and request:get-parameter($request-parameter-name, '') gt '') then (
                    $common:line-ws,
                    element team { 
                        attribute id { request:get-parameter($request-parameter-name, '') } 
                    }
                )
                else if($request-parameter-name eq 'affiliation[]') then
                    for $affiliation in request:get-parameter('affiliation[]', '')
                    return (
                        $common:line-ws,
                        element affiliation { 
                            attribute type { $affiliation } 
                        }
                    )
                else ()
             ,
             
             (:for $element in $person/*[not(self::m:label | self::m:institution | self::m:team | self::m:affiliation)]:)
             for $element in $person/*[not(local-name(.) = ('label','institution','team','affiliation'))]
             return (
                $common:line-ws,
                $element
             ),
             
             $common:node-ws
             
        }
    
    let $update := common:update('contributor-person', $person, $new-value, $parent, ())
    
    return
        $new-value//@xml:id
        
};

declare function contributors:delete($element as element()) as element()? {
    if($element[self::m:person | self::m:team | self::m:institution][parent::m:contributors]) then
        common:update('contributor-delete', $element, (), (), ())
    else ()
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
            attribute timestamp { current-dateTime() },
            
            if(request:get-parameter('hidden', '') eq '1') then
                attribute rend { 'hidden' }
            else ()
            ,
            
            $common:line-ws,
            element { QName('http://read.84000.co/ns/1.0', 'label') } {
                text { request:get-parameter('name', '') }
            },
            
            (:for $element in $team/*[not(self::m:label)]:)
            for $element in $team/*[not(local-name(.) eq 'label')]
            return (
                $common:line-ws,
                $element
            )
            
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
        element { QName('http://read.84000.co/ns/1.0','institution') } {
        
            attribute xml:id { $institution-id },
            attribute timestamp { current-dateTime() },
            
            attribute institution-type-id { request:get-parameter('institution-type-id', '') },
            attribute region-id { request:get-parameter('region-id', '') },
            
            element label {
                text { request:get-parameter('name', '') }
            },
            
            (:for $element in $institution/*[not(self::m:label)]:)
            for $element in $institution/*[not(local-name(.) eq 'label')]
            return (
                $common:line-ws,
                $element
            )
        }
    
    let $parent := $contributors:contributors/m:contributors
    
    let $update := common:update('contributor-institution', $institution, $new-value, $parent, $parent/m:institution[last()])
    
    return
        $new-value//@xml:id
};
