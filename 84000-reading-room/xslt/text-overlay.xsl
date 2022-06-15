<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:template name="text-marked">
        <xsl:param name="data"/>
        <xsl:for-each select="$data/node()">
            <xsl:choose>
                
                <!-- Segment folios by ref -->
                <xsl:when test="self::text()[parent::m:folio-content][normalize-space(.)]">
                    <span class="section">
                        <xsl:if test="preceding-sibling::tei:ref[1][@cRef eq //m:folio-content/@start-ref]">
                            <xsl:attribute name="class" select="'selected'"/>
                        </xsl:if>
                        <xsl:value-of select="concat(normalize-space(.),' ')"/>
                    </span>
                </xsl:when>
                
                <!-- Segment source by p -->
                <xsl:when test="self::tei:p[parent::m:language]">
                    <span class="section">
                        <xsl:if test="@class eq 'selected'">
                            <xsl:attribute name="class" select="'selected'"/>
                        </xsl:if>
                        <xsl:for-each select="text()[normalize-space(.)]">
                            <span>
                                <xsl:attribute name="data-line" select="preceding-sibling::tei:milestone[@unit eq 'line'][1]/@n"/>
                                <xsl:call-template name="normalize">
                                    <xsl:with-param name="text" select="concat(., ' ')"/>
                                </xsl:call-template>
                            </span>
                        </xsl:for-each>
                    </span>
                </xsl:when>
                
                <!-- ignore -->
                <xsl:otherwise>
                    
                </xsl:otherwise>
                
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="text-plain">
        <xsl:param name="data"/>
        <xsl:for-each select="$data/node()">
            <xsl:choose>
                
                <!-- Output text nodes only -->
                <xsl:when test="self::text()[normalize-space(.)][parent::tei:p]">
                    <xsl:call-template name="normalize">
                        <xsl:with-param name="text" select="concat(., ' ')"/>
                    </xsl:call-template>
                </xsl:when>
                
                <xsl:when test="self::text()[normalize-space(.)]">
                    <xsl:value-of select="concat(normalize-space(.),' ')"/>
                </xsl:when>
                
                <!-- ignore -->
                <xsl:otherwise>
                    
                </xsl:otherwise>
                
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="normalize">
        <xsl:param name="text" as="xs:string"/>
        <xsl:value-of select="translate(normalize-space(concat('', translate(replace($text, '་\s+$', '་'), '&#xA;', ''), '')), '', '')"/>
    </xsl:template>
    
</xsl:stylesheet>