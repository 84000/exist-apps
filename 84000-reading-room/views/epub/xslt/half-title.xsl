<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="epub-page.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="page-title" select="'Half Title'"/>
        <xsl:variable name="translation-title" select="m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
        
        <xsl:variable name="content">
            <section class="center half-title" epub:type="halftitlepage">
                <h2 class="text-bo">
                    <xsl:apply-templates select="m:translation/m:titles/m:title[@xml:lang eq 'bo']"/>
                </h2>
                <h1>
                    <xsl:apply-templates select="m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
                </h1>
                <h2 class="text-sa">
                    <xsl:apply-templates select="m:translation/m:titles/m:title[@xml:lang eq 'sa-ltn']"/>
                </h2>
                <img src="image/logo-stacked.png" alt="84000 Translating the Words of the Buddha Logo" class="logo logo-84000"/>
            </section>
        </xsl:variable>
        
        <xsl:call-template name="epub-page">
            <xsl:with-param name="translation-title" select="$translation-title"/>
            <xsl:with-param name="page-title" select="$page-title"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>