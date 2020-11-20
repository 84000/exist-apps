<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0" exclude-result-prefixes="#all">
        
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
    
</xsl:stylesheet>