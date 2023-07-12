xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace owl="http://www.w3.org/2002/07/owl#";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";

declare variable $local:kangyur-tei := collection($common:translations-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:location/@work = 'UT4CZ5369'];
declare variable $local:text-refs := doc(concat($common:data-path, '/config/linked-data/text-refs.xml'));
    
element { QName('http://read.84000.co/ns/1.0', 'attributions') } {
    
    namespace {"rdf"} { "http://www.w3.org/1999/02/22-rdf-syntax-ns#" },
    namespace {"owl"} { "http://www.w3.org/2002/07/owl#" },
    
    element export {
        attribute timestamp { current-dateTime() },
        attribute user { common:user-name() }
    },

    for $tei in $local:kangyur-tei(:[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/@key eq 'toh13']:)
        
        let $text-id := tei-content:id($tei)
        let $bibls := $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[tei:location[@work = 'UT4CZ5369']]
        let $tohs := 
            for $bibl in $bibls
            return translation:toh($tei, $bibl/@key)
        let $tohs-1 := $tohs[1]
        let $toh-number := $tohs-1/@number[. gt ''] ! xs:integer(.)
    
    order by 
        $toh-number, 
        $tohs-1/@letter, 
        $tohs-1/@chapter-number[. gt ''] ! xs:integer(.),
        $tohs-1/@chapter-letter
    
    return
    element { QName('http://read.84000.co/ns/1.0', 'text') } {
        attribute id { $text-id },
        
        for $bibl in $bibls
        let $toh := translation:toh($tei, $bibl/@key)
        let $text-refs := $local:text-refs/m:text-refs/m:text[@key eq $toh/@key]
        return 
            element bibl {
                attribute type { 'toh' },
                attribute key { $toh/@key },
                element label { $toh/m:full/text() },
                element work {
                    attribute type { 'tibetanSource' },
                    element label {
                        if($tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type eq "mainTitle"][@xml:lang eq "Bo-Ltn"][text()]) then 
                            $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type eq "mainTitle"][@xml:lang eq "Bo-Ltn"]/text()
                        else if($tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type eq "mainTitle"][@xml:lang eq "bo"][text()]) then
                            common:wylie-from-bo($tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type eq "mainTitle"][@xml:lang eq "bo"]/text())
                        else ()
                    },
                    element rdf:type {
                        attribute rdf:resource { 'http://purl.bdrc.io/ontology/core/Work' }
                    },
                    if($text-refs[m:ref[@type eq 'bdrc-tibetan-id'][@value]]) then
                        element owl:sameAs {
                            attribute rdf:resource { $text-refs/m:ref[@type eq 'bdrc-tibetan-id']/@value/string() }
                        }
                    else ()
                    ,
                    for $author in $bibl/tei:author[normalize-space(text())]
                    let $author-tokenized := tokenize(replace($author/data(), '^[atr][0-9]*[\.:]\s*', ''), '[,:]') ! normalize-space(.)
                    let $author-id := replace($author-tokenized[1] ! lower-case(.) ! common:normalized-chars(.), "[^a-z0-9]+", "-")
                    return
                    element attribution {
                        attribute role {
                            if(matches($author, '^a[0-9]*[\.:]\s*')) then
                                'author'
                            else if(matches($author, '^r[0-9]*[\.:]\s*')) then
                                'reviser'
                            else if(matches($author, '^t[0-9]*[\.:]\s*')) then
                                'translatorTib'
                            else 
                                $author/@role/string()
                        },
                        if(matches($author, '^r[0-9]+[\.:]\s*')) then 
                            attribute revision { replace($author, '^r([0-9]+)([\.:]\s*.*)', '$1') }
                        else ()
                         ,
                        attribute resource { lower-case(concat('eft:', $author-id)) },
                        for $author-string in $author-tokenized
                        return
                        element label { $author-string }
                    }
                }
            }
        ,
        element work {
            attribute type { 'englishTranslation' },
            element label { $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type eq "mainTitle"][@xml:lang eq "en"]/text() },
            element rdf:type {
                attribute rdf:resource { 'http://purl.bdrc.io/ontology/core/Work' }
            },
            (:element link {
                attribute target-media { 'text/tei' },
                attribute url { 'https://read.84000-translate.org/translation/' || $text-id || '.tei'  }
            },:)
            for $attribution in $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:*[@role = ('dharmaMaster', 'translatorMain', 'translatorEng', 'reviser', 'advisor', 'associateEditor', 'finalReviewer', 'externalReviewer')]
            let $attribution-id := $attribution/@xml:id
            let $contributor := $contributors:contributors//m:instance[@id eq $attribution-id]/parent::m:*[@xml:id]
            return
                element attribution {
                    $attribution/@role,
                    attribute resource { lower-case(concat('eft:', $contributor/@xml:id)) },
                    $contributor/m:label
                }
        }
    }

}