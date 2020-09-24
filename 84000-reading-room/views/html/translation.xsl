<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:import href="../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="../../xslt/lang.xsl"/>
    <xsl:import href="website-page.xsl"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
    <xsl:variable name="front-end-path" select="$environment/m:url[@id eq 'front-end']/text()"/>
    <xsl:variable name="render-status" select="$environment/m:render-translation/m:status/@status-id"/>
    
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
            <div class="title-band hidden-print">
                <div class="container">
                    <div class="center-vertical center-aligned text-center">
                        <div>
                            <ul id="outline" class="breadcrumb">
                                <xsl:copy-of select="common:breadcrumb-items(m:translation/m:parent | m:translation/m:parent//m:parent, /m:response/@lang)"/>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Main article -->
            <article class="content-band">
                <div class="container">
                    <div class="row">
                        <div class="col-md-offset-1 col-md-10 col-lg-offset-2 col-lg-8 print-width-override">

                            <!-- Front-matter -->
                            <section id="front-matter">
                                <xsl:call-template name="front-matter">
                                    <xsl:with-param name="translation" select="m:translation"/>
                                </xsl:call-template>
                            </section>
                            
                            <!-- Additional front-matter -->
                            <xsl:if test="m:translation/@status = $render-status">
                                
                                <!-- Download options -->
                                <aside class="download-options hidden-print text-center">
                                    <xsl:call-template name="download-options">
                                        <xsl:with-param name="translation" select="m:translation"/>
                                    </xsl:call-template>
                                </aside>
                                
                                <!-- Print statement -->
                                <aside id="print-version" class="visible-print-block text-center page">
                                    <xsl:call-template name="local-text">
                                        <xsl:with-param name="local-key" select="'print-version'"/>
                                    </xsl:call-template>
                                </aside>

                            </xsl:if>
                            
                            <!-- Table of Contents -->
                            <xsl:if test="m:translation[m:toc]">
                                <hr class="hidden-print"/>
                                <aside id="contents" class="page">
                                    <xsl:apply-templates select="m:translation/m:toc"/>
                                </aside>
                            </xsl:if>
                            
                            <!-- Summary -->
                            <xsl:call-template name="section">
                                <xsl:with-param name="section" select="m:translation/m:section[@type eq 'summary']"/>
                                <xsl:with-param name="css-classes" select="'page text glossarize-section'"/>
                            </xsl:call-template>
                        
                            <!-- Acknowledgment -->
                            <xsl:call-template name="section">
                                <xsl:with-param name="section" select="m:translation/m:section[@type eq 'acknowledgment']"/>
                                <xsl:with-param name="css-classes" select="'text'"/>
                            </xsl:call-template>
                            
                            <!-- Preface -->
                            <xsl:call-template name="section">
                                <xsl:with-param name="section" select="m:translation/m:section[@type eq 'preface']"/>
                                <xsl:with-param name="css-classes" select="'page text'"/>
                                <xsl:with-param name="render-in-viewport" select="true()"/>
                            </xsl:call-template>
                            
                            <!-- Introduction -->
                            <xsl:call-template name="section">
                                <xsl:with-param name="section" select="m:translation/m:section[@type eq 'introduction']"/>
                                <xsl:with-param name="css-classes" select="'page text glossarize-section'"/>
                                <xsl:with-param name="render-in-viewport" select="true()"/>
                            </xsl:call-template>

                            <!-- Main title -->
                            <section id="translation" class="page">
                                
                                <hr class="hidden-print"/>
                                
                                <xsl:call-template name="body-title">
                                    <xsl:with-param name="section" select="m:translation/m:section[@type eq 'translation']"/>
                                </xsl:call-template>
                                
                            </section>
                            
                            <!-- The Chapters -->
                            <xsl:for-each select="m:translation/m:section[@type eq 'translation']/m:section">
                                <xsl:call-template name="section">
                                    <xsl:with-param name="section" select="."/>
                                    <xsl:with-param name="css-classes" select="'text page glossarize-section'"/>
                                    <xsl:with-param name="render-in-viewport" select="true()"/>
                                </xsl:call-template>
                            </xsl:for-each>
                            
                            <!-- Appendix -->
                            <xsl:call-template name="section">
                                <xsl:with-param name="section" select="m:translation/m:section[@type eq 'appendix']"/>
                                <xsl:with-param name="css-classes" select="'page text glossarize-section'"/>
                                <xsl:with-param name="render-in-viewport" select="true()"/>
                            </xsl:call-template>
                            
                            <!-- Abbreviations -->
                            <xsl:call-template name="section">
                                <xsl:with-param name="section" select="m:translation/m:section[@type eq 'abbreviations']"/>
                                <xsl:with-param name="css-classes" select="'page'"/>
                                <xsl:with-param name="render-in-viewport" select="true()"/>
                            </xsl:call-template>
                            
                            <!-- Notes -->
                            <xsl:call-template name="section">
                                <xsl:with-param name="section" select="m:translation/m:section[@type eq 'end-notes']"/>
                                <xsl:with-param name="css-classes" select="'page'"/>
                                <xsl:with-param name="render-in-viewport" select="true()"/>
                            </xsl:call-template>
                            
                            <!-- Bilbiography -->
                            <xsl:call-template name="section">
                                <xsl:with-param name="section" select="m:translation/m:section[@type eq 'bibliography']"/>
                                <xsl:with-param name="css-classes" select="'page'"/>
                                <xsl:with-param name="render-in-viewport" select="true()"/>
                            </xsl:call-template>
                            
                            <!-- Glossary -->
                            <xsl:call-template name="section">
                                <xsl:with-param name="section" select="m:translation/m:section[@type eq 'glossary']"/>
                                <xsl:with-param name="css-classes" select="'page'"/>
                                <xsl:with-param name="render-in-viewport" select="true()"/>
                            </xsl:call-template>

                        </div>
                    </div>
                    
                </div>
            </article>
            
            <!-- Navigation controls -->
            <div class="nav-controls show-on-scroll-xs hidden-print">
                
                <div id="navigation-btn-container" class="fixed-btn-container">
                    <a href="#contents-sidebar" class="btn-round show-sidebar">
                        <i class="fa fa-bars" aria-hidden="true"/>
                    </a>
                </div>
                
                <div id="bookmarks-btn-container" class="fixed-btn-container">
                    <a href="#bookmarks-sidebar" id="bookmarks-btn" class="btn-round show-sidebar" aria-haspopup="true">
                        <i class="fa fa-bookmark"/>
                        <span class="badge badge-notification">0</span>
                    </a>
                </div>
                
                <div id="link-to-trans-top-container" class="fixed-btn-container">
                    <a href="#top" class="btn-round scroll-to-anchor link-to-top" title="top">
                        <i class="fa fa-arrow-up" aria-hidden="true"/>
                    </a>
                </div>
                
                <div id="rewind-btn-container" class="fixed-btn-container hidden">
                    <button class="btn-round" title="Return to the last location">
                        <i class="fa fa-undo" aria-hidden="true"/>
                    </button>
                </div>
                
            </div>
            
            <!-- General pop-up for notes and glossary -->
            <div id="popup-footer" class="fixed-footer collapse hidden-print">
                <div class="fix-height">
                    <div class="container">
                        <div class="row">
                            <div class="col-md-offset-1 col-md-10 col-lg-offset-2 col-lg-8">
                                <div class="data-container">
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
                        <xsl:call-template name="contents-sidebar">
                            <xsl:with-param name="translation" select="m:translation"/>
                        </xsl:call-template>
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
            
            <!-- Bookmarks fly-out -->
            <xsl:call-template name="bookmarks-sidebar"/>
            
        </xsl:variable>
        
        <!-- Pass the content to the page -->
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="m:translation/@page-url"/>
            <xsl:with-param name="page-class" select="concat('reading-room translation ', if(m:request/@view-mode = ('editor', 'annotation')) then 'editor-mode' else '')"/>
            <xsl:with-param name="page-title" select="concat(m:translation/m:titles/m:title[@xml:lang eq 'en']/text(), ' | 84000 Reading Room')"/>
            <xsl:with-param name="page-description" select="normalize-space(data(m:translation/m:section[@type eq 'summary']/tei:p[1]))"/>
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
                
                <xsl:if test="m:request/@view-mode eq 'annotation'">
                    <!-- <script type="application/json" class="js-hypothesis-config">{"theme": "clean"}</script> -->
                    <script src="https://hypothes.is/embed.js" async="async"/>
                </xsl:if>
                
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>

    <xsl:template name="front-matter">
        <xsl:param name="translation" required="yes"/>
        
        <div class="page page-first">
            
            <div id="titles" class="section-panel">
                <h2 class="text-bo">
                    <xsl:apply-templates select="$translation/m:titles/m:title[@xml:lang eq 'bo']"/>
                </h2>
                <h1>
                    <xsl:apply-templates select="$translation/m:titles/m:title[@xml:lang eq 'en']"/>
                </h1>
                <xsl:if test="$translation/m:titles/m:title[@xml:lang eq 'Sa-Ltn']/text()">
                    <h2 class="text-sa">
                        <xsl:apply-templates select="$translation/m:titles/m:title[@xml:lang eq 'Sa-Ltn']"/>
                    </h2>
                </xsl:if>
            </div>
            
            <xsl:if test="count($translation/m:long-titles/m:title/text()) eq 1 and $translation/m:long-titles/m:title[@xml:lang eq 'Bo-Ltn']/text()">
                <div id="long-titles">
                    <h4 class="text-wy">
                        <xsl:apply-templates select="$translation/m:long-titles/m:title[@xml:lang eq 'Bo-Ltn']/text()"/>
                    </h4>
                </div>
            </xsl:if>
            
        </div>
        
        <xsl:if test="count($translation/m:long-titles/m:title/text()) gt 1">
            <div class="page">
                
                <div id="long-titles">
                    <xsl:if test="$translation/m:long-titles/m:title[@xml:lang eq 'bo']/text()">
                        <h4 class="text-bo">
                            <xsl:apply-templates select="$translation/m:long-titles/m:title[@xml:lang eq 'bo']"/>
                        </h4>
                    </xsl:if>
                    <xsl:if test="$translation/m:long-titles/m:title[@xml:lang eq 'Bo-Ltn']/text()">
                        <h4 class="text-wy">
                            <xsl:apply-templates select="$translation/m:long-titles/m:title[@xml:lang eq 'Bo-Ltn']"/>
                        </h4>
                    </xsl:if>
                    <xsl:if test="$translation/m:long-titles/m:title[@xml:lang eq 'en']/text()">
                        <h4>
                            <xsl:apply-templates select="$translation/m:long-titles/m:title[@xml:lang eq 'en']"/>
                        </h4>
                    </xsl:if>
                    <xsl:if test="$translation/m:long-titles/m:title[@xml:lang eq 'Sa-Ltn']/text()">
                        <h4 class="text-sa">
                            <xsl:apply-templates select="$translation/m:long-titles/m:title[@xml:lang eq 'Sa-Ltn']"/>
                        </h4>
                    </xsl:if>
                </div>
                
            </div>
        </xsl:if>
        
        <div class="page">
            
            <img class="logo">
                <!-- Update to set image in CSS -->
                <xsl:attribute name="src" select="concat($front-end-path,'/imgs/logo.png')"/>
                <xsl:attribute name="alt" select="'84000 logo'"/>
            </img>
            
            <div id="toh">
                <h4>
                    <xsl:apply-templates select="$translation/m:source/m:toh"/>
                </h4>
                <xsl:if test="$translation/m:source[m:series/text() or m:scope/text() or m:range/text()]">
                    <p id="location">
                        <xsl:value-of select="string-join($translation/m:source/m:series/text() | $translation/m:source/m:scope/text() | $translation/m:source/m:range/text(), ', ')"/>.
                    </p>
                </xsl:if>
            </div>
            
            <xsl:if test="$translation/@status = $render-status">
                <xsl:variable name="contributors-summary" select="$translation/m:publication/m:contributors/m:summary"/>
                <xsl:if test="$contributors-summary[node()]">
                    <div class="well">
                        <xsl:for-each select="$translation/m:publication/m:contributors/m:summary">
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
                        <xsl:when test="$translation/m:publication/m:publication-date castable as xs:date">
                            <xsl:value-of select="concat('First published ', format-date($translation/m:publication/m:publication-date, '[Y]'))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'Not yet published'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <br/>
                    <xsl:choose>
                        <xsl:when test="$translation/m:publication/m:edition/tei:date[1] gt ''">
                            <xsl:value-of select="concat('Current version ', $translation/m:publication/m:edition/text()[1], '(', $translation/m:publication/m:edition/tei:date[1], ')')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'Invalid version'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <br/>
                    <span class="small">
                        <xsl:value-of select="concat('Generated by 84000 Reading Room v',@app-version)"/>
                    </span>
                </p>
            </div>
            
            <div class="bottom-margin">
                <p id="publication-statement">
                    <xsl:apply-templates select="$translation/m:publication/m:publication-statement"/>
                </p>
            </div>
            
            <xsl:if test="$translation/m:publication/m:tantric-restriction/tei:p">
                <div id="tantric-warning" class="well well-danger">
                    <xsl:for-each select="$translation/m:publication/m:tantric-restriction/tei:p">
                        <p>
                            <xsl:apply-templates select="node()"/>
                        </p>
                    </xsl:for-each>
                </div>
            </xsl:if>
            
            <xsl:if test="$translation/@status = $render-status">
                <div id="license">
                    <img>
                        <!-- Update to set image in CSS -->
                        <xsl:attribute name="src" select="replace($translation/m:publication/m:license/@img-url, '^http:', 'https:')"/>
                        <xsl:attribute name="alt" select="'Logo for the license'"/>
                    </img>
                    <xsl:for-each select="$translation/m:publication/m:license/tei:p">
                        <p class="text-muted small">
                            <xsl:apply-templates select="node()"/>
                        </p>
                    </xsl:for-each>
                </div>
            </xsl:if>
            
        </div>
    </xsl:template>
    
    <xsl:template name="download-options">
        <xsl:param name="translation" required="yes"/>
        
        <h5>
            <xsl:value-of select="'This translation is also available to download'"/>
        </h5>
        
        <xsl:for-each select="$translation/m:downloads/m:download[@type = ('pdf', 'epub', 'azw3')]">
            <a target="_blank">
                <xsl:attribute name="title">
                    <xsl:call-template name="download-label">
                        <xsl:with-param name="type" select="@type"/>
                    </xsl:call-template>
                </xsl:attribute>
                <xsl:attribute name="href" select="@url"/>
                <xsl:attribute name="download" select="@filename"/>
                <xsl:attribute name="class" select="'btn-round log-click'"/>
                <xsl:if test="@type = ('pdf', 'epub', 'azw3')">
                    <xsl:attribute name="data-page-alert" select="common:internal-link('/widget/download-dana.html', concat('resource-id=', $translation/m:source/@key), '#dana-description', /m:response/@lang)"/>
                </xsl:if>
                <xsl:call-template name="download-icon">
                    <xsl:with-param name="type" select="@type"/>
                </xsl:call-template>
            </a>
        </xsl:for-each>
        <a href="#" class="btn-round print-preview" title="Print">
            <i class="fa fa-print"/>
        </a>
    </xsl:template>
    
    <xsl:template name="section">
        
        <xsl:param name="section" as="node()*"/>
        <xsl:param name="css-classes" as="xs:string" select="''"/>
        <xsl:param name="render-in-viewport" as="xs:boolean" select="false()"/>
        
        <xsl:if test="$section">
            
            <section>
                
                <xsl:attribute name="id" select="$section/@section-id"/>
                
                <xsl:call-template name="class-attribute">
                    <xsl:with-param name="base-classes" as="xs:string*">
                        <xsl:value-of select="concat('section-type-', $section/@type)"/>
                        <xsl:value-of select="$css-classes"/>
                        <xsl:if test="$section[@nesting eq '0'] and $section[@section-id eq 'section-1'] and not($section/following-sibling::m:section[@section-id eq 'section-2'])">
                            <xsl:attribute name="class" select="'hide-header'"/>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
                
                <hr class="hidden-print"/>
                
                <div>
                    <xsl:if test="$render-in-viewport and not(/m:response/m:request/@view-mode = ('editor', 'annotation', 'app'))">
                        <xsl:attribute name="class" select="'render-in-viewport'"/>
                    </xsl:if>
                    <xsl:apply-templates select="$section/m:* | $section/tei:*"/>
                </div>
                
            </section>
            
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="contents-sidebar">
        <xsl:param name="translation" required="yes"/>
        <h4>
            <xsl:apply-templates select="$translation/m:titles/m:title[@xml:lang eq 'en']"/>
        </h4>
        <div class="data-container bottom-margin"/>
        <h4>
            <xsl:value-of select="'Search this translation'"/>
        </h4>
        <form action="/search.html" method="post" class="form-horizontal bottom-margin">
            <input type="hidden" name="resource-id" value="{ $translation/@id }"/>
            <div class="input-group">
                <input type="text" name="search" id="search" class="form-control" placeholder="Search" required="required" value=""/>
                <span class="input-group-btn">
                    <button type="submit" class="btn btn-primary">
                        <i class="fa fa-search"/>
                    </button>
                </span>
            </div>
        </form>
        <xsl:if test="$translation/@status = $render-status">
            <h4>
                <xsl:value-of select="'Download Options'"/>
            </h4>
            <table class="contents-table bottom-margin">
                <tbody>
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
                    <xsl:for-each select="$translation/m:downloads/m:download[@type = ('pdf', 'epub', 'azw3')]">
                        <tr>
                            <td>
                                <a target="_blank">
                                    <xsl:attribute name="title">
                                        <xsl:call-template name="download-label">
                                            <xsl:with-param name="type" select="@type"/>
                                        </xsl:call-template>
                                    </xsl:attribute>
                                    <xsl:attribute name="href" select="@url"/>
                                    <xsl:attribute name="download" select="@filename"/>
                                    <xsl:attribute name="class" select="'log-click'"/>
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
                                    <xsl:attribute name="href" select="@url"/>
                                    <xsl:attribute name="download" select="@filename"/>
                                    <xsl:attribute name="class" select="'log-click'"/>
                                    <xsl:attribute name="data-page-alert" select="common:internal-link('/widget/download-dana.html', concat('resource-id=', $translation/m:source/@key), '#dana-description', /m:response/@lang)"/>
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
                            <xsl:value-of select="'View Published Translations'"/>
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
    </xsl:template>
    
</xsl:stylesheet>