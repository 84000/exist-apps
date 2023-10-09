xquery version "3.1";

(: 
    Migration procedure:
    --------------------
    1. Update sections with latest knowledge base content 
    2. Disable triggers
    3. Archive sections in knowledge base
    4. Migrate knowledge base local:migrate-knowledgebase()
    5. Migrate sections local:migrate-sections()
    6. Remove eft-kb-id from lobby and all translated
    7. Find and fix duplicate section ids local:duplicate-section-ids()
    8. Migrate all TEI local:migrate-general()
    9. Merge entities local:merge-entities()
    10. Re-enable triggers
:)

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace m="http://read.84000.co/ns/1.0";
declare namespace eft="http://read.84000.co/ns/1.0";
declare namespace ex="http://exist-db.org/collection-config/1.0";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace glossary="http://read.84000.co/glossary" at "../../84000-reading-room/modules/glossary.xql";
import module namespace update-tei="http://operations.84000.co/update-tei" at "../../84000-operations/modules/update-tei.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";
import module namespace entities="http://read.84000.co/entities" at "../../84000-reading-room/modules/entities.xql";
import module namespace sponsors="http://read.84000.co/sponsors" at "../../84000-reading-room/modules/sponsors.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";
import module namespace update-entity="http://operations.84000.co/update-entity" at "../../84000-operations/modules/update-entity.xql";
import module namespace trigger="http://exist-db.org/xquery/trigger" at "../triggers.xql";
import module namespace functx="http://www.functx.com";

declare variable $local:translations-tei := collection($common:translations-path)//tei:TEI;
declare variable $local:sections-tei := collection($common:sections-path)//tei:TEI;
declare variable $local:knowledgebase-tei := collection($common:knowledgebase-path)//tei:TEI;
declare variable $local:layout-checks-tei := collection(concat($common:tei-path, '/layout-checks'))//tei:TEI;
declare variable $local:all-tei := (
    $local:translations-tei
    | $local:sections-tei
    | $local:knowledgebase-tei
    | $local:layout-checks-tei
);

declare function local:gloss-refactored($tei as element(tei:TEI)) {

    (: Be extra sure not to do this twice :)
    if(not($tei//tei:revisionDesc/tei:change[@type eq 'text-version']/tei:desc[matches(text(), functx:escape-for-regex(' migrated to 2.19.0'), 'i')])) then
        
        (: Update glosses individually to preserve any other content in the glossary :)
        for $gloss in $tei//tei:back//tei:gloss
        let $entity-instance := $entities:entities//m:instance[@id eq $gloss/@xml:id]
        let $gloss-refactored:= 
            element { QName('http://www.tei-c.org/ns/1.0','gloss') } {
            
                (: Copy gloss attributes :)
                $gloss/@*,
                
                (: Translation :)
                for $term at $index in ($gloss/tei:term[not(@type)][not(@xml:lang)] | $gloss/tei:term[@type = ('translation','translationMain')])
                return (
                    text{ common:ws(7) },
                    element { QName('http://www.tei-c.org/ns/1.0', 'term') } {
                        attribute type { if($index eq 1) then 'translationMain' else 'translationAlternative' },
                        text { string-join($term/text()) ! normalize-space(.) }
                    }
                ),
                
                (: Alternatives :)
                for $term in $gloss/tei:term[@type = ('alternative','translationAlternative')]
                return (
                    text{ common:ws(7) },
                    element { QName('http://www.tei-c.org/ns/1.0', 'term') } {
                        attribute type { 'translationAlternative' },
                        text { string-join($term/text()) ! normalize-space(.) }
                    }
                ),
                
                (: Sanskrit :)
                for $term in $gloss/tei:term[@xml:lang eq 'Sa-Ltn']
                let $attestation-type := ($glossary:attestation-types//m:attestation-type[@id eq $term/@type] | $glossary:attestation-types//m:attestation-type[m:migrate/@id = $term/@type] | $glossary:attestation-types//m:attestation-type[m:appliesToLang[@xml:lang eq $term/@xml:lang][@default]][1] )[1]
                return (
                    text{ common:ws(7) },
                    element { QName('http://www.tei-c.org/ns/1.0', 'term') } {
                        attribute xml:lang { 'Sa-Ltn' },
                        attribute type { $attestation-type/@id },
                        $term/@status,
                        text { string-join($term/text()) ! lower-case(.) ! normalize-unicode(.) ! normalize-space(.) }
                    }
                ),
                
                (: Tibetan :)
                for $term at $index in $gloss/tei:term[@xml:lang eq 'Bo-Ltn']
                let $term-bo-ltn := string-join($term/text()) (:! lower-case(.):) ! normalize-unicode(.) ! normalize-space(.)
                let $attestation-type := ($glossary:attestation-types//m:attestation-type[@id eq $term/@type] | $glossary:attestation-types//m:attestation-type[m:migrate/@id = $term/@type] | $glossary:attestation-types//m:attestation-type[m:appliesToLang[@xml:lang eq $term/@xml:lang][@default]][1] )[1]
                return (
                    text{ common:ws(7) },
                    element { QName('http://www.tei-c.org/ns/1.0', 'term') } {
                        attribute xml:lang { 'Bo-Ltn' },
                        attribute type { $attestation-type/@id },
                        attribute n { $index },
                        $term/@status,
                        text { $term-bo-ltn }
                    },
                    text{ common:ws(7) },
                    element { QName('http://www.tei-c.org/ns/1.0', 'term') } {
                        attribute xml:lang { 'bo' },
                        attribute type { $attestation-type/@id },
                        attribute n { $index },
                        $term/@status,
                        text { common:bo-term($term-bo-ltn) }
                    }
                ),
                
                (: Other source terms :)
                for $term in $gloss/tei:term[@xml:lang][not(@xml:lang = ('Sa-Ltn','Bo-Ltn','bo'))]
                let $attestation-type := ($glossary:attestation-types//m:attestation-type[@id eq $term/@type] | $glossary:attestation-types//m:attestation-type[m:migrate/@id = $term/@type] | $glossary:attestation-types//m:attestation-type[m:appliesToLang[@xml:lang eq $term/@xml:lang][@default]][1] | $glossary:attestation-types//m:attestation-type[@id eq 'sourceUnspecified'] )[1]
                return(
                    text{ common:ws(7) },
                    element { QName('http://www.tei-c.org/ns/1.0', 'term') } {
                        $term/@xml:lang,
                        attribute type { $attestation-type/@id },
                        $term/@status,
                        text { string-join($term/text()) ! normalize-unicode(.) ! normalize-space(.) }
                    }
                ),
                
                (: Definitions :)
                if($gloss/tei:*[@type eq 'definition'][not(self::tei:note)][descendant::text()[normalize-space()]]) then (
                    text{ common:ws(7) },
                    element { QName('http://www.tei-c.org/ns/1.0', 'note') } {
                        
                        attribute type { 'definition' },
                        
                        if($entity-instance[@use-definition]) then (
                            attribute rend { $entity-instance/@use-definition/string() }
                        )
                        else(),
                        
                        for $definition in $gloss/tei:*[@type eq 'definition'][not(self::tei:note)]
                        return (
                            text{ common:ws(8) },
                            element { QName('http://www.tei-c.org/ns/1.0', 'p') } {
                                $definition/node()
                            }
                        ),
                        
                        text{ common:ws(7) }
                        
                    }
                )
                else 
                    for $definition in $gloss/tei:note[@type eq 'definition']
                    return (
                        text{ common:ws(7) },
                        $definition
                    )
                ,
                
                (: Retain comments :)
                for $comment in $gloss/comment()
                return (
                    text{ common:ws(7) },
                    $comment
                ),
                
                (: Whitespace :)
                text{ common:ws(6) }
                
            }
        
        return (
            update replace $gloss with $gloss-refactored,
            if($entity-instance[@use-definition] and $gloss-refactored/tei:note[@rend eq $entity-instance/@use-definition]) then
                update delete $entity-instance/@use-definition
            else ()
        )
    else ()
};

declare function local:term-type-to-rend($tei as element(tei:TEI)){

    for $term in $tei//tei:term[@type eq 'ignore']
    return (
        update insert attribute rend { 'ignore' } into $term,
        update delete $term/@type
    )

};

declare function local:ref-prefixes($tei as element(tei:TEI)) {

    for $ref in $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:*[matches(@ref, '^(sponsors|contributors)\.xml#')]/@ref
    return (
        (:$ref/string(),:)
        update replace $ref with attribute ref { replace($ref/string(), '^(sponsors|contributors)\.xml#', 'eft:') }
    )
    
};

declare function local:migrate-entity-refs($tei as element(tei:TEI)) {
    
    (: Calculate the next id :)
    let $text-id := tei-content:id($tei)
    let $xml-ids := $tei//@xml:id[not(parent::tei:idno)][not(parent::tei:div)]
    let $xml-ids-max := max($xml-ids ! substring-after(., $text-id) ! substring(., 2) ! common:integer(.))
    
    return (
    
        (: For each attribution :)
        for $attribution at $index in (
            $tei//tei:sourceDesc/tei:bibl/tei:author
            | $tei//tei:sourceDesc/tei:bibl/tei:editor
            | $tei//tei:titleStmt/tei:author 
            | $tei//tei:titleStmt/tei:editor 
            | $tei//tei:titleStmt/tei:consultant
            | $tei//tei:titleStmt/tei:sponsor
        )[@ref](:[not(@xml:id)]:)
        
        let $next-id := 
            if(not($attribution[@xml:id])) then
                concat($text-id, '-', xs:string(sum(($xml-ids-max, $index))))
            else
                $attribution/@xml:id/string()
        
        let $attribution-ref := $attribution/@ref ! lower-case(replace(., '^eft:', '', 'i'))
        
        where $attribution-ref[. gt '']
        return (
            
            (: Add an xml:id :)
            if($attribution[not(@xml:id)]) then
                update insert attribute xml:id { $next-id } into $attribution
            else ()
            ,
            
            (: Entities :)
            if($attribution[parent::tei:bibl]) then 
                let $entity := $entities:entities/id($attribution-ref)
                let $entity := 
                    if(not($entity)) then
                        $entities:entities//m:relation[@predicate eq 'sameAs'][@id eq $attribution-ref]/parent::m:entity
                    else
                        $entity
                let $instance := 
                    element { QName('http://read.84000.co/ns/1.0','instance') } {
                        attribute id { $next-id },
                        attribute type { 'source-attribution' }
                    }
                where $entity
                (: Add an instance to the entity and remove the ref :)
                return (
                    update insert ($instance, text{ common:ws(2) }) into $entity,
                    update delete $attribution/@ref
                )
            
            (: Sponsors :)
            else if($attribution[parent::tei:titleStmt][self::tei:sponsor]) then 
                let $sponsor :=  $sponsors:sponsors/id($attribution-ref)
                let $instance := 
                    element { QName('http://read.84000.co/ns/1.0','instance') } {
                        attribute id { $next-id },
                        attribute type { 'translation-sponsor' }
                    }
                where $sponsor
                (: Add an instance to the entity and remove the ref :)
                return (
                    update insert ($instance, text{ common:ws(1) }) into $sponsor,
                    update delete $attribution/@ref
                )
            
            (: Other contributors :)
            else if($attribution[parent::tei:titleStmt]) then 
                let $contributor := $contributors:contributors/id($attribution-ref)
                let $instance := 
                    element { QName('http://read.84000.co/ns/1.0','instance') } {
                        attribute id { $next-id },
                        attribute type { 'translation-contribution' }
                    }
                where $contributor
                (: Add an instance to the entity and remove the ref :)
                return (
                    update insert ($instance, text{ common:ws(1) }) into $contributor,
                    update delete $attribution/@ref
                )
                
            else ()
        )
        
    )
        
};

declare function local:migrate-publication-status($tei as element(tei:TEI)) {
    
    let $publicationStmt := $tei/tei:teiHeader/tei:fileDesc/tei:publicationStmt
    
    where $publicationStmt[@status]
    return (
        let $insert-status :=
            if($publicationStmt[tei:availability]) then
                update insert $publicationStmt/@status into $publicationStmt/tei:availability
            else 
                update insert element { QName('http://www.tei-c.org/ns/1.0','availability') } { $publicationStmt/@status } preceding $publicationStmt/tei:idno[@xml:id]
        
        where $publicationStmt/tei:availability[@status]
        return
            update delete $publicationStmt/@status
    )
    
};

declare function local:create-revisionDesc($tei as element(tei:TEI)) {

    let $fileDesc := $tei/tei:teiHeader/tei:fileDesc
    where $fileDesc[not(tei:revisionDesc)]
    return
    
        let $notesStmt := $fileDesc/tei:notesStmt
        
        let $text-id := tei-content:id($tei)
        let $max-id := max($tei//@xml:id ! substring-after(., concat($text-id, '-')) ! tokenize(., '-')[1][functx:is-a-number(.)] ! common:integer(.))
    
        (: Create revisionDesc :)
        let $revisionDesc := 
            element { QName('http://www.tei-c.org/ns/1.0', 'revisionDesc') } {
                
                for $update at $index in $notesStmt/tei:note[@type eq 'updated']
                return (
                    text{ common:ws(4) },
                    element change {
                        attribute who { '#' || $update/@user },
                        attribute when { $update/@date-time },
                        attribute type { $update/@update },
                        if($update[@update = ('text-version','translation-status','publication-status')]) then
                            attribute status { $update/@value }
                        else ()
                        ,
                        attribute xml:id { string-join(($text-id, xs:string(sum(($max-id, $index)))), '-') },
                        $update/@target,
                        $update/@import ! attribute source { string() },
                        element desc { string-join($update/text()) }
                    }
                ),
                
                text{ common:ws(3) }
                
            }
        
        (: Revise notesStmt :)
        let $notesStmt-revised :=
            element { QName('http://www.tei-c.org/ns/1.0', 'notesStmt') } {
                $notesStmt/tei:note[not(@type = ('updated', 'lastUpdated'))]
            }
        
        return (
            update insert ( text{ $common:chr-tab }, $revisionDesc, text{ common:ws(2) } ) into $tei/tei:teiHeader/tei:fileDesc,
            update replace $notesStmt with $notesStmt-revised
        )

};

declare function local:migrate-knowledgebase() {

    for $tei in $local:knowledgebase-tei
    let $kb-id := $tei/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@m:kb-id]
    let $kb-idno :=
        element { QName('http://www.tei-c.org/ns/1.0','idno') } {
            attribute type { 'eft-kb-id' },
            text { $kb-id/@m:kb-id }
        }
        
    where $kb-id(:[@m:kb-id eq 'amrapali']:)
    return (
        $kb-idno,
        update replace $kb-id with $kb-idno
    )
    
};

declare function local:migrate-sections() {

    for $tei in $local:sections-tei
    let $text-id := tei-content:id($tei)
    let $work := $tei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/@work
    let $main-title := ($tei//tei:titleStmt/tei:title[@xml:lang eq 'en'])[1]
    
    where $text-id (:= ('O1JC114941JC14665'):)
    return 
        element section {
        
            attribute text-id { $text-id },
            
            (: Add a KB title :)
            if(not($tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type eq 'articleTitle']) and not($main-title[matches(., 'The\s(Kangyur|Tengyur|Collection)')])) then
                let $work-name := if($work eq 'W22084') then 'Kangyur' else 'Tengyur'
                let $article-title :=
                    element { QName('http://www.tei-c.org/ns/1.0','title') } {
                        attribute type { 'articleTitle' },
                        attribute xml:lang { 'en' },
                        text { $main-title || ' (' || $work-name || ' Section)' }
                    }
                return (
                    $article-title,
                    update insert ($article-title, text{ common:ws(4) }) into $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt
                    
                )
            else (),
            
            (: Add a KB id :)
            if(not($tei/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type eq 'eft-kb-id'])) then
                let $title-as-id := translation:filename($tei, '') ! string-join(subsequence(tokenize(., '\-')[not(. = ('_84000', 'the', 'on', 'of', 'for', 'and', 'by', 'a', 's'))], 1, 6), '-')
                let $kb-idno :=
                    element { QName('http://www.tei-c.org/ns/1.0','idno') } {
                        attribute type { 'eft-kb-id' },
                        text { $title-as-id }
                    }
                return (
                    $kb-idno,
                    update insert (text{ common:ws(4) }, $kb-idno) following $tei/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@xml:id]
                )
            else(),
            
            (: Set publication status - dependant on content :)
            if(not($tei/tei:teiHeader/tei:fileDesc/tei:publicationStmt[@status eq '1'])) then
                let $publication-status := attribute status { if($tei/tei:text/tei:body//*[text()][not(ancestor-or-self::*[@rend eq 'default-text'])]) then '1' else '2.a' }
                return (
                    element { QName('http://www.tei-c.org/ns/1.0','publicationStmt') } { $publication-status },
                    update insert $publication-status into $tei/tei:teiHeader/tei:fileDesc/tei:publicationStmt
                )
            else (),
            
            (: Add Edition statement :)
            if(not($tei/tei:teiHeader/tei:fileDesc/tei:editionStmt)) then
                let $edition-statement :=
                    element { QName('http://www.tei-c.org/ns/1.0','editionStmt') } {
                        element edition {
                            text { 'v 0.1.0 ' },
                            element date { format-date(current-date(), '[Y]') }
                        }
                    }
                return (
                    $edition-statement,
                    update insert (text{ common:ws(3) }, $edition-statement) following $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt
                )
            else (),
            
            (: Convert about to article :)
            let $about := $tei/tei:text/tei:body/tei:div[@type eq 'about'][1]
            let $article := $tei/tei:text/tei:body/tei:div[@type eq 'article'][1]
            let $type-article := attribute type { 'article' }
            return 
                
                (: Update type :)
                if($about and not($article)) then (
                
                    update replace $about/@type with $type-article,
                    update replace $about/tei:head[1]/@type with $type-article,
                    
                    (: Return something :)
                    element { QName('http://www.tei-c.org/ns/1.0','div') } { $type-article }
                    
                )
                
                (: Insert article stub :)
                else if(not($article) and not($text-id = ('LOBBY','ALL-TRANSLATED'))) then
                
                    let $article :=
                        element { QName('http://www.tei-c.org/ns/1.0','div') } { 
                             $type-article,
                             tei-content:new-section('article')
                        }
                        
                    return
                        update insert $article into $tei/tei:text/tei:body
                 
                 else ()
            ,
            
            (: Add placeholder back matter :)
            if(not($tei/tei:text/tei:back)) then 
                let $back-placeholder := 
                    element { QName('http://www.tei-c.org/ns/1.0','back') } {
                        element div {
                            attribute type { 'listBibl' },
                            element head {
                                attribute type { 'listBibl' },
                                text { 'Bibliography' }
                            },
                            tei-content:new-section('listBibl')
                        },
                        element div {
                            attribute type { 'glossary' },
                            element list {
                                attribute type { 'glossary' }
                            }
                        }
                    }
                return (
                    $back-placeholder,
                    update insert (text{ common:ws(2) }, $back-placeholder) following $tei/tei:text/tei:body
                )
            else (),
            
            trigger:after-update-document(base-uri($tei)),
            
            util:log('info', concat($text-id, ' migrated to 2.19.0'))
            
        }
    
};

declare function local:duplicate-section-ids() {
    let $eft-kb-ids := $local:sections-tei//tei:idno[@type eq 'eft-kb-id']
    for $eft-kb-id in $eft-kb-ids
    where ($eft-kb-ids except $eft-kb-id)[compare(text(), $eft-kb-id/text()) eq 0]
    return
        $eft-kb-id
};

declare function local:migrate-general() {
    
    for $tei in $local:all-tei
    let $text-id := tei-content:id($tei)
    where 
        $text-id (:= ('UT22084-000-000', 'UT23703-000-000', 'UT22084-001-006','UT23703-093-001', 'UT23703-124-001', 'UT22084-040-003', 'UT22084-026-001', 'UT22084-014-001', 'UT22084-012-002'):)
        and not($tei//tei:revisionDesc/tei:change[@type eq 'text-version']/tei:desc[matches(text(), functx:escape-for-regex(' migrated to 2.19.0'), 'i')])
        (:and $tei//tei:fileDesc//*[@ref]:)
    return 
        (:if(true()) then $text-id else:)
        (# exist:batch-transaction #) {
            
            local:gloss-refactored($tei),
            
            local:term-type-to-rend($tei),
            
            local:ref-prefixes($tei),
            
            local:migrate-entity-refs($tei),
            
            local:migrate-publication-status($tei),
            
            local:create-revisionDesc($tei),
            
            update-tei:minor-version-increment($tei, 'TEI migrated to 2.19.0'),
            
            util:log('info', concat($text-id, ' migrated to 2.19.0')),
            
            'migrated-general: ' || $text-id
            
        }
};

declare function local:merge-entities() {
    (# exist:batch-transaction #) {

        let $entity-refs := $local:all-tei//tei:fileDesc//*[@ref]
        return
            (: Check there are no entity refs left in the TEI :)
            if($entity-refs) then (
                <warning>{ 'TEI STILL CONTAINS ', count($entity-refs) ,' ENTITY REFS' }</warning>,
                for $entity-ref in $entity-refs
                let $tei := $entity-ref/ancestor::tei:TEI[1]
                let $text-id := tei-content:id($tei)
                group by $text-id
                return
                    element tei {
                        attribute text-id { $text-id },
                        $entity-ref
                    }
            )
            (: Merge each entity with sameAs :)
            else
                for $entity in $entities:entities/m:entity[m:relation[@predicate eq 'sameAs']]
                let $target-entity := $entities:entities/id($entity/m:relation[@predicate eq 'sameAs']/@id) except $entity
                where $target-entity
                return 
                    update-entity:merge($entity/@xml:id, $target-entity/@xml:id)
        
    }
};

let $trigger := doc(concat('/db/system/config',$common:tei-path, '/collection.xconf'))/ex:collection/ex:triggers/ex:trigger

(: RUN MIGRATION :)
return (

    local:migrate-knowledgebase(),
    
    (: DISABLE TRIGGER :)
    (:if($trigger) then 
        <warning>{ 'DISABLE TRIGGERS BEFORE MIGRATING SECTIONS' }</warning>
    else 
        local:migrate-sections()
    ,:)
    
    (:local:duplicate-section-ids(),:)
    
    (: DISABLE TRIGGER :)
    (:if($trigger) then 
        <warning>{ 'DISABLE TRIGGERS BEFORE MIGRATING TRANSLATIONS' }</warning>
    else 
        local:migrate-general()
    ,:)
    
    (:local:merge-entities(),:)
    
    util:log('info', '2.19.0 migration complete!')
    
)