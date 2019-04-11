<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">

    <xsl:import href="about.xsl"/>

    <xsl:template match="/m:response">

        <xsl:variable name="content">
            <h2>Help us Preserve a Living Tradition</h2>
            <p>84000: Translating the Words of the Buddha is a global non-profit initiative to <strong>translate</strong> all of the Buddha’s words into modern languages, and to <strong>make them available</strong> to everyone.</p>
            <h3>Our Vision</h3>
            <div class="about-stats">
                <div class="row bottom-margin">
                    <div class="col-sm-3 col-lg-2">
                        <div class="stat red">
                            <div class="data">
                                <span>100</span> years</div>
                        </div>
                    </div>
                    <div class="col-sm-9 col-lg-10">
                        <p>To provide universal access to the words of the Buddha (the <a href="http://84000.co/facts-and-figures-about-kangyur-and-tengyur" target="_blank" rel="noopener">Kangyur and Tengyur</a>) translated into modern languages. </p>
                    </div>
                </div>
                <div class="row bottom-margin">
                    <div class="col-sm-3 col-lg-2">
                        <div class="stat orange">
                            <div class="data">
                                <span>25</span> years</div>
                        </div>
                    </div>
                    <div class="col-sm-9 col-lg-10">
                        <p> To make all of the Kangyur and related volumes of the Tengyur available in English, and provide widespread accessibility in multiple platforms. </p>
                    </div>
                </div>
                <div class="row bottom-margin">
                    <div class="col-sm-3 col-lg-2">
                        <div class="stat green">
                            <div class="data">
                                <span>10</span> years</div>
                        </div>
                    </div>
                    <div class="col-sm-9 col-lg-10">
                        <p> To make a significant portion of the Kangyur and complementary Tengyur texts available in English, and easily accessible in multiple platforms. </p>
                    </div>
                </div>
                <div class="row bottom-margin">
                    <div class="col-sm-3 col-lg-2">
                        <div class="stat blue">
                            <div class="data">
                                <span>5</span> years</div>
                        </div>
                    </div>
                    <div class="col-sm-9 col-lg-10">
                        <p> To make a representative sample of the <a href="/facts-and-figures-about-kangyur-and-tengyur" target="_blank" rel="noopener">Kangyur and Tengyur</a> available in English, and establish the infrastructure and resources necessary to accomplish the long-term vision. </p>
                    </div>
                </div>
            </div>
            <h3>Our Goals</h3>
            <p>Our two goals are: <strong>Translation</strong> and <strong>Global Access</strong>
            </p>
            <h4>Translation: Why translate now?</h4>
            <p>It is said that the Buddha taught more than 84,000 methods to attain true peace and freedom from suffering. As of 2010, only 5% of these teachings were translated into modern languages. Due to the rapid decline in the knowledge of classical Buddhist languages (such as Tibetan, Pali, Sanskrit and classical Chinese) and in the number of qualified scholars, we are in danger of losing this cultural heritage and spiritual legacy.</p>
            <h4>Global Access: Why publish online?</h4>
            <p>84000 is both a translation body and an online publication house. For the sake of giving all those interested in the Buddha’s teachings easy access to high quality translations, the translated texts will be freely available in the online Reading Room to anyone with access to the Internet, anywhere in the world.</p>
            <p>Beyond that, culturally, for centuries, there has been a widespread practice of printing and disseminating physical copies of sutras because doing so allows practicing Buddhists to spread the dharma and to “accumulate merit.” In this respect, it could be said that the number of printed copies limited the access to and potential reach of each text (i.e. printing and distributing 1,000 sutras could only reach and benefit 1,000 people). Enabling the online publication of the Buddha’s
                words is comparable to the printing and disseminating of an infinite number of texts, immeasurably benefitting both the sponsor and the readers.</p>
            <h3>Our Scope</h3>
            <p>84000’s primary focus for translation is the canonical Tibetan texts included in the <a href="/facts-and-figures-about-kangyur-and-tengyur" target="_blank" rel="noopener">Kangyur and Tengyur</a>. The canonical texts in Pali and Chinese are beyond the scope of our work at present. At the moment, 84000 is concentrating on translations into English, as there are very few canonical texts available in the English language. Translations into other modern languages will be looked into
                when resources are available.</p>
            <p>Translations are made according to broad, consensual guidelines. Translator teams produce translations for an audience of educated but non-specialist readers, practitioners, and people looking for insight from the Buddha’s words, as well as providing the clear and comprehensive detail required by scholars. Brief introductions, notes, bibliographies, glossaries and other reference materials are included within each text.</p>
            <p>After expert review, the translations are published in our <a title="Online Reading Room" href="http://read.84000.co" target="_blank" rel="noopener">online Reading Room</a>, free of charge, and equipped with advanced technology for easy use and navigation. It provides access to 84000’s translations as they become available, and references other known existing translations. Print editions will be made available as funding permits.</p>
        </xsl:variable>

        <xsl:call-template name="about">
            <xsl:with-param name="sub-content" select="$content"/>
        </xsl:call-template>

    </xsl:template>

</xsl:stylesheet>