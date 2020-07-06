xquery version "3.1" encoding "UTF-8";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace entities="http://read.84000.co/entities" at "../modules/entities.xql";

(: TO DO: clear out redundant tei:list[@type eq "glossary"]/tei:item/tei:gloss/@type :)

declare variable $local:tei := collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt/@status = ('1', '1.a')];

(: !!! Switch off update trigger before running !!! :)
(: Actually we probably won't need this !!!
declare function local:add-xmlids(){
    
    for $tei in $local:tei//tei:TEI(\:[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno/@xml:id = ("UT22084-040-003")]:\)
        let $translation-id := tei-content:id($tei)
        let $max-id := max($tei//@xml:id ! substring-after(., $translation-id) ! substring(., 2) ! common:integer(.))
        for $element at $index in $tei/tei:text[not(@xml:id) or @xml:id eq ''] | $tei//tei:text//tei:div[@type = ('prologue', 'homage', 'section', 'chapter', 'colophon', 'colophon', 'notes', 'listBibl', 'appendix', 'glossary')][not(@xml:id) or @xml:id eq '']
            let $next-id := concat($translation-id, '-', xs:string(sum(($max-id, $index))))
        return (
            $next-id,
            update insert attribute xml:id { $next-id } into $element
        )
};:)

declare function local:create-entities-file(){

    (: Loop through texts with sponsor status :)
    let $entities-data := 
        <entities xmlns="http://read.84000.co/ns/1.0">
        {
            for $gloss at $gloss-index in $local:tei//tei:list[@type eq "glossary"]/tei:item/tei:gloss
                let $type := $gloss/@type
                let $term := $gloss/tei:term[@xml:lang = ('bo', 'Sa-Ltn')][normalize-space(.)][1] ! normalize-space(.)
                let $term-lang := $gloss/tei:term[text() ! normalize-space(.) = $term][1]/@xml:lang
            where $term
            group by $term, $type
            return (
                common:ws(1),
                (: Add an entity for all glossary items :)
                element { QName('http://read.84000.co/ns/1.0', 'entity') } {
                    attribute xml:id { concat('entity-', $gloss-index[1]) },
                    common:ws(2),
                    element { QName('http://read.84000.co/ns/1.0', 'label') } {
                        attribute xml:lang { $term-lang[1] },
                        $term
                    },
                    for $gloss-type in distinct-values($gloss/@type)
                    return (
                        common:ws(2),
                        element { QName('http://read.84000.co/ns/1.0', 'type') } {
                            attribute type { concat('eft-glossary-', $gloss-type) }
                        }
                    ),
                    for $gloss-single in $gloss
                    return (
                        common:ws(2),
                        element { QName('http://read.84000.co/ns/1.0', 'instance') } {
                            attribute id { $gloss-single/@xml:id },
                            attribute type { 'glossary-item' },
                            
                            (: Do a check for out-of-scope ids :)
                            if(not(tei-content:valid-xml-id($gloss-single/ancestor::tei:TEI, $gloss-single/@xml:id))) then
                                attribute flag { 'xml-id-not-valid' }
                            else
                                ()
                         }
                    ),
                    common:ws(1)
                }
            )
        }
        </entities>
    
    (: Create the entities file :)
    let $collection := concat($common:data-path, '/operations')
    let $file-name := 'entities.xml'
    let $create-file := xmldb:store($collection, $file-name, $entities-data)
    
    (: Set permissions :)
    let $file-uri := concat($collection, '/', $file-name)
    let $set-permissions := 
        (
            sm:chown($file-uri, 'admin'),
            sm:chgrp($file-uri, 'operations'),
            sm:chmod($file-uri, 'rw-rw-r--')
        )
    
    return concat('Created: ', $file-uri)
};

local:create-entities-file()


