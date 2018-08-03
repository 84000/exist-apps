xquery version "3.0";

declare namespace m = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "../../modules/common.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../modules/translation.xql";

let $data := request:get-data()
let $translation-title := $data//m:translation/m:titles/m:title[@xml:lang eq 'en']/string()
let $epub-id := concat('http://read.84000.co/translation/', $data//m:translation/m:source/@key, '.epub')

let $parameters := 
    <parameters>
        <param name="epub-id" value="{ $epub-id }"/>
    </parameters>

let $entries := (
    <entry name="mimetype" type="text" method="store">application/epub+zip</entry>,
    <entry name="META-INF/container.xml" type="xml">
        <container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0">
            <rootfiles>
                <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
            </rootfiles>
        </container>
    </entry>,
    <entry name="OEBPS/content.opf" type="xml">
        <package xmlns="http://www.idpf.org/2007/opf" version="3.0" xml:lang="en" unique-identifier="bookid">
            <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
                <dc:title id="title">{ $translation-title }</dc:title>
                <meta refines="#title" property="title-type">main</meta>
                <meta refines="#title" property="file-as">{ translation:title-listing($translation-title) }</meta>
                <dc:creator id="creator">84000 – Translating the Words of the Buddha</dc:creator>
                <meta property="file-as" refines="#creator">84000 – Translating the Words of the Buddha</meta>
                <dc:identifier id="bookid">{$epub-id}</dc:identifier>
                <dc:language>en-GB</dc:language>
                <dc:publisher>84000 – Translating the Words of the Buddha</dc:publisher>
                <dc:date>{ $data/m:response/m:translation/m:translation/m:publication-date/text() }</dc:date>
                <meta property="dcterms:modified">{ current-dateTime() }</meta><!-- Published now? -->
                <meta property="belongs-to-collection" id="collection">84000 Translations from the Kangyur</meta>
                <meta refines="#collection" property="collection-type">series</meta>
                <meta refines="#collection" property="group-position">{ replace(lower-case($data/m:response/m:translation/m:source/@key), '^toh', '') }</meta>
            </metadata>
            <manifest>
                <item id="manualStyles" href="css/manualStyles.css" media-type="text/css"/>
                <item id="fontStyles" href="css/fontStyles.css" media-type="text/css"/>
                <item id="logo" href="image/logo-stacked.png" media-type="image/png"/>
                <item id="creative-commons-logo" href="image/CC_logo.png" media-type="image/png"/>
                <item id="tibetan-font" href="fonts/DDC_Uchen.ttf" media-type="application/x-font-truetype"/>
                <item id="english-font-regular" href="fonts/IndUni-P-Regular.otf" media-type="application/vnd.ms-opentype"/>
                <item id="english-font-bold" href="fonts/IndUni-P-Bold.otf" media-type="application/vnd.ms-opentype"/>
                <item id="english-font-italic" href="fonts/IndUni-P-Italic.otf" media-type="application/vnd.ms-opentype"/>
                <item id="english-font-bold-italic" href="fonts/IndUni-P-BoldItalic.otf" media-type="application/vnd.ms-opentype"/>
                <item id="half-title" href="half-title.xhtml" media-type="application/xhtml+xml"/>
                <item id="full-title" href="full-title.xhtml" media-type="application/xhtml+xml"/>
                <item id="imprint" href="imprint.xhtml" media-type="application/xhtml+xml"/>
                <item id="contents" href="contents.xhtml" media-type="application/xhtml+xml" properties="nav"/>
                <item id="summary" href="summary.xhtml" media-type="application/xhtml+xml"/>
                <item id="acknowledgements" href="acknowledgements.xhtml" media-type="application/xhtml+xml"/>
                <item id="introduction" href="introduction.xhtml" media-type="application/xhtml+xml"/>
                <item id="body-title" href="body-title.xhtml" media-type="application/xhtml+xml"/>
                {
                    if($data/m:response/m:translation/m:prologue//tei:p) then 
                        <item id="prologue" href="prologue.xhtml" media-type="application/xhtml+xml"/>
                    else
                        ()
                }
                {
                    for $chapter in $data/m:response/m:translation/m:body/m:chapter
                    return
                        <item id="chapter-{ $chapter/@chapter-index }" href="chapter-{ $chapter/@chapter-index }.xhtml" media-type="application/xhtml+xml"/>
                }
                {
                    if($data/m:response/m:translation/m:colophon//tei:p) then 
                        <item id="colophon" href="colophon.xhtml" media-type="application/xhtml+xml"/>
                    else
                        ()
                }
                {
                    if($data/m:response/m:translation/m:appendix//tei:p) then 
                        <item id="appendix" href="appendix.xhtml" media-type="application/xhtml+xml"/>
                    else
                        ()
                }
                {
                    if($data/m:response/m:translation/m:abbreviations/m:item) then 
                        <item id="abbreviations" href="abbreviations.xhtml" media-type="application/xhtml+xml"/>
                    else
                        ()
                }
                <item id="notes" href="notes.xhtml" media-type="application/xhtml+xml"/>
                <item id="bibliography" href="bibliography.xhtml" media-type="application/xhtml+xml"/>
                <item id="glossary" href="glossary.xhtml" media-type="application/xhtml+xml"/>
                <item id="toc" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
            </manifest>
            <spine toc="toc">
                <itemref idref="half-title"/>
                <itemref idref="full-title"/>
                <itemref idref="imprint"/>
                <itemref idref="contents"/>
                <itemref idref="summary"/>
                <itemref idref="acknowledgements"/>
                <itemref idref="introduction"/>
                <itemref idref="body-title"/>
                {
                    if($data/m:response/m:translation/m:prologue//tei:p) then 
                        <itemref idref="prologue"/>
                    else
                        ()
                }
                {
                    for $chapter in $data/m:response/m:translation/m:body/m:chapter
                    return
                        <itemref idref="chapter-{ $chapter/@chapter-index }"/>
                }
                {
                    if($data/m:response/m:translation/m:colophon//tei:p) then 
                        <itemref idref="colophon"/>
                    else
                        ()
                }
                {
                    if($data/m:response/m:translation/m:appendix//tei:p) then 
                        <itemref idref="appendix"/>
                    else
                        ()
                }
                {
                    if($data/m:response/m:translation/m:abbreviations/m:item) then 
                        <itemref idref="abbreviations"/>
                    else
                        ()
                }
                <itemref idref="notes"/>
                <itemref idref="bibliography"/>
                <itemref idref="glossary"/>
            </spine>
        </package>
    </entry>,
    <entry name="OEBPS/css/manualStyles.css" type="binary">{ common:epub-resource('css/manualStyles.css') }</entry>,
    <entry name="OEBPS/css/fontStyles.css" type="binary">{ common:epub-resource('css/fontStyles.css') }</entry>,
    <entry name="OEBPS/image/logo-stacked.png" type="binary">{ common:epub-resource('image/logo-stacked.png') }</entry>,
    <entry name="OEBPS/image/CC_logo.png" type="binary">{ common:epub-resource('image/CC_logo.png') }</entry>,
    <entry name="OEBPS/fonts/DDC_Uchen.ttf" type="binary">{ common:epub-resource('fonts/DDC_Uchen.ttf') }</entry>,
    <entry name="OEBPS/fonts/IndUni-P-Regular.otf" type="binary">{ common:epub-resource('fonts/IndUni-P-Regular.otf') }</entry>,
    <entry name="OEBPS/fonts/IndUni-P-Bold.otf" type="binary">{ common:epub-resource('fonts/IndUni-P-Bold.otf') }</entry>,
    <entry name="OEBPS/fonts/IndUni-P-Italic.otf" type="binary">{ common:epub-resource('fonts/IndUni-P-Italic.otf') }</entry>,
    <entry name="OEBPS/fonts/IndUni-P-BoldItalic.otf" type="binary">{ common:epub-resource('fonts/IndUni-P-BoldItalic.otf') }</entry>,
    <entry name="OEBPS/half-title.xhtml" type="xml">{transform:transform($data, doc("xslt/half-title.xsl"), ())}</entry>,
    <entry name="OEBPS/full-title.xhtml" type="xml">{transform:transform($data, doc("xslt/full-title.xsl"), ())}</entry>,
    <entry name="OEBPS/imprint.xhtml" type="xml">{transform:transform($data, doc("xslt/imprint.xsl"), ())}</entry>,
    <entry name="OEBPS/contents.xhtml" type="xml">{transform:transform($data, doc("xslt/contents.xsl"), ())}</entry>,
    <entry name="OEBPS/summary.xhtml" type="xml">{transform:transform($data, doc("xslt/summary.xsl"), ())}</entry>,
    <entry name="OEBPS/acknowledgements.xhtml" type="xml">{transform:transform($data, doc("xslt/acknowledgements.xsl"), ())}</entry>,
    <entry name="OEBPS/introduction.xhtml" type="xml">{transform:transform($data, doc("xslt/introduction.xsl"), ())}</entry>,
    <entry name="OEBPS/body-title.xhtml" type="xml">{transform:transform($data, doc("xslt/body-title.xsl"), ())}</entry>,
    if($data/m:response/m:translation/m:prologue//tei:p) then 
        <entry name="OEBPS/prologue.xhtml" type="xml">{transform:transform($data, doc("xslt/prologue.xsl"), ())}</entry>
    else
        ()
    ,
    for $chapter in $data/m:response/m:translation/m:body/m:chapter
    return
        <entry name="OEBPS/chapter-{ $chapter/@chapter-index }.xhtml" type="xml">
            { transform:transform($data, doc("xslt/chapter.xsl"), <parameters><param name="chapter-index" value="{ $chapter/@chapter-index }"/></parameters>) }
        </entry>
    ,
    if($data/m:response/m:translation/m:colophon//tei:p) then 
        <entry name="OEBPS/colophon.xhtml" type="xml">{transform:transform($data, doc("xslt/colophon.xsl"), ())}</entry>
    else
        ()
    ,
    if($data/m:response/m:translation/m:appendix//tei:p) then 
        <entry name="OEBPS/appendix.xhtml" type="xml">{transform:transform($data, doc("xslt/appendix.xsl"), ())}</entry>
    else
        ()
    ,
    if($data/m:response/m:translation/m:abbreviations/m:item) then 
        <entry name="OEBPS/abbreviations.xhtml" type="xml">{transform:transform($data, doc("xslt/abbreviations.xsl"), ())}</entry>
    else
        ()
    ,
    <entry name="OEBPS/notes.xhtml" type="xml">{transform:transform($data, doc("xslt/notes.xsl"), ())}</entry>,
    <entry name="OEBPS/bibliography.xhtml" type="xml">{transform:transform($data, doc("xslt/bibliography.xsl"), ())}</entry>,
    <entry name="OEBPS/glossary.xhtml" type="xml">{transform:transform($data, doc("xslt/glossary.xsl"), ())}</entry>,
    <entry name="OEBPS/toc.ncx" type="xml">{transform:transform(transform:transform($data, doc("xslt/toc.xsl"), $parameters), doc("xslt/play-order.xsl"), ())}</entry>
)
let $zip := compression:zip($entries, true())
return
    response:stream-binary($zip, 'application/epub+zip')

