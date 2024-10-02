xquery version "3.1" encoding "UTF-8";

(: Check the contents of 84000-static :)

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace eft="http://read.84000.co/ns/1.0";

import module namespace tei-content="http://read.84000.co/tei-content" at "/db/apps/84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "/db/apps/84000-reading-room/modules/translation.xql";
import module namespace store="http://read.84000.co/store" at "/db/apps/84000-reading-room/modules/store.xql";

declare function local:check-translations() {

    for $tei at $index in $tei-content:translations-collection//tei:TEI
    let $text-id := tei-content:id($tei)
    (:where $text-id = ('UT22084-066-009', 'UT23703-001-001', 'UT22084-040-003'):)
    return
        for $source-key in $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key
        let $translation-files := translation:files($tei, ((::)'translation-html'(:,'translation-files','source-html','glossary-html','publications-list':)), $source-key)
        where $translation-files/eft:file[not(@timestamp gt '')]
        return
            concat($index, ' - ', $source-key/string())
            (:$translation-files/eft:file[not(@timestamp gt '')] ! string-join((@target-folder, @target-file),'/'):)
            
};

local:check-translations()