xquery version "3.0";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace tmx="http://www.lisa.org/tmx14";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";

import module namespace common = "http://read.84000.co/common" at "../../../modules/common.xql";
import module namespace search = "http://read.84000.co/search" at "../../../modules/search.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

(:
    Edge cases:
:)

declare variable $has-request := if(request:exists()) then 'request' else ();
declare variable $local:api-version :=    ($has-request ! request:get-attribute('api-version')[. gt ''],                                              '0.4.0')[1];
declare variable $local:input-string :=   ($has-request ! request:get-parameter('search', '')[. gt ''],                                               'stong pa nyid')[1];
declare variable $local:input-lang :=     ($has-request ! request:get-parameter('lang', '')[. = ('en','bo')],                                         'bo')[1];
declare variable $local:result-page :=    ($has-request ! request:get-parameter('page', 1)[functx:is-a-number(.)] ! xs:integer(.) ! abs(.),            1)[1];
declare variable $local:items-per-page := ($has-request ! request:get-parameter('items-per-page', 10)[functx:is-a-number(.)] ! xs:integer(.) ! abs(.), 10)[1];

declare function local:search() as element()* {

    (: Transliterate :)
    let $search-string := 
        if(lower-case($local:input-lang) eq 'bo' and not(common:string-is-bo($local:input-string))) then
            common:bo-from-wylie($local:input-string)
        else
            $local:input-string

    (: Normalize :)
    let $search-string := 
        if(lower-case($local:input-lang) eq 'en') then
            lower-case($search-string) ! common:normalized-chars(.) ! replace(., '\-', ' ')
        else
            common:normalized-chars($search-string)
    
    let $tm-units := collection(concat($common:data-path, '/translation-memory'))//tmx:tu
    
    (: Select matching terms :)
    let $search-regex := 
        if($local:input-lang eq 'bo') then
            string-join(tokenize($search-string, '\s+(།\s*)?')[normalize-space(.)] ! normalize-space(.) ! replace(., '(^་|་$|&#8203;)', ''), ' OR ')
        else
            functx:escape-for-regex($search-string)
    
    let $lang-field := lower-case($local:input-lang)
    
    (: Only search units with segments for both languages :)
    let $matching-units := $tm-units[ft:query(tmx:tuv, concat($lang-field, ':(', $search-regex, ')'), map { "fields": ($lang-field) })][tmx:tuv[@xml:lang eq $local:input-lang]]
    
    (: Don't return all, but do return some :)
    let $matching-units := search:some-matches($matching-units, 1)
    
    (: Sort matches :)
    let $matching-units :=
        for $match in $matching-units
        let $score := ft:score($match)
        order by $score descending
        return 
            $match
    
    (: Select subset of enities :)
    let $start-item := (($local:result-page - 1) * $local:items-per-page) + 1
    let $end-item := $start-item + ($local:items-per-page - 1)
    let $count-items := count($matching-units)
    let $count-pages := ceiling($count-items div $local:items-per-page)
    let $matching-units := subsequence($matching-units, $start-item, $local:items-per-page)
    
    return 
        element results {
            
            element itemsCount { attribute json:literal { true() }, $count-items },
            element pagesCount { attribute json:literal { true() }, $count-pages },
            element searchString { $search-string },
            
            for $unit in $matching-units
            return 
                element item {
                
                    attribute json:array { true() },
                    
                    for $lang in ('En', 'Bo')
                    let $lang-attr := lower-case($lang)
                    return
                        element { concat('segment', $lang) } { 
                            string-join(
                                if($lang-field eq $lang-attr) then 
                                    ft:highlight-field-matches($unit//tmx:tuv[@xml:lang eq $lang-attr], $lang-field)/node() ! (if(self::exist:match) then element mark { node() } else descendant-or-self::text()) ! serialize(.) 
                                else
                                    $unit/tmx:tuv[@xml:lang eq $lang-attr]/tmx:seg/descendant::text()
                            ) ! normalize-space(.)
                        }
                    
                }
            
        }
};


element tm-search {

    attribute modelType { 'tm-search' },
    attribute apiVersion { $local:api-version },
    attribute search { $local:input-string },
    attribute lang { $local:input-lang },
    element page { attribute json:literal { true() }, $local:result-page },
    element itemsPerPage { attribute json:literal { true() }, $local:items-per-page },
    element url { concat('/tm/search.json?', string-join(('api-version=' || $local:api-version, 'search=' || $local:input-string, 'lang=' || $local:input-lang, 'page=' || $local:result-page, 'items-per-page=' || $local:items-per-page), '&amp;')) },
    
    local:search()
    
}
