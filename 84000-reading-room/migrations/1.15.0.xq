xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

(: Migrate @sameAs to @ref :)

declare variable $translations := collection('/db/apps/84000-data/tei/translations');

(# exist:batch-transaction #) {
    for $node in $translations//*[@sameAs]
        let $value := string($node/@sameAs)
    return 
        (
            update delete $node/@sameAs,
            update insert attribute ref { $value } into $node
        )
     (: $node :)
}