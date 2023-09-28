<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:m="http://read.84000.co/ns/1.0" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:import href="../../xslt/tei-to-xhtml.xsl"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment" select="/m:response/m:environment"/>
    <xsl:variable name="front-end-path" select="$environment/m:url[@id eq 'front-end']/text()"/>
    <xsl:variable name="render-status" select="$environment/m:render/m:status[@type eq 'article']/@status-id"/>
    
    <xsl:variable name="article-id" select="$article/m:page/@xml:id"/>
    <xsl:variable name="article-title" select="($article/m:page/m:titles/m:title[@type eq 'articleTitle'], $article/m:page/m:titles/m:title[@type eq 'mainTitle'][@xml:lang eq 'en'], $article/m:page/m:titles/m:title[@type eq 'mainTitle'])[1]"/>
    <xsl:variable name="article-entity" select="$entities[m:instance[@id eq $article-id]][1]"/>

    <xsl:template match="/m:response">
        
        <!-- PAGE CONTENT -->
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
                                    
                                    <li>
                                        <xsl:value-of select="$article-title"/>
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
            
            <!-- Publication warning -->
            <xsl:if test="not($article/m:page[@status-group eq 'published'])">
                <div class="title-band warning">
                    <div class="container">
                        <xsl:value-of select="'This text is not yet ready for publication!'"/>                      
                    </div>
                </div>
            </xsl:if>
            
            <xsl:variable name="attributed-texts" select="$article/m:part[@type eq 'related-texts']/m:text"/>
            
            <xsl:variable name="parts-with-content" as="element(m:part)*">
                <xsl:for-each select="$article/m:part[@type eq 'article']/m:part[@type eq 'section'] | $article/m:part[not(@type = ('article','related-texts','end-notes'))]">
                    <xsl:if test="m:has-user-content(.)">
                        <xsl:sequence select="."/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            
            <xsl:variable name="notes-with-content" as="element(tei:note)*">
                <xsl:for-each select="$parts-with-content//tei:note[@place eq 'end'][@xml:id]">
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:variable>
            
            <div class="content-band">
                <div class="container">
                    <div class="row">
                        
                        <main class="col-md-8 col-lg-9">
                            
                            <h1 id="title">
                                <!--<xsl:apply-templates select="$article-title"/>-->
                                <xsl:value-of select="$article-title"/>
                            </h1>
                            
                            <xsl:variable name="otherTitles" select="$article/m:page/m:titles/m:title[not(@xml:lang eq 'en')] except $article-title"/>
                            
                            <xsl:if test="$otherTitles">
                                <ul class="small">
                                    <xsl:for-each-group select="$otherTitles" group-by="@xml:lang">
                                        <li>
                                            <xsl:value-of select="common:lang-label(@xml:lang)"/>
                                            <span>
                                                <xsl:call-template name="class-attribute">
                                                    <xsl:with-param name="lang" select="@xml:lang"/>
                                                </xsl:call-template>
                                                <xsl:value-of select="text()[1]"/>
                                            </span>
                                        </li>
                                    </xsl:for-each-group>
                                </ul>
                            </xsl:if>
                            
                            <p class="italic text-muted">
                                <xsl:value-of select="concat(if($article/m:publication/m:publication-date[matches(text(), '^[0-9]{4}')]) then concat('First published ', $article/m:publication/m:publication-date ! replace(text(), '^([0-9]{4})(.*)', '$1'), '. ') else (), 'Last updated ', format-dateTime($article/m:page/@last-updated, '[D1o] [MNn,*-3] [Y0001]'), '.')"/>
                            </p>
                            
                            <div id="parts">
                                
                                <xsl:choose>
                                    <xsl:when test="$article/m:part[@type eq 'abstract'] ! m:has-user-content(.)">
                                        <section id="abstract" class="tei-parser rw-no-gtr">
                                            <xsl:apply-templates select="$article/m:part[@type eq 'abstract']/*"/>
                                        </section>
                                    </xsl:when>
                                    <xsl:when test="$tei-editor">
                                        <section id="abstract" class="tei-parser rw-no-gtr">
                                            <form action="/tei-editor.html" method="post" class="bottom-margin">
                                                
                                                <xsl:attribute name="data-ajax-target" select="'#ajax-source'"/>
                                                <xsl:attribute name="data-ajax-target-callbackurl" select="concat($reading-room-path, '/knowledgebase/', $article/m:page/@kb-id, '.html?view-mode=editor#parts')"/>
                                                
                                                <input type="hidden" name="form-action" value="add-element"/>
                                                <input type="hidden" name="resource-id" value="{ $article-id }"/>
                                                <input type="hidden" name="resource-type" value="knowledgebase"/>
                                                <input type="hidden" name="new-element-name" value="abstract-part-create"/>
                                                <input type="hidden" name="return" value="none"/>
                                                
                                                <button type="submit" class="btn-link editor" data-loading="Adding section...">
                                                    <xsl:value-of select="'Add an abstract'"/>
                                                </button>
                                                
                                            </form>
                                        </section>
                                    </xsl:when>
                                </xsl:choose>
                                
                                <xsl:if test="$article/m:page[@status = $render-status] or $tei-editor">
                                    
                                    <xsl:if test="$parts-with-content[@type eq 'section']">
                                        <section id="body" class="tei-parser">
                                            <xsl:apply-templates select="$article/m:part[@type eq 'article']"/>
                                        </section>
                                    </xsl:if>
                                    
                                </xsl:if>
                                
                                <xsl:if test="$attributed-texts">
                                    
                                    <xsl:if test="not($tei-editor) and (not($article/m:page[@status = $render-status]) or not($parts-with-content[@type eq 'section']))">
                                        <section id="disclaimer" class="tei-parser">
                                            <p class="italic text-muted">This knowledge base page is incomplete; biographical, historical, and other details have yet to be added. In the meantime, it is provided to allow readers to see a list of all the works attributed to this author.</p>
                                        </section>
                                    </xsl:if>
                                    
                                    <section id="attributed-texts" class="tei-parser">
                                        
                                        <h2>
                                            <xsl:apply-templates select="$article/m:part[@type eq 'related-texts']/tei:head/node()"/>
                                        </h2>
                                        
                                        <div class="list-group accordion" id="attributed-texts-list">
                                            
                                            <xsl:for-each-group select="$attributed-texts" group-by="m:parent/@id">
                                                
                                                <xsl:sort select="m:parent[1]/@id"/>
                                                
                                                <xsl:call-template name="expand-item">
                                                    <xsl:with-param name="id" select="concat('attributed-texts-', m:parent[1]/@id)"/>
                                                    <xsl:with-param name="accordion-selector" select="'#attributed-texts-list'"/>
                                                    <xsl:with-param name="title-opener" select="false()"/>
                                                    <xsl:with-param name="active" select="if(count($attributed-texts) le 5) then true() else false()"/>
                                                    <xsl:with-param name="persist" select="true()"/>
                                                    <xsl:with-param name="title">
                                                        
                                                        <div class="list-group-item-heading">
                                                            
                                                            <h3>
                                                                
                                                                <a class="no-underline">
                                                                    <xsl:attribute name="href" select="common:internal-link(concat('/section/', m:parent[1]/@id, '.html'), (), '', /m:response/@lang)"/>
                                                                    <xsl:value-of select="m:parent[1]/m:titles/m:title[@xml:lang eq 'en'][1]"/>
                                                                </a>
                                                                
                                                                <xsl:value-of select="' '"/>
                                                                <span class="label label-default">
                                                                    <xsl:value-of select="count(current-group())"/>
                                                                </span>
                                                                
                                                                <xsl:choose>
                                                                    <xsl:when test="count(current-group()[@status-group eq 'published']) gt 0">
                                                                        <xsl:value-of select="' '"/>
                                                                        <span class="label label-default">
                                                                            <xsl:value-of select="concat(count(current-group()[@status-group eq 'published']), ' published')"/>
                                                                        </span>
                                                                    </xsl:when>
                                                                </xsl:choose>
                                                                
                                                            </h3>
                                                            
                                                        </div>
                                                        
                                                        <div role="navigation" title="The location of this section" class="text-muted small">
                                                            <xsl:value-of select="'In '"/>
                                                            <ul class="breadcrumb">
                                                                <xsl:sequence select="common:breadcrumb-items(m:parent[1]/descendant::m:parent[not(@id eq 'LOBBY')], /m:response/@lang)"/>
                                                            </ul>
                                                        </div>
                                                        
                                                    </xsl:with-param>
                                                    <xsl:with-param name="content">
                                                        
                                                        <div class="text-list top-margin">
                                                            
                                                            <div class="row table-headers hidden-print">
                                                                
                                                                <div class="col-sm-10">
                                                                    <xsl:value-of select="'Title'"/>
                                                                </div>
                                                                
                                                                <div class="col-sm-2 hidden-xs">
                                                                    <xsl:value-of select="'Toh / Status'"/>
                                                                </div>
                                                                
                                                            </div>
                                                            
                                                            <div>
                                                                <xsl:for-each-group select="current-group()" group-by="@id">
                                                                    
                                                                    <xsl:sort select="number(m:toh[1]/@number)"/>
                                                                    <xsl:sort select="m:toh[1]/@letter"/>
                                                                    <xsl:sort select="number(m:toh[1]/@chapter-number)"/>
                                                                    <xsl:sort select="m:toh[1]/@chapter-letter"/>
                                                                    
                                                                    <xsl:variable name="text" select="."/>
                                                                    
                                                                    <div class="row list-item" id="text-item-{ $text/@id }">
                                                                        
                                                                        <div class="col-sm-10 bottom-margin-xs">
                                                                            
                                                                            <h4 class="item-title">
                                                                                
                                                                                <xsl:variable name="title" as="xs:string*">
                                                                                    <xsl:if test="$text/m:titles/m:parent">
                                                                                        <xsl:value-of select="concat($text/m:titles/m:parent/m:titles/m:title[@xml:lang eq 'en'], ', ')"/>
                                                                                    </xsl:if>
                                                                                    <xsl:value-of select="$text/m:titles/m:title[@xml:lang eq 'en']"/>
                                                                                </xsl:variable>
                                                                                
                                                                                <xsl:choose>
                                                                                    <xsl:when test="$text/@status eq '1'">
                                                                                        <a>
                                                                                            <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $text/m:toh/@key, '.html')"/>
                                                                                            <xsl:attribute name="target" select="concat($text/@id, '.html')"/>
                                                                                            <xsl:value-of select="$title"/>
                                                                                        </a>
                                                                                    </xsl:when>
                                                                                    <xsl:otherwise>
                                                                                        <xsl:value-of select="$title"/>
                                                                                    </xsl:otherwise>
                                                                                </xsl:choose>
                                                                                
                                                                            </h4>
                                                                            
                                                                            <ul class="list-unstyled sml-margin bottom">
                                                                                <xsl:for-each select="('bo', 'Bo-Ltn', 'Sa-Ltn', 'zh')">
                                                                                    
                                                                                    <xsl:variable name="lang" select="."/>
                                                                                    <xsl:variable name="title" select="$text/m:titles/m:title[@xml:lang eq $lang][1][text()]"/>
                                                                                    
                                                                                    <xsl:if test="$title">
                                                                                        <li>
                                                                                            <span>
                                                                                                <xsl:attribute name="class" select="common:lang-class($title/@xml:lang)"/>
                                                                                                <xsl:value-of select="$title"/>
                                                                                            </span>
                                                                                        </li>
                                                                                    </xsl:if>
                                                                                    
                                                                                </xsl:for-each>
                                                                            </ul>
                                                                            
                                                                            <xsl:if test="$text/m:publication/m:tantric-restriction/tei:p">
                                                                                <xsl:call-template name="tantra-warning">
                                                                                    <xsl:with-param name="id" select="$text/@id"/>
                                                                                    <xsl:with-param name="node" select="$text/m:publication/m:tantric-restriction/tei:p"/>
                                                                                </xsl:call-template>
                                                                            </xsl:if>
                                                                            
                                                                            <xsl:call-template name="expandable-summary">
                                                                                <xsl:with-param name="text" select="$text"/>
                                                                                <xsl:with-param name="expand-id" select="concat('summary-detail-', $text/@id)"/>
                                                                                <xsl:with-param name="prepend-hr" select="false()"/>
                                                                            </xsl:call-template>
                                                                            
                                                                        </div>
                                                                        
                                                                        <div class="col-sm-2">
                                                                            
                                                                            <div class="small">
                                                                                <xsl:value-of select="$text/m:toh/m:full"/>
                                                                            </div>
                                                                            
                                                                            <div class="small text-warning">
                                                                                <xsl:value-of select="format-number($text/m:source/m:location/@count-pages, '#,###')"/>
                                                                                <xsl:choose>
                                                                                    <xsl:when test="$text/m:source/m:location/@count-pages ! xs:integer(.) eq 1">
                                                                                        <xsl:value-of select="' page'"/>
                                                                                    </xsl:when>
                                                                                    <xsl:otherwise>
                                                                                        <xsl:value-of select="' pages'"/>
                                                                                    </xsl:otherwise>
                                                                                </xsl:choose>
                                                                            </div>
                                                                            
                                                                            <div class="italic small">
                                                                                <xsl:choose>
                                                                                    <xsl:when test="$text/@status-group eq 'published'">
                                                                                        <xsl:attribute name="class" select="'italic small text-success'"/>
                                                                                        <xsl:value-of select="'Published'"/>
                                                                                    </xsl:when>
                                                                                    <xsl:when test="$text/@status-group = ('translated', 'in-translation')">
                                                                                        <xsl:attribute name="class" select="'italic small text-warning'"/>
                                                                                        <xsl:value-of select="'In progress'"/>
                                                                                    </xsl:when>
                                                                                    <xsl:when test="$text/@status-group eq 'in-application'">
                                                                                        <xsl:attribute name="class" select="'italic small text-warning'"/>
                                                                                        <xsl:value-of select="'Application pending'"/>
                                                                                    </xsl:when>
                                                                                    <xsl:otherwise>
                                                                                        <xsl:attribute name="class" select="'italic small text-muted'"/>
                                                                                        <xsl:value-of select="'Not Started'"/>
                                                                                    </xsl:otherwise>
                                                                                </xsl:choose>
                                                                            </div>
                                                                            
                                                                        </div>
                                                                        
                                                                        
                                                                    </div>
                                                                    
                                                                </xsl:for-each-group>
                                                            </div>
                                                            
                                                        </div>
                                                        
                                                    </xsl:with-param>
                                                </xsl:call-template>
                                                
                                            </xsl:for-each-group>
                                            
                                        </div>
                                        
                                    </section>
                                
                                </xsl:if>
                                
                                <xsl:if test="$article/m:page[@status = $render-status] or $tei-editor">
                                    
                                    <xsl:if test="$parts-with-content[@type eq 'bibliography']">
                                        <section id="bibliography" class="tei-parser">
                                            <xsl:apply-templates select="$article/m:part[@type eq 'bibliography']/*"/>
                                        </section>
                                    </xsl:if>
                                    
                                    <xsl:if test="$notes-with-content">
                                        <section id="end-notes" class="tei-parser">
                                            <!--<hr class="hidden-print"/>-->
                                           <xsl:call-template name="end-notes"/>
                                        </section>
                                    </xsl:if>
                                    
                                    <xsl:if test="$parts-with-content[@type eq 'section'] and $article/m:part[@type eq 'glossary']/tei:gloss">
                                        <section id="glossary" class="tei-parser">
                                            <xsl:call-template name="glossary"/>
                                        </section>
                                    </xsl:if>
                                    
                                </xsl:if>
                            
                            </div>
                            
                        </main>
                        
                        <aside class="col-md-4 col-lg-3">
                            
                            <!-- Alert locked file -->
                            <xsl:if test="$tei-editor and $article/m:page[@locked-by-user gt '']">
                                <div class="alert alert-danger break" role="alert">
                                    <xsl:value-of select="concat('File ', $article/m:page/@document-url, ' is currenly locked by user ', $article/m:page/@locked-by-user, '. ')"/>
                                    <xsl:value-of select="'You cannot modify this file until the lock is released.'"/>
                                </div>
                            </xsl:if>
                            
                            <!-- If it could be TEI editor but isn't, show a button -->
                            <xsl:if test="$tei-editor-off">
                                <div class="well">
                                    <a>
                                        <xsl:attribute name="href" select="'?view-mode=editor'"/>
                                        <xsl:attribute name="class" select="'editor'"/>
                                        <xsl:value-of select="'Show editor'"/>
                                    </a>
                                </div>
                            </xsl:if>
                            
                            <!-- Link to header form / glossary editor -->
                            <!-- Knowledge base only, editor mode, operations app, no child divs and an id -->
                            <xsl:if test="$tei-editor">
                                
                                <div class="well">
                                    
                                    <h3 class="no-top-margin">
                                        <xsl:value-of select="'Editor options '"/>
                                        <span>
                                            <xsl:choose>
                                                <xsl:when test="$article/m:page[@status eq '1']">
                                                    <xsl:attribute name="class" select="'label label-success'"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:attribute name="class" select="'label label-warning'"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <xsl:value-of select="$article/m:page/@status"/>
                                        </span>
                                    </h3>
                                    
                                    <xsl:if test="$article-id gt ''">
                                        
                                        <ul>
                                            <li>
                                                <a class="editor" target="84000-operations">
                                                    <xsl:attribute name="href" select="concat($environment/m:url[@id eq 'operations']/text(), '/edit-kb-header.html', '?id=', $article-id)"/>
                                                    <xsl:value-of select="'Edit headers'"/>
                                                </a>
                                            </li>
                                            <li>
                                                <a class="editor" target="84000-glossary-tool">
                                                    <xsl:attribute name="href" select="concat($environment/m:url[@id eq 'operations']/text(), '/edit-glossary.html', '?resource-id=', $article-id, '&amp;resource-type=knowledgebase')"/>
                                                    <xsl:value-of select="'Edit glossary'"/>
                                                </a>
                                            </li>
                                            <li>
                                                <a class="editor" target="tei-editor">
                                                    <xsl:attribute name="href" select="concat('/tei-editor.html?resource-type=knowledgebase&amp;resource-id=', $article-id,'&amp;passage-id=locking#ajax-source')"/>
                                                    <xsl:attribute name="data-ajax-target" select="'#popup-footer-editor .data-container'"/>
                                                    <xsl:value-of select="'Lock / unlock file'"/>
                                                </a>
                                            </li>
                                            <li>
                                                <a href="mailto:knowledgebase@84000.co" class="editor">Get some help</a>
                                            </li>
                                            <li>
                                                <a class="editor" target="_self">
                                                    <xsl:attribute name="href" select="concat('?timestamp=', current-dateTime())"/>
                                                    <xsl:value-of select="'Hide editor'"/>
                                                </a>
                                            </li>
                                        </ul>
                                        
                                    </xsl:if>
                                    
                                </div>
                                
                            </xsl:if>
                            
                            <!-- Table of contents -->
                            <xsl:if test="count($parts-with-content) gt 2 or $tei-editor">
                                
                                <div class="panel panel-default">
                                    <div class="panel-body">
                                        
                                        <h3 class="no-top-margin">
                                            <xsl:value-of select="'Table of Contents'"/>
                                        </h3>
                                        
                                        <ul>
                                            
                                            <li>
                                                <a>
                                                    <xsl:attribute name="href" select="'#title'"/>
                                                    <xsl:value-of select="'Title'"/>
                                                </a>
                                            </li>
                                            
                                            <xsl:for-each select="$parts-with-content[@type eq 'section'][tei:head]">
                                                <li>
                                                    <a>
                                                        <xsl:attribute name="href" select="'#' || @id"/>
                                                        <xsl:apply-templates select="tei:head/node()"/>
                                                    </a>
                                                </li>
                                            </xsl:for-each>
                                            
                                            <xsl:if test="$attributed-texts">
                                                <li>
                                                    <a>
                                                        <xsl:attribute name="href" select="'#attributed-texts'"/>
                                                        <xsl:apply-templates select="$article/m:part[@type eq 'related-texts']/tei:head/node()"/>
                                                    </a>
                                                </li>
                                            </xsl:if>
                                            
                                            <xsl:if test="$parts-with-content[@type eq 'bibliography'][tei:head]">
                                                <li>
                                                    <a>
                                                        <xsl:attribute name="href" select="'#bibliography'"/>
                                                        <xsl:apply-templates select="$article/m:part[@type eq 'bibliography']/tei:head/node()"/>
                                                    </a>
                                                </li>
                                            </xsl:if>
                                            
                                            <xsl:if test="$notes-with-content">
                                                <li>
                                                    <a>
                                                        <xsl:attribute name="href" select="'#end-notes'"/>
                                                        <xsl:value-of select="'Notes'"/>
                                                    </a>
                                                </li>
                                            </xsl:if>
                                            
                                            <xsl:if test="$parts-with-content[@type eq 'section'] and $article/m:part[@type eq 'glossary'][tei:head]/tei:gloss">
                                                <li>
                                                    <a>
                                                        <xsl:attribute name="href" select="'#glossary'"/>
                                                        <xsl:apply-templates select="$article/m:part[@type eq 'glossary']/tei:head/node()"/>
                                                    </a>
                                                </li>
                                            </xsl:if>
                                            
                                        </ul>
                                        
                                    </div>
                                </div>
                                
                            </xsl:if>
                            
                            <!-- Related content -->
                            <!-- Exclude this entity and attributions in related texts -->
                            <xsl:variable name="related-entity-pages" select="key('related-pages', /m:response/m:entities/m:related/m:entity[not(@xml:id = $article-entity/@xml:id)]/m:instance/@id, $root)" as="element(m:page)*"/>
                            <xsl:variable name="related-entity-entries" select="key('related-entries', /m:response/m:entities/m:related/m:entity/m:instance/@id | $article-entity/m:instance/@id, $root)" as="element(m:entry)*"/>
                            <xsl:variable name="related-section" select="$article/m:section" as="element(m:section)*"/>
                            
                            <xsl:if test="$related-entity-pages | $related-entity-entries | $related-section">
                                
                                <div class="panel panel-default">
                                    <div class="panel-body">
                                        
                                        <h3 class="no-top-margin">
                                            <xsl:value-of select="'Related content'"/>
                                        </h3>
                                        
                                        <xsl:if test="$related-section">
                                            
                                            <label>
                                                <xsl:value-of select="'This section in The Collection'"/>
                                            </label>
                                            
                                            <ul>
                                                <li>
                                                    <a>
                                                        
                                                        <xsl:variable name="main-title" select="$related-section/m:titles/m:title[@xml:lang eq 'en'][1]"/>
                                                        
                                                        <xsl:attribute name="href" select="concat('/section/', $related-section/@id, '.html')"/>
                                                        <xsl:call-template name="class-attribute">
                                                            <xsl:with-param name="lang" select="$main-title/@xml:lang"/>
                                                        </xsl:call-template>
                                                        
                                                        <xsl:value-of select="normalize-space($main-title/text())"/>
                                                        
                                                    </a>
                                                </li>
                                            </ul>
                                            
                                        </xsl:if>
                                        
                                        <xsl:if test="$related-entity-pages">
                                            
                                            <label>
                                                <xsl:value-of select="'From the 84000 Knowledge Base'"/>
                                            </label>
                                            
                                            <ul>
                                                <xsl:for-each select="$related-entity-pages">
                                                    <li>
                                                        <a>
                                                            <xsl:variable name="main-title" select="m:titles ! (m:title[@type eq 'articleTitle'], m:title[@type eq 'mainTitle'][@xml:lang eq 'en'], m:title[@type eq 'mainTitle'])[1]"/>
                                                            
                                                            <xsl:attribute name="href" select="concat('/knowledgebase/', @kb-id, '.html')"/>
                                                            <xsl:call-template name="class-attribute">
                                                                <xsl:with-param name="lang" select="$main-title/@xml:lang"/>
                                                            </xsl:call-template>
                                                            
                                                            <xsl:value-of select="normalize-space($main-title/text())"/>
                                                            
                                                        </a>
                                                    </li>
                                                </xsl:for-each>
                                            </ul>
                                            
                                        </xsl:if>
                                        
                                        <xsl:if test="$related-entity-entries">
                                            
                                            <label>
                                                <xsl:value-of select="'From the 84000 Glossary'"/>
                                            </label>
                                            
                                            <ul>
                                                <xsl:for-each select="($article-entity[m:instance/@type = 'glossary-item'], /m:response/m:entities/m:related/m:entity[not(@xml:id eq $article-entity/@xml:id)][m:instance/@id = $related-entity-entries/@id])">
                                                    
                                                    <xsl:variable name="related-entity" select="."/>
                                                    <xsl:variable name="entity-data" as="element(m:entity-data)?">
                                                        <xsl:call-template name="entity-data">
                                                            <xsl:with-param name="entity" select="$related-entity"/>
                                                        </xsl:call-template>
                                                    </xsl:variable>
                                                    
                                                    <li>
                                                        <a class="block-link">
                                                            
                                                            <xsl:attribute name="href" select="concat('/glossary/', $related-entity/@xml:id, '.html')"/>
                                                            
                                                            <h4 class="no-top-margin no-bottom-margin { common:lang-class($entity-data/m:label[@type eq 'primary']/@xml:lang) }">
                                                                <xsl:value-of select="normalize-space($entity-data/m:label[@type eq 'primary']/text())"/>
                                                            </h4>
                                                            
                                                            <xsl:for-each select="$entity-data/m:label[not(@type eq 'primary')]">
                                                                <p class="no-bottom-margin { common:lang-class(@xml:lang) }">
                                                                    <xsl:value-of select="text() ! normalize-space(.)"/>
                                                                </p>
                                                            </xsl:for-each>
                                                            
                                                        </a>
                                                    </li>
                                                    
                                                </xsl:for-each>
                                            </ul>
                                            
                                        </xsl:if>
                                        
                                    </div>
                                </div>
                                
                            </xsl:if>
                            
                        </aside>
                        
                    </div>
                </div>
            </div>
            
            <!-- General pop-up for notes and glossary -->
            <div id="popup-footer-text" class="fixed-footer collapse hidden-print">
                <div class="fix-height">
                    <div class="container">
                        <div class="row">
                            <div class="col-md-8 col-lg-9">
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
            
            <!-- Pop-up for tei-editor -->
            <xsl:call-template name="tei-editor-footer"/>
            
        </xsl:variable>
        
        <!-- Pass the content to the page -->
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="($article/m:page/@page-url, '')[1]"/>
            <xsl:with-param name="page-class" select="'reading-room knowledgebase'"/>
            <xsl:with-param name="page-title" select="concat($article-title, ' | 84000 Knowledge Base')"/>
            <xsl:with-param name="page-description" select="normalize-space(data($article/m:page/m:summary/tei:p[1]))"/>
            <xsl:with-param name="content" select="$content"/>
            <xsl:with-param name="additional-links">
                <script src="https://code.highcharts.com/highcharts.js"/>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
        
    <!--<xsl:template name="taxonomy">
        
        <ul class="list-unstyled taxonomy">
            <xsl:for-each select="$article/m:taxonomy/tei:category">
                <li class="label label-filter">
                    <xsl:value-of select="tei:catDesc"/>
                </li>
            </xsl:for-each>
        </ul>
        
    </xsl:template>-->
    
</xsl:stylesheet>