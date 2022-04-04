<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">

    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>

    <xsl:template match="/m:response">

        <xsl:variable name="content">
            <div class="container">
                <div class="panel panel-default">

                    <div class="panel-heading bold hidden-print center-vertical">

                        <span class="title">
                            <xsl:value-of select="'Editable content'"/>
                        </span>

                    </div>
                    
                    <script>
                        var button = document.getElementById("submit-button");
                        button.addEventListener('click', function(){ alert('!') }, false);
                    </script>
                    
                    <div class="panel-body min-height-md">
                        <form method="post">
                            <div class="row">
                                <div class="col-sm-6">
                                    <div contenteditable="" name="contenteditable">
                                        <xsl:copy-of select="m:editable"/>
                                    </div>
                                    <textarea name="content" class="hidden"/>
                                    <hr/>
                                    <div>
                                        <xsl:copy-of select="m:input/node()"/>
                                    </div>
                                </div>
                                <div class="col-sm-6">
                                    <button type="submit" class="btn btn-success" id="submit-button">Save</button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </xsl:variable>

        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities prototype'"/>
            <xsl:with-param name="page-title" select="'Prototype | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="''"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>

    </xsl:template>

</xsl:stylesheet>