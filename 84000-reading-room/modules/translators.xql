xquery version "3.1";

module namespace translators="http://read.84000.co/translators";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $translators:translators := doc(concat($common:data-path, '/operations/translators.xml'));
declare variable $translators:texts := collection($common:translations-path);
declare variable $translators:translator-prefixes := '(Dr\.|Prof\.)';
declare variable $translators:team-prefixes := '(Dr\.|The\.)';
declare variable $translators:institution-prefixes := '(The\s)';

declare function translators:translators($include-acknowledgements as xs:boolean) as node() {
    
    let $translators := 
        for $translator in $translators:translators/m:translators/m:translator
        order by normalize-space(replace($translator/m:name, $translators:translator-prefixes, ''))
        return $translator
    
    return
        <translators xmlns="http://read.84000.co/ns/1.0">
        {
            for $translator in $translators
            return
                translators:translator($translator/@xml:id, $include-acknowledgements)
        }
        </translators>
};

declare function translators:translator($id as xs:string, $include-acknowledgements as xs:boolean) as node() {
    
    let $translator := $translators:translators/m:translators/m:translator[@xml:id eq $id]
    
    return
        element { node-name($translator) } {
            $translator/@*,
            attribute start-letter { upper-case(substring(normalize-space(replace($translator/m:name, $translators:translator-prefixes, '')), 1, 1)) },
            $translator/*,
            if($include-acknowledgements) then
                translators:acknowledgements(concat('translators.xml#', $translator/@xml:id))
            else
                ()
        }
};

declare function translators:teams($include-acknowledgements as xs:boolean) as node(){

    let $teams := 
        for $team in $translators:translators/m:translators/m:team
        order by normalize-space(replace($team/text(), $translators:team-prefixes,''))
        return $team
    
    return
        <translator-teams xmlns="http://read.84000.co/ns/1.0">
        {
            for $team in $teams
            return
                translators:team($team/@xml:id, $include-acknowledgements)
        }
        </translator-teams>
};

declare function translators:team($id as xs:string, $include-acknowledgements as xs:boolean) as node() {
    
    let $team := $translators:translators/m:translators/m:team[@xml:id eq $id]
    
    return
        element { node-name($team) } {
            $team/@*,
            attribute start-letter { upper-case(substring(normalize-space(replace($team/text(), $translators:team-prefixes, '')), 1, 1)) },
            element name { $team/text() },
            if($include-acknowledgements) then
                for $tei in $translators:texts//tei:TEI[tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author[@sameAs eq concat('translators.xml#', $team/@xml:id)]]
                    let $acknowledgement := $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author[@sameAs eq concat('translators.xml#', $team/@xml:id)]
                return
                    translators:acknowledgement($tei, element tei:p { text { $acknowledgement } })
            else
                ()
        }
};

declare function translators:acknowledgements($uri as xs:string){
    
    let $query-options := 
        <options>
            <default-operator>and</default-operator>
            <phrase-slop>0</phrase-slop>
            <leading-wildcard>no</leading-wildcard>
        </options>
    
    let $translator-id := substring-after($uri, 'translators.xml#')
    
    return
        for $tei in $translators:texts//tei:TEI[tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author[@sameAs eq $uri]]
            let $translation-author := $tei//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author[@sameAs eq $uri][1]
            let $author-name := 
                if(data($translation-author) gt '') then
                    data($translation-author)
                else
                    $translators:translators/m:translators/m:translator[@xml:id eq $translator-id]/m:name/text()
            
            let $query := 
                <query>
                    <phrase occur="must">{ lower-case($author-name) }</phrase>
                </query>
                
            let $query-result := $tei//tei:front/tei:div[@type eq "acknowledgment"]/tei:p[ft:query(., $query, $query-options)]
            let $expanded := util:expand($query-result, "expand-xincludes=no")
            
            return
                translators:acknowledgement($tei, $expanded)
};

declare function translators:acknowledgement($tei, $content){
    let $title := tei-content:title($tei)
    let $translation-id := tei-content:id($tei)
    let $translation-status := $tei//tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status
    for $toh-key in $tei//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
        let $toh := translation:toh($tei, $toh-key)
    return
        element m:acknowledgement {
            attribute translation-id { $translation-id },
            attribute translation-status {$translation-status},
            element m:title { text { $title } },
            $toh,
            element tei:div {
                attribute type {'acknowledgment'},
                $content
            }
        }
};

declare function translators:regions($include-stats as xs:boolean){
    
    (: Total is the count of translators in institutions with regions :)
    let $region-ids := $translators:translators/m:translators/m:region/@id
    let $regions-institution-xmlids := $translators:translators/m:translators/m:institution[@region-id = $region-ids]/@xml:id
    let $translators-count := count($translators:translators/m:translators/m:translator[m:institution/@id = $regions-institution-xmlids])
    
    return
        <translator-regions xmlns="http://read.84000.co/ns/1.0">
        {
            for $region in $translators:translators/m:translators/m:region
                let $region-institution-xmlids := $translators:translators/m:translators/m:institution[@region-id eq $region/@id]/@xml:id
            return
                element { node-name($region) } {
                    $region/@*,
                    element name { $region/text() },
                    if($include-stats) then
                        let $region-translators-count := count($translators:translators/m:translators/m:translator[m:institution/@id = $region-institution-xmlids])
                        return
                            (
                                element stat {
                                    attribute type {'translator-count' },
                                    attribute value { $region-translators-count }
                                },
                                element stat {
                                    attribute type {'translator-percentage' },
                                    attribute value { xs:integer(($region-translators-count div $translators-count) * 100) }
                                }
                            )
                    else
                        ()
                }
        }
        </translator-regions>
};

declare function translators:institutions(){
    
    let $institutions := 
        for $institution in $translators:translators/m:translators/m:institution
        order by normalize-space(replace($institution/text(), $translators:institution-prefixes,''))
        return $institution
    
    return
        <translator-institutions xmlns="http://read.84000.co/ns/1.0">
        {
            for $institution in $institutions
            return
                element { node-name($institution) } {
                    $institution/@*,
                    attribute start-letter { upper-case(substring(normalize-space(replace($institution/text(), $translators:institution-prefixes, '')), 1, 1)) },
                    element name { $institution/text() }
                 }
        }
        </translator-institutions>
};

declare function translators:institution-types($include-stats as xs:boolean){

    (: Total is the count of translators in institutions with regions :)
    let $institution-type-ids := $translators:translators/m:translators/m:institution-type/@id
    let $institution-types-institutions-xmlids := $translators:translators/m:translators/m:institution[@institution-type-id = $institution-type-ids]/@xml:id
    let $translators-count := count($translators:translators/m:translators/m:translator[m:institution/@id = $institution-types-institutions-xmlids])
    
    return
        <translator-institution-types xmlns="http://read.84000.co/ns/1.0">
        {
            for $institution-type in $translators:translators/m:translators/m:institution-type
                let $institution-type-institution-xmlids := $translators:translators/m:translators/m:institution[@institution-type-id eq $institution-type/@id]/@xml:id
            return
                element { node-name($institution-type) } {
                    $institution-type/@*,
                    element name { $institution-type/text() },
                    if($include-stats) then
                        let $institution-type-translators-count := count($translators:translators/m:translators/m:translator[m:institution/@id = $institution-type-institution-xmlids])
                        return
                            (
                                element stat {
                                    attribute type {'translator-count' },
                                    attribute value { $institution-type-translators-count }
                                },
                                element stat {
                                    attribute type {'translator-percentage' },
                                    attribute value { xs:integer(($institution-type-translators-count div $translators-count) * 100) }
                                }
                            )
                    else
                        ()
                }
        }
        </translator-institution-types>
};

declare function translators:next-id() as xs:integer {
    max($translators:translators/m:translators/m:translator/@xml:id ! substring-after(., 'translator-') ! xs:integer(concat('0', .))) + 1
};

declare function translators:update($translator as node()?) as xs:string {
    
    let $translator-id :=
        if($translator/@xml:id) then
            $translator/@xml:id
        else
            concat('translator-', xs:string(translators:next-id()))
    
    let $new-value := 
        <translator xmlns="http://read.84000.co/ns/1.0" 
            xml:id="{ $translator-id }">
            <name>{  request:get-parameter('name', '') }</name>
            {
                for $index in 0 to count($translator/m:institution/@id)
                return
                    if(request:get-parameter(concat('institution-id-', $index), '') gt '') then
                        <institution id="{ request:get-parameter(concat('institution-id-', $index), '') }"/>
                    else
                        ()
            }
            {
                for $index in 0 to count($translator/m:team/@id)
                return
                    if(request:get-parameter(concat('team-id-', $index), '') gt '') then
                        <team id="{ request:get-parameter(concat('team-id-', $index), '') }"/>
                    else
                        ()
            }
        </translator>
    
    let $parent := $translators:translators/m:translators
    
    return
        if(common:update('translator', $translator, $new-value, $parent, ())) then
            $translator-id
        else
            ''
        
};

declare function translators:delete($translator as node()){
    common:update('sponsor', $translator, (), (), ())
};

declare function translators:next-team-id() as xs:integer {
    max($translators:translators/m:translators/m:team/@xml:id ! substring-after(., 'team-') ! xs:integer(concat('0', .))) + 1
};

declare function translators:update-team($team as node()?) as xs:string {
    
    let $team-id :=
        if($team/@xml:id) then
            $team/@xml:id
        else
            concat('team-', xs:string(translators:next-team-id()))
    
    let $new-value := 
        <team xmlns="http://read.84000.co/ns/1.0" xml:id="{ $team-id }">{
            request:get-parameter('name', '')
        }</team>
    
    let $parent := $translators:translators/m:translators
    
    return
        if(common:update('team', $team, $new-value, $parent, $parent/m:team[last()])) then
            $team-id
        else
            ''
};

declare function translators:next-institution-id() as xs:integer {
    max($translators:translators/m:translators/m:institution/@xml:id ! substring-after(., 'institution-') ! xs:integer(concat('0', .))) + 1
};

declare function translators:update-institution($institution as node()?) as xs:string {
    
    let $institution-id :=
        if($institution/@xml:id) then
            $institution/@xml:id
        else
            concat('institution-', xs:string(translators:next-institution-id()))
    
    let $new-value := 
        <institution 
            xmlns="http://read.84000.co/ns/1.0" 
            xml:id="{ $institution-id }" 
            institution-type-id="{ request:get-parameter('institution-type-id', '') }" 
            region-id="{ request:get-parameter('region-id', '') }">{
            request:get-parameter('name', '')
        }</institution>
    
    let $parent := $translators:translators/m:translators
    
    return
        if(common:update('institution', $institution, $new-value, $parent, $parent/m:institution[last()])) then
            $institution-id
        else
            ''
};
