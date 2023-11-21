<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:bdo="http://purl.bdrc.io/ontology/core/" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/webpage.xsl"/>
    
    <xsl:variable name="request" select="/m:response/m:request"/>
    <xsl:variable name="translation" select="/m:response/m:translation" as="element(m:translation)?"/>
    <xsl:variable name="text-id" select="$translation/@id" as="xs:string?"/>
    <xsl:variable name="toh-key" select="$translation/m:source/@key" as="xs:string?"/>
    <xsl:variable name="toh-number" select="$translation/m:toh/@key ! replace(., '^toh', '')" as="xs:string?"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="work" select="m:source/@work"/>
        
        <xsl:variable name="work-string" as="xs:string">
            <xsl:choose>
                <xsl:when test="$work eq 'UT23703'">
                    <xsl:value-of select="'Tengyur'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'Kangyur'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="content">
            
            <!-- Breadcrumbs -->
            <xsl:if test="$translation[m:parent]">
                <div class="title-band hidden-print hidden-iframe">
                    <div class="container">
                        <div class="center-vertical center-aligned text-center">
                            <nav role="navigation" aria-label="Breadcrumbs">
                                <ul id="outline" class="breadcrumb">
                                    <xsl:sequence select="common:breadcrumb-items($translation/m:parent/descendant-or-self::m:parent, /m:response/@lang)"/>
                                </ul>
                            </nav>
                        </div>
                    </div>
                </div>
            </xsl:if>
            
            <!-- Main content -->
            <main id="source-content" class="content-band">
                
                <!-- Output folios -->
                <div>
                    <xsl:for-each select="m:source/m:page">
                        <div>
                            
                            <xsl:variable name="folio-string" as="xs:string">
                                <xsl:choose>
                                    <xsl:when test="$translation/m:folio-content[@start-ref gt '']">
                                        <xsl:value-of select="$translation/m:folio-content/@start-ref"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat('folio ', @folio-in-etext)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            
                            <!-- Text title -->
                            <div class="text-center hidden-iframe">
                                
                                <div class="container">
                                    <div class="row top-margin bottom-margin">
                                        <div class="col-md-offset-1 col-md-10 col-lg-offset-2 col-lg-8 print-width-override">
                                            
                                            <xsl:if test="$translation/m:titles/m:title[@xml:lang eq 'bo']">
                                                <h2 class="title text-bo">
                                                    <xsl:apply-templates select="$translation/m:titles/m:title[@xml:lang eq 'bo']"/>
                                                </h2>
                                            </xsl:if>
                                            
                                            <xsl:if test="$translation/m:titles/m:title[@xml:lang eq 'bo']">
                                                <hr/>
                                                <h2 class="title main-title">
                                                    <xsl:value-of select="$translation/m:titles/m:title[@xml:lang eq 'en']"/>
                                                </h2>
                                            </xsl:if>
                                            
                                            <xsl:if test="$translation/m:titles/m:title[@xml:lang eq 'Sa-Ltn']">
                                                <hr/>
                                                <h2 class="title text-sa">
                                                    <xsl:apply-templates select="$translation/m:titles/m:title[@xml:lang eq 'Sa-Ltn']"/>
                                                </h2>
                                            </xsl:if>
                                            
                                        </div>
                                    </div>
                                </div>
                                
                                <hr/>
                                
                            </div>
                            
                            <!-- Page title (folio) -->
                            <div id="folio-content" class="container text-center">
                                <h1 class="title" id="popup-title">
                                    <xsl:value-of select="concat('Degé ', $work-string, ' volume ', @volume, ', ', $folio-string)"/>
                                </h1>
                            </div>
                            
                            <!-- Content -->
                            <div class="container relative">
                                <xsl:apply-templates select="m:language[@xml:lang eq 'bo']"/>
                            </div>
                            
                            <!-- Pagination -->
                            <xsl:variable name="current-page" select="$request/@ref-index" as="xs:integer?"/>
                            <xsl:variable name="count-pages" select="$translation/m:folio-content/@count-refs" as="xs:integer?"/>
                            <div class="text-center">
                                <nav aria-label="Page navigation" class="pagination-nav">
                                    <ul class="pagination no-top-margin">
                                        
                                        <xsl:if test="$request/@ref-index ! xs:integer(.) gt  1">
                                            <li>
                                                <a>
                                                    <xsl:attribute name="href" select="concat('/source/', $toh-key,'.html?ref-index=', '1')"/>
                                                    <!--<xsl:attribute name="data-ajax-target" select="'#source-content'"/>-->
                                                    <xsl:attribute name="title" select="'first page (1)'"/>
                                                    <xsl:attribute name="target" select="'_self'"/>
                                                    <xsl:attribute name="data-loading" select="'Loading first page...'"/>
                                                    <!--<xsl:value-of select="'page 1'"/>-->
                                                    <i class="fa fa-step-backward"/>
                                                </a>
                                            </li>
                                            <li>
                                                <a>
                                                    <xsl:attribute name="href" select="concat('/source/', $toh-key,'.html?ref-index=', ($current-page - 1))"/>
                                                    <!--<xsl:attribute name="data-ajax-target" select="'#source-content'"/>-->
                                                    <xsl:attribute name="title" select="concat('previous page (', format-number(($current-page - 1), '#,###'), ')')"/>
                                                    <xsl:attribute name="target" select="'_self'"/>
                                                    <xsl:attribute name="data-loading" select="'Loading previous page...'"/>
                                                    <i class="fa fa-chevron-left"/>
                                                </a>
                                            </li>
                                        </xsl:if>
                                        
                                        <li class="active">
                                            <span>
                                                <xsl:value-of select="concat('page ', format-number($current-page, '#,###'), ' of ', format-number($count-pages, '#,###'))"/>
                                            </span>
                                        </li>
                                        
                                        <xsl:if test="$current-page lt $count-pages">
                                            <li>
                                                <a>
                                                    <xsl:attribute name="href" select="concat('/source/', $toh-key,'.html?ref-index=', ($current-page + 1))"/>
                                                    <!--<xsl:attribute name="data-ajax-target" select="'#source-content'"/>-->
                                                    <xsl:attribute name="title" select="concat('next page (', format-number(($current-page + 1), '#,###'), ')')"/>
                                                    <xsl:attribute name="target" select="'_self'"/>
                                                    <xsl:attribute name="data-loading" select="'Loading next page...'"/>
                                                    <i class="fa fa-chevron-right"/>
                                                </a>
                                            </li>
                                            <li>
                                                <a>
                                                    <xsl:attribute name="href" select="concat('/source/', $toh-key,'.html?ref-index=', $count-pages)"/>
                                                    <!--<xsl:attribute name="data-ajax-target" select="'#source-content'"/>-->
                                                    <xsl:attribute name="title" select="concat('last page (', format-number($count-pages, '#,###'), ')')"/>
                                                    <xsl:attribute name="target" select="'_self'"/>
                                                    <xsl:attribute name="data-loading" select="'Loading last page...'"/>
                                                    <!--<xsl:value-of select="'page ' || $count-pages"/>-->
                                                    <i class="fa fa-step-forward"/>
                                                </a>
                                            </li>
                                        </xsl:if>
                                        
                                    </ul>
                                </nav>
                            </div>
                            
                            <!-- Links -->
                            <xsl:if test="$tei-editor-off and $environment/m:url[@id eq 'operations'][text()]">
                                <div class="container text-center bottom-margin">
                                    <ul class="list-inline inline-dots">
                                        
                                        <!-- Editor link -->
                                        <li>
                                            <a class="editor" target="84000-operations">
                                                <xsl:attribute name="href" select="concat($environment/m:url[@id eq 'operations']/data(), '/source-utils.html?text-id=', $text-id, $request/@ref-index ! concat('&amp;ref-index=', .))"/>
                                                <xsl:value-of select="'Open source utilities'"/>
                                            </a>
                                        </li>
                                        
                                    </ul>
                                </div>
                            </xsl:if>
                            
                            <hr/>
                            
                            <!-- Footer - about the etext -->
                            <div class="container footer text-center" id="source-footer">
                                
                                <p class="text-muted">
                                    <xsl:value-of select="concat(if($work eq 'UT23703') then 'eTengyur' else 'eKangyur', ', ', @etext-id, ', page ', @page-in-volume, ' (', @folio-in-etext, ').')"/>
                                    <br/>
                                    <a href="#etext-description-{ position() }" role="button" data-toggle="collapse" class="small text-muted">
                                        <i class="fa fa-info-circle"/>
                                        <xsl:value-of select="' '"/>
                                        <xsl:call-template name="local-text">
                                            <xsl:with-param name="local-key" select="if($work eq 'UT23703') then 'etengyur-description-title' else 'ekangyur-description-title'"/>
                                        </xsl:call-template>
                                    </a>
                                </p>
                                
                                <div id="etext-description-{ position() }" class="well well-sml collapse">
                                    <xsl:call-template name="local-text">
                                        <xsl:with-param name="local-key" select="if($work eq 'UT23703') then 'etengyur-description-content' else 'ekangyur-description-content'"/>
                                    </xsl:call-template>
                                </div>
                                
                            </div>
                            
                        </div>
                    </xsl:for-each>
                </div>
                
                <!-- Link to translation - keep outside of ajax data -->
                <xsl:if test="m:back-link[@url]">
                    <div class="hidden-iframe">
                        <hr class="no-margin"/>
                        <div class="container top-margin bottom-margin">
                            <p class="text-center small">
                                <xsl:call-template name="local-text">
                                    <xsl:with-param name="local-key" select="'backlink-label'"/>
                                </xsl:call-template>
                                <br/>
                                <a>
                                    <xsl:attribute name="href" select="m:back-link/@url"/>
                                    <xsl:attribute name="target" select="concat(m:translation/@id, '.html')"/>
                                    <xsl:value-of select="m:back-link/@url"/>
                                </a>
                            </p>
                        </div>
                    </div>
                </xsl:if>
                
            </main>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="(m:source/@page-url, '')[1]"/>
            <xsl:with-param name="page-class" select="'reading-room source'"/>
            <xsl:with-param name="page-title" select="string-join((concat(m:translation/m:toh/m:full, ' Vol.', m:source/m:page[1]/@volume, ' F.', m:source/m:page[1]/@folio-in-volume), 'Tibetan Source', '84000 Reading Room'), ' | ')"/>
            <xsl:with-param name="page-description" select="normalize-space(m:section/m:abstract/tei:p[1]/text())"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template match="tei:p[@class eq 'selected']">
        
        <xsl:variable name="preceding-word" select="tokenize(preceding-sibling::tei:p/text()[last()], '\s+')[last()]"/>
        <xsl:variable name="last-word" select="tokenize(text()[normalize-space(.)][last()], '\s+')[normalize-space(.)][last()] ! normalize-space(.)"/>
        <xsl:variable name="following-word" select="tokenize(following-sibling::tei:p/text()[1], '\s+')[1]"/>
        
        <xsl:variable name="text-content" as="node()*">
            
            <!-- To avoid part sentences, include the last partial sentence from the preceding paragraph -->
            <xsl:if test="$preceding-word gt '' and not(ends-with($preceding-word, '།'))">
                <span class="text-muted" aria-hidden="true">
                    <xsl:value-of select="common:normalize-bo($preceding-word)"/>
                </span>
            </xsl:if>
            
            <!-- Indicate text that is from the preceding text -->
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="$toh-number and following-sibling::tei:milestone[@unit eq 'text'][@toh eq $toh-number] and descendant-or-self::text()">
                        <span class="text-muted" aria-hidden="true">
                            <xsl:value-of select="common:normalize-bo(.)"/>
                        </span>
                    </xsl:when>
                    <xsl:when test="$toh-number and preceding-sibling::tei:milestone[@unit eq 'text'][1][@toh ne $toh-number] and descendant-or-self::text()">
                        <span class="text-muted" aria-hidden="true">
                            <xsl:value-of select="common:normalize-bo(.)"/>
                        </span>
                    </xsl:when>
                    <xsl:when test="descendant-or-self::text()">
                        <xsl:value-of select="common:normalize-bo(.)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
            
            <!-- To avoid part sentences, include the first partial sentence from the following paragraph -->
            <xsl:if test="$following-word gt '' and not(ends-with($last-word, '།'))">
                <span class="text-muted" aria-hidden="true">
                    <xsl:value-of select="common:normalize-bo($following-word)"/>
                </span>
            </xsl:if>
            
        </xsl:variable>
        
        <p class="source text-bo">
            <xsl:sequence select="$text-content"/>
        </p>
        
    </xsl:template>
    
    <xsl:template match="tei:p">
        <!-- Ignore non-selected <p/>s -->
    </xsl:template>
    
    <xsl:template match="tei:milestone[@unit eq 'line']">
        <xsl:if test="@n ne '1'">
            <!-- <br/> -->
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>