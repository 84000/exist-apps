<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
        
    <xsl:template name="indent">
        <xsl:param name="counter"/>
        <xsl:param name="finish"/>
        <xsl:param name="content"/>
        <span class="indent">
            <xsl:choose>
                <xsl:when test="$counter eq $finish">
                    <xsl:copy-of select="$content"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="indent">
                        <xsl:with-param name="counter" select="$counter + 1"/>
                        <xsl:with-param name="finish" select="$finish"/>
                        <xsl:with-param name="content" select="$content"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>
    
    <xsl:template name="preview-controls">
        
        <xsl:param name="section-id" as="xs:string"/>
        <xsl:param name="get-url" as="xs:string?"/>
        <xsl:param name="log-click" as="xs:boolean?"/>
        
        <!-- Expand -->
        <a target="_self" title="Read this section">
            
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="$get-url">
                        <xsl:value-of select="$get-url"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('#', $section-id)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            
            <xsl:attribute name="class">
                <xsl:value-of select="'reveal'"/>
                <xsl:if test="$log-click">
                    <xsl:value-of select="' log-click'"/>
                </xsl:if>
                <xsl:if test="$get-url">
                    <xsl:value-of select="' scroll-to-anchor'"/>
                </xsl:if>
            </xsl:attribute>
            
            <span class="btn-round">
                <i class="fa fa-angle-down"/>
            </span>
            
        </a>
        
        <!-- Collapse -->
        <a class="preview" title="Close this section">
            <xsl:attribute name="href" select="concat('#', $section-id)"/>
            <span class="btn-round">
                <i class="fa fa-times"/>
            </span>
        </a>
        
    </xsl:template>
    
</xsl:stylesheet>