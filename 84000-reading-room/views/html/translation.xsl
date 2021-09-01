<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/tei-to-xhtml.xsl"/>

    <!-- Look up environment variables -->
    <xsl:variable name="front-end-path" select="$environment/m:url[@id eq 'front-end']/text()"/>
    <xsl:variable name="render-status" select="$environment/m:render/m:status[@type eq 'translation']/@status-id"/>
    
    <xsl:variable name="page-title" as="node()*">
        <xsl:sequence select="/m:response/m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
        <xsl:sequence select="/m:response/m:translation//m:part[@prefix][@render eq 'show'][1]/tei:head[@type eq parent::m:part/@type]"/>
    </xsl:variable>
    
    <xsl:template match="/m:response">
        
        <!-- PAGE CONTENT -->
        <xsl:variable name="content">
            
            <!-- Un-published alert -->
            <xsl:if test="not(m:translation/@status-group eq 'published')">
                <div class="title-band warning">
                    <div class="container">
                        <div class="center-vertical center-aligned">
                            <div>
                                <xsl:value-of select="'This text is not yet ready for publication!'"/>
                            </div>
                        </div>                        
                    </div>
                </div>
            </xsl:if>
            
            <!-- Breadcrumbs -->
            <xsl:if test="m:translation[m:parent]">
                <div class="title-band hidden-print">
                    <div class="container">
                        <div class="center-vertical center-aligned text-center">
                            <nav role="navigation" aria-label="Breadcrumbs">
                                <ul id="outline" class="breadcrumb">
                                    <xsl:sequence select="common:breadcrumb-items(m:translation/m:parent/descendant-or-self::m:parent, /m:response/@lang)"/>
                                </ul>
                            </nav>
                        </div>
                    </div>
                </div>
            </xsl:if>
            
            <!-- Main article -->
            <main class="content-band">
                <div class="container">
                    <div class="row">
                        <div class="col-md-offset-1 col-md-10 col-lg-offset-2 col-lg-8 print-width-override">

                            <xsl:if test="$view-mode[not(@layout eq 'part-only')] or $requested-part = ('all', 'front')">
                                
                                <!-- Front matter -->
                                <xsl:call-template name="front-matter"/>
                                
                                <!-- Table of Contents -->
                                <xsl:if test="m:translation/@status = $render-status">
                                    <xsl:call-template name="table-of-contents"/>
                                </xsl:if>
                                
                            </xsl:if>
                            
                            <!-- Summary -->
                            <xsl:call-template name="part">
                                <xsl:with-param name="part" select="m:translation/m:part[@type eq 'summary']"/>
                                <xsl:with-param name="css-classes" select="'page text'"/>
                            </xsl:call-template>
                        
                            <xsl:if test="m:translation/@status = $render-status">
                            
                                <!-- Acknowledgment -->
                                <xsl:call-template name="part">
                                    <xsl:with-param name="part" select="m:translation/m:part[@type eq 'acknowledgment']"/>
                                    <xsl:with-param name="css-classes" select="'page text'"/>
                                </xsl:call-template>
                                
                                <!-- Preface -->
                                <xsl:call-template name="part">
                                    <xsl:with-param name="part" select="m:translation/m:part[@type eq 'preface']"/>
                                    <xsl:with-param name="css-classes" select="'page text'"/>
                                </xsl:call-template>
                                
                                <!-- Introduction -->
                                <xsl:call-template name="part">
                                    <xsl:with-param name="part" select="m:translation/m:part[@type eq 'introduction']"/>
                                    <xsl:with-param name="css-classes" select="'page text'"/>
                                </xsl:call-template>
    
                                <!-- Main title -->
                                <xsl:call-template name="body-title"/>
                                
                                <!-- The Chapters -->
                                <xsl:for-each select="m:translation/m:part[@type eq 'translation']/m:part">
                                    <xsl:call-template name="part">
                                        <xsl:with-param name="part" select="."/>
                                        <xsl:with-param name="css-classes" select="'text page'"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                                
                                <!-- Appendix -->
                                <xsl:call-template name="part">
                                    <xsl:with-param name="part" select="m:translation/m:part[@type eq 'appendix']"/>
                                    <xsl:with-param name="css-classes" select="'page text'"/>
                                </xsl:call-template>
                                
                                <!-- Abbreviations -->
                                <xsl:call-template name="part">
                                    <xsl:with-param name="part" select="m:translation/m:part[@type eq 'abbreviations']"/>
                                    <xsl:with-param name="css-classes" select="'page'"/>
                                </xsl:call-template>
                                
                                <!-- Notes -->
                                <xsl:call-template name="part">
                                    <xsl:with-param name="part" select="m:translation/m:part[@type eq 'end-notes']"/>
                                    <xsl:with-param name="css-classes" select="'page'"/>
                                </xsl:call-template>
                                
                                <!-- Bilbiography -->
                                <xsl:call-template name="part">
                                    <xsl:with-param name="part" select="m:translation/m:part[@type eq 'bibliography']"/>
                                    <xsl:with-param name="css-classes" select="'page'"/>
                                </xsl:call-template>
                                
                                <!-- Glossary -->
                                <xsl:call-template name="part">
                                    <xsl:with-param name="part" select="m:translation/m:part[@type eq 'glossary']"/>
                                    <xsl:with-param name="css-classes" select="'page'"/>
                                </xsl:call-template>
                                
                            </xsl:if>
                        
                        </div>
                    </div>
                    
                </div>
            </main>
            
            <xsl:if test="$view-mode[@client eq 'browser'][not(@layout eq 'part-only')]">
                
                <!-- Navigation controls -->
                <nav class="nav-controls show-on-scroll-xs hidden-print" aria-label="Navigation icons">
                    
                    <div id="navigation-btn-container" class="fixed-btn-container">
                        <a href="#contents-sidebar" class="btn-round show-sidebar" aria-haspopup="true" title="Show the side navigation panel">
                            <i class="fa fa-bars" aria-hidden="true"/>
                        </a>
                    </div>
                    
                    <div id="bookmarks-btn-container" class="fixed-btn-container">
                        <a href="#bookmarks-sidebar" id="bookmarks-btn" class="btn-round show-sidebar" aria-haspopup="true" title="Show the bookmarks panel">
                            <i class="fa fa-bookmark"/>
                            <span class="badge badge-notification">0</span>
                        </a>
                    </div>
                    
                    <div id="link-to-trans-top-container" class="fixed-btn-container">
                        
                        <!-- Link to the start of the section / defaults to the start of the page -->
                        <a class="btn-round scroll-to-anchor link-to-top" title="Go to the top of the page">
                            <xsl:attribute name="href" select="'#top'"/>
                            <i class="fa fa-arrow-up" aria-hidden="true"/>
                        </a>
                        
                    </div>
                    
                    <div id="rewind-btn-container" class="fixed-btn-container hidden">
                        <button class="btn-round" title="Return to the last location">
                            <i class="fa fa-undo" aria-hidden="true"/>
                        </button>
                    </div>
                    
                </nav>
                
                <!-- General pop-up for notes and glossary -->
                <div id="popup-footer" class="fixed-footer collapse hidden-print">
                    <div class="fix-height">
                        <div class="container">
                            <div class="row">
                                <div class="col-md-offset-1 col-md-10 col-lg-offset-2 col-lg-8">
                                    <div class="data-container tei-parser">
                                        <!-- Ajax data here -->
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="fixed-btn-container close-btn-container">
                        <button type="button" class="btn-round close close-collapse" aria-label="Close">
                            <span aria-hidden="true">
                                <i class="fa fa-times"/>
                            </span>
                        </button>
                    </div>
                </div>
                
                <!-- Source pop-up -->
                <div id="popup-footer-source" class="fixed-footer collapse hidden-print">
                    <div class="fix-height">
                        <div class="data-container">
                            <!-- Ajax data here -->
                            <div class="ajax-target"/>
                        </div>
                    </div>
                    <div class="fixed-btn-container close-btn-container">
                        <button type="button" class="btn-round close close-collapse" aria-label="Close">
                            <span aria-hidden="true">
                                <i class="fa fa-times"/>
                            </span>
                        </button>
                    </div>
                </div>
                
                <!-- Contents fly-out -->
                <div id="contents-sidebar" class="fixed-sidebar collapse width hidden-print">
                    
                    <div class="fix-width">
                        <div class="sidebar-content">
                            
                            <h4>
                                <xsl:value-of select="'Contents'"/>
                            </h4>
                            
                            <div class="data-container bottom-margin"/>
                            
                            <h4>
                                <xsl:value-of select="'Search this translation'"/>
                            </h4>
                            
                            <form action="/search.html" method="post" role="search" class="form-horizontal bottom-margin">
                                <input type="hidden" name="resource-id" value="{ m:translation/@id }"/>
                                <div class="input-group">
                                    <input type="search" name="search" id="search" class="form-control" placeholder="Search" required="required" aria-label="Search text" value=""/>
                                    <span class="input-group-btn">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fa fa-search"/>
                                        </button>
                                    </span>
                                </div>
                            </form>
                            
                            <xsl:if test="m:translation/@status = $render-status">
                                <h4>
                                    <xsl:value-of select="'Download Options'"/>
                                </h4>
                                <table class="contents-table bottom-margin">
                                    <tbody>
                                        <xsl:if test="$part-status eq 'complete'">
                                            <tr>
                                                <td>
                                                    <a target="_blank" class="print-preview">
                                                        <xsl:attribute name="title" select="'Print'"/>
                                                        <xsl:attribute name="href" select="'#'"/>
                                                        <i class="fa fa-laptop"/>
                                                    </a>
                                                </td>
                                                <td>
                                                    <a href="#" title="Print" class="print-preview">
                                                        <xsl:value-of select="'Print'"/>
                                                    </a>
                                                </td>
                                            </tr>
                                        </xsl:if>
                                        <xsl:for-each select="m:translation/m:downloads/m:download[@type = ('pdf', 'epub', 'azw3')]">
                                            <tr>
                                                <td>
                                                    <a target="_blank">
                                                        <xsl:attribute name="title">
                                                            <xsl:call-template name="download-label">
                                                                <xsl:with-param name="type" select="@type"/>
                                                            </xsl:call-template>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="href" select="@download-url"/>
                                                        <xsl:attribute name="download" select="@filename"/>
                                                        <xsl:attribute name="class" select="'log-click'"/>
                                                        <xsl:attribute name="data-page-alert" select="common:internal-link('/widget/download-dana.html', concat('resource-id=', $toh-key), '#dana-description', /m:response/@lang)"/>
                                                        <xsl:call-template name="download-icon">
                                                            <xsl:with-param name="type" select="@type"/>
                                                        </xsl:call-template>
                                                    </a>
                                                </td>
                                                <td>
                                                    <a target="_blank">
                                                        <xsl:attribute name="title">
                                                            <xsl:call-template name="download-label">
                                                                <xsl:with-param name="type" select="@type"/>
                                                            </xsl:call-template>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="href" select="@download-url"/>
                                                        <xsl:attribute name="download" select="@filename"/>
                                                        <xsl:attribute name="class" select="'log-click'"/>
                                                        <xsl:attribute name="data-page-alert" select="common:internal-link('/widget/download-dana.html', concat('resource-id=', $toh-key), '#dana-description', /m:response/@lang)"/>
                                                        <xsl:call-template name="download-label">
                                                            <xsl:with-param name="type" select="@type"/>
                                                        </xsl:call-template>
                                                    </a>
                                                </td>
                                            </tr>
                                        </xsl:for-each>
                                    </tbody>
                                </table>
                            </xsl:if>
                            
                            <h4>
                                <xsl:value-of select="'Other Links'"/>
                            </h4>
                            
                            <table class="contents-table bottom-margin">
                                <tbody>
                                    <tr>
                                        <td>
                                            <a>
                                                <xsl:attribute name="href" select="common:homepage-link('', /m:response/@lang)"/>
                                                <i class="fa fa-home"/>
                                            </a>
                                        </td>
                                        <td>
                                            <a>
                                                <xsl:attribute name="href" select="common:homepage-link('', /m:response/@lang)"/>
                                                <xsl:value-of select="'84000 Homepage'"/>
                                            </a>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <a>
                                                <xsl:attribute name="href" select="common:internal-link('/', (), '', /m:response/@lang)"/>
                                                <i class="fa fa-bookmark"/>
                                            </a>
                                        </td>
                                        <td>
                                            <a>
                                                <xsl:attribute name="href" select="common:internal-link('/', (), '', /m:response/@lang)"/>
                                                <xsl:value-of select="'Reading Room Lobby'"/>
                                            </a>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <a>
                                                <xsl:attribute name="href" select="common:internal-link('/section/all-translated.html', (), '', /m:response/@lang)"/>
                                                <i class="fa fa-list"/>
                                            </a>
                                        </td>
                                        <td>
                                            <a>
                                                <xsl:attribute name="href" select="common:internal-link('/section/all-translated.html', (), '', /m:response/@lang)"/>
                                                <xsl:value-of select="'Published Translations'"/>
                                            </a>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <a>
                                                <xsl:attribute name="href" select="common:internal-link('/search.html', (), '', /m:response/@lang)"/>
                                                <i class="fa fa-search"/>
                                            </a>
                                        </td>
                                        <td>
                                            <a href="/search.html">
                                                <xsl:attribute name="href" select="common:internal-link('/search.html', (), '', /m:response/@lang)"/>
                                                <xsl:value-of select="'Search the Reading Room'"/>
                                            </a>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <a>
                                                <xsl:attribute name="href" select="common:homepage-link('sponsors', /m:response/@lang)"/>
                                                <i class="fa fa-heart"/>
                                            </a>
                                        </td>
                                        <td>
                                            <a href="/search.html">
                                                <xsl:attribute name="href" select="common:homepage-link('sponsors',/m:response/@lang)"/>
                                                <xsl:value-of select="'Our Sponsors'"/>
                                            </a>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                            
                            <a href="http://84000.co/how-you-can-help/donate/#sap" class="btn btn-primary btn-uppercase">
                                <xsl:copy-of select="common:override-href(/m:response/@lang, 'zh', 'http://84000.co/ch-howhelp/donate')"/>
                                <xsl:value-of select="'Sponsor Translation'"/>
                            </a>
                            
                        </div>
                    </div>
                    
                    <div class="fixed-btn-container close-btn-container right">
                        <button type="button" class="btn-round close close-collapse" aria-label="Close">
                            <span aria-hidden="true">
                                <i class="fa fa-times"/>
                            </span>
                        </button>
                    </div>
                    
                </div>
                
                <!-- Include the bookmarks sidebar -->
                <xsl:variable name="bookmarks-sidebar">
                    <m:bookmarks-sidebar>
                        <xsl:copy-of select="$eft-header/m:translation"/>
                    </m:bookmarks-sidebar>
                </xsl:variable>
                <xsl:apply-templates select="$bookmarks-sidebar"/>
                
            </xsl:if>
        
        </xsl:variable>
 
        <!-- Pass the content to the page -->
        <xsl:call-template name="reading-room-page">
            
            <xsl:with-param name="page-url" select="(m:translation/@canonical-html, '')[1]"/>
            <xsl:with-param name="page-class">
                <xsl:value-of select="'reading-room'"/>
                <xsl:value-of select="' translation'"/>
                <xsl:value-of select="concat(' ', $part-status)"/>
                <xsl:if test="$part-status eq 'part' and m:request[@part gt '']">
                    <xsl:value-of select="concat(' part-', m:request/@part)"/>
                </xsl:if>
            </xsl:with-param>
            <xsl:with-param name="page-title" select="string-join(($page-title/data(), '84000 Reading Room'), ' | ')"/>
            <xsl:with-param name="page-description" select="normalize-space(data(m:translation/m:part[@type eq 'summary']/tei:p[1]))"/>
            <xsl:with-param name="content" select="$content"/>
            <xsl:with-param name="additional-links">
                
                <!-- Add OPDS auto-discovery links for other formats -->
                <xsl:for-each select="m:translation/m:downloads/m:download[@type = ('epub', 'azw3', 'pdf')]">
                    <link rel="alternate">
                        <xsl:attribute name="href" select="@url"/>
                        <xsl:choose>
                            <xsl:when test="@type eq 'epub'">
                                <xsl:attribute name="type" select="'application/epub+zip'"/>
                            </xsl:when>
                            <xsl:when test="@type eq 'azw3'">
                                <xsl:attribute name="type" select="'application/vnd.amazon.mobi8-ebook'"/>
                            </xsl:when>
                            <xsl:when test="@type eq 'pdf'">
                                <xsl:attribute name="type" select="'application/pdf'"/>
                            </xsl:when>
                        </xsl:choose>
                    </link>
                </xsl:for-each>
                
                <!-- Add OPDS auto-discovery links for atom feeds -->
                <link rel="related" type="application/atom+xml;profile=opds-catalog;kind=navigation" href="/section/lobby.navigation.atom" title="The 84000 Reading Room"/>
                <link rel="related" type="application/atom+xml;profile=opds-catalog;kind=acquisition" href="/section/all-translated.acquisition.atom" title="84000: All Translated Texts"/>
                
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="part">
        
        <xsl:param name="part" as="node()*"/>
        <xsl:param name="css-classes" as="xs:string" select="''"/>
        
        <!-- 'hide' allows the inclusion of content in the xml structure without outputting -->
        <xsl:if test="$part[@render = ('persist', 'show', 'collapse', 'preview', 'passage')]">
            <section>
                
                <xsl:attribute name="id" select="$part/@id"/>
                
                <xsl:call-template name="class-attribute">
                    
                    <xsl:with-param name="base-classes" as="xs:string*">
                        
                        <xsl:value-of select="concat('part-type-', $part/@type)"/>
                        <xsl:value-of select="$css-classes"/>
                        <xsl:value-of select="'tei-parser'"/>
                        
                    </xsl:with-param>
                    
                    <xsl:with-param name="html-classes">
                        
                        <xsl:choose>
                            <xsl:when test="$part[@render eq 'collapse'] and $view-mode[@layout = ('expanded', 'expanded-fixed')]">
                                <!-- .show displays content expanded -->
                                <xsl:value-of select="'show'"/>
                            </xsl:when>
                            <xsl:when test="$part[@render eq 'preview']">
                                <!-- .preview displays content collapsed -->
                                <!-- .partial indicates that it is incomplete -->
                                <xsl:value-of select="'preview partial'"/>
                            </xsl:when>
                            <xsl:when test="$part[@render eq 'collapse']">
                                <!-- .preview displays content collapsed -->
                                <xsl:value-of select="'preview'"/>
                            </xsl:when>
                            <xsl:when test="$part[@render eq 'part-only']">
                                <!-- .hidden hides content -->
                                <xsl:value-of select="'hidden'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- .show displays content expanded -->
                                <xsl:value-of select="'show'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </xsl:with-param>
                    
                </xsl:call-template>
                
                <hr class="hidden-print"/>
                
                <!-- The content -->
                <xsl:choose>
                    
                    <xsl:when test="$part[@type eq 'end-notes']">
                        <xsl:call-template name="end-notes"/>
                    </xsl:when>
                    
                    <xsl:when test="$part[@type eq 'glossary']">
                        <xsl:call-template name="glossary"/>
                    </xsl:when>
                    
                    <xsl:otherwise>
                        <xsl:apply-templates select="$part/m:* | $part/tei:*"/>
                    </xsl:otherwise>
                    
                </xsl:choose>
                
                <!-- Add controls to expand / collapse -->
                <xsl:if test="$part[@render = ('show', 'collapse', 'preview')] and $view-mode[not(@layout = ('expanded-fixed'))]">
                    
                    <xsl:call-template name="preview-controls">
                        
                        <xsl:with-param name="section-id" select="$part/@id"/>
                        <xsl:with-param name="log-click" select="true()"/>
                        
                        <!-- Provide complete navigation links so they will be followed by crawlers and right-click works -->
                        <xsl:with-param name="get-url">
                            <xsl:if test="$part[@render eq 'preview']">
                                <xsl:value-of select="concat('?part=', $part/@id, m:view-mode-parameter(()), m:archive-path-parameter(), '#', $part/@id)"/>
                            </xsl:if>
                        </xsl:with-param>
                        
                    </xsl:call-template>
                    
                </xsl:if>
                
            </section>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template name="front-matter">
        
        <section id="titles">
            
            <!-- Include an additional page warning about incompleteness of rendering -->
            <xsl:if test="count($page-title) gt 1 or not($part-status eq 'complete')">
                <div class="page">
                    
                    <!-- h1 should reflect that it's a part -->
                    <xsl:if test="count($page-title) gt 1">
                        <h1 class="h2 text-center top-margin">
                            <xsl:for-each select="$page-title">
                                <xsl:choose>
                                    <xsl:when test="self::m:title">
                                        <small>
                                            <xsl:value-of select="."/>
                                        </small>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <br/>
                                        <span class="dot-parenth">
                                            <xsl:value-of select="' '"/>
                                            <xsl:value-of select="."/>
                                            <xsl:value-of select="' '"/>
                                        </span>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </h1>
                    </xsl:if>
                    
                    <!-- Warn the user not to print a partial view -->
                    <xsl:if test="not($part-status eq 'complete')">
                        <div class="visible-print-block">
                            
                            <div class="well text-center top-margin hidden-pdf">
                                
                                <p class="uppercase">
                                    <xsl:call-template name="text">
                                        <xsl:with-param name="global-key" select="'translation.partial-text-warning'"/>
                                    </xsl:call-template>
                                </p>
                                
                                <xsl:variable name="pdf-download" select="m:translation/m:downloads/m:download[@type eq 'pdf']"/>
                                <xsl:if test="$pdf-download">
                                    <p>
                                        <xsl:call-template name="text">
                                            <xsl:with-param name="global-key" select="'translation.partial-text-link'"/>
                                        </xsl:call-template>
                                        <br/>
                                        <a target="_blank">
                                            <xsl:attribute name="title">
                                                <xsl:call-template name="download-label">
                                                    <xsl:with-param name="type" select="$pdf-download/@type"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                            <xsl:attribute name="href" select="$pdf-download/@download-url"/>
                                            <xsl:attribute name="download" select="$pdf-download/@filename"/>
                                            <xsl:attribute name="class" select="'log-click'"/>
                                            <xsl:attribute name="data-page-alert" select="common:internal-link('/widget/download-dana.html', concat('resource-id=', $toh-key), '#dana-description', /m:response/@lang)"/>
                                            <xsl:value-of select="concat($reading-room-path, $pdf-download/@download-url)"/>
                                        </a>
                                    </p>
                                </xsl:if>
                                
                            </div>
                            
                        </div>
                    </xsl:if>
                    
                </div>
            </xsl:if>
            
            <xsl:variable name="main-titles" select="m:translation/m:titles/m:title[text()]"/>
            <xsl:variable name="long-titles" select="m:translation/m:long-titles/m:title[text()]"/>
            
            <!-- Main titles -->
            <div class="page">
                
                <div id="main-titles" class="ornamental-panel">
                    
                    <xsl:apply-templates select="$main-titles[@xml:lang eq 'bo']"/>
                    
                    <xsl:element name="{ if(count($page-title) gt 1) then 'div' else 'h1' }">
                        <xsl:attribute name="class" select="'title main-title'"/>
                        <xsl:value-of select="$main-titles[@xml:lang eq 'en']"/>
                    </xsl:element>
                    
                    <xsl:apply-templates select="$main-titles[@xml:lang eq 'Sa-Ltn']"/>
                
                </div>
                
                <xsl:if test="count($long-titles) eq 1 and $long-titles[@xml:lang eq 'Bo-Ltn'][text()]">
                    <div id="long-titles">
                        <xsl:apply-templates select="$long-titles[@xml:lang eq 'Bo-Ltn']"/>
                    </div>
                </xsl:if>
                
            </div>
            
            <!-- Long titles -->
            <xsl:if test="count($long-titles) gt 1">
                <div class="page">
                    
                    <div id="long-titles">
                        <xsl:apply-templates select="$long-titles[@xml:lang eq 'bo']"/>
                        <xsl:apply-templates select="$long-titles[@xml:lang eq 'Bo-Ltn']"/>
                        <xsl:apply-templates select="$long-titles[@xml:lang eq 'en']"/>
                        <xsl:apply-templates select="$long-titles[@xml:lang eq 'Sa-Ltn']"/>
                    </div>
                    
                </div>
            </xsl:if>
            
        </section>
        
        <section id="imprint">
            
            <div class="page page-force">
                
                <xsl:if test="m:translation[m:source]">
                    
                    <img class="logo">
                        <!-- Update to set image in CSS -->
                        <xsl:attribute name="src" select="concat($front-end-path,'/imgs/logo.png')"/>
                        <xsl:attribute name="alt" select="'84000 logo'"/>
                    </img>
                    
                    <div id="toh">
                        <h4>
                            <xsl:apply-templates select="m:translation/m:source/m:toh"/>
                        </h4>
                        <xsl:if test="m:translation/m:source[m:series[text()] or m:scope[text()] or m:range[text()]]">
                            <p id="location">
                                <xsl:value-of select="concat(normalize-space(string-join(m:translation/m:source/m:series/text() | m:translation/m:source/m:scope/text() | m:translation/m:source/m:range/text(), ', ')), '.')"/>
                            </p>
                        </xsl:if>
                    </div>
                    
                </xsl:if>
                
                <xsl:if test="m:translation[m:publication]">
                    
                    <xsl:if test="m:translation/@status = $render-status">
                        <xsl:if test="m:translation/m:publication/m:contributors/m:summary[node()]">
                            <div class="well">
                                <xsl:for-each select="m:translation/m:publication/m:contributors/m:summary">
                                    <p id="authours-summary">
                                        <xsl:apply-templates select="node()"/>
                                    </p>
                                </xsl:for-each>
                            </div>
                        </xsl:if>
                    </xsl:if>
                    
                    <div class="bottom-margin">
                        <p id="edition">
                            <xsl:choose>
                                <xsl:when test="m:translation/m:publication/m:publication-date castable as xs:date">
                                    <xsl:value-of select="concat('First published ', format-date(m:translation/m:publication/m:publication-date, '[Y]'))"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'Not yet published'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <br/>
                            <xsl:choose>
                                <xsl:when test="m:translation/m:publication/m:edition/tei:date[1] gt ''">
                                    <xsl:value-of select="concat('Current version ', m:translation/m:publication/m:edition/text()[1], '(', m:translation/m:publication/m:edition/tei:date[1], ')')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'Invalid version'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <br/>
                            <span class="small">
                                <xsl:value-of select="concat('Generated by 84000 Reading Room v', /m:response/@app-version)"/>
                            </span>
                        </p>
                    </div>
                    
                    <div class="bottom-margin">
                        <p id="publication-statement">
                            <xsl:apply-templates select="m:translation/m:publication/m:publication-statement"/>
                        </p>
                    </div>
                    
                    <xsl:if test="m:translation/m:publication/m:tantric-restriction[tei:p]">
                        <div id="tantric-warning" class="well well-danger">
                            <xsl:for-each select="m:translation/m:publication/m:tantric-restriction/tei:p">
                                <p>
                                    <xsl:apply-templates select="node()"/>
                                </p>
                            </xsl:for-each>
                        </div>
                    </xsl:if>
                    
                    <xsl:if test="m:translation[@status = $render-status]">
                        <div id="license" class="bottom-margin">
                            <img>
                                <!-- Update to set image in CSS -->
                                <xsl:attribute name="src" select="replace(m:translation/m:publication/m:license/@img-url, '^http:', 'https:')"/>
                                <xsl:attribute name="alt" select="'Logo for the license'"/>
                            </img>
                            <xsl:for-each select="m:translation/m:publication/m:license/tei:p">
                                <p class="text-muted small">
                                    <xsl:apply-templates select="node()"/>
                                </p>
                            </xsl:for-each>
                        </div>
                    </xsl:if>
                    
                </xsl:if>
                
                <!-- Additional front-matter -->
                <xsl:if test="m:translation[@status = $render-status]/m:downloads[m:download[@type = ('pdf', 'epub', 'azw3')]]">
                    
                    <!-- Download options -->
                    <nav class="download-options hidden-print text-center bottom-margin" aria-label="download-options-header">
                        
                        <header id="download-options-header">
                            <xsl:value-of select="'Options for downloading this publication'"/>
                        </header>
                        
                        <xsl:for-each select="m:translation/m:downloads/m:download[@type = ('pdf', 'epub', 'azw3')]">
                            <a target="_blank">
                                <xsl:attribute name="title">
                                    <xsl:call-template name="download-label">
                                        <xsl:with-param name="type" select="@type"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                                <xsl:attribute name="href" select="@download-url"/>
                                <xsl:attribute name="download" select="@filename"/>
                                <xsl:attribute name="class" select="'btn-round log-click'"/>
                                <xsl:if test="@type = ('pdf', 'epub', 'azw3')">
                                    <xsl:attribute name="data-page-alert" select="common:internal-link('/widget/download-dana.html', concat('resource-id=', $toh-key), '#dana-description', /m:response/@lang)"/>
                                </xsl:if>
                                <xsl:call-template name="download-icon">
                                    <xsl:with-param name="type" select="@type"/>
                                </xsl:call-template>
                            </a>
                        </xsl:for-each>
                        
                        <!--<a href="#" class="btn-round print-preview" title="Print">
                            <i class="fa fa-print"/>
                        </a>-->
                        
                    </nav>
                    
                    <!-- Print statement -->
                    <aside id="print-version" class="visible-print-block text-center page page-force">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'print-version'"/>
                        </xsl:call-template>
                    </aside>
                    
                </xsl:if>
                
            </div>
            
        </section>
        
    </xsl:template>
    
    <xsl:template name="body-title">
        
        <xsl:if test="m:translation/m:part[@type eq 'translation']">
            <section id="body-title">
                
                <xsl:call-template name="class-attribute">
                    <xsl:with-param name="html-classes" as="xs:string*">
                        <xsl:value-of select="'part-type-translation'"/>
                        <xsl:if test="$view-mode[not(@parts = ('part', 'passage'))] or $requested-part = ('all', 'body', 'body-title')">
                            <xsl:value-of select="'page'"/>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
                
                <hr class="hidden-print"/>
                
                <div class="rw rw-section-head">
                    
                    <xsl:attribute name="id" select="m:translation/m:part[@type eq 'translation']/@id"/>
                    
                    <div class="rw-heading heading-section chapter">
                        
                        <xsl:if test="count(m:translation/m:part[@type eq 'translation']/m:part[@type = ('section', 'chapter')]) gt 1">
                            <div class="h3">
                                <xsl:value-of select="'The Translation'"/>
                            </div>
                        </xsl:if>
                        
                        <xsl:if test="m:translation/m:part[@type eq 'translation']/m:honoration[text()]">
                            <div class="h2">
                                <xsl:apply-templates select="m:translation/m:part[@type eq 'translation']/m:honoration"/>
                            </div>
                        </xsl:if>
                        
                        <xsl:if test="m:translation/m:part[@type eq 'translation']/m:main-title[text()]">
                            <div class="h1">
                                <xsl:apply-templates select="m:translation/m:part[@type eq 'translation']/m:main-title"/>
                                <xsl:if test="m:translation/m:part[@type eq 'translation']/m:sub-title[text()]">
                                    <br/>
                                    <small>
                                        <xsl:apply-templates select="m:translation/m:part[@type eq 'translation']/m:sub-title"/>
                                    </small>
                                </xsl:if>
                            </div>
                        </xsl:if>
                        
                    </div>
                    
                </div>
                
            </section>
        </xsl:if>
        
    </xsl:template>
    
</xsl:stylesheet>