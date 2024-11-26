xquery version "3.1";

let $log-file-path := '/db/apps/84000-data/uploads/apache-logs'
for $log-file-name in xmldb:get-child-resources($log-file-path)
let $log-file := util:binary-to-string(util:binary-doc(string-join(($log-file-path, $log-file-name),'/')))
let $log-file-lines := tokenize($log-file, '&#10;')

(:string-join(($log-file-path, $log-file-name),'/'),:)
(:count($log-file-lines),:)

let $search-terms := 
    for $line in $log-file-lines
    where matches($line, 'search-type=tei', 'i')
    return
        let $line-chunks := tokenize($line, ' ')
        for $line-chunk in $line-chunks
        where matches($line-chunk, '^/search.html', 'i')
        return
            let $parameters := tokenize($line-chunk, '&amp;')
            for $parameter in $parameters
            where matches($parameter, '^search=', 'i')
            return
                tokenize($parameter, '=')[2]

for $search-term in $search-terms
group by $search-term
let $count-term := count($search-terms[. eq $search-term])
order by $count-term descending
return
    concat(util:unescape-uri($search-term, "UTF-8"), ' (', $count-term,')')


