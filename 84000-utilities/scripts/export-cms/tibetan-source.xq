xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace eft="http://read.84000.co/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace common="http://read.84000.co/common" at "../../../84000-reading-room/modules/common.xql";
import module namespace source="http://read.84000.co/source" at "../../../84000-reading-room/modules/source.xql";
import module namespace functx="http://www.functx.com";

declare variable $local:export-work := $source:tengyur-work;
declare variable $local:volumes := collection(source:etext-path($local:export-work));

declare function local:parse-source() as text()* {

    (: Headers :)
    text { string-join(('Volume','Volume ID','Folio','Folio ID','Content'), ',') || '&#10;'},
    
    (: Content :)
    let $volumes-tei := 
        for $volume-tei in $local:volumes//tei:TEI
        let $long-id := $volume-tei/descendant::tei:idno[@type eq "TBRC_TEXT_RID"]/text()
        order by $long-id
        return 
            $volume-tei
    
    for $volume-tei at $volume-index in $volumes-tei
    let $long-id := $volume-tei/descendant::tei:idno[@type eq "TBRC_TEXT_RID"]/text()
    return 
        for $folio at $folio-index in $volume-tei/descendant::tei:p
        let $content := string-join($folio/text()) ! replace(., '\s+', ' ') ! normalize-space(.)
        where $content
        return 
            text { string-join(($volume-index, $long-id, $folio-index, $folio/@data-orig-n, $content), ',') || '&#10;'}
            
};

xmldb:store('/db/apps/84000-data/uploads/export-to-cms', $local:export-work || '.csv', string-join(local:parse-source()), 'plain/txt')
