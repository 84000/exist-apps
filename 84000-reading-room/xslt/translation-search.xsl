<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="2.0">
        
    <!-- 
        Converts expanded search result to xhtml
    -->
    
    <xsl:import href="functions.xsl"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
    <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
    
    <xsl:template name="search">
        <xsl:param name="action"/>
        
        <div id="search-container" class="row">
            
            <div class="col-md-10 col-md-offset-1 col-lg-8 col-lg-offset-2">
                
                <form method="post" class="form-horizontal">
                    <xsl:attribute name="action" select="$action"/>
                    <div class="input-group">
                        <input type="text" name="s" id="search" class="form-control" placeholder="Search" required="required">
                            <xsl:attribute name="value" select="m:search/m:request/text()"/>
                        </input>
                        <span class="input-group-btn">
                            <button type="submit" class="btn btn-primary">
                                Search
                            </button>
                        </span>
                    </div>
                </form>
                
                <xsl:choose>
                    <xsl:when test="m:search/m:results/m:item">
                        <xsl:variable name="first-record" select="m:search/m:results/@first-record"/>
                        <xsl:for-each select="m:search/m:results/m:item">
                            <xsl:variable name="source" select="m:source"/>
                            <div class="search-result">
                                
                                <div class="row">
                                    
                                    <div class="col-sm-1 text-muted">
                                        <xsl:value-of select="$first-record + (position() - 1)"/>.
                                    </div>
                                    
                                    <div class="col-sm-11 col-md-9">
                                        <a>
                                            <xsl:attribute name="href" select="m:match-url($source)"/>
                                            <xsl:value-of select="$source/m:title/text()"/>
                                        </a>
                                    </div>
                                    
                                    <div class="col-sm-11 col-sm-offset-1 col-md-2 col-md-offset-0 text-md-right">
                                        <xsl:choose>
                                            <xsl:when test="$source[@tei-type eq 'section']">
                                                <span class="label label-success">
                                                    Section
                                                </span>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:call-template name="translation-status">
                                                    <xsl:with-param name="status" select="m:source/@translation-status"/>
                                                </xsl:call-template>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </div>
                                    
                                </div>
                                
                                <xsl:for-each select="$source/m:bibl">
                                    <div class="row">
                                        <div class="col-sm-11 col-sm-offset-1 small text-muted">
                                            in
                                            <ul class="breadcrumb">
                                                <xsl:for-each select="m:parent | m:parent//m:parent">
                                                    <xsl:sort select="@nesting" order="descending"/>
                                                    <li>
                                                        <xsl:value-of select="m:title[@xml:lang='en']/text()"/>
                                                    </li>
                                                </xsl:for-each>
                                                <xsl:if test="m:toh/m:full">
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="href" select="m:match-url($source)"/>
                                                            <xsl:value-of select="m:toh/m:full"/>
                                                        </a>
                                                    </li>
                                                </xsl:if>
                                            </ul>
                                        </div>
                                    </div>
                                </xsl:for-each>
                                
                                <section>
                                    <xsl:attribute name="id" select="concat('result-matches-', position())"/>
                                    <div class="relative">
                                        <xsl:if test="count(m:match) gt 1">
                                            <xsl:attribute name="class" select="'relative render-in-viewport'"/>
                                        </xsl:if>
                                        <xsl:for-each select="m:match">
                                            <!-- Don't bother if it's the title, we already show this -->
                                            <xsl:if test="not(@node-type eq 'title' and @type eq 'mainTitle' and @xml:lang eq 'en')">
                                                <div class="row">
                                                    <div class="col-sm-offset-1 col-sm-10">
                                                        <xsl:apply-templates select="."/>
                                                    </div>
                                                </div>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </div>
                                </section>
                                
                            </div>
                        </xsl:for-each>
                        
                        <!-- Pagination -->
                        <xsl:copy-of select="common:pagination(m:search/m:results/@first-record, m:search/m:results/@max-records, m:search/m:results/@count-records, $action, concat('&amp;s=', m:search/m:request/text()))"/>
                        
                    </xsl:when>
                    <xsl:otherwise>
                        <br/>
                        <p>
                            No search results
                        </p>
                    </xsl:otherwise>
                </xsl:choose>
                
            </div>
        </div>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:value-of select="translate(normalize-space(concat('', translate(., '&#xA;', ''), '')), '', '')"/>
    </xsl:template>
    
    <xsl:function name="m:match-url" as="xs:string">
        <xsl:param name="node"/>
        <!-- Pass the m:match node with an m:source sibling or just pass the m:source -->
        <xsl:variable name="source" select="($node[self::m:source] | $node/preceding-sibling::m:source)[1]"/>
        <xsl:choose>
            <xsl:when test="$source[@tei-type eq 'translation']">
                <xsl:choose>
                    
                    <xsl:when test="$source/@translation-status eq '1'">
                        <!-- Published translation -->
                        <xsl:variable name="page-url" select="concat($reading-room-path, '/translation/', $source/m:bibl[1]/m:toh/@key, '.html')"/>
                        <xsl:choose>
                            <!-- Has an xml:id -->
                            <xsl:when test="$node/@xml:id">
                                <xsl:value-of select="concat($page-url, '#', $node/@xml:id)"/>
                            </xsl:when>
                            <!-- Has an id -->
                            <xsl:when test="$node/@tid">
                                <xsl:value-of select="concat($page-url, '#node-', $node/@tid)"/>
                            </xsl:when>
                            <!-- Toh / Scope -->
                            <xsl:when test="$node/@node-type = ('ref', 'biblScope')">
                                <xsl:value-of select="concat($page-url, '#toh')"/>
                            </xsl:when>
                            <!-- Author -->
                            <xsl:when test="$node/@node-type = ('author', 'sponsor')">
                                <xsl:value-of select="concat($page-url, '#acknowledgements')"/>
                            </xsl:when>
                            <!-- Default to the beginning of the page -->
                            <xsl:otherwise>
                                <xsl:value-of select="$page-url"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    
                    <xsl:otherwise>
                        <!-- Un-published text -->
                        <xsl:variable name="page-url" select="concat($reading-room-path, '/section/', $source/m:bibl[1]/m:parent/@id, '.html')"/>
                        <xsl:choose>
                            <xsl:when test="$node/@tid">
                                <!-- Has an id that must be elaborated to work in the section/texts list -->
                                <xsl:value-of select="concat($page-url, '#', $source/m:bibl[1]/m:toh/@key,'-node-', $node/@tid)"/>
                            </xsl:when>
                            <xsl:when test="$node[@node-type eq 'title' and @type eq 'otherTitle']">
                                <!-- Has a collapsed title in the section/texts list -->
                                <xsl:value-of select="concat($page-url, '#', $source/m:bibl[1]/m:toh/@key, '-title-variants')"/>
                            </xsl:when>
                            <!-- Default to the location in the section page -->
                            <xsl:otherwise>
                                <xsl:value-of select="concat($page-url, '#', $source/m:bibl[1]/m:toh/@key)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:when>
            <xsl:when test="$source[@tei-type = ('section', 'grouping')]">
                <xsl:variable name="page-url" select="concat($reading-room-path, '/section/', $source/@resource-id, '.html')"/>
                <xsl:choose>
                    <!-- Has an xml:id -->
                    <xsl:when test="$node/@xml:id">
                        <xsl:value-of select="concat($page-url, '#', $node/@xml:id)"/>
                    </xsl:when>
                    <!-- Has an id -->
                    <xsl:when test="$node/@tid">
                        <xsl:value-of select="concat($page-url, '#node-', $node/@tid)"/>
                    </xsl:when>
                    <!-- Default to the beginning of the page -->
                    <xsl:otherwise>
                        <xsl:value-of select="$page-url"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:template match="m:match">
        <a class="search-match small">
            <xsl:attribute name="href" select="m:match-url(.)"/>
            <div class="row">
                <div class="col-sm-12">
                    <xsl:apply-templates select="node()"/>
                </div>
            </div>
            <xsl:for-each select="descendant::tei:note[descendant::exist:match]">
                <div class="row">
                    <div class="col-sm-1">
                        <xsl:value-of select="@index"/>
                    </div>
                    <div class="col-sm-10">
                        <xsl:apply-templates select="node()"/>
                    </div>
                </div>
            </xsl:for-each>
        </a>
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
    
    <xsl:template match="tei:gloss">
        <xsl:for-each select="tei:term">
            <span>
                <xsl:apply-templates select="node()"/>
            </span>
            <br/>
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
                <xsl:apply-templates select="text()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:term[parent::m:match[@node-type eq 'gloss']]">
        <xsl:choose>
            <xsl:when test="@type eq 'definition'">
                <xsl:apply-templates select="node()"/>.
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="node()"/> · 
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>