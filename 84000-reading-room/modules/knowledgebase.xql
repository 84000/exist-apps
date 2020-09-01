xquery version "3.1";

module namespace knowledgebase="http://read.84000.co/knowledgebase";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";

declare variable $knowledgebase:pages := collection($common:knowledgebase-path);

declare function knowledgebase:kb-id($tei as element(tei:TEI)) as xs:string? {
    $tei/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@m:kb-id][1]/@m:kb-id
};

declare function knowledgebase:sort-name($tei as element(tei:TEI)) as xs:string? {
    tei-content:title($tei) ! normalize-space(.) ! lower-case(.) ! common:normalized-chars(.) ! common:alphanumeric(.)
};

declare function knowledgebase:page($tei as element(tei:TEI)) as element(m:page) {
    
    let $kb-id := knowledgebase:kb-id($tei)
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'page') }{
            attribute xml:id { tei-content:id($tei) },
            attribute kb-id { $kb-id },
            attribute uri { base-uri($tei) },
            attribute last-updated { max(tei-content:last-updated($tei/tei:teiHeader/tei:fileDesc)) },
            attribute version-number { tei-content:version-number(tei-content:version-number-str($tei)) },
            attribute status { tei-content:translation-status($tei) },
            attribute status-group { tei-content:translation-status-group($tei) },
            attribute page-url { concat($common:environment/m:url[@id eq 'reading-room'], '/knowledgebase/', $kb-id, '.html') },
            element sort-name { knowledgebase:sort-name($tei) },
            tei-content:titles($tei)
        }
};

declare function knowledgebase:pages() as element(m:knowledgebase) {
    
    element { QName('http://read.84000.co/ns/1.0', 'knowledgebase') }{
    
        for $tei in $knowledgebase:pages//tei:TEI
        return 
            knowledgebase:page($tei)
    }
};

declare function knowledgebase:publication($tei as element(tei:TEI)) as element(m:publication) {
    let $fileDesc := $tei/tei:teiHeader/tei:fileDesc
    return
        element { QName('http://read.84000.co/ns/1.0', 'publication') } {
            element contributors {
                for $contributor in $fileDesc/tei:titleStmt/tei:author | $fileDesc/tei:titleStmt/tei:editor | $fileDesc/tei:titleStmt/tei:consultant
                return 
                    element { local-name($contributor) } {
                        $contributor/@role,
                        $contributor/@ref,
                        normalize-space($contributor/text())
                    }
            },
            element edition {
                $fileDesc/tei:editionStmt/tei:edition[1]/node() 
            },
            element license {
                attribute img-url { $fileDesc/tei:publicationStmt/tei:availability/tei:licence/tei:graphic/@url },
                text {
                    common:normalize-space($fileDesc/tei:publicationStmt/tei:availability/tei:licence/tei:p)
                }
            },
            element publication-statement {
                common:normalize-space($fileDesc/tei:publicationStmt/tei:publisher/node())
            },
            element publication-date {
                $fileDesc/tei:publicationStmt/tei:date/text()
            }
        }
};

declare function knowledgebase:summary($tei as element(tei:TEI), $lang as xs:string) as element(m:summary) {
    
    element { QName('http://read.84000.co/ns/1.0', 'summary') }{
    
        attribute prefix { 's' },
        
        common:normalize-space(
                $tei/tei:text/tei:front//tei:div[@type eq 'summary']
        )
    }
};

declare function knowledgebase:article($tei as element(tei:TEI)) as element(m:article) {
    
    element { QName('http://read.84000.co/ns/1.0', 'article') }{
    
        attribute prefix { 'a' },
        
        common:normalize-space(
                $tei/tei:text/tei:body/*
        )
    }
};

declare function knowledgebase:bibliography($tei as element(tei:TEI)) as element() {
    element { QName('http://read.84000.co/ns/1.0', 'bibliography') } {
        attribute prefix { 'b' },
        for $section in $tei/tei:text/tei:back/*[@type eq 'listBibl']/*[@type eq 'section']
        return
            knowledgebase:bibliography-section($section)
    }
};

declare function knowledgebase:bibliography-section($section as element()) as element() {
    element { QName('http://read.84000.co/ns/1.0', 'section') } {
        let $head := $section/tei:head[@type='section'][text()]
        where $head
        return
            element title { 
                $head/text()
            }
        ,
        for $item in $section/tei:bibl
        return
            element item {
                attribute id { $item/@xml:id },
                $item/node()
            }
        ,
        for $sub-section in $section/tei:div[@type eq 'section']
        return
            knowledgebase:bibliography-section($sub-section)
    }
};

declare function knowledgebase:taxonomy($tei as element(tei:TEI)) as element(m:taxononmy) {
    
    element { QName('http://read.84000.co/ns/1.0', 'taxonomy') }{
        $tei/tei:teiHeader/tei:profileDesc/tei:textClass/tei:catRef/tei:taxonomy/*
    }
    
};

declare function knowledgebase:id($title as xs:string) as xs:string {
    
    (: Generate an id from a title :)
    
    let $stopwords := ('a', 'an', 'the', 'and', 'with', 'of')
    
    return
        string-join(
            tokenize(
                replace(
                    common:normalized-chars(
                        lower-case($title)      (: convert to lower case :)
                    )                           (: remove diacritics :)
                ,'[^a-zA-Z0-9\s]', ' ')         (: remove non-alphanumeric, except spaces :)
            , '\s+')[not(. = $stopwords)]       (: remove stopwords :)
        , '-')                                  (: remove concat words with hyphens :)
    
    
};

declare function knowledgebase:new-tei($title as xs:string) as document-node()? {
let $id := knowledgebase:id($title)
where $id gt ''
return document {
<?xml-model href="../schema/current/knowledgebase.rng" schematypens="http://relaxng.org/ns/structure/1.0"?>,
<TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:eft="http://read.84000.co/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">
    <teiHeader>
        <fileDesc>
            <titleStmt>
                <title type="mainTitle" xml:lang="en">{ $title }</title>
            </titleStmt>
            <editionStmt>
                <edition>v 0.0.1 <date>{ format-date(current-date(), '[Y]') }</date></edition>
            </editionStmt>
            <publicationStmt status="2.a">
                <publisher>
                    <name>84000: Translating the Words of the Buddha</name>
                </publisher>
                <idno xml:id="EFT-KB-{ upper-case($id) }"/>
                <idno eft:kb-id="{ lower-case($id) }"/>
            </publicationStmt>
            <sourceDesc>
                <tei:p>Created by 84000: Translating the Words of the Buddha</tei:p>
            </sourceDesc>
            <notesStmt/>
        </fileDesc>
    </teiHeader>
    <text>
        <front/>
    </text>
</TEI>
}};

