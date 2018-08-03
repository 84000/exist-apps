<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="epub-page.xsl"/>
    
    <xsl:param name="chapter-index"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="page-title" select="'Body'"/>
        <xsl:variable name="translation-title" select="m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
        <xsl:variable name="chapter" select="m:translation/m:body/m:chapter[@chapter-index eq $chapter-index]"/>
        
        <xsl:variable name="content">
            
            <section class="translation" epub:type="chapter">
                
                <xsl:attribute name="id" select="concat('chapter-', $chapter-index)"/>
                <xsl:variable name="chapter-index" select="$chapter-index"/>
                
                <xsl:if test="$chapter/m:title/text() or $chapter/m:title-number/text()">
                    <div class="center header">
                        <xsl:choose>
                            <xsl:when test="$chapter/m:title-number/text() and not($chapter/m:title/text())">
                                <xsl:if test="$chapter/m:title-number/text()">
                                    <h2 class="chapter-number">
                                        <xsl:apply-templates select="$chapter/m:title-number/text()"/>
                                    </h2>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="$chapter/m:title-number/text()">
                                    <h4 class="chapter-number">
                                        <xsl:apply-templates select="$chapter/m:title-number/text()"/>
                                    </h4>
                                </xsl:if>
                                
                                <xsl:if test="$chapter/m:title/text()">
                                    <h2>
                                        <xsl:apply-templates select="$chapter/m:title/text()"/>
                                    </h2>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </xsl:if>
                
                <div class="text">
                    <xsl:apply-templates select="$chapter/tei:*"/>
                </div>
                
            </section>
            
        </xsl:variable>
        
        <xsl:call-template name="epub-page">
            <xsl:with-param name="translation-title" select="$translation-title"/>
            <xsl:with-param name="page-title" select="$page-title"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>