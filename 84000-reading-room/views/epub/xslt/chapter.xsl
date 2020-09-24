<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="epub-page.xsl"/>
    
    <!-- epub:types https://idpf.github.io/epub-vocabs/structure/ -->
    
    <xsl:param name="section-id" required="yes"/>
    <xsl:param name="parent-id" required="yes"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="section" select="m:translation/m:section[@section-id eq $parent-id]/m:section[@section-id eq $section-id]"/>
        
        <xsl:call-template name="epub-page">
            <xsl:with-param name="page-title" select="$section/tei:head[@type eq $section/@type]"/>
            <xsl:with-param name="content">
                
                <section epub:type="chapter" class="text">
                    <xsl:apply-templates select="$section"/>
                </section>
                
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>