<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">

    <xsl:import href="about.xsl"/>

    <xsl:template match="/m:response">

        <xsl:variable name="content">
            
            <p class="text-center text-moted bottom-margin">ON THE AUSPICIOUS OCCASION OF LOSAR, 84000 IS PLEASED TO ANNOUNCE ITS NEWEST PUBLICATION</p>
            <div class="row">
                <div class="col-sm-8 col-sm-offset-2">
                    <div class="section-panel">
                        <a href="http://read.84000.co/translation/toh231.html" class="block-link">
                            <h2 class="text-bo">དཀོན་མཆོག་སྤྲིན།</h2>
                            <h1>The Jewel Cloud</h1>
                            <h2 class="text-sa">Ratnamegha</h2>
                        </a>
                    </div>
                </div>
            </div>
            <p class="text-center bottom-margin">Toh 231</p>
            <p class="text-center">On Gayāśīrṣa Hill, Buddha Śākyamuni is visited by a great gathering of
                bodhisattvas who have travelled miraculously there from a distant world, to
                venerate him as one who has vowed to liberate beings in a world much more
                afflicted than their own. The visiting bodhisattvas are led by
                Sarvanīvaraṇaviṣkambhin, who asks the Buddha a series of searching
                questions. In response, the Buddha gives a detailed and systematic account of
                the practices, qualities, and nature of bodhisattvas, the stages of their path,
                their realisation, and their activities. Many of the topics are structured into
                sets of ten aspects, expounded with reasoned explanations and illustrated with
                parables and analogies. This sūtra’s doctrinal richness, profundity, and clarity
                are justly celebrated, and some of its key statements on meditation, the
                realisation of emptiness, and the fundamental nature of the mind have been
                widely quoted in the Indian treatises and Tibetan commentarial literature.</p>
            <p class="text-center">
                Access this and other sūtras in the 84000 Reading Room:
                <br/>
                <a href="http://read.84000.co/translation/toh231.html" target="_blank" rel="noopener" class="text-bold">
                    The Jewel Cloud
                </a>
            </p>

        </xsl:variable>

        <xsl:call-template name="about">
            <xsl:with-param name="sub-content" select="$content"/>
        </xsl:call-template>

    </xsl:template>

</xsl:stylesheet>