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
            
            <article class="content-band">
                <div class="container">
                    <div class="row">
                        <div class="col-md-offset-1 col-md-10 col-lg-offset-2 col-lg-8 print-width-override">

                            <section id="front-matter">
                                <xsl:call-template name="front-matter">
                                    <xsl:with-param name="translation" select="m:translation"/>
                                </xsl:call-template>
                            </section>
                            
                            <xsl:if test="m:translation/@status = $render-status">
                                
                                <!-- Keep download options upfront as a reminder that they are available -->
                                <aside class="download-options hidden-print text-center">
                                    <xsl:call-template name="download-options">
                                        <xsl:with-param name="translation" select="m:translation"/>
                                    </xsl:call-template>
                                </aside>
                                
                                <aside id="print-version" class="visible-print-block text-center page">
                                    <xsl:call-template name="local-text">
                                        <xsl:with-param name="local-key" select="'print-version'"/>
                                    </xsl:call-template>
                                </aside>

                                <hr class="hidden-print"/>
    
                                <aside id="contents" class="page">
                                    
                                    <xsl:call-template name="section-title">
                                        <xsl:with-param name="id" select="'contents'"/>
                                        <xsl:with-param name="prefix" select="'co'"/>
                                        <xsl:with-param name="title" select="'Contents'"/>
                                    </xsl:call-template>
                                    
                                    <div class="rw">
                                        <xsl:call-template name="table-of-contents">
                                            <xsl:with-param name="translation" select="m:translation"/>
                                        </xsl:call-template>
                                    </div>
                                    
                                </aside>
                                
                            </xsl:if>
                            
                            <xsl:if test="m:translation/m:summary[tei:p]">
                                
                                <hr class="hidden-print"/>
                                
                                <section id="summary" class="page text glossarize-section">
                                    
                                    <xsl:call-template name="section-title">
                                        <xsl:with-param name="id" select="'summary'"/>
                                        <xsl:with-param name="prefix" select="m:translation/m:summary/@prefix"/>
                                        <xsl:with-param name="title" select="'Summary'"/>
                                    </xsl:call-template>
                                    
                                    <div>
                                        <xsl:apply-templates select="m:translation/m:summary"/>
                                    </div>
                                    
                                </section>
                                
                            </xsl:if>
                            
                            <xsl:if test="m:translation/@status = $render-status">
                            
                                <hr class="hidden-print"/>
    
                                <section id="acknowledgements" class="text">
                                    
                                    <xsl:call-template name="section-title">
                                        <xsl:with-param name="id" select="'acknowledgements'"/>
                                        <xsl:with-param name="prefix" select="m:translation/m:acknowledgment/@prefix"/>
                                        <xsl:with-param name="title" select="'Acknowledgements'"/>
                                    </xsl:call-template>
                                    
                                    <div>
                                        <xsl:apply-templates select="m:translation/m:acknowledgment"/>
                                    </div>
                                    
                                </section>
                                
                                <xsl:if test="m:translation/m:preface//tei:*">
                                    <hr class="hidden-print"/>
                                    
                                    <section id="preface" class="page text">
                                        
                                        <xsl:call-template name="section-title">
                                            <xsl:with-param name="id" select="'preface'"/>
                                            <xsl:with-param name="prefix" select="m:translation/m:preface/@prefix"/>
                                            <xsl:with-param name="title" select="'Preface'"/>
                                        </xsl:call-template>
                                        
                                        <div>
                                            <xsl:if test="not(m:request/@view-mode = ('editor','app'))">
                                                <xsl:attribute name="class" select="'render-in-viewport'"/>
                                            </xsl:if>
                                            <xsl:apply-templates select="m:translation/m:preface"/>
                                        </div>
                                        
                                    </section>
                                </xsl:if>
    
                                <hr class="hidden-print"/>
    
                                <section id="introduction" class="page text glossarize-section">
                                    
                                    <xsl:call-template name="section-title">
                                        <xsl:with-param name="id" select="'introduction'"/>
                                        <xsl:with-param name="prefix" select="m:translation/m:introduction/@prefix"/>
                                        <xsl:with-param name="title" select="'Introduction'"/>
                                    </xsl:call-template>
                                    
                                    <div>
                                        <xsl:if test="not(m:request/@view-mode = ('editor','app'))">
                                            <xsl:attribute name="class" select="'render-in-viewport'"/>
                                        </xsl:if>
                                        <xsl:apply-templates select="m:translation/m:introduction"/>
                                    </div>
                                    
                                </section>

                                <hr class="hidden-print"/>
    
                                <section id="body-title" class="page">
                                    <xsl:call-template name="body-title">
                                        <xsl:with-param name="translation" select="m:translation"/>
                                    </xsl:call-template>
                                </section>
                                
                                <xsl:if test="m:translation/m:prologue//tei:*">
                                    <hr class="hidden-print"/>
                                    <section id="prologue" class="page text glossarize-section">
                                        
                                        <xsl:call-template name="section-title">
                                            <xsl:with-param name="id" select="'prologue'"/>
                                            <xsl:with-param name="prefix" select="m:translation/m:prologue/@prefix"/>
                                            <xsl:with-param name="title" select="'Prologue'"/>
                                            <xsl:with-param name="title-tag" select="'h3'"/>
                                        </xsl:call-template>
                                        
                                        <div>
                                            <xsl:if test="not(m:request/@view-mode = ('editor','app'))">
                                                <xsl:attribute name="class" select="'render-in-viewport'"/>
                                            </xsl:if>
                                            <xsl:apply-templates select="m:translation/m:prologue"/>
                                        </div>
                                        
                                    </section>
                                </xsl:if>
                                
                                <div id="translation">
                                    
                                    <xsl:for-each select="m:translation/m:body/m:chapter">
                                        
                                        <xsl:if test="m:title/text() or m:title-number/text()">
                                            <hr class="hidden-print"/>
                                        </xsl:if>
                                        
                                        <section>
                                            <xsl:attribute name="id" select="concat('chapter-', @prefix)"/>
                                            
                                            <xsl:choose>
                                                <xsl:when test="m:title/text() or m:title-number/text() or m:translation/m:prologue//tei:*">
                                                    <xsl:attribute name="class" select="'chapter text glossarize-section page'"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:attribute name="class" select="'chapter text glossarize-section'"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            
                                            <xsl:if test="m:title/text() or m:title-number/text()">
                                                
                                                <xsl:call-template name="chapter-title">
                                                    <xsl:with-param name="title" select="m:title"/>
                                                    <xsl:with-param name="title-number" select="m:title-number"/>
                                                    <xsl:with-param name="chapter-index" select="@chapter-index/string()"/>
                                                    <xsl:with-param name="prefix" select="@prefix/string()"/>
                                                </xsl:call-template>
                                                
                                            </xsl:if>
                                            
                                            <div>
                                                <xsl:if test="not(m:request/@view-mode = ('editor','app'))">
                                                    <xsl:attribute name="class" select="'render-in-viewport'"/>
                                                </xsl:if>
                                                <xsl:apply-templates select="tei:*"/>
                                            </div>
                                            
                                        </section>
                                        
                                    </xsl:for-each>
                                </div>
                                
                                <xsl:if test="m:translation/m:colophon//tei:*">
                                    
                                    <hr class="hidden-print"/>
                                    
                                    <section id="colophon" class="text glossarize-section">
                                        
                                        <xsl:call-template name="section-title">
                                            <xsl:with-param name="id" select="'colophon'"/>
                                            <xsl:with-param name="prefix" select="m:translation/m:colophon/@prefix"/>
                                            <xsl:with-param name="title" select="'Colophon'"/>
                                            <xsl:with-param name="title-tag" select="'h3'"/>
                                        </xsl:call-template>
                                        
                                        <div>
                                            <xsl:if test="not(m:request/@view-mode = ('editor','app'))">
                                                <xsl:attribute name="class" select="'render-in-viewport'"/>
                                            </xsl:if>
                                            <xsl:apply-templates select="m:translation/m:colophon"/>
                                        </div>
                                        
                                    </section>
                                </xsl:if>
                                
                                <xsl:if test="m:translation/m:appendix//tei:*">
                                    
                                    <hr class="hidden-print"/>
                                    
                                    <section id="appendix" class="page text glossarize-section">
                                        
                                        <xsl:call-template name="section-title">
                                            <xsl:with-param name="id" select="'appendix'"/>
                                            <xsl:with-param name="prefix" select="m:translation/m:appendix/@prefix"/>
                                            <xsl:with-param name="title" select="'Appendix'"/>
                                            <xsl:with-param name="title-tag" select="'h3'"/>
                                        </xsl:call-template>
                                        
                                        <div>
                                            <xsl:if test="not(m:request/@view-mode = ('editor','app'))">
                                                <xsl:attribute name="class" select="'render-in-viewport'"/>
                                            </xsl:if>
                                            <xsl:for-each select="m:translation/m:appendix/m:chapter">
                                                
                                                <xsl:if test="position() gt 1">
                                                    <hr class="hidden-print"/>
                                                </xsl:if>
                                                
                                                <div class="relative chapter">
                                                    
                                                    <xsl:attribute name="id" select="concat('chapter-', @prefix)"/>
                                                    
                                                    <xsl:call-template name="chapter-title">
                                                        <xsl:with-param name="title" select="m:title"/>
                                                        <xsl:with-param name="title-number" select="m:title-number"/>
                                                        <xsl:with-param name="chapter-index" select="@chapter-index/string()"/>
                                                        <xsl:with-param name="prefix" select="@prefix/string()"/>
                                                    </xsl:call-template>
                                                    
                                                    <xsl:apply-templates select="tei:*"/>
                                                    
                                                </div>
                                            </xsl:for-each>
                                        </div>
                                    </section>
                                </xsl:if>
                                
                                <xsl:if test="m:translation/m:abbreviations//m:list/m:item">
                                    
                                    <hr class="hidden-print"/>
                                    
                                    <section id="abbreviations" class="page">
                                        
                                        <xsl:call-template name="section-title">
                                            <xsl:with-param name="id" select="'abbreviations'"/>
                                            <xsl:with-param name="prefix" select="m:translation/m:abbreviations/@prefix"/>
                                            <xsl:with-param name="title" select="'Abbreviations'"/>
                                        </xsl:call-template>
                                        
                                        <div>
                                            <xsl:if test="not(m:request/@view-mode = ('editor','app'))">
                                                <xsl:attribute name="class" select="'render-in-viewport'"/>
                                            </xsl:if>
                                            <div class="rw">
                                                <xsl:call-template name="abbreviations">
                                                    <xsl:with-param name="translation" select="m:translation"/>
                                                </xsl:call-template>
                                            </div>
                                        </div>
                                        
                                    </section>
                                    
                                </xsl:if>
    
                                <hr class="hidden-print"/>
    
                                <section id="notes" class="page glossarize-section">
                                    
                                    <xsl:call-template name="section-title">
                                        <xsl:with-param name="id" select="'notes'"/>
                                        <xsl:with-param name="prefix" select="m:translation/m:notes/@prefix"/>
                                        <xsl:with-param name="title" select="'Notes'"/>
                                    </xsl:call-template>
                                    
                                    <div>
                                        <xsl:if test="not(m:request/@view-mode = ('editor','app'))">
                                            <xsl:attribute name="class" select="'render-in-viewport'"/>
                                        </xsl:if>
                                        <xsl:call-template name="notes">
                                            <xsl:with-param name="translation" select="m:translation"/>
                                        </xsl:call-template>
                                    </div>
                                </section>
                                
                                <hr class="hidden-print"/>
                                
                                <section id="bibliography" class="page">
                                    
                                    <xsl:call-template name="section-title">
                                        <xsl:with-param name="id" select="'bibliography'"/>
                                        <xsl:with-param name="prefix" select="m:translation/m:bibliography/@prefix"/>
                                        <xsl:with-param name="title" select="'Bibliography'"/>
                                    </xsl:call-template>
                                    
                                    <div>
                                        <xsl:if test="not(m:request/@view-mode = ('editor','app'))">
                                            <xsl:attribute name="class" select="'render-in-viewport'"/>
                                        </xsl:if>
                                        <xsl:for-each select="m:translation/m:bibliography">
                                            <div class="rw">
                                                <xsl:apply-templates select="node()"/>
                                            </div>
                                        </xsl:for-each>
                                    </div>
                                </section>
    
                                <hr class="hidden-print"/>

                                <section id="glossary" class="page glossarize-section">
                                    
                                    <xsl:call-template name="section-title">
                                        <xsl:with-param name="id" select="'glossary'"/>
                                        <xsl:with-param name="prefix" select="m:translation/m:glossary/@prefix"/>
                                        <xsl:with-param name="title" select="'Glossary'"/>
                                    </xsl:call-template>
                                    
                                    <div>
                                        <xsl:if test="not(m:request/@view-mode = ('editor','app'))">
                                            <xsl:attribute name="class" select="'render-in-viewport'"/>
                                        </xsl:if>
                                        <xsl:call-template name="glossary">
                                            <xsl:with-param name="translation" select="m:translation"/>
                                        </xsl:call-template>
                                    </div>
                                    
                                </section>
                                
                            </xsl:if>

                        </div>
                    </div>
                    
                </div>
            </article>
            
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
                    <a href="#top" class="btn-round scroll-to-anchor" title="top">
                        <i class="fa fa-arrow-up" aria-hidden="true"/>
                    </a>
                </div>
                
                <div id="rewind-btn-container" class="fixed-btn-container hidden">
                    <button class="btn-round" title="Return to the last location">
                        <i class="fa fa-undo" aria-hidden="true"/>
                    </button>
                </div>
                
            </div>
    
            <div id="popup-footer" class="fixed-footer collapse hidden-print">
                <div class="fix-height">
                    <div class="container">
                        <div class="row">
                            <div class="col-sm-offset-1 col-sm-10 col-lg-offset-2 col-lg-8">
                                <div class="data-container">
                                    <!-- Ajax data here -->
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="fixed-btn-container close-btn-container">
                    <button type="button" class="btn-round close" aria-label="Close">
                        <span aria-hidden="true">
                            <i class="fa fa-times"/>
                        </span>
                    </button>
                </div>
            </div>
            
            <div id="popup-footer-source" class="fixed-footer collapse hidden-print">
                <div class="fix-height">
                    <div class="data-container">
                        <!-- Ajax data here -->
                    </div>
                </div>
                <div class="fixed-btn-container close-btn-container">
                    <button type="button" class="btn-round close" aria-label="Close">
                        <span aria-hidden="true">
                            <i class="fa fa-times"/>
                        </span>
                    </button>
                </div>
            </div>
            
            <div id="contents-sidebar" class="fixed-sidebar collapse width hidden-print">
                
                <div class="fix-width">
                    <div class="sidebar-content">
                        <xsl:call-template name="contents-sidebar">
                            <xsl:with-param name="translation" select="m:translation"/>
                        </xsl:call-template>
                    </div>
                </div>
                
                <div class="fixed-btn-container close-btn-container right">
                    <button type="button" class="btn-round close" aria-label="Close">
                        <span aria-hidden="true">
                            <i class="fa fa-times"/>
                        </span>
                    </button>
                </div>
                
            </div>
            
            <xsl:call-template name="bookmarks-sidebar"/>
            
        </xsl:variable>
        
        <!-- Pass the content to the page -->
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="m:translation/@page-url"/>
            <xsl:with-param name="page-class" select="concat('translation ', if(m:request/@view-mode eq 'editor') then 'editor-mode' else '')"/>
            <xsl:with-param name="page-title" select="concat('84000 Reading Room | ', m:translation/m:titles/m:title[@xml:lang eq 'en']/text())"/>
            <xsl:with-param name="page-description" select="normalize-space(data(m:translation/m:summary/tei:p[1]))"/>
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
                
                <xsl:if test="m:request/@view-mode eq 'editor'">
                    <!-- <script type="application/json" class="js-hypothesis-config">{"theme": "clean"}</script> -->
                    <script src="https://hypothes.is/embed.js" async="async"/>
                </xsl:if>
                
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="body-title">
        <xsl:param name="translation" required="yes"/>
        <div class="rw rw-body-title">
            <div class="gtr">
                <a href="#body-title" class="milestone milestone-h3" title="Bookmark this section">
                    <xsl:value-of select="concat($translation/m:body/@prefix, '.')"/>
                </a>
            </div>
            <div class="rw-heading">
                <h3>
                    <xsl:value-of select="'The Translation'"/>
                </h3>
                <xsl:if test="$translation/m:body/m:honoration/text()">
                    <h2>
                        <xsl:apply-templates select="$translation/m:body/m:honoration"/>
                    </h2>
                </xsl:if>
                <h1>
                    <xsl:apply-templates select="$translation/m:body/m:main-title"/>
                </h1>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template name="table-of-contents">
        <xsl:param name="translation" required="yes"/>
        <table id="table-of-contents" class="contents-table">
            <tbody>
                <tr>
                    <td>ti.</td>
                    <td>
                        <a href="#top" class="scroll-to-anchor">Title</a>
                    </td>
                </tr>
                <tr>
                    <td>co.</td>
                    <td>
                        <a href="#contents" class="scroll-to-anchor">Contents</a>
                    </td>
                </tr>
                <xsl:if test="$translation/m:summary//tei:*">
                    <tr>
                        <td>
                            <xsl:value-of select="concat($translation/m:summary/@prefix, '.')"/>
                        </td>
                        <td>
                            <a href="#summary" class="scroll-to-anchor">Summary</a>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="$translation/m:acknowledgment//tei:*">
                    <tr>
                        <td>
                            <xsl:value-of select="concat($translation/m:acknowledgment/@prefix, '.')"/>
                        </td>
                        <td>
                            <a href="#acknowledgements" class="scroll-to-anchor">Acknowledgements</a>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="$translation/m:preface//tei:*">
                    <tr>
                        <td>
                            <xsl:value-of select="concat($translation/m:preface/@prefix, '.')"/>
                        </td>
                        <td>
                            <a href="#preface" class="scroll-to-anchor">Preface</a>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="$translation/m:introduction//tei:*">
                    <tr>
                        <td>
                            <xsl:value-of select="concat($translation/m:introduction/@prefix, '.')"/>
                        </td>
                        <td>
                            <a href="#introduction" class="scroll-to-anchor">Introduction</a>
                        </td>
                    </tr>
                </xsl:if>
                <tr>
                    <td>
                        <xsl:value-of select="concat($translation/m:body/@prefix, '.')"/>
                    </td>
                    <td>
                        <a href="#body-title" class="scroll-to-anchor">The Translation</a>
                    </td>
                </tr>
                <xsl:if test="$translation/m:prologue//tei:*">
                    <tr>
                        <td>
                            <xsl:value-of select="concat($translation/m:prologue/@prefix, '.')"/>
                        </td>
                        <td>
                            <a href="#prologue" class="scroll-to-anchor">Prologue</a>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="$translation/m:body/m:chapter[m:title/text() | m:title-number/text()]">
                    <xsl:call-template name="table-of-contents-chapters">
                        <xsl:with-param name="chapters" select="$translation/m:body/m:chapter[m:title/text() | m:title-number/text()]"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:if test="$translation/m:colophon//tei:*">
                    <tr>
                        <td>
                            <xsl:value-of select="concat($translation/m:colophon/@prefix, '.')"/>
                        </td>
                        <td>
                            <a href="#colophon" class="scroll-to-anchor">Colophon</a>
                        </td>
                    </tr>
                </xsl:if>
                <xsl:if test="$translation/m:appendix//tei:*">
                    <tr>
                        <td>
                            <xsl:value-of select="concat($translation/m:appendix/@prefix, '.')"/>
                        </td>
                        <td>
                            <a href="#appendix" class="scroll-to-anchor">Appendix</a>
                        </td>
                    </tr>
                    <xsl:if test="$translation/m:appendix/m:chapter">
                        <xsl:call-template name="table-of-contents-sub-chapters">
                            <xsl:with-param name="sub-chapters" select="$translation/m:appendix/m:chapter[m:title/text()]"/>
                            <xsl:with-param name="expand-id" select="'appendix-chapters'"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:if>
                <xsl:if test="$translation/m:abbreviations//m:list/m:item">
                    <tr>
                        <td>
                            <xsl:value-of select="concat($translation/m:abbreviations/@prefix, '.')"/>
                        </td>
                        <td>
                            <a href="#abbreviations" class="scroll-to-anchor">Abbreviations</a>
                        </td>
                    </tr>
                </xsl:if>
                <tr>
                    <td>
                        <xsl:value-of select="concat($translation/m:notes/@prefix, '.')"/>
                    </td>
                    <td>
                        <a href="#notes" class="scroll-to-anchor">Notes</a>
                    </td>
                </tr>
                <tr>
                    <td>
                        <xsl:value-of select="concat($translation/m:bibliography/@prefix, '.')"/>
                    </td>
                    <td>
                        <a href="#bibliography" class="scroll-to-anchor">Bibliography</a>
                    </td>
                </tr>
                <tr>
                    <td>
                        <xsl:value-of select="concat($translation/m:glossary/@prefix, '.')"/>
                    </td>
                    <td>
                        <a href="#glossary" class="scroll-to-anchor">Glossary</a>
                    </td>
                </tr>
            </tbody>
        </table>
    </xsl:template>
    
    <xsl:template name="table-of-contents-chapters">
        <xsl:param name="chapters" required="yes"/>
        <xsl:for-each select="$chapters">
            
            <xsl:variable name="id" select="if(@prefix) then concat('chapter-', @prefix) else concat('section-', @section-id)"/>
            
            <tr>
                <td>
                    <xsl:choose>
                        <xsl:when test="@prefix">
                            <xsl:apply-templates select="@prefix"/>
                            <xsl:value-of select="'.'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'·'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
                <td>
                    <a class="scroll-to-anchor">
                        <xsl:attribute name="href" select="concat('#', $id)"/>
                        
                        <xsl:choose>
                            <xsl:when test="tei:head/text()">
                                <xsl:apply-templates select="tei:head/text()"/>
                            </xsl:when>
                            <xsl:when test="m:title/text()">
                                <xsl:apply-templates select="m:title/text()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="m:title-number/text()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                </td>
            </tr>
            
            <xsl:if test="tei:div[@type = ('section', 'chapter')][tei:head/text()]">
                <xsl:call-template name="table-of-contents-sub-chapters">
                    <xsl:with-param name="sub-chapters" select="tei:div[@type = ('section', 'chapter')][tei:head/text()]"/>
                    <xsl:with-param name="expand-id" select="concat('toc-', $id)"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template name="table-of-contents-sub-chapters">
        <xsl:param name="sub-chapters" required="yes"/>
        <xsl:param name="expand-id" required="yes"/>
        <tr class="sub">
            <td/>
            <td>
                
                <xsl:if test="$expand-id">
                    <a role="button" data-toggle="collapse" aria-expanded="true" class="small collapsed">
                        <xsl:attribute name="href" select="concat('#', $expand-id)"/>
                        <xsl:attribute name="aria-controls" select="$expand-id"/>
                        <span class="collapsed-show">
                            <span class="monospace">
                                <xsl:value-of select="'+'"/>
                            </span>
                            <xsl:value-of select="' sub-sections'"/>
                        </span>
                        <span class="collapsed-hide">
                            <span class="monospace">
                                <xsl:value-of select="'-'"/>
                            </span>
                            <xsl:value-of select="' sub-sections'"/>
                        </span>
                    </a>
                </xsl:if>
                
                <div>
                    <xsl:if test="$expand-id">
                        <xsl:attribute name="class" select="'collapse print-expand collapse-chapter'"/>
                        <xsl:attribute name="id" select="$expand-id"/>
                    </xsl:if>
                    <table>
                        <tbody>
                            <xsl:call-template name="table-of-contents-chapters">
                                <xsl:with-param name="chapters" select="$sub-chapters"/>
                            </xsl:call-template>
                        </tbody>
                    </table>
                </div>
                
            </td>
        </tr>
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
                <xsl:if test="$translation/m:titles/m:title[@xml:lang eq 'sa-ltn']/text()">
                    <h2 class="text-sa">
                        <xsl:apply-templates select="$translation/m:titles/m:title[@xml:lang eq 'sa-ltn']"/>
                    </h2>
                </xsl:if>
            </div>
            
            <xsl:if test="count($translation/m:long-titles/m:title/text()) eq 1 and $translation/m:long-titles/m:title[@xml:lang eq 'bo-ltn']/text()">
                <div id="long-titles">
                    <h4 class="text-wy">
                        <xsl:apply-templates select="$translation/m:long-titles/m:title[@xml:lang eq 'bo-ltn']/text()"/>
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
                    <xsl:if test="$translation/m:long-titles/m:title[@xml:lang eq 'bo-ltn']/text()">
                        <h4 class="text-wy">
                            <xsl:apply-templates select="$translation/m:long-titles/m:title[@xml:lang eq 'bo-ltn']"/>
                        </h4>
                    </xsl:if>
                    <xsl:if test="$translation/m:long-titles/m:title[@xml:lang eq 'en']/text()">
                        <h4>
                            <xsl:apply-templates select="$translation/m:long-titles/m:title[@xml:lang eq 'en']"/>
                        </h4>
                    </xsl:if>
                    <xsl:if test="$translation/m:long-titles/m:title[@xml:lang eq 'sa-ltn']/text()">
                        <h4 class="text-sa">
                            <xsl:apply-templates select="$translation/m:long-titles/m:title[@xml:lang eq 'sa-ltn']"/>
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
            
            <xsl:if test="m:translation/@status = $render-status">
                <xsl:if test="$translation/m:translation/m:contributors/m:summary/text()">
                    <div class="well">
                        <xsl:for-each select="$translation/m:translation/m:contributors/m:summary">
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
                        <xsl:when test="$translation/m:translation/m:publication-date castable as xs:date">
                            <xsl:value-of select="concat('First published ', format-date($translation/m:translation/m:publication-date, '[Y]'))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'Not yet published'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <br/>
                    <xsl:choose>
                        <xsl:when test="$translation/m:translation/m:edition/tei:date gt ''">
                            <xsl:value-of select="concat('Current version ', $translation/m:translation/m:edition/text()[1], '(', $translation/m:translation/m:edition/tei:date, ')')"/>
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
                    <xsl:apply-templates select="$translation/m:translation/m:publication-statement"/>
                </p>
            </div>
            
            <xsl:if test="$translation/m:translation/m:tantric-restriction/tei:p">
                <div id="tantric-warning" class="well well-danger">
                    <xsl:for-each select="$translation/m:translation/m:tantric-restriction/tei:p">
                        <p>
                            <xsl:apply-templates select="node()"/>
                        </p>
                    </xsl:for-each>
                </div>
            </xsl:if>
            
            <xsl:if test="m:translation/@status = $render-status">
                <div id="license">
                    <img>
                        <!-- Update to set image in CSS -->
                        <xsl:attribute name="src" select="replace($translation/m:translation/m:license/@img-url, '^http:', 'https:')"/>
                        <xsl:attribute name="alt" select="'Logo for the license'"/>
                    </img>
                    <xsl:for-each select="$translation/m:translation/m:license/tei:p">
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
                    <xsl:attribute name="data-download-dana" select="$translation/m:titles/m:title[@xml:lang eq 'en']/text()"/>
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
    
    <xsl:template name="notes">
        <xsl:param name="translation" required="yes"/>
        <xsl:for-each select="$translation/m:notes/m:note">
            <div class="footnote rw">
                <xsl:attribute name="id" select="@uid"/>
                <div class="gtr">
                    <a class="scroll-to-anchor footnote-number">
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('#link-to-', @uid)"/>
                        </xsl:attribute>
                        <xsl:attribute name="data-mark">
                            <xsl:value-of select="concat('#link-to-', @uid)"/>
                        </xsl:attribute>
                        <xsl:apply-templates select="@index"/>
                    </a>
                </div>
                <div class="glossarize">
                    <xsl:apply-templates select="node()"/>
                </div>
            </div>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="glossary">
        <xsl:param name="translation" required="yes"/>
        <xsl:for-each select="$translation/m:glossary/m:item">
            <xsl:sort select="m:sort-term"/>
            <div class="glossary-item rw">
                
                <xsl:attribute name="id" select="@uid/string()"/>
                <xsl:attribute name="data-match" select="if(@mode/string() eq 'marked') then 'marked' else 'match'"/>
                
                <div class="gtr">
                    <a class="milestone" title="Bookmark this section">
                        <xsl:attribute name="href" select="concat('#', @uid/string())"/>
                        <xsl:value-of select="concat('g.', position())"/>
                    </a>
                </div>
                
                <div class="row">
                    
                    <div class="col-md-8 match-this-height print-width-override print-height-override">
                        
                        <xsl:if test="/m:response/m:request/@view-mode = ('app')">
                            <xsl:attribute name="class" select="'col-md-12 print-width-override print-height-override'"/>
                        </xsl:if>
                        
                        <xsl:attribute name="data-match-height" select="concat('g-', position())"/>
                        <xsl:attribute name="data-match-height-media" select="'.md,.lg'"/>
                        
                        <xsl:call-template name="glossary-item">
                            <xsl:with-param name="glossary-item" select="."/>
                        </xsl:call-template>
                        
                    </div>
                    
                    <xsl:if test="not(/m:response/m:request/@view-mode = ('app'))">
                        <div class="col-md-4 occurences hidden-print match-height-overflow print-height-override">
                            <xsl:attribute name="data-match-height" select="concat('g-', position())"/>
                            <xsl:attribute name="data-match-height-media" select="'.md,.lg'"/>
                            <hr class="visible-xs-block visible-sm-block"/>
                            <h6>
                                <xsl:value-of select="'Finding passages containing this term...'"/>
                            </h6>
                        </div>
                    </xsl:if>
                    
                </div>
                
            </div>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="contents-sidebar">
        <xsl:param name="translation" required="yes"/>
        <h4>
            <xsl:apply-templates select="$translation/m:titles/m:title[@xml:lang eq 'en']"/>
        </h4>
        <div class="data-container bottom-margin"/>
        <xsl:if test="m:translation/@status = $render-status">
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
                                    <xsl:attribute name="data-download-dana" select="$translation/m:titles/m:title[@xml:lang eq 'en']/text()"/>
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
                            <xsl:attribute name="href" select="common:homepage-link(/m:response/@lang)"/>
                            <i class="fa fa-home"/>
                        </a>
                    </td>
                    <td>
                        <a>
                            <xsl:attribute name="href" select="common:homepage-link(/m:response/@lang)"/>
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
            </tbody>
        </table>
        <a href="http://84000.co/how-you-can-help/donate/#sap" class="btn btn-primary btn-uppercase">
            <xsl:copy-of select="common:override-href(/m:response/@lang, 'zh', 'http://84000.co/ch-howhelp/donate')"/>
            <xsl:value-of select="'Sponsor Translation'"/>
        </a>
    </xsl:template>
    
    <!-- 
    <xsl:template name="donate-sidebar">
        <h2>Become a Friend of the Reading Room</h2>
        <p>84000’s mandate is both to translate and to make freely available the sūtras and shastras. If our translation efforts represent wisdom, 84000’s publication and provision of freely accessible texts represents its compassionate activity.</p>
        <p>This aspect of our mandate leverages and integrates new technologies to make these publications as accessible and beneficial as possible to readers, practitioners, and scholars around the world.</p>
        <p>By becoming a Friend of the Reading Room, you allow us to think ahead by planning new features for our Reading Room; as well as indicating support for our Publications and Technology teams that are so integral to our ability to continually innovate our readers’ experience and ability to engage with the sūtras.</p>
        <p>
            <a>
                <xsl:attribute name="href" select="'https://84000.secure.force.com/donate'"/>
                Read more about becoming a Friend of the Reading Room
            </a>
        </p>
    </xsl:template>
     -->
    
</xsl:stylesheet>