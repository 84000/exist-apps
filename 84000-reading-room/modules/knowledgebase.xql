xquery version "3.1";

module namespace knowledgebase="http://read.84000.co/knowledgebase";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace common="http://read.84000.co/common" at "common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "tei-content.xql";
import module namespace glossary="http://read.84000.co/glossary" at "glossary.xql";
import module namespace entities="http://read.84000.co/entities" at "entities.xql";
import module namespace translations="http://read.84000.co/translations" at "translations.xql";
import module namespace functx="http://www.functx.com";

declare variable $knowledgebase:tei := (
    collection($common:knowledgebase-path)//tei:TEI
    | collection($common:sections-path)//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt[not(tei:idno/@xml:id = ('LOBBY','ALL-TRANSLATED'))]]
);

declare variable $knowledgebase:tei-render := 
    $knowledgebase:tei
        [tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability
            [@status = $common:environment/m:render/m:status[@type eq 'article']/@status-id]
        ];

declare variable $knowledgebase:title-prefixes := '(The|A)';

declare variable $knowledgebase:view-modes := 
    <view-modes xmlns="http://read.84000.co/ns/1.0">
        <view-mode id="default"          client="browser"  cache="use-cache"  layout="full"  glossary="use-cache"  parts="all"/>
        <view-mode id="editor"           client="browser"  cache="suppress"   layout="full"  glossary="no-cache"   parts="all"/>
        <view-mode id="glossary-editor"  client="browser"  cache="suppress"   layout="full"  glossary="use-cache"  parts="all"/>
        <view-mode id="glossary-check"   client="browser"  cache="suppress"   layout="flat"  glossary="no-cache"   parts="all"/>
    </view-modes>;

declare variable $knowledgebase:article-types := 
    <article-types xmlns="http://read.84000.co/ns/1.0">
        <type id="articles">Articles</type>
        <type id="authors">Authors</type>
        <type id="sections">Sections</type>
    </article-types>;

declare function knowledgebase:kb-id($tei as element(tei:TEI)) as xs:string? {
    $tei/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type eq 'eft-kb-id'][1]/text() ! normalize-space(.)
};

declare function knowledgebase:sort-name($tei as element(tei:TEI)) as xs:string? {
    
    let $titles := tei-content:titles-all($tei)
    
    let $sort-title := (
        $titles/m:title[@type eq 'articleTitle'],
        $titles/m:title[@type eq 'mainTitle'][not(@xml:lang eq 'bo')][normalize-space(text())],
        $titles/m:title[not(@xml:lang eq 'bo')]
    )[1]
    
    return
        replace($sort-title/data(), concat('^', $knowledgebase:title-prefixes, '\s+'), '', 'i')
        ! normalize-space(.)
        ! lower-case(.)
        ! common:normalized-chars(.)
        ! common:alphanumeric(.)
};

declare function knowledgebase:titles($tei as element(tei:TEI)) as element(m:titles) {
    
    let $tei-titles := tei-content:titles-all($tei)
    
    return
        element { node-name($tei-titles) }{
            for $title in $tei-titles/m:title[text()]
            order by 
                if($title/@type eq 'articleTitle') then 0 else if($title/@type eq 'mainTitle') then 1 else 2 ascending,
                if($title/@xml:lang eq 'en') then 0 else if($title/@xml:lang eq 'Sa-Ltn') then 1 else 2 ascending
            return
                element { node-name($title) }{
                    $title/@*,
                    $title/node()
                }
        }
    
};

declare function knowledgebase:page($tei as element(tei:TEI)) as element(m:page)? {
    
    let $text-id := tei-content:id($tei)
    let $kb-id := knowledgebase:kb-id($tei)
    let $sort-name := knowledgebase:sort-name($tei)
    let $entity := $entities:entities//m:instance[range:eq(@id, $text-id)]/parent::m:entity[1]
    
    where $kb-id
    return
        element { QName('http://read.84000.co/ns/1.0', 'page') }{
            attribute xml:id { $text-id },
            attribute kb-id { $kb-id },
            attribute document-url { base-uri($tei) },
            attribute locked-by-user { tei-content:locked-by-user($tei) },
            attribute last-updated { tei-content:last-modified($tei) },
            attribute tei-version { tei-content:version-number-str($tei) },
            attribute status { tei-content:publication-status($tei) },
            attribute status-group { tei-content:publication-status-group($tei) },
            attribute page-url { concat($common:environment/m:url[@id eq 'reading-room'], '/knowledgebase/', $kb-id, '.html') },
            attribute type { 
                if($tei/tei:teiHeader/tei:fileDesc[@type = ('section','grouping','pseudo-section')]) then 
                    'section'
                else if($entity/m:instance[@type eq 'source-attribution']) then
                    'author'
                else 
                    'article'
            },
            attribute start-letter { upper-case(substring($sort-name, 1, 1)) },
            
            element sort-name { $sort-name },
            
            knowledgebase:titles($tei),
            
            (:$entities:entities//m:instance[range:eq(@id, $text-id)]/parent::m:entity:)
            
            $tei/tei:teiHeader/tei:fileDesc[@type = ('section','grouping','pseudo-section')] ! element section { attribute id { $text-id } },
            
            element summary { 
                if($tei//tei:front/tei:div[@type eq 'abstract']) then 
                    $tei//tei:front/tei:div[@type eq 'abstract']/node()
                (:else if($tei//tei:body/tei:div[@type eq 'article']) then
                    tei-content:preview($tei//tei:body/tei:div[@type eq 'article']):)
                else ()
            }
            
        }
};

declare function knowledgebase:pages() as element(m:knowledgebase) {
    element { QName('http://read.84000.co/ns/1.0', 'knowledgebase') }{
        knowledgebase:pages('all', false(), ())
    }
};

declare function knowledgebase:pages($ids as xs:string*, $published-only as xs:boolean, $sort as xs:string?) as element(m:page)* {
    
    let $teis := 
        if($published-only) then
            $knowledgebase:tei-render
        else
            $knowledgebase:tei
    
    let $sections-tei := $teis[tei:teiHeader/tei:fileDesc/@type = ('section','grouping','pseudo-section')]
    
    let $author-entities := $entities:entities//m:instance[@type eq 'source-attribution']/parent::m:entity
    let $author-kb-ids := $author-entities/m:instance[@type eq 'knowledgebase-article']/@id
    let $authors-tei := $teis/id($author-kb-ids)/ancestor::tei:TEI
    
    let $teis := (
    
        if($ids = ('sections','all')) then
            $sections-tei
        else (),
        
        if($ids = ('authors','all')) then
            $authors-tei
        else (),
        
        (: Everything other than authors and sections :)
        if($ids = ('articles','all')) then
            $teis except ($sections-tei | $authors-tei) 
        else (),
        
        $teis/id($ids)/ancestor::tei:TEI
        
    )
    
    for $tei in $teis
    let $kb-page := knowledgebase:page($tei)
    order by
        if($sort eq 'latest') then $kb-page/@last-updated ! xs:dateTime(.) else true() descending,
        if($sort eq 'status') then $tei-content:text-statuses/m:status[@type eq 'article'][@status-id eq $kb-page/@status]/@status-id else true() ascending,
        $kb-page/m:sort-name
    return 
        $kb-page

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
                        $contributor/@xml:id,
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

declare function knowledgebase:abstract($tei as element(tei:TEI)) as element(m:part)? {

    $tei/tei:text/tei:front/tei:div[@type eq 'abstract'] ! 
    element { QName('http://read.84000.co/ns/1.0', 'part') } {
        attribute type { 'abstract' },
        attribute id { 'abstract' },
        attribute nesting { 0 },
        attribute prefix { 'ab' },
        attribute content-status { 'complete' },
        *
    }
};

declare function knowledgebase:article($tei as element(tei:TEI)) as element(m:part) {

    element { QName('http://read.84000.co/ns/1.0', 'part') } {

        attribute type { 'article' },
        attribute id { 'article' },
        attribute nesting { 0 },
        attribute prefix { 'a' },
        attribute content-status { 'complete' },
        
        for $section at $index in $tei/tei:text/tei:body/tei:div[@type eq 'article']/tei:div
        return
            element { QName('http://read.84000.co/ns/1.0', 'part') } {

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
        let $knowledgebase-title := knowledgebase:titles($tei)//m:title[@type eq 'mainTitle'][1]
        
        return (
            
            element {QName('http://www.tei-c.org/ns/1.0', 'head')} {
                attribute type { 'related-texts' },
                text { 'Texts attributed to '},
                element {QName('http://www.tei-c.org/ns/1.0', 'foreign')} {
                    $knowledgebase-title/@xml:lang,
                    $knowledgebase-title/text()
                }
            },
            
            for $attribution in $tei-content:translations-collection//tei:sourceDesc/tei:bibl//*[@xml:id = $knowledgebase-entity/m:instance/@id]
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
        
        $tei/tei:text/tei:back//tei:list[@type eq 'glossary']/tei:item/tei:gloss[@xml:id][not(@mode eq 'surfeit')]
        
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
            <publicationStmt>
                <publisher>
                    <name>84000: Translating the Words of the Buddha</name>
                </publisher>
                <availability status="3"/>
                <idno xml:id="EFT-KB-{ upper-case($id) }"/>
                <idno type="eft-kb-id">{ lower-case($id) }</idno>
                <date>{ format-date(current-date(), '[Y0001]-[M01]-[D01]') }</date>
            </publicationStmt>
            <sourceDesc>
                <p>Created by 84000: Translating the Words of the Buddha</p>
            </sourceDesc>
            <notesStmt/>
            <revisionDesc/>
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

declare function knowledgebase:outline($tei as element(tei:TEI)) as element(m:text-outline)* {
    
    let $text-id := tei-content:id($tei)
    let $app-version := replace($common:app-version, '\.', '-')
    
    return
        element { QName('http://read.84000.co/ns/1.0', 'text-outline') } {
            
            attribute text-id { $text-id },
            attribute app-version { $app-version },
            
            tei-content:titles-all($tei),
            tei-content:milestones-pre-processed($tei),
            tei-content:end-notes-pre-processed($tei),
            glossary:pre-processed($tei)
            
        }
};

