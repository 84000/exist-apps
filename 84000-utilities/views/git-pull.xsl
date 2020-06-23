<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
        <xsl:variable name="request-repo" select="m:request/m:parameter[@name eq 'repo']" as="xs:string?"/>
        
        <xsl:variable name="content">
            
            <div class="container">
                <div class="row">
                    <div class="col-sm-offset-2 col-sm-8">
                        
                        <div class="alert alert-danger small text-center">
                            <h1 class="no-top-margin">
                                <xsl:value-of select="concat($environment/m:label, '$ git pull')"/>
                            </h1>
                            <p>
                                <xsl:value-of select="'This function pulls the lastest files from the relevant GitHub repositories and loads it into the database where appropriate.'"/>
                            </p>
                            <ul class="list-inline inline-dots">
                                <xsl:for-each-group select="$environment/m:git-config/m:pull/m:repo" group-by="@url">
                                    <li>
                                        <a target="_blank" class="alert-link nowrap">
                                            <xsl:attribute name="href" select="concat(@url, '/commits/master')"/>
                                            <xsl:value-of select="@url"/>
                                        </a>
                                    </li>
                                </xsl:for-each-group>
                            </ul>
                        </div>
                        
                        <form action="/git-pull.html" method="post" class="form-horizontal">
                            
                            <div class="form-group">
                                <label for="repo" class="col-sm-3 control-label">
                                    <xsl:value-of select="'Repository'"/>
                                </label>
                                <div class="col-sm-9">
                                    <select name="repo" id="repo" class="form-control">
                                        <xsl:for-each select="$environment/m:git-config/m:pull/m:repo">
                                            <option>
                                                <xsl:attribute name="value" select="@id"/>
                                                <xsl:if test="compare(@id, $request-repo) eq 0">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="m:label"/>
                                            </option>
                                        </xsl:for-each>
                                    </select>
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <label for="password" class="col-sm-3 control-label">
                                    <xsl:value-of select="'Admin password'"/>
                                </label>
                                <div class="col-sm-3">
                                    <input type="password" name="password" id="password" value="" maxlength="20" class="form-control" autocomplete="off"/>
                                </div>
                                <div class="col-sm-3">
                                    <button type="submit" class="btn btn-primary">
                                        <xsl:value-of select="'Pull from Git repository'"/>
                                    </button>
                                </div>
                            </div>
                            
                        </form>
                        
                        <div class="well well-sm well-code top-margin small monospace">
                            <xsl:for-each select="//execution">
                                <strong>
                                    <xsl:value-of select="concat($environment/m:label, '$ ', commandline/text())"/>
                                </strong>
                                <br/>
                                <xsl:for-each select="stdout/line">
                                    <xsl:value-of select="concat('  ', text())"/>
                                    <br/>
                                </xsl:for-each>
                                <hr/>
                            </xsl:for-each>
                            <strong>
                                <xsl:value-of select="concat($environment/m:label, '$ ...')"/>
                            </strong>
                        </div>
                        
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Pull from Git repository | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Utility to pull from Git repository'"/>
            <xsl:with-param name="content">
                <xsl:call-template name="utilities-page">
                    <xsl:with-param name="content" select="$content"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>