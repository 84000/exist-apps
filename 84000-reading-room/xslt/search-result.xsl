<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="2.0">
        
    <!-- 
        Converts expanded search result to xhtml
    -->
    
    <xsl:import href="functions.xsl"/>
    
    <xsl:function name="m:match-url" as="xs:string">
        <xsl:param name="node"/>
        <!-- Pass the m:match node with an m:source sibling or just pass the m:source -->
        <xsl:variable name="source" select="($node[self::m:source] | $node/preceding-sibling::m:source)[1]"/>
        <xsl:choose>
            <xsl:when test="$source[@tei-type eq 'translation']">
                <xsl:choose>
                    
                    <xsl:when test="$source/@translation-status eq '1'">
                        <!-- Published translation -->
                        <xsl:variable name="page-url" select="concat('/translation/', $source/m:bibl[1]/m:toh/@key, '.html')"/>
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
                        <xsl:variable name="page-url" select="concat('/section/', $source/m:bibl[1]/m:parent/@id, '.html')"/>
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
                <xsl:variable name="page-url" select="concat('/section/', $source/@resource-id, '.html')"/>
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
                <xsl:choose>
                    <xsl:when test="tei:note[exist:match] | tei:l/tei:note[exist:match]">
                        <xsl:for-each select="tei:note[exist:match] | tei:l/tei:note[exist:match]">
                            <div class="col-sm-1">
                                <xsl:value-of select="@index"/>
                            </div>
                            <div class="col-sm-11">
                                <xsl:apply-templates select="node()"/>
                            </div>
                        </xsl:for-each>
                    </xsl:when>
                </xsl:choose>
            </div>
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