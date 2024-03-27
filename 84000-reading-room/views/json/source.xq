xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace common = "http://read.84000.co/common" at "../../modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../modules/tei-content.xql";
import module namespace eft-json = "http://read.84000.co/json" at "eft-json.xql";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:api-version := '0.1.0';
declare variable $local:response := request:get-data()/m:response;
declare variable $local:request := $local:response/m:request;
declare variable $local:source := $local:response/m:source;
declare variable $local:translation := $local:response/m:translation;
declare variable $local:toh-key := $local:response/m:translation/m:toh[1]/@key;
declare variable $local:toh-number := $local:toh-key ! replace(., '^toh', '');

element source {

    attribute api-version { $local:api-version },
    attribute url { concat('/source/', $local:request/@resource-id,'.json?page=', $local:request/@page,'&amp;folio=', $local:request/@folio,'&amp;api-version=', $local:api-version) },
    attribute work { $local:source/@work },
    attribute text-id { $local:translation/@id },
    attribute toh-key { $local:translation/m:source/@key },
    $local:source/@canonical-html ! attribute source-html { . },
    $local:source/m:back-link/@url ! attribute translation-html { . },
    
    for $title in ($local:translation/m:titles/m:title, $local:translation/m:long-titles/m:title, $local:translation/m:source/m:toh)
    return
        element title { 
            attribute lang { ($title/@xml:lang, 'en')[1] }, 
            $title/text()
        }
    ,
    
    for $page at $index in $local:source/m:page
    return
        element folio { 
            $page/@etext-id,
            attribute volume { $page/@volume },
            attribute page-in-volume { $page/@page-in-volume },
            attribute page-in-text { $index },
            attribute label { $page/@folio-in-volume ! concat('[F.', ., ']') },
            text {
                replace(
                    replace(
                        string-join(
                            $page/m:language[@xml:lang eq 'bo']/tei:p/text()
                                [
                                    not($local:toh-number) or (
                                        not(following-sibling::tei:milestone[@unit eq 'text'][@toh eq $local:toh-number])
                                        and not(preceding-sibling::tei:milestone[@unit eq 'text'][1][not(@toh eq $local:toh-number)])
                                    )
                                ]
                        )
                    ,'\s+', ' ')            (: Condense other whitespace :) 
                , '(^\s+|\s+$)', '')        (: Remove leading/trailing space :)
            }
        }
}