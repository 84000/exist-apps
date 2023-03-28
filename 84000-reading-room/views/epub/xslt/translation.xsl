<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="epub-page.xsl"/>
    
    <!-- epub:types https://idpf.github.io/epub-vocabs/structure/ -->
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="toh-key" select="m:translation/m:source/@key" as="xs:string?"/>
        <xsl:variable name="translation-head" select="m:translation/m:part[@type eq 'translation']/tei:head[@type eq 'translation'][not(@key) or @key eq $toh-key][normalize-space(text())]" as="element(tei:head)?"/>
        <xsl:variable name="honoration" select="m:translation/m:part[@type eq 'translation']/tei:head[@type eq 'titleHon'][not(@key) or @key eq $toh-key][normalize-space(text())]" as="element(tei:head)?"/>
        <xsl:variable name="main-title" select="m:translation/m:part[@type eq 'translation']/tei:head[@type eq 'titleMain'][not(@key) or @key eq $toh-key][normalize-space(text())]" as="element(tei:head)?"/>
        <xsl:variable name="sub-title" select="m:translation/m:part[@type eq 'translation']/tei:head[@type eq 'sub'][not(@key) or @key eq $toh-key][normalize-space(text())]" as="element(tei:head)?"/>
        <xsl:variable name="first-part-head" select="m:translation/m:part[@type eq 'translation']/m:part[1]/tei:head[@type eq parent::m:part/@type][normalize-space(text())][1]" as="element(tei:head)?"/>
        
        <xsl:call-template name="epub-page">
            <xsl:with-param name="page-title" select="'The Translation'"/>
            <xsl:with-param name="content">
                <section epub:type="halftitle" id="body-title" class="new-page heading-section">
                    
                    
                    <!-- If the first parent head is the same as the main title we want to use the translation part head in the first chapter, so not here -->
                    <xsl:if test="$translation-head and data($first-part-head) and not(data($first-part-head) eq data($main-title))">
                        <div class="h3">
                            <xsl:value-of select="$translation-head[1]/node()"/>
                        </div>
                    </xsl:if>
                    
                    <xsl:if test="$honoration">
                        <div class="h2">
                            <xsl:apply-templates select="$honoration[1]/node()"/>
                        </div>
                    </xsl:if>
                    
                    <xsl:if test="$main-title">
                        <div class="h1">
                            <xsl:apply-templates select="$main-title[1]/node()"/>
                            <xsl:if test="$sub-title">
                                <br/>
                                <small>
                                    <xsl:apply-templates select="$sub-title[1]"/>
                                </small>
                            </xsl:if>
                        </div>
                    </xsl:if>
                    
                </section>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>