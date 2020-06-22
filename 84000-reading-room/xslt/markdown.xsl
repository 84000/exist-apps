<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="xs" version="2.0">
    

    <!-- This is markup so mark it down -->
    <xsl:template match="m:markup">
        <!--<m:markdown>
            <!-\- Loop through nodes formatting everything to strings -\->
            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test=". instance of text()">
                        <xsl:value-of select="."/>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </m:markdown>-->
        <xsl:variable name="serialization-parameters" as="element(output:serialization-parameters)">
            <output:serialization-parameters>
                <output:method value="xml"/>
                <output:version value="1.1"/>
                <output:indent value="no"/>
                <output:omit-xml-declaration value="yes"/>
            </output:serialization-parameters>
        </xsl:variable>
        <xsl:value-of select="replace(normalize-space(serialize(node(), $serialization-parameters)), '\sxmlns\S+', ' ')"/>
    </xsl:template>
    
    <!-- This is markdown so mark it up -->
    <xsl:template match="m:markdown">
        <m:markup>
            <!-- Parse string creating nodes -->
            
        </m:markup>
    </xsl:template>
    
</xsl:stylesheet>