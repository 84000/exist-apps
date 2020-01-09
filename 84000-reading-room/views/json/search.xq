xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";

import module namespace common = "http://read.84000.co/common" at "../../modules/common.xql";
import module namespace eft-json = "http://read.84000.co/json" at "eft-json.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $xhtml-xsl := doc(concat($common:app-path, "/xslt/tei-search.xsl"));

declare function local:results($results as element()*) as element()* {
    element results {
        $results/@*,
        for $item in $results/m:item
        return
            element item {
                $item/@*,
                for $tei in $item/m:tei
                return
                    for $bibl in $tei/m:bibl
                    return
                        element { 'text' } {
                            attribute id { $bibl/m:toh/@key },
                            attribute canonical-html { $bibl/@canonical-html },
                            attribute translation-status { $tei/@translation-status-group },
                            eft-json:titles($tei/m:titles/m:title),
                            $bibl/m:toh,
                            eft-json:parent-sections($bibl/m:parent)
                        }
                ,
                for $match in $item/m:match
                return
                    element match {
                        attribute score { $match/@score },
                        attribute link { $match/@link },
                        element content { eft-json:tei-to-escaped-xhtml($match/*, $xhtml-xsl) }
                    }
                  
            }
    }
};

let $search := request:get-data()/m:response/m:search
let $api-version := '0.1.0'

return
    <search json:array="true">
    {
        attribute api-version { $api-version },
        attribute url { concat('/search/search.json?search=', escape-uri($search/m:request, false()), '&amp;api-version=', $api-version) },
        local:results($search/m:results)
    }
    </search>