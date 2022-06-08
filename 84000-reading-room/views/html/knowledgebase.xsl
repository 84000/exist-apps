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
            
            <xsl:variable name="related-texts" select="m:knowledgebase/m:part[@type eq 'related-texts']/m:text"/>
            
            <div class="content-band">
                <div class="container">
                    <div class="row">
                        
                        <main class="col-md-8">
                            
                            <h1 id="title">
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
                                <section id="article" class="tei-parser gtr-right">
                                    <xsl:apply-templates select="m:knowledgebase/m:part[@type eq 'article']"/>
                                </section>
                            </xsl:if>
                            
                            <xsl:if test="$related-texts">
                                <section id="related-texts" class="tei-parser gtr-right">
                                    
                                    <h2>
                                        <xsl:apply-templates select="m:knowledgebase/m:part[@type eq 'related-texts']/tei:head/node()"/>
                                    </h2>
                                    
                                    <div class="text-list">
                                        
                                        <xsl:for-each-group select="$related-texts" group-by="m:parent/@id">
                                            
                                            <xsl:sort select="m:parent[1]/@id"/>
                                            
                                            <div class="row">
                                                
                                                <h3 class="sml-margin top bottom">
                                                    <!--<span class="small text-muted">
                                                        <xsl:value-of select="'From '"/>
                                                    </span>-->
                                                    <a>
                                                        <xsl:attribute name="href" select="common:internal-link(concat('/section/', m:parent[1]/@id, '.html'), (), '', /m:response/@lang)"/>
                                                        <xsl:value-of select="m:parent[1]/m:titles/m:title[@xml:lang eq 'en'][1]"/>
                                                    </a>
                                                </h3>
                                                
                                                <div role="navigation" title="The location of this section" class="text-muted small sml-margin bottom">
                                                    <xsl:value-of select="'In '"/>
                                                    <ul class="breadcrumb">
                                                        <xsl:sequence select="common:breadcrumb-items(m:parent[1]/descendant::m:parent, /m:response/@lang)"/>
                                                    </ul>
                                                </div>
                                                
                                                <xsl:for-each-group select="current-group()" group-by="@id">
                                                    
                                                    <xsl:sort select="number(m:toh[1]/@number)"/>
                                                    <xsl:sort select="m:toh[1]/@letter"/>
                                                    <xsl:sort select="number(m:toh[1]/@chapter-number)"/>
                                                    <xsl:sort select="m:toh[1]/@chapter-letter"/>
                                                    
                                                    <xsl:variable name="text" select="."/>
                                                    
                                                    <div class="bottom-margin">
                                                        
                                                        <h4>
                                                            
                                                            <span class="item-title">
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
                                                            </span>
                                                            
                                                            <span class="small">
                                                                <xsl:value-of select="' / '"/>
                                                                <xsl:value-of select="$text/m:toh/m:full"/>
                                                            </span>
                                                            
                                                        </h4>
                                                        
                                                        <ul class="sml-margin bottom">
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
                                                    
                                                </xsl:for-each-group>
                                                
                                            </div>
                                            
                                        </xsl:for-each-group>
                                        
                                    </div>
                                    
                                </section>
                            </xsl:if>
                            
                            <xsl:if test="m:has-user-content(m:knowledgebase/m:part[@type eq 'bibliography'])">
                                <section id="bibliography" class="tei-parser gtr-right">
                                    <!--<hr class="hidden-print"/>-->
                                    <xsl:apply-templates select="m:knowledgebase/m:part[@type eq 'bibliography']"/>
                                </section>
                            </xsl:if>
                            
                            <xsl:if test="m:has-user-content(m:knowledgebase/m:part[@type = ('article','bibliography')]//tei:note[@place eq 'end'][@xml:id])">
                                <section id="end-notes" class="tei-parser">
                                    <!--<hr class="hidden-print"/>-->
                                    <xsl:call-template name="end-notes">
                                        <xsl:with-param name="end-notes" select="m:knowledgebase/m:part[@type = ('article','bibliography')]//tei:note[@place eq 'end'][@xml:id][m:has-user-content(.)]"/>
                                    </xsl:call-template>
                                </section>
                            </xsl:if>
                            
                            <xsl:if test="m:has-user-content(m:knowledgebase/m:part[@type eq 'glossary'])">
                                <section id="glossary" class="tei-parser">
                                    <!--<hr class="hidden-print"/>-->
                                    <xsl:call-template name="glossary"/>
                                </section>
                            </xsl:if>
                            
                        </main>
                        
                        <aside class="col-md-4 col-lg-3 col-lg-offset-1">
                            
                            <!-- Alert locked file -->
                            <xsl:if test="$tei-editor and m:knowledgebase/m:page[@locked-by-user gt '']">
                                <div class="alert alert-danger break" role="alert">
                                    <xsl:value-of select="concat('File ', m:knowledgebase/m:page/@document-url, ' is currenly locked by user ', m:knowledgebase/m:page/@locked-by-user, '. ')"/>
                                    <xsl:value-of select="'You cannot modify this file until the lock is released.'"/>
                                </div>
                            </xsl:if>
                            
                            <div class="panel panel-default">
                                <div class="panel-body">
                                    
                                    <h3 class="no-top-margin">
                                        <xsl:value-of select="'Table of Contents'"/>
                                    </h3>
                                    
                                    <ul>
                                        
                                        <li>
                                            <a class="scroll-to-anchor">
                                                <xsl:attribute name="href" select="'#title'"/>
                                                <xsl:value-of select="'Title'"/>
                                            </a>
                                        </li>
                                        
                                        <xsl:for-each select="m:knowledgebase/m:part[@type eq 'article']/m:part[@type eq 'section']">
                                            <xsl:if test="m:has-user-content(.)">
                                                <li>
                                                    <a class="scroll-to-anchor">
                                                        <xsl:attribute name="href" select="'#article'"/>
                                                        <xsl:apply-templates select="tei:head/node()"/>
                                                    </a>
                                                </li>
                                            </xsl:if>
                                        </xsl:for-each>
                                        
                                        <xsl:if test="$related-texts">
                                            <li>
                                                <a class="scroll-to-anchor">
                                                    <xsl:attribute name="href" select="'#related-texts'"/>
                                                    <xsl:apply-templates select="m:knowledgebase/m:part[@type eq 'related-texts']/tei:head/node()"/>
                                                </a>
                                            </li>
                                        </xsl:if>
                                        
                                        <xsl:if test="m:has-user-content(m:knowledgebase/m:part[@type eq 'bibliography'])">
                                            <li>
                                                <a class="scroll-to-anchor">
                                                    <xsl:attribute name="href" select="'#bibliography'"/>
                                                    <xsl:apply-templates select="m:knowledgebase/m:part[@type eq 'bibliography']/tei:head/node()"/>
                                                </a>
                                            </li>
                                        </xsl:if>
                                        
                                        <xsl:if test="m:has-user-content(m:knowledgebase/m:part[@type = ('article','bibliography')]//tei:note[@place eq 'end'][@xml:id])">
                                            <li>
                                                <a class="scroll-to-anchor">
                                                    <xsl:attribute name="href" select="'#end-notes'"/>
                                                    <xsl:value-of select="'Notes'"/>
                                                </a>
                                            </li>
                                        </xsl:if>
                                        
                                        <xsl:if test="m:has-user-content(m:knowledgebase/m:part[@type eq 'glossary'])">
                                            <li>
                                                <a class="scroll-to-anchor">
                                                    <xsl:attribute name="href" select="'#glossary'"/>
                                                    <xsl:apply-templates select="m:knowledgebase/m:part[@type eq 'glossary']/tei:head/node()"/>
                                                </a>
                                            </li>
                                        </xsl:if>
                                        
                                    </ul>
                                </div>
                            </div>
                            
                            <!-- Related content -->
                            <xsl:variable name="exclude-related-entity" select="($article-entity/@xml:id, m:knowledgebase/m:part[@type eq 'related-texts']//m:attribution/@ref ! replace(., '^eft:', ''))"/>
                            <xsl:variable name="related-entity-pages" select="key('related-pages', /m:response/m:entities/m:related/m:entity[not(@xml:id = $exclude-related-entity)]/m:instance/@id, $root)" as="element(m:page)*"/>
                            <xsl:variable name="related-entity-entries" select="key('related-entries', /m:response/m:entities/m:related/m:entity/m:instance/@id | $article-entity/m:instance/@id, $root)" as="element(m:entry)*"/>
                            
                            <xsl:if test="$related-entity-pages | $related-entity-entries">
                                
                                <div class="panel panel-default">
                                    <div class="panel-body">
                                        
                                        <h3 class="no-top-margin">
                                            <xsl:value-of select="'Related content'"/>
                                        </h3>
                                        
                                        
                                        <xsl:if test="$related-entity-pages">
                                            
                                            <p>
                                                <xsl:value-of select="'From the 84000 Knowledge Base'"/>
                                            </p>
                                            
                                            <ul>
                                                <xsl:for-each select="$related-entity-pages">
                                                    <li>
                                                        <a>
                                                            
                                                            <xsl:attribute name="href" select="concat('/knowledgebase/', @kb-id, '.html')"/>
                                                            
                                                            <xsl:variable name="main-title" select="m:titles/m:title[@type eq 'mainTitle'][1]"/>
                                                            
                                                            <h4>
                                                                <xsl:attribute name="class">
                                                                    <xsl:value-of select="string-join(('list-group-item-heading', common:lang-class($main-title/@xml:lang)),' ')"/>
                                                                </xsl:attribute>
                                                                <xsl:value-of select="normalize-space($main-title/text())"/>
                                                            </h4>
                                                            
                                                        </a>
                                                    </li>
                                                </xsl:for-each>
                                            </ul>
                                            
                                        </xsl:if>
                                        
                                        <xsl:if test="$related-entity-entries">
                                            
                                            <p>
                                                <xsl:value-of select="'From the 84000 Glossary of Terms'"/>
                                            </p>
                                            
                                            <ul class="list-unstyled">
                                                <xsl:for-each select="($article-entity[m:instance/@type = 'glossary-item'], /m:response/m:entities/m:related/m:entity[not(@xml:id eq $article-entity/@xml:id)][m:instance/@id = $related-entity-entries/@id])">
                                                    
                                                    <xsl:variable name="related-entity" select="."/>
                                                    <xsl:variable name="entity-data" as="element(m:entity-data)?">
                                                        <xsl:call-template name="entity-data">
                                                            <xsl:with-param name="entity" select="$related-entity"/>
                                                            <xsl:with-param name="selected-term-lang" select="''"/>
                                                        </xsl:call-template>
                                                    </xsl:variable>
                                                    
                                                    <li>
                                                        <a class="block-link">
                                                            
                                                            <xsl:attribute name="href" select="concat('/glossary/', $related-entity/@xml:id, '.html')"/>
                                                            
                                                            <h4>
                                                                <xsl:attribute name="class">
                                                                    <xsl:value-of select="string-join(('no-bottom-margin', common:lang-class($entity-data/m:label[@type eq 'primary']/@xml:lang)),' ')"/>
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
                                                            
                                                        </a>
                                                    </li>
                                                    
                                                </xsl:for-each>
                                            </ul>
                                            
                                        </xsl:if>
                                        
                                        
                                    </div>
                                </div>
                                
                            </xsl:if>
                            
                            <!-- If it could be TEI editor but isn't, show a button -->
                            <xsl:if test="$tei-editor-off">
                                <div class="bottom-margin">
                                    <a>
                                        <xsl:attribute name="href" select="'?view-mode=editor'"/>
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
                                                    
                                                    <xsl:attribute name="href" select="concat('/tei-editor.html?resource-type=knowledgebase&amp;resource-id=', $article-id,'&amp;passage-id=locking#ajax-source')"/>
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