<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="about.xsl"/>
    
    <xsl:template match="/m:response">
        <xsl:variable name="content">
            
            <h3>
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'matching-funds-title'"/>
                </xsl:call-template>
            </h3>
            
            <xsl:call-template name="local-text">
                <xsl:with-param name="local-key" select="'matching-funds-description'"/>
            </xsl:call-template>
            
            <hr class="no-margin"/>
            
            <div id="matching-funds" class="list-group accordion" role="tablist" aria-multiselectable="false">
                
                <xsl:call-template name="expand-item">
                    <xsl:with-param name="id" select="'matching-funds-sponsors'"/>
                    <xsl:with-param name="title">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'matching-funds-list-title'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="content">
                        <ul>
                            <xsl:for-each select="m:sponsors/m:sponsor[m:type[@id eq 'matching-funds']]">
                                <li>
                                    <xsl:value-of select="m:label"/>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:with-param>
                </xsl:call-template>
            </div>
            
            <h3>
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'sutras-title'"/>
                    
                </xsl:call-template>
            </h3>
            
            <xsl:call-template name="local-text">
                <xsl:with-param name="local-key" select="'sutras-description'"/>
            </xsl:call-template>
            
            <hr class="no-margin"/>
            
            <div id="sutra" class="list-group accordion" role="tablist" aria-multiselectable="false">
                <xsl:call-template name="expand-item">
                    <xsl:with-param name="id" select="'sutra-sponsors'"/>
                    <xsl:with-param name="title">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'sutras-list-title'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="content">
                        <xsl:call-template name="text-list">
                            <xsl:with-param name="texts" select="m:sponsored-texts/m:text"/>
                            <xsl:with-param name="grouping" select="'text'"/>
                            <xsl:with-param name="show-sponsors" select="true()"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </div>
            
            <h3>
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'founding-title'"/>
                </xsl:call-template>
            </h3>
            
            <xsl:call-template name="local-text">
                <xsl:with-param name="local-key" select="'founding-description'"/>
            </xsl:call-template>
            
            <hr class="no-margin"/>
            
            <div id="founding" class="list-group accordion" role="tablist" aria-multiselectable="false">
                <xsl:call-template name="expand-item">
                    <xsl:with-param name="id" select="'founding-sponsors'"/>
                    <xsl:with-param name="title">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'founding-list-title'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="content">
                        <table class="table no-border">
                            <xsl:for-each select="m:sponsors/m:sponsor[m:type[@id eq 'founding']]">
                                <tr>
                                    <td class="nowrap">
                                        <xsl:value-of select="concat(position(), '.')"/>
                                    </td>
                                    <td>
                                        <xsl:value-of select="m:label"/>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </xsl:with-param>
                </xsl:call-template>
                
            </div>
            
            <!-- 
            <ul class="nav nav-tabs" role="tablist" id="sponsors-tabs">
                <li role="presentation">
                    <xsl:if test="m:request/@tab eq 'matching-funds-tab'">
                        <xsl:attribute name="class" select="'active'"/>
                    </xsl:if>
                    <a role="tab" data-toggle="tab" href="#matching-funds-tab" aria-controls="matching-funds-tab">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'matching-funds-tab-label'"/>
                        </xsl:call-template>
                    </a>
                </li>
                <li role="presentation">
                    <xsl:if test="m:request/@tab eq 'sutras-tab'">
                        <xsl:attribute name="class" select="'active'"/>
                    </xsl:if>
                    <a role="tab" data-toggle="tab" href="#sutras-tab" aria-controls="sutras-tab">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'sutras-tab-label'"/>
                        </xsl:call-template>
                    </a>
                </li>
                <li role="presentation">
                    <xsl:if test="m:request/@tab eq 'founding-tab'">
                        <xsl:attribute name="class" select="'active'"/>
                    </xsl:if>
                    <a role="tab" data-toggle="tab" href="#founding-tab" aria-controls="founding-tab">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'founding-tab-label'"/>
                        </xsl:call-template>
                    </a>
                </li>
            </ul>
             -->
            
            <!-- 
            <div class="tab-content">
                
                <div role="tabpanel" id="sutras-tab">
                    <xsl:attribute name="class" select="if(m:request/@tab eq 'sutras-tab') then 'tab-pane fade in active' else 'tab-pane fade'"/>
                    
                    <div class="text-list">
                        <div class="row table-headers">
                            <div class="col-sm-2 hidden-xs">
                                <xsl:call-template name="local-text">
                                    <xsl:with-param name="local-key" select="'column-toh-label'"/>
                                </xsl:call-template>
                            </div>
                            <div class="col-xs-8 col-sm-10">
                                <xsl:call-template name="local-text">
                                    <xsl:with-param name="local-key" select="'column-title-label'"/>
                                </xsl:call-template>
                            </div>
                            <div class="col-xs-4 visible-xs text-right">
                                <xsl:call-template name="local-text">
                                    <xsl:with-param name="local-key" select="'column-status-label'"/>
                                </xsl:call-template>
                            </div>
                        </div>
                        <div class="list-section">
                            <xsl:for-each select="m:sponsored-texts/m:text">
                                <xsl:sort select="number(m:toh/@number)"/>
                                <xsl:sort select="m:toh/@letter"/>
                                <xsl:sort select="number(m:toh/@chapter-number)"/>
                                <xsl:sort select="m:toh/@chapter-letter"/>
                                <div class="row list-item">
                                    
                                    <div class="col-sm-2">
                                        
                                        <xsl:value-of select="m:toh/m:full"/>
                                        
                                        <div class="col-xs-top-right">
                                            <xsl:call-template name="status-label">
                                                <xsl:with-param name="status-group" select="@status-group"/>
                                            </xsl:call-template>
                                        </div>
                                        
                                        <hr class="visible-xs sml-margin"/>
                                        
                                    </div>
                                    
                                    <div class="col-sm-10">
                                        
                                        <xsl:call-template name="text-list-title">
                                            <xsl:with-param name="text" select="."/>
                                        </xsl:call-template>
                                        
                                        <xsl:call-template name="text-list-subtitles">
                                            <xsl:with-param name="text" select="."/>
                                        </xsl:call-template>
                                        
                                        <xsl:if test="m:sponsors/tei:div[@type eq 'acknowledgment']/tei:p">
                                            <hr/>
                                            <div>
                                                <xsl:for-each select="m:sponsors/tei:div[@type eq 'acknowledgment']/tei:p">
                                                    <p>
                                                        <xsl:value-of select="data(.)"/>
                                                    </p>
                                                </xsl:for-each>
                                                <xsl:if test="m:sponsorship-status/m:status[@id eq 'part']">
                                                    <p class="text-muted">
                                                        <a class="italic text-danger">
                                                            <xsl:attribute name="href" select="common:internal-link('http://read.84000.co/about/sponsor-a-sutra.html', (), '', /m:response/@lang)"/>
                                                            <xsl:call-template name="local-text">
                                                                <xsl:with-param name="local-key" select="'text-sponsorship-link-label'"/>
                                                            </xsl:call-template>
                                                        </a>
                                                    </p>
                                                </xsl:if>
                                            </div>
                                            
                                        </xsl:if>
                                        
                                        <xsl:call-template name="expandable-summary">
                                            <xsl:with-param name="text" select="."/>
                                        </xsl:call-template>
                                        
                                    </div>
                                </div>
                                
                            </xsl:for-each>
                        </div>
                    </div>
                   
                </div>
                
            </div> -->
            
        </xsl:variable>
        
        <xsl:call-template name="about">
            <xsl:with-param name="sub-content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>