xquery version "3.1" encoding "UTF-8";

(: Migrate <eft:flag type="alternateSource"/> to <tmx:prop name="alternative-source"/> :)

declare namespace eft="http://read.84000.co/ns/1.0";
declare namespace tmx="http://www.lisa.org/tmx14";

import module namespace update-tm="http://operations.84000.co/update-tm" at "../../84000-operations/modules/update-tm.xql";

for $tu-flagged in collection($update-tm:tm-path)//tmx:tmx/tmx:body/tmx:tu[eft:flag]
where $tu-flagged/ancestor::tmx:tmx/tmx:header[@eft:text-id eq 'UT22084-060-003']
return (
    $tu-flagged/eft:flag,
    for $flag in $tu-flagged/eft:flag
    return
        update replace $flag
        with 
            element { QName('http://www.lisa.org/tmx14', 'prop') } {
                attribute name { 
                    if($flag[@type = ('alternateSource', 'alternativeSource')]) then
                        'alternative-source'
                    else 
                        $flag/@type/string()
                },
                $flag/text()
            }
)