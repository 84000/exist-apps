<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="epub-page.xsl"/>
    
    <!-- epub:types https://idpf.github.io/epub-vocabs/structure/ -->
    
    <xsl:param name="part-id" required="yes"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="part" select="m:translation//m:part[@id eq $part-id]"/>
        
        <xsl:call-template name="epub-page">
            <xsl:with-param name="page-title" select="($part/tei:head[@type eq $part/@type][not(@key) or @key eq $toh-key][data()], $part/parent::m:part[@type eq 'translation']/tei:head[@type eq 'translation'][not(@key) or @key eq $toh-key])[1]"/>
            <xsl:with-param name="content">
                
                <section epub:type="chapter" class="new-page text">
                    
                    <xsl:if test="not($part/tei:head[@type eq $part/@type][not(@key) or @key eq $toh-key][data()])">
                        <xsl:apply-templates select="$part/parent::m:part[@type eq 'translation']/tei:head[@type eq 'translation'][not(@key) or @key eq $toh-key][data()]"/>
                    </xsl:if>
                    
                    <xsl:apply-templates select="$part"/>
                
                </section>
                
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>