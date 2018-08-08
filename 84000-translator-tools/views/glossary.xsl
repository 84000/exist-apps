<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:template name="glossary">
        
        <div id="cumulative-glossary">
            <div class="row">
                <div class="col-sm-8">
                    <ul class="nav nav-pills">
                        <li role="presentation">
                            <xsl:if test="m:glossary/@type eq 'term'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a href="?tab=glossary&amp;type=term">
                                Terms
                            </a>
                        </li>
                        <li role="presentation">
                            <xsl:if test="m:glossary/@type eq 'person'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a href="?tab=glossary&amp;type=person">
                                Persons
                            </a>
                        </li>
                        <li role="presentation">
                            <xsl:if test="m:glossary/@type eq 'place'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a href="?tab=glossary&amp;type=place">
                                Places
                            </a>
                        </li>
                        <li role="presentation">
                            <xsl:if test="m:glossary/@type eq 'text'">
                                <xsl:attribute name="class" select="'active'"/>
                            </xsl:if>
                            <a href="?tab=glossary&amp;type=text">
                                Texts
                            </a>
                        </li>
                    </ul>
                </div>
                <div class="col-sm-4">
                    <a href="cumulative-glossary.zip" class="download-link center-vertical">
                        <span>
                            <i class="fa fa-cloud-download"/>
                        </span>
                        <span>Download All (.xml)</span>
                    </a>
                </div>
            </div>
            <div class="row">
                
                <div class="col-items">
                    
                    <xsl:for-each select="m:glossary/m:term">
                        <div class="glossary-term">
                            
                            <xsl:variable name="start-letter" select="@start-letter"/>
                            
                            <xsl:if test="not(preceding-sibling::*[@start-letter = $start-letter])">
                                <a class="milestone">
                                    <xsl:attribute name="name" select="$start-letter"/>
                                    <xsl:attribute name="id" select="concat('group-', $start-letter)"/>
                                    <xsl:value-of select="$start-letter"/>
                                </a>
                            </xsl:if>
                            
                            <div class="row">
                                <div class="col-sm-6">
                                    <p>
                                        <xsl:value-of select="normalize-space(m:main-term/text())"/>
                                    </p>
                                </div>
                                <div class="col-sm-6 text-right">
                                    <a target="_self">
                                        <xsl:attribute name="href" select="concat('glossary-items.html?term=', fn:encode-for-uri(m:main-term/text()))"/>
                                        <xsl:attribute name="data-ajax-target" select="concat('#occurrences-', position())"/>
                                        <xsl:choose>
                                            <xsl:when test="@count-items &gt; 1">
                                                <xsl:value-of select="@count-items"/> matches
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="@count-items"/> match
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        
                                    </a>
                                </div>
                            </div>
                            
                            <div class="collpase">
                                <xsl:attribute name="id" select="concat('occurrences-', position())"/>
                            </div>
                            
                        </div>                                    
                    </xsl:for-each>
                </div>
                
                <div id="letters-nav" class="col-nav">
                    <div data-spy="affix">
                        <div class="btn-group-vertical btn-group-xs" role="group" aria-label="navigation">
                            <xsl:for-each select="m:glossary/m:term">
                                <xsl:variable name="start-letter" select="@start-letter"/>
                                <xsl:if test="not(preceding-sibling::*[@start-letter = $start-letter])">
                                    
                                    <a class="btn btn-default scroll-to-anchor">
                                        <xsl:attribute name="href" select="concat('#group-', $start-letter)"/>
                                        <xsl:value-of select="$start-letter"/>
                                    </a>
                                    
                                </xsl:if>
                            </xsl:for-each>
                        </div>
                    </div>
                </div>
                
            </div>
            
        </div>
    </xsl:template>
    
</xsl:stylesheet>