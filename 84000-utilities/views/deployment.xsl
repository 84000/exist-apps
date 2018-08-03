<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:include href="../../84000-reading-room/views/html/reading-room-page.xsl"/>
    <xsl:include href="tabs.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        
        <xsl:variable name="content">
            
            <div class="container">
                <div class="panel panel-default">
                    <div class="panel-heading panel-heading-bold hidden-print center-vertical">
                        
                        <span class="title">
                            84000 Utilities
                        </span>
                        
                        <span class="text-right">
                            <a target="_self">
                                <xsl:attribute name="href" select="$reading-room-path"/>
                                Reading Room
                            </a>
                        </span>
                        
                    </div>
                    
                    <div class="panel-body">
                        
                        <xsl:call-template name="tabs">
                            <xsl:with-param name="active-tab" select="@model-type"/>
                        </xsl:call-template>
                        
                        <div class="tab-content">
                            
                            <p class="text-muted text-center small">
                                This function commits a new version of the Reading Room app to the 
                                <a target="_blank">
                                    <xsl:attribute name="href" select="//m:view-repo-url/text()"/>
                                    GitHub repository</a>.
                            </p>
                            <form action="/deployment.html" method="post" class="form-horizontal">
                                
                                <input type="hidden" name="tab" value="deployment"/>
                                <input type="hidden" name="action" value="sync"/>
                                
                                <div class="form-group">
                                    <label for="message" class="col-sm-2 control-label">
                                        Commit message
                                    </label>
                                    <div class="col-sm-10">
                                        <input type="text" name="message" id="message" value="" required="required" maxlength="100" class="form-control" placeholder="e.g. bug fix for ebooks"/>
                                    </div>
                                </div>
                                
                                <div class="form-group">
                                    <div class="col-sm-10 col-sm-offset-2">
                                        <button type="submit" class="btn btn-warning">Commit this version</button>
                                    </div>
                                </div>
                                
                            </form>
                            
                            <xsl:if test="//m:execute">
                                <div class="well well-sm">
                                    <code>
                                        <xsl:for-each select="//m:execute">
                                            $ <xsl:value-of select="execution/commandline/text()"/>
                                            <br/>
                                            <xsl:for-each select="execution/stdout/line">
                                                $ <xsl:value-of select="text()"/>
                                                <br/>
                                            </xsl:for-each>
                                            <xsl:if test="not(position() = last())">
                                                <hr/>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </code>
                                </div>
                            </xsl:if>
                        </div>
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Code Deployment :: 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Code deployment utility'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>