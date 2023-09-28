<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:m="http://read.84000.co/ns/1.0" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="3.0">

    <xsl:import href="../../xslt/tei-to-xhtml.xsl"/>
    
    <xsl:variable name="request" select="/m:response/m:request"/>
    <xsl:variable name="selected-type" select="$request/m:article-types/m:type[@selected eq 'selected']" as="element(m:type)*"/>

    <xsl:variable name="page-url" select="concat($reading-room-path, '/knowledgebase.html?') || string-join(($selected-type ! concat('article-type[]=', @id), $request/@sort ! concat('sort=', .)), '&amp;')" as="xs:string"/>

    <xsl:template match="/m:response">

        <xsl:variable name="content">

            <!-- Title band -->
            <div class="title-band hidden-print">
                <div class="container">
                    <div class="center-vertical-sm full-width">

                        <div>
                            <nav role="navigation" aria-label="Breadcrumbs">
                                <ul class="breadcrumb">

                                    <li>
                                        <xsl:value-of select="'84000 Knowledge Base'"/>
                                    </li>

                                </ul>
                            </nav>
                        </div>

                        <div>
                            <div class="center-vertical pull-right">

                                <div>
                                    <a href="#bookmarks-sidebar" id="bookmarks-btn" class="show-sidebar center-vertical" role="button" aria-haspopup="true" aria-expanded="false">
                                        <span>
                                            <span class="btn-round sml">
                                                <i class="fa fa-bookmark"/>
                                                <span class="badge badge-notification">0</span>
                                            </span>
                                        </span>
                                        <span class="btn-round-text">
                                            <xsl:value-of select="'Bookmarks'"/>
                                        </span>
                                    </a>
                                </div>

                            </div>
                        </div>

                    </div>
                </div>
            </div>

            <!-- Include the bookmarks sidebar -->
            <xsl:variable name="bookmarks-sidebar">
                <m:bookmarks-sidebar>
                    <xsl:copy-of select="$eft-header/m:translation"/>
                </m:bookmarks-sidebar>
            </xsl:variable>
            <xsl:apply-templates select="$bookmarks-sidebar"/>

            <main class="content-band" id="knowledgebase-index">
                <div class="container">

                    <div class="section-title row">
                        <div class="col-sm-8 col-sm-offset-2">
                            <h1 class="main-title">
                                <xsl:value-of select="'84000 Knowledge Base'"/>
                            </h1>
                            <hr/>
                            <p>
                                <xsl:value-of select="'Our collection of supplementary articles about themes, people and places from the Tibetan Buddhist canon.'"/>
                            </p>
                            <p>
                                <xsl:value-of select="'This is a provisional page for browsing the articles. '"/>
                                <xsl:value-of select="'To search for articles please use the '"/>
                                <a href="/search.html?search-type=tei&amp;search-data[]=knowledgebase">
                                    <xsl:value-of select="'publications search'"/>
                                </a>
                                <xsl:value-of select="'.'"/>
                            </p>
                            <xsl:choose>
                                <xsl:when test="$tei-editor-off">
                                    <div class="well well-sm">
                                        <p class="small">
                                            <xsl:value-of select="'For more options activate '"/>
                                            <a href="{ $page-url }&amp;view-mode=editor" class="editor">
                                                <xsl:value-of select="'editor mode'"/>
                                            </a>
                                            <xsl:value-of select="'.'"/>
                                        </p>
                                    </div>
                                </xsl:when>
                                <xsl:when test="$tei-editor">
                                    <div class="well well-sm">
                                        <p class="small">Existing knowledge base articles and stubs may be found here or in our shared <a href="https://drive.google.com/drive/folders/11Q3B4lc7lZR_rufoupFZ5Nv4whNT9Lzc" target="84000-google-drive">Google Drive</a>. Please check both locations for any existing content.</p>
                                        <p class="small">If you find an article here you would like to contribute to you can try editing it yourself in editor mode.</p>
                                        <p class="small">Otherwise just search the Google Drive and add your content there. The owner of the document will automatically be notified of your changes. Once an article has enough content it can be passed onto the digital editors to publish the article.</p>
                                        <ul class="list-inline inline-dots">
                                            <li>
                                                <a href="/search.html?search-type=tei&amp;search-data[]=knowledgebase" target="_self" class="editor">
                                                    <xsl:value-of select="'Search for articles'"/>
                                                </a>
                                            </li>
                                            <li>
                                                <a href="https://drive.google.com/drive/folders/11Q3B4lc7lZR_rufoupFZ5Nv4whNT9Lzc" target="84000-google-drive" class="editor">
                                                    <xsl:value-of select="'Search Google Drive'"/>
                                                </a>
                                            </li>
                                            <li>
                                                <a target="84000-operations" class="editor">
                                                    <xsl:attribute name="href" select="'/create-article.html#ajax-source'"/>
                                                    <xsl:attribute name="data-ajax-target" select="'#popup-footer-editor .data-container'"/>
                                                    <xsl:attribute name="data-editor-callbackurl" select="common:internal-link(concat($reading-room-path, '/knowledgebase.html?') || string-join(('article-type[]=articles', 'sort=latest', 'view-mode=editor'), '&amp;'), (), '#articles-list', $root/m:response/@lang)"/>
                                                    <xsl:value-of select="'Start a new article'"/>
                                                </a>
                                            </li>
                                            <li>
                                                <a href="mailto:knowledgebase@84000.co" class="editor">Get some help</a>
                                            </li>
                                            <li>
                                                <a href="{ $page-url }" target="_self" class="editor">
                                                    <xsl:value-of select="'Hide editor'"/>
                                                </a>
                                            </li>
                                        </ul>
                                    </div>
                                </xsl:when>
                            </xsl:choose>
                        </div>
                    </div>

                    <div id="articles-list" class="row">
                        <div class="col-sm-offset-1 col-sm-10">

                            <form action="/knowledgebase.html" method="get" role="search" class="form-inline form-filter" data-loading="Searching...">

                                <xsl:if test="$view-mode[@id eq 'editor']">
                                    <input type="hidden" name="view-mode" value="editor"/>
                                </xsl:if>

                                <!-- Type checkboxes -->
                                <div class="align-center bottom-margin">

                                    <div class="form-group">

                                        <xsl:for-each select="m:request/m:article-types/m:type">
                                            <div class="checkbox">
                                                <label>
                                                    <input type="checkbox" name="article-type[]">
                                                        <xsl:attribute name="value" select="@id"/>
                                                        <xsl:if test="@selected eq 'selected'">
                                                            <xsl:attribute name="checked" select="'checked'"/>
                                                        </xsl:if>
                                                    </input>
                                                    <xsl:value-of select="' ' || text()"/>
                                                </label>
                                            </div>
                                        </xsl:for-each>

                                        <!-- Results summary -->
                                        <div class="checkbox">
                                            <div class="center-vertical align-center">
                                                <span>
                                                    <span class="badge">
                                                        <xsl:value-of select="m:knowledgebase/@count-pages ! format-number(xs:integer(.), '#,###')"/>
                                                    </span>
                                                    <span class="badge-text">
                                                        <xsl:choose>
                                                            <xsl:when test="m:knowledgebase/@count-pages ! xs:integer(.) eq 1">
                                                                <xsl:value-of select="'article'"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="'articles'"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </span>
                                                </span>
                                            </div>
                                        </div>

                                        <select name="sort" class="form-control">
                                            <option value="latest">
                                                <xsl:if test="$request[@sort eq 'latest']">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'Most recent'"/>
                                            </option>
                                            <option value="name">
                                                <xsl:if test="$request[@sort eq 'name']">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="'Sort A-Z'"/>
                                            </option>
                                        </select>

                                        <button type="submit" class="btn btn-primary btn-sm" title="Search">
                                            <i class="fa fa-refresh"/>
                                            <xsl:value-of select="' Reload'"/>
                                        </button>

                                    </div>

                                </div>

                            </form>

                            <xsl:choose>
                                <xsl:when test="m:knowledgebase[m:page]">

                                    <!-- Articles list -->
                                    <div class="list-group accordion">

                                        <xsl:for-each select="m:knowledgebase/m:page">

                                            <!-- Article -->
                                            <div class="list-group-item row">
                                                <div class="col-sm-12">

                                                    <!-- Title / type -->
                                                    <div class="center-vertical full-width">
                                                        
                                                        <div>
                                                            <h3 class="no-top-margin">
                                                                <a>
                                                                    <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', @kb-id, '.html')"/>
                                                                    <xsl:value-of select="m:titles ! (m:title[@type eq 'articleTitle'], m:title[@type eq 'mainTitle'][@xml:lang eq 'en'], m:title[@type eq 'mainTitle'])[1]"/>
                                                                </a>
                                                            </h3>
                                                        </div>
                                                        
                                                        <div class="text-right">
                                                            <span class="label label-default">
                                                                <xsl:choose>
                                                                    <xsl:when test="@type eq 'section'">
                                                                        <xsl:value-of select="'Section'"/>
                                                                    </xsl:when>
                                                                    <xsl:when test="@type eq 'author'">
                                                                        <xsl:value-of select="'Author'"/>
                                                                    </xsl:when>
                                                                    <xsl:when test="@type eq 'article'">
                                                                        <xsl:value-of select="'Article'"/>
                                                                    </xsl:when>
                                                                </xsl:choose>
                                                            </span>
                                                        </div>

                                                    </div>

                                                    <!-- Abstract -->
                                                    <xsl:if test="m:summary ! m:has-user-content(.)">
                                                        <xsl:apply-templates select="m:summary/*"/>
                                                    </xsl:if>

                                                    <!-- Actions (if multiple) -->
                                                    <xsl:if test="m:section[@id]">
                                                        <ul class="list-inline inline-dots small">
                                                            <li>
                                                                <a class="underline">
                                                                    <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', @kb-id, '.html')"/>
                                                                    <xsl:value-of select="'Read the article'"/>
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a class="underline">
                                                                    <xsl:attribute name="href" select="concat('/section/', m:section/@id, '.html')"/>
                                                                    <xsl:value-of select="'Browse the texts'"/>
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </xsl:if>

                                                    <!-- Editor options -->
                                                    <xsl:if test="$tei-editor">
                                                        <div class="well well-sm">

                                                            <div class="center-vertical full-width">

                                                                <!-- File path -->
                                                                <div>
                                                                    <a class="text-muted small">
                                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', @kb-id, '.tei')"/>
                                                                        <xsl:attribute name="target" select="concat(@xml:id, '.tei')"/>
                                                                        <xsl:value-of select="@document-url"/>
                                                                    </a>
                                                                </div>

                                                                <!-- Status -->
                                                                <div class="text-right">
                                                                    <span>
                                                                        <xsl:choose>
                                                                            <xsl:when test="@status-group eq 'published'">
                                                                                <xsl:attribute name="class" select="'label label-success'"/>
                                                                                <xsl:value-of select="'Published'"/>
                                                                            </xsl:when>
                                                                            <xsl:when test="@status-group eq 'in-progress'">
                                                                                <xsl:attribute name="class" select="'label label-warning'"/>
                                                                                <xsl:value-of select="'In-progress'"/>
                                                                            </xsl:when>
                                                                            <xsl:otherwise>
                                                                                <xsl:attribute name="class" select="'label label-default'"/>
                                                                                <xsl:value-of select="'Not published'"/>
                                                                            </xsl:otherwise>
                                                                        </xsl:choose>
                                                                    </span>
                                                                </div>

                                                            </div>

                                                            <!-- Alert if file locked -->
                                                            <xsl:if test="@locked-by-user gt ''">
                                                                <div class="sml-margin bottom">
                                                                    <span class="label label-danger">
                                                                        <xsl:value-of select="concat('WARNING: This file is currenly locked by user ', @locked-by-user)"/>
                                                                    </span>
                                                                </div>
                                                            </xsl:if>

                                                            <!-- Actions -->
                                                            <div>
                                                                <ul class="list-inline inline-dots">
                                                                    <li>
                                                                        <a class="editor">
                                                                            <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', @kb-id, '.html?view-mode=editor')"/>
                                                                            <xsl:attribute name="target" select="concat(@xml:id, '.html')"/>
                                                                            <xsl:value-of select="'Edit article'"/>
                                                                        </a>
                                                                    </li>
                                                                    <li>
                                                                        <a class="editor">
                                                                            <xsl:attribute name="href" select="concat($environment/m:url[@id eq 'operations'], '/edit-kb-header.html?id=', @xml:id)"/>
                                                                            <xsl:attribute name="target" select="'_blank'"/>
                                                                            <xsl:value-of select="'Edit headers'"/>
                                                                        </a>
                                                                    </li>
                                                                    <li>
                                                                        <a class="editor">
                                                                            <xsl:attribute name="href" select="concat($environment/m:url[@id eq 'operations'],'/edit-glossary.html?resource-id=', @xml:id, '&amp;resource-type=knowledgebase')"/>
                                                                            <xsl:attribute name="target" select="'84000-glossary-tool'"/>
                                                                            <xsl:value-of select="'Edit glossary'"/>
                                                                        </a>
                                                                    </li>
                                                                </ul>
                                                            </div>

                                                        </div>
                                                    </xsl:if>

                                                </div>
                                            </div>

                                        </xsl:for-each>

                                    </div>

                                </xsl:when>
                                <xsl:otherwise>
                                    <div class="text-center text-muted">
                                        <p class="italic">
                                            <xsl:value-of select="'~ No matches for this query ~'"/>
                                        </p>
                                    </div>
                                </xsl:otherwise>
                            </xsl:choose>

                            <!-- Pagination -->
                            <xsl:sequence select="common:pagination(m:request/@first-record, m:request/@records-per-page, m:knowledgebase/@count-pages, common:internal-link($page-url, (m:view-mode-parameter((),())),(), /m:response/@lang))"/>

                        </div>
                    </div>

                </div>
            </main>
            
            <xsl:call-template name="tei-editor-footer"/>
            
        </xsl:variable>

        <!-- Compile with page template -->
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="'http://read.84000.co/knowledgebase.html'"/>
            <xsl:with-param name="page-class" select="'reading-room section'"/>
            <xsl:with-param name="page-title" select="'84000 Knowledge Base'"/>
            <xsl:with-param name="page-description" select="''"/>
            <xsl:with-param name="content" select="$content"/>
            <xsl:with-param name="additional-links">
                <script src="https://code.highcharts.com/highcharts.js"/>
            </xsl:with-param>
        </xsl:call-template>

    </xsl:template>

</xsl:stylesheet>