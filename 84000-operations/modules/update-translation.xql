module namespace update-translation="http://operations.84000.co/update-translation";

import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace sponsors="http://read.84000.co/sponsors" at "../../84000-reading-room/modules/sponsors.xql";
import module namespace contributors="http://read.84000.co/contributors" at "../../84000-reading-room/modules/contributors.xql";
import module namespace sponsorship="http://read.84000.co/sponsorship" at "../../84000-reading-room/modules/sponsorship.xql";
import module namespace functx="http://www.functx.com";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function update-translation:update($tei as element()) as element()* {
    
    (: exist:batch-transaction should defer triggers until all updates are made :)
    (# exist:batch-transaction #) {
        
        (: If we are updating these nodes then add notes to notesStmt :)
        let $parameter-add-notes:= ('translation-status', 'text-version')
        
        let $text-id := tei-content:id($tei)
        
        return
            (: The updates have to follow in the correct order e.g. input-1, input-2... :)
            for $request-parameter in common:sort-trailing-number-in-string(request:get-parameter-names(), '-')
                
                (: Get the new value :)
                let $new-value := 
                
                    (: Title node :)
                    if(starts-with($request-parameter, 'title-text-')) then
                        let $title-index := substring-after($request-parameter, 'title-text-')
                        let $title-type := request:get-parameter(concat('title-type-', $title-index), '')
                        let $title-lang := request:get-parameter(concat('title-lang-', $title-index), '')
                        let $title-text := request:get-parameter(concat('title-text-', $title-index), '')
                        return
                            if($title-text gt '') then
                                element { QName("http://www.tei-c.org/ns/1.0", "title") }{
                                    attribute type { $title-type },
                                    attribute xml:lang { $title-lang },
                                    text { $title-text }
                                }
                            else
                                ()
                    
                    (: Location :)
                    else if(starts-with($request-parameter, 'location-')) then
                        let $toh-key := substring-after($request-parameter, 'location-')
                        return
                            element { QName("http://www.tei-c.org/ns/1.0", "location") }{
                                attribute count-pages { request:get-parameter(concat('count-pages-', $toh-key), '0') },
                                element start {
                                    attribute volume { request:get-parameter(concat('start-volume-', $toh-key), '0') },
                                    attribute page { request:get-parameter(concat('start-page-', $toh-key), '0') }
                                },
                                element end {
                                    attribute volume { request:get-parameter(concat('end-volume-', $toh-key), '0') },
                                    attribute page { request:get-parameter(concat('end-page-', $toh-key), '0') }
                                }
                            }
                    
                    (: Translator summary node may or may not exist :)
                    else if($request-parameter eq 'translator-team-id') then
                        if($tei//tei:fileDesc/tei:titleStmt/tei:author[@role eq 'translatorMain'][1]) then
                            functx:add-or-update-attributes(
                                $tei//tei:fileDesc/tei:titleStmt/tei:author[@role eq 'translatorMain'][1], 
                                xs:QName('ref'), 
                                request:get-parameter('translator-team-id', '')
                            )
                         else
                            element { QName("http://www.tei-c.org/ns/1.0", "author") }{
                                attribute role { "translatorMain" },
                                attribute ref { request:get-parameter('translator-team-id', '') }
                            }
                    
                    (: Sponsor node :)
                    else if(starts-with($request-parameter, 'sponsor-id-')) then
                        let $sponsor-index := substring-after($request-parameter, 'sponsor-id-')
                        let $sponsor-id := request:get-parameter(concat('sponsor-id-', $sponsor-index), '')
                        let $sponsor-expression := request:get-parameter(concat('sponsor-expression-', $sponsor-index), '')
                        let $sponsor-expression := 
                            if($sponsor-expression gt '') then
                                $sponsor-expression
                            else
                                $sponsors:sponsors//m:sponsor[@xml:id eq substring-after($sponsor-id, 'sponsors.xml#')]/m:label/text()
                                
                        return
                            if($sponsor-id) then
                                element { QName("http://www.tei-c.org/ns/1.0", "sponsor") }{
                                    attribute ref { $sponsor-id },
                                    text { $sponsor-expression }
                                }
                            else
                                ()
                    
                    (: Contributor (author/editor node :)
                    else if(starts-with($request-parameter, 'contributor-id-')) then
                        let $contributor-index := substring-after($request-parameter, 'contributor-id-')
                        let $contributor-id := request:get-parameter(concat('contributor-id-', $contributor-index), '')
                        let $contributor-type := request:get-parameter(concat('contributor-type-', $contributor-index), '')
                        let $contributor-type-tokenized := tokenize($contributor-type, '-')
                        let $contributor-node-name := $contributor-type-tokenized[1]
                        let $contributor-role := if(count($contributor-type-tokenized) eq 2) then $contributor-type-tokenized[2] else ''
                        let $contributor-expression := request:get-parameter(concat('contributor-expression-', $contributor-index), '')
                        let $contributor-expression := 
                            if($contributor-expression gt '') then
                                $contributor-expression
                            else
                                $contributors:contributors//m:person[@xml:id eq substring-after($contributor-id, 'contributors.xml#')]/m:label/text()
                        return
                            if($contributor-id and $contributor-node-name and $contributor-role) then
                                element { QName("http://www.tei-c.org/ns/1.0", $contributor-node-name) }{
                                    attribute role { $contributor-role },
                                    attribute ref { $contributor-id },
                                    text { $contributor-expression }
                                }
                            else
                                ()
                    
                    (: Version :)
                    else if($request-parameter eq 'text-version') then
                        element { QName("http://www.tei-c.org/ns/1.0", "editionStmt") }{
                            element edition {
                                text { concat(normalize-space(request:get-parameter('text-version', '')), ' ') },
                                if(request:get-parameter('text-version-date', '')) then
                                    element date {
                                        request:get-parameter('text-version-date', '')
                                    }
                                else 
                                    ()
                            }
                        }
                    
                    (: Publication date :)
                    else if($request-parameter eq 'publication-date') then
                        element { QName("http://www.tei-c.org/ns/1.0", "date") }{
                            text { request:get-parameter('publication-date', '') }
                        }
                        
                    (: Sponsorship use text-id as default for project-id :)
                    else if($request-parameter = ('sponsorship-project-id') and $text-id) then
                        sponsorship:project-posted($text-id)
                    
                    (: Attributes: translation status :)
                    else if($request-parameter = ('translation-status')) then
                        attribute {'status'} {
                            (: force zero to '' :)
                            if(request:get-parameter($request-parameter, '') eq '0') then
                                ''
                            else
                                request:get-parameter($request-parameter, '')
                        }
                
                (: Default to a string value :)
                else if(not(ends-with($request-parameter, '[]'))) then
                    request:get-parameter($request-parameter, '')
                else
                    ()
            
            (: Get the context so we can add :)
            let $parent :=
                if(starts-with($request-parameter, 'title-text-')) then
                    $tei//tei:fileDesc/tei:titleStmt
                else if(starts-with($request-parameter, 'location-')) then
                     $tei//tei:fileDesc/tei:sourceDesc/tei:bibl[@key eq substring-after($request-parameter, 'location-')]
                else if($request-parameter eq 'translation-status') then
                    $tei//tei:fileDesc/tei:publicationStmt
                else if(starts-with($request-parameter, 'sponsor-id-')) then
                    $tei//tei:fileDesc/tei:titleStmt
                else if($request-parameter eq 'translator-team-id') then
                    $tei//tei:fileDesc/tei:titleStmt
                else if(starts-with($request-parameter, 'contributor-id-')) then
                    $tei//tei:fileDesc/tei:titleStmt
                else if($request-parameter eq 'publication-date') then
                    $tei//tei:fileDesc/tei:publicationStmt
                else if($request-parameter eq 'text-version') then
                    $tei//tei:fileDesc
                else if($request-parameter = ('sponsorship-project-id')) then
                    $sponsorship:data/m:sponsorship
                else
                    ()
            
            (: Get the existing value so we can compare :)
            let $existing-value := 
                if(starts-with($request-parameter, 'title-text-')) then
                    common:item-from-index($parent/tei:title, substring-after($request-parameter, 'title-text-'))
                else if(starts-with($request-parameter, 'location-')) then
                    $parent/tei:location
                else if($request-parameter eq 'translation-status') then
                    $parent/@status
                else if(starts-with($request-parameter, 'sponsor-id-')) then
                    common:item-from-index($parent/tei:sponsor, substring-after($request-parameter, 'sponsor-id-'))
                else if($request-parameter eq 'translator-team-id') then
                    $parent/tei:author[@role eq 'translatorMain'][1]
                else if(starts-with($request-parameter, 'contributor-id-')) then
                    let $contributors := ($parent/tei:author[not(@role eq 'translatorMain')] | $parent/tei:editor | $parent/tei:consultant)
                    return
                        common:item-from-index($contributors, substring-after($request-parameter, 'contributor-id-'))
                else if($request-parameter eq 'publication-date') then
                    $parent/tei:date
                else if($request-parameter eq 'text-version') then
                    $parent/tei:editionStmt
                else if($request-parameter = ('sponsorship-project-id')) then
                    $parent/m:project[@id eq request:get-parameter('sponsorship-project-id', '')]
                else
                    ()
            
            (: Specify a location to add it to if necessary :)
            let $insert-following :=
                if(starts-with($request-parameter, 'title-text-')) then
                    $parent//tei:title[last()]
                else if($request-parameter eq 'translator-team-id') then
                    $parent//tei:title[last()]
                else if(starts-with($request-parameter, 'contributor-id-')) then
                    let $contributor-index := substring-after($request-parameter, 'contributor-id-')
                    let $contributor-type := request:get-parameter(concat('contributor-type-', $contributor-index), '')
                    let $contributor-type-tokenized := tokenize($contributor-type, '-')
                    let $contributor-node-name := $contributor-type-tokenized[1]
                    let $contributors-of-type := 
                        if($contributor-node-name eq 'consultant') then
                            $parent/tei:consultant
                        else if($contributor-node-name eq 'editor') then
                            $parent/tei:editor
                        else
                            $parent/tei:author[not(@role eq 'translatorMain')]
                    return
                        $contributors-of-type[last()]
                        
                else if(starts-with($request-parameter, 'sponsor-id-')) then
                    $parent//tei:sponsor[last()]
                else if($request-parameter eq 'publication-date') then
                    $parent/tei:idno[last()]
                else if($request-parameter eq 'text-version') then
                    $parent/tei:titleStmt
                else
                    ()
            
            let $add-note := 
                if($request-parameter = $parameter-add-notes and not(compare($existing-value, $new-value) eq 0)) then
                    element { QName("http://www.tei-c.org/ns/1.0", "note") }{
                        attribute type { 'updated' },
                        attribute update { $request-parameter },
                        attribute value { normalize-space(request:get-parameter($request-parameter, '')) },
                        attribute date-time { current-dateTime() },
                        attribute user { common:user-name() },
                        text { string(normalize-space($new-value)) }
                    }
                else
                    ()
            
            where $existing-value or $new-value
            return
                (
                    common:update($request-parameter, $existing-value, $new-value, $parent, $insert-following),
                    if($add-note) then 
                        common:update('add-note', (), $add-note, $tei//tei:fileDesc/tei:notesStmt, ())
                    else
                        ()
                )
                (:element update-debug {
                    element request-parameter { $request-parameter }, 
                    element existing-value { $existing-value }, 
                    element new-value { $new-value }, 
                    element parent { $parent }, 
                    element insert-following { $insert-following }
                }:)
     }
};