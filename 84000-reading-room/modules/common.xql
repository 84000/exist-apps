xquery version "3.1";

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
declare variable $common:app-config := concat($common:app-path, '/config');
declare variable $common:app-version := doc(concat($common:root-path, '/expath-pkg.xml'))/pkg:package/@version;
declare variable $common:log-path := '/db/system/logs';
declare variable $common:data-collection := '/84000-data';
declare variable $common:data-path := concat('/db/apps', $common:data-collection);
declare variable $common:tei-path := concat($common:data-path, '/tei');
declare variable $common:translations-path := concat($common:tei-path, '/translations');
declare variable $common:sections-path := concat($common:tei-path, '/sections');
declare variable $common:knowledgebase-path := concat($common:tei-path, '/knowledgebase');
declare variable $common:import-data-collection := '/84000-import-data';
declare variable $common:import-data-path := concat('/db/apps', $common:import-data-collection);
declare variable $common:environment-path := '/db/system/config/db/system/environment.xml';
declare variable $common:environment := doc($common:environment-path)/m:environment;

declare variable $common:diacritic-letters := 'āḍḥīḷḹṃṇñṅṛṝṣśṭūṁ';
declare variable $common:diacritic-letters-without := 'adhillmnnnrrsstum';
declare variable $common:chr-nl := '&#10;';
declare variable $common:chr-tab := '&#32;&#32;&#32;&#32;';
declare variable $common:node-ws := $common:chr-nl || $common:chr-tab;
declare variable $common:line-ws := $common:chr-nl || $common:chr-tab || $common:chr-tab;

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

declare function common:request-lang() as xs:string {
    if(request:exists()) then request:get-parameter('lang', 'en') else 'en'
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
    let $lang := common:request-lang() ! lower-case(.)
    let $local-texts :=
        if($lang = ('en', 'zh')) then
            doc(concat($common:app-config, '/', 'texts.', $lang, '.xml'))/m:texts/m:item
        else
            doc(concat($common:app-config, '/', 'texts.en.xml'))/m:texts/m:item
    return
        <response 
            xmlns="http://read.84000.co/ns/1.0" 
            model-type="{ $model-type }"
            timestamp="{ current-dateTime() }"
            app-id="{ $app-id }" 
            app-version="{ $common:app-version }"
            app-path="{ $common:app-path }" 
            app-config="{ $common:app-config }" 
            data-path="{ $common:data-path }" 
            user-name="{ common:user-name() }" 
            lang="{ $lang }"
            exist-version="{ system:get-version() }"
            tei-editor="{ if($common:environment/m:url[@id eq 'operations'] and common:user-in-group('operations')) then true() else false() }">
            {
                $data,
                element { name($common:environment) } {
                    $common:environment/@*,
                    $common:environment/m:label,
                    $common:environment/m:url,
                    $common:environment/m:google-analytics,
                    $common:environment/m:html-head,
                    $common:environment/m:render-translation,
                    if($app-id eq 'utilities') then (
                        $common:environment/m:store-conf,
                        $common:environment/m:git-config
                    )
                    else if($app-id eq 'operations') then (
                        $common:environment/m:conversion-conf
                    )
                    else ()
                },
                element lang-items {
                    $local-texts
                }
            }
        </response>
};

declare function common:html($xml as element(m:response), $view as xs:string){

    util:declare-option("exist:serialize", "method=html5 media-type=text/html"),
    response:set-header('Expires', xs:string(xs:dateTime(current-dateTime()))),
    response:set-header('X-UA-Compatible', 'IE=edge,chrome=1'),
    
    try {
        transform:transform($xml, doc($view), <parameters/>)
    }
    catch * {
        let $error :=
            <exception xmlns="">
                <path>{$err:value}</path>
                <message>{$err:description}</message>
            </exception>
        return
            transform:transform($error, doc(concat($common:app-path, "/views/html/error.xsl")), <parameters/>)
    }
    
};

declare
    %test:args('<data lang="tibetan" encoding="native"/>') 
    %test:assertEquals('bo-ltn')
    %test:args('<data lang="other"/>') 
    %test:assertEquals('other')
function common:xml-lang($node as element()) as xs:string {

    if($node/@encoding eq "extendedWylie") then
        "Bo-Ltn"
    else if($node/@lang eq "tibetan" and $node/@encoding eq "native") then
        "Bo-Ltn"
    else if($node[self::o:title and not(@lang)]) then
        "Bo-Ltn"
    else if ($node/@lang eq "sanskrit") then
        "Sa-Ltn"
    else if ($node/@lang eq "english") then
        "en"
    else
        $node/@lang/string()
};

declare function common:normalize-space($nodes as node()*) as node()*{
    for $node in $nodes
    return
        if ($node instance of text()) then
            text {
                translate(
                    normalize-space(
                        concat('', 
                            translate($node, '&#xA;', '')   (: Strip return characters :)
                         , '')                             (: Wrap in delete chars to preserve leading/trailing spaces :)
                    )                                       (: Normalize space to simplify multiple spaces :)
                , '', '')                                  (: Remove delete characters :)
            }
        else if ($node instance of element()) then
            element { node-name($node) }{
                $node/@*,
                common:normalize-space($node/node())
           }
        else
            ()
};

(: Create xml whitespace to prettify updates :)
declare function common:ws($indent as xs:integer) as xs:string {
    concat($common:chr-nl, functx:repeat-string($common:chr-tab, $indent))
};

(: Markup string :)
(: TO DO: replace with proper markup function :)
declare function common:markup($markdown as xs:string, $namespace as xs:string) as node()* {
    functx:change-element-ns-deep(<nodes>{ common:unescape($markdown) }</nodes>, $namespace, '')/node()
};

(: Markdown nodes :)
(: TO DO: replace with proper markdown function :)
declare function common:markdown($nodes as node()*, $namespace as xs:string) as xs:string {
    common:normalize-space( text { replace(serialize($nodes), concat('\s', functx:escape-for-regex(concat('xmlns="', $namespace, '"'))), '') } )
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

declare function common:format-number($number as numeric) as xs:string {

    let $input := tokenize(string(abs($number)),'\.')[1]
    let $dec := substring(tokenize(string($number),'\.')[2],1,2)
    let $rev := reverse(string-to-codepoints(string($input)))
    let $comma := string-to-codepoints(',')
    
    let $chars :=
        for $c at $i in $rev
        return (
            $c,
            if ($i mod 3 eq 0 and not($i eq count($rev))) then 
                $comma 
            else 
                ()
        )
    
    return 
        concat(
            if ($number lt 0) then '-' else (),
            codepoints-to-string(reverse($chars)),
            if ($dec != '') then concat('.',$dec) else ()
        )
};

declare function common:small-caps($string as xs:string) as xs:string {
    translate($string, 'abcdefghijklmnopqrstuvwxyz', 'ᴀʙᴄᴅᴇꜰɢʜɪᴊᴋʟᴍɴᴏᴘǫʀsᴛᴜᴠᴡxʏᴢ')
};

declare
    %test:args('0!123/4567ṃṁṇñṅ abcde?f*ghi-') 
    %test:assertEquals('01234567 abcdefghi-')
function common:alphanumeric($string as xs:string?) as xs:string? {
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
    try {
        parse-xml(concat('<doc>',$text,'</doc>'))/doc/node()
    }
    catch err:FODC0006 {
        text { $text }
    }  
};

declare function common:mark-nodes($nodes as node()*, $strings as xs:string*, $mode as xs:string) as node()* {
    
    for $node in $nodes
    return
        if ($node instance of text() and $node[normalize-space()]) then
            common:mark-text($node, $strings, $mode)
        else if ($node instance of element()) then
            element { node-name($node) }{
                $node/@*,
                common:mark-nodes($node/node(), $strings, $mode)
            }
        else
            $node
};

declare function common:mark-text($text as xs:string, $find as xs:string*, $mode as xs:string) as node()* {
    
    (: Standardise the input :)
    let $find := $find ! common:normalized-chars(.) ! lower-case(.) ! normalize-space(.)
    
    (: Tokenise the input (applying mode) :)
    let $find-tokenized :=
        if($mode = ('words')) then
             $find ! tokenize(., '\s+')
        else if($mode = ('tibetan')) then
             $find ! tokenize(., '\s+') ! replace(., '།', '')
        else
            $find
    
    (: A list of words with diacritics that are equivalent to a search term, so we can look for those too :)
    let $find-diacritics := 
        if($mode = ('words')) then
            for $word in tokenize($text, '[^\w­]') (: Not alphanumeric or soft-hyphen (There's a soft-hyphen in there too i.e.[^\w-] !!!) :)
                let $word-normalized := lower-case(common:normalized-chars($word))
                (: If it's an input word and it's changed :)
                where not(lower-case(normalize-unicode($word)) eq $word-normalized)
            group by $word-normalized
                for $find-match in $find-tokenized[starts-with(., substring($word-normalized, 1, string-length(.)))]
                (:group by $find-match:)
                return
                    substring($word[1], 1, (string-length($find-match) + string-length(replace($word[1], '\w', ''))))
        else
            ()
    
    (: Construct the regex :)
    let $regex := 
        if($mode = ('tibetan')) then
            concat('(', string-join($find-tokenized[not(. = ('།'))] ! functx:escape-for-regex(.), '|'),')')
        else
            concat('(?:^|\W*)(', string-join(($find-tokenized, $find-diacritics) ! functx:escape-for-regex(.), '|'),')(?:$|\W*)')
    
    (: shrink multiple spaces to single :)
    let $text := replace($text, '\s+', ' ')
    
    (: Look for matches :)
    let $analyze-result := analyze-string($text, $regex, 'i')
    
    (: Output result :)
    return (
        for $analyze-result-text in $analyze-result//text()
        return 
            if($analyze-result-text[parent::xpath:group]) then
                element exist:match {
                    $analyze-result-text
                }
            else
                $analyze-result-text
    )
        
};

declare function common:replace($node as node(), $replacements as element(m:replacement)*) {

    typeswitch ($node)
        case element() return 
            element { node-name($node) } {
                $node/@*,
                for $sub in $node/node()
                return 
                    common:replace($sub, $replacements)
            }
        case text() return
            common:replace-multi($node, $replacements, 1)
        default return $node
        
};

declare function common:replace-multi($string as xs:string, $replacements as element(m:replacement)* ,$position as xs:integer)  as xs:string? {

    if($position le count($replacements)) then 
        common:replace-multi(
            replace(
                $string, 
                functx:escape-for-regex($replacements[$position]/@key),
                $replacements[$position]/text()
            ),
            $replacements,
            $position + 1
        )
    else 
        $string
   
};

declare function common:normalize-unicode($string as xs:string?) as xs:string? {
    normalize-unicode(replace($string, '­', ''))
};

declare 
    %test:args('ṇñṅṛṝṣśṭūāḍḥīḷḹṃṁ') 
    %test:assertEquals('nnnrrsstuadhillmm')
function common:normalized-chars($string as xs:string?) as xs:string {
    if($string) then
        translate(
            replace(
                replace(
                    normalize-unicode($string)
                , '­'(: This is a soft-hyphen :), ''), 
            '&#39;', '&#8217;'),
            string-join(($common:diacritic-letters, upper-case($common:diacritic-letters)), ''), 
            string-join(($common:diacritic-letters-without, upper-case($common:diacritic-letters-without)), '')
        )
    else
        ''
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

declare function common:add-selected($element as element(), $selected-value as xs:string*) as element() {
    
    element { node-name($element) } {
        $element/@*,
        if($element[@value = $selected-value[. gt '']] or $element[@id = $selected-value[. gt '']]) then
            attribute selected { 'selected' }
        else (),
        $element/node()
    }
    
};

declare function common:add-selected-children($element as element(), $selected-value as xs:string*) as element() {
    element { node-name($element) } {
        $element/@*,
        for $element-child in $element/*
        return
            common:add-selected($element-child, $selected-value)
    }
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

declare function common:user-in-group($group as xs:string*) as xs:boolean {
    
    if(sm:id()//sm:real/sm:groups/sm:group[text() = $group]) then
        true()
    else
        false()
        
};

declare function common:auth-path($path as xs:string) as xs:boolean {
    (: Check the environment to see if we need to login :)
    if($common:environment/m:auth[@path eq $path]) then
        true()
    else
        false()
};

declare function common:valid-lang($lang as xs:string) as xs:string {
    if(lower-case($lang) = ('bo-ltn', 'bo-latn')) then
        'Bo-Ltn'
    else if(lower-case($lang) = ('sa-ltn', 'sa-latn')) then
        'Sa-Ltn'
    else if(lower-case($lang) eq 'bo') then
        'bo'
    else if(lower-case($lang) eq 'zh') then
        'zh'
    else if(lower-case($lang) eq 'en') then
        'en'
    else
        ''
};

declare function common:letter-variations($letter as xs:string) as xs:string* {
    (: this shouldn't be necessary if collation were working!?? :)
    let $letter := lower-case(common:normalized-chars($letter))
    return
        if($letter eq 'a') then ('a','ā')
        else if($letter eq 'd') then ('d','ḍ')
        else if($letter eq 'h') then ('h','h','ḥ')
        else if($letter eq 'i') then ('i','ī')
        else if($letter eq 'l') then ('l','ḷ','ḹ')
        else if($letter eq 'm') then ('m','ṃ','ṁ')
        else if($letter eq 'n') then ('n','ṇ','ñ','ṅ')
        else if($letter eq 'r') then ('r','ṛ','ṝ')
        else if($letter eq 's') then ('s','ṣ','ś')
        else if($letter eq 't') then ('t','ṭ')
        else if($letter eq 'u') then ('u','ū')
        else $letter
};

declare function common:local-text($key as xs:string, $lang as xs:string) {
    
    let $local-texts :=
        if(lower-case($lang) = ('en', 'zh')) then
            doc(concat($common:app-config, '/', 'texts.', lower-case($lang), '.xml'))//m:item
        else
            doc(concat($common:app-config, '/', 'texts.en.xml'))//m:item
    
    let $local-text := $local-texts[@key eq $key][1]/node()
    
    return
        if ($local-text instance of text()) then
            normalize-space($local-text)
        else
            common:normalize-space($local-text)
            
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
function common:contains-class($string as xs:string?, $class as xs:string*) as xs:boolean {
    (: for testing existence of a class in a class attribute :)
    matches(
        lower-case($string),
        concat('^(.*\s+)?(', string-join($class ! lower-case(.) ! functx:escape-for-regex(.), '|'), ')(\s+.*)?$')
    )
}; 

(: Generic update fumction :)
declare function common:update($request-parameter as xs:string, $existing-value as item()?, $new-value as item()?, $insert-into as element()?, $insert-following as node()?) as element()? {
    
    (:<debug>
        <request-parameter>{$request-parameter}</request-parameter>
        <existing-value>{$existing-value}</existing-value>
        <new-value>{$new-value}</new-value>
        <insert-into>{$insert-into}</insert-into>
        <insert-following>{$insert-following}</insert-following>
    </debug>:)

    if(functx:node-kind($existing-value) eq 'text' and compare($existing-value, $new-value) eq 0) then 
        () (: Data unchanged, do nothing :)
    
    else if(functx:node-kind($existing-value) eq 'attribute' and compare($existing-value, $new-value) eq 0) then
        () (: Data unchanged, do nothing :)
    
    else if(functx:node-kind($existing-value) eq 'element' and deep-equal($existing-value, $new-value)) then
        () (: Data unchanged, do nothing :)
    
    else if(not($existing-value) and not($new-value)) then
        () (: No data, do nothing :)
        
    else 
        
        (: Add whitespace so it's not too unreadable :)
        let $padding-ws :=
            if(not($new-value instance of xs:anyAtomicType) and functx:node-kind($new-value) eq 'element') then
                text { $common:node-ws }
            else ()
        
        (: Return <updated/> :)
        return
            element { QName('http://read.84000.co/ns/1.0', 'updated') } {
            
                (: Request parameter :)
                attribute node { $request-parameter },             
                
                (: Do the update :)
                if(not($existing-value) and $new-value) then            (: Insert :)
                
                    if($insert-following) then (                        (: Insert following :)
                        update insert ($padding-ws, $new-value) following $insert-following,
                        attribute update { 'insert' }
                    )
                    else if($insert-into) then (                        (: Insert wherever :)
                        update insert ($padding-ws, $new-value) into $insert-into,
                        attribute update { 'insert' }
                    )
                    else ()
                    
                else if($existing-value and not($new-value)) then (     (: Delete:)
                
                    update delete $existing-value,
                    attribute update { 'delete' }
                    
                )
                else (                                                  (: Replace :)
                
                    update replace $existing-value with $new-value,
                    attribute update { 'replace' }
                    
                )
            }
};

(: Sorts a sequence based on the trailing number e.g. ('n-3', 'n-1', 'n-2') -> ('n-1', 'n-2', 'n-3') :)
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

(: Returns an item at the given index :)
declare function common:item-from-index($items as item()*, $index) as item()? {
    if($index and functx:is-a-number($index) and count($items) ge xs:integer($index)) then
        $items[xs:integer($index)]
    else
        ()
};

(: Set a default for a request parameter in an request attribute with the same name, then call this to get it :)
declare function common:get-parameter($parameter-name as xs:string) {
    if(normalize-space(request:get-parameter($parameter-name, '')) gt '') then 
        normalize-space(request:get-parameter($parameter-name, '')) 
    else 
        request:get-attribute($parameter-name)
};
