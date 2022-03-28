xquery version "3.1";

module namespace knowledgebase="http://read.84000.co/knowledgebase";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace entities="http://read.84000.co/entities" at "entities.xql";
import module namespace translations="http://read.84000.co/translations" at "translations.xql";
import module namespace functx="http://www.functx.com";

declare variable $knowledgebase:tei := collection($common:knowledgebase-path)//tei:TEI;
declare variable $knowledgebase:tei-render := 
    $knowledgebase:tei
        [tei:teiHeader/tei:fileDesc/tei:publicationStmt
            [@status = $common:environment/m:render/m:status[@type eq 'article']/@status-id]
        ];
declare variable $knowledgebase:title-prefixes := '(The|A)';

declare variable $knowledgebase:view-modes := 
    <view-modes xmlns="http://read.84000.co/ns/1.0">
        <view-mode id="default"         client="browser"    layout="full"            glossary="use-cache"       parts="all"/>,
        <view-mode id="editor"          client="browser"    layout="full"            glossary="no-cache"        parts="all"/>,
        <view-mode id="glossary-editor" client="browser"    layout="full"            glossary="use-cache"       parts="all"/>,
        <view-mode id="glossary-check"  client="browser"    layout="expanded-fixed"  glossary="no-cache"        parts="all"/>
    </view-modes>;

declare function knowledgebase:kb-id($tei as element(tei:TEI)) as xs:string? {
    $tei/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@m:kb-id][1]/@m:kb-id
};

declare function knowledgebase:sort-name($tei as element(tei:TEI)) as xs:string? {
    
    let $titles := tei-content:titles($tei)
    
    let $sort-title := (
        $titles/m:title[@type eq 'mainTitle'][not(@xml:lang eq 'bo')],
        $titles/m:title[not(@xml:lang eq 'bo')]
    )[1]
    
    return
        replace($sort-title/data(), concat($knowledgebase:title-prefixes, '\s+'), '')
        ! normalize-space(.)
        ! lower-case(.)
        ! common:normalized-chars(.)
        ! common:alphanumeric(.)
};


declare function knowledgebase:titles($tei as element(tei:TEI)) as element(m:titles) {
    
    let $tei-titles := tei-content:titles($tei)
    let $titles :=
        for $title at $index in $tei-titles/m:title
        order by if($title/@type eq 'mainTitle') then 0 else 1 ascending
        return $title
    return
        element { node-name($tei-titles) }{
            for $title at $index in $titles
            return
                element { node-name($title) }{
                    attribute type {
                        if($index eq 1) then 'mainTitle' else 'otherTitle'
                    },
                    $title/@xml:lang,
                    $title/data()
                }
        }
    
};

declare function knowledgebase:page($tei as element(tei:TEI)) as element(m:page) {
    
    let $kb-id := knowledgebase:kb-id($tei)
    let $sort-name := knowledgebase:sort-name($tei)
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'page') }{
            attribute xml:id { tei-content:id($tei) },
            attribute kb-id { $kb-id },
            attribute document-url { tei-content:document-url($tei) },
            attribute locked-by-user { tei-content:locked-by-user($tei) },
            attribute last-updated { max(tei-content:last-updated($tei/tei:teiHeader/tei:fileDesc)) },
            attribute version-number { tei-content:version-number(tei-content:version-number-str($tei)) },
            attribute status { tei-content:translation-status($tei) },
            attribute status-group { tei-content:translation-status-group($tei) },
            attribute page-url { concat($common:environment/m:url[@id eq 'reading-room'], '/knowledgebase/', $kb-id, '.html') },
            attribute start-letter { upper-case(substring($sort-name, 1, 1)) },
            element sort-name { $sort-name },
            knowledgebase:titles($tei)
        }
};

declare function knowledgebase:pages() as element(m:knowledgebase) {
    element { QName('http://read.84000.co/ns/1.0', 'knowledgebase') }{
        knowledgebase:pages('all', false())
    }
};

declare function knowledgebase:pages($ids as xs:string*, $published-only as xs:boolean) as element(m:page)* {
    
    for $tei in 
        if($published-only) then
            if($ids = 'all') then
                $knowledgebase:tei-render
            else
                $knowledgebase:tei-render/id($ids)/ancestor::tei:TEI
        else
            if($ids = 'all') then
                $knowledgebase:tei
            else
                $knowledgebase:tei/id($ids)/ancestor::tei:TEI
                
    return 
        knowledgebase:page($tei)
        
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

declare function knowledgebase:article($tei as element(tei:TEI)) as element(m:part) {

    element { QName('http://read.84000.co/ns/1.0', 'part') } {

        attribute type { 'article' },
        attribute id { 'article' },
        attribute nesting { 0 },
        attribute prefix { 'a' },
        
        for $section at $index in $tei/tei:text/tei:body/tei:div[@type eq 'article']/tei:div
        return
            element {QName('http://read.84000.co/ns/1.0', 'part')} {

                attribute type { $section/@type },
                attribute id { $section/@xml:id },
                attribute nesting { 1 },
                attribute prefix { $index },
                attribute glossarize { 'mark' },
                
                $section/*
                
            }
    }
};

declare function knowledgebase:bibliography($tei as element(tei:TEI)) as element(m:part) {
    
    element { QName('http://read.84000.co/ns/1.0', 'part') } {

        attribute type { 'bibliography' },
        attribute id { 'bibliography' },
        attribute nesting { 0 },
        attribute prefix { 'b' },
        
        let $bibliography := $tei/tei:text/tei:back/tei:div[@type eq 'listBibl']
        return (
        
            let $head := $bibliography/tei:head[@type eq 'listBibl']
            where $head[text()]
            return
                element { QName('http://www.tei-c.org/ns/1.0', 'head') } {
                    attribute type { 'bibliography' },
                    $head/@tid,
                    $head/text()
                }
            ,
            
            $bibliography/*[not(local-name(.) eq 'head' and @type eq 'listBibl')]
            
        )
    }
};

declare function knowledgebase:end-notes($tei as element(tei:TEI)) as element() {
    element { QName('http://read.84000.co/ns/1.0', 'part') } {
        
        attribute type { 'end-notes' },
        attribute id { 'end-notes' },
        attribute nesting { 0 },
        attribute prefix { 'n' },
        attribute glossarize { 'mark' },
            
        element {QName('http://www.tei-c.org/ns/1.0', 'head')} {
            attribute type { 'end-notes' },
            text { 'Notes' }
        },
        
        $tei/tei:text//tei:note[@place eq 'end'][@xml:id]
        
    }
};


declare function knowledgebase:related-texts($tei as element(tei:TEI)) as element()? {
    
    element { QName('http://read.84000.co/ns/1.0', 'part') } {
        
        attribute type { 'related-texts' },
        attribute id { 'related-texts' },
        attribute nesting { 0 },
        attribute prefix { 'a' },
        
        let $knowledgebase-id := tei-content:id($tei)
        let $knowledgebase-entity := $entities:entities//m:instance[@id eq $knowledgebase-id]/parent::m:entity
        let $author-ref := concat('eft:', $knowledgebase-entity/@xml:id)
        let $knowledgebase-title := knowledgebase:titles($tei)//m:title[@type eq 'mainTitle']
        
        return (
            
            element {QName('http://www.tei-c.org/ns/1.0', 'head')} {
                attribute type { 'related-texts' },
                text { 'Texts attributed to '},
                element {QName('http://www.tei-c.org/ns/1.0', 'foreign')} {
                    $knowledgebase-title/@xml:lang,
                    $knowledgebase-title/text()
                }
            },
            
            for $attribution in $tei-content:translations-collection//tei:sourceDesc/tei:bibl//*[@ref eq $author-ref]
            return
                translations:filtered-text($attribution/ancestor::tei:TEI, $attribution/ancestor::tei:bibl/@key, false(), 'none', false())
                
        )
        
    }
    
};

declare function knowledgebase:glossary($tei as element(tei:TEI)) as element()? {

    element { QName('http://read.84000.co/ns/1.0', 'part') } {
        
        attribute type { 'glossary' },
        attribute id { 'glossary' },
        attribute nesting { 0 },
        attribute prefix { 'g' },
        attribute glossarize { 'mark' },
            
        element {QName('http://www.tei-c.org/ns/1.0', 'head')} {
            attribute type { 'glossary' },
            text { 'Glossary' }
        },
        
        $tei/tei:text/tei:back//tei:list[@type eq 'glossary']/tei:item
        
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
                        lower-case(
                            normalize-space($title) (: remove leading & trailing spaces :)
                        )                           (: convert to lower case :)
                    )                               (: remove diacritics :)
                ,'[^a-zA-Z0-9\s]', ' ')             (: remove non-alphanumeric, except spaces :)
            , '\s+')[not(. = $stopwords)]           (: remove stopwords and multiple spaces :)
        , '-')                                      (: concat words with hyphens :)
    
};

declare function knowledgebase:new-tei($id as xs:string, $titles as element(tei:title)*) as document-node()? {
document {
<?xml-model href="../schema/current/knowledgebase.rng" schematypens="http://relaxng.org/ns/structure/1.0"?>,
<TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:eft="http://read.84000.co/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">
    <teiHeader>
        <fileDesc>
            <titleStmt>
            {
                for $title in $titles
                return (
                    common:ws(4),
                    $title
                )
            }
            </titleStmt>
            <editionStmt>
                <edition>v 0.1.0 <date>{ format-date(current-date(), '[Y]') }</date></edition>
            </editionStmt>
            <publicationStmt status="3">
                <publisher>
                    <name>84000: Translating the Words of the Buddha</name>
                </publisher>
                <idno xml:id="EFT-KB-{ upper-case($id) }"/>
                <idno eft:kb-id="{ lower-case($id) }"/>
                <date>{ format-date(current-date(), '[Y0001]-[M01]-[D01]') }</date>
            </publicationStmt>
            <sourceDesc>
                <p>Created by 84000: Translating the Words of the Buddha</p>
            </sourceDesc>
            <notesStmt/>
        </fileDesc>
    </teiHeader>
    <text>
        <front/>
        <body>
            <div type="article">
                { tei-content:new-section('article') }
            </div>
        </body>
        <back>
            <div type="listBibl">
                <head type="listBibl">Bibliography</head>
                { tei-content:new-section('listBibl') }
            </div>
            <div type="glossary">
                <list type="glossary"/>
            </div>
        </back>
    </text>
</TEI>
}};


