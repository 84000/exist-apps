<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="../../84000-reading-room/xslt/tei-to-xhtml.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            <div class="container">
                <div id="panel" class="panel panel-default">
                    <div class="panel-heading">
                        <h3 class="panel-title">
                            <xsl:value-of select="concat('Glossary items for: ', m:glossary/m:key)"/>
                        </h3>
                    </div>
                    <div class="panel-body">
                        <div id="glossary-items">
                            <xsl:for-each select="m:glossary/m:item">
                                <div class="glossary-item">
                                    <div class="title">
                                        <xsl:value-of select="'in '"/>
                                        <a>
                                            <xsl:attribute name="href" select="m:text/@uri"/>
                                            <xsl:attribute name="target" select="m:text/@id"/>
                                            <xsl:apply-templates select="m:text/m:title/text()"/>
                                        </a>
                                        <label class="label label-default pull-right">
                                            <xsl:choose>
                                                <xsl:when test="@type eq 'term'">Term</xsl:when>
                                                <xsl:when test="@type eq 'person'">Person</xsl:when>
                                                <xsl:when test="@type eq 'place'">Place</xsl:when>
                                                <xsl:when test="@type eq 'text'">Text</xsl:when>
                                            </xsl:choose>
                                        </label>
                                    </div>
                                    
                                    <div class="row">
                                        <xsl:if test="m:term">
                                            <div class="col-sm-6">
                                                <ul>
                                                    <xsl:for-each select="(m:term | m:alternative)">
                                                        <xsl:if test="normalize-space(text())">
                                                            <li>
                                                                <span>
                                                                    <xsl:attribute name="lang" select="@xml:lang"/>
                                                                    <xsl:if test="@xml:lang eq 'bo'">
                                                                        <xsl:attribute name="class" select="'text-bo'"/>
                                                                    </xsl:if>
                                                                    <xsl:choose>
                                                                        <xsl:when test="self::m:alternative">
                                                                            <span class="text-muted">
                                                                                <xsl:value-of select="'Also spelled: '"/>
                                                                                <xsl:apply-templates select="text()"/>
                                                                            </span>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <xsl:apply-templates select="text()"/>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </span>
                                                            </li>
                                                        </xsl:if>
                                                    </xsl:for-each>
                                                </ul>
                                            </div>
                                        </xsl:if>
                                        <xsl:if test="m:definition">
                                            <div class="col-sm-6">
                                                <xsl:for-each select="m:definition">
                                                    <p class="text-muted small">
                                                        <xsl:apply-templates select="node()"/>
                                                    </p>
                                                </xsl:for-each>
                                            </div>
                                        </xsl:if>    
                                    </div>
                                    
                                </div>
                            </xsl:for-each>
                        </div>
                    </div>
                </div>
            </div>
        </xsl:variable>
        
        <xsl:call-template name="widget-page">
            <xsl:with-param name="page-url" select="'http://translator-tools.84000.co/glossary-items.html'"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'84000 | Glossary Items'"/>
            <xsl:with-param name="page-description" select="'Items from the 84000 glossary'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
         
    </xsl:template>
    
</xsl:stylesheet>