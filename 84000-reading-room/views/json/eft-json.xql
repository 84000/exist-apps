xquery version "3.1";

module namespace eft-json = "http://read.84000.co/json";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";

import module namespace common = "http://read.84000.co/common" at "../../modules/common.xql";
import module namespace functx="http://www.functx.com";

declare function eft-json:titles($titles as element()*) {
    for $title in $titles
    return
        element { 'title' } {
            element { $title/@xml:lang } {
                text {$title/text() }
            }
        }
};

declare function eft-json:parent-sections($parent as element()?) as element()? {
    if($parent) then
        element parent-section {
            $parent/@id,
            attribute url { concat('/section/', $parent/@id, '.json') },
            eft-json:titles($parent/m:titles/m:title),
            eft-json:parent-sections($parent/m:parent)
        }
    else ()
};

declare function eft-json:tei-to-escaped-xhtml($tei as element()*, $xsl as document-node()) as xs:string {
    serialize(
        <div xmlns="http://www.w3.org/1999/xhtml">
        { 
            transform:transform(
                common:strip-ids($tei),
                $xsl,
                <parameters/>
            )
        }
        </div>
    )
};

declare function eft-json:copy-nodes($nodes as node()*) as element()* {
    for $node in $nodes
    return
        if($node[self::text()]) then
            $node
        else
            element { local-name($node) } {
                for $attr in $node/@*
                return
                    element { local-name($attr) } {
                        if(functx:is-a-number($attr/string())) then
                            attribute json:literal {'true'}
                        else ()
                        ,
                        $attr/string()
                    }
                ,
                eft-json:copy-nodes($node/*)
            }
};