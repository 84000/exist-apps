<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:include href="about.xsl"/>
    
    <xsl:template match="/m:response">
        <xsl:variable name="content">
            <h2>Our Global Impact</h2>
            
            <div class="row about-stats">
                <div class="col-sm-6">
                    <p>84000’s two goals are: <strong>Translation</strong> and <strong>Global Access</strong>. </p>
                    <p>Besides <strong>translating</strong> the words of the Buddha, we need to build and maintain a user-friendly and technologically robust mass publication platform (our online Reading Room) that will allow everyone in the world to have <strong>easy access</strong> to these texts. </p>
                    <p>With your generous support, the online Reading Room has achieved <strong>8.3 million views</strong>, and the words of the Buddha are now being read by more than <strong>178,000 people</strong> from <strong>242 countries/regions</strong> spanning the globe.</p>
                    <p>The diagram below provide an overview of the <strong>global impact</strong> we have created together. Your <a href="http://84000.co/how-you-can-help/sponsor-a-page" target="_blank">continued support</a> will provide global access to the words of the Buddha. </p>
                </div>
                <div class="col-sm-6">
                   
                    <div class="stat">
                        <div class="heading">This website</div>
                        <div class="data">
                            <span>
                                <xsl:value-of select="format-number(sum(//m:period/m:stat[@name = 'comms-pageviews']/@value), '#,###')"/>
                            </span> views, 
                            <span>
                                <xsl:value-of select="format-number(sum(//m:period/m:stat[@name = 'comms-users']/@value), '#,###')"/>
                            </span> visitors.
                        </div>
                    </div>
                    
                    <div class="stat">
                        <div class="heading">The Reading Room</div>
                        <div class="data">
                            <span>
                                <xsl:value-of select="format-number(sum(//m:period/m:stat[@name = 'reading-room-pageviews']/@value), '#,###')"/>
                            </span> views, 
                            <span>
                                <xsl:value-of select="format-number(sum(//m:period/m:stat[@name = 'reading-room-users']/@value), '#,###')"/>
                            </span> visitors.
                        </div>
                    </div>
                    
                    <div class="stat">
                        <div class="heading">Downloads from the Reading Room</div>
                        <div class="data">
                            <span>
                                <xsl:value-of select="format-number(sum(//m:period/m:stat[@name = 'text-downloads']/@value), '#,###')"/>
                            </span> downloads.
                        </div>
                    </div>
                    
                    <div class="stat">
                        <div class="heading">Our reach</div>
                        <div class="data">
                            <span>
                                <xsl:value-of select="format-number(count(//m:list[@name = 'user-countries']/m:item), '#,###')"/>
                            </span> different countries.
                        </div>
                    </div>
                    
                </div>
            </div>
            
            <h2>Countries where our readers come from</h2>
            <!-- A map would be great here -->
            <div class="row">
                <xsl:for-each select="//m:list[@name = 'user-countries']/m:item">
                    <xsl:sort select="text()"/>
                    <div class="col-sm-3">
                        <xsl:value-of select="text()"/>
                    </div>
                </xsl:for-each>
                
            </div>
        </xsl:variable>
        
        <xsl:call-template name="about">
            <xsl:with-param name="sub-content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>