xquery version "3.0";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace common = "http://read.84000.co/common" at "../../modules/common.xql";
import module namespace tei-content = "http://read.84000.co/tei-content" at "../../modules/tei-content.xql";
import module namespace store = "http://read.84000.co/store" at "../../modules/store.xql";
import module namespace translation = "http://read.84000.co/translation" at "../../modules/translation.xql";

declare variable $resource-id := request:get-parameter('resource-id', '');
declare variable $resource-requested := request:get-parameter('resource-requested', '') ! lower-case(.) ! replace(., '[^a-zA-Z0-9\-_\.]', '');
declare variable $ebook-config := $store:conf/eft:ebooks;
declare variable $data := request:get-data();

declare function local:generate-epub() as xs:base64Binary? {
    
    let $translation-title := $data//eft:translation/eft:titles/eft:title[@xml:lang eq 'en']/string()
    let $epub-id := concat('https://84000.co/translation/', $data//eft:translation/eft:source/@key, '.epub')
    
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
                    <dc:date>{ $data/eft:response/eft:translation/eft:publication/eft:publication-date/text() }</dc:date>
                    <meta property="dcterms:modified">{ format-dateTime(current-dateTime(), "[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z") }</meta>
                    <meta property="belongs-to-collection" id="collection">84000 Translations from the Kangyur</meta>
                    <meta refines="#collection" property="collection-type">series</meta>
                    <meta refines="#collection" property="group-position">{ replace(lower-case($data/eft:response/eft:translation/eft:source/@key), '^toh', '') }</meta>
                </metadata>
                <manifest>
                    <item id="manualStyles" href="css/manualStyles.css" media-type="text/css"/>
                    <item id="fontStyles" href="css/fontStyles.css" media-type="text/css"/>
                    <item id="logo" href="image/logo-stacked.png" media-type="image/png"/>
                    <item id="creative-commons-logo" href="image/CC_logo.png" media-type="image/png"/>
                    {
                    for $image-url at $index in distinct-values($data/eft:response/eft:translation/eft:part//tei:media[@mimeType eq 'image/png']/@url)
                    return
                        <item id="content-image-{$index}" href="image{$image-url}" media-type="image/png"/>
                    }
                    <item id="tibetan-font" href="fonts/Jomolhari-Regular.ttf" media-type="application/vnd.ms-opentype"/>
                    <item id="english-font-regular" href="fonts/IndUni-P-Regular.otf" media-type="application/vnd.ms-opentype"/>
                    <item id="english-font-bold" href="fonts/IndUni-P-Bold.otf" media-type="application/vnd.ms-opentype"/>
                    <item id="english-font-italic" href="fonts/IndUni-P-Italic.otf" media-type="application/vnd.ms-opentype"/>
                    <item id="english-font-bold-italic" href="fonts/IndUni-P-BoldItalic.otf" media-type="application/vnd.ms-opentype"/>
                    <item id="japanese-font" href="fonts/NotoSansJP-Regular.otf" media-type="application/vnd.ms-opentype"/>
                    <item id="chinese-font" href="fonts/NotoSansTC-Regular.otf" media-type="application/vnd.ms-opentype"/>
                    <item id="titles" href="titles.xhtml" media-type="application/xhtml+xml"/>
                    <item id="imprint" href="imprint.xhtml" media-type="application/xhtml+xml"/>
                    <item id="contents" href="contents.xhtml" media-type="application/xhtml+xml" properties="nav"/>
                    {
                        for $part in $data/eft:response/eft:translation/eft:part[not(@type eq 'citation-index')]
                        return (
                        
                            if($part[@type eq 'translation'][eft:part[@type eq 'prelude']]) then (
                                <item id="prelude-title" href="prelude-title.xhtml" media-type="application/xhtml+xml"/>,
                                for $chapter in $part/eft:part[@type eq 'prelude']
                                return
                                    <item id="{ $chapter/@id }" href="{ $chapter/@id }.xhtml" media-type="application/xhtml+xml"/>
                            )
                            else ()
                            ,
                        
                            <item id="{ $part/@id }" href="{ $part/@id }.xhtml" media-type="application/xhtml+xml"/>,
                            
                            if($part[@type = ('translation', 'appendix')]) then
                                for $chapter in $part/eft:part[not(@type eq 'prelude')]
                                return
                                    <item id="{ $chapter/@id }" href="{ $chapter/@id }.xhtml" media-type="application/xhtml+xml"/>
                            else ()
                            
                        )
                     }
                    <item id="toc" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
                </manifest>
                <spine toc="toc">
                    <itemref idref="titles"/>
                    <itemref idref="imprint"/>
                    <itemref idref="contents"/>
                    {
                        for $part in $data/eft:response/eft:translation/eft:part[not(@type eq 'citation-index')]
                        return (
                        
                            if($part[@type eq 'translation'][eft:part[@type eq 'prelude']]) then (
                                <itemref idref="prelude-title"/>,
                                for $chapter in $part/eft:part[@type eq 'prelude']
                                return
                                    <itemref idref="{ $chapter/@id }"/>
                            )
                            else ()
                            ,
                        
                            <itemref idref="{ $part/@id }"/>,
                            
                            if($part[@type = ('translation', 'appendix')]) then
                                for $chapter in $part/eft:part[not(@type eq 'prelude')]
                                return
                                    <itemref idref="{ $chapter/@id }"/>
                            else ()
                            
                        )
                     }
                </spine>
            </package>
        </entry>,
        <entry name="OEBPS/css/manualStyles.css" type="binary">{ common:epub-resource('css/manualStyles.css') }</entry>,
        <entry name="OEBPS/css/fontStyles.css" type="binary">{ common:epub-resource('css/fontStyles.css') }</entry>,
        <entry name="OEBPS/image/logo-stacked.png" type="binary">{ common:epub-resource('image/logo-stacked.png') }</entry>,
        <entry name="OEBPS/image/CC_logo.png" type="binary">{ common:epub-resource('image/CC_logo.png') }</entry>,
        for $image-url in distinct-values($data/eft:response/eft:translation/eft:part//tei:media[@mimeType eq 'image/png']/@url)[not(matches(., '^http', 'i'))]
        return
            <entry name="OEBPS/image{ $image-url }" type="binary">{ util:binary-doc(xs:anyURI(concat($common:static-content-path, $image-url))) }</entry>
        ,
        <entry name="OEBPS/fonts/Jomolhari-Regular.ttf" type="binary">{ common:epub-resource('fonts/Jomolhari-Regular.ttf') }</entry>,
        <entry name="OEBPS/fonts/IndUni-P-Regular.otf" type="binary">{ common:epub-resource('fonts/IndUni-P-84000-Regular.otf') }</entry>,
        <entry name="OEBPS/fonts/IndUni-P-Bold.otf" type="binary">{ common:epub-resource('fonts/IndUni-P-Bold.otf') }</entry>,
        <entry name="OEBPS/fonts/IndUni-P-Italic.otf" type="binary">{ common:epub-resource('fonts/IndUni-P-Italic.otf') }</entry>,
        <entry name="OEBPS/fonts/IndUni-P-BoldItalic.otf" type="binary">{ common:epub-resource('fonts/IndUni-P-BoldItalic.otf') }</entry>,
        <entry name="OEBPS/fonts/NotoSansJP-Regular.otf" type="binary">{ common:epub-resource('fonts/NotoSansJP-Regular.otf') }</entry>,
        <entry name="OEBPS/fonts/NotoSansTC-Regular.otf" type="binary">{ common:epub-resource('fonts/NotoSansTC-Regular.otf') }</entry>,
        <entry name="OEBPS/titles.xhtml" type="xml">{ transform:transform($data, doc('xslt/titles.xsl'), ()) }</entry>,
        <entry name="OEBPS/imprint.xhtml" type="xml">{ transform:transform($data, doc('xslt/imprint.xsl'), ()) }</entry>,
        <entry name="OEBPS/contents.xhtml" type="xml">{ transform:transform($data, doc('xslt/contents.xsl'), ()) }</entry>,
        for $part in $data/eft:response/eft:translation/eft:part[not(@type eq 'citation-index')]
        return (
            
            if($part[@type eq 'translation']/eft:part[@type eq 'prelude']) then (
                
                <entry name="OEBPS/prelude-title.xhtml" type="xml">{ transform:transform($data, doc('xslt/prelude-title.xsl'), ()) }</entry>,
            
               for $chapter in $part/eft:part[@type eq 'prelude']
               let $parameters := 
                    <parameters>
                        <param name="part-id" value="{ $chapter/@id }"/>
                    </parameters>
                return
                    <entry name="OEBPS/{ $chapter/@id }.xhtml" type="xml">{transform:transform($data, doc('xslt/chapter.xsl'), $parameters)}</entry>
                    
            )
            else()
            ,
            
            <entry name="OEBPS/{ $part/@id }.xhtml" type="xml">{ transform:transform($data, doc(concat('xslt/', $part/@type, '.xsl')), ()) }</entry>,
            
            if($part[@type = ('translation', 'appendix')]) then
                for $chapter in $part/eft:part[not(@type eq 'prelude')]
                let $parameters := 
                    <parameters>
                        <param name="part-id" value="{ $chapter/@id }"/>
                    </parameters>
                return
                    <entry name="OEBPS/{ $chapter/@id }.xhtml" type="xml">{transform:transform($data, doc('xslt/chapter.xsl'), $parameters)}</entry>
            else ()
            
        ),
        
        let $parameters := 
            <parameters>
                <param name="epub-id" value="{ $epub-id }"/>
            </parameters>
        return
            <entry name="OEBPS/toc.ncx" type="xml">{transform:transform(transform:transform($data, doc("xslt/toc.xsl"), $parameters), doc("xslt/play-order.xsl"), ())}</entry>
    )
    
    return
        compression:zip($entries, true())
};

let $source-key := $data//eft:translation/eft:source/@key
let $tei := tei-content:tei($source-key, 'translation')
let $translation-epub := translation:files($tei, 'translation-files', $source-key)/eft:file[@type eq 'epub']
let $file-path := string-join(($translation-epub/@target-folder, $translation-epub/@target-file), '/')

where $translation-epub
return
    (: Generate latest epub :)
    if(
        (: Master database :)
        $ebook-config
        (: Authorised user :)
        (:and common:user-in-group('operations'):)
        and sm:id()
    ) then
        let $epub := local:generate-epub()
        return
            response:stream-binary($epub, 'application/epub+zip', $resource-requested)
    
    (: Return the latest file if there is one :)
    else if($translation-epub/@timestamp gt '') then
        let $epub := util:binary-doc($file-path)
        return
            response:stream-binary($epub, 'application/epub+zip', $resource-requested)
    
    else 
        let $exception :=
            element { QName('http://read.84000.co/ns/1.0','exception') } {
                element path { '/db/apps/84000-reading-room/views/epub/translation.xq' },
                element message { 'Ebook not found (' || $file-path || ')'}
            }
        return
            common:html(common:response('error',common:app-id(), $exception), concat($common:app-path, '/views/html/error.xsl'))

(:return <entries>{$entries}</entries>:)

