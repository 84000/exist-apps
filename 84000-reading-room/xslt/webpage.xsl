<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <!-- include navigation stylesheet -->
    <xsl:import href="84000-html.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment" select="if(/m:response[m:environment]) then /m:response/m:environment else doc('/db/system/config/db/system/environment.xml')/m:environment"/>
    
    <xsl:variable name="front-end-path" select="if($environment/m:url[@id eq 'front-end']) then $environment/m:url[@id eq 'front-end'] else ''" as="xs:string"/>
    <xsl:variable name="reading-room-path" select="if($environment/m:url[@id eq 'reading-room']) then $environment/m:url[@id eq 'reading-room'] else ''" as="xs:string"/>
    <xsl:variable name="communications-site-path" select="if($environment/m:url[@id eq 'communications-site']) then $environment/m:url[@id eq 'communications-site'] else ''" as="xs:string"/>
    <xsl:variable name="ga-tracking-id" select="if($environment/m:google-analytics[@tracking-id]) then $environment/m:google-analytics/@tracking-id else ''" as="xs:string"/>
    <xsl:variable name="app-version" select="if(/m:response/@app-version) then /m:response/@app-version else ''" as="xs:string"/>
    <xsl:variable name="app-version-url-attribute" select="if($app-version gt '') then concat('?v=', $app-version) else ''" as="xs:string"/>
    
    <!-- get shared html -->
    <xsl:variable name="eft-header" select="doc('../config/84000-header.xml')/m:eft-header" as="element(m:eft-header)"/>
    <xsl:variable name="eft-footer" select="doc('../config/84000-footer.xml')/m:eft-footer" as="element(m:eft-footer)"/>
    
    <!-- language [en|zh] -->
    <xsl:variable name="lang" select="if(/m:response/@lang) then /m:response/@lang else 'en'" as="xs:string"/>
    
    <!-- Tei Editor -->
    <xsl:variable name="tei-editor" select="/m:response[@tei-editor eq 'true'] and $view-mode[@id = ('editor','editor-passage')]"/>
    <xsl:variable name="tei-editor-off" select="/m:response[@tei-editor eq 'true'] and not($view-mode[@id = ('editor','editor-passage')])"/>
    
    <!-- view-mode [default|editor|annotation|txt|ebook|pdf|app|tests|glossary-editor|glossary-check] -->
    <xsl:variable name="view-mode" select="/m:response/m:request/m:view-mode" as="element(m:view-mode)?"/>
    <xsl:function name="m:view-mode-parameter" as="xs:string">
        <xsl:param name="override" as="xs:string?"/>
        <xsl:value-of select="m:view-mode-parameter($override, '&amp;')"/>
    </xsl:function>
    <xsl:function name="m:view-mode-parameter" as="xs:string?">
        <xsl:param name="override" as="xs:string?"/>
        <xsl:param name="prefix" as="xs:string?"/>
        <xsl:variable name="view-mode-id" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$override gt ''">
                    <xsl:value-of select="$override"/>
                </xsl:when>
                <xsl:when test="$tei-editor">
                    <xsl:value-of select="'editor'"/>
                </xsl:when>
                <xsl:when test="$view-mode[not(@id eq 'default')]">
                    <xsl:value-of select="$view-mode/@id"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$view-mode-id ! concat($prefix, 'view-mode=',.)"/>
    </xsl:function>
    
    <xsl:variable name="archive-path" select="/m:response/m:request/@archive-path" as="xs:string?"/>
    <xsl:function name="m:archive-path-parameter" as="xs:string">
        <xsl:value-of select="if($archive-path gt '') then concat('&amp;archive-path=', $archive-path)  else ''"/>
    </xsl:function>
    
    <!-- doc-type [html|epub|ncx] -->
    <xsl:variable name="doc-type" select="/m:response/m:request/@doc-type"/>
    
    <!-- Override navigation params -->
    <xsl:variable name="active-url" as="xs:string">
        <!-- <xsl:value-of select="common:internal-link('https://read.84000.co/', (), '', $lang)"/> -->
        <xsl:choose>
            <xsl:when test="upper-case(/m:response/m:section/@id) eq 'ALL-TRANSLATED'">
                <xsl:value-of select="common:internal-link('https://read.84000.co/section/all-translated.html', (), '', $lang)"/>
            </xsl:when>
            <xsl:when test="/m:response/@model eq 'section'">
                <xsl:value-of select="common:internal-link('https://read.84000.co/section/lobby.html', (), '', $lang)"/>
            </xsl:when>
            <xsl:when test="/m:response/@model eq 'search'">
                <xsl:value-of select="common:internal-link('https://read.84000.co/search.html', (), '', $lang)"/>
            </xsl:when>
            <xsl:when test="/m:response/@model = ('glossary', 'glossary-entry')">
                <xsl:value-of select="common:internal-link('https://read.84000.co/glossary/search.html', (), '', $lang)"/>
            </xsl:when>
            <xsl:when test="/m:response/@model = ('knowledgebase', 'knowledgebase-article')">
                <xsl:value-of select="common:internal-link('https://read.84000.co/knowledgebase.html', (), '', $lang)"/>
            </xsl:when>
            <xsl:when test="/m:response/@model eq 'about/sponsors'">
                <xsl:value-of select="common:internal-link('https://read.84000.co/about/sponsors.html', (), '', $lang)"/>
            </xsl:when>
            <xsl:when test="/m:response/@model eq 'about/impact'">
                <xsl:value-of select="common:internal-link('https://read.84000.co/about/impact.html', (), '', $lang)"/>
            </xsl:when>
            <xsl:when test="/m:response/@model eq 'about/progress'">
                <xsl:value-of select="common:internal-link('https://read.84000.co/about/progress.html', (), '', $lang)"/>
            </xsl:when>
            <xsl:when test="/m:response/@model eq 'about/translators'">
                <xsl:value-of select="common:internal-link('https://read.84000.co/about/translators.html', (), '', $lang)"/>
            </xsl:when>
            <xsl:when test="/m:response/@model eq 'about/sponsor-a-sutra'">
                <xsl:value-of select="common:internal-link('https://read.84000.co/about/sponsor-a-sutra.html', (), '', $lang)"/>
            </xsl:when>
            <xsl:when test="/m:response/@model eq 'knowledgebase'">
                <xsl:value-of select="common:internal-link('https://read.84000.co/knowledgebase.html', (), '', $lang)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="common:internal-link('#reading-room', (), '', '')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="local-comms-url" select="$communications-site-path" as="xs:string"/>
    <xsl:variable name="local-reading-room-url" select="$reading-room-path" as="xs:string"/>
    <xsl:variable name="local-front-end-url" select="$front-end-path" as="xs:string"/>
    <xsl:variable name="default-search-form-target" select="'reading-room'" as="xs:string"/>
    
    <xsl:output method="html" indent="no" doctype-system="about:legacy-compat" omit-xml-declaration="yes"/>
    
    <!-- html head tag -->
    <xsl:template name="html-head">
        
        <xsl:param name="front-end-path" required="yes" as="xs:string"/>
        <xsl:param name="page-url" required="yes" as="xs:string"/>
        <xsl:param name="page-title" required="yes" as="xs:string"/>
        <xsl:param name="page-description" required="yes" as="xs:string"/>
        <xsl:param name="page-type" required="yes" as="xs:string"/>
        <xsl:param name="additional-links" required="no" as="node()*"/>
        
        <head>
            
            <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1.0, user-scalable=0"/>
            <meta name="description">
                <xsl:attribute name="content" select="$page-description"/>
            </meta>
            
            <title>
                <xsl:value-of select="$page-title"/>
            </title>
            
            <link rel="stylesheet" type="text/css">
                <xsl:choose>
                    <xsl:when test="$page-type = ('communications')">
                        <xsl:attribute name="href" select="concat($front-end-path, '/css/84000-comms.css', $app-version-url-attribute)"/>
                    </xsl:when>
                    <xsl:when test="$page-type = ('utilities')">
                        <xsl:attribute name="href" select="concat($front-end-path, '/css/84000-utilities.css', $app-version-url-attribute)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="href" select="concat($front-end-path, '/css/84000-translation.css', $app-version-url-attribute)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </link>
            
            <xsl:if test="not($view-mode) or $view-mode[@client eq 'browser']">
                
                <link rel="stylesheet" type="text/css">
                    <xsl:attribute name="href" select="concat($front-end-path, '/css/ie10-viewport-bug-workaround.css')"/>
                </link>
                
                <xsl:if test="$page-url gt ''">
                    <link rel="canonical">
                        <xsl:attribute name="href" select="$page-url"/>
                    </link>
                </xsl:if>
                
                <link rel="apple-touch-icon">
                    <xsl:attribute name="href" select="concat($front-end-path, '/favicon/apple-touch-icon.png')"/>
                </link>
                <link rel="icon" type="image/png" sizes="32x32">
                    <xsl:attribute name="href" select="concat($front-end-path, '/favicon/favicon-32x32.png')"/>
                </link>
                <link rel="icon" type="image/png" sizes="16x16">
                    <xsl:attribute name="href" select="concat($front-end-path, '/favicon/favicon-16x16.png')"/>
                </link>
                <link rel="manifest">
                    <xsl:attribute name="href" select="concat($front-end-path, '/favicon/manifest.json')"/>
                </link>
                <link rel="mask-icon">
                    <xsl:attribute name="href" select="concat($front-end-path, '/favicon/safari-pinned-tab.svg')"/>
                </link>
                <link rel="shortcut icon">
                    <xsl:attribute name="href" select="concat($front-end-path, '/favicon/favicon.ico')"/>
                </link>
                
                <xsl:sequence select="$additional-links"/>
                
                <xsl:sequence select="$environment/m:html-head/xhtml:*"/>
                
                <meta name="msapplication-config">
                    <xsl:attribute name="content" select="concat($front-end-path, '/favicon/browserconfig.xml')"/>
                </meta>
                <meta name="theme-color" content="#ffffff"/>
                
                <meta property="og:url">
                    <xsl:attribute name="content" select="$page-url"/>
                </meta>
                <meta property="og:title">
                    <xsl:attribute name="content" select="$page-title"/>
                </meta>
                <meta property="og:description">
                    <xsl:attribute name="content" select="$page-description"/>
                </meta>
                <meta property="og:image">
                    <xsl:attribute name="content" select="concat($front-end-path, '/imgs/logo-stacked-sq.jpg')"/>
                </meta>
                <meta property="og:image:width" content="300"/>
                <meta property="og:image:height" content="300"/>
                <meta property="og:site_name" content="84000 Translating The Words of The Budda"/>
                <meta name="twitter:card" content="summary"/>
                <meta name="twitter:image:alt" content="84000 Translating The Words of The Budda Logo"/>
                <meta name="twitter:site" content="@Translate84000"/>
                
                <!--[if lt IE 9]>
                    <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
                    <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
                <![endif]-->
                
                <script>
                    <xsl:attribute name="src" select="concat($front-end-path, '/js/84000-fe.min.js', $app-version-url-attribute)"/>
                </script>
                
                <xsl:if test="$view-mode[@annotation eq 'web']">
                    <!-- <script type="application/json" class="js-hypothesis-config">{"theme": "clean"}</script> -->
                    <script src="https://hypothes.is/embed.js" async="async"/>
                </xsl:if>
                
            </xsl:if>
        
        </head>
        
    </xsl:template>
    
    <!-- html footer -->
    <xsl:template name="html-footer">
        
        <xsl:param name="front-end-path" required="yes" as="xs:string"/>
        <xsl:param name="ga-tracking-id" required="no" as="xs:string?"/>
        <xsl:param name="text-id" required="no" as="xs:string?"/>
        
        <!-- Shared footer -->
        <xsl:apply-templates select="$eft-footer"/>
        
        <!-- Don't add js in static mode -->
        <xsl:if test="not($view-mode) or $view-mode[@client eq 'browser']">
            <xsl:if test="$ga-tracking-id and not($ga-tracking-id eq '')">
                <!-- Global site tag (gtag.js) - Google Analytics -->
                <script async="async">
                    <xsl:attribute name="src" select="concat('https://www.googletagmanager.com/gtag/js?id=', $ga-tracking-id)"/>
                </script>
                <script>
                    window.dataLayer = window.dataLayer || [];
                    function gtag(){dataLayer.push(arguments);}
                    gtag('js', new Date());
                    gtag('config', '<xsl:value-of select="$ga-tracking-id"/>' <xsl:if test="$text-id and not($text-id eq '')">, { 'text_id': '<xsl:value-of select="$text-id"/>' }</xsl:if>);
                </script>
            </xsl:if>
        </xsl:if>
        
    </xsl:template>
    
    <!-- Website page -->
    <xsl:template name="website-page">
        
        <xsl:param name="page-url" required="yes" as="xs:string"/>
        <xsl:param name="page-class" required="yes" as="xs:string"/>
        <xsl:param name="page-title" required="yes" as="xs:string"/>
        <xsl:param name="page-description" required="yes" as="xs:string"/>
        <xsl:param name="content" required="no" as="node()*"/>
        <xsl:param name="additional-links" required="no" as="node()*"/>
        
        <html>
            
            <xsl:attribute name="lang" select="$lang"/>
            
            <!-- Get the common <head> -->
            <xsl:call-template name="html-head">
                <xsl:with-param name="front-end-path" select="$front-end-path"/>
                <xsl:with-param name="page-url" select="$page-url"/>
                <xsl:with-param name="page-title" select="$page-title"/>
                <xsl:with-param name="page-description" select="$page-description"/>
                <xsl:with-param name="page-type" select="'communications'"/>
                <xsl:with-param name="additional-links" select="$additional-links"/>
            </xsl:call-template>
            
            <body id="top">
                
                <xsl:attribute name="class">
                    <xsl:value-of select="$page-class"/>
                    <xsl:if test="$view-mode[@id]">
                        <xsl:value-of select="concat(' ', $view-mode/@id, '-mode')"/>
                    </xsl:if>
                </xsl:attribute>
                
                <!-- Environment alert -->
                <xsl:if test="$environment/m:label/text()">
                    <div class="environment-warning">
                        <xsl:value-of select="$environment/m:label/text()"/> / <xsl:value-of select="@user-name"/> / <xsl:value-of select="$app-version"/> / <xsl:value-of select="@exist-version"/>
                    </div>
                </xsl:if>
                
                <!-- Alert -->
                <aside id="page-alert" class="fixed-footer fix-height collapse">
                    <div class="container"/>
                </aside>
                
                <!-- Shared header -->
                <xsl:apply-templates select="$eft-header"/>
                
                <!-- Content -->
                <xsl:sequence select="$content"/>
                
                <!-- Get the common <footer> -->
                <xsl:call-template name="html-footer">
                    <xsl:with-param name="front-end-path" select="$front-end-path"/>
                    <xsl:with-param name="ga-tracking-id" select="$ga-tracking-id"/>
                </xsl:call-template>
                
            </body>
        </html>
        
    </xsl:template>
    
    <!-- Reading Room page -->
    <xsl:template name="reading-room-page">
        
        <xsl:param name="page-url" required="yes" as="xs:string"/>
        <xsl:param name="page-class" required="yes" as="xs:string"/>
        <xsl:param name="page-title" required="yes" as="xs:string"/>
        <xsl:param name="page-description" required="yes" as="xs:string"/>
        <xsl:param name="content" required="no" as="node()*"/>
        <xsl:param name="additional-links" required="no" as="node()*"/>
        <xsl:param name="text-id" required="no" as="xs:string?"/>
        
        <html>
            
            <xsl:attribute name="lang" select="$lang"/>
            
            <!-- Get the common <head> -->
            <xsl:call-template name="html-head">
                <xsl:with-param name="front-end-path" select="$front-end-path"/>
                <xsl:with-param name="page-url" select="$page-url"/>
                <xsl:with-param name="page-title" select="$page-title"/>
                <xsl:with-param name="page-description" select="$page-description"/>
                <xsl:with-param name="page-type" select="if(contains($page-class, 'utilities')) then 'utilities' else 'reading-room'"/>
                <xsl:with-param name="additional-links" select="$additional-links"/>
            </xsl:call-template>
            
            <body id="top">
                
                <xsl:attribute name="class" select="string-join(($page-class, $view-mode/@id ! concat(.,'-mode')), ' ')"/>
                
                <!-- Environment alert -->
                <xsl:if test="$environment/m:label/text()">
                    <div class="environment-warning">
                        <xsl:value-of select="$environment/m:label/text()"/> / <xsl:value-of select="@user-name"/> / <xsl:value-of select="$app-version"/> / <xsl:value-of select="@exist-version"/>
                    </div>
                </xsl:if>
                
                <!-- Alert -->
                <aside id="page-alert" class="fixed-footer fix-height collapse">
                    <div class="container"/>
                </aside>
                
                <!-- Place content -->
                <xsl:sequence select="$content"/>
                
                <!-- Get the common <footer> -->
                <xsl:call-template name="html-footer">
                    <xsl:with-param name="front-end-path" select="$front-end-path"/>
                    <xsl:with-param name="ga-tracking-id" select="$ga-tracking-id"/>
                    <xsl:with-param name="text-id" select="$text-id"/>
                </xsl:call-template>
                
            </body>
        </html>
        
    </xsl:template>
    
    <!-- Widget page -->
    <xsl:template name="widget-page">
        
        <xsl:param name="page-url" required="yes" as="xs:string"/>
        <xsl:param name="page-class" required="yes" as="xs:string"/>
        <xsl:param name="page-title" required="yes" as="xs:string"/>
        <xsl:param name="page-description" required="yes" as="xs:string"/>
        <xsl:param name="content" required="no" as="node()*"/>
        <xsl:param name="additional-links" required="no" as="node()*"/>
        
        <html>
            
            <xsl:attribute name="lang" select="$lang"/>
            
            <!-- Get the common <head> -->
            <xsl:call-template name="html-head">
                <xsl:with-param name="front-end-path" select="$front-end-path"/>
                <xsl:with-param name="page-url" select="$page-url"/>
                <xsl:with-param name="page-title" select="$page-title"/>
                <xsl:with-param name="page-description" select="$page-description"/>
                <xsl:with-param name="page-type" select="'communications'"/>
                <xsl:with-param name="additional-links" select="$additional-links"/>
            </xsl:call-template>
            
            <body id="top">
                
                <xsl:attribute name="class" select="$page-class"/>
                
                <!-- Place content -->
                <xsl:copy-of select="$content"/>
                
            </body>
        </html>
        
    </xsl:template>
    
    <!-- Pop-up for tei-editor -->
    <xsl:template name="tei-editor-footer">
        
        <div id="popup-footer-editor" class="fixed-footer collapse persist hidden-print">
            <div class="fix-height">
                <div class="container">
                    <div class="data-container">
                        <!-- Ajax data here -->
                    </div>
                </div>
            </div>
            <div class="fixed-btn-container close-btn-container">
                <div class="center-vertical">
                    <div>
                        <!-- Set footer height -->
                        <button type="button" class="btn-round orange" data-drag-height="#popup-footer-editor .fix-height" aria-label="Set the height of the footer" title="Set the height of the footer">
                            <span aria-hidden="true">
                                <i class="fa fa-sort"/>
                            </span>
                        </button>
                    </div>
                    <div>
                        <!-- Close -->
                        <button type="button" class="btn-round orange close close-collapse" title="Close" aria-label="Close">
                            <span aria-hidden="true">
                                <i class="fa fa-times"/>
                            </span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
        
    </xsl:template>
    
    <!-- Check nodes have more that default text -->
    <xsl:function name="m:has-user-content" as="xs:boolean">
        <xsl:param name="content" as="node()*"/>
        <xsl:sequence select="if($view-mode[@id eq 'editor'] or $content/descendant-or-self::text()[normalize-space(.)][not(ancestor::tei:head)][not(ancestor::*/@rend = 'default-text')]) then true() else false()"/>
    </xsl:function>
    
</xsl:stylesheet>