xquery version "3.1" encoding "UTF-8";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "../modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../modules/tei-content.xql";
import module namespace entities="http://read.84000.co/entities" at "../modules/entities.xql";

(: !!! Switch off update trigger before running !!! :)

(: TO DO: clear out redundant tei:list[@type eq "glossary"]/tei:item/tei:gloss/@type :)

declare variable $local:tei := collection($common:translations-path);

(: Actually we probably won't need this !!!
declare function local:add-xmlids(){
    
    for $tei in $local:tei//tei:TEI(\:[tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno/@xml:id = ("UT22084-040-003")]:\)
        let $translation-id := tei-content:id($tei)
        let $max-id := max($tei//@xml:id ! substring-after(., $translation-id) ! substring(., 2) ! common:integer(.))
        for $element at $index in $tei/tei:text[not(@xml:id) or @xml:id eq ''] | $tei//tei:text//tei:div[@type = ('prologue', 'section', 'chapter', 'colophon', 'colophon', 'notes', 'listBibl', 'appendix', 'glossary')][not(@xml:id) or @xml:id eq '']
            let $next-id := concat($translation-id, '-', xs:string(sum(($max-id, $index))))
        return
        (
            $next-id,
            update insert attribute xml:id { $next-id } into $element
        )
};:)

declare function local:create-entities-file(){

    (: Loop through texts with sponsor status :)
    let $entities-data := 
        <entities xmlns="http://read.84000.co/ns/1.0">
        {
            for $glossary-item at $item-index in $local:tei//tei:list[@type eq "glossary"]/tei:item/tei:gloss
            return
            (
                text {'&#10;'},
                (: Add an entity for all glossary items :)
                element { QName('http://read.84000.co/ns/1.0', 'entity') } {
                    attribute xml:id { concat('entity-', $item-index) },
                    element { QName('http://read.84000.co/ns/1.0', 'label') } {
                        $glossary-item/tei:term[not(@xml:lang) or @xml:lang eq ''][1]/text()
                    },
                    element { QName('http://read.84000.co/ns/1.0', 'definition') } {
                        attribute type { 'glossary-item' },
                        attribute id { $glossary-item/@xml:id }
                    },
                    element { QName('http://read.84000.co/ns/1.0', 'type') } {
                        attribute type { concat('eft-glossary-', $glossary-item/@type) }
                    }
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


