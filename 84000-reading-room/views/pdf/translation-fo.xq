xquery version "3.0";

declare namespace fo="http://www.w3.org/1999/XSL/Format";
declare namespace m="http://read.84000.co/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace common="http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translation="http://read.84000.co/translation" at "../../modules/translation.xql";

declare function fo:main($translation) {
    <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
        <fo:layout-master-set>
            <fo:simple-page-master master-name="84000" 
                margin-top="10mm" margin-bottom="10mm" margin-left="12mm" margin-right="12mm">
                <fo:region-body margin-bottom="10mm" margin-top="10mm"/>
                <fo:region-before region-name="header" margin-bottom="10mm" extent="10mm"/>
                <fo:region-after region-name="footnotes" extent="10mm"/>
            </fo:simple-page-master>
        </fo:layout-master-set>
        <fo:page-sequence master-reference="84000">
            <fo:flow flow-name="xsl-region-body">
                <fo:block font-size="12pt" text-align="center" font-family="IndUni-P-84000-Regular" color="gray" margin-bottom="10mm">
                     - This is just a provisional pdf to test font rendering using Apache FO - 
                </fo:block>
                <fo:block text-align="center" font-size="30pt" font-family="Tibetan" margin-bottom="10mm" script="tibt">
                {
                    $translation/m:titles/m:title[@xml:lang = 'bo']/text() ! normalize-unicode(.)
                }
                </fo:block>
                <fo:block font-size="44pt" text-align="center" font-family="IndUni-P-84000-Regular" margin-bottom="10mm">
                {
                    $translation/m:titles/m:title[@xml:lang = 'en']/text()
                }
                </fo:block>
                <fo:block text-align="center" font-size="30pt" font-family="IndUni-P-84000-Regular" margin-bottom="10mm">
                {
                    $translation/m:titles/m:title[@xml:lang = 'Sa-Ltn']/text()
                }
                </fo:block>
                {
                    for $paragraph in $translation/m:part[@type eq 'summary']/tei:p
                    return
                        <fo:block font-size="12pt" text-align="justify" font-family="IndUni-P-84000-Regular" margin-bottom="5mm">
                        {
                            $paragraph//text()
                        }
                        </fo:block>
                }
            </fo:flow>                    
        </fo:page-sequence>
    </fo:root>
};

declare function local:fop-config() {
    <fop version="2.1">
        <!-- Strict user configuration -->
        <strict-configuration>true</strict-configuration>
        <!-- Strict FO validation -->
        <strict-validation>false</strict-validation>
        <!-- Base URL for resolving relative URLs -->
        <base>./</base>
        <renderers>
            <renderer mime="application/pdf">
                <fonts>
                    <font kerning="no"
                        embed-url="/db/apps/84000-reading-room/views/pdf/resources/fonts/Jomolhari-Regular.ttf"
                        encoding-mode="auto">
                        <font-triplet name="Tibetan" style="normal" weight="normal"/>
                    </font>
                    <font kerning="yes"
                        embed-url="/db/apps/84000-reading-room/views/pdf/resources/fonts/IndUni-P-84000-Regular.otf"
                        encoding-mode="auto">
                        <font-triplet name="IndUni-P-84000-Regular" style="normal" weight="normal"/>
                    </font>
                </fonts>
            </renderer>
        </renderers>
    </fop>
};

let $data := request:get-data()/m:response
let $pdf := xslfo:render(fo:main($data/m:translation), "application/pdf", (), local:fop-config())
let $title := normalize-space($data/m:translation/m:titles/m:title[@xml:lang = 'en']/text())

return
    response:stream-binary($pdf, "media-type=application/pdf", concat($title, ".pdf"))
