<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">

    <!-- http://84000.co/about/84000Workflow.pdf -->
    <xsl:import href="about.xsl"/>

    <xsl:template match="/m:response">

        <xsl:variable name="content">

            <div class="row">
                <div class="col-sm-9">

                    <h3 id="patrons">Honorary Patrons</h3>
                    <ul>
                        <li>The King of Bhutan, His Majesty Jigme Khesar Namgyel Wangchuck</li>
                        <li>The Princess of Bhutan, Ashi Kesang Wangmo Wangchuck</li>
                        <li>Dr. Kapila Vatsyayan</li>
                    </ul>

                    <h3 id="endorsements">Endorsements</h3>
                    <ul>
                        <li>H.H. the Dalai Lama</li>
                        <li>H.H. the Karmapa</li>
                        <li>H.H. the Sakya Trizin</li>
                        <li>H.H. Jigdal Dagchen Sakya</li>
                        <li>H.H. the late Mindrolling Trichen</li>
                        <li>H.H. the Gaden Tripa, Rizong Sras</li>
                        <li>H.E. Garchen Rinpoche</li>
                        <li>H.E. Jetsun Khandro Rinpoche</li>
                        <li>H.E. Shenphen Dawa Rinpoche</li>
                        <li>H.E. the late Tenga Rinpoche</li>
                        <li>H.E. Thrangu Rinpoche</li>
                        <li>the late Khenpo Appey Rinpoche</li>
                        <li>Ashin Kheminda</li>
                        <li>Chokyi Nyima Rinpoche</li>
                        <li>Dzigar Kongtrul Rinpoche</li>
                        <li>Dzogchen Ponlop Rinpoche</li>
                        <li>Geshe Dorji Damdul</li>
                        <li>Geshe Lhakdor</li>
                        <li>Khen Rinpoche Lobsang Tsetan</li>
                        <li>Khenchen Pema Sherab Rinpoche</li>
                        <li>Khenchen Tsewang Gyatso Rinpoche</li>
                        <li>Khenpo Ngawang Jorden</li>
                        <li>Lama Doboom Tulku Rinpoche</li>
                        <li>Mingyur Rinpoche</li>
                        <li>Orgyen Tobgyal Rinpoche</li>
                        <li>Ringu Tulku</li>
                        <li>Sangye Nyenpa Rinpoche</li>
                        <li>Sogyal Rinpoche</li>
                        <li>Matthieu Ricard</li>
                        <li>the late Dr. Gene Smith</li>
                        <li>Dr. Peter Skilling (and many others ...)</li>
                    </ul>

                    <h3 id="board">Board</h3>
                    <ul>
                        <li>Dzongsar Khyentse Rinpoche (84000 Chair)</li>
                        <li>David Lunsford</li>
                        <li>Prof. Sara McClintock, Emory University</li>
                        <li>Erik Pema Kunsang</li>
                        <li>Dr. Gregory Forgues, University of Vienna</li>
                    </ul>

                    <h3 id="advisory-panel">Advisory Panel</h3>
                    <ul>
                        <li>Jeff Wallman, Buddhist Digital Resource Center</li>
                        <li>Dr. Steven Goodman, California Institute of Integral Studies</li>
                        <li>Dr. Tom Tillemans, University of Lausanne</li>
                    </ul>

                    <h3 id="working-committee">Working Committee</h3>
                    <ul>
                        <li>Dzongsar Khyentse Rinpoche (84000 Chair)</li>
                        <li>Huang Jing Rui (84000 Executive Director)</li>
                        <li>Dr. Andreas Doctor, Rangjung Yeshe Institute</li>
                        <li>Dominic Latham</li>
                        <li>Dr. James Gentry, Harvard University</li>
                        <li>Dr. John Canti, Padmakara Translation Group</li>
                        <li>Cangioli Che, Khyentse Foundation</li>
                        <li>Ivy Ang, Visionlinc</li>
                    </ul>

                    <h3 id="grants">Grants Subcommittee</h3>
                    <ul>
                        <li>Amy Ang (84000 Grants Coordinator)</li>
                        <li>Dr. Andreas Doctor</li>
                        <li>Dr. James Gentry</li>
                        <li>Dr. John Canti</li>
                        <li>Cangioli Che</li>
                        <li>Huang Jing Rui</li>
                    </ul>

                    <h3 id="editorial">Editorial Subcommittee</h3>
                    <ul>
                        <li>Dr. John Canti (84000 Editorial Chair and Director)</li>
                        <li>Dr. James Gentry (84000 Editor in Chief)</li>
                        <li>Dr. Andreas Doctor (84000 Editor)</li>
                    </ul>

                    <h4>Associate Editors</h4>
                    <ul>
                        <li>Nancy Lin, University of California, Berkeley</li>
                        <li>Rory Lindsay, University of California, Santa Barbara</li>
                        <li>Ryan Damron, University of California, Berkeley</li>
                        <li>Thomas Cruijsen, Namgyal Institute of Tibetology</li>
                    </ul>

                    <h4>Copyeditors</h4>
                    <ul>
                        <li>Konchog Norbu</li>
                        <li>Laura Goetz</li>
                    </ul>

                    <h4>Editorial Consultants</h4>
                    <ul>
                        <li>Gavin Kilty, Institute of Tibetan Classics</li>
                        <li>Larry Mermelstein, Nalanda Translation Committee</li>
                    </ul>

                    <h3 id="reviewers">Board of Reviewers</h3>

                    <h4>Indo-Himalayan teachers/scholars</h4>
                    <ul>
                        <li>Drubgyud Tenzin Rinpoche</li>
                        <li>Geshe Dorji Damdul</li>
                        <li>Geshe Lhakdor</li>
                        <li>H.E. Jetsun Khandro Rinpoche</li>
                        <li>Ringu Tulku</li>
                        <li>Sangye Nyenpa Rinpoche</li>
                    </ul>

                    <h4>Western academics</h4>
                    <ul>
                        <li>Prof. Anne Klein, Rice University</li>
                        <li>Prof. Bill Waldron, Middlebury College, Vermont</li>
                        <li>Prof. Christian K. Wedemeyer, University of Chicago Divinity School</li>
                        <li>Prof. Dan Hirshberg, University of Mary Washington</li>
                        <li>Prof. David Gray, Santa Clara University</li>
                        <li>Dr. David Higgins, University of Vienna</li>
                        <li>Prof. Dominic Sur, Utah State University</li>
                        <li>Prof. Douglas Duckworth, Temple University</li>
                        <li>Gavin Kilty, Institute of Tibetan Classics</li>
                        <li>Prof. Giacomella Orofino, University of Naples “L’Orientale”</li>
                        <li>Dr. Gyurme Dorje, University of London</li>
                        <li>Prof. Jake Dalton, University of California-Berkeley</li>
                        <li>Dr. James Gentry, Harvard University</li>
                        <li>Dr. Jan Nattier, University of California, Berkeley</li>
                        <li>Prof. Jens Braarvig, University of Oslo</li>
                        <li>Prof. John Makransky, Boston College</li>
                        <li>Prof. John Dunne, Emory University</li>
                        <li>Prof. Jose Cabezon, University of California, Santa Barbara</li>
                        <li>Prof. Kammie Takahashi, Muhlenberg Colleage</li>
                        <li>Prof. Karen Lang, University of Virginia</li>
                        <li>Dr. Karen Liljenberg, School of Oriental and African Studies (SOAS),</li>
                        <li>University of London</li>
                        <li>Prof. Klaus-Dieter Mathes, University of Vienna</li>
                        <li>Prof. Kurtis Schaeffer, University of Virginia</li>
                        <li>Dr. Olga Serbaeva, University of Zurich</li>
                        <li>Dr. Paul Hackett, Columbia University</li>
                        <li>Prof. Paul Harrison, Stanford University</li>
                        <li>Prof. Per Sørensen, Leipzig University</li>
                        <li>Dr. Peter Alan Roberts</li>
                        <li>Dr. Philippe Turenne, Kathmandu University</li>
                        <li>Robert Miller, Lhundrub Chime Gatsal Ling</li>
                        <li>Dr. Rory Lindsay, University of California, Santa Barbara</li>
                        <li>Ryan Damron, UC Berkeley</li>
                        <li>Prof. Sara McClintock, Emory University</li>
                        <li>Prof. Shrikant Bahulkar, University of Pune</li>
                        <li>Thomas Cruijsen, Namgyal Institute of Tibetology</li>
                        <li>Dr. Thomas Doctor, Kathmandu University</li>
                        <li>Dr. Vincent Eltschinger, IKGA of the Austrian Academy of Sciences</li>
                        <li>Prof. Warner Belanger, Georgia College</li>
                        <li>Dr. Wiesiek Mical, Kathmandu University</li>
                    </ul>

                    <h3 id="technology">Technology and Resources Subcommittee</h3>
                    <ul>
                        <li>Dominic Latham (84000 Technical Lead)</li>
                    </ul>

                    <h4>Publications and TEI Markup</h4>
                    <ul>
                        <li>Mike Engle (Publications Lead)</li>
                        <li>Andre Rodrigues</li>
                        <li>Celso Wilkinson</li>
                        <li>Chandika Maharjan</li>
                        <li>Laura Goetz</li>
                    </ul>

                    <h4>Technical Support</h4>
                    <ul>
                        <li>Koh Seng Kiat</li>
                        <li>Dave Zwiebeck</li>
                    </ul>

                    <h4>Technology and Resources consultants</h4>
                    <ul>
                        <li>Adam Pearcey, SOAS London, Lotsawa House</li>
                        <li>Alex Wright, Etsy</li>
                        <li>Dr. Michael Sheehy, Mind and Life Institute</li>
                        <li>Prof. Jake Dalton, University of California-Berkeley</li>
                        <li>Prof. Marcus Bingenheimer, Temple University</li>
                    </ul>

                    <h3 id="operations">Operations Subcommittee</h3>
                    <ul>
                        <li>Huang Jing Rui</li>
                        <li>Cangioli Che</li>
                        <li>Ivy Ang</li>
                    </ul>

                    <h4>Operations Team</h4>
                    <ul>
                        <li>Huang Jing Rui</li>
                        <li>Amy Ang</li>
                        <li>Pema Abrahams</li>
                        <li>Ushnisha Ng</li>
                    </ul>

                    <h3 id="communications">Communications</h3>
                    <ul>
                        <li>Pema Abrahams (84000 Communications Lead)</li>
                        <li>Joie Chen</li>
                        <li>Ushnisha Ng</li>
                        <li>Huang Jing Rui</li>
                    </ul>

                    <h4>Chinese Communications Team</h4>
                    <ul>
                        <li>Joie Chen (Coordinator)</li>
                        <li>Jain Feng</li>
                        <li>Huang Jing Rui</li>
                        <li>Claire Fang Yang</li>
                        <li>Huang Yu Chien</li>
                        <li>Joanne Liao</li>
                        <li>Ma Lan</li>
                        <li>Qiu Hong</li>
                        <li>Ratna Liu</li>
                        <li>Wang Lang</li>
                    </ul>

                    <h4>Branding</h4>
                    <ul>
                        <li>John Solomon (Branding)</li>
                        <li>Jordan Valdez</li>
                        <li>Alex Wright</li>
                        <li>Isaiah Seret</li>
                        <li>Laura Lopez</li>
                    </ul>
                    <p>*Thanks to <a href="https://www.miltonglaser.com/">Milton Glaser</a> and <a href="http://www.hotstudio.com/">Hot Studio</a> for their design services.</p>

                    <h3 id="events">Events and Operations</h3>
                    <ul>
                        <li>Ushnisha Ng (84000 Operations Manager)</li>
                    </ul>

                    <h4>Event Coordinators</h4>
                    <ul>
                        <li>Andrea Bringmann</li>
                        <li>Yeh Li-Hao</li>
                    </ul>

                    <h4>Team Members</h4>
                    <ul>
                        <li>
                            <strong>Australia:</strong> Dr. Diana Cousens (Sunyata)</li>
                        <li>
                            <strong>Bhutan:</strong> Dellay Phuntsho, Sangay Tenzin, Tashi Tobgay</li>
                        <li>
                            <strong>Canada:</strong> Julie Jay</li>
                        <li>
                            <strong>China:</strong> Lily Shen</li>
                        <li>
                            <strong>Europe:</strong> Andrea Bringmann, Arne Schelling</li>
                        <li>
                            <strong>Hong Kong:</strong> Stella Yi Jin (coordinator), Jacqueline Lee, Zoe Tang</li>
                        <li>
                            <strong>North America:</strong> Dr. Tom Trabin, James Hopkins, Kiat-Sing Teo, Laura Lopez</li>
                        <li>
                            <strong>India:</strong> Deepa Thakur, Nisheeta Jagtiani</li>
                        <li>
                            <strong>Indonesia:</strong> Emi Theng, Winnie Alamsjah</li>
                        <li>
                            <strong>Singapore:</strong> Alan Kuek, Cabie Sim</li>
                        <li>
                            <strong>Taiwan:</strong> Jain Feng</li>
                    </ul>

                    <h3 id="finance">Finance and Database</h3>
                    <ul>
                        <li>Marco Noailles (Treasurer)</li>
                        <li>Amy Ang (Finance Manager)</li>
                        <li>Wu Lin (Accountant)</li>
                        <li>Awing Choi</li>
                        <li>Celia Chew</li>
                        <li>Diana Tan</li>
                        <li>Florence Yeh</li>
                        <li>Karen Choo</li>
                        <li>Lizzy Tam</li>
                        <li>Ratna Liu</li>
                        <li>Ranya Wu</li>
                    </ul>

                    <h3 id="legal">Legal Counsel</h3>
                    <ul>
                        <li>Alexander Halpern, LLC of Boulder, Colorado, USA</li>
                    </ul>

                </div>
                <div id="affix-nav" class="col-sm-3 hidden-print hidden-sm hidden-xs small">
                    <ul class="list-group" aria-label="navigation" data-spy="affix" data-offset-top="60">
                        <li class="list-group-item">
                            <a href="#patrons" class="scroll-to-anchor">Patrons</a>
                        </li>
                        <li class="list-group-item">
                            <a href="#endorsements" class="scroll-to-anchor">Endorsements</a>
                        </li>
                        <li class="list-group-item">
                            <a href="#board" class="scroll-to-anchor">Board</a>
                        </li>
                        <li class="list-group-item">
                            <a href="#advisory-panel" class="scroll-to-anchor">Advisory Panel</a>
                        </li>
                        <li class="list-group-item">
                            <a href="#working-committee" class="scroll-to-anchor">Working Committee</a>
                        </li>
                        <li class="list-group-item">
                            <a href="#grants" class="scroll-to-anchor">Grants</a>
                        </li>
                        <li class="list-group-item">
                            <a href="#editorial" class="scroll-to-anchor">Editorial</a>
                        </li>
                        <li class="list-group-item">
                            <a href="#reviewers" class="scroll-to-anchor">Reviewers</a>
                        </li>
                        <li class="list-group-item">
                            <a href="#technology" class="scroll-to-anchor">Technology</a>
                        </li>
                        <li class="list-group-item">
                            <a href="#operations" class="scroll-to-anchor">Operations</a>
                        </li>
                        <li class="list-group-item">
                            <a href="#communications" class="scroll-to-anchor">Communications</a>
                        </li>
                        <li class="list-group-item">
                            <a href="#events" class="scroll-to-anchor">Events</a>
                        </li>
                        <li class="list-group-item">
                            <a href="#finance" class="scroll-to-anchor">Finance</a>
                        </li>
                        <li class="list-group-item">
                            <a href="#legal" class="scroll-to-anchor">Legal</a>
                        </li>
                    </ul>
                </div>
            </div>



        </xsl:variable>

        <xsl:call-template name="about">
            <xsl:with-param name="sub-content" select="$content"/>
        </xsl:call-template>

    </xsl:template>

</xsl:stylesheet>