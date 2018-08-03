xquery version "3.0";

module namespace tests="http://utilities.84000.co/tests";
import module namespace functx="http://www.functx.com";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace m="http://read.84000.co/ns/1.0";

declare function tests:test-section($section-tei as element()*, $section-html as element()*, $section-name as xs:string, $required-paragraphs as xs:integer, $count-chapters as xs:boolean)
{
    let $section-count-tei-p := count($section-tei//*[self::tei:p | self::tei:ab | self::tei:trailer | self::tei:bibl | self::tei:l[parent::tei:lg[not(ancestor::tei:note)]]])
    let $section-count-html-p := count($section-html//xhtml:p | $section-html//xhtml:div[contains(@class, 'line ')]) 
    (: This needs attention: we can't rely on a space after the class 'line' :)
    
    let $section-count-tei-note := count($section-tei//tei:note)
    let $section-count-html-note := count($section-html//xhtml:a[contains(@class, 'footnote-link')])
    
    let $section-count-tei-q := count($section-tei//tei:q)
    let $section-count-html-q := count($section-html//xhtml:blockquote | $section-html//xhtml:span[contains(@class, 'blockquote')])
    
    let $section-count-tei-id := count($section-tei//*[@tid][not(ancestor::tei:note)])
    let $section-count-html-id := count($section-html//*[contains(@id, 'node-')])
    
    let $section-count-tei-list-item := count($section-tei//tei:list[not(ancestor::tei:note)]/tei:item)
    let $section-count-html-list-item := count($section-html//xhtml:div[contains(@class, 'list-item')])
    
    let $section-count-tei-chapters := count($section-tei//tei:div[@type = ('section', 'chapter')])
    let $section-count-html-chapters := count($section-html//xhtml:section[contains(@class, 'chapter')])
    
    let $section-count-tei-milestones := count($section-tei//tei:milestone)
    let $section-count-html-milestones := count($section-html//xhtml:a[contains(@class, 'milestone from-tei')])
    
    let $required-paragraphs-rule := if ($required-paragraphs > 0) then concat(' at least ', $required-paragraphs , ' paragraph(s) and') else ''
    let $count-chapters-rule := if ($count-chapters eq true()) then ', chapters' else ''
    
    return
        <test xmlns="http://read.84000.co/ns/1.0" >
            <title>
            {
                concat(functx:capitalize-first($section-name) ,': The ', $section-name, ' has', $required-paragraphs-rule, ' the same number of paragraphs, notes, quotes, ids, labels, list items', $count-chapters-rule, ' and milestones  in the HTML as in the TEI.')
            }
            </title>
            <result>{ if(
                    $section-count-html-p ge $required-paragraphs
                    and $section-count-html-p eq $section-count-tei-p
                    and $section-count-html-note eq $section-count-tei-note
                    and $section-count-html-q eq $section-count-tei-q
                    and $section-count-html-id eq $section-count-tei-id
                    and $section-count-html-list-item eq $section-count-tei-list-item
                    and ($count-chapters eq false() or $section-count-tei-chapters eq 0 or $section-count-html-chapters eq $section-count-tei-chapters)
                    and $section-count-html-milestones eq $section-count-tei-milestones
                ) then 1 else 0 }</result>
            <details>
                <detail>{$section-count-tei-p} TEI paragraph(s), {$section-count-html-p} HTML paragraph(s).</detail>
                <detail>{$section-count-tei-note} TEI note(s), {$section-count-html-note} HTML note(s).</detail>
                <detail>{$section-count-tei-q} TEI quote(s), {$section-count-html-q} HTML quote(s).</detail>
                <detail>{$section-count-tei-id} TEI id(s), {$section-count-html-id} HTML id(s).</detail>
                <detail>{$section-count-tei-list-item} TEI list item(s), {$section-count-html-list-item} HTML list item(s).</detail>
                <detail>{$section-count-tei-milestones} TEI milestone(s), {$section-count-html-milestones} HTML milestone(s).</detail>
                {
                    if ($count-chapters eq true()) then
                        <detail>{$section-count-tei-chapters} TEI chapter(s), {$section-count-html-chapters} HTML chapter(s).</detail>
                    else
                        ()
                }
            </details>
        </test>
};
