<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="epub-page.xsl"/>
    
    <!-- epub:types https://idpf.github.io/epub-vocabs/structure/ -->
    
    <xsl:template match="/m:response">
        
        <xsl:call-template name="epub-page">
            <xsl:with-param name="page-title" select="'Title'"/>
            <xsl:with-param name="content">
                <div>
                    
                    <xsl:attribute name="id" select="'titles'"/>
                    
                    <section epub:type="halftitlepage" class="new-page heading-section">
                    
                        <h2 class="main-title text-bo">
                            <xsl:apply-templates select="m:translation/m:titles/m:title[@xml:lang eq 'bo']"/>
                        </h2>
                        
                        <h1 class="main-title">
                            <xsl:apply-templates select="m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
                        </h1>
                        
                        <h2 class="main-title text-sa">
                            <xsl:apply-templates select="m:translation/m:titles/m:title[@xml:lang eq 'Sa-Ltn']"/>
                        </h2>
                        
                        <img src="image/logo-stacked.png" alt="84000 Translating the Words of the Buddha Logo" class="logo logo-84000"/>
                    
                    </section>
                    
                    <section epub:type="titlepage" class="new-page">
                        
                        <div class="heading-section">
                            
                            <xsl:if test="m:translation/m:long-titles/m:title[@xml:lang eq 'bo'][text()]">
                                <h2 class="text-bo">
                                    <xsl:apply-templates select="m:translation/m:long-titles/m:title[@xml:lang eq 'bo']"/>
                                </h2>
                            </xsl:if>
                            
                            <xsl:if test="m:translation/m:long-titles/m:title[@xml:lang eq 'Bo-Ltn'][text()]">
                                <h2>
                                    <xsl:apply-templates select="m:translation/m:long-titles/m:title[@xml:lang eq 'Bo-Ltn']"/>
                                </h2>
                            </xsl:if>
                            
                            <xsl:if test="m:translation/m:long-titles/m:title[@xml:lang eq 'en'][text()]">
                                <h1>
                                    <xsl:apply-templates select="m:translation/m:long-titles/m:title[@xml:lang eq 'en']"/>
                                </h1>
                            </xsl:if>
                            
                            <xsl:if test="m:translation/m:long-titles/m:title[@xml:lang eq 'Sa-Ltn'][text()]">
                                <h2 class="text-sa">
                                    <xsl:apply-templates select="m:translation/m:long-titles/m:title[@xml:lang eq 'Sa-Ltn']"/>
                                </h2>
                            </xsl:if>
                            
                            <h3>
                                <xsl:apply-templates select="m:translation/m:source/m:toh"/>
                            </h3>
                            
                            <p>
                                <xsl:value-of select="concat(string-join(m:translation/m:source/m:series/text() | m:translation/m:source/m:scope/text() | m:translation/m:source/m:range/text(), ', '), '.')"/>
                            </p>
                        </div>
                        
                        <div epub:type="contributors" class="translator">
                            <xsl:for-each select="m:translation/m:publication/m:contributors/m:summary">
                                <p>
                                    <xsl:apply-templates select="node()"/>
                                </p>
                            </xsl:for-each>
                        </div>
                        
                    </section>
                    
                </div>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>