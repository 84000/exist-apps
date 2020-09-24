<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="epub-page.xsl"/>
    
    <!-- epub:types https://idpf.github.io/epub-vocabs/structure/ -->
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="section" select="m:translation/m:toc/m:section[@section-id eq 'contents']"/>
        
        <xsl:call-template name="epub-page">
            <xsl:with-param name="page-title" select="$section/tei:head[@type eq $section/@type]"/>
            <xsl:with-param name="content">
                
                <aside>
                    
                    <xsl:attribute name="id" select="$section/@section-id"/>
                    
                    <xsl:apply-templates select="$section/tei:head[@type eq $section/@type]"/>
                    
                    <nav epub:type="toc">
                        <ol>
                            
                            <xsl:call-template name="toc-sections">
                                <xsl:with-param name="sections" select="m:translation/m:toc/m:section"/>
                                <xsl:with-param name="doc-type" select="'epub'"/>
                            </xsl:call-template>
                            
                        </ol>
                    </nav>
                    
                </aside>
                
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>