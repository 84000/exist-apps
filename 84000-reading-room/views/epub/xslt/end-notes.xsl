<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="epub-page.xsl"/>
    
    <!-- epub:types https://idpf.github.io/epub-vocabs/structure/ -->
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="section" select="m:translation/m:section[@section-id eq 'end-notes']"/>
        
        <xsl:call-template name="epub-page">
            <xsl:with-param name="page-title" select="$section/tei:head[@type eq $section/@type]"/>
            <xsl:with-param name="content">
                <aside epub:type="endnotes">
                    
                    <xsl:attribute name="id" select="$section/@section-id"/>
                    
                    <xsl:apply-templates select="$section/tei:head[@type eq $section/@type]"/>
                    
                    <xsl:for-each select="$section/m:note">
                        <div class="footnote rw">
                            
                            <xsl:variable name="target-id" select="@uid"/>
                            <xsl:variable name="target" select="/m:response//tei:note[@xml:id eq $target-id]"/>
                            <xsl:variable name="target-section" select="$target/ancestor::m:section[@nesting eq '0'][@section-id][1]"/>
                            <xsl:variable name="OEBPS-entry" select="concat(($target-section/@section-id, '')[1], '.xhtml')"/>
                            
                            <xsl:attribute name="id" select="$target-id"/>
                            
                            <div class="gtr">
                                <a class="footnote-number">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="concat($OEBPS-entry, '#link-to-', $target-id)"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="concat($section/@prefix, '.', @index)"/>
                                </a>
                            </div>
                            
                            <div epub:type="footnote">
                                <xsl:apply-templates select="node()"/>
                            </div>
                            
                        </div>
                    </xsl:for-each>
                    
                </aside>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>