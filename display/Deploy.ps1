function Deploy($script) {
    if(-not(Test-Path -Path $script)){
        return $false
    }else{
        return $true 
    }
}
