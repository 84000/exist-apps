<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
        
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
    
    <xsl:template name="expandable-toh">
        <xsl:param name="toh" required="yes" as="element(m:toh)"/>
        <xsl:choose>
            <xsl:when test="$toh/m:duplicates">
                <xsl:variable name="expand-id" select="concat('expand-toh-', $toh/@key)"/>
                <a role="button" data-toggle="collapse" aria-expanded="true" class="collapsed nowrap">
                    <xsl:attribute name="href" select="concat('#', $expand-id)"/>
                    <xsl:attribute name="aria-controls" select="$expand-id"/>
                    <xsl:value-of select="$toh/m:full"/>
                    <span class="collapsed-show">
                        <span class="monospace">+</span>
                    </span>
                </a>
                <div class="collapse print-expand">
                    <xsl:attribute name="id" select="$expand-id"/>
                    <xsl:for-each select="$toh/m:duplicates/m:duplicate">
                        <span class="nowrap">
                            <xsl:value-of select="normalize-space(concat(' / ', m:full/text()))"/>
                        </span>
                        <br/>
                    </xsl:for-each>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <span class="nowrap">
                    <xsl:value-of select="$toh/m:full"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>