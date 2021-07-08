xquery version "3.1";

module namespace knowledgebase="http://read.84000.co/knowledgebase";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";

declare variable $knowledgebase:pages := collection($common:knowledgebase-path);
declare variable $knowledgebase:title-prefixes := '(The|A)';

declare variable $knowledgebase:view-modes := 
    <view-modes xmlns="http://read.84000.co/ns/1.0">
        <view-mode id="default"         client="browser"    layout="full"            glossary="use-cache"       parts="all"/>,
        <view-mode id="editor"          client="browser"    layout="full"            glossary="no-cache"        parts="all"/>,
        <view-mode id="glossary-editor" client="browser"    layout="full"            glossary="use-cache"       parts="all"/>,
        <view-mode id="glossary-check"  client="none"       layout="expanded-fixed"  glossary="no-cache"        parts="all"/>
    </view-modes>;

declare function knowledgebase:kb-id($tei as element(tei:TEI)) as xs:string? {
    $tei/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@m:kb-id][1]/@m:kb-id
};

declare function knowledgebase:sort-name($tei as element(tei:TEI)) as xs:string? {
    replace(
        tei-content:titles($tei)/m:title[@type eq 'mainTitle'][1]/data(), 
        concat($knowledgebase:title-prefixes, '\s+'), ''
    )
    ! normalize-space(.)
    ! lower-case(.)
    ! common:normalized-chars(.)
    ! common:alphanumeric(.)
};


declare function knowledgebase:titles($tei as element(tei:TEI)) as element(m:page) {
    
    let $tei-titles := tei-content:titles($tei)
    return
        element { node-name($tei-titles) }{
            for $title at $index in $tei-titles/m:title
            order by if($title/@type eq 'mainTitle') then 0 else 1
            return
                element { node-name($title) }{
                    attribute type {
                        if($index eq 1) then
                            'mainTitle'
                        else
                            'otherTitle'
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
            attribute uri { base-uri($tei) },
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
        knowledgebase:pages(())
    }
};

declare function knowledgebase:pages($ids as xs:string*) as element(m:page)* {
    
    for $tei in $knowledgebase:pages//tei:TEI[if(count($ids) gt 0) then id($ids) else true()]
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
                attribute glossarize { 'true' },
                
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
        attribute glossarize { 'true' },
            
        element {QName('http://www.tei-c.org/ns/1.0', 'head')} {
            attribute type { 'end-notes' },
            text { 'Notes' }
        },
        
        $tei/tei:text//tei:note[@place eq 'end'][@xml:id]
        
    }
};


declare function knowledgebase:glossary($tei as element(tei:TEI)) as element()? {

    element { QName('http://read.84000.co/ns/1.0', 'part') } {
        
        attribute type { 'glossary' },
        attribute id { 'glossary' },
        attribute nesting { 0 },
        attribute prefix { 'g' },
        attribute glossarize { 'true' },
            
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
                        lower-case($title)      (: convert to lower case :)
                    )                           (: remove diacritics :)
                ,'[^a-zA-Z0-9\s]', ' ')         (: remove non-alphanumeric, except spaces :)
            , '\s+')[not(. = $stopwords)]       (: remove stopwords and multiple spaces :)
        , '-')                                  (: concat words with hyphens :)
    
};

declare function knowledgebase:new-tei($id as xs:string, $title as xs:string) as document-node()? {
document {
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


