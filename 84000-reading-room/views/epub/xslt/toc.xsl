<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.daisy.org/z3986/2005/ncx/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:param name="epub-id"/>
    
    <xsl:template match="/m:response">
        
        <ncx version="2005-1" xml:lang="en">
            <head>
                <meta name="dtb:uid" content="{$epub-id}"/>
                <meta name="dtb:depth" content="1"/>
                <meta name="dtb:totalPageCount" content="0"/>
                <meta name="dtb:maxPageNumber" content="0"/>
            </head>
            <docTitle>
                <text>
                    <xsl:apply-templates select="m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
                </text>
            </docTitle>
            <navMap>
                <xsl:call-template name="toc-sections">
                    <xsl:with-param name="sections" select="m:translation/m:toc/m:section"/>
                    <xsl:with-param name="doc-type" select="'ncx'"/>
                </xsl:call-template>
            </navMap>
        </ncx>
    </xsl:template>
</xsl:stylesheet>