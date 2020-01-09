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
        <xsl:param name="action" required="yes"/>
        <xsl:param name="lang" required="no"/>
        
        <div id="search-container" class="row">
            
            <div class="col-md-10 col-md-offset-1 col-lg-8 col-lg-offset-2">
                
                <form method="post" class="form-horizontal">
                    <xsl:attribute name="action" select="$action"/>
                    <xsl:if test="$lang eq 'zh'">
                        <input type="hidden" name="lang">
                            <xsl:attribute name="value" select="$lang"/>
                        </input>
                    </xsl:if>
                    <div class="input-group">
                        <input type="text" name="search" id="search" class="form-control" placeholder="Search" required="required">
                            <xsl:attribute name="value" select="m:search/m:request/text()"/>
                        </input>
                        <span class="input-group-btn">
                            <button type="submit" class="btn btn-primary">
                                <xsl:value-of select="'Search'"/>
                            </button>
                        </span>
                    </div>
                </form>
                
                <xsl:choose>
                    <xsl:when test="m:search/m:results/m:item">
                        <xsl:variable name="first-record" select="m:search/m:results/@first-record"/>
                        <xsl:for-each select="m:search/m:results/m:item">
                            <xsl:sort select="@score" data-type="number" order="descending"/>
                            <xsl:variable name="tei" select="m:tei"/>
                            <xsl:variable name="matches" select="m:match"/>
                            <xsl:variable name="count-matches" select="count(m:match)"/>
                            <div class="search-result">
                                
                                <div class="row">
                                    
                                    <div class="col-sm-1 text-muted">
                                        <xsl:value-of select="$first-record + (position() - 1)"/>.
                                    </div>
                                    
                                    <div class="col-sm-11 col-md-9">
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
                                                    <xsl:value-of select="$tei/m:titles/m:title[@xml:lang eq 'en']"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </a>
                                    </div>
                                    
                                    <div class="col-sm-11 col-sm-offset-1 col-md-2 col-md-offset-0 text-md-right">
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
                                    <div class="row">
                                        <div class="col-sm-11 col-sm-offset-1 small text-muted">
                                            <xsl:value-of select="'in'"/>
                                            <ul class="breadcrumb">
                                                <xsl:for-each select="m:parent | m:parent//m:parent">
                                                    <xsl:sort select="@nesting" order="descending"/>
                                                    <li>
                                                        <xsl:value-of select="m:titles/m:title[@xml:lang='en']"/>
                                                    </li>
                                                </xsl:for-each>
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
                        <xsl:copy-of select="common:pagination(m:search/m:results/@first-record, m:search/m:results/@max-records, m:search/m:results/@count-records, $action, concat('&amp;search=', m:search/m:request/text()))"/>
                        
                    </xsl:when>
                    <xsl:otherwise>
                        <br/>
                        <p class="text-center text-muted italic">
                            <xsl:value-of select="'- No search results -'"/>
                        </p>
                    </xsl:otherwise>
                </xsl:choose>
                
            </div>
        </div>
    </xsl:template>
    
    <xsl:template match="text()">
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
                <div class="search-match">
                    
                    <!-- Output the match (unless it's only in the note) -->
                    <xsl:if test="not(ancestor::tei:note)">
                        <div class="small">
                            <xsl:if test="@node-name = ('title', 'head')">
                                <xsl:attribute name="class" select="''"/>
                                <xsl:if test="@node-type eq 'chapter'">
                                    <xsl:attribute name="class" select="'uppercase'"/>
                                </xsl:if>
                            </xsl:if>
                            <!-- Reduce this to a snippet -->
                            <xsl:apply-templates select="node()"/>
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
                            <div class="col-sm-11">
                                <span class="small">
                                    <!-- Reduce this to a snippet -->
                                    <xsl:apply-templates select="node()"/>
                                </span>
                            </div>
                        </div>
                    </xsl:for-each>
                    
                    <div class="small">
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
    
    <xsl:template match="tei:term[parent::m:match[@node-name eq 'gloss']]">
        <xsl:choose>
            <xsl:when test="@node-type eq 'definition'">
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