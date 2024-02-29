xquery version "3.1";

module namespace devanagari="http://read.84000.co/devanagari";

declare namespace test="http://exist-db.org/xquery/xqsuite";

declare variable $devanagari:dev-to-iast-vowels-and-numbers := map {
  "अ": "a","आ": "ā","इ": "i","ई": "ī",
  "उ": "u","ऊ": "ū","ऋ": "ṛ","ॠ": "ṝ",
  "ऌ": "ḷ","ॡ": "ḹ","ए": "e","ऐ": "ai",
  "ओ": "o","औ": "au","अं": "ṃ","अः": "ḥ",
  "ऽ": "'",'\u0902': "ṃ",'\u0903': "ḥ",
  "१": "1","२": "2","३": "3","४": "4","५": "5",
  "६": "6","७": "7","८": "8","९": "9","०": "0"
};

declare variable $devanagari:dev-to-iast-consonants := map {
  "क": "k","ख": "kh","ग": "g","घ": "gh","ङ": "ṅ",
  "च": "c","छ": "ch","ज": "j","झ": "jh","ञ": "ñ",
  "ट": "ṭ","ठ": "ṭh","ड": "ḍ","ढ": "ḍh","ण": "ṇ","त": "t","थ": "th",
  "द": "d","ध": "dh","न": "n","प": "p","फ": "ph","ब": "b","भ": "bh",
  "म": "m","य": "y","र": "r","ल": "l","व": "v",
  "श": "ś","ष": "ṣ","स": "s","ह": "h"
};

declare variable $devanagari:dev-to-iast-consonant-ending := '\u094D';

declare variable $devanagari:dev-to-iast-vowel-ending := map {
  "": "a",
  '\u093E': "ā",'\u093F': "i",'\u0940': "ī",'\u0941': "u",'\u0942': "ū",
  '\u0943': "ṛ",'\u0944': "ṝ",'\u0962': "ḷ",'\u0963': "ḹ",'\u0947': "e",
  '\u0948': "ai",'\u094B': "o",'\u094C': "au",'\u0902': "ṃ",'\u0903': "ḥ"
};

declare 
    %test:args('घटिका ब्रह्म') 
    %test:assertEquals("ghaṭikā brahma")
function devanagari:toIast($devanagari as xs:string) (:as xs:string?:) {

    let $consonant-keys := map:keys($devanagari:dev-to-iast-consonants)
    let $vowel-ending-keys := map:keys($devanagari:dev-to-iast-vowel-ending)
    
    let $dev-letters := $devanagari:dev-to-iast-vowels-and-numbers
    
    let $dev-letters-extended := 
        for $i in 1 to count($consonant-keys)
        return (
            map:put($dev-letters, $consonant-keys[$i] || $devanagari:dev-to-iast-consonant-ending, $devanagari:dev-to-iast-consonants($consonant-keys[$i])),
            for $j in 1 to count($vowel-ending-keys)
            return 
                map:put($dev-letters, $consonant-keys[$i] || $vowel-ending-keys[$j], $devanagari:dev-to-iast-consonants($consonant-keys[$i]) || $devanagari:dev-to-iast-vowel-ending($vowel-ending-keys[$j]))
        )
    
    let $dev-letters-merged := map:merge($dev-letters-extended)
    let $dev-letters-merged-keys := map:keys($dev-letters-merged)
    let $dev-letters-merged-keys-max-len := max($dev-letters-merged-keys ! string-length(.))
    
    (:return $dev-letters-merged-keys-max-len:)
    (:return $dev-letters-merged-keys ! $dev-letters-merged(.) :)
     
    return 
        local:dev-char-to-iast(normalize-unicode($devanagari), 1, $dev-letters-merged-keys-max-len, $dev-letters-merged-keys-max-len, "", $dev-letters-merged) ! normalize-unicode()
        
};

declare function local:dev-char-to-iast($str as xs:string, $start as xs:integer, $chunk-size as xs:integer, $max-chunk-size as xs:integer, $result as xs:string, $dev-letters-merged as map()) (:as xs:string?:) {
    
    (: End of string, return result :)
    if ($start gt string-length($str)) then
        $result
    
    (: Look for smaller chunks :)
    else if (($start + ($chunk-size - 1)) gt string-length($str)) then
        local:dev-char-to-iast($str, $start, $chunk-size - 1, $max-chunk-size, $result, $dev-letters-merged)
    
    else
    
        let $dev-chunk := substring($str, $start, $chunk-size)
        let $iast-match := $dev-letters-merged($dev-chunk)
        return 
            (: chunk matches :)
            if ($iast-match gt '') then
                local:dev-char-to-iast($str, $start + $chunk-size, $max-chunk-size, $max-chunk-size, concat($result, $iast-match), $dev-letters-merged)
            
            (: No matches found, move along  :)
            else if ($chunk-size = 1) then
                local:dev-char-to-iast($str, $start + $chunk-size, $max-chunk-size, $max-chunk-size, concat($result, $dev-chunk), $dev-letters-merged)
            
            (: Move along the string chunks :)
            else
                local:dev-char-to-iast($str, $start, $chunk-size - 1, $max-chunk-size, $result, $dev-letters-merged)
};

