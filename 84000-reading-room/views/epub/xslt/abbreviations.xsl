<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="epub-page.xsl"/>
    
    <!-- epub:types https://idpf.github.io/epub-vocabs/structure/ -->
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="section-id" select="'abbreviations'"/>
        <xsl:variable name="section-title" select="'Abbreviations'"/>
        <xsl:variable name="section-prefix" select="m:translation/m:abbreviations/@prefix"/>
        <xsl:variable name="translation-title" select="m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
        
        <xsl:call-template name="epub-page">
            <xsl:with-param name="translation-title" select="$translation-title"/>
            <xsl:with-param name="page-title" select="$section-title"/>
            <xsl:with-param name="content">
                <section epub:type="index-legend">
                    
                    <xsl:attribute name="id" select="$section-id"/>
                    
                    <div class="center header">
                        <h3>
                            <xsl:value-of select="$section-title"/>
                        </h3>
                    </div>
                    
                    <xsl:call-template name="abbreviations">
                        <xsl:with-param name="translation" select="m:translation"/>
                    </xsl:call-template>
                    
                </section>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>