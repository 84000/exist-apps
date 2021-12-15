declare namespace tei = "http://www.tei-c.org/ns/1.0";

element tenjyur-page-count {

    for $volume-number in 1 to 214
    
    let $volume-elements := collection('/db/apps/84000-data/tei/translations')//tei:location[@work eq "UT23703"]/tei:volume[@number eq xs:string($volume-number)]
    
    let $page-count-tei := sum( $volume-elements ! (xs:integer(@end-page) - (xs:integer(@start-page) - 1)))
    let $last-page-tei := max( $volume-elements/@end-page ! xs:integer(.) )
    let $eTengyur-volume := $volume-number + 1316
    let $eTengyur-pages := doc(concat('/db/apps/tibetan-source/data/UT23703/UT23703-', xs:string($eTengyur-volume), '-0000.xml'))//tei:p
    let $page-count-eTengyur := count($eTengyur-pages)
    
    return 
    element volume {
        attribute number { $volume-number },
        attribute count-pages-tei { $page-count-tei },
        attribute last-page-tei { $last-page-tei },
        attribute count-pages-eTengyur { $page-count-eTengyur },
        attribute count-pages-diff { $page-count-tei - $page-count-eTengyur },
        for $volume-element in $volume-elements
        order by xs:integer($volume-element/@start-page)
        return element {'text'} {
            $volume-element/ancestor::tei:bibl/@key,
            $volume-element/@start-page,
            $volume-element/@end-page
        }
    }
}
