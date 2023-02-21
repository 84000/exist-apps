<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/tei-to-xhtml.xsl"/>

    <!-- Look up environment variables -->
    <xsl:variable name="front-end-path" select="$environment/m:url[@id eq 'front-end']/text()"/>
    <xsl:variable name="app-path" select="$environment/m:url[@id eq 'app']/text()"/>
    <xsl:variable name="render-status" select="$environment/m:render/m:status[@type eq 'translation']/@status-id"/>
    
    <xsl:variable name="page-title" as="node()*">
        <xsl:sequence select="/m:response/m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
        <xsl:sequence select="/m:response/m:translation//m:part[@content-status eq 'complete'][@id eq $requested-part][1]/tei:head[@type eq parent::m:part/@type]"/>
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
                    
                    <!-- Front matter -->
                    <xsl:call-template name="front-matter"/>
                    
                    <!-- Table of Contents -->
                    <xsl:if test="m:translation/@status = $render-status">
                        <div class="row">
                            <div class="col-md-offset-1 col-md-10 col-lg-offset-2 col-lg-8 print-width-override">
                                <xsl:call-template name="table-of-contents"/>
                            </div>
                        </div>
                    </xsl:if>
                    
                    <div id="parts">
                        
                        <!-- Summary -->
                        <xsl:call-template name="part">
                            <xsl:with-param name="part" select="m:translation/m:part[@type eq 'summary']"/>
                            <xsl:with-param name="css-classes" select="'page page-force text'"/>
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
            </main>
            
            <!-- Additional functional elements -->
            <xsl:if test="$view-mode[@client eq 'browser'][not(@layout eq 'flat')]">
                
                <!-- Navigation controls -->
                <nav class="nav-controls show-on-scroll-xs hidden-print hidden-iframe" aria-label="Navigation icons">
                    
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
                    
                    <!-- Link to the start of the section / defaults to the start of the page -->
                    <div id="link-to-trans-top-container" class="fixed-btn-container">
                        <a class="btn-round link-to-top" title="Go to the top of the page">
                            <xsl:attribute name="href" select="'#top'"/>
                            <i class="fa fa-arrow-up" aria-hidden="true"/>
                        </a>
                    </div>
                    
                    <div id="rewind-btn-container" class="fixed-btn-container hidden">
                        <button class="btn-round" title="Return to the previous location">
                            <i class="fa fa-undo" aria-hidden="true"/>
                        </button>
                    </div>
                    
                </nav>
                
                <!-- General pop-up for notes and glossary -->
                <div id="popup-footer-text" class="fixed-footer collapse hidden-print">
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
                
                <!-- Dual-view pop-up -->
                <xsl:call-template name="dualview-popup"/>
                
                <!-- Contents fly-out -->
                <div id="contents-sidebar" class="fixed-sidebar collapse width hidden-print">
                    
                    <div class="fix-width">
                        <div class="sidebar-content">
                            
                            <!--<h3>
                                <xsl:value-of select="m:translation/m:titles/m:title[text()][@xml:lang eq 'en'][1]"/>
                            </h3>-->
                            
                            <xsl:if test="m:translation/@status = $render-status">
                                
                                <h4>
                                    <xsl:value-of select="'Table of Contents'"/>
                                </h4>
                                <div class="data-container bottom-margin"/>
                                <hr/>
                                
                                <h4>
                                    <xsl:value-of select="'Search this text'"/>
                                </h4>
                                <form action="/search.html" method="post" role="search" class="form-horizontal bottom-margin">
                                    <input type="hidden" name="specified-text" value="{ m:translation/@id }"/>
                                    <div class="input-group">
                                        <input type="search" name="search" id="search" class="form-control" placeholder="Search" required="required" aria-label="Search text" value=""/>
                                        <span class="input-group-btn">
                                            <button type="submit" class="btn btn-primary">
                                                <i class="fa fa-search"/>
                                            </button>
                                        </span>
                                    </div>
                                </form>
                                <hr/>
                                
                                <xsl:if test="m:translation/m:downloads/m:download[@type = ('pdf', 'epub', 'azw3')]">
                                    
                                    <h4>
                                        <xsl:value-of select="'Other ways to read'"/>
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
                                                    <td class="icon">
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
                                            
                                            <xsl:if test="m:translation[@status eq '1'] and $app-path">
                                                <xsl:variable name="app-href" select="concat($app-path, '/translation/', $toh-key, '.html')"/>
                                                <tr>
                                                    <td class="icon">
                                                        <a target="_blank">
                                                            <xsl:attribute name="title">
                                                                <xsl:call-template name="download-label">
                                                                    <xsl:with-param name="type" select="'app'"/>
                                                                </xsl:call-template>
                                                            </xsl:attribute>
                                                            <xsl:attribute name="href" select="$app-href"/>
                                                            <xsl:attribute name="class" select="'log-click'"/>
                                                            <xsl:attribute name="target" select="'84000-comms'"/>
                                                            <xsl:call-template name="download-icon">
                                                                <xsl:with-param name="type" select="'app'"/>
                                                            </xsl:call-template>
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <a target="_blank">
                                                            <xsl:attribute name="title">
                                                                <xsl:call-template name="download-label">
                                                                    <xsl:with-param name="type" select="'app'"/>
                                                                </xsl:call-template>
                                                            </xsl:attribute>
                                                            <xsl:attribute name="href" select="$app-href"/>
                                                            <xsl:attribute name="class" select="'log-click'"/>
                                                            <xsl:attribute name="target" select="'84000-comms'"/>
                                                            <xsl:call-template name="download-label">
                                                                <xsl:with-param name="type" select="'app'"/>
                                                            </xsl:call-template>
                                                        </a>
                                                    </td>
                                                </tr>
                                            </xsl:if>
                                            
                                        </tbody>
                                    </table>
                                    
                                    <hr/>
                                    
                                </xsl:if>
                                
                            </xsl:if>
                            
                            <xsl:if test="$communications-site-path">
                                <h4>
                                    <xsl:value-of select="'Spotted a mistake?'"/>
                                </h4>
                                <p class="small text-muted">
                                    <xsl:value-of select="'Please use the contact form provided to '"/>
                                    <a target="84000-comms">
                                        <xsl:attribute name="href" select="concat($communications-site-path, '/about/contact/?toh=', m:translation/m:source/m:toh[1] ,'#suggest-a-correction-section')"/>
                                        <xsl:value-of select="'suggest a correction'"/>
                                    </a>
                                    <xsl:value-of select="'.'"/>
                                </p>
                                <hr/>
                            </xsl:if>
                            
                            <h4>
                                <xsl:value-of select="'How to cite this text'"/>
                            </h4>
                            <p class="small text-muted">
                                <xsl:value-of select="'The following is an example of how to correctly cite this publication. '"/>
                                <xsl:value-of select="'Links to specific passages can be derived by right-clicking on the milestones markers in the left-hand margin (e.g. s.1). The copied link address can replace the url below.'"/>
                            </p>
                            <p class="small break">
                                <xsl:value-of select="concat(m:translation/m:publication/m:team[1]/m:label[1], ' (tr.). ')"/>
                                <xsl:value-of select="concat(m:translation/m:titles/m:title[@xml:lang eq 'en'],' ')"/>
                                <xsl:value-of select="'('"/>
                                <xsl:for-each select="(m:translation/m:titles/m:title[@xml:lang eq 'Sa-Ltn'], m:translation/m:titles/m:title[@xml:lang eq 'bo'])[1]">
                                    <span>
                                        <xsl:call-template name="class-attribute">
                                            <xsl:with-param name="lang" select="@xml:lang"/>
                                        </xsl:call-template>
                                        <xsl:value-of select="."/>
                                    </span>
                                </xsl:for-each>
                                <xsl:value-of select="concat(', ', m:translation/m:toh/m:full, '). ')"/>
                                <xsl:value-of select="concat('84000: Translating the Words of the Buddha, ', m:translation/m:publication/m:edition/tei:date[1], ': ')"/>
                                <br/>
                                <xsl:value-of select="m:translation/@canonical-html"/>
                            </p>
                            <hr/>
                            
                            <h4>
                                <xsl:value-of select="'Other links'"/>
                            </h4>
                            <table class="contents-table bottom-margin">
                                <tbody>
                                    
                                    <tr>
                                        <td class="icon">
                                            <a target="84000-comms">
                                                <xsl:attribute name="href" select="common:homepage-link('', /m:response/@lang)"/>
                                                <i class="fa fa-home"/>
                                            </a>
                                        </td>
                                        <td>
                                            <a target="84000-comms">
                                                <xsl:attribute name="href" select="common:homepage-link('', /m:response/@lang)"/>
                                                <xsl:value-of select="'84000 Homepage'"/>
                                            </a>
                                        </td>
                                    </tr>
                                    
                                    <tr>
                                        <td class="icon">
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
                                        <td class="icon">
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
                                    
                                    <!-- Add a link to other texts by this author -->
                                    <!--<xsl:for-each select="m:translation/m:source/m:attribution[@role eq 'author'][@ref]">
                                        <xsl:variable name="entity-id" select="replace(@ref, '^eft:', '')"/>
                                        <xsl:variable name="entity" select="/m:response/m:entities/m:entity/id($entity-id)"/>
                                        <xsl:variable name="page" select="$entity/m:instance[@type eq 'knowledgebase-article']/m:page"/>
                                        <xsl:variable name="href" select="common:internal-link(concat('/knowledgebase/', $page/@kb-id, '.html'), (), '', /m:response/@lang)"/>
                                        <tr>
                                            <td class="icon">
                                                <a>
                                                    <xsl:attribute name="href" select="$href"/>
                                                    <i class="fa fa-user"/>
                                                </a>
                                            </td>
                                            <td>
                                                <ul class="list-inline inline-dots">
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="href" select="$href"/>
                                                            <xsl:value-of select="'Other texts by '"/>
                                                            <span>
                                                                <xsl:call-template name="class-attribute">
                                                                    <xsl:with-param name="lang" select="@xml:lang"/>
                                                                </xsl:call-template>
                                                                <xsl:value-of select="normalize-space(text())"/> 
                                                            </span>
                                                        </a>
                                                    </li>
                                                </ul>
                                            </td>
                                        </tr>
                                    </xsl:for-each>-->
                                    
                                    <tr>
                                        <td class="icon">
                                            <a>
                                                <xsl:attribute name="href" select="common:internal-link('/search.html', (), '', /m:response/@lang)"/>
                                                <i class="fa fa-search"/>
                                            </a>
                                        </td>
                                        <td>
                                            <a>
                                                <xsl:attribute name="href" select="common:internal-link('/search.html', (), '', /m:response/@lang)"/>
                                                <xsl:value-of select="'Search the Reading Room'"/>
                                            </a>
                                        </td>
                                    </tr>
                                    
                                </tbody>
                            </table>
                            
                            <a class="btn btn-danger" target="84000-donate">
                                <xsl:attribute name="href">
                                    <xsl:call-template name="text">
                                        <xsl:with-param name="global-key" select="'about.common.sponsor-button-link'"/>
                                    </xsl:call-template>
                                </xsl:attribute>
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
                <xsl:if test="$part-status eq 'part' and $requested-part gt ''">
                    <xsl:value-of select="concat(' part-', $requested-part)"/>
                </xsl:if>
            </xsl:with-param>
            <xsl:with-param name="page-title" select="string-join(($page-title/data(), '84000 Reading Room'), ' / ')"/>
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
        <xsl:if test="$part[@content-status = ('complete', 'preview', 'passage')]">
            <div class="row">
                <div class="col-md-offset-1 col-md-10 col-lg-offset-2 col-lg-8 print-width-override">
                    
                    <xsl:element name="{ if($part[@content-status = ('complete')]) then 'section' else 'aside' }" namespace="http://www.w3.org/1999/xhtml">
                        
                        <xsl:attribute name="id" select="$part/@id"/>
                        
                        <xsl:call-template name="class-attribute">
                            
                            <xsl:with-param name="base-classes" as="xs:string*">
                                
                                <xsl:value-of select="concat('part-type-', $part/@type)"/>
                                <xsl:value-of select="$css-classes"/>
                                <xsl:value-of select="'tei-parser'"/>
                                
                            </xsl:with-param>
                            
                            <xsl:with-param name="html-classes" as="xs:string*">
                                
                                <xsl:choose>
                                    <!-- Expand all -->
                                    <xsl:when test="$view-mode[@layout = ('expanded', 'flat')]">
                                        <xsl:value-of select="'show'"/>
                                    </xsl:when>
                                    <!-- Expand only the complete part -->
                                    <xsl:when test="$part[@content-status eq 'complete'] and $part[@id eq $requested-part]">
                                        <xsl:value-of select="'show'"/>
                                    </xsl:when>
                                    <!-- Collapse and flag as .partial -->
                                    <xsl:when test="$part[@content-status eq 'preview']">
                                        <xsl:value-of select="'preview partial'"/>
                                    </xsl:when>
                                    <!-- Collapse by default -->
                                    <xsl:otherwise>
                                        <xsl:value-of select="'preview'"/>
                                        <!--<xsl:if test="$view-mode[@client eq 'browser']">
                                            <xsl:value-of select="'delay-render'"/>
                                        </xsl:if>-->
                                    </xsl:otherwise>
                                </xsl:choose>
                                
                                <xsl:value-of select="'relative'"/>
                                
                            </xsl:with-param>
                            
                        </xsl:call-template>
                        
                        <xsl:call-template name="data-location-id-attribute">
                            <xsl:with-param name="node" select="$part"/>
                        </xsl:call-template>
                        
                        <xsl:if test="$view-mode[not(@layout eq 'part-only')]">
                            <hr class="hidden-print"/>
                        </xsl:if>
                        
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
                        <xsl:if test="$part[@content-status = ('complete', 'preview')] and $view-mode[not(@layout = ('flat'))]">
                            
                            <xsl:call-template name="preview-controls">
                                
                                <xsl:with-param name="section-id" select="$part/@id"/>
                                <xsl:with-param name="log-click" select="true()"/>
                                
                                <!-- Provide complete navigation links so they will be followed by crawlers and right-click works -->
                                <xsl:with-param name="href" select="concat('/translation/', $toh-key, '.html?part=', $part/@id, m:view-mode-parameter(()), m:archive-path-parameter(), '#', $part/@id)"/>
                                
                                <!-- The javascript will intercept and use this in the RR, loading the part into the skeleton of the text -->
                                <xsl:with-param name="href-override">
                                    <xsl:if test="$view-mode[@client = ('browser', 'ajax')]">
                                        <xsl:value-of select="concat('#', $part/@id)"/>
                                    </xsl:if>
                                </xsl:with-param>
                                
                            </xsl:call-template>
                            
                        </xsl:if>
                        
                    </xsl:element>
                
                </div>
            </div>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template name="front-matter">
        
        <div class="row">
            <div class="col-md-offset-1 col-md-10 print-width-override">
                
                <section id="titles">
                    
                    <!-- Include an additional page warning about incompleteness of rendering -->
                    <xsl:if test="not($part-status eq 'complete')">
                        <div class="page page-first visible-print-block">
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
                    
                    <xsl:variable name="main-titles" select="m:translation/m:titles/m:title[text()]"/>
                    <xsl:variable name="long-titles" select="m:translation/m:long-titles/m:title[text()]"/>
                    
                    <!-- Main titles -->
                    <div>
                        
                        <xsl:call-template name="class-attribute">
                            <xsl:with-param name="base-classes" as="xs:string*">
                                <xsl:value-of select="'page'"/>
                                <xsl:if test="$part-status eq 'complete'">
                                    <xsl:value-of select="'page-first'"/>
                                </xsl:if>
                            </xsl:with-param>
                        </xsl:call-template>
                        
                        <div id="main-titles" class="ornamental-panel">
                            
                            <xsl:if test="$main-titles[@xml:lang eq 'bo']">
                                <div class="panel-row">
                                    <xsl:apply-templates select="$main-titles[@xml:lang eq 'bo']"/>
                                </div>
                            </xsl:if>
                            
                            <h1 class="panel-row title main-title">
                                <xsl:for-each select="$page-title">
                                    <xsl:choose>
                                        <xsl:when test="self::m:title">
                                            <span>
                                                <xsl:value-of select="."/>
                                            </span>
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
                            
                            <xsl:if test="$main-titles[@xml:lang eq 'Sa-Ltn']">
                                <div class="panel-row">
                                    <xsl:apply-templates select="$main-titles[@xml:lang eq 'Sa-Ltn']"/>
                                </div>
                            </xsl:if>
                            
                            <xsl:variable name="sourceAuthors" select="m:translation/m:source/m:attribution[@role eq 'author'][@ref]"/>
                            <xsl:if test="$sourceAuthors">
                                <div class="panel-row">
                                    <div class="small text-muted">
                                        <xsl:value-of select="'by'"/>
                                    </div>
                                    <div>
                                        <ul class="list-inline inline-dots">
                                            <xsl:for-each select="$sourceAuthors">
                                                <li>
                                                    <span>
                                                        <xsl:call-template name="class-attribute">
                                                            <xsl:with-param name="lang" select="@xml:lang"/>
                                                        </xsl:call-template>
                                                        <xsl:value-of select="normalize-space(text())"/> 
                                                    </span>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                    </div>
                                </div>
                            </xsl:if>
                            
                        </div>
                        
                        <xsl:if test="count($long-titles) eq 1 and $long-titles[@xml:lang eq 'Bo-Ltn'][text()]">
                            <div id="long-titles">
                                <xsl:apply-templates select="$long-titles[@xml:lang eq 'Bo-Ltn']"/>
                            </div>
                        </xsl:if>
                        
                        <xsl:variable name="supplementaryRoles" select="('translator', 'reviser')"/>
                        <xsl:for-each select="$supplementaryRoles">
                            <xsl:variable name="supplementaryRole" select="."/>
                            <xsl:variable name="roleAttributions" select="$root//m:translation/m:source/m:attribution[@role eq $supplementaryRole][@ref]"/>
                            <xsl:if test="$roleAttributions">
                                <div class="top-margin">
                                    <div class="small text-muted">
                                        <xsl:choose>
                                            <xsl:when test="$supplementaryRole eq 'reviser'">
                                                <xsl:value-of select="'Revision'"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'Tibetan translation'"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </div>
                                    <div>
                                        <ul class="list-inline inline-dots">
                                            <xsl:for-each select="$roleAttributions">
                                                <li>
                                                    <span>
                                                        <xsl:call-template name="class-attribute">
                                                            <xsl:with-param name="lang" select="@xml:lang"/>
                                                        </xsl:call-template>
                                                        <xsl:value-of select="normalize-space(text())"/> 
                                                    </span>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                    </div>
                                </div>
                            </xsl:if>
                        </xsl:for-each>
                        
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
                                <xsl:if test="m:translation/m:source[m:scope//text()]">
                                    <p id="location">
                                        <xsl:apply-templates select="m:translation/m:source/m:scope/node()"/>
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
                                
                                <xsl:call-template name="tantra-warning">
                                    <xsl:with-param name="id" select="'tantric-restriction-modal'"/>
                                    <xsl:with-param name="node" select="m:translation/m:publication/m:tantric-restriction/tei:p"/>
                                    <xsl:with-param name="modal-only" select="true()"/>
                                    <xsl:with-param name="restricted-text-id" select="$toh-key"/>
                                </xsl:call-template>
                                
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
                                
                                <xsl:if test="m:translation[@status eq '1'] and $app-path">
                                    <a target="_blank">
                                        <xsl:attribute name="title">
                                            <xsl:call-template name="download-label">
                                                <xsl:with-param name="type" select="'app'"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                        <xsl:attribute name="href" select="concat($app-path, '/translation/', $toh-key, '.html')"/>
                                        <xsl:attribute name="class" select="'btn-round log-click'"/>
                                        <xsl:call-template name="download-icon">
                                            <xsl:with-param name="type" select="'app'"/>
                                        </xsl:call-template>
                                    </a>
                                </xsl:if>
                                
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
                
            </div>
        </div>
        
    </xsl:template>
    
    <xsl:template name="body-title">
        
        <xsl:if test="m:translation/m:part[@type eq 'translation'] and $view-mode[not(@layout eq 'part-only')]">
            <div class="row">
                <div class="col-md-offset-1 col-md-10 col-lg-offset-2 col-lg-8 print-width-override">
                    
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
                                
                                <xsl:variable name="translation-part-head" select="m:translation/m:part[@type eq 'translation']/tei:head[@type eq 'translation'][text()][1]" as="element(tei:head)?"/>
                                <xsl:variable name="main-title" select="m:translation/m:part[@type eq 'translation']/m:main-title[text()]" as="element(m:main-title)?"/>
                                <xsl:variable name="first-part-head" select="m:translation/m:part[@type eq 'translation']/m:part[1]/tei:head[@type eq parent::m:part/@type][text()][1]" as="element(tei:head)?"/>
                                
                                <!-- If the first paret head is the same as the main title we want to use the translation part head in the first chapter, so not here -->
                                <xsl:if test="$translation-part-head and not(data($first-part-head) eq data($main-title))">
                                    <div class="h3">
                                        <xsl:value-of select="$translation-part-head"/>
                                    </div>
                                </xsl:if>
                                
                                <xsl:if test="m:translation/m:part[@type eq 'translation']/m:honoration[text()]">
                                    <div class="h2 break">
                                        <xsl:apply-templates select="m:translation/m:part[@type eq 'translation']/m:honoration"/>
                                    </div>
                                </xsl:if>
                                
                                <xsl:if test="$main-title">
                                    <div class="h1 break">
                                        <xsl:apply-templates select="$main-title"/>
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
                    
                </div>
            </div>
        </xsl:if>
        
    </xsl:template>
    
</xsl:stylesheet>