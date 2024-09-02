xquery version "3.1" encoding "UTF-8";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace json="http://www.json.org";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";

declare option exist:serialize "method=json indent=yes media-type=text/javascript";
declare option output:indent "yes";

(: Return Apple Universal Links JSON file for iOS apps :)

(:'{
   "applinks": {
      "apps": [],
      "details": [
         {
            "appIDs": ["KAZM92M7ZW.co.84000.reader","L8R7M2F4B8.co.84000.reader"],
            "paths": [ 
                "/translation/toh1-1",
                "/translation/toh1-6",
                "/translation/toh11",
                "/translation/toh43-1"
            ]
         }
      ]
  }
}':)

<apple-app-site-association>
    <applinks>
        <apps json:array="true"/>
        <details json:array="true">
            <appIDs>KAZM92M7ZW.co.84000.reader</appIDs>
            <appIDs>L8R7M2F4B8.co.84000.reader</appIDs>
            {
                for $bibl in $tei-content:translations-collection//tei:fileDesc[tei:publicationStmt/tei:availability/@status = '1']/tei:sourceDesc/tei:bibl[@key]
                order by $bibl/@key ! replace(., '^toh(\d+)([a-zA-Z]*)\-*(\d*)([a-zA-Z]*)', '$1')[. gt ''] ! xs:integer(.), $bibl/@key
                return
                    <paths>{ translation:href($bibl/@key/string(), (), (), (), ()) }</paths>
            }
        </details>
    </applinks>
</apple-app-site-association>

    