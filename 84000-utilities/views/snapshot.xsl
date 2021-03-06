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
                    <div class="panel-heading bold hidden-print center-vertical">
                        
                        <xsl:call-template name="header"/>
                        
                    </div>
                    
                    <div class="panel-body">
                        
                        <xsl:call-template name="tabs">
                            <xsl:with-param name="active-tab" select="@model-type"/>
                        </xsl:call-template>
                        
                        <div class="tab-content">
                            
                            <div class="row">
                                <div class="col-sm-offset-2 col-sm-8">
                                    
                                    <div class="alert alert-info small text-center">
                                        <p>
                                            <xsl:value-of select="'This function makes a snapshot of the selected resource(s) and pushes it to the public GitHub repositories: '"/>
                                        </p>
                                        <ul class="list-inline inline-dots">
                                            <xsl:for-each select="('data-tei', 'data-config', 'data-translation-memory', 'data-rdf')">
                                                <li>
                                                    <a target="_blank" class="alert-link">
                                                        <xsl:attribute name="href" select="concat('https://github.com/84000/', ., '/commits/master')"/>
                                                        <xsl:value-of select="."/>
                                                    </a>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                    </div>
                                    
                                    <form action="/snapshot.html" method="post" class="form-horizontal">
                                        
                                        <input type="hidden" name="tab" value="snapshot"/>
                                        <input type="hidden" name="action" value="sync"/>
                                        
                                        <div class="form-group">
                                            <label for="resource" class="col-sm-3 control-label">
                                                <xsl:value-of select="'Resources'"/>
                                            </label>
                                            <div class="col-sm-9">
                                                <select name="resource" id="resource" class="form-control">
                                                    <option value="tei">All TEI files</option>
                                                    <option value="sections">Section TEI files</option>
                                                    <option value="config">Config files</option>
                                                    <option value="tm">Translation Memory files</option>
                                                    <option value="tmg">Translation Memory Generator files</option>
                                                    <option value="rdf">RDF files</option>
                                                    <xsl:for-each select="m:translations/m:file">
                                                        <xsl:sort select="@file-name"/>
                                                        <option>
                                                            <xsl:attribute name="value" select="@uri"/>
                                                            <xsl:value-of select="@file-name"/>
                                                        </option>
                                                    </xsl:for-each>
                                                </select>
                                            </div>
                                        </div>
                                        
                                        <div class="form-group">
                                            <label for="message" class="col-sm-3 control-label">
                                                Commit message
                                            </label>
                                            <div class="col-sm-9">
                                                <input type="text" name="message" id="message" value="" maxlength="100" class="form-control" placeholder="e.g. Toh X updates Jan 2018"/>
                                            </div>
                                        </div>
                                        
                                        <div class="form-group">
                                            <div class="col-sm-8 col-sm-offset-4">
                                                <button type="submit" class="btn btn-primary">Make a snapshot</button>
                                            </div>
                                        </div>
                                        
                                    </form>
                                    
                                    <xsl:if test="//m:execute">
                                        <div class="well well-sm">
                                            <code class="small">
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
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Data Snapshot | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Data snapshot utility'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>