<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">

    <!-- http://84000.co/about/84000Workflow.pdf -->
    <xsl:import href="about.xsl"/>

    <xsl:template match="/m:response">

        <xsl:variable name="content">
            <blockquote class="offset">
                <p>People must understand the tremendous need and the value of having access to the original teachings and that they are not something in volumes and volumes up there in the shrine that you supplicate and prostrate to and make homages to, but they are something that you can read, you can understand and you can contemplate upon. That’s really bringing the Buddha into a living moment, really being able to be in the presence of the Buddha himself. That I think powerful and filled with blessings. Extraordinary undertakings, absolutely must be supported by everyone.</p>
                <footer>H.E. Mindrolling Jetsun Khandro Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>As followers of the Buddha, we say that the body of Buddha Shakyamuni has, supposedly, gone 2,500 years ago. The mind of the Buddha can only be materialized if you practice and achieve enlightenment one day. The only thing that is tangible - something you can communicate with and work with - is the speech of the Buddha; and that is in the form of Kangyur and Tengyur, which we are now translating. You can really help in every form and in every way.</p>
                <footer>Dzongsar Khyentse Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>If you only had Tibetan, then probably maybe not even one per cent of the human population will understand the Buddha's teachings that are now only in the Tibetan language...But if you translate into English... English is a language that can pervade the whole world.</p>
                <footer>H.E. Garchen Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>I am very supportive of 84000.co. When it is completed, I hope that it will benefit many scholars, including researchers and students who are studying Buddhism. However, I feel that solely relying on web publication is not enough, it should also have some some printed materials. I look forward to seeing the printed version of these works in the future! Through a website like 84000.co, I hope that it will enable more people to learn about Buddhist sutras; especially when these sutras are no longer simply being left on the shelves, but - through translation - are brought closer to us, allowing us to understand the Buddhadharma through the process of reading sutras.</p>
                <footer>Venerable Dhammapala</footer>
            </blockquote>
            <blockquote class="offset">
                <p>After the completion of all these texts, they should be available to everyone free of charge.</p>
                <footer>Professor Alex Berzin</footer>
            </blockquote>
            <blockquote class="offset">The translations of the Kangyur and Tengyur are the greatest treasure we have as Tibetans.
                <footer>H.H. the Dalai Lama spoke in Tibetan during Kalachakra 2011</footer>
            </blockquote>
            <blockquote class="offset">
                <p>If one person tries to stubbornly shift a huge boulder on their own, all that is achieved is a terrible drain on their energy and time, and the boulder still won't move. But the cooperative effort of a dozen people can move the boulder easily.</p>
                <p>If we collaborate to move our own huge boulder...we'd be able to work out how to be more efficient and use our resources more wisely.</p>
                <footer>Dzongsar Khyentse Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>Words of the Buddha, the scriptures, are actually deeply considered more precious than the image of the Buddha. Because image of the Buddha is very precious, but the Buddha himself actually prophesied, saying later in times of degeneration, he will appear as a teacher in the form of scriptures. Scriptures teach us the Dharma. The scriptures are much more precious, much more important than the image of the Buddha.</p>
                <footer>H.E. Garchen Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>By translating and making available the Tibetan Buddhist texts to modern people, a vast swath of Buddhist civilization and culture may be saved from annihilation.</p>
                <footer>Dzongsar Khyentse Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>When it comes to accomplishing an important goal, we must, as the Tibetan saying goes, carry the banner in common. This banner that we are trying to lift is no small banner––it is enormous, and to ensure success, everyone should contribute.</p>
                <footer>Chökyi Nyima Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>The primary object of the Buddha's teaching is to enable sentient beings to transform their minds. This can only be effectively achieved if they are available in a language that the listener or reader can understand. Although there seems to be a custom of paying respect to the scriptures from afar in all Buddhist societies, the purpose of such books will be much better fulfilled if interested people can actually read them and understand them in their own language.</p>
                <footer>H.H. the Dalai Lama</footer>
            </blockquote>
            <blockquote class="offset">
                <p>It will make an invaluable contribution to a deep and lasting understanding of the Buddhist tradition in Western lands.</p>
                <footer>H.H. the Dalai Lama</footer>
            </blockquote>
            <blockquote class="offset">
                <p>The sole thing we want to translate is Buddha's realization. That depends on compassion, kindness, and especially bodhicitta (altruistic intention). That's what our teachers from all traditions have said.</p>
                <footer>Jigme Khyentse Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>For young translators, I'd like to encourage you to develop and preserve your courage. Don't limit it. You should have the courage to move mountains.</p>
                <p>But never allow yourself to have pride, as pride closes the door of learning.</p>
                <footer>Tulku Pema Wangyal Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>I think it's very workable to translate the Kangyur and Tengyur, and it's very important that translators really come together as one harmonious unit to do the work for the present time and also for future generations.</p>
                <footer>Dzigar Kongtrül Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>One reason for prioritizing translation work is that we must continue to make available sacred Buddhist texts for non-Tibetans who wish to study and practise the Buddhadharma.</p>
                <footer>Dzongsar Khyentse Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>The fundamental policy of this group, the Buddhist Literary Heritage Project, will be––and has to be––the policy of bodhicitta (altruistic intention).</p>
                <footer>Dzongsar Khyentse Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>H.H. Dilgo Khyentse Rinpoche said it's important to translate the words of Buddha into English and eventually into other languages.</p>
                <footer>Tulku Pema Wangyal Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>Although the precious Dharma currently exists in Tibetan, Chinese, Sanskrit, Pali, and other Asian languages, it still remains largely inaccessible for anyone who does not have the fortune of studying and mastering these difficult tongues.</p>
                <footer>Chökyi Nyima Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>To make the words of the Buddha available now will be a precious source for pacifying the terrible troubles of humanity.</p>
                <footer>Wulstan Fletcher</footer>
            </blockquote>
            <blockquote class="offset">
                <p>Both the very generous and also the very knowledgeable and experienced translators will be able to perfect their two accumulations of virtue through their interdependent connection.</p>
                <footer>Tri Ralpachen (one of the three Dharma kings of Tibet)</footer>
            </blockquote>
            <blockquote class="offset">
                <p>We will be making available to people of all nationalities, everything they need to follow the Buddha's infinite path to liberation.</p>
                <footer>Dzongsar Khyentse Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>Please pray that if at times I successfully manage to tap the merit of the buddhas and bodhisattvas, this won't cause the swelling of my head.</p>
                <p>Please pray that I will have bodhicitta (altruistic intention) when I undertake this project so I won't be carried away by all kinds of personal agendas.</p>
                <p>Please pray that I won't be discouraged by unfavorable circumstances.</p>
                <p>Please pray that when things get stagnant I won't give up.</p>
                <footer>Dzongsar Khyentse Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>Hearing the wisdom of the Buddha through translation will be a great contribution to world society, now and in future.</p>
                <footer>Dzogchen Pönlop Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>While translating, the most difficult thing isn't a lack of funding; it's our own ignorance and pride. That's what obscures us.</p>
                <footer>Jigme Khyentse Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>It is such a great and worthwhile project that you are undertaking that I would like to take this opportunity to thank you and your colleagues and extend my heartfelt support to this project. I am with you and will do everything in my power to help you and support you. I also know that you are under very good guidance and I have no doubt that the project will be a great success.</p>
                <footer>Ringu Tulku Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>You should really think about serving mankind, serving humanity, serving the larger world with what you're doing... You should know first hand how Dharma helps you, how it brings so much betterment of one's own life, peace and joy.</p>
                <p>With this mind if you extend your intention to reach out with your translation...it'll really make a difference in the world, and it already does.</p>
                <footer>Dzigar Kongtrül Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>If one wishes to repay the kindness of Lord Buddha, the most supreme way is hearing, contemplating, writing, reading, keeping, and even touching Dharma texts.</p>
                <p>Of course, imagine translating––making these texts available to people who otherwise would not have this kind of opportunity to explore this world of wisdom and compassion. I think it's really worth it.</p>
                <footer>Dzongsar Khyentse Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>It has been a joy to witness the steady growth in Tibetan Buddhist translation over the last few decades. Now, with many different individuals and groups around the world participating in this noble and historic endeavour, it is crucial that we work together and strive to produce translations that are as accurate, authentic and accessible as possible. It is my hope that through conferences such as this, translators can come to recognize the critical role they play in ensuring the longevity of these teachings, and, with a common vision and understanding, carry out their task in a spirit of harmony, collaboration and humility, and always with the purest motivation. In so doing, and by building upon the pioneering efforts of earlier generations, we can make an important and lasting contribution to the future of the Buddhadharma, and, indeed, of humanity itself.</p>
                <footer>Sogyal Rinpoche, August 15, 2008</footer>
            </blockquote>
            <blockquote class="offset">
                <p>Infrastructure is very important, and funding is necessary of course––but even more important than that is bodhicitta (altruistic intention). Without that, what are we going to translate? What's the use?</p>
                <footer>Jigme Khyentse Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>The Buddhist teachings are based on nonviolence and they are a source of world peace.</p>
                <footer>Tulku Pema Wangyal Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>The translation of the Kangyur is a cultural transfer and a spiritual transmission. The goal is communication, which can be achieved through collaboration and consultation.</p>
                <footer>Dr. Peter Skilling, Fragile Palm Leaves Foundation</footer>
            </blockquote>
            <blockquote class="offset">
                <p>It's entirely possible that the survival of the Buddhadharma could depend on it being translated into other languages.</p>
                <footer>Dzongsar Khyentse Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>If we don't translate now, then even though the favorable material conditions for lotsawas (translators) will keep increasing, the potential from panditas (scholars) will keep disappearing.</p>
                <footer>Orgyen Tobgyal Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>Because the wisdom of the Buddha is timeless, we're bringing these teachings to the present world.</p>
                <footer>Jakob Leschly</footer>
            </blockquote>
            <blockquote class="offset">
                <p>Even though there are religious aspects to Buddhism that have been expressed throughout the centuries in different cultures, in essence it's a science of mind.</p>
                <p>It's a world heritage we must preserve, continue and share in all languages.</p>
                <footer>Dzogchen Pönlop Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>For the Buddha's teachings to truly thrive in our cultures and take root in our hearts, we must have a genuine Western Buddhism.</p>
                <p>For this genuine tradition to flourish and become fully integrated in the West, we must have the words of the Buddha in English.</p>
                <footer>Dzogchen Pönlop Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>Presentation of the Dharma in languages other than Tibetan and Sanskrit will create great merit and through this so many people can attain liberation and enlightenment.</p>
                <footer>H.H. Sakya Trizin</footer>
            </blockquote>
            <blockquote class="offset">
                <p>It's not just the heritage of one tradition, one civilization or one nation––it's the heritage of the world.</p>
                <p>The Kangyur and Tengyur will really contribute to the happiness, peace and freedom of all mankind.</p>
                <footer>Tulku Pema Wangyal Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>Since the late 1960s I have researched, and found that barely half of the Sanskrit texts exist.</p>
                <p>Kangyur Rinpoche said this would happen in the future with Tibetan texts as well...and that we would need to translate them into other languages in future so that we could translate them back to Tibetan.</p>
                <footer>Tulku Pema Wangyal Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>Actually we're already 30-40 years too late in beginning this task.</p>
                <footer>Orgyen Tobgyal Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>There is much wisdom in the sutras...like the Buddhist view of organizational science and the organization of sangha...how a bodhisattva should rule a country...the view and function of military science––isn't that important today?</p>
                <footer>Dzogchen Pönlop Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>For people to be free from suffering and gain happiness, they need access to the teachings of the Buddha. Therefore, the Buddhist Literary Heritage Project can be a great help in the lives of many.</p>
                <footer>Khen Rinpoche Lobsang Tsetan</footer>
            </blockquote>
            <blockquote class="offset">
                <p>In 1962 there was a great gathering of all the lamas in Tibet, and if you look at how few of them are still alive in this world when you compare that gathering with similar recent gatherings, you'll see what I mean.</p>
                <footer>Orgyen Tobgyal Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>What a great opportunity. We are in the golden age of establishing the genuine Dharma in the English speaking world.</p>
                <footer>Ringu Tulku Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>From the perspective of translating the Buddhadharma, bodhicitta (altruistic intention) is of paramount importance. With that it's possible to develop wisdom, not just knowledge. That wisdom is what we're trying to transmit.</p>
                <footer>Jigme Khyentse Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>The Buddhist heritage and culture that permeated Tibetan life for more than a thousand years has all but disappeared in India, its country of origin.</p>
                <p>The great lotsawas (translators) who translated Buddhist texts into Tibetan effectively rescued the Buddhadharma from premature extinction.</p>
                <p>What was virtually lost in India can now be found in Tibet, and it's becoming available again in India.</p>
                <footer>Dzongsar Khyentse Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>Now we still have extraordinary masters capable of using the texts to explain everything they mean. If we have to wait longer, there will be fewer such masters.</p>
                <footer>John Canti</footer>
            </blockquote>
            <blockquote class="offset">
                <p>Translating the words of the Buddha and commentarial treatises from Tibetan into English is a necessary foundation for the genuine study and practice of the Buddhadharma for English speakers.</p>
                <footer>H.H. the 17th Karmapa</footer>
            </blockquote>
            <blockquote class="offset">
                <p>This task is to translate the wealth we share in common, and so there is no need to think in terms of 'them' and 'us'.</p>
                <p>We should therefore all make an effort since we all work to assist the teaching and sentient beings––and there is no greater way to serve than this translation work.</p>
                <p>We should all fill our hearts with courage and appreciation for this task.</p>
                <footer>Chökyi Nyima Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>The Buddhist canon is our most precious treasury of wisdom. This is true not only for Buddhists, but it is also a great source of wisdom for the world.</p>
                <footer>Dzogchen Pönlop Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>There's urgency as old lamas are exhausting and disappearing...we can't really wait.</p>
                <footer>Dzongsar Khyentse Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>When something is important it must be emphasized. And if it pertains to the holy Dharma, we should repeat it 100 times!</p>
                <footer>H. H. Ganden Tripa Rizong Sras Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>Don't waste time in dedication for me, I don't care about my illness anymore. Just get the translation done quickly. One more word I am able to read, one more fire glows inside me. The excitement of reading the words of the Buddha really made me forget for a few minutes that I am sick.</p>
                <footer>Yeap Min Seang</footer>
            </blockquote>
            <blockquote class="offset">
                <p>Translation of the Kangyur won't become easier, and there won't be a better time to do so––the longer we wait, the less likely it is to happen.</p>
                <footer>Orgyen Tobgyal Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>The last thing we want to do is make translations that are objects of reverence but are not used. We must use our translations in study and practice.</p>
                <footer>Dzogchen Pönlop Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>A comprehensive English compilation of the Buddha's words will serve as an authoritative bedrock for a living tradition.</p>
                <footer>Dzogchen Pönlop Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>To our great fortune...we have the throne-holding masters of the four major schools. We have authentic masters well versed in all the important topics, both sutra and tantra.</p>
                <p>They can resolve our questions. They can advise us. It is therefore important to translate as soon as possible.</p>
                <footer>Chökyi Nyima Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>We live in a time when the Buddhadharma hangs by a thin thread... Many masters, both learned and realized, are no longer alive. When thinking of this I feel a deep loss and sadness.</p>
                <p>It is for these reasons I feel strongly that we must commence the task of translating the great Kangyur as soon as possible.</p>
                <footer>Chökyi Nyima Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>It is wonderful to know that...the highest level of authentic translation is being done for the spread of Dharma throughout the world.</p>
                <footer>late H.H. Mindrolling Trichen Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>Over these 25 years, so many great books have been translated due to the kindness of the translators and the teachers who guided them.</p>
                <p>Now when teachings are to be done...things have become comparatively easier because of the availability of books.</p>
                <footer>Dzigar Kongtrül Rinpoche</footer>
            </blockquote>
            <blockquote class="offset">
                <p>84,000 teachings were taught because there are 84,000 kinds of attitudes and kinds of mind-streams. And that is, supposedly, according to the Heyavajra Tantra, that is supposedly like not even one percent of what Buddha taught.</p>
                <footer>Dzongsar Khyentse Rinpoche, August 2002</footer>
            </blockquote>
        </xsl:variable>

        <xsl:call-template name="about">
            <xsl:with-param name="sub-content" select="$content"/>
        </xsl:call-template>

    </xsl:template>

</xsl:stylesheet>