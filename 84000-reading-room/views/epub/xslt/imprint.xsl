<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="../../../xslt/lang.xsl"/>
    <xsl:import href="epub-page.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="page-title" select="'Imprint'"/>
        <xsl:variable name="translation-title" select="m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
        
        <xsl:variable name="content">
            <section class="imprint center">
                <div>
                    <p>
                        <xsl:value-of select="concat('First published ', format-date(m:translation/m:translation/m:publication-date, '[Y]'))"/>
                        <br/>
                        <xsl:value-of select="concat('Current version ', m:translation/m:translation/m:edition/text(), '(', m:translation/m:translation/m:edition/tei:date, ')')"/>
                        <br/>
                        <span class="small">
                            <xsl:value-of select="concat('Generated by 84000 Reading Room v',@app-version)"/>
                        </span>
                    </p>
                </div>
                <div>
                    <img src="image/logo-stacked.png" alt="84000 Translating the Words of the Buddha Logo" class="logo logo-84000"/>
                    <p>
                        <xsl:apply-templates select="m:translation/m:translation/m:publication-statement"/>
                    </p>
                </div>
                <div>
                    <img src="image/CC_logo.png" alt="Creative Commons Logo" class="logo"/>
                    <xsl:for-each select="m:translation/m:translation/m:license/tei:p">
                        <p class="small">
                            <xsl:apply-templates select="node()"/>
                        </p>
                    </xsl:for-each>
                </div>
            </section>
            
            <section class="imprint center">
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'print-version'"/>
                </xsl:call-template>
            </section>
            
            <xsl:if test="m:translation/m:translation/m:tantric-restriction/tei:p">
                <section class="imprint center">
                    <div id="tantric-warning" class="alert alert-danger">
                        <xsl:for-each select="m:translation/m:translation/m:tantric-restriction/tei:p">
                            <p>
                                <xsl:apply-templates select="node()"/>
                            </p>
                        </xsl:for-each>
                    </div>
                </section>
            </xsl:if>
            
        </xsl:variable>
        
        <xsl:call-template name="epub-page">
            <xsl:with-param name="translation-title" select="$translation-title"/>
            <xsl:with-param name="page-title" select="$page-title"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>