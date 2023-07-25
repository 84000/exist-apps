xquery version "3.0";

import module namespace trigger="http://exist-db.org/xquery/trigger" at "triggers.xql";

(:trigger:after-update-document(xs:anyURI('/db/apps/84000-data/tei/translations/kangyur/translations/001-001_toh1-1_chapter_on_going_forth.xml')):)
(:trigger:after-update-document(xs:anyURI('/db/apps/84000-data/tei/translations/kangyur/placeholders/014-001_toh8-the_perfection_of_wisdom_in_one_hundred_thousand_lines.xml')):)
trigger:after-update-document(xs:anyURI('/db/apps/84000-data/tei/layout-checks/84000-layout-checks.xml'))