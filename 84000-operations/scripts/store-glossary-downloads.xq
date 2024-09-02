xquery version "3.0" encoding "UTF-8";
(:
    Stores data for combined glossary downloads
:)

import module namespace store="http://read.84000.co/store" at "../../84000-reading-room/modules/store.xql";

util:log('info', 'store-glossary-downloads:initiated'),
store:glossary-downloads(),
util:log('info', 'store-glossary-downloads:completed')
