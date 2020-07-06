<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="epub-page.xsl"/>
    
    <!-- epub:types https://idpf.github.io/epub-vocabs/structure/ -->
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="section-id" select="'preface'"/>
        <xsl:variable name="section-title" select="'Preface'"/>
        <xsl:variable name="section-prefix" select="m:translation/m:preface/@prefix"/>
        <xsl:variable name="translation-title" select="m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
       
        <xsl:call-template name="epub-page">
            <xsl:with-param name="translation-title" select="$translation-title"/>
            <xsl:with-param name="page-title" select="$section-title"/>
            <xsl:with-param name="content">
                <section class="translation" epub:type="preface">
                    
                    <xsl:attribute name="id" select="$section-id"/>
                    
                    <div class="center header">
                        <xsl:call-template name="section-title">
                            <xsl:with-param name="bookmark-id" select="$section-id"/>
                            <xsl:with-param name="prefix" select="$section-prefix"/>
                            <xsl:with-param name="title" select="$section-title"/>
                        </xsl:call-template>
                    </div>
                    
                    <div class="text">
                        <xsl:apply-templates select="m:translation/m:preface"/>
                    </div>
                    
                </section>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>