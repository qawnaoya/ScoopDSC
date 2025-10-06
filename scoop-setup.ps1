Configuration InstallScoop
{
    param
    (
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    Node localhost
    {
        Script InstallScoopForUser
        {
            # 修正点1: パラメータで受け取ったCredentialオブジェクトを指定
            PsDscRunAsCredential = $Credential

            GetScript = {
                # TestScriptと同じロジックでOK
                # Resultキーに状態を入れるとより丁寧
                return @{
                    Result = "Scoop Installed: $((Get-Command scoop -ErrorAction SilentlyContinue) -ne $null)"
                }
            }

            SetScript = {
                # 修正点3: よりモダンなコマンドに変更
                Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
                Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
            }

            TestScript = {
                (Get-Command scoop -ErrorAction SilentlyContinue) -ne $null
            }
        }
        # 修正点2: FileリソースとDependsOnを削除
    }
}
