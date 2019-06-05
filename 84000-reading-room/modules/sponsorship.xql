xquery version "3.1";

module namespace sponsorship="http://read.84000.co/sponsorship";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";

declare function sponsorship:statuses($selected-status as xs:string?) as element()  {
    element { QName('http://read.84000.co/ns/1.0', 'sponsorship-statuses') } {(
        common:add-selected(
            <status value="">No sponsorship status</status>, 
            $selected-status
        ),
        common:add-selected(
            <status value="full">Fully sponsored</status>, 
            $selected-status
        ),
        common:add-selected(
           <status value="part">Partly sponsored</status>, 
           $selected-status
        ),
        common:add-selected(
            <status value="available">Available for sponsorship</status>, 
            $selected-status
        ),
        common:add-selected(
            <status value="priority">Priority for sponsorship</status>, 
            $selected-status
        ),
        common:add-selected(
            <status value="reserved">Sponsorship reserved</status>, 
            $selected-status
        )
    )}
};

declare function sponsorship:cost-estimate($tei as element()) as element()* {
    
    let $cost-groups := doc(concat($common:data-path, '/config/cost-groups.xml'))

    let $sponsor-status := $tei//tei:titleStmt/@sponsored
    let $bibl := tei-content:source-bibl($tei, '')
    let $count-pages := $bibl/tei:location/@count-pages/xs:integer(.)
    let $dollars-per-page := $cost-groups/m:cost-groups/@cost-per-page
    let $basic-cost := $count-pages * $dollars-per-page
    let $rounded-cost := ceiling($basic-cost div 1000) * 1000
    
    let $cost-group := $cost-groups//m:cost-group[xs:integer(@page-upper) ge $count-pages][1]
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'cost') } {
            attribute currency { $cost-groups/m:cost-groups/@currency},
            attribute pages { $count-pages },
            attribute per-page-price { $dollars-per-page },
            attribute basic-cost { $basic-cost },
            attribute rounded-cost { $rounded-cost },
            attribute cost-group { xs:integer($cost-group/xs:integer(@page-upper) * $dollars-per-page) },
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