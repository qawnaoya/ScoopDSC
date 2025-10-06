# Scoop Installer using PowerShell DSC

## 概要

このリポジトリは、Windows向けのパッケージマネージャーである [Scoop](https://scoop.sh/) を、PowerShell Desired State Configuration (DSC) を利用して自動的にインストールするためのスクリプトを提供します。

DSCを利用することで、冪等性を保ちながら環境構築を自動化できます。つまり、このスクリプトを実行すれば、Scoopがまだインストールされていない場合にのみインストール処理が行われます。

## 特徴

- **PowerShell DSC**: 宣言的な構文で、システムの構成を定義します。
- **冪等性**: スクリプトを何度実行しても、システムの状態は同じになります。
- **モダンなコマンド**: `Invoke-RestMethod` を使用して、安全かつ効率的にScoopのインストールスクリプトを取得・実行します。

## 前提条件

- Windows PowerShell 5.1 またはそれ以降
- 管理者権限

## 使い方

このDSC構成を実行するには、管理者権限でPowerShellを開き、以下の手順に従います。

1. **資格情報（Credential）の準備**

   DSCの実行には、対象ノード（この場合は`localhost`）で操作を行うためのユーザー資格情報が必要です。以下のコマンドで `PSCredential` オブジェクトを生成します。

   ```powershell
   $credential = Get-Credential
   ```
   実行するとダイアログが表示されるので、ログインしているユーザーの資格情報を入力してください。

2. **DSC構成の実行**

   `scoop-setup.ps1` スクリプトを実行して、DSC構成を適用します。

   ```powershell
   # スクリプトがあるディレクトリに移動
   cd /path/to/this/repository

   # DSC構成を適用
   . ./scoop-setup.ps1
   ConfigurationInstallScoop -Credential $credential -OutputPath ./DSC_Output
   Start-DscConfiguration -Path ./DSC_Output -Wait -Force -Verbose
   ```

   これにより、`DSC_Output` ディレクトリに構成ファイル（`.mof`）が生成され、`Start-DscConfiguration` コマンドがその構成をシステムに適用します。`-Wait` オプションを付けているため、処理が完了するまで待機します。

## スクリプトの解説

`scoop-setup.ps1` は、`InstallScoopForUser` という名前の `Script` リソースを定義しています。

- `GetScript`: 現在Scoopがインストールされているかを確認します。
- `SetScript`: Scoopがインストールされていない場合に、インストール処理を実行します。
- `TestScript`: `GetScript` と同様に、Scoopのインストール状態をテストし、DSCが構成を適用する必要があるかを判断します。

`PsDscRunAsCredential` プロパティに実行ユーザーの資格情報を渡すことで、適切な権限でスクリプトが実行されることを保証します。