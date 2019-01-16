xquery version "3.0";

declare namespace o="http://www.tbrc.org/models/outline";
declare namespace m="http://read.84000.co/ns/1.0";

declare variable $kangyur-outline := doc('/db/apps/84000-data/archived/outlines/kangyur.xml');
declare variable $tengyur-outline := doc('/db/apps/84000-data/archived/outlines/tengyur.xml');

declare function local:section($section as element()) as element() {
    <section xmlns="http://read.84000.co/ns/1.0"
        source-id="{ $section/@RID }">
        {
            for $section in $section/o:node[@type = ('section') or o:node[@type = ('text', 'section', 'chapter')]]
            return
                local:section($section)
        }
        {
            if($section/@RID eq 'O1JC76301JC11278') then
                (: Add works of Atisa :)
                for $i in (4465 to 4567)
                return
                    local:text(<text RID="{ concat('O1JC76301JC11278', $i) }"/>)
                
            else
                for $text in $section/o:node
                    [not(@type = ('translation', 'section'))]               (: presumably therefore @type = ('text', 'chapter') :)
                    [not(o:node[@type = ('text', 'section', 'chapter')])]   (: no sub-nodes :)
                return
                    local:text($text)             
        }
    </section>
};

declare function local:text($text as element()) as element() {
    <text xmlns="http://read.84000.co/ns/1.0"
        source-id="{ $text/@RID }"/>
};

if($kangyur-outline/o:outline and $tengyur-outline/o:outline) then
    xmldb:store(
       '/db/apps/84000-data/operations/', 
       'sections-structure.xml', 
        <sections-structure xmlns="http://read.84000.co/ns/1.0">
            <section source-id="LOBBY">
                {
                    for $outline in $kangyur-outline/o:outline
                    return
                        local:section($outline)
                }
                {
                    for $outline in $tengyur-outline/o:outline
                    return
                        local:section($outline)
                }
            </section>
        </sections-structure>
    )
else
    ()

