#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

. $BATS_TEST_DIRNAME/common.rc

@test "oglGetRemoteBranches() on pushed branch (1)" {
    __commitAndPushMaster

    run oglGetRemoteBranches
    echo $output
    [ $output == 'origin/master' ]
    [ "$status" -eq 0 ]
}

@test "oglGetRemoteBranches() on pushed branch (2)" {
    __commitAndPushMaster

    run oglGetRemoteBranches master
    [ $output == 'origin/master' ]
    [ "$status" -eq 0 ]
}

@test "oglGetRemoteBranches() on pushed branch (3)" {
    __commitAndPushMaster
    __createBranch plop
    __push plop
    git remote add origin2 $GIT_REPO_DIR > /dev/null 2>&1
    __addCommit
    git push origin2 plop > /dev/null 2>&1

    run oglGetRemoteBranches plop
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" == "origin/plop" ]]
    [[ "${lines[1]}" == "origin2/plop" ]]
}

@test "oglGetRemoteBranches() on pushed branch (4)" {
    __addCommit
    __createBranch plop
    __push plop

    run oglGetRemoteBranches plop
    [ "$status" -eq 0 ]
    [ $output == 'origin/plop' ]
}

@test "oglGetRemoteBranches() on non remote branch (1)" {
    __addCommit

    run oglGetRemoteBranches master
    [ "$status" -eq 0 ]
    echo $output
    [[ $output == "" ]]
}

@test "oglGetRemoteBranches() on non remote branch (2)" {
    __addCommit
    __createBranch plap

    run oglGetRemoteBranches plap
    [ "$status" -eq 0 ]
    [[ $output == '' ]]
}
