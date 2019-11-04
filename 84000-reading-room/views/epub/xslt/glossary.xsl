<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="epub-page.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="section-id" select="'glossary'"/>
        <xsl:variable name="section-title" select="'Glossary'"/>
        <xsl:variable name="section-prefix" select="m:translation/m:glossary/@prefix"/>
        <xsl:variable name="translation-title" select="m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
        
        <xsl:call-template name="epub-page">
            <xsl:with-param name="translation-title" select="$translation-title"/>
            <xsl:with-param name="page-title" select="$section-title"/>
            <xsl:with-param name="content">
                <section epub:type="glossary">
                    
                    <xsl:attribute name="id" select="$section-id"/>
                    
                    <div class="center header">
                        <h3>
                            <xsl:value-of select="$section-title"/>
                        </h3>
                    </div>
                    
                    <xsl:for-each select="m:translation/m:glossary/m:item">
                        <xsl:sort select="common:standardized-sa(m:term[lower-case(@xml:lang) = 'en'][1])"/>
                        <div class="glossary-item">
                            <xsl:call-template name="glossary-item">
                                <xsl:with-param name="glossary-item" select="."/>
                            </xsl:call-template>
                        </div>
                    </xsl:for-each>
                    
                </section>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>