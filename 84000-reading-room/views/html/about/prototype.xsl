<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <!-- http://84000.co/about/84000Workflow.pdf -->
    <xsl:import href="about.xsl"/>
    
    <xsl:template match="/m:response">
        <xsl:variable name="content">
            
            <h2>What It Takes To Produce A Page of Translation</h2>
            
            <div class="panel panel-danger bordered no-shadow">
                
                <div class="panel-heading">
                    <h3 class="panel-title">Translation and editorial overview</h3>
                </div>
                
                <div class="panel-body">
                    <div class="row">
                        <div class="col-sm-6">
                            <div class="eft-block blue">
                                <h4>Phase 1 : Translation</h4>
                                <h5>I. Grant selection</h5>
                                <ol>
                                    <li>Grant proposal submission</li>
                                    <li>Grant evaluation</li>
                                    <li>Grant agreement confirmation</li>
                                </ol>
                                <h5>II.Translation</h5>
                                <ol>
                                    <li>Research</li>
                                    <li>Consult multiple editions</li>
                                    <li>Initial reading</li>
                                    <li>First draft</li>
                                    <li>Subsequent revisions</li>
                                    <li>Preparation of auxilliary materials</li>
                                    <li>Further stylistic revisions</li>
                                </ol>
                                <h5>III. Editorial</h5>
                                <ol>
                                    <li>Coordinate and provide guidance to translators</li>
                                    <li>Review and edit translations at various stages</li>
                                    <li>Ensure overall translation quality</li>
                                    <li>Manage review process</li>
                                </ol>
                                <h5>IV. Review</h5>
                                <ol>
                                    <li>Ongoing internal review</li>
                                    <li>External review</li>
                                    <li>Final draft</li>
                                </ol>
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="eft-block orange bottom-margin">
                                <h4>Phase 2 : Publication</h4>
                                <h5>I. Copyediting</h5>
                                <ol>
                                    <li>Pre-copyediting check</li>
                                    <li>Copyediting</li>
                                </ol>
                                <h5>II. Pre-publication</h5>
                                <ol>
                                    <li>Post-copyediting check</li>
                                    <li>Detailed pre-publication review and editing</li>
                                </ol>
                                <h5>III. TEI Markup</h5>
                                <ol>
                                    <li>TEI markup</li>
                                    <li>Post-markup problem solving</li>
                                </ol>
                                <h5>IV. Final editing</h5>
                                <ol>
                                    <li>Final editorial review</li>
                                    <li>Problem solving</li>
                                </ol>
                                <h5>V. Publication</h5>
                                <ol>
                                    <li>Internal release</li>
                                    <li>Pre-release checks and proofreading</li>
                                    <li>Public release</li>
                                </ol>
                            </div>
                            <div class="well">
                                <p>Editorial overview and management accross all stages.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="panel panel-danger bordered no-shadow">
                <div class="panel-heading">
                    <h3 class="panel-title">Technology</h3>
                </div>
                <div class="panel-body">
                    <p>Ongoing development and maintenance of:</p>
                    <ul>
                        <li>Mass online publication database (online reading room)</li>
                        <li>Editorial tools (e.g. Layers of editorial access etc.)</li>
                        <li>Translation tools and resources (e.g. Cumulative glossary, terminology pages, etc.)</li>
                        <li>User interface features and design (e.g. Automatic mutli-format generators including PDF and others, multi-level search function, etc.)</li>
                        <li>Version control</li>
                        <li>Backup system</li>
                    </ul>
                </div>
                
            </div>
            
            
            <div class="panel panel-danger bordered no-shadow">
                <div class="panel-heading">
                    <h3 class="panel-title">Operations and administration</h3>
                </div>
                <div class="panel-body">
                    <ul>
                        <li>Stategic planning and implementation</li>
                        <li>Translation grant administration</li>
                        <li>Administration of payment and services</li>
                        <li>Communications and fundraising</li>
                        <li>Human ressource management</li>
                    </ul>
                </div>
                
            </div>
            
            <div class="panel panel-danger bordered no-shadow">
                <div class="panel-heading">
                    <h3 class="panel-title">Training and developement</h3>
                </div>
                <div class="panel-body">
                    <ul>
                        <li>Identification of training needs of translators, editors, copyeditors, markup editors, and knowledge/skills needed across all stages of work</li>
                        <li>Work with partner organizations/institutions to enhance translation standards, and to ensure a steady stream of translators tosustain 84000's work in the long term</li>
                    </ul>
                </div>
            </div>
        </xsl:variable>
        
        <xsl:call-template name="about">
            <xsl:with-param name="sub-content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>