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
                            <xsl:variable name="matches" select="m:match"/>
                            <xsl:variable name="count-matches" select="count(m:match)"/>
                            <div class="search-result">
                                
                                <div class="row">
                                    
                                    <div class="col-sm-1 text-muted">
                                        <xsl:value-of select="$first-record + (position() - 1)"/>.
                                    </div>
                                    
                                    <div class="col-sm-11 col-md-9">
                                        <a>
                                            <xsl:attribute name="href" select="m:match-url($source)"/>
                                            <xsl:choose>
                                                <xsl:when test="$matches[@node-type eq 'title' and @type eq 'mainTitle' and @xml:lang eq 'en']">
                                                    <xsl:apply-templates select="$matches[@node-type eq 'title' and @type eq 'mainTitle' and @xml:lang eq 'en']"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="$source/m:title/text()"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </a>
                                    </div>
                                    
                                    <div class="col-sm-11 col-sm-offset-1 col-md-2 col-md-offset-0 text-md-right">
                                        <xsl:choose>
                                            <xsl:when test="$source[@tei-type = 'section']">
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
                                    <xsl:variable name="toh-key" select="m:toh/@key"/>
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
                                                            <xsl:choose>
                                                                <xsl:when test="$matches[@key eq $toh-key and @node-type eq 'bibl']">
                                                                    <xsl:apply-templates select="$matches[@key eq $toh-key and @node-type eq 'bibl']"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:apply-templates select="m:toh/m:full"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
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
                                        <xsl:if test="$count-matches gt 1">
                                            <xsl:attribute name="class" select="'relative render-in-viewport'"/>
                                        </xsl:if>
                                        
                                        <div class="row">
                                            <div class="col-sm-offset-1 col-sm-10">
                                                <span class="small text-muted">
                                                    <span class="badge badge-muted badge-notification">
                                                        <xsl:value-of select="$count-matches"/> 
                                                    </span>
                                                    <xsl:choose>
                                                        <xsl:when test="$count-matches eq 1">
                                                            match
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            matches
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                    
                                                </span>
                                            </div>
                                        </div>
                                        
                                        <xsl:for-each select="$matches">
                                            <xsl:choose>
                                                <xsl:when test="@node-type eq 'title' and @type eq 'mainTitle' and @xml:lang eq 'en'">
                                                    <!-- Don't bother if it's the title, we already show this -->
                                                </xsl:when>
                                                <xsl:when test="@node-type eq 'bibl' and @key">
                                                    <!-- Don't bother if it's the toh, we already show this -->
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <div class="row">
                                                        <div class="col-sm-offset-1 col-sm-10">
                                                            <xsl:apply-templates select="."/>
                                                        </div>
                                                    </div>
                                                </xsl:otherwise>
                                            </xsl:choose>
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
            <xsl:when test="$source[@tei-type = ('section')]">
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
        <xsl:choose>
            <xsl:when test="@node-type eq 'title' and @type eq 'mainTitle' and @xml:lang eq 'en'">
                <!-- A main title replaces the title string -->
                <xsl:apply-templates select="node()"/>
            </xsl:when>
            <xsl:when test="@node-type eq 'bibl' and @key gt ''">
                <!-- A bibl ref replaces the Toh string -->
                <xsl:apply-templates select="tei:ref"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- Everything else is listed as a search-match -->
                <div class="search-match">
                    
                    <!-- Output the match (unless it's only in the note) -->
                    <xsl:if test="descendant::exist:match[not(ancestor::tei:note)]">
                        <div class="row">
                            <div class="col-sm-12">
                                <span class="small">
                                    <xsl:if test="@node-type = ('title', 'head')">
                                        <xsl:attribute name="class" select="''"/>
                                        <xsl:if test="@type eq 'chapter'">
                                            <xsl:attribute name="class" select="'uppercase'"/>
                                        </xsl:if>
                                    </xsl:if>
                                    <!-- Reduce this to a snippet -->
                                    <xsl:apply-templates select="node()"/>
                                </span>
                            </div>
                        </div>
                    </xsl:if>
                    
                    <!-- Output related notes if they have matches too -->
                    <xsl:for-each select="descendant::tei:note[descendant::exist:match]">
                        <div class="row">
                            <div class="col-sm-1">
                                <span class="small">
                                    <xsl:value-of select="@index"/>
                                </span>
                            </div>
                            <div class="col-sm-10">
                                <span class="small">
                                    <!-- Reduce this to a snippet -->
                                    <xsl:apply-templates select="node()"/>
                                </span>
                            </div>
                        </div>
                    </xsl:for-each>
                    
                    <div class="row">
                        <div class="col-sm-12">
                            <a class="small">
                                <xsl:attribute name="href" select="m:match-url(.)"/>
                                read...
                            </a>
                        </div>
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
                <xsl:apply-templates select="node()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:term[parent::m:match[@node-type eq 'gloss']]">
        <xsl:choose>
            <xsl:when test="@type eq 'definition'">
                <xsl:apply-templates select="node()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="node()"/> · 
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="m:full[parent::m:toh]">
        <xsl:apply-templates select="text()"/>
    </xsl:template>
    
</xsl:stylesheet>