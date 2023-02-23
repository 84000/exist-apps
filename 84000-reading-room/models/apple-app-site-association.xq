xquery version "3.0" encoding "UTF-8";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace json="http://www.json.org";

import module namespace tei-content="http://read.84000.co/tei-content" at "../../84000-reading-room/modules/tei-content.xql";
import module namespace translation="http://read.84000.co/translation" at "../../84000-reading-room/modules/translation.xql";

declare option exist:serialize "method=json media-type=text/javascript";

(: Return Apple Universal Links JSON file for iOS apps :)

(:'{
   "applinks": {
      "apps": [],
      "details": [
         {
            "appIDs": ["KAZM92M7ZW.co.84000.reader","L8R7M2F4B8.co.84000.reader"],
            "paths": [ 
                "/translation/toh1-1.html",
                "/translation/toh1-6.html",
                "/translation/toh11.html",
                "/translation/toh43-1.html"
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
                for $bibl in $tei-content:translations-collection//tei:fileDesc[tei:publicationStmt/@status = '1']/tei:sourceDesc/tei:bibl
                return
                    <paths>/translation/{ $bibl/@key/string() }.html</paths>
            }
        </details>
    </applinks>
</apple-app-site-association>