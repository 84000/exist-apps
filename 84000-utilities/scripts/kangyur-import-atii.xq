xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace functx="http://www.functx.com";

declare variable $local:kangyur-work-id := 'UT4CZ5369';
declare variable $local:kangyur-tei := collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[tei:location/@work = $local:kangyur-work-id]];
declare variable $local:source-path := '/db/apps/84000-data/uploads/kangyur-import/atii/DergeKangyur.xml';
declare variable $local:text-refs-path := '/db/apps/84000-data/config/linked-data/text-refs.xml';
declare variable $local:target-path := '/db/apps/84000-data/uploads/kangyur-import/kangyur-data-atii.xml';
declare variable $local:import-attributions := doc($local:source-path)/m:data/*;
declare variable $local:text-refs := doc($local:text-refs-path)//m:text;

(:
    TO DO:
    1. Loop through each toh-key in the kangyur data
       a. Skip where there's a note that this import file has already been imported
    2. Validate that there's a atii-id entry in text-refs
       a. Try to assign atii-ids to each of those text-ref records that don't have one
       b. Manually assign remaining
    3. Validate that there are atii attributions based on the atii-id
       a. Flag where there's no attribution data
    4. Loop through each atii attribution for the text
    5. Try to find an entity based on names
       a. Associate where an entity is found
       b. Create an entity where one is missing
       c. In both cases store the BDRC person reference
    6. Update the TEI with the attribution
       b Add a note that this has been imported from this source file
:)

declare function local:texts(){
    for $tei in $local:kangyur-tei
        let $text-id := tei-content:id($tei)
        order by $text-id
        
        for $bibl in $tei//tei:fileDesc/tei:sourceDesc/tei:bibl[tei:location/@work = $local:kangyur-work-id]
        let $toh-key := $bibl/@key
        let $text-ref := $local:text-refs[@key = $toh-key]
        let $atii-text-id := $text-ref/m:ref[@type eq "atii-id"]/@value/string()
        let $row := $local:import-attributions[local-name(.) eq $atii-text-id]
        return
            element { QName('http://read.84000.co/ns/1.0','text') }{
                attribute eft-text-id { $text-id },
                attribute eft-toh-key { $toh-key },
                attribute atii-text-id { $atii-text-id },
                element eft-title { ($tei//tei:fileDesc/tei:titleStmt/tei:title[@type eq 'mainTitle'][@xml:lang eq 'Bo-Ltn'])[1]/text() },
                element atii-title { ($row/m:title)[1]/text() },
                for $attribution in $row
                return
                    element attribution {
                        attribute atii-id { $attribution/m:identification/text() },
                        attribute atii-role { $attribution/m:role/text() },
                        element atii-name {
                            $attribution/m:indicated_value/text()
                        }
                    }
            }
};

declare function local:assign-atii-ids(){
    
    element { QName('http://read.84000.co/ns/1.0','kangyur-data') } {
        let $texts := local:texts()
        for $text in $texts[not(@atii-text-id gt '')]
        let $toh-key := $text/@eft-toh-key/string()
        let $text-ref := $local:text-refs[@key eq $toh-key]
        let $bdrc-idx := $text-ref/m:ref[@type eq 'bdrc-idx']/@value/string()
        let $atii-text-id-proposed := concat('0000',  $bdrc-idx) ! substring(., string-length(.) -3, 4) ! concat('D', .)
        let $atti-ref-proposed :=
            element {QName('http://read.84000.co/ns/1.0','ref')} {
                attribute type { 'atii-id' },
                attribute value { $atii-text-id-proposed }
            }
        let $atii-row := $local:import-attributions[local-name(.) eq $atii-text-id-proposed]
        return
            element action {
                attribute type { 'assign-atii-id' },
                attribute atii-text-id-proposed { $atii-text-id-proposed },
                $text/@eft-toh-key,
                if($atii-row) then
                    element source { $atii-row }
                else (),
                if($text-ref) then
                    element target { $text-ref }
                else (),
                if($atii-row and $text-ref) then 
                    element add { 
                        common:update('assign-atii-ids', (), $atti-ref-proposed, $text-ref, ()),
                        $atti-ref-proposed 
                    }
                else ()
            }
    }
    
};

declare function local:import-atii(){
    element { QName('http://read.84000.co/ns/1.0','kangyur-data') } {
        
        element head {
            element doc {
                attribute doc_id { $local:target-path }
            },
            element processed {
                attribute date { current-dateTime() },
                attribute auth { 'dl' },
                attribute ver { '0.1' }
            },
            element source {
                attribute file-path {$local:source-path}
            }
        },
        
        let $texts := local:texts()
        
        (: Validate mappings :)
        let $texts-no-atii-id := $texts[not(@atii-text-id gt '')]
        return
        if($texts-no-atii-id) then
            element error {
                attribute type {'no-atii-id'},
                $texts-no-atii-id
            }
        else
            $texts
        
    }
};

local:assign-atii-ids()
    