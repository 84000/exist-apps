declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace ex="http://exist-db.org/collection-config/1.0";
import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";

let $trigger := doc(concat('/db/system/config',$common:tei-path, '/collection.xconf'))/ex:collection/ex:triggers/ex:trigger

return 
    if($trigger) then 
        <warning>{ 'DISABLE TRIGGERS BEFORE UPDATING TEI' }</warning>
        
    else 
    
        for $fileDesc in collection($common:translations-path)//tei:fileDesc
        let $toh-number := ($fileDesc/tei:sourceDesc/tei:bibl/@key)[1] ! replace(., '^toh([0-9]+)\-?([0-9]+)?.*', '$1.$2') ! xs:double(.)
        order by $toh-number
        where 
            not(count($fileDesc/tei:titleStmt/tei:title[@xml:lang eq 'Bo-Ltn']) eq count($fileDesc/tei:titleStmt/tei:title[@xml:lang eq 'bo'])) 
            (:and $toh-number eq 9:)
        return 
            element titles {
                
                $fileDesc/tei:sourceDesc/tei:bibl/tei:ref[1],
                
                let $titles-bo := $fileDesc/tei:titleStmt/tei:title[@xml:lang eq 'bo']/data() ! normalize-space(.) ! common:normalize-unicode(.) ! concat(., if(not(matches(., '།$'))) then '།' else ())
                
                return (
                    if($fileDesc/tei:titleStmt/tei:title[@xml:lang eq 'bo']) then
                        element titles-bo-existing {
                            $fileDesc/tei:titleStmt/tei:title[@xml:lang eq 'bo']
                        }
                    else ()
                    ,
                    
                    for $title-wy in $fileDesc/tei:titleStmt/tei:title[@xml:lang eq 'Bo-Ltn']
                    let $title-wy-transliterated := $title-wy ! concat(data(), if(not(matches(., '/$'))) then '/' else ()) ! common:bo-from-wylie(.) ! normalize-space(.) ! common:normalize-unicode(.)
                    where not($titles-bo = $title-wy-transliterated)
                    return 
                        element titles-bo-add {
                            $title-wy,
                            let $title-bo :=
                                element { QName('http://www.tei-c.org/ns/1.0','title') } {
                                    $title-wy/@type,
                                    attribute xml:lang { 'bo' },
                                    $title-wy ! common:bo-from-wylie(.) ! normalize-space(.) ! common:normalize-unicode(.)
                                }
                            return (
                                $title-bo(:,
                                update insert (common:ws(4), $title-bo) following $title-wy:)
                            )
                        }
                    
                )
            }