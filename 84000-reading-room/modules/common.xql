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
import module namespace ewts = "http://tbrc.org/xquery/ewts2unicode"; (:at "java:org.tbrc.xquery.extensions.EwtsToUniModule":)

declare variable $common:app-id := common:app-id();
declare variable $common:root-path := concat('/db/apps/', $common:app-id);
declare variable $common:app-path := concat('/db/apps/', $common:app-id);
declare variable $common:app-config := concat($common:app-path, '/config');
declare variable $common:app-version := doc(concat($common:root-path, '/expath-pkg.xml'))/pkg:package/@version;
declare variable $common:log-path := '/db/system/logs';
declare variable $common:cache-path := '/db/apps/84000-cache';
declare variable $common:data-collection := '/84000-data';
declare variable $common:data-path := concat('/db/apps', $common:data-collection);
declare variable $common:tei-path := concat($common:data-path, '/tei');
declare variable $common:translations-path := concat($common:tei-path, '/translations');
declare variable $common:sections-path := concat($common:tei-path, '/sections');
declare variable $common:knowledgebase-path := concat($common:tei-path, '/knowledgebase');
declare variable $common:archive-path := concat($common:data-path, '/archived');
declare variable $common:import-data-collection := '/84000-import-data';
declare variable $common:import-data-path := concat('/db/apps', $common:import-data-collection);
declare variable $common:environment-path := '/db/system/config/db/system/environment.xml';
declare variable $common:environment := doc($common:environment-path)/m:environment;

declare variable $common:diacritic-letters := 'āḍéḥīḷḹṃṇñṅņṛṝṣśṭūṁ';
declare variable $common:diacritic-letters-without := 'adehillmnnnnrrsstum';
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

declare 
    %test:assertEquals("en")
function common:request-lang() as xs:string {
    if(request:exists()) then
        (request:get-parameter('lang', 'en')[. = ('en', 'zh')], 'en')[1]
    else
        'en'
};

declare
    %test:args('dummy', 'dummy', "()") 
    %test:assertXPath("$result[@model eq 'dummy'][@app-id eq 'dummy']/*:environment")
    %test:args('dummy', 'dummy', "()") 
    %test:assertXPath("$result/*:lang-items")
function common:response($model as xs:string, $app-id as xs:string, $data as item()*) as element() {
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
        element { QName('http://read.84000.co/ns/1.0','response') } {
        
            attribute model { $model },
            attribute timestamp { current-dateTime() },
            attribute app-id { $app-id },
            attribute app-version { $common:app-version },
            attribute app-path { $common:app-path },
            attribute app-config { $common:app-config },
            attribute data-path { $common:data-path },
            attribute user-name { common:user-name() },
            attribute lang { $lang },
            attribute exist-version { system:get-version() },
            attribute tei-editor { common:tei-editor() },
            
            $data,
            
            element { name($common:environment) } {
                $common:environment/@*,
                $common:environment/m:label,
                $common:environment/m:url,
                $common:environment/m:google-analytics,
                $common:environment/m:html-head,
                $common:environment/m:render,
                $common:environment/m:enable,
                if($app-id eq 'utilities') then (
                    $common:environment/m:store-conf,
                    $common:environment/m:git-config
                )
                else if($app-id eq 'operations') then (
                    $common:environment/m:store-conf,
                    $common:environment/m:conversion-conf
                )
                else ()
            },
            
            element lang-items {
                $local-texts
            }
            
        }
};

(: Return serialized as html :)
declare function common:serialize-html($html){
    
    (: Serialization :)
    util:declare-option("exist:serialize", "method=html5 media-type=text/html"),
    
    (: Headers :)
    if(response:exists()) then response:set-header('Expires', xs:string(xs:dateTime(current-dateTime()))) else(),
    if(response:exists()) then response:set-header('X-UA-Compatible', 'IE=edge,chrome=1') else(),
    
    (: Content :)
    $html

};

(: Return serialized as xml :)
declare function common:serialize-xml($xml){
    
    (: Headers :)
    util:declare-option("exist:serialize", "method=xml indent=no"),
    
    (: Content :)
    $xml

};

(: Return serialized as txt :)
declare function common:serialize-txt($txt){
    
    (: Headers :)
    util:declare-option("exist:serialize", "media-type=text/plain"),
    
    (: Content :)
    $txt

};

(: Transform xml to html, checking cache :)
declare function common:html($xml as element(m:response), $view as xs:string, $cache-key as xs:string?) {

    try {
        
        let $xslt := doc($view)
        let $html := transform:transform($xml, $xslt, <parameters/>)
        let $request-xml := $xml/descendant::m:request[1]
        let $cache := 
            if($request-xml and $cache-key gt '') then
                common:cache-put($request-xml, $html, $cache-key)
            else ()
        
        return 
            common:serialize-html($html)
        
    }
    
    catch * {
        let $error :=
            <exception xmlns="">
                <path>{$err:value}</path>
                <message>{$err:description}</message>
            </exception>
        return 
            common:serialize-html(
                transform:transform($error, doc(concat($common:app-path, "/views/html/error.xsl")), <parameters/>)
            )
    }
};

(: Transform xml to html, ignore cache :)
declare function common:html($xml as element(m:response), $view as xs:string) {
    common:html($xml, $view, ())
};

declare
    %test:args('<data lang="tibetan" encoding="native"/>') 
    %test:assertEquals('Bo-Ltn')
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
declare 
    %test:args(3)
    %test:assertEquals('&#10;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;&#32;')
function common:ws($indent as xs:integer) as text() {
    text { concat($common:chr-nl, functx:repeat-string($common:chr-tab, $indent)) }
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
                $node/@*[not(local-name(.) = ('id', 'tid'))],
                common:strip-ids($node/node())
           }
        else ()
};

declare 
    %test:args('   033!')
    %test:assertEquals(33) 
function common:integer($node as xs:anyAtomicType?) as xs:integer {
    replace(concat('0',$node), '\D', '')
};

declare
    %test:args(35800)
    %test:assertEquals('35,800') 
function common:format-number($number as numeric) as xs:string {

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
            else ()
        )
    
    return 
        concat(
            if ($number lt 0) then '-' else (),
            codepoints-to-string(reverse($chars)),
            if ($dec != '') then concat('.',$dec) else ()
        )
};

declare
    %test:args('dom')
    %test:assertEquals('ᴅᴏᴍ') 
function common:small-caps($string as xs:string) as xs:string {
    translate($string, 'abcdefghijklmnopqrstuvwxyz', 'ᴀʙᴄᴅᴇꜰɢʜɪᴊᴋʟᴍɴᴏᴘǫʀsᴛᴜᴠᴡxʏᴢ')
};

declare
    %test:args('Dom')
    %test:assertEquals('dom') 
function common:lower-case-first($string as xs:string) as xs:string {
    concat(lower-case(substring($string,1,1)),substring($string,2))
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
            ewts:toUnicode($bo-ltn-underscores)
        else
            ""
};

declare
    %test:args('ཨར་མོ་ནིག་ལྟ་བུའི་རྡོ་ལེབ།') 
    %test:assertEquals("ar mo nig lta bu'i rdo leb/")
function common:wylie-from-bo($bo as xs:string) as xs:string {
    if ($bo gt "") then
        ewts:toWylie($bo)
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
        if ($bo-ltn gt '') then
            replace(replace(normalize-space($bo-ltn), ' __,__', '__,__'), '__,__', ' __,__')
        else
            ''
    
    (: add a shad :)
    let $bo-ltn-length := string-length($bo-ltn-underscores)
    let $bo-ltn-shad :=
        (: check there isn't already a shad :)
        if($bo-ltn-length gt 0 and not(matches($bo-ltn-underscores, '/$'))) then
        
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
        if ($bo-ltn-shad gt '') then
            ewts:toUnicode($bo-ltn-shad)
        else
            ''
    
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

declare 
    %test:args('ངག་བཀྱལ་བ།')
    %test:assertTrue
    %test:args('Some English')
    %test:assertFalse
function common:string-is-bo ($string as xs:string) as xs:boolean {
    functx:between-inclusive(min(string-to-codepoints(replace($string, '\W', ''))), 3840, 4095)
};

declare function common:normalize-bo($string as xs:string) as xs:string {
(:
    - Normalize whitespace
    - Add a zero-length break after a beginning shad
    - Add a she to the end
:)
    replace(
        replace(
            replace($string, '\s+', ' ')
            , '(།)(\S)', '$1​$2')
   , '་\s+$', '་')
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
    let $find := $find ! lower-case(.) ! normalize-unicode(.) ! common:normalized-chars(.) ! normalize-space(.)
    
    (: Tokenise the input (applying mode) :)
    let $find-tokenized :=
        if($mode = ('words')) then
             $find ! tokenize(., '[^\p{L}]+')
             
        else if($mode = ('tibetan')) then
             $find ! tokenize(., '\s+') ! replace(., '(་|།)$', '')
             
        else
            $find
    
    (: A list of words with diacritics that are equivalent to a search term, so we can look for those too :)
    let $find-diacritics := 
        if($mode = ('words')) then
            for $word in tokenize($text, '[^\p{L}]+')
            let $word-standardised := $word ! lower-case(.) ! normalize-unicode(.)
            let $word-normalized := $word-standardised ! common:normalized-chars(.) 
            
            (: Return if it's changed by removing diacritics, and if it's in the search :)
            where 
                not($word-standardised eq $word-normalized)
                and matches($find, $word-normalized, 'i')
            group by $word-normalized
            return
                $word[1]
        else ()
    
    (: Construct the regex :)
    let $regex := 
        if($mode = ('tibetan')) then
            concat('(', string-join($find-tokenized[not(. = ('།'))] ! functx:escape-for-regex(.), '|'),')')
        else
            let $find-escaped := ($find-tokenized, $find-diacritics)[. gt ' '] ! functx:escape-for-regex(.) ! replace(., '\s+', '\\s+')
            return
                concat('\b(', string-join($find-escaped, '|'),')\b')
    
    (: double spaces to support the regex :)
    let $text := replace($text, '\s+', '  ') (:! common:normalized-chars(.):)
    
    (: Look for matches :)
    let $analyze-result := analyze-string($text, $regex, 'i;j')
    
    (: Output result :)
    return (
    
        (:element debug {
            element find { $find },
            element regex {$regex},
            element search-text {$text},
            $analyze-result
        },:)
        
        for $analyze-result-text in $analyze-result//text()
        return 
            if($analyze-result-text[parent::xpath:group]) then
                element exist:match {
                    text { $analyze-result-text ! replace(., '\s+', ' ') }
                }
            else
                text { $analyze-result-text ! replace(., '\s+', ' ') }
                
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
    normalize-unicode(replace($string, '­'(: This is a soft-hyphen :), ''))
};

declare 
    %test:args('ṇñṅṛṝṣśṭūāḍḥīḷḹṃṁ') 
    %test:assertEquals('nnnrrsstuadhillmm')
function common:normalized-chars($string as xs:string?) as xs:string {
    if($string) then
        normalize-unicode($string)
        ! replace(., '­'(: This is a soft-hyphen :), '')
        ! replace(., '&#39;', '&#8217;') (: Use correct apostrophe :)
        ! translate(
                ., 
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

declare
    %test:assertTrue
function common:tei-editor() as xs:boolean {
    if($common:environment/m:url[@id eq 'operations'] and common:user-in-group('operations')) then true() else false()
};

declare
    %test:args('utilities')
    %test:assertTrue
function common:user-in-group($group as xs:string*) as xs:boolean {
    
    let $smid := sm:id()
    return
        if($smid//sm:real/sm:groups/sm:group[text() = $group]) then
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

declare
    %test:args('')
    %test:assertEquals('') 
    %test:args('EN')
    %test:assertEquals('en') 
    %test:args('bo-latn')
    %test:assertEquals('Bo-Ltn') 
    %test:args('unknown')
    %test:assertEquals('') 
function common:valid-lang($lang as xs:string) as xs:string {
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
        else if($letter eq 'e') then ('e','é')
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

(: Generic update function :)
declare function common:update($request-parameter as xs:string, $existing-value as item()?, $new-value as item()?, $insert-into as element()?, $insert-following as node()?) as element()? {
    common:update($request-parameter, $existing-value, $new-value, $insert-into, $insert-following, true())
};

declare function common:update($request-parameter as xs:string, $existing-value as item()?, $new-value as item()?, $insert-into as element()?, $insert-following as node()?, $compare as xs:boolean) as element()? {
    
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
    
    else if(not($existing-value) and not($new-value)) then
        () (: No data, do nothing :)
        
    else if(functx:node-kind($existing-value) eq 'element' and $compare and deep-equal($existing-value, $new-value)) then
        () (: Data unchanged, do nothing :)
    
    else 
        
        element { QName('http://read.84000.co/ns/1.0', 'updated') } {
        
            (: Request parameter :)
            attribute node { $request-parameter },             
            
            (: Do the update :)
            if(not($existing-value) and $new-value) then
            
                (: Insert following :)
                if($insert-following) then (
                
                    (: Add whitespace so it's not too unreadable :)
                    (: Only apply to single elements :)
                    let $padding-before :=
                        if($new-value instance of element()) then 
                            text { $insert-following/preceding-sibling::text()[1] }
                        else ()
                    return
                    update insert ($padding-before, $new-value) following $insert-following,
                    
                    attribute update { 'insert' }
                    
                )
                
                (: Insert at end :)
                else if($insert-into) then (    
                    
                    (: Add whitespace so it's not too unreadable :)
                    (: Only apply to single elements :)
                    let $padding-before :=
                        if($new-value instance of element()) then 
                            text { $common:chr-tab }
                        else ()
                    let $padding-after :=
                        if($new-value instance of element()) then 
                            text { $insert-into/*[last()]/following-sibling::text()[1] }
                        else ()
                    return
                    update insert ($padding-before, $new-value, $padding-after) into $insert-into,
                    
                    attribute update { 'insert' }
                    
                )
                
                (: No target element :)
                else ()
            
            (: Delete:)
            else if($existing-value and not($new-value)) then (                
                update delete $existing-value,
                attribute update { 'delete' }
            )
            
            (: Replace :)
            else (
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
declare
    %test:args('no-request')
    %test:assertEmpty
function common:get-parameter($parameter-name as xs:string) {
    if(request:exists()) then
        if(normalize-space(request:get-parameter($parameter-name, '')) gt '') then 
            normalize-space(request:get-parameter($parameter-name, '')) 
        else 
            request:get-attribute($parameter-name)
    else ()
};

declare function common:cache-collection($request as element(m:request)) as xs:string? {

    let $cache-conf := $common:environment/m:cache-conf/m:cache[@model eq $request/@model][@view eq $request/@resource-suffix]
    let $request-collection := 
        string-join((
            (: model/resource-id as folders :)
            $request/@*[local-name(.) = ('model', 'resource-id')]/string() ! replace(., '[^A-Za-z0-9\-_]', '-'),
            (: remainder attributes as one folder :)
            string-join($request/@*[not(local-name(.) = ('model', 'resource-id'))]/string() ! replace(., '[^A-Za-z0-9\-_]', '-'), '_')
        ), '/') ! lower-case(.)
    where $cache-conf
    return
        string-join(($cache-conf/@collection, $request-collection), '/')
        
};

(:declare function common:cache-filename($request as element(m:request), $timestamp as xs:dateTime?) as xs:string {
    
    let $suffix := if($request/@resource-suffix eq 'txt') then '.txt' else '.xml'
    return
        string-join((
            format-dateTime($timestamp, "[Y0001]-[M01]-[D01]-[H01]-[m01]-[s01]"), 
            replace($common:app-version, '\.', '-')
        ), '_') || $suffix ! lower-case(.)
};:)

declare
    %test:args("<request xmlns='http://read.84000.co/ns/1.0'/>", 'test key')
    %test:assertEquals('test-key.xml')
function common:cache-filename($request as element(m:request), $cache-key as xs:string?) as xs:string? {
    
    let $cache-key-normalized := replace(replace(normalize-space(lower-case($cache-key)), '\s+', '-'), '[^a-z0-9\-­]', '')
    let $file-extension := 
        if($request/@resource-suffix eq 'txt') then '.txt' 
        else if($request/@resource-suffix eq 'xlsx') then '.xlsx' 
        else if($request/@resource-suffix eq 'dict') then '.dict' 
        else '.xml'
    where $cache-key-normalized
    return
        concat($cache-key-normalized, $file-extension)
    
};

declare function common:cache-key-latest($request as element(m:request)) as xs:string? {

    let $cache-collection := common:cache-collection($request)
    where $cache-collection and xmldb:collection-available($cache-collection)
    let $resources := xmldb:get-child-resources($cache-collection)
    let $resources-sorted :=
        for $resource in $resources
        order by xmldb:last-modified($cache-collection, $resource)
        return
            $resource
    let $file-extension-regex := concat('\.', $request/@resource-suffix, '$')
    return 
        $resources-sorted[last()] ! replace(., $file-extension-regex, '')
        
};

declare function common:cache-last-modified($request as element(m:request), $cache-key as xs:string?) as xs:dateTime? {

    let $cache-collection := common:cache-collection($request)
    let $cache-filename := common:cache-filename($request, $cache-key)
    return 
        xmldb:last-modified($cache-collection, $cache-filename)
        
};

declare function common:cache-get($request as element(m:request), $cache-key as xs:string?) {
    common:cache-get($request, $cache-key, true())
};

declare function common:cache-get($request as element(m:request), $cache-key as xs:string?, $headers as xs:boolean?) {

    let $cache-collection := common:cache-collection($request)
    let $cache-filename := common:cache-filename($request, $cache-key)
    
    where $cache-collection and $cache-filename gt ''
    return
        
        let $cached := 
            if($request/@resource-suffix = ('html', 'xml')) then
                doc(xs:anyURI(concat($cache-collection, '/', $cache-filename)))
            else
                util:binary-doc(concat($cache-collection, '/', $cache-filename))
        
        (: where $cached - can't test binary result :)
        return (
        
            if(response:exists() and $headers) then response:set-header('X-EFT-Cache', 'from-cache') else (),
            
            if($request/@resource-suffix eq 'html') then
                common:serialize-html($cached)
            
            else if($request/@resource-suffix eq 'xml') then 
                common:serialize-xml($cached)
            
            else 
                $cached
            
       )
};

declare function common:cache-put($request as element(m:request), $data, $cache-key as xs:string?) {
    
    let $cache-collection-parent := $common:environment/m:cache-conf/m:cache[@model eq $request/@model][@view eq $request/@resource-suffix]
    let $cache-collection := common:cache-collection($request)
    let $cache-filename := common:cache-filename($request, $cache-key)
    
    where $cache-collection-parent and $cache-collection and $cache-filename gt ''
    return
        
        (: Clear existing cache :)
        let $clear-cache := 
            if(xmldb:collection-available($cache-collection)) then 
                xmldb:remove($cache-collection)
            else ()
    
        return (
            
            (: Create the collection :)
            if(not(xmldb:collection-available($cache-collection))) then (
            
                let $cache-collection-no-parent := substring-after($cache-collection, concat($cache-collection-parent, '/'))
                let $cache-collection-dirs := tokenize($cache-collection-no-parent, '/')
                
                (: Loop through structure making sure collections are present with permissions set :)
                for $nesting in 1 to count($cache-collection-dirs)
                let $dir := $cache-collection-dirs[$nesting]
                let $parent := string-join(($cache-collection-parent, subsequence($cache-collection-dirs, 1, ($nesting - 1))), '/')
                where not(xmldb:collection-available(string-join(($parent, $dir), '/')))
                return (
                    (:string-join(($parent, $dir), '/'),:)
                    xmldb:create-collection($parent, $dir),
                    sm:chgrp(xs:anyURI(string-join(($parent, $dir), '/')), 'guest'),
                    sm:chmod(xs:anyURI(string-join(($parent, $dir), '/')), 'rwxrwxrwx'),
                    util:log('info', concat('Cache created: ', $cache-collection, '/', $cache-filename))
                )
                
            )
            else(),
            
            (: Store the file :)
            if($request/@resource-suffix eq 'html') then
                xmldb:store($cache-collection, $cache-filename, $data, 'text/html')
                
            else if($request/@resource-suffix eq 'txt') then
                xmldb:store($cache-collection, $cache-filename, $data, 'text/plain')
            
            else if($request/@resource-suffix eq 'xlsx') then
                xmldb:store($cache-collection, $cache-filename, $data, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
            
            else if($request/@resource-suffix = ('dict', 'zip')) then
                xmldb:store($cache-collection, $cache-filename, $data, 'application/zip')
                
            else
                xmldb:store($cache-collection, $cache-filename, $data, 'application/xml')
            ,
            
            (: Set permissions :)
            if(not(common:user-name() eq 'guest')) then (
                sm:chgrp(xs:anyURI(string-join(($cache-collection, $cache-filename), '/')), 'guest'),
                sm:chmod(xs:anyURI(string-join(($cache-collection, $cache-filename), '/')), 'rwxrwxrwx')
            )
            else ()
    )
    
};

declare function common:spreadsheet-zip($spreadsheet-data as element(m:spreadsheet-data)) {

    let $spreadsheet-excel := 
       transform:transform(
           $spreadsheet-data,
           doc(concat($common:app-path, "/views/spreadsheet/excel.xsl")), 
           <parameters/>
       )
    
    let $entries := 
        for $entry in $spreadsheet-excel
        
        let $params :=
            element { QName('http://www.w3.org/2010/xslt-xquery-serialization','serialization-parameters') }{
                element omit-xml-declaration { 
                    attribute value { ($entry/@omit-xml-declaration, 'no')[1] }
                }
            }
        
        return
            <entry name="{ $entry/@href }" type="{ if($entry/@media-type eq 'text/plain') then 'text' else 'xml' }">{fn:serialize(document{$entry/node()}, $params)}</entry>
    
    return
        compression:zip($entries, true())

};

(: Mitigate too many causes error - pass in some ids to get chunks of 1024 back :)
declare function common:ids-chunked($ids as xs:string*) as map(*) {
    
    map:merge(
    
        let $chunk-size := xs:integer(1024)
        let $chunks-count := xs:integer(ceiling(count($ids) div $chunk-size))
        
        for $chunk in 1 to $chunks-count
        let $chunk-start := (($chunk-size * ($chunk - 1)) + 1)
        return
            map{$chunk: subsequence($ids, $chunk-start, $chunk-size)}
        
    )

};

