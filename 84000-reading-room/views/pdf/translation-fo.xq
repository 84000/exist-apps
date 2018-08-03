xquery version "3.0";

declare namespace fo="http://www.w3.org/1999/XSL/Format";
declare namespace t="http://read.84000.co/ns/1.0";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

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
                <fo:block font-size="12pt" text-align="center" font-family="Arial" color="gray" margin-bottom="10mm">
                     - This is just a provisional pdf to test font rendering using Apache FO - 
                </fo:block>
                <fo:block text-align="center" font-size="30pt" font-family="Tibetan" script="tibt" margin-bottom="10mm">
                {
                    $translation/t:titles/t:title[@xml:lang = 'bo']/text()
                }
                </fo:block>
                <fo:block font-size="44pt" text-align="center" font-family="Arial" margin-bottom="10mm">
                {
                    $translation/t:titles/t:title[@xml:lang = 'en']/text()
                }
                </fo:block>
                <fo:block text-align="center" font-size="30pt" font-family="Times" margin-bottom="10mm">
                {
                    $translation/t:titles/t:title[@xml:lang = 'sa-ltn']/text()
                }
                </fo:block>
                {
                    for $paragraph in $translation/t:summary/xhtml:p
                    return
                        <fo:block font-size="12pt" text-align="justify" font-family="Times" margin-bottom="5mm">
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
        <complex-scripts disabled="false"/>
        <renderers>
            <renderer mime="application/pdf">
            {
                doc('/db/env/fonts.xml')
            }
            </renderer>
        </renderers>
    </fop>
};

let $data := request:get-data()
let $pdf := xslfo:render(fo:main($data/t:response/t:translation), "application/pdf", (), local:fop-config())
let $title := normalize-space($data/t:response/t:translation/t:titles/t:title[@xml:lang = 'en']/text())

return
    response:stream-binary($pdf, "media-type=application/pdf", concat($title, ".pdf"))
