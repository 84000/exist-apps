<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:import href="about/about.xsl"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment" select="/m:response/m:environment"/>
    <xsl:variable name="front-end-path" select="$environment/m:url[@id eq 'front-end']/text()"/>
    <xsl:variable name="render-status" select="$environment/m:render/m:status[@type eq 'translation']/m:status/@status-id"/>
    
    <xsl:variable name="article-id" select="/m:response/m:knowledgebase/m:page/@xml:id"/>
    <xsl:variable name="article-title" select="/m:response/m:knowledgebase/m:page/m:titles/m:title[@type = 'mainTitle'][1]"/>
    <xsl:variable name="article-entity" select="/m:response/m:entities/m:entity[m:instance[@id eq $article-id]]"/>
    
    <!-- Ignore any nodes with @rend='default-text' unless it's editor mode -->
    <xsl:template match="tei:*[$view-mode[not(@id eq 'editor')] and @rend eq 'default-text']">
        <!-- Ignore these -->
    </xsl:template>
    
    <!-- Check nodes have more that default text -->
    <xsl:function name="m:has-user-content" as="xs:boolean">
        <xsl:param name="content" as="node()*"/>
        <xsl:sequence select="if($view-mode[@id eq 'editor'] or $content/descendant-or-self::text()[normalize-space(.)][not(ancestor::tei:head)][not(ancestor::*/@rend = 'default-text')]) then true() else false()"/>
    </xsl:function>
    
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
            <xsl:if test="not(m:knowledgebase/m:page/@status-group eq 'published')">
                <div class="title-band warning">
                    <div class="container">
                        <xsl:value-of select="'This text is not yet ready for publication!'"/>                      
                    </div>
                </div>
            </xsl:if>
            
            <div class="content-band">
                <div class="container">
                    <div class="row">
                        
                        <main class="col-md-8">
                            
                            <h1>
                                <!--<xsl:apply-templates select="$article-title"/>-->
                                <xsl:value-of select="$article-title"/>
                            </h1>
                            
                            <xsl:variable name="otherTitles" select="m:knowledgebase/m:page/m:titles/m:title[count((. | $article-title)) ne 1]"/>
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
                            
                            <xsl:if test="m:has-user-content(m:knowledgebase/m:part[@type eq 'article'])">
                                <section class="tei-parser gtr-right">
                                    <xsl:apply-templates select="m:knowledgebase/m:part[@type eq 'article']"/>
                                </section>
                            </xsl:if>
                            
                            <xsl:if test="m:knowledgebase/m:part[@type eq 'related-texts'][m:text]">
                                <section class="top-margin">
                                    <!--<hr class="hidden-print"/>-->
                                    <h2>
                                        <xsl:apply-templates select="m:knowledgebase/m:part[@type eq 'related-texts']/tei:head/node()"/>
                                    </h2>
                                    <xsl:call-template name="text-list">
                                        <xsl:with-param name="texts" select="m:knowledgebase/m:part[@type eq 'related-texts']/m:text"/>
                                        <xsl:with-param name="list-id" select="'related-texts'"/>
                                        <xsl:with-param name="show-translation-status" select="true()"/>
                                    </xsl:call-template>
                                </section>
                            </xsl:if>
                            
                            <xsl:if test="m:has-user-content(m:knowledgebase/m:part[@type eq 'bibliography'])">
                                <section class="tei-parser gtr-right">
                                    <!--<hr class="hidden-print"/>-->
                                    <xsl:apply-templates select="m:knowledgebase/m:part[@type eq 'bibliography']"/>
                                </section>
                            </xsl:if>
                            
                            <xsl:if test="m:has-user-content(m:knowledgebase/m:part[@type = ('article','bibliography')]//tei:note[@place eq 'end'][@xml:id])">
                                <section class="tei-parser">
                                    <!--<hr class="hidden-print"/>-->
                                    <xsl:call-template name="end-notes">
                                        <xsl:with-param name="end-notes" select="m:knowledgebase/m:part[@type = ('article','bibliography')]//tei:note[@place eq 'end'][@xml:id][m:has-user-content(.)]"/>
                                    </xsl:call-template>
                                </section>
                            </xsl:if>
                            
                            <xsl:if test="m:has-user-content(m:knowledgebase/m:part[@type eq 'glossary'])">
                                <section class="tei-parser">
                                    <!--<hr class="hidden-print"/>-->
                                    <xsl:call-template name="glossary"/>
                                </section>
                            </xsl:if>
                            
                        </main>
                        
                        <aside class="col-md-4 col-lg-offset-1 col-lg-3">
                            
                            <!-- Alert locked file -->
                            <xsl:if test="$tei-editor and m:knowledgebase/m:page[@locked-by-user gt '']">
                                <div class="alert alert-danger break" role="alert">
                                    <xsl:value-of select="concat('File ', m:knowledgebase/m:page/@document-url, ' is currenly locked by user ', m:knowledgebase/m:page/@locked-by-user, '. ')"/>
                                    <xsl:value-of select="'You cannot modify this file until the lock is released.'"/>
                                </div>
                            </xsl:if>
                            
                            <!-- Table of contents -->
                            <xsl:variable name="toc">
                                <!-- Article -->
                                <!-- Attributions -->
                                <!-- Bibliography -->
                                <!-- Notes -->
                                <!-- Glossary -->
                            </xsl:variable>
                            
                            <!-- Related content -->
                            <xsl:variable name="exclude-related-entity" select="($article-entity/@xml:id, m:knowledgebase/m:part[@type eq 'related-texts']//m:attribution/@ref ! replace(., '^eft:', ''))"/>
                            <xsl:variable name="related-entity-pages" select="key('related-pages', /m:response/m:entities/m:related/m:entity[not(@xml:id = $exclude-related-entity)]/m:instance/@id, $root)" as="element(m:page)*"/>
                            <xsl:variable name="related-entity-entries" select="key('related-entries', /m:response/m:entities/m:related/m:entity/m:instance/@id | $article-entity/m:instance/@id, $root)" as="element(m:entry)*"/>
                            
                            <xsl:if test="$related-entity-pages | $related-entity-entries">
                                
                                <h3>
                                    <xsl:value-of select="'Related content'"/>
                                </h3>
                                
                                <div class="list-group">
                                    
                                    <xsl:if test="$related-entity-pages">
                                        
                                        <div class="list-group-item">
                                            <p class="list-group-item-text">
                                                <xsl:value-of select="'From the 84000 Knowledge Base'"/>
                                            </p>
                                        </div>
                                        
                                        <xsl:for-each select="$related-entity-pages">
                                            <a class="list-group-item">
                                                
                                                <xsl:attribute name="href" select="concat('/knowledgebase/', @kb-id, '.html')"/>
                                                
                                                <xsl:variable name="main-title" select="m:titles/m:title[@type eq 'mainTitle'][1]"/>
                                                
                                                <h4>
                                                    <xsl:attribute name="class">
                                                        <xsl:value-of select="string-join(('list-group-item-heading', common:lang-class($main-title/@xml:lang)),' ')"/>
                                                    </xsl:attribute>
                                                    <xsl:value-of select="normalize-space($main-title/text())"/>
                                                </h4>
                                                
                                            </a>
                                        </xsl:for-each>
                                        
                                    </xsl:if>
                                    
                                    <xsl:if test="$related-entity-entries">
                                        
                                        <div class="list-group-item">
                                            <p class="list-group-item-text">
                                                <xsl:value-of select="'From the 84000 Glossary of Terms'"/>
                                            </p>
                                        </div>
                                        
                                        <xsl:for-each select="($article-entity[m:instance/@type = 'glossary-item'], /m:response/m:entities/m:related/m:entity[not(@xml:id eq $article-entity/@xml:id)][m:instance/@id = $related-entity-entries/@id])">
                                            
                                            <xsl:variable name="related-entity" select="."/>
                                            <xsl:variable name="entity-data" as="element(m:entity-data)?">
                                                <xsl:call-template name="entity-data">
                                                    <xsl:with-param name="entity" select="$related-entity"/>
                                                    <xsl:with-param name="search-text" select="''"/>
                                                    <xsl:with-param name="selected-term-lang" select="''"/>
                                                </xsl:call-template>
                                            </xsl:variable>
                                            
                                            <a class="list-group-item">
                                                
                                                <xsl:attribute name="href" select="concat('/glossary.html?entity-id=', $related-entity/@xml:id)"/>
                                                
                                                <h4>
                                                    <xsl:attribute name="class">
                                                        <xsl:value-of select="string-join(('list-group-item-heading', common:lang-class($entity-data/m:label[@type eq 'primary']/@xml:lang)),' ')"/>
                                                    </xsl:attribute>
                                                    <xsl:value-of select="normalize-space($entity-data/m:label[@type eq 'primary']/text())"/>
                                                </h4>
                                                
                                                <xsl:if test="$entity-data[m:label[@type eq 'secondary']]">
                                                    <p>
                                                        <xsl:attribute name="class">
                                                            <xsl:value-of select="string-join(('text-muted',common:lang-class($entity-data/m:label[@type eq 'secondary']/@xml:lang)),' ')"/>
                                                        </xsl:attribute>
                                                        <xsl:value-of select="normalize-space($entity-data/m:label[@type eq 'secondary']/text())"/>
                                                    </p>
                                                </xsl:if>
                                                
                                                <!--<xsl:for-each select="m:content[@type eq 'glossary-definition']">
                                                    <p class="list-group-item-text">                                                              
                                                        <xsl:apply-templates select="node()"/>
                                                    </p>
                                                </xsl:for-each>-->
                                                
                                            </a>
                                        </xsl:for-each>
                                            
                                    </xsl:if>
                                    
                                </div>
                                
                            </xsl:if>
                            
                            <!-- If it could be TEI editor but isn't, show a button -->
                            <xsl:if test="$tei-editor-off">
                                <div class="bottom-margin">
                                    <a>
                                        <xsl:attribute name="href" select="concat('?view-mode=editor&amp;timestamp=', current-dateTime())"/>
                                        <xsl:attribute name="class" select="'btn btn-danger uppercase'"/>
                                        <xsl:value-of select="'Show Editor'"/>
                                    </a>
                                </div>
                            </xsl:if>
                            
                            <!-- Link to header form / glossary editor -->
                            <!-- Knowledge base only, editor mode, operations app, no child divs and an id -->
                            <xsl:if test="$tei-editor">
                                
                                <div class="well">
                                    
                                    <h3 class="no-top-margin">
                                        <xsl:value-of select="'Editor options'"/>
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
                                                <a class="editor" target="84000-operations">
                                                    <xsl:attribute name="href" select="concat($environment/m:url[@id eq 'operations']/text(), '/edit-glossary.html', '?resource-id=', $article-id, '&amp;resource-type=knowledgebase')"/>
                                                    <xsl:value-of select="'Edit glossary'"/>
                                                </a>
                                            </li>
                                            <li>
                                                <a class="editor" target="tei-editor">
                                                    
                                                    <xsl:attribute name="href" select="concat('/tei-editor.html?type=knowledgebase&amp;resource-id=', $article-id,'&amp;timestamp=', current-dateTime(), '#ajax-source')"/>
                                                    <xsl:attribute name="data-ajax-target" select="'#popup-footer-editor .data-container'"/>
                                                    
                                                    <xsl:value-of select="'Lock / unlock file'"/>
                                                    
                                                </a>
                                            </li>
                                        </ul>
                                        
                                    </xsl:if>
                                    
                                    <a>
                                        <xsl:attribute name="href" select="concat('?timestamp=', current-dateTime())"/>
                                        <xsl:attribute name="class" select="'btn btn-sm btn-warning uppercase'"/>
                                        <xsl:value-of select="'Hide Editor'"/>
                                    </a>
                                    
                                </div>
                                
                            </xsl:if>
                            
                        </aside>
                        
                    </div>
                </div>
                
            </div>
            
            <!-- General pop-up for notes -->
            <div id="popup-footer" class="fixed-footer collapse hidden-print">
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
                <div id="popup-footer-editor" class="fixed-footer collapse hidden-print">
                    <div class="fix-height">
                        <div class="container">
                            <div class="data-container">
                                <!-- Ajax data here -->
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
            </xsl:if>
            
        </xsl:variable>
        
        <!-- Pass the content to the page -->
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="(m:knowledgebase/m:page/@page-url, '')[1]"/>
            <xsl:with-param name="page-class" select="'reading-room knowledgebase'"/>
            <xsl:with-param name="page-title" select="concat($article-title, ' | 84000 Reading Room')"/>
            <xsl:with-param name="page-description" select="normalize-space(data(m:knowledgebase/m:page/m:summary/tei:p[1]))"/>
            <xsl:with-param name="content" select="$content"/>
            <xsl:with-param name="additional-links">
                <script src="https://code.highcharts.com/highcharts.js"/>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
        
    <xsl:template name="taxonomy">
        
        <ul class="list-unstyled taxonomy">
            <xsl:for-each select="m:knowledgebase/m:taxonomy/tei:category">
                <li class="label label-filter">
                    <xsl:value-of select="tei:catDesc"/>
                </li>
            </xsl:for-each>
        </ul>
        
    </xsl:template>
    
</xsl:stylesheet>