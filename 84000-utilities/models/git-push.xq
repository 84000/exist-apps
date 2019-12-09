xquery version "3.0" encoding "UTF-8";

import module namespace local="http://utilities.84000.co/local" at "../modules/local.xql";
import module namespace common="http://read.84000.co/common" at "../../84000-reading-room/modules/common.xql";
import module namespace deploy="http://read.84000.co/deploy" at "../../84000-reading-room/modules/deploy.xql";

declare option exist:serialize "method=xml indent=no";

let $repo := request:get-parameter('repo', '')
let $password := request:get-parameter('password', '')
let $message := request:get-parameter('message', '')

return 
    common:response(
        'utilities/git-push',
        'utilities',
        (
            local:request(),
            if(common:user-in-group('git-push') and $repo gt '') then
                deploy:push($repo, $password, $message, ())
            else
                ()
        )
    )