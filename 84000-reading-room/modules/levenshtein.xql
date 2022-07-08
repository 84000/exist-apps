xquery version "3.1";

module namespace levenshtein = "http://read.84000.co/xquery-levenshtein-distance";

(:~ 
   Calculate Levenshtein Distance, using XQuery
   Adapted from Guillaume Mella's source by Joe Wicentowski - reformatted, refactored, refocused
   @author Guillaume Mella (original)
   @author Joe Wicentowski (revisions)
   @see http://apps.jmmc.fr/~mellag//xquery/levenshtein/2018/01/19/xquery-levenshtein-distance/
:)

declare function levenshtein:levenshtein-distance(
    $string1 as xs:string?, 
    $string2 as xs:string?) 
as xs:integer {
    if (min((string-length($string1), string-length($string2))) eq 0) then
        max((string-length($string1), string-length($string2)))
    else
        local:_levenshtein-distance(
            string-to-codepoints($string1),
            string-to-codepoints($string2),
            string-length($string1),
            string-length($string2),
            (1, 0, 1),
            2
        ) 
};

declare %private function local:_levenshtein-distance(
    $chars1 as xs:integer*, 
    $chars2 as xs:integer*, 
    $length1 as xs:integer, 
    $length2 as xs:integer,
    $lastDiag as xs:integer*, 
    $total as xs:integer)
as xs:integer { 
    let $shift := 
        if ($total gt $length2) then 
            ($total - ($length2 + 1))
        else
            0 
    let $diag := 
        for $i in (max((0, $total - $length2)) to min(($total, $length1))) 
        let $j := $total - $i 
        let $d := ($i - $shift) * 2 
        return ( 
            if ($j lt $length2) then 
                $lastDiag[$d - 1]
            else
                (),
            if ($i eq 0) then 
                $j 
            else if ($j eq 0) then 
                $i 
            else 
                min((
                    $lastDiag[$d - 1] + 1,
                    $lastDiag[$d + 1] + 1,
                    $lastDiag[$d] + (
                        if ($chars1[$i] eq $chars2[$j]) then 
                            0 
                        else 
                            1
                    )
                ))
        )
    return
        if ($total eq $length1 + $length2) then 
            $diag
        else 
            local:_levenshtein-distance($chars1, $chars2, $length1, $length2, $diag, $total + 1) 
};