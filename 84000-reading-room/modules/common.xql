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
declare namespace test="http://exist-db.org/xquery/xqsuite";

import module namespace functx="http://www.functx.com";
import module namespace converter="http://tbrc.org/xquery/ewts2unicode" at "java:org.tbrc.xquery.extensions.EwtsToUniModule";

declare variable $common:app-id := common:app-id();
declare variable $common:root-path := concat('/db/apps/', $common:app-id);
declare variable $common:app-path := concat('/db/apps/', $common:app-id);
declare variable $common:app-version := doc(concat($common:root-path, '/expath-pkg.xml'))/pkg:package/@version;
declare variable $common:log-path := '/db/system/logs';
declare variable $common:data-collection := '/84000-data';
declare variable $common:data-path := concat('/db/apps', $common:data-collection);
declare variable $common:tei-path := concat($common:data-path, '/tei');
declare variable $common:translations-path := concat($common:tei-path, '/translations');
declare variable $common:sections-path := concat($common:tei-path, '/sections');
(:declare variable $common:outlines-path := concat($common:data-path, '/outlines');:)
declare variable $common:import-data-collection := '/84000-import-data';
declare variable $common:import-data-path := concat('/db/apps', $common:import-data-collection);
declare variable $common:ekangyur-work := 'UT4CZ5369';
declare variable $common:ekangyur-path := concat('/db/apps/eKangyur/data/', $common:ekangyur-work);
declare variable $common:environment-path := '/db/system/config/db/system/environment.xml';
declare variable $common:environment := doc($common:environment-path)/m:environment;

declare
    %test:assertEquals("84000-reading-room")
function common:app-id() as xs:string {

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

declare
    %test:args('dummy', 'dummy', '<data xmlns="http://read.84000.co/ns/1.0" />') 
    %test:assertXPath("$result//m:data")
function common:response($model-type as xs:string, $app-id as xs:string, $data as item()*) as element() {
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
        app-version="{ $common:app-version }"
        data-path="{ $common:data-path }" 
        environment-path="{ $common:environment-path }"
        user-name="{ common:user-name() }" 
        lang="{ request:get-parameter('lang', 'en') }"
        exist-version="{ system:get-version() }">
        {
            $data
        }
    </response>
};

declare
    %test:args('<data lang="tibetan" encoding="native"/>') 
    %test:assertEquals('bo-ltn')
    %test:args('<data lang="other"/>') 
    %test:assertEquals('other')
function common:xml-lang($node as element()) as xs:string {

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

declare 
    %test:args('ṇñṅṛṝṣśṭūāḍḥīḷḹṃṁ') 
    %test:assertEquals('nnnrrsstuadhillmm')
function common:normalized-chars($string as xs:string) as xs:string {
    let $in  := 'āḍḥīḷḹṃṁṇñṅṛṝṣśṭū'
    let $out := 'adhillmmnnnrrsstu'
    return 
        (: translate(lower-case($string), $in, $out) :)
        translate(lower-case(normalize-unicode($string)), $in, $out)
};

declare function common:normalize-space($nodes as node()*) as node()*{
    for $node in $nodes
    return
        if ($node instance of text()) then
            text { translate(normalize-space(concat('', translate($node, '&#xA;', ''), '')), '', '') }
        else if ($node instance of element()) then
            element { node-name($node) }{
                $node/@*,
                common:normalize-space($node/node())
           }
        else
            ()
};

(: Strips ids from content to avoid duplicates where multiple documents are merged :)
declare function common:strip-ids($nodes as node()*) as node()*{
    for $node in $nodes
    return
        if ($node instance of text()) then
            text { $node }
        else if ($node instance of element()) then
            element { node-name($node) }{
                $node/@*[not(local-name() = ('id', 'tid'))],
                common:strip-ids($node/node())
           }
        else
            ()
};

declare function common:integer($node as xs:anyAtomicType?) as xs:integer {
    replace(concat('0',$node), '\D', '')
};

declare function common:small-caps($string as xs:string) as xs:string {
    translate($string, 'abcdefghijklmnopqrstuvwxyz', 'ᴀʙᴄᴅᴇꜰɢʜɪᴊᴋʟᴍɴᴏᴘǫʀsᴛᴜᴠᴡxʏᴢ')
};

declare
    %test:args('0!123/4567ṃṁṇñṅ abcde?f*ghi-') 
    %test:assertEquals('01234567 abcdefghi-')
function common:alphanumeric($string as xs:string) as xs:string* {
    replace(normalize-space($string), '[^a-zA-Z0-9\s\-­]', '')
};

declare
    %test:args('one two three, four   five!') 
    %test:assertEquals(5)
function common:word-count($strings as xs:string*) as xs:integer {
  count(tokenize(string-join($strings, ' '), '\W+')[. != ''])
};

declare
    %test:args("ar mo nig lta bu'i rdo leb/") 
    %test:assertEquals('ཨར་མོ་ནིག་ལྟ་བུའི་རྡོ་ལེབ། ')
function common:bo-from-wylie($bo-ltn as xs:string) as xs:string {
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

declare
    %test:args('ཨར་མོ་ནིག་ལྟ་བུའི་རྡོ་ལེབ།') 
    %test:assertEquals("ar mo nig lta bu'i rdo leb/")
function common:wylie-from-bo($bo as xs:string) as xs:string {
    if ($bo gt "") then
        converter:toWylie($bo)
    else
        ""
};

declare
    %test:args("chos kyi phyag rgya bzhi__,__bka' rtags kyi phyag rgya bzhi")
    %test:assertEquals("ཆོས་ཀྱི་ཕྱག་རྒྱ་བཞི་  ,  བཀའ་རྟགས་ཀྱི་ཕྱག་རྒྱ་བཞི།")
    %test:args('gso sbyong') 
    %test:assertEquals("གསོ་སྦྱོང་།")
    %test:args('gsang tshig') 
    %test:assertEquals("གསང་ཚིག")
    %test:args('gsang ste ston pa') 
    %test:assertEquals("གསང་སྟེ་སྟོན་པ།")
function common:bo-term($bo-ltn as xs:string) as xs:string {   
    
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

declare
    %test:args('  a__b  ')
    %test:assertEquals('a b') 
function common:bo-ltn($string as xs:string) as xs:string {
    if ($string) then
        replace(normalize-space($string), '__', ' ')
    else
        ""
};

declare function common:unescape($text as xs:string*) as node()* {
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

declare function common:mark-nodes($nodes as node()*, $strings as xs:string*) as node()* {
    
    for $node in $nodes
    return
        if ($node instance of text()) then
            common:mark-text( $node, $strings )
        else if ($node instance of element()) then
            element { node-name($node) }{
                $node/@*,
                common:mark-nodes($node/node(), $strings)
           }
        else
            $node
};

declare function common:mark-text($text as xs:string, $find as xs:string*) as node()* {
    
    let $find-escaped := $find ! lower-case(.) ! normalize-space(.) ! functx:escape-for-regex(.)
    let $regex := concat('(', string-join($find-escaped, '|'),')')
    let $analyze-result := analyze-string($text, $regex, 'i')
    
    return
        for $node in $analyze-result/xpath:*
        return
            if($node[self::xpath:match]) then
                element exist:match {
                    text { data($node) }
                }
            else
                text { data($node) }
        
};

declare
    %test:args('0123456789', 5)
    %test:assertEquals('01234...') 
    %test:args('01234', 5)
    %test:assertEquals('01234') 
function common:limit-str($str as xs:string, $limit as xs:integer) as xs:string {
    if(string-length($str) > $limit) then
        concat(substring($str, 1, $limit), '...')
    else
        $str
};

declare function common:add-selected($element as element(), $selected-value as xs:string?) as element() {
    if(not($selected-value) and $element/@value eq '' or $element/@value eq $selected-value) then
        element { node-name($element) } {
            $element/@*,
            attribute selected { 'selected' },
            $element/node()
        }
    else
        $element
};

declare function common:epub-resource($file as xs:string) as xs:base64Binary {
    util:binary-doc(xs:anyURI(concat($common:app-path, '/views/epub/resources/', $file)))
};

declare
    %test:assertEquals('admin') 
function common:user-name() as xs:string* {
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

declare function common:valid-lang($lang) as xs:string {
    if(lower-case($lang) eq 'bo-ltn') then
        'Bo-Ltn'
    else if(lower-case($lang) eq 'sa-ltn') then
        'Sa-Ltn'
    else if(lower-case($lang) eq 'bo') then
        'bo'
    else if(lower-case($lang) eq 'en') then
        'en'
    else
        ''
};

declare function common:local-text($key as xs:string, $lang as xs:string) {
    
    let $local-texts :=
        if($lang = ('en', 'zh')) then
            doc(concat($common:data-path, '/config/texts.', $lang, '.xml'))//m:item
        else
            doc(concat($common:data-path, '/config/texts.en.xml'))//m:item
    
    let $local-text := $local-texts[@key eq $key][1]/node()
    
    return
        if ($local-text instance of text()) then
            normalize-space($local-text)
        else
            common:normalize-space($local-text)
            
};

declare function common:replace($node as node(), $replacements as element()) {
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

declare 
    %test:args('line', 'line')
    %test:assertTrue 
    %test:args('line other-class', 'line')
    %test:assertTrue
    %test:args('other-class line', 'line')
    %test:assertTrue
    %test:args('other-class line other-line', 'line other-line')
    %test:assertTrue
    %test:args('other-class line', 'other-line')
    %test:assertFalse
    %test:args('other-class line other', 'line other-line')
    %test:assertFalse
function common:contains-class($string as xs:string?, $class as xs:string ) as xs:boolean {
    (: for testing existence of a class in a class attribute :)
    matches(
        lower-case($string),
        concat('^(.*\s)?', lower-case(functx:escape-for-regex($class)), '(\s.*)?$')
    )
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
        element { QName('http://read.84000.co/ns/1.0', 'updated') }
        {
            attribute node { $request-parameter },
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

        }
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
