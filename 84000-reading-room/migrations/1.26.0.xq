xquery version "3.0";
declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace source="http://read.84000.co/source" at "../modules/source.xql";

(: !!! Switch off update trigger before running !!! :)

declare variable $local:tei := collection($common:translations-path);

for $fileDesc in $local:tei//tei:TEI/tei:teiHeader/tei:fileDesc[tei:sourceDesc/tei:bibl/tei:location/tei:start]
    
    let $id := string($fileDesc/tei:publicationStmt/tei:idno/@xml:id)
    
    for $bibl in $fileDesc/tei:sourceDesc/tei:bibl
        
        let $toh-key := string($bibl/@key)
        let $work := 
            if($bibl/tei:idno[@source-id]/@work eq 'W22084') then
                $source:ekangyur-work
            else
                $source:etengyur-work
        
        let $volumes := 
            for $volume-number in xs:integer($bibl/tei:location/tei:start/@volume) to xs:integer($bibl/tei:location/tei:end/@volume)
                
                let $etext-volume-number := source:etext-volume-number($work, $volume-number)
                let $etext-id := source:etext-id($work, $etext-volume-number)
                let $etext-volume := source:etext-volume($etext-id)
                let $etext-volume-page-count := count($etext-volume//tei:p)
                let $start-page := 
                    if(xs:integer($bibl/tei:location/tei:start[@volume = $volume-number]/@page) gt 1) then 
                        xs:integer($bibl/tei:location/tei:start[@volume = $volume-number]/@page) - 2
                    else 
                        2
                let $end-page := 
                    if(xs:integer($bibl/tei:location/tei:end[@volume = $volume-number]/@page) lt $etext-volume-page-count) then 
                        xs:integer($bibl/tei:location/tei:end[@volume = $volume-number]/@page) - 2
                    else 
                        $etext-volume-page-count
                        
            return
                element { QName('http://www.tei-c.org/ns/1.0', 'volume') }{
                    attribute number { $volume-number },
                    (: attribute etext-id { $etext-id }, :) 
                    attribute start-page { $start-page },
                    attribute end-page { $end-page }
                }
                
        return
            (
            $toh-key,
            update replace $bibl/tei:location with (: :)
                element { QName('http://www.tei-c.org/ns/1.0', 'location') }{
                    attribute work { $work },
                    attribute count-pages { 
                        if($bibl/tei:location/@count-pages gt '') then
                            $bibl/tei:location/@count-pages
                        else
                            sum($volumes ! (xs:integer(@end-page) - (xs:integer(@start-page) - 1))) 
                    },
                    $volumes
                }
             )
    