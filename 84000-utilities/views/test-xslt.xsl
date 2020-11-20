<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:template match="/">
        <xsl:value-of select="concat('Hello ','world!')"/>
    </xsl:template>
    
</xsl:stylesheet>