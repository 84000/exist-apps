<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="epub-page.xsl"/>
    
    <!-- epub:types https://idpf.github.io/epub-vocabs/structure/ -->
    
    <xsl:template match="/m:response">
        
        <xsl:call-template name="epub-page">
            <xsl:with-param name="page-title" select="'Imprint'"/>
            <xsl:with-param name="content">
                
                <div>
                    
                    <xsl:attribute name="id" select="'imprint'"/>
                    
                    <section epub:type="imprint" class="new-page">
                        <div class="margin-bottom">
                            <p>
                                <xsl:value-of select="concat('First published ', format-date(m:translation/m:publication/m:publication-date, '[Y]'))"/>
                                <br/>
                                <xsl:value-of select="concat('Current version ', m:translation/m:publication/m:edition/text()[1], '(', m:translation/m:publication/m:edition/tei:date, ')')"/>
                                <br/>
                                <span class="small">
                                    <xsl:value-of select="concat('Generated by 84000 Reading Room v', @app-version)"/>
                                </span>
                            </p>
                        </div>
                        <div class="margin-bottom">
                            <img src="image/logo-stacked.png" alt="84000 Translating the Words of the Buddha Logo" class="logo logo-84000"/>
                            <p>
                                <xsl:apply-templates select="m:translation/m:publication/m:publication-statement"/>
                            </p>
                        </div>
                        <div>
                            <img src="image/CC_logo.png" alt="Creative Commons Logo" class="logo"/>
                            <xsl:for-each select="m:translation/m:publication/m:license/tei:p">
                                <p class="small">
                                    <xsl:apply-templates select="node()"/>
                                </p>
                            </xsl:for-each>
                        </div>
                    </section>
                    
                    <section class="new-page">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'print-version'"/>
                        </xsl:call-template>
                    </section>
                    
                    <xsl:if test="m:translation/m:publication/m:tantric-restriction/tei:p">
                        <section class="new-page">
                            <div id="tantric-warning" class="alert alert-danger">
                                <xsl:for-each select="m:translation/m:publication/m:tantric-restriction/tei:p">
                                    <p>
                                        <xsl:apply-templates select="node()"/>
                                    </p>
                                </xsl:for-each>
                            </div>
                        </section>
                    </xsl:if>
                    
                </div>
                
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>