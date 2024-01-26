declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace ex="http://exist-db.org/collection-config/1.0";
import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace knowledgebase="http://read.84000.co/knowledgebase" at "../../84000-reading-room/modules/knowledgebase.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../../84000-operations/modules/update-tei.xql";

declare variable $local:dry-run := true();

declare function local:authors-contested(){

    for $tei in collection($common:translations-path)//tei:TEI[descendant::tei:bibl/tei:author[@xml:id][not(@role)][@key eq 'alternate']]
    let $sourceBibls := $tei/descendant::tei:bibl[tei:author[@xml:id][not(@role)][@key eq 'alternate']]
    let $toh-number := ($sourceBibls/@key)[1] ! replace(., '^toh([0-9]+)\-?([0-9]+)?.*', '$1.$2') ! xs:double(.)
    order by $toh-number
    (:where $toh-number eq 1127:)
    
    return (
        
        tei-content:id($tei),
        
        for $sourceBibl in $sourceBibls[tei:author[@xml:id][not(@role)][@key eq 'alternate']](:[count(tei:author[@xml:id][not(@role)]) gt 1][not(tei:author[@xml:id][not(@role)][@key eq 'alternate'])]:)
        return (
        
            concat($sourceBibl/tei:ref/data(), ': ', string-join($sourceBibl/tei:author[@xml:id][not(@role)], ', ')),
            
            for $alternateAuthors in $sourceBibl/tei:author[not(@role)]
            let $authorContested :=
                element { node-name($alternateAuthors) } {
                    attribute role { 'authorContested' },
                    $alternateAuthors/@*[not(name(.) eq 'key')],
                    normalize-space(string-join($alternateAuthors/text()))
                }
            return (
                $authorContested,
                if(not($local:dry-run)) then
                    update replace $alternateAuthors with $authorContested
                else ()
            )
            
        ),
        
        if(not($local:dry-run)) then
            update-tei:minor-version-increment($tei, 'TEI migrated to 2.21.0 - author contested')
        else ()
        
    )
    
};

declare function local:publish-author-stubs(){
    
    let $author-pages := knowledgebase:pages('authors', false(), ())
    for $tei in $knowledgebase:tei/id($author-pages/@xml:id)/ancestor::tei:TEI[descendant::tei:publicationStmt/tei:availability/@status = '3']
    let $text-id := tei-content:id($tei)
    (:where $text-id eq 'EFT-KB-ABHAYAKARA':)
    
    return (
    
        $text-id ,
        
        if(not($local:dry-run)) then (
        
            update replace $tei/descendant::tei:publicationStmt/tei:availability/@status with attribute status { '1.b' },
            
            update-tei:minor-version-increment($tei, 'TEI migrated to 2.21.0 - author stub published'),
            update-tei:add-change($tei, 'publication-status', '1.b', 'Author stubs set to 1.b')
        
        )
        else ()
        
    )
};

let $trigger := doc(concat('/db/system/config',$common:tei-path, '/collection.xconf'))/ex:collection/ex:triggers/ex:trigger

return 
    if($trigger and not($local:dry-run)) then 
        <warning>{ 'DISABLE TRIGGERS BEFORE UPDATING TEI' }</warning>
        
    else (
        local:authors-contested(),
        local:publish-author-stubs()
    )