<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="epub-page.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="page-title" select="'Glossary'"/>
        <xsl:variable name="translation-title" select="m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
        
        <xsl:variable name="content">
            <section epub:type="glossary">
                
                <div class="center header">
                    <h2>
                        <xsl:value-of select="$page-title"/>
                    </h2>
                </div>
                
                <xsl:for-each select="m:translation/m:glossary/m:item">
                    <xsl:sort select="common:standardized-sa(m:term[lower-case(@xml:lang) = 'en'][1])"/>
                    <div class="glossary-item">
                        <h4 class="term">
                            <xsl:apply-templates select="m:term[lower-case(@xml:lang) = 'en']"/>
                        </h4>
                        <xsl:if test="m:term[lower-case(@xml:lang) eq 'bo-ltn']">
                            <p class="text-wy">
                                <xsl:value-of select="string-join(m:term[lower-case(@xml:lang) eq 'bo-ltn'], ' · ')"/>
                            </p>
                        </xsl:if>
                        <xsl:if test="m:term[lower-case(@xml:lang) eq 'bo']">
                            <p class="text-bo">
                                <xsl:value-of select="string-join(m:term[lower-case(@xml:lang) eq 'bo'], ' · ')"/>
                            </p>
                        </xsl:if>
                        <xsl:if test="m:term[lower-case(@xml:lang) eq 'sa-ltn']">
                            <p class="text-sa">
                                <xsl:value-of select="string-join(m:term[lower-case(@xml:lang) eq 'sa-ltn'], ' · ')"/>
                            </p>
                        </xsl:if>
                        <xsl:for-each select="m:definition">
                            <p class="definition">
                                <xsl:apply-templates select="node()"/>
                            </p>
                        </xsl:for-each>
                    </div>
                </xsl:for-each>
                
            </section>
        </xsl:variable>
        
        <xsl:call-template name="epub-page">
            <xsl:with-param name="translation-title" select="$translation-title"/>
            <xsl:with-param name="page-title" select="$page-title"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>