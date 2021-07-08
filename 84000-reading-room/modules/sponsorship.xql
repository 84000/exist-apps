xquery version "3.1";

module namespace sponsorship="http://read.84000.co/sponsorship";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "translation.xql";

declare variable $sponsorship:data := doc(concat($common:data-path, '/operations/sponsorship.xml'));
declare variable $sponsorship:cost-groups := doc(concat($common:app-config, '/', 'cost-groups.xml'));

declare variable $sponsorship:sponsorship-statuses :=
    <sponsorship-statuses xmlns="http://read.84000.co/ns/1.0">
        <status id="no-sponsorship">
            <label>No sponsorship</label>
        </status>
        <status id="full">
            <label>Fully sponsored</label>
        </status>
        <status id="part">
            <label>Part sponsored</label>
        </status>
        <status id="available">
            <label>Available for sponsorship</label>
        </status>
        <status id="priority">
            <label>Priority for sponsorship</label>
        </status>
        <status id="reserved">
            <label>Sponsorship reserved</label>
        </status>
    </sponsorship-statuses>;
    
declare variable $sponsorship:sponsorship-groups :=
    <sponsorship-groups xmlns="http://read.84000.co/ns/1.0">
        <group id="sponsored">
            <label>Sponsored texts</label>
        </group>
        <group id="fully-sponsored">
            <label>Fully sponsored texts</label>
        </group>
        <group id="part-sponsored">
            <label>Part sponsored texts</label>
        </group>
        <group id="priority">
            <label>Prioritised for sponsorship</label>
        </group>
        <group id="reserved">
            <label>Sponsorship reserved</label>
        </group>
        <group id="available">
            <label>Available for sponsorship</label>
        </group>
        <group id="no-status">
            <label>No sponsorship status</label>
        </group>
    </sponsorship-groups>;

declare function sponsorship:text-status($text-id as xs:string, $estimate-cost as xs:boolean) as element() {
    
    let $project := $sponsorship:data//m:project[m:text[@text-id eq $text-id]][1]
    
    let $estimate-teis :=
        if($estimate-cost) then
            if($project) then
                for $project-text-id in $project/m:text/@text-id
                return
                    tei-content:tei($project-text-id, 'translation')
             else
                tei-content:tei($text-id, 'translation')
        else
            ()
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'sponsorship-status') } {(
            attribute project-id { $project/@id },
            $project/m:cost,
            if($estimate-teis) then
                element estimate {
                    sponsorship:cost-estimate($estimate-teis)
                }
            else ()
            ,
            $project/m:text,
            if(not($project)) then
                $sponsorship:sponsorship-statuses//m:status[@id = 'no-sponsorship']
            else
                if ($project[count(m:cost/m:part[@status eq 'sponsored']) eq count(m:cost/m:part)]) then
                    $sponsorship:sponsorship-statuses//m:status[@id = 'full']
                else
                    $sponsorship:sponsorship-statuses//m:status[@id = 'available']
                ,
                if ($project
                        [count(m:cost/m:part) gt 1] (: multiple parts :)
                        [m:cost/m:part[@status eq 'sponsored']] (: sponsored parts :)
                        [count(m:cost/m:part) gt count(m:cost/m:part[@status eq 'sponsored'])] (: not all parts sponsored :)
                    )
                    then
                    $sponsorship:sponsorship-statuses//m:status[@id = 'part']
                else
                    ()
                ,
                if ($project[m:cost/m:part/@status eq 'priority']) then
                    $sponsorship:sponsorship-statuses//m:status[@id = 'priority']
                else
                    ()
                ,
                if ($project[m:cost/m:part/@status eq 'reserved']) then
                    $sponsorship:sponsorship-statuses//m:status[@id = 'reserved']
                else
                    ()
        )}
};

declare function sponsorship:text-ids($sponsorship-group as xs:string) as xs:string* {
    (
        if($sponsorship-group eq 'sponsored')then
            (: Any project with a part sponsored :)
            $sponsorship:data//m:project
                [m:cost/m:part/@status eq 'sponsored']/m:text/@text-id
        else if($sponsorship-group eq 'fully-sponsored')then
            (: Any project with all parts sponsored :)
            $sponsorship:data//m:project
                [count(m:cost/m:part[@status eq 'sponsored']) eq count(m:cost/m:part)]/m:text/@text-id
        else if($sponsorship-group eq 'part-sponsored')then
            (: Any project with multiple parts and not all parts sponsored :)
            $sponsorship:data//m:project
                [count(m:cost/m:part) gt 1] (: multiple parts :)
                [m:cost/m:part[@status eq 'sponsored']] (: sponsored parts :)
                [count(m:cost/m:part) gt count(m:cost/m:part[@status eq 'sponsored'])] (: not all parts sponsored :)/m:text/@text-id
        else if($sponsorship-group eq 'available')then
            (: Any project with a part not sponsored :)
            $sponsorship:data//m:project
                [count(m:cost/m:part[@status eq 'sponsored']) lt count(m:cost/m:part)]/m:text/@text-id
        else if($sponsorship-group eq 'priority')then
            (: Any project with a part with priority :)
            $sponsorship:data//m:project
                [m:cost/m:part/@status eq 'priority']/m:text/@text-id
        else if($sponsorship-group eq 'reserved')then
            (: Any project with a part reserved :)
            $sponsorship:data//m:project
                [m:cost/m:part/@status eq 'reserved']/m:text/@text-id
        else
            (: All texts with a sponsorship status :)
            $sponsorship:data//m:project/m:text/@text-id
    )
};

declare function sponsorship:cost-estimate($teis as element(tei:TEI)*) as element()* {
    
    (: This need modifying after the migration removing tei:titleStmt/@sponsored :)
    
    let $sponsor-status := $teis[1]//tei:titleStmt/@sponsored
    let $bibls := 
        for $tei in $teis
        return
            tei-content:source-bibl($tei, '')
    let $count-pages := sum($bibls/tei:location/@count-pages ! common:integer(.))
    
    let $cost-per-page := $sponsorship:cost-groups/m:cost-groups/@cost-per-page
    let $basic-cost := $count-pages * $cost-per-page
    let $rounded-cost := ceiling($basic-cost div 1000) * 1000
    
    let $cost-group := $sponsorship:cost-groups//m:cost-group[xs:integer(@page-upper) ge $count-pages][1]
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'cost') } {
            attribute currency { $sponsorship:cost-groups/m:cost-groups/@currency },
            attribute pages { $count-pages },
            attribute per-page-price { $cost-per-page },
            attribute basic-cost { $basic-cost },
            attribute rounded-cost { $rounded-cost },
            (: attribute cost-group { xs:integer($cost-group/xs:integer(@page-upper) * $cost-per-page) },:)
            for $i in (1 to xs:integer($cost-group/@parts)) 
            return
                element part {
                    attribute amount { ceiling(($rounded-cost div xs:integer($cost-group/@parts)) div 1000) * 1000 },
                    if ($sponsor-status = ('full')) then 
                        attribute status { 'sponsored' }
                    else if ($sponsor-status = ('part') and $i eq 1) then 
                        attribute status { 'sponsored' }
                    else if ($sponsor-status = ('reserved')) then 
                        attribute status { 'reserved' }
                    else if ($sponsor-status = ('priority')) then 
                        attribute status { 'priority' }
                    else
                        ()
                }
        }
        
};

declare function sponsorship:project-posted($project-id as xs:string) as element()* {
    
    let $project-id :=
        if(request:get-parameter('sponsorship-project-id', '') gt '') then
            request:get-parameter('sponsorship-project-id', '')
        else
            $project-id
    
    let $count-pages := common:integer(request:get-parameter('sponsorship-pages', '0'))
    let $cost-per-page := $sponsorship:cost-groups/m:cost-groups/@cost-per-page
    let $basic-cost := $count-pages * $cost-per-page
    let $estimated-rounded-cost := ceiling($basic-cost div 1000) * 1000
    let $rounded-cost := common:integer(request:get-parameter('rounded-cost', $estimated-rounded-cost))
    let $cost-group := $sponsorship:cost-groups//m:cost-group[xs:integer(@page-upper) ge $count-pages][1]
    
    let $texts := 
        for $parameter-name in request:get-parameter-names()
            where contains($parameter-name, 'sponsorship-text-')
            let $index := common:integer(tokenize($parameter-name, '-')[last()])
            order by $index
        return
            let $text-id := request:get-parameter(concat('sponsorship-text-', $index), '')
            where $text-id gt ''
            return
                element { QName("http://read.84000.co/ns/1.0", "text") } {
                    attribute text-id { $text-id }
                }
    
    let $cost-parts := 
        for $parameter-name in request:get-parameter-names()
            where contains($parameter-name, 'cost-part-amount-')
            let $index := common:integer(tokenize($parameter-name, '-')[last()])
            order by $index
        return
            let $cost-part-amount := common:integer(request:get-parameter(concat('cost-part-amount-', $index), ''))
            let $cost-part-status := request:get-parameter(concat('cost-part-status-', $index), '')
            where $cost-part-amount gt 0 and $cost-part-status = ('available', 'priority', 'reserved', 'sponsored')
            return
                element { QName("http://read.84000.co/ns/1.0", "part") } {
                    attribute amount { $cost-part-amount },
                    if($cost-part-status = ('priority', 'reserved', 'sponsored')) then
                        attribute status { $cost-part-status }
                    else
                        ()
                }
    
    let $cost-parts := 
        if(not($cost-parts) and $rounded-cost gt 0) then
            element { QName("http://read.84000.co/ns/1.0", "part") } {
                attribute amount { $rounded-cost }
            }
        else
            $cost-parts
    
    return
        if($cost-parts) then
           element { QName("http://read.84000.co/ns/1.0", "project") }{
               attribute id { $project-id },
               $texts,
               element cost {
                   attribute currency { $sponsorship:cost-groups/m:cost-groups/@currency },
                   attribute pages { $count-pages },
                   attribute per-page-price { $cost-per-page },
                   attribute basic-cost { $basic-cost },
                   attribute rounded-cost { $rounded-cost },
                   (: attribute cost-group { xs:integer($cost-group/xs:integer(@page-upper) * $cost-per-page) },:)
                   $cost-parts
               }
           }
        else
            ()
};
