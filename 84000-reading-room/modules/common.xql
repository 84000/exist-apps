xquery version "3.0";

module namespace common="http://read.84000.co/common";

declare namespace m="http://read.84000.co/ns/1.0";
declare namespace o = "http://www.tbrc.org/models/outline";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace sm = "http://exist-db.org/xquery/securitymanager";
declare namespace pkg="http://expath.org/ns/pkg";
declare namespace repo="http://exist-db.org/xquery/repo";
declare namespace xpath="http://www.w3.org/2005/xpath-functions";

import module namespace functx="http://www.functx.com";
import module namespace converter="http://tbrc.org/xquery/ewts2unicode" at "java:org.tbrc.xquery.extensions.EwtsToUniModule";

declare variable $common:app-id := common:app-id();
declare variable $common:root-path := concat('/db/apps/', $common:app-id);
declare variable $common:app-path := concat('/db/apps/', $common:app-id);
declare variable $common:log-path := '/db/system/logs';
declare variable $common:data-collection := '/84000-data';
declare variable $common:data-path := concat('/db/apps', $common:data-collection);
declare variable $common:tei-path := concat($common:data-path, '/tei');
declare variable $common:translations-path := concat($common:tei-path, '/translations');
declare variable $common:sections-path := concat($common:tei-path, '/sections');
declare variable $common:outlines-path := concat($common:data-path, '/outlines');
declare variable $common:ekangyur-path := '/db/apps/eKangyur/data/UT4CZ5369';
declare variable $common:environment-path := '/db/system/config/db/system/environment.xml';
declare variable $common:environment := doc($common:environment-path)/m:environment;

declare function common:app-id() as xs:string {

    (:
        Single point to set the app id
        -----------------------------------
        This is the name of the collection 
        containing the app (this file).
    :)
    
    let $servlet-path := system:get-module-load-path()
    let $tokens := tokenize($servlet-path, '/')
    return 
        $tokens[last() - 1]
    
};

declare function common:response($model-type as xs:string, $app-id as xs:string, $data) as node() {
    (:
        A response node
        -------------------------------------
        Includes standard attributes for xslts
        This should be the response root
    :)
    <response 
        xmlns="http://read.84000.co/ns/1.0" 
        model-type="{ $model-type }"
        timestamp="{ current-dateTime() }"
        app-id="{ $app-id }" 
        app-version="{ doc(concat($common:root-path, '/expath-pkg.xml'))/pkg:package/@version }"
        environment-path="{ $common:environment-path }"
        user-name="{ common:user-name() }" >
        {
            $data
        }
    </response>
};

declare function common:xml-lang($node) as xs:string {

    if($node/@encoding eq "extendedWylie") then
        "bo-ltn"
    else if($node/@lang eq "tibetan" and $node/@encoding eq "native") then
        "bo-ltn"
    else if($node[self::o:title and not(@lang)]) then
        "bo-ltn"
    else if ($node/@lang eq "sanskrit") then
        "sa-ltn"
    else if ($node/@lang eq "english") then
        "en"
    else
        $node/@lang/string()
};

declare function common:normalized-chars($string as xs:string) as xs:string{
    let $in  := 'āḍḥīḷḹṃṇñṅṛṝṣśṭūṁ'
    let $out := 'adhillmnnnrrsstum'
    return 
        translate(lower-case($string), $in, $out)
};

declare function common:alphanumeric($string as xs:string) as xs:string* {
    replace(normalize-space($string), '[^a-zA-Z0-9\s\-­]', '')
};

declare function common:word-count($strings as xs:string*) as xs:integer
{
  count(tokenize(string-join($strings, ' '), '\W+')[. != ''])
};

declare function common:bo-from-wylie($bo-ltn as xs:string*) as xs:string
{
    (: correct the spacing and spacing around underscores :)
    let $bo-ltn-underscores:= 
        if ($bo-ltn) then
            replace(replace(concat(normalize-space($bo-ltn), ' '), ' __,__', '__,__'), '__,__', ' __,__')
        else
            ""
    
    (: convert to Tibetan unicode :)
    return 
        if ($bo-ltn-underscores gt "") then
            converter:toUnicode($bo-ltn-underscores)
        else
            ""
};

declare function common:wylie-from-bo($bo as xs:string*) as xs:string
{
    if ($bo gt "") then
        converter:toWylie($bo)
    else
        ""
};

declare function common:bo-term($bo-ltn as xs:string*) as xs:string
{   
    
    (: correct the spacing and spacing around underscores :)
    let $bo-ltn-underscores:= 
        if ($bo-ltn) then
            replace(replace(normalize-space($bo-ltn), ' __,__', '__,__'), '__,__', ' __,__')
        else
            ""
    
    (: add a shad :)
    let $bo-ltn-length := string-length($bo-ltn-underscores)
    let $bo-ltn-shad :=
        if (
            (: check there isn't already a shad :)
            substring($bo-ltn-underscores, $bo-ltn-length, 1) ne "/"
            
        ) then
        
            (: these cases add a tshek and a shad :)
            if(substring($bo-ltn-underscores, ($bo-ltn-length - 2), 3) = ('ang','eng','ing','ong','ung')) then
                concat($bo-ltn-underscores, " /")
            
            (: these cases no shad :)
            else if((
                    substring($bo-ltn-underscores, ($bo-ltn-length - 1), 2) = ('ag', 'eg', 'ig', 'og', 'ug')
                )
                or (
                    substring($bo-ltn-underscores, ($bo-ltn-length - 2), 1) = ('_', ' ', 'g','d','b','m',"'")
                    and substring($bo-ltn-underscores, ($bo-ltn-length - 1), 2) = ('ga','ge','gi','go','gu','ka','ke','ki','ko','ku')
                )
            ) then
                $bo-ltn-underscores
            
            (: otherwise end in a shad :)
            else
                concat($bo-ltn-underscores, "/")
                
        else
            $bo-ltn-underscores
    
    (: convert to Tibetan unicode :)
    let $bo :=
        if ($bo-ltn-shad ne "") then
            converter:toUnicode($bo-ltn-shad)
        else
            ""
    
    return 
        xs:string($bo)
};

declare function common:bo-ltn($string as xs:string*) as xs:string
{
    if ($string) then
        replace(normalize-space($string), '__', ' ')
    else
        ""
};

declare function common:unescape($text as xs:string*) as node()* 
{
    let $html := util:parse-html($text)
    return
        if($html/HTML/xhtml:body) then
            $html/HTML/xhtml:body/node()
        else
            $html/HTML/BODY/node()
};

declare function common:search-result($nodes as node()*) as node()*
{
    for $node in $nodes
    return
        transform:transform(
            $node, 
            doc(concat($common:app-path, "/xslt/search-result.xsl")), 
            (), 
            (), 
            'method=xml indent=no'
        )
};

declare function common:marked-section($section as node()?, $strings as xs:string*) as item()?{
    
    let $marked-paragraphs :=
        if($section) then
            for $paragraph-text in $section/tei:p/data()
                let $marked-paragraph := common:marked-paragraph( $paragraph-text, $strings )
            return
                if($marked-paragraph[exist:match]) then
                    $marked-paragraph
                else
                    ()
        else
            ()

    return
        if($marked-paragraphs) then
            element tei:div {
                $section/@*,
                $marked-paragraphs
            }
        else
            $section
};

declare function common:marked-paragraph($text as xs:string, $find as xs:string*) as item() {
    
    let $find-escaped := $find ! functx:escape-for-regex(.)
    let $regex := concat('(', string-join($find-escaped, '|'),')')
    let $analyze-result := analyze-string(normalize-space($text), $regex, 'gi')
    
    return
        element tei:p {
            for $node in $analyze-result/xpath:*
            return
                if($node[self::xpath:match]) then
                    element exist:match {
                        data($node)
                    }
                else
                    data($node)
        }
        
};

declare function common:limit-str($str as xs:string*, $limit as xs:integer) as xs:string* 
{
    if(string-length($str) > $limit) then
        concat(substring($str, 1, $limit), '...')
    else
        $str
};

declare function common:epub-resource($file as xs:string) as xs:base64Binary
{
    util:binary-doc(xs:anyURI(concat($common:app-path, '/views/epub/resources/', $file)))
};

declare function common:test-conf() as node()* 
{
    $common:environment//m:test-conf
};

declare function common:snapshot-conf() as node()* 
{
    $common:environment//m:snapshot-conf
};

declare function common:deployment-conf() as node()* 
{
    $common:environment//m:deployment-conf
};

declare function common:user-name() as xs:string* {
    let $user := sm:id()
    return
        $user//sm:real/sm:username
};

declare function common:auth-environment() as xs:boolean {
    (: Check the environment to see if we need to login :)
    if($common:environment/@auth eq '1')then
        true()
    else
        false()
};

declare function common:app-text($key as xs:string) {

    let $result := doc(concat($common:data-path, '/config/app-text.xml'))//m:item[@key eq $key][1]/node()
    
    return
        if ($result instance of text()) then
            normalize-space($result)
        else
            $result
};

declare function common:app-texts($search as xs:string, $replacements as node()) {

    let $results := doc(concat($common:data-path, '/config/app-text.xml'))//m:item[contains(@key, concat($search, '.'))]
    
    for $result in $results
    return
        common:replace(
            <app-text xmlns="http://read.84000.co/ns/1.0" key="{$result/@key}">
            {
                if (count($result/node()) eq 1 and $result/node()[1] instance of text()) then
                    normalize-space($result/text())
                else
                    $result/node()
            }
            </app-text>,
            $replacements
        )
        
};

declare function common:replace($node as node(), $replacements as node()) {
    typeswitch ($node)
        case element() return 
            element { node-name($node) } {
                for $attribute in $node/@*
                    return attribute {name($attribute)} {functx:replace-multi(string($attribute), $replacements/m:value/@key, $replacements/m:value/text())},
                for $sub in $node/node()
                    return common:replace($sub, $replacements)
            }
        case text() return
            functx:replace-multi($node, $replacements/m:value/@key, $replacements/m:value/text())
        default return $node
};

declare function common:update($request-parameter as xs:string, $existing-value as item()?, $new-value as item()?, $insert-into as node()?, $insert-following as node()?) as element()? {

    if(functx:node-kind($existing-value) eq 'text' and compare($existing-value, $new-value) eq 0) then 
        () (: Data unchanged, do nothing :)
    
    else if(functx:node-kind($existing-value) eq 'attribute' and compare($existing-value, $new-value) eq 0) then
        () (: Data unchanged, do nothing :)
    
    else if(functx:node-kind($existing-value) eq 'element' and deep-equal($existing-value, $new-value)) then
        () (: Data unchanged, do nothing :)
    
    else if(not($existing-value) and not($new-value)) then
        () (: No data, do nothing :)
        
    else
        <updated xmlns="http://read.84000.co/ns/1.0" node="{ $request-parameter }">
        {
            if(not($existing-value) and $new-value) then        (: Insert :)
            
                if($insert-following) then                      (: Insert following :)
                    update insert $new-value following $insert-following
                    
                else                                            (: Insert wherever:)
                    update insert $new-value into $insert-into
            
            else if($existing-value and not($new-value)) then   (: Delete:)
                update delete $existing-value
            
            else                                                (: Update :)
                update replace $existing-value 
                    with $new-value

        }</updated>
};


declare function common:sort-trailing-number-in-string($seq as xs:string*, $separator) as xs:string* {

    for $string in $seq
        let $string-tokens := tokenize($string, $separator)
        let $number-str := $string-tokens[last()]
        let $number := 
            if(functx:is-a-number($number-str)) then 
                xs:integer($number-str) 
            else 
                0
                
        let $prefix := 
            if(functx:is-a-number($number-str)) then 
                string-join(subsequence($string-tokens, 1, count($string-tokens) - 1), $separator)
            else
                $string
    
    order by $prefix, $number
    return $string
 
};

declare function common:item-from-index($items as item()*, $index) as item()? {
    if($index and functx:is-a-number($index) and count($items) ge xs:integer($index)) then
        $items[xs:integer($index)]
    else
        ()
};
