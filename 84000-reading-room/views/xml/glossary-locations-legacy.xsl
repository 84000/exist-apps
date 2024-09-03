<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:template match="/m:glossary-cached-locations">
        <cache xmlns="http://read.84000.co/ns/1.0">
            <glossary-cache>
                <xsl:sequence select="@*"/>
                <xsl:sequence select="*"/>
            </glossary-cache>
        </cache>
    </xsl:template>
    
</xsl:stylesheet>