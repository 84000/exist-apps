<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="3.0">
        
    <!-- 
        Converts expanded search result to xhtml
    -->
    
    <xsl:import href="../views/html/website-page.xsl"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment" select="/m:response/m:environment"/>
    <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
    <xsl:variable name="request-translation" select="/m:response/m:search/m:translation"/>
    
    <xsl:template name="search">
        
        <xsl:param name="action" required="yes"/>
        <xsl:param name="lang" required="no"/>
        
        <div id="search-container" class="row">
            
            <div class="col-md-10 col-md-offset-1 col-lg-8 col-lg-offset-2">
                
                <form method="post" role="search" class="form-horizontal">
                    <xsl:attribute name="action" select="$action"/>
                    
                    <xsl:if test="$lang eq 'zh'">
                        <input type="hidden" name="lang">
                            <xsl:attribute name="value" select="$lang"/>
                        </input>
                    </xsl:if>
                    
                    <div class="input-group">
                        <input type="search" name="search" id="search" class="form-control" aria-label="Search text" placeholder="Search" required="required">
                            <xsl:attribute name="value" select="m:search/m:request/text()"/>
                        </input>
                        <span class="input-group-btn">
                            <button type="submit" class="btn btn-primary">
                                <xsl:value-of select="'Search'"/>
                            </button>
                        </span>
                    </div>
                    
                    <xsl:if test="$request-translation">
                        <input type="hidden" name="resource-id" value="{ $request-translation/@id }"/>
                        <div class="alert alert-warning small top-margin no-bottom-margin" role="alert">
                            <xsl:value-of select="concat('in ', $request-translation/m:titles/m:title[@xml:lang eq 'en'][1] , ' / ', $request-translation/m:toh/m:full[1])"/>
                            <span class="pull-right">
                                <a class="inline-block alert-link">
                                    <xsl:attribute name="href" select="common:internal-link($action, concat('search=', m:search/m:request/text()), '', /m:response/@lang)"/>
                                    <xsl:value-of select="'remove filter'"/>
                                </a>
                            </span>
                        </div>
                    </xsl:if>
                    
                </form>
                
                <section>
                    
                    <h2 class="sr-only">
                        <xsl:value-of select="'Results'"/>
                    </h2>
                    
                    <xsl:choose>
                        <xsl:when test="m:search/m:results/m:item">
                            <xsl:variable name="first-record" select="m:search/m:results/@first-record"/>
                            <xsl:for-each select="m:search/m:results/m:item">
                                
                                <xsl:sort select="@score" data-type="number" order="descending"/>
                                <xsl:variable name="tei" select="m:tei"/>
                                <xsl:variable name="matches" select="m:match"/>
                                <xsl:variable name="count-matches" select="@count-records" as="xs:integer"/>
                                <xsl:variable name="record-number" select="$first-record + (position() - 1)"/>
                                
                                <div class="search-result">
                                    
                                    <div class="row">
                                        
                                        <div class="col-sm-12 col-md-10">
                                            
                                            <h3 class="result-title">
                                                <a>
                                                    <!-- If the match is in the main title then use the match, otherwise output the title -->
                                                    <xsl:variable name="title-match" select="$matches[@node-name eq 'title' and @node-type eq 'mainTitle' and @node-lang eq 'en']"/>
                                                    <xsl:choose>
                                                        
                                                        <xsl:when test="$title-match">
                                                            <xsl:attribute name="href" select="common:internal-link(concat($reading-room-path, $title-match/@link), (), '', /m:response/@lang)"/>
                                                            <xsl:apply-templates select="$title-match"/>
                                                        </xsl:when>
                                                        
                                                        <xsl:otherwise>
                                                            <xsl:attribute name="href" select="common:internal-link(concat($reading-room-path, $tei/@link), (), '', /m:response/@lang)"/>
                                                            <xsl:choose>
                                                                <xsl:when test="$tei/m:titles/m:title[@xml:lang eq 'en']/text()">
                                                                    <xsl:value-of select="$tei/m:titles/m:title[@xml:lang eq 'en']"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:value-of select="$tei/m:titles/m:title[@xml:lang eq 'Sa-Ltn']"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                            
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </a>
                                            </h3>
                                            
                                        </div>
                                        
                                        <div class="col-sm-12 col-md-2 text-right-md">
                                            
                                            <xsl:choose>
                                                <xsl:when test="$tei[@type = 'section']">
                                                    <span class="label label-danger">
                                                        <xsl:value-of select="'Section'"/>
                                                    </span>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:copy-of select="common:translation-status($tei/@translation-status-group)"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            
                                        </div>
                                        
                                    </div>
                                    
                                    <xsl:for-each select="$tei/m:bibl">
                                        <xsl:variable name="toh-key" select="m:toh/@key"/>
                                        <nav role="navigation" aria-label="Breadcrumbs" class="small text-muted">
                                            <xsl:value-of select="'in '"/>
                                            <ul class="breadcrumb">
                                                
                                                <xsl:sequence select="common:breadcrumb-items(m:parent/descendant-or-self::m:parent, /m:response/@lang)"/>
                                                
                                                <xsl:if test="m:toh/m:full">
                                                    <li>
                                                        <a>
                                                            <!-- If the match is a Toh number then output the match -->
                                                            <xsl:variable name="key-match" select="$matches[@key eq $toh-key and @node-name eq 'bibl']"/>
                                                            <xsl:choose>
                                                                <xsl:when test="$key-match">
                                                                    <xsl:attribute name="href" select="common:internal-link(concat($reading-room-path, $key-match/@link), (), '', /m:response/@lang)"/>
                                                                    <xsl:apply-templates select="$key-match"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:attribute name="href" select="common:internal-link(concat($reading-room-path, $tei/@link), (), '', /m:response/@lang)"/>
                                                                    <xsl:apply-templates select="m:toh/m:full"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </a>
                                                    </li>
                                                </xsl:if>
                                                
                                            </ul>
                                        </nav>
                                    </xsl:for-each>
                                    
                                    <xsl:variable name="tantric-restriction" select="$tei/m:publication/m:tantric-restriction"/>
                                    <xsl:if test="$tantric-restriction/tei:p">
                                        <div class="row">
                                            <div class="col-sm-12">
                                                <a data-toggle="modal" class="warning">
                                                    <xsl:attribute name="href" select="concat('#tantra-warning-', $tei/@resource-id)"/>
                                                    <xsl:attribute name="data-target" select="concat('#tantra-warning-', $tei/@resource-id)"/>
                                                    <i class="fa fa-exclamation-circle" aria-hidden="true"/>
                                                    <xsl:value-of select="' Tantra Text Warning'"/>
                                                </a>
                                                
                                                <div class="modal fade warning" tabindex="-1" role="dialog">
                                                    <xsl:attribute name="id" select="concat('tantra-warning-', $tei/@resource-id)"/>
                                                    <xsl:attribute name="aria-labelledby" select="concat('tantra-warning-label-', $tei/@resource-id)"/>
                                                    <div class="modal-dialog" role="document">
                                                        <div class="modal-content">
                                                            <div class="modal-header">
                                                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                                    <span aria-hidden="true">
                                                                        <i class="fa fa-times"/>
                                                                    </span>
                                                                </button>
                                                                <h4 class="modal-title">
                                                                    <xsl:attribute name="id" select="concat('tantra-warning-label-', $tei/@resource-id)"/>
                                                                    <i class="fa fa-exclamation-circle" aria-hidden="true"/>
                                                                    <xsl:value-of select="' Tantra Text Warning'"/>
                                                                </h4>
                                                            </div>
                                                            <div class="modal-body">
                                                                <xsl:for-each select="$tantric-restriction/tei:p">
                                                                    <p>
                                                                        <xsl:apply-templates select="node()"/>
                                                                    </p>
                                                                </xsl:for-each>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </xsl:if>
                                    
                                    <section class="result-matches">
                                        
                                        <xsl:variable name="section-id" select="concat('result-matches-', position())"/>
                                        <xsl:attribute name="id" select="$section-id"/>
                                        
                                        <xsl:if test="$count-matches gt 1 and not($request-translation)">
                                            
                                            <xsl:attribute name="class" select="'result-matches preview'"/>
                                            
                                            <xsl:call-template name="preview-controls">
                                                
                                                <xsl:with-param name="section-id" select="$section-id"/>
                                                
                                            </xsl:call-template>
                                            
                                        </xsl:if>
                                        
                                        <div class="row">
                                            <div class="col-sm-12">
                                                
                                                <span class="badge badge-notification">
                                                    <xsl:value-of select="$count-matches"/> 
                                                </span>
                                                
                                                <span class="badge-text">
                                                    <xsl:choose>
                                                        <xsl:when test="$count-matches eq 1">
                                                            <xsl:value-of select="' match'"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="' matches'"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </span>
                                                
                                            </div>
                                        </div>
                                        
                                        <xsl:for-each select="$matches">
                                            <xsl:sort select="@score" data-type="number" order="descending"/>
                                            <xsl:choose>
                                                <xsl:when test="@node-name eq 'title' and @node-type eq 'mainTitle' and @node-lang eq 'en'">
                                                    <!-- Don't bother if it's the title, we already show this -->
                                                </xsl:when>
                                                <xsl:when test="@node-name eq 'bibl' and @key">
                                                    <!-- Don't bother if it's the toh, we already show this -->
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <div class="row">
                                                        
                                                        <div class="col-sm-12">
                                                            
                                                            <xsl:apply-templates select="."/>
                                                            
                                                        </div>
                                                    </div>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:for-each>
                                        
                                        <xsl:if test="$count-matches gt count($matches)">
                                            <div class="row">
                                                
                                                <div class="col-sm-12">
                                                    
                                                    <xsl:if test="not($request-translation)">
                                                        
                                                        <p>
                                                            <xsl:value-of select="concat('These are the first ', count($matches), ' matches. ')"/>
                                                            <a href="" target="_self">
                                                                <xsl:attribute name="href" select="common:internal-link($action, (concat('search=', /m:response/m:search/m:request/text()), concat('resource-id=', $tei/@resource-id)), '', /m:response/@lang)"/>
                                                                <xsl:value-of select="concat('View all ', $count-matches)"/>
                                                            </a>
                                                        </p>
                                                        
                                                    </xsl:if>
                                                    
                                                </div>
                                            </div>
                                            
                                        </xsl:if>
                                        
                                    </section>
                                    
                                </div>
                            </xsl:for-each>
                            
                            <!-- Pagination -->
                            <xsl:if test="m:search/m:results/@count-records gt m:search/m:results/@max-records">
                                <xsl:copy-of select="common:pagination(m:search/m:results/@first-record, m:search/m:results/@max-records, m:search/m:results/@count-records, $action, concat('&amp;search=', m:search/m:request/text()))"/>
                            </xsl:if>
                            
                        </xsl:when>
                        
                        <xsl:otherwise>
                            <br/>
                            <p class="text-center text-muted italic">
                                <xsl:value-of select="'- No search results -'"/>
                            </p>
                        </xsl:otherwise>
                        
                    </xsl:choose>
                    
                </section>
                
            </div>
        
        </div>
    </xsl:template>
    
    <xsl:template match="text()">
        
        <!--<xsl:variable name="text">
            <xsl:choose>
                <xsl:when test="ancestor::tei:term[not(@type)][not(@xml:lang) or @xml:lang eq 'en']">
                    <xsl:value-of select="functx:capitalize-first(.)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>-->
        
        <xsl:value-of select="translate(normalize-space(concat('', translate(., '&#xA;', ''), '')), '', '')"/>
        
    </xsl:template>
    
    <!--<xsl:function name="common:match-url" as="xs:string">
        <xsl:param name="node"/>
        <xsl:param name="lang"/>
        <!-\- Pass the m:match node with an m:tei sibling or just pass the m:tei -\->
        <xsl:variable name="tei" select="($node[self::m:tei] | $node/preceding-sibling::m:tei)[1]"/>
        <xsl:choose>
            <xsl:when test="$tei[@type eq 'translation']">
                <xsl:choose>
                    
                    <xsl:when test="$tei/@translation-status eq '1'">
                        <!-\- Published translation -\->
                        <xsl:variable name="page-url" select="concat($reading-room-path, '/translation/', $tei/m:bibl[1]/m:toh/@key, '.html')"/>
                        <xsl:variable name="fragment-id">
                            <xsl:choose>
                                <!-\- Has an xml:id -\->
                                <xsl:when test="$node/@xml:id">
                                    <xsl:value-of select="concat('#', $node/@xml:id)"/>
                                </xsl:when>
                                <!-\- Has an id -\->
                                <xsl:when test="$node/@tid">
                                    <xsl:value-of select="concat('#node-', $node/@tid)"/>
                                </xsl:when>
                                <!-\- Toh / Scope -\->
                                <xsl:when test="$node/@node-name = ('ref', 'biblScope')">
                                    <xsl:value-of select="'#toh'"/>
                                </xsl:when>
                                <!-\- Author -\->
                                <xsl:when test="$node/@node-name = ('author', 'sponsor')">
                                    <xsl:value-of select="'#acknowledgements'"/>
                                </xsl:when>
                                <!-\- Default to the beginning of the page -\->
                                <xsl:otherwise>
                                    <xsl:value-of select="''"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:value-of select="common:internal-link($page-url, (), $fragment-id, $lang)"/>
                        
                    </xsl:when>
                    
                    <xsl:otherwise>
                        <!-\- Un-published text -\->
                        <xsl:variable name="page-url" select="concat($reading-room-path, '/section/', $tei/m:bibl[1]/m:parent/@id, '.html')"/>
                        <xsl:variable name="fragment-id">
                            <xsl:choose>
                                <xsl:when test="$node/@tid">
                                    <!-\- Has an id that must be elaborated to work in the section/texts list -\->
                                    <xsl:value-of select="concat('#', $tei/m:bibl[1]/m:toh/@key,'-node-', $node/@tid)"/>
                                </xsl:when>
                                <xsl:when test="$node[@node-name eq 'title' and @node-type eq 'otherTitle']">
                                    <!-\- Has a collapsed title in the section/texts list -\->
                                    <xsl:value-of select="concat('#', $tei/m:bibl[1]/m:toh/@key, '-title-variants')"/>
                                </xsl:when>
                                <!-\- Default to the location in the section page -\->
                                <xsl:otherwise>
                                    <xsl:value-of select="concat('#', $tei/m:bibl[1]/m:toh/@key)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:value-of select="common:internal-link($page-url, (), $fragment-id, $lang)"/>
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:when>
            <xsl:when test="$tei[@type = ('section')]">
                <xsl:variable name="page-url" select="concat($reading-room-path, '/section/', $tei/@resource-id, '.html')"/>
                <xsl:variable name="fragment-id">
                    <xsl:choose>
                        <!-\- Has an xml:id -\->
                        <xsl:when test="$node/@xml:id">
                            <xsl:value-of select="concat('#', $node/@xml:id)"/>
                        </xsl:when>
                        <!-\- Has an id -\->
                        <xsl:when test="$node/@tid">
                            <xsl:value-of select="concat('#node-', $node/@tid)"/>
                        </xsl:when>
                        <!-\- Default to the beginning of the page -\->
                        <xsl:otherwise>
                            <xsl:value-of select="''"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="common:internal-link($page-url, (), $fragment-id, $lang)"/>
            </xsl:when>
        </xsl:choose>
        
    </xsl:function>-->
    
    <xsl:template match="m:match">
        <xsl:choose>
            
            <xsl:when test="@node-name eq 'title' and @node-type eq 'mainTitle' and @node-lang eq 'en'">
                <!-- A main title replaces the title string -->
                <xsl:apply-templates select="node()"/>
            </xsl:when>
            
            <xsl:when test="@node-name eq 'bibl' and @key gt ''">
                <!-- A bibl ref replaces the Toh string -->
                <xsl:apply-templates select=".//tei:ref"/>
            </xsl:when>
            
            <xsl:otherwise>
                <!-- Everything else is listed as a search-match -->
                <div class="search-match small">
                    
                    <!-- Output the match (unless it's only in the note) -->
                    <xsl:if test="not(ancestor::tei:note)">
                        <div>
                            <xsl:attribute name="class" select="concat('search-match-', @node-name)"/>
                            <!-- Reduce this to a snippet -->
                            <xsl:apply-templates select="node()"/>
                        </div>
                    </xsl:if>
                    
                    <!-- Output related notes if they have matches too -->
                    <xsl:for-each select="descendant::tei:note[descendant::exist:match]">
                        <div class="row">
                            <div class="col-sm-1">
                                <span>
                                    <xsl:value-of select="@index"/>
                                </span>
                            </div>
                            <div class="col-sm-11">
                                <span>
                                    <!-- Reduce this to a snippet -->
                                    <xsl:apply-templates select="node()"/>
                                </span>
                            </div>
                        </div>
                    </xsl:for-each>
                    
                    <div>
                        <a>
                            <xsl:attribute name="href" select="common:internal-link(concat($reading-room-path, @link), (), '', /m:response/@lang)"/>
                            <xsl:value-of select="'read...'"/>
                        </a>
                    </div>
                    
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="exist:match">
        <span class="mark">
            <xsl:apply-templates select="text()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:note">
        <sup>
            <xsl:attribute name="href">
                <xsl:value-of select="concat('#footnote-', @index)"/>
            </xsl:attribute>
            <xsl:attribute name="id">
                <xsl:value-of select="concat('footnote-link', @index)"/>
            </xsl:attribute>
            <xsl:value-of select="@index"/>
        </sup>
    </xsl:template>
    
    <xsl:template match="tei:title">
        <xsl:choose>
            <xsl:when test="preceding-sibling::*">
                <em>
                    <xsl:apply-templates select="node()"/>
                </em>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="node()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:foreign">
        <span>
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:bibl">
        <p>
            <xsl:apply-templates select="node()"/>
        </p>
    </xsl:template>
    
    <xsl:template match="tei:gloss">
        
        <xsl:variable name="gloss" select="."/>
        
        <h4 class="term">
            <xsl:apply-templates select="$gloss/tei:term[not(@type)][not(@xml:lang) or @xml:lang eq 'en'][1]"/>
        </h4>
        
        <xsl:for-each select="('Bo-Ltn','bo','Sa-Ltn')">
            
            <xsl:variable name="term-lang" select="."/>
            <xsl:variable name="term-lang-terms" select="$gloss/tei:term[not(@type = ('definition','alternative'))][@xml:lang eq $term-lang][normalize-space(data())]"/>
            
            <xsl:choose>
                <xsl:when test="$term-lang-terms">
                    <ul class="list-inline inline-dots">
                
                        <xsl:for-each select="$term-lang-terms">
                            <li>
                                <xsl:attribute name="class" select="common:lang-class($term-lang)"/>
                                <xsl:apply-templates select="node()"/>
                            </li>
                        </xsl:for-each>
                        
                    </ul>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        
        <xsl:for-each select="$gloss/tei:term[@type eq 'definition'][node()]">
            <p>
                <xsl:apply-templates select="node()"/>
            </p>
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>
    
    <xsl:template match="tei:date">
        <span class="date">
            <xsl:apply-templates select="text()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:l">
        <xsl:apply-templates select="node()"/>
        <br/>
    </xsl:template>
    
    <xsl:template match="tei:ref">
        <xsl:choose>
            <xsl:when test="@cRef">
                <span class="ref">[<xsl:apply-templates select="@cRef"/>]</span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="node()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="m:full[parent::m:toh]">
        <xsl:apply-templates select="text()"/>
    </xsl:template>
    
</xsl:stylesheet>