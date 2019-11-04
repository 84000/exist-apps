<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="epub-page.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="section-id" select="'appendix'"/>
        <xsl:variable name="section-title" select="'Appendix'"/>
        <xsl:variable name="section-prefix" select="m:translation/m:appendix/@prefix"/>
        <xsl:variable name="translation-title" select="m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
        
        <xsl:call-template name="epub-page">
            <xsl:with-param name="translation-title" select="$translation-title"/>
            <xsl:with-param name="page-title" select="$section-title"/>
            <xsl:with-param name="content">
                <section class="translation" epub:type="appendix">
                    
                    <xsl:attribute name="id" select="$section-id"/>
                    
                    <xsl:choose>
                        <xsl:when test="count(m:translation/m:appendix/m:chapter) gt 1">
                            
                            <div class="center header">
                                <h3>
                                    <xsl:value-of select="$section-title"/>
                                </h3>
                            </div>
                            
                            <xsl:for-each select="m:translation/m:appendix/m:chapter">
                                <div class="new-page">
                                    
                                    <div class="center header">
                                        <xsl:call-template name="chapter-title">
                                            <xsl:with-param name="title" select="m:title"/>
                                            <xsl:with-param name="title-number" select="m:title-number"/>
                                            <xsl:with-param name="chapter-index" select="@chapter-index/string()"/>
                                            <xsl:with-param name="prefix" select="@prefix/string()"/>
                                        </xsl:call-template>
                                    </div>
                                    
                                    <div class="text">
                                        <xsl:apply-templates select="tei:*"/>
                                    </div>
                                    
                                </div>
                            </xsl:for-each>
                            
                        </xsl:when>
                        <xsl:otherwise>
                            
                            <div class="center header">
                                <xsl:call-template name="section-title">
                                    <xsl:with-param name="id" select="$section-id"/>
                                    <xsl:with-param name="prefix" select="$section-prefix"/>
                                    <xsl:with-param name="title" select="$section-title"/>
                                </xsl:call-template>
                            </div>
                            
                            <div class="text">
                                <xsl:apply-templates select="tei:*"/>
                            </div>
                            
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </section>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>