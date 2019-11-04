<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="epub-page.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="section-id" select="'notes'"/>
        <xsl:variable name="section-title" select="'Notes'"/>
        <xsl:variable name="section-prefix" select="m:translation/m:notes/@prefix"/>
        <xsl:variable name="translation-title" select="m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
        
        <xsl:call-template name="epub-page">
            <xsl:with-param name="translation-title" select="$translation-title"/>
            <xsl:with-param name="page-title" select="$section-title"/>
            <xsl:with-param name="content">
                <aside>
                    
                    <xsl:attribute name="id" select="$section-id"/>
                    
                    <div class="center header">
                        <h3>
                            <xsl:value-of select="$section-title"/>
                        </h3>
                    </div>
                    
                    <xsl:for-each select="m:translation/m:notes/m:note">
                        <div class="footnote rw">
                            
                            <xsl:variable name="target-id" select="@uid"/>
                            <xsl:variable name="target" select="/m:response//*[@xml:id eq $target-id]"/>
                            <xsl:variable name="section" select="$target/ancestor::*[self::m:summary | self::m:acknowledgment | self::m:preface | self::m:introduction | self::m:prologue  | self::m:body  | self::m:colophon  | self::m:appendix  | self::m:abbreviations  | self::m:bibliography  | self::m:glossary]"/>
                            <xsl:variable name="section-name" select="local-name($section)"/>
                            
                            <xsl:variable name="OEBPS-entry">
                                <xsl:choose>
                                    <xsl:when test="$section-name eq 'body' and $target/ancestor::m:chapter/@chapter-index">
                                        <xsl:value-of select="concat('chapter-', $target/ancestor::m:chapter/@chapter-index,'.xhtml')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat($section-name, '.xhtml')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            
                            <div class="gtr">
                                <a class="footnote-number">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="concat($OEBPS-entry, '#link-to-', $target-id)"/>
                                    </xsl:attribute>
                                    <xsl:apply-templates select="@index"/>
                                </a>
                            </div>
                            
                            <div epub:type="footnote">
                                <xsl:attribute name="id" select="$target-id"/>
                                <xsl:apply-templates select="node()"/>
                            </div>
                            
                        </div>
                    </xsl:for-each>
                    
                </aside>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>