#!/usr/bin/env bats
# -*- tab-width: 4; encoding: utf-8 -*-

. $BATS_TEST_DIRNAME/common.rc

@test "oglHasRemoteBranch() on pushed branch should return 0 (1)" {
    __commitAndPushMaster

    run oglHasRemoteBranch
    [ "$status" -eq 0 ]
}

@test "oglHasRemoteBranch() on pushed branch should return 0 (2)" {
    __commitAndPushMaster

    run oglHasRemoteBranch master
    [ "$status" -eq 0 ]
}

@test "oglHasRemoteBranch() on pushed branch should return 0 (3)" {
    __commitAndPushMaster
    __createBranch plop
    git remote add origin2 $GIT_REPO_DIR > /dev/null 2>&1
    git push origin2 plop

    run oglHasRemoteBranch plop
    [ "$status" -eq 0 ]
}

@test "oglHasRemoteBranch() on pushed branch should return 0 (4)" {
    __addCommit
    __createBranch plop
    __push plop

    run oglHasRemoteBranch plop
    [ "$status" -eq 0 ]
}


@test "oglHasRemoteBranch() on non remote branch should return 1 (1)" {
    __addCommit

    run oglHasRemoteBranch master
    [ "$status" -eq 1 ]
}

@test "oglHasRemoteBranch() on non remote branch should return 1 (2)" {
    __addCommit
    __createBranch plap

    run oglHasRemoteBranch plap
    [ "$status" -eq 1 ]
}
