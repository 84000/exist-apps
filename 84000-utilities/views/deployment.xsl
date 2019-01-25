<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="tabs.xsl"/>
    
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
                            <a target="reading-room">
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
                            
                            <div class="row">
                                <div class="col-sm-offset-2 col-sm-8">
                                    
                                    <xsl:if test="m:apps/m:app">
                                        
                                        <xsl:variable name="role" select="m:apps/@role"/>
                                        
                                        <form action="/deployment.html" method="post" class="form-horizontal">
                                            
                                            <input type="hidden" name="tab" value="deployment"/>
                                            
                                            <xsl:choose>
                                                <xsl:when test="$role eq 'push'">
                                                    
                                                    <div class="alert alert-danger small text-center">
                                                        <p>
                                                            Commit new versions of the 84000 eXist apps to the 
                                                            <a target="_blank" class="alert-link">
                                                                <xsl:attribute name="href" select="//m:view-repo-url/text()"/>
                                                                GitHub repository</a>.
                                                        </p>
                                                    </div>
                                                    
                                                    <div class="form-group">
                                                        <label for="message" class="col-sm-3 control-label">
                                                            Commit message
                                                        </label>
                                                        <div class="col-sm-9">
                                                            <input type="text" name="message" id="message" value="" required="required" maxlength="100" class="form-control" placeholder="e.g. bug fix for ebooks"/>
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="form-group">
                                                        <label for="password" class="col-sm-3 control-label">
                                                            Admin password
                                                        </label>
                                                        <div class="col-sm-3">
                                                            <input type="password" name="password" id="password" value="" required="required" class="form-control" autocomplete="off"/>
                                                        </div>
                                                        <div class="col-sm-3">
                                                            <button type="submit" class="btn btn-danger">Commit</button>
                                                        </div>
                                                    </div>
                                                    
                                                </xsl:when>
                                                <xsl:when test="$role eq 'pull'">
                                                    
                                                    <div class="alert alert-success small text-center">
                                                        <p>
                                                            Get new versions of the 84000 eXist apps from the 
                                                            <a target="_blank" class="alert-link">
                                                                <xsl:attribute name="href" select="//m:view-repo-url/text()"/>
                                                                GitHub repository</a>.
                                                        </p>
                                                    </div>
                                                    
                                                    <div class="form-group">
                                                        <label for="app" class="col-sm-3 control-label">
                                                            84000 app 
                                                        </label>
                                                        <div class="col-sm-9">
                                                            <select name="app" id="app" class="form-control">
                                                                <option/>
                                                                <xsl:for-each select="m:apps/m:app">
                                                                    <option>
                                                                        <xsl:attribute name="value" select="@collection"/>
                                                                        <xsl:value-of select="normalize-space(@collection)"/>
                                                                    </option>
                                                                </xsl:for-each>
                                                            </select>
                                                            
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="form-group">
                                                        <label for="password" class="col-sm-3 control-label">
                                                            Admin password
                                                        </label>
                                                        <div class="col-sm-3">
                                                            <input type="password" name="password" id="password" value="" required="required" class="form-control" autocomplete="off"/>
                                                        </div>
                                                        <!-- 
                                                        <div class="col-sm-3">
                                                            <div class="checkbox">
                                                                <label>
                                                                    <input type="checkbox" name="get-fe" value="1"/>
                                                                    Get front-end
                                                                </label>
                                                            </div>
                                                        </div> -->
                                                        <div class="col-sm-3">
                                                            <button type="submit" class="btn btn-success">Pull updates</button>
                                                        </div>
                                                    </div>
                                                    
                                                </xsl:when>
                                            </xsl:choose>
                                            
                                        </form>
                                    </xsl:if>
                                    
                                    <xsl:if test="//m:execute">
                                        <div class="well well-sm">
                                            <code>
                                                <xsl:for-each select="//execution">
                                                    <xsl:if test="commandline/text()">
                                                        $ <xsl:value-of select="commandline/text()"/>
                                                    </xsl:if>
                                                    <br/>
                                                    <xsl:for-each select="stdout/line">
                                                        <xsl:if test="text()">
                                                            $ <xsl:value-of select="text()"/>
                                                        </xsl:if>
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