xquery version "3.1" encoding "UTF-8";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace source="http://read.84000.co/source" at "../../84000-reading-room/modules/source.xql";

let $output := 'User-agent: * '
let $disallows := 
    for $work-id in ($source:kangyur-work, $source:tengyur-work)
    return
        for $fileDesc in $tei-content:translations-collection//tei:fileDesc
            [tei:publicationStmt/tei:availability[@status = $translation:published-status-ids][tei:p[@type eq 'tantricRestriction']]]
        let $volumes := $fileDesc/tei:sourceDesc/tei:bibl[@key]/tei:location[@work eq $work-id]/tei:volume
        let $volume-first-number := min($volumes/@number ! xs:integer(.))
        let $volume-first := $volumes[@number ! xs:integer(.) eq $volume-first-number]
        where $volumes
        order by $volume-first/@number ! xs:integer(.), $volume-first/@start-page ! xs:integer(.)
        return
            for $bibl in $fileDesc/tei:sourceDesc/tei:bibl[@key][tei:location[@work eq $work-id]]
            return
                concat('Disallow: /translation/', $bibl/@key, '/')

return
    common:serialize-txt(string-join(($output, $disallows), $common:chr-nl))