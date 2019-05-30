<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:import href="../../xslt/functions.xsl"/>
    <xsl:import href="website-page.xsl"/>
    
    <xsl:output method="html" indent="no" doctype-system="about:legacy-compat"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
    <xsl:variable name="front-end-path" select="$environment/m:url[@id eq 'front-end']/text()"/>
    <xsl:variable name="translation-id" select="m:translation-glossary/@id"/>
    
    <xsl:template match="/m:response">
        
        <!-- PAGE CONTENT -->
        <xsl:variable name="content">
            
            <article class="container">
                
                <div class="panel panel-default">
                    
                    <xsl:if test="m:translation-glossary/@status != 'available'">
                        <div class="panel-heading bold danger">
                            <xsl:value-of select="'This text is not yet ready for publication!'"/>
                            
                        </div>
                    </xsl:if>
                    
                    <div class="panel-body">
                        <div class="row">
                            <div class="col-sm-offset-1 col-sm-10 print-width-override">
                                
                                <section id="title" class="indent">
                                    <div class="page page-first">
                                        <div id="titles" class="section-panel">
                                            <h3>
                                                <xsl:value-of select="'Glossary'"/>
                                            </h3>
                                            <h1>
                                                <xsl:value-of select="m:translation-glossary/m:title"/>
                                            </h1>
                                        </div>
                                    </div>
                                </section>
                                
                                <section id="glossary" class="page indent">
                                    
                                    <div>
                                        <xsl:for-each select="m:translation-glossary/m:glossary/m:item">
                                            <xsl:sort select="common:standardized-sa(m:term[lower-case(@xml:lang) = 'en'][1])"/>
                                            <div class="glossary-item">
                                                <xsl:attribute name="id" select="@uid/string()"/>
                                                <xsl:attribute name="data-match" select="if(@mode/string() eq 'marked') then 'marked' else 'match'"/>
                                                <a class="milestone" title="Bookmark this section">
                                                    <xsl:attribute name="href" select="concat('#', @uid/string())"/>
                                                    <xsl:value-of select="concat('g.', position())"/>
                                                </a>
                                                <div class="row">
                                                    
                                                    <div class="col-sm-6 col-md-8">
                                                        
                                                        <h4 class="term">
                                                            <xsl:value-of select="m:term[lower-case(@xml:lang) = 'en']"/>
                                                        </h4>
                                                        
                                                        <xsl:for-each select="m:term[lower-case(@xml:lang) != 'en']">
                                                            <p>
                                                                <xsl:attribute name="class" select="common:lang-class(@xml:lang)"/>
                                                                <xsl:value-of select="text()"/>
                                                            </p>
                                                        </xsl:for-each>
                                                        
                                                        <xsl:for-each select="m:alternatives/m:alternative">
                                                            <p class="term alternative">
                                                                <xsl:value-of select="text()"/>
                                                            </p>
                                                        </xsl:for-each>
                                                        
                                                        <xsl:for-each select="m:definitions/m:definition">
                                                            <p>
                                                                <xsl:apply-templates select="node()"/>
                                                            </p>
                                                        </xsl:for-each>
                                                        
                                                    </div>
                                                    
                                                    <div class="col-sm-6 col-md-4">
                                                        <xsl:variable name="count-passages" select="count(m:passages/m:passage)"/>
                                                        <h5>
                                                            <xsl:choose>
                                                                <xsl:when test="$count-passages eq 1">
                                                                    <xsl:value-of select="'1 passage contains this term'"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:value-of select="concat($count-passages, ' passages contain this term')"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </h5>
                                                        <ul class="list-inline">
                                                            <xsl:for-each select="m:passages/m:passage">
                                                                <li>
                                                                    <a>
                                                                        <xsl:attribute name="href" select="concat('/translation/', $translation-id, '.html', '#node-', @tid)"/>
                                                                        <xsl:value-of select="position()"/>
                                                                    </a>
                                                                </li>
                                                            </xsl:for-each>
                                                        </ul>
                                                    </div>
                                                    
                                                </div>
                                            </div>
                                        </xsl:for-each>
                                    </div>
                                </section>
    
                            </div>
                        </div>
                    </div>
                </div>
            </article>
            
        </xsl:variable>
        
        <!-- Pass the content to the page -->
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="concat('translation ', if(m:request/@view-mode eq 'editor') then 'editor-mode' else '')"/>
            <xsl:with-param name="page-title" select="concat('84000 | Glossary: ', m:translation-glossary/m:title)"/>
            <xsl:with-param name="page-description" select="''"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template match="tei:title">
        <span>
            <xsl:attribute name="class">
                <xsl:value-of select="normalize-space(common:lang-class(@xml:lang))"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:foreign">
        <span>
            <xsl:attribute name="class">
                <xsl:value-of select="normalize-space(common:lang-class(@xml:lang))"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:emph">
        <em>
            <xsl:attribute name="class">
                <xsl:value-of select="normalize-space(common:lang-class(@xml:lang))"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </em>
    </xsl:template>
    
    <xsl:template match="tei:ptr">
        <a class="internal-ref" target="_blank">
            <xsl:attribute name="href" select="@target"/>
            <xsl:choose>
                <xsl:when test="text()">
                    <xsl:value-of select="text()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@target"/>
                </xsl:otherwise>
            </xsl:choose>
        </a>
    </xsl:template>
    
</xsl:stylesheet>