<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="3.0">

    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="epub-page.xsl"/>

    <!-- epub:types https://idpf.github.io/epub-vocabs/structure/ -->

    <xsl:template match="/m:response">

        <xsl:call-template name="epub-page">
            <xsl:with-param name="page-title" select="'Table of Contents'"/>
            <xsl:with-param name="content">

                <section class="new-page">

                    <xsl:attribute name="id" select="'toc'"/>

                    <div class="rw rw-section-head">
                        <div class="gtr">co.</div>
                        <div class="rw-heading heading-section chapter">
                            <div>
                                <h2>
                                    <xsl:value-of select="'Table of Contents'"/>
                                </h2>
                            </div>
                        </div>
                    </div>
                    
                    <nav epub:type="toc">
                        <ol>
                            
                            <li>
                                <a href="titles.xhtml">
                                    <xsl:value-of select="'Title'"/>
                                </a>
                            </li>
                            
                            <li>
                                <a href="imprint.xhtml">
                                    <xsl:value-of select="'Imprint'"/>
                                </a>
                            </li>
                            
                            <xsl:call-template name="toc-parts">
                                <xsl:with-param name="parts" select="m:translation/m:part"/>
                                <xsl:with-param name="doc-type" select="'epub'"/>
                            </xsl:call-template>

                        </ol>
                    </nav>

                </section>

            </xsl:with-param>
        </xsl:call-template>

    </xsl:template>

</xsl:stylesheet>