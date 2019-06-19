<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="forms.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="reading-room-path" select="$reading-room-path"/>
                <xsl:with-param name="active-tab" select="@model-type"/>
                <xsl:with-param name="page-content">
                    <div class="well well-sm center-vertical full-width bottom-margin">
                        
                        <span class="small">
                            <xsl:value-of select="concat('Listing ', fn:format-number(xs:integer(count(m:contributor-teams/m:team)),'#,##0'), ' translator teams ')"/>
                        </span>
                        
                        <div>
                            <form method="post" action="/translator-teams.html" class="form-inline filter-form pull-right">
                                
                                <div class="checkbox hidden"><!-- Hide this for now -->
                                    <label class="small">
                                        <input type="checkbox" name="include-acknowledgements" value="1">
                                            <xsl:if test="m:request/@include-acknowledgements eq 'true'">
                                                <xsl:attribute name="checked" select="'checked'"/>
                                            </xsl:if>
                                        </input>
                                        <xsl:value-of select="'List all attributions'"/>
                                        
                                    </label>
                                </div>
                                
                                <a class="btn btn-primary btn-sml">
                                    <xsl:attribute name="href" select="'/edit-translator-team.html'"/>
                                    <xsl:value-of select="'Add a translator team'"/>
                                </a>
                                
                            </form>
                        </div>
                        
                    </div>
                    
                    <div class="row">
                        <div class="col-items div-list">
                            
                            <xsl:for-each select="m:contributor-teams/m:team">
                                <xsl:sort select="@start-letter"/>
                                
                                <xsl:variable name="team-id" select="@xml:id"/>
                                
                                <div class="item">
                                    
                                    <xsl:copy-of select="common:marker(@start-letter, if(preceding-sibling::m:team[1]/@start-letter) then preceding-sibling::m:team[1]/@start-letter else '')"/>
                                    
                                    <div class="row">
                                        <div class="col-sm-3">
                                            <a>
                                                <xsl:attribute name="href" select="concat('/edit-translator-team.html?id=', $team-id)"/>
                                                <xsl:value-of select="m:sort-name"/>
                                            </a>
                                            <xsl:if test="@rend eq 'hidden'">
                                                <span class="label label-default">
                                                    <xsl:value-of select="'Hidden'"/>
                                                </span>
                                            </xsl:if>
                                            <br/>
                                            <span class="small text-muted">
                                                <xsl:value-of select="$team-id"/>
                                            </span>
                                        </div>
                                        
                                        <div class="col-sm-4">
                                            <section>
                                                <div>
                                                    <xsl:attribute name="id" select="concat('team-contributors-', $team-id)"/>
                                                    <xsl:attribute name="class" select="'relative preview-list render-in-viewport'"/>
                                                    <xsl:for-each select="m:person">
                                                        <xsl:variable name="translator" select="."/>
                                                        <div>
                                                            <xsl:value-of select="$translator/m:label"/>
                                                            <xsl:value-of select="concat(' (', $translator/@xml:id, ')')"/>
                                                        </div>
                                                    </xsl:for-each>
                                                </div>
                                            </section>
                                        </div>
                                        
                                        <div class="col-sm-5">
                                            <section>
                                                <div>
                                                    <xsl:attribute name="id" select="concat('team-acknowledgements-', $team-id)"/>
                                                    <xsl:attribute name="class" select="'relative preview-list render-in-viewport'"/>
                                                    <xsl:if test="/m:response/m:request/@include-acknowledgements eq 'true'">
                                                        <xsl:call-template name="acknowledgements">
                                                            <xsl:with-param name="acknowledgements" select="m:acknowledgement"/>
                                                            <xsl:with-param name="group" select="''"/>
                                                            <xsl:with-param name="css-class" select="'col-sm-12'"/>
                                                            <xsl:with-param name="link-href" select="'/edit-text-header.html?id=@translation-id'"/>
                                                        </xsl:call-template>
                                                    </xsl:if>
                                                </div>
                                            </section>
                                        </div>
                                    </div>
                                    
                                </div>
                            </xsl:for-each>
                            
                        </div>
                        
                        <div id="affix-nav" class="col-nav">
                            <xsl:copy-of select="common:marker-nav(m:contributor-teams/m:team)"/>
                        </div>
                        
                    </div>
                </xsl:with-param>
            </xsl:call-template>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Translator Teams | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'Translator Teams configuration for 84000 operations team.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <!-- 
    <xsl:template match="tei:org">
        <span>
            <xsl:if test="ends-with(@ref, ancestor::m:team/@xml:id)">
                <xsl:attribute name="class" select="'mark'"/>
            </xsl:if>
            <xsl:value-of select="text()"/>
        </span>
    </xsl:template>
     -->
    
</xsl:stylesheet>