<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.daisy.org/z3986/2005/ncx/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:param name="epub-id"/>
    
    <xsl:template match="/m:response">
        
        <ncx version="2005-1" xml:lang="en">
            <head>
                <meta name="dtb:uid" content="{$epub-id}"/>
                <meta name="dtb:depth" content="1"/>
                <meta name="dtb:totalPageCount" content="0"/>
                <meta name="dtb:maxPageNumber" content="0"/>
            </head>
            <docTitle>
                <text>
                    <xsl:apply-templates select="m:translation/m:titles/m:title[@xml:lang eq 'en']"/>
                </text>
            </docTitle>
            <navMap>
                <navPoint id="title">
                    <navLabel>
                        <text>Title</text>
                    </navLabel>
                    <content src="half-title.xhtml"/>
                </navPoint>
                <navPoint id="imprint">
                    <navLabel>
                        <text>Imprint</text>
                    </navLabel>
                    <content src="imprint.xhtml"/>
                </navPoint>
                <navPoint id="contents">
                    <navLabel>
                        <text>Contents</text>
                    </navLabel>
                    <content src="contents.xhtml"/>
                </navPoint>
                <navPoint id="summary">
                    <navLabel>
                        <text>Summary</text>
                    </navLabel>
                    <content src="summary.xhtml"/>
                </navPoint>
                <navPoint id="acknowledgements">
                    <navLabel>
                        <text>Acknowledgements</text>
                    </navLabel>
                    <content src="acknowledgements.xhtml"/>
                </navPoint>
                <navPoint id="introduction">
                    <navLabel>
                        <text>Introduction</text>
                    </navLabel>
                    <content src="introduction.xhtml"/>
                </navPoint>
                <xsl:if test="m:translation/m:prologue//tei:p">
                    <navPoint id="prologue">
                        <navLabel>
                            <text>Prologue</text>
                        </navLabel>
                        <content src="prologue.xhtml"/>
                    </navPoint>
                </xsl:if>
                <navPoint id="body-title">
                    <navLabel>
                        <text>The Translation</text>
                    </navLabel>
                    <content src="body-title.xhtml"/>
                </navPoint>
                <xsl:for-each select="m:translation/m:body/m:chapter[m:title/text() | m:title-number/text()]">
                    <navPoint>
                        <xsl:attribute name="id" select="concat('chapter-', @chapter-index/string())"/>
                        <navLabel>
                            <text>
                                <xsl:choose>
                                    <xsl:when test="m:title/text()">
                                        <xsl:apply-templates select="@chapter-index"/>. <xsl:apply-templates select="m:title/text()"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates select="m:title-number/text()"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </text>
                        </navLabel>
                        <content>
                            <xsl:attribute name="src" select="concat('chapter-', @chapter-index, '.xhtml')"/>
                        </content>
                    </navPoint>
                </xsl:for-each>
                <xsl:if test="m:translation/m:colophon//tei:p">
                    <navPoint id="colophon">
                        <navLabel>
                            <text>Colophon</text>
                        </navLabel>
                        <content src="colophon.xhtml"/>
                    </navPoint>
                </xsl:if>
                <xsl:if test="m:translation/m:appendix//tei:p">
                    <navPoint id="appendix">
                        <navLabel>
                            <text>Appendix</text>
                        </navLabel>
                        <content src="appendix.xhtml"/>
                    </navPoint>
                </xsl:if>
                <xsl:if test="m:translation/m:abbreviations/m:item">
                    <navPoint id="abbreviations">
                        <navLabel>
                            <text>Abbreviations</text>
                        </navLabel>
                        <content src="abbreviations.xhtml"/>
                    </navPoint>
                </xsl:if>
                <navPoint id="notes">
                    <navLabel>
                        <text>Notes</text>
                    </navLabel>
                    <content src="notes.xhtml"/>
                </navPoint>
                <navPoint id="bibliography">
                    <navLabel>
                        <text>Bibliography</text>
                    </navLabel>
                    <content src="bibliography.xhtml"/>
                </navPoint>
                <navPoint id="glossary">
                    <navLabel>
                        <text>Glossary</text>
                    </navLabel>
                    <content src="glossary.xhtml"/>
                </navPoint>
            </navMap>
        </ncx>
    </xsl:template>
</xsl:stylesheet>