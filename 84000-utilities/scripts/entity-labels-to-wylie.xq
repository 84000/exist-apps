declare namespace m = "http://read.84000.co/ns/1.0";

import module namespace converter="http://tbrc.org/xquery/ewts2unicode" at "java:org.tbrc.xquery.extensions.EwtsToUniModule";

declare variable $entities := doc('/db/apps/84000-data/operations/entities.xml');

(
count($entities//m:label[@xml:lang eq 'bo']),

(: Replace Tibetan labels with wylie labels :)
for $label-bo in subsequence($entities//m:label[@xml:lang eq 'bo'], 1, 500)(::)

let $label-wylie-existing := $label-bo/preceding-sibling::m:label[@xml:lang eq 'Bo-Ltn'][normalize-space(text())] | $label-bo/following-sibling::m:label[@xml:lang eq 'Bo-Ltn'][normalize-space(text())]
let $label-wylie := 
    if(not($label-wylie-existing)) then
        element { QName('http://read.84000.co/ns/1.0', 'label') }{
            attribute xml:lang { 'Bo-Ltn' },
            $label-bo/@*[not(local-name(.) eq 'lang')],
            text { converter:toWylie($label-bo/text()) ! replace(., '/$', '') }
        }
    else 
        $label-wylie-existing

return (
    (:$label-bo,:)
    $label-wylie,
    (: Delete the bo, we have wylie already :)
    if($label-wylie-existing) then
        update delete $label-bo
    (: Replace the bo with the wylie :)
    else
        update replace $label-bo with $label-wylie
)
)