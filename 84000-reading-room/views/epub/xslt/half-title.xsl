<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="epub-page.xsl"/>
    
    <!-- epub:types https://idpf.github.io/epub-vocabs/structure/ -->
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="section" select="m:translation/m:toc/m:section[@section-id eq 'half-title']"/>
        
        <xsl:call-template name="epub-page">
            <xsl:with-param name="page-title" select="$section/tei:head[@type eq $section/@type]"/>
            <xsl:with-param name="content">
                <div>
                    
                    <xsl:attribute name="id" select="$section/@section-id"/>
                    
                    <section epub:type="halftitlepage" class="heading-section">
                    
                        <h2 class="text-bo">
                            <xsl:apply-templates select="m:translation/m:titles/m:title[@xml:lang eq 'bo']"/>
                        </h2>
                        
                        <h1>
                            <xsl:apply-templates select="m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
                        </h1>
                        
                        <h2 class="text-sa">
                            <xsl:apply-templates select="m:translation/m:titles/m:title[@xml:lang eq 'Sa-Ltn']"/>
                        </h2>
                        
                        <img src="image/logo-stacked.png" alt="84000 Translating the Words of the Buddha Logo" class="logo logo-84000"/>
                    
                    </section>
                </div>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>