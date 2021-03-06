<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="epub-page.xsl"/>
    
    <!-- epub:types https://idpf.github.io/epub-vocabs/structure/ -->
    
    <xsl:template match="/m:response">
        
        <xsl:call-template name="epub-page">
            <xsl:with-param name="page-title" select="'The Translation'"/>
            <xsl:with-param name="content">
                <section epub:type="halftitle" id="body-title" class="new-page heading-section">
                    
                    <xsl:if test="m:translation/m:part[@type eq 'translation']/m:honoration[text()]">
                        <h2>
                            <xsl:apply-templates select="m:translation/m:part[@type eq 'translation']/m:honoration"/>
                        </h2>
                    </xsl:if>
                    
                    <xsl:if test="m:translation/m:part[@type eq 'translation']/m:main-title[text()]">
                        <h1>
                            <xsl:apply-templates select="m:translation/m:part[@type eq 'translation']/m:main-title"/>
                            <xsl:if test="m:translation/m:part[@type eq 'translation']/m:sub-title[text()]">
                                <br/>
                                <small>
                                    <xsl:apply-templates select="m:translation/m:part[@type eq 'translation']/m:sub-title"/>
                                </small>
                            </xsl:if>
                        </h1>
                    </xsl:if>
                    
                </section>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>