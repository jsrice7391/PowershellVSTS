$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

$script = "$here\..\deploy.ps1"


Describe "Deploy" {
    It "Verifies if the deploy file is there." {
        Deploy -Script $script | Should -Be $true
    }
}

