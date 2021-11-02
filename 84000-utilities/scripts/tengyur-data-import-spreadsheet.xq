xquery version "3.0";
declare namespace m="http://read.84000.co/ns/1.0";

declare variable $local:spreadsheet-data := collection('/db/apps/84000-data/uploads/tengyur-spreadsheets');

<tengyur-data xmlns="http://read.84000.co/ns/1.0">
    <head>
        <doc doc_id="tengyur-data-3981-4085_CD_v1.xml"/>
        <processed date="{ current-dateTime() }" ver="1" auth="CDisimone"/>
    </head>
    {
        for $row in $local:spreadsheet-data//m:spreadsheet/*
        let $text-id := $row/@Text-id/string()
        group by $text-id
        where matches($text-id, '^UT')
        order by $text-id
        return 
        <text text-id="{ $text-id }">
        {
            for $sub-row in $row
            let $toh := local-name($sub-row)
            group by $toh
            return 
                <toh key="{ replace($toh, '_', '') ! lower-case(.) }" label="{ replace($toh, '_', ' ') }"/>
            ,
            
            let $sub-rows :=
                for $sub-row in $row                
                return (
                    if($sub-row[@Type eq 'title'][@Value/string() gt '']) then
                        <title type="{ $sub-row/@Group }" xml:lang="{ $sub-row/@Lang }">{ $sub-row/@Value/string() }</title>
                    else if($sub-row[@Type eq 'author'][@Value/string() gt '']) then
                        <author ref="{ $sub-row/@Group }" xml:lang="{ $sub-row/@Lang }">{ $sub-row/@Value/string() }</author>
                    else if($sub-row[@Type eq 'translator'][@Value/string() gt '']) then
                        <translator ref="{ $sub-row/@Group }" xml:lang="{ $sub-row/@Lang }">{ $sub-row/@Value/string() }</translator>
                    else ()
                    ,
                    if($sub-row[@Notes/string() gt '' and not(@Notes/string() eq '#ERROR!')]) then
                        <note type="{ $sub-row/@Type }" ref="{ $sub-row/@Group }" xml:lang="En">{ $sub-row/@Notes/string() }</note>
                    else ()
                )
            return (
                $sub-rows[self::m:title],
                <authorstatement type="main">
                {
                    $sub-rows[self::m:author]
                }
                </authorstatement>,
                <translatorstatement>
                {
                    $sub-rows[self::m:translator]
                }
                </translatorstatement>,
                $sub-rows[self::m:note]
            )
            
        }
        </text>
    }
</tengyur-data> 