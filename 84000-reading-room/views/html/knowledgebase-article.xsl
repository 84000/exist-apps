<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:import href="../../xslt/tei-to-xhtml.xsl"/>
    
    <!-- Look up environment variables -->
    <!--<xsl:variable name="environment" select="/m:response/m:environment"/>-->
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
                                    
                                    <section id="attributed-texts">
                                        
                                        <h2>
                                            <xsl:apply-templates select="$article/m:part[@type eq 'related-texts']/tei:head/node()"/>
                                        </h2>
                                        
                                        <div class="list-group accordion" id="attributed-texts-list">
                                            
                                            <xsl:for-each-group select="$attributed-texts" group-by="m:parent/@id">
                                                
                                                <xsl:sort select="m:parent[1]/@id"/>
                                                
                                                <xsl:call-template name="expand-item">
                                                    <xsl:with-param name="id" select="concat('attributed-texts-', m:parent[1]/@id)"/>
                                                    <xsl:with-param name="accordion-selector" select="'#attributed-texts-list'"/>
                                                    <xsl:with-param name="active" select="if(count(distinct-values($attributed-texts/m:parent/@id)) le 1) then true() else false()"/>
                                                    <xsl:with-param name="persist" select="true()"/>
                                                    <xsl:with-param name="title-opener" select="true()"/>
                                                    <xsl:with-param name="title">
                                                        
                                                        <h3 class="list-group-item-heading">
                                                            
                                                            <xsl:value-of select="m:parent[1]/m:titles/m:title[@xml:lang eq 'en'][1]"/>
                                                            
                                                            <xsl:value-of select="' '"/>
                                                            <span class="label label-primary">
                                                                <xsl:value-of select="concat(count(current-group()), if(count(current-group()) eq 1) then ' text' else ' texts')"/>
                                                            </span>
                                                            
                                                            <xsl:variable name="texts-as-translator" select="current-group()[m:source/m:attribution[@xml:id = $article-entity/m:instance/@id][@role eq 'translator']]"/>
                                                            <xsl:if test="$texts-as-translator">
                                                                <xsl:value-of select="' '"/>
                                                                <span class="label label-default">
                                                                    <xsl:value-of select="concat(count($texts-as-translator), ' as translator')"/>
                                                                </span>
                                                            </xsl:if>
                                                            
                                                            <xsl:variable name="texts-as-reviser" select="current-group()[m:source/m:attribution[@xml:id = $article-entity/m:instance/@id][@role eq 'reviser']]"/>
                                                            <xsl:if test="$texts-as-reviser">
                                                                <xsl:value-of select="' '"/>
                                                                <span class="label label-default">
                                                                    <xsl:value-of select="concat(count($texts-as-reviser), ' as reviser')"/>
                                                                </span>
                                                            </xsl:if>
                                                            
                                                            <xsl:if test="count(current-group()[@status-group eq 'published']) gt 0">
                                                                <xsl:value-of select="' '"/>
                                                                <span class="label label-default">
                                                                    <xsl:value-of select="concat(count(current-group()[@status-group eq 'published']), ' published')"/>
                                                                </span>
                                                            </xsl:if>
                                                            
                                                        </h3>
                                                        
                                                        <div title="The location of this section" class="text-muted small">
                                                            <xsl:value-of select="'In '"/>
                                                            <ul class="breadcrumb">
                                                                <xsl:variable name="breadbrumbs" select="common:breadcrumb-items(m:parent[1]/descendant::m:parent[not(@id eq 'LOBBY')], /m:response/@lang)"/>
                                                                <xsl:for-each select="$breadbrumbs[self::xhtml:li]">
                                                                    <li>
                                                                        <xsl:value-of select="xhtml:a/text()"/>
                                                                    </li>
                                                                </xsl:for-each>
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
                                                                    <xsl:value-of select="'Translation status'"/>
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
                                                                                            <xsl:attribute name="href" select="m:translation-href($text/m:toh/@key, (), (), ())"/>
                                                                                            <xsl:attribute name="target" select="concat($text/@id, '.html')"/>
                                                                                            <xsl:value-of select="$title"/>
                                                                                        </a>
                                                                                    </xsl:when>
                                                                                    <xsl:otherwise>
                                                                                        <a>
                                                                                            <xsl:attribute name="href" select="common:internal-href(concat('/section/', m:parent[1]/@id, '.html'), (), $text/m:toh/@key ! concat('#', .), /m:response/@lang)"/>
                                                                                            <xsl:value-of select="$title"/>
                                                                                        </a>
                                                                                    </xsl:otherwise>
                                                                                </xsl:choose>
                                                                                
                                                                                <xsl:choose>
                                                                                    <xsl:when test="$text/m:source/m:attribution[@xml:id = $article-entity/m:instance/@id][@role eq 'translator']">
                                                                                        <span class="label label-default">
                                                                                            <xsl:value-of select="'attributed as translator'"/>
                                                                                        </span>
                                                                                    </xsl:when>
                                                                                    <xsl:when test="$text/m:source/m:attribution[@xml:id = $article-entity/m:instance/@id][@role eq 'reviser']">
                                                                                        <span class="label label-default">
                                                                                            <xsl:value-of select="'attributed as reviser'"/>
                                                                                        </span>
                                                                                    </xsl:when>
                                                                                </xsl:choose>
                                                                                
                                                                            </h4>
                                                                            
                                                                            <xsl:for-each select="('bo', 'Bo-Ltn', 'Sa-Ltn', 'zh')">
                                                                                
                                                                                <xsl:variable name="lang" select="."/>
                                                                                <xsl:variable name="title" select="$text/m:titles/m:title[@xml:lang eq $lang][1][text()]"/>
                                                                                
                                                                                <xsl:if test="$title">
                                                                                    <xsl:choose>
                                                                                        <xsl:when test="$lang eq 'Bo-Ltn' and $text/m:titles/m:title[@xml:lang eq 'bo']">
                                                                                            <xsl:value-of select="' · '"/>
                                                                                        </xsl:when>
                                                                                        <xsl:otherwise>
                                                                                            <hr/>
                                                                                        </xsl:otherwise>
                                                                                    </xsl:choose>
                                                                                    <span>
                                                                                        <xsl:attribute name="class" select="common:lang-class($title/@xml:lang)"/>
                                                                                        <xsl:value-of select="$title"/>
                                                                                    </span>
                                                                                </xsl:if>
                                                                                
                                                                            </xsl:for-each>
                                                                            
                                                                            <xsl:if test="$text/m:publication/m:tantric-restriction[tei:p]">
                                                                                <hr class="sml-margin"/>
                                                                                <xsl:call-template name="tantra-warning">
                                                                                    <xsl:with-param name="id" select="$text/@id"/>
                                                                                </xsl:call-template>
                                                                            </xsl:if>
                                                                            
                                                                            <!-- Authors -->
                                                                            <xsl:call-template name="source-authors">
                                                                                <xsl:with-param name="text" select="$text"/>
                                                                                <xsl:with-param name="exclude-entity-ids" select="$article-entity/@xml:id"/>
                                                                            </xsl:call-template>
                                                                            
                                                                            <xsl:call-template name="expandable-summary">
                                                                                <xsl:with-param name="text" select="$text"/>
                                                                                <xsl:with-param name="expand-id" select="concat('summary-detail-', $text/@id)"/>
                                                                            </xsl:call-template>
                                                                            
                                                                        </div>
                                                                        
                                                                        <div class="col-sm-2">
                                                                            
                                                                            <div>
                                                                                <xsl:choose>
                                                                                    <xsl:when test="$text/@status-group eq 'published'">
                                                                                        <span class="label label-success">
                                                                                            <xsl:value-of select="'Published'"/>
                                                                                        </span>
                                                                                    </xsl:when>
                                                                                    <xsl:when test="$text/@status-group = ('translated', 'in-translation')">
                                                                                        <span class="label label-warning">
                                                                                            <xsl:value-of select="'In progress'"/>
                                                                                        </span>
                                                                                    </xsl:when>
                                                                                    <!--<xsl:when test="$text/@status-group eq 'in-application'">
                                                                                        <span class="label label-default">
                                                                                            <xsl:value-of select="'In progress'"/>
                                                                                        </span>
                                                                                    </xsl:when>-->
                                                                                    <xsl:otherwise>
                                                                                        <span class="label label-default">
                                                                                            <xsl:value-of select="'Not Started'"/>
                                                                                        </span>
                                                                                    </xsl:otherwise>
                                                                                </xsl:choose>
                                                                            </div>
                                                                            
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
                        
                        <aside class="col-md-4 col-lg-3 sticky">
                            
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
                                        <xsl:value-of select="'Show editor options'"/>
                                    </a>
                                </div>
                            </xsl:if>
                            
                            <!-- Link to header form / glossary editor -->
                            <!-- Knowledge base only, editor mode, operations app, no child divs and an id -->
                            <xsl:if test="$tei-editor">
                                
                                <div class="well">
                                    
                                    <h3 class="no-top-margin">
                                        <xsl:value-of select="'Editor options '"/>
                                    </h3>
                                    
                                    <xsl:if test="$article/m:page[@status]">
                                        <p>
                                            <xsl:value-of select="'Publication status: '"/>
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
                                        </p>
                                    </xsl:if>
                                    
                                    <ul>
                                        
                                        <xsl:if test="$article-id gt ''">
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
                                        </xsl:if>
                                        
                                        <li>
                                            <xsl:value-of select="'Get some help: '"/>
                                            <ul class="list-inline">
                                                <li>
                                                    <a href="mailto:knowledgebase@84000.co" class="editor">
                                                        <xsl:value-of select="'Email'"/>
                                                    </a>
                                                </li>
                                                <li>
                                                    <a target="_blank" class="editor" href="https://84000-translate.slack.com/channels/translation-tech-helpdesk">
                                                        <xsl:value-of select="'Slack'"/>
                                                    </a>
                                                </li>
                                            </ul>
                                        </li>
                                        
                                        <li>
                                            <a class="editor" target="_self">
                                                <xsl:attribute name="href" select="concat('?timestamp=', current-dateTime())"/>
                                                <xsl:value-of select="'Hide editor options'"/>
                                            </a>
                                        </li>
                                        
                                    </ul>
                                    
                                </div>
                                
                            </xsl:if>
                            
                            <!-- Table of contents -->
                            <xsl:if test="count($parts-with-content) gt 2 or $tei-editor">
                                
                                <div class="panel panel-default">
                                    <div class="panel-heading">
                                        <h3 class="panel-title">
                                            <xsl:value-of select="'Table of Contents'"/>
                                        </h3>
                                    </div>
                                    <div class="panel-body">
                                        
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
                                    
                                    <div class="panel-heading">
                                        <h3 class="panel-title">
                                            <xsl:value-of select="'Related content'"/>
                                        </h3>
                                    </div>
                                    
                                    <xsl:if test="$related-section">
                                        <div class="panel-body">
                                            
                                            <p>
                                                <a>
                                                    
                                                    <xsl:variable name="section-title" select="$related-section/m:titles/m:title[@xml:lang eq 'en'][1]"/>
                                                    
                                                    <xsl:attribute name="href" select="concat('/section/', $related-section/@id, '.html')"/>
                                                    <xsl:call-template name="class-attribute">
                                                        <xsl:with-param name="lang" select="$section-title/@xml:lang"/>
                                                    </xsl:call-template>
                                                    
                                                    <xsl:value-of select="concat('Go to the section &#34;', $section-title, '&#34;')"/>
                                                    
                                                </a>
                                            </p>
                                            
                                            <xsl:if test="$article/m:parent-section[m:section]">
                                                
                                                <h4 class="sml-margin bottom">
                                                    <xsl:value-of select="'This section is located in'"/>
                                                </h4>
                                                
                                                <xsl:call-template name="section-structure">
                                                    <xsl:with-param name="sections" select="($article/m:parent-section//m:section)[last()]"/>
                                                    <xsl:with-param name="direction" select="'ascending'"/>
                                                </xsl:call-template>
                                                
                                            </xsl:if>
                                            
                                            <xsl:if test="$related-section[m:section]">
                                                
                                                <h4 class="sml-margin bottom">
                                                    <xsl:value-of select="'Subsections'"/>
                                                </h4>
                                                
                                                <xsl:call-template name="section-structure">
                                                    <xsl:with-param name="sections" select="$related-section/m:section"/>
                                                </xsl:call-template>
                                                
                                            </xsl:if>
                                            
                                        </div>
                                    </xsl:if>
                                    
                                    <xsl:if test="$related-entity-pages">
                                        <div class="panel-body">
                                            <h4>
                                                <xsl:value-of select="'From the 84000 Knowledge Base'"/>
                                            </h4>
                                            <xsl:for-each select="$related-entity-pages">
                                                <hr class="sml-margin"/>
                                                <p>
                                                    <a>
                                                        <xsl:variable name="main-title" select="m:titles ! (m:title[@type eq 'articleTitle'], m:title[@type eq 'mainTitle'][@xml:lang eq 'en'], m:title[@type eq 'mainTitle'])[1]"/>
                                                        
                                                        <xsl:attribute name="href" select="concat('/knowledgebase/', @kb-id, '.html')"/>
                                                        <xsl:call-template name="class-attribute">
                                                            <xsl:with-param name="lang" select="$main-title/@xml:lang"/>
                                                        </xsl:call-template>
                                                        
                                                        <xsl:value-of select="normalize-space($main-title/text())"/>
                                                        
                                                    </a>
                                                </p>
                                            </xsl:for-each>
                                        </div>
                                    </xsl:if>
                                        
                                    <xsl:if test="$related-entity-entries">
                                        <div class="panel-body">
                                            <h4>
                                                <xsl:value-of select="'From the 84000 Glossary'"/>
                                            </h4>
                                            <xsl:for-each select="($article-entity[m:instance/@type = 'glossary-item'], /m:response/m:entities/m:related/m:entity[not(@xml:id eq $article-entity/@xml:id)][m:instance/@id = $related-entity-entries/@id])">
                                                
                                                <xsl:variable name="related-entity" select="."/>
                                                <xsl:variable name="entity-data" as="element(m:entity-data)?">
                                                    <xsl:call-template name="entity-data">
                                                        <xsl:with-param name="entity" select="$related-entity"/>
                                                    </xsl:call-template>
                                                </xsl:variable>
                                                
                                                <hr class="sml-margin"/>
                                                <p>
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
                                                </p>
                                                
                                            </xsl:for-each>
                                        </div>
                                        
                                    </xsl:if>
                                    
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
            <xsl:if test="$tei-editor">
                <xsl:call-template name="tei-editor-footer"/>
            </xsl:if>
            
        </xsl:variable>
        
        <!-- Pass the content to the page -->
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="($article/m:page/@page-url, '')[1]"/>
            <xsl:with-param name="page-class" select="'reading-room knowledgebase'"/>
            <xsl:with-param name="page-title" select="concat($article-title, ' | 84000 Knowledge Base')"/>
            <xsl:with-param name="page-description" select="normalize-space(data($article/m:page/m:summary/tei:p[1]))"/>
            <xsl:with-param name="content" select="$content"/>
            <xsl:with-param name="additional-tags">
                <script src="https://code.highcharts.com/highcharts.js"/>
                <script src="https://code.highcharts.com/modules/accessibility.js"/>
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
    
    <xsl:template name="section-structure">
        
        <xsl:param name="sections" as="element(m:section)*"/>
        <xsl:param name="direction" as="xs:string?"/>
        
        <xsl:if test="$sections">
            <ul>
                <xsl:for-each select="$sections">
                    
                    <xsl:variable name="section-title" select="m:titles/m:title[@xml:lang eq 'en'][1]"/>
                    <xsl:variable name="kb-page" select="m:page"/>
                    <li>
                        <a>
                            
                            <xsl:attribute name="href">
                                <xsl:choose>
                                    <xsl:when test="$kb-page[@kb-id][@status-group eq 'published']">
                                        <xsl:value-of select="concat('/knowledgebase/', $kb-page/@kb-id, '.html')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat('/section/', @id, '.html')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            
                            <xsl:call-template name="class-attribute">
                                <xsl:with-param name="lang" select="$section-title/@xml:lang"/>
                            </xsl:call-template>
                            
                            <xsl:value-of select="normalize-space($section-title/text())"/>
                            
                        </a>
                        <xsl:choose>
                            <xsl:when test="$direction eq 'ascending'">
                                <xsl:call-template name="section-structure">
                                    <xsl:with-param name="sections" select="parent::m:section"/>
                                    <xsl:with-param name="direction" select="$direction"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="section-structure">
                                    <xsl:with-param name="sections" select="m:section"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </li>
                    
                </xsl:for-each>
            </ul>
        </xsl:if>
        
    </xsl:template>
    
</xsl:stylesheet>