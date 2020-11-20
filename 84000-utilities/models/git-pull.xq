xquery version "3.0" encoding "UTF-8";

import module namespace utilities="http://utilities.84000.co/utilities" at "../modules/utilities.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace deploy="http://read.84000.co/deploy" at "../../84000-reading-room/modules/deploy.xql";

declare option exist:serialize "method=xml indent=no";

let $repo := request:get-parameter('repo', '')
let $password := request:get-parameter('password', '')

return 
    common:response(
        'utilities/git-pull',
        'utilities',
        (
            utilities:request(),
            if(common:user-in-group('dba') and $repo gt '') then
                deploy:pull($repo, $password)
            else
                ()
        )
    )