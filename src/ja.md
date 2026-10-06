# 4DとNotionの連携：Notion APIによるページとデータベースの作成

Al Mahdi Bakkali（4D Inc. 品質サポートエンジニア）

テクニカルノート 25-08

## 概要

このテクニカルノートでは、強力なアプリケーション開発環境である4Dと、モダンなワークスペースプラットフォームであるNotionを、Notion APIを使用して連携する方法を解説します。4DアプリケーションからNotionのデータベースやページに対して、CRUD（作成・読み取り・更新・削除）操作をプログラムで実行する方法を紹介します。4DのHTTPリクエスト機能と解析ツールを活用すれば、在庫などの構造化された業務データをNotionに送り込み、追跡、共同作業、分析に役立てることができます。サンプルの業務アプリケーションでは実際の使用例を示し、4Dで完了したトランザクションから構造化されたエントリーをNotionに自動生成することで、チームによる業務データの可視化と管理がどのように変わるかを紹介します。

## はじめに

最近の4Dのバージョンには、Webクライアント接続のための機能やコマンドが数多く用意されています。以前のバージョンで導入されたHTTPRequestクラスにより、HTTPリクエストとレスポンスの扱いは大きく改善されました。これにより、4Dは市場で求められるサードパーティのサービスとシームレスに接続し、連携できるようになっています。

## 4DとNotionの概要

Notionは、個人のメモ取りだけでなく、企業レベルのプロジェクト管理ソリューションとしても近年人気が高まっている生産性ソフトウェアです。Notionは柔軟な共同ワークスペースを提供し、ユーザーはデータベース、カレンダー、テーブルなどを追加して自由にカスタマイズできます。使いやすいインターフェースとクロスプラットフォーム対応により、同期されたデータがチーム運営の成否を左右する場面で、チームの共同作業ツールとして選ばれています。

### ユースケース：4DからNotionへの在庫のリアルタイム同期

このテクニカルノートでは、4DとNotionを連携し、NotionでCRUD操作を実行する方法を探ります。これにより、Notionのデータベースとそのページを4Dと直接同期させ、上記の操作を即座に実行できるようになります。

本テクニカルノートのユースケースは在庫管理システムを模したもので、顧客対応の従業員がNotionで店舗の在庫を管理します。エンドユーザーは商品アイテムのリストを持ち、新しい注文を受けるとそのリストが更新されます。バックエンドでは、4Dが保管施設の在庫管理システムの役割を担い、そこに貨物が届いて在庫が補充されます。4Dのユーザーが商品の在庫を更新すると、その内容が即座にNotionに反映されます。

### 連携のメリット：知識の一元化、自動化、チームの共同作業

Notionのデータベースはデータをテーブル形式で表示でき、各エントリーは1件のレコード、つまりNotionでいう「ページ」を表します。各ページには、エンドユーザーが入力できる複数の属性を持たせることができます。

本テクニカルノートで紹介する4DとNotionの連携により、開発者はサードパーティのデータを一元化し、レコードを4Dで直接表示・変更できるようになります。紹介するユースケースでは、さまざまなソフトウェアで手作業で行っていた在庫更新を自動化することで、2つの事業部門を結び付け、業務とチームの連携を促進します。

### 前提条件

- 4D 20 R9
- 内部インテグレーションシークレット（Internal Integration Secret）の認証情報で作成したNotionのインテグレーション
- JSONとREST APIに関する基本的な知識

## Notion APIの認証

Notion APIは、ページ、データベース、ユーザー、コメントなど、Notionのワークスペースを細かくカスタマイズするための強力なAPIエンドポイント群を提供しています。次の節では、Notionが提供するインテグレーション（integration）の種類と、Notionでの内部インテグレーションの設定方法を説明します。

Notionには、用途に応じてデータにアクセスするための2種類のインテグレーションがあります。APIエンドポイントは同じですが、認証の手順が異なります。2つのインテグレーションの主な違いは、エンドユーザーの範囲とアクセス権です。

> **注：**そのインテグレーションは一般公開を目的としていますか？それとも社内ツールとして使うことを想定していますか？

これらは、適切な種類のインテグレーションを選ぶときに開発者が自問すべき質問です。それぞれを詳しく見てみましょう。

- **内部（Internal）**：非公開の社内ワークスペース向け。
- **パブリック（Public）**：広く公開・共有されるワークスペース向け。

前述のとおり、データへのアクセスと権限はどちらのインテグレーションでも同じです。つまり、どちらの場合も開発者は同じAPIエンドポイントを利用できます。読み取り・書き込みの権限はNotionのダッシュボードで設定し、2種類のインテグレーションで共通です。

### 新しい内部インテグレーションの追加

本テクニカルノートでは企業向けソリューションを想定し、Notion APIへの内部インテグレーションを使用します。

この種類のインテグレーションを設定する手順を、順を追って説明します。

1. Notionアカウントにログインし、https://www.notion.so/profile/integrations にアクセスします。
2. 「New Integration」をクリックします。
3. 「Integration name」を入力します。
4. 「Associated workspace」を選択し、「Type」ドロップダウンで「Internal」を選択します。必要に応じてロゴをアップロードします。
5. 「Save」をクリックします。
6. 成功のアラートで「Configure integration settings」をクリックします。

以上の手順でインテグレーションが作成され、ブラウザーはインテグレーションの設定ページにリダイレクトされます。このページは、Notion APIへのアクセスを設定・制限するうえで重要です。

### 新しいNotionページの登録

作成したばかりのインテグレーションはまだどのページにもアクセスできないため、「Access」タブでページを追加するよう促すアラートが表示されます。テンプレートギャラリーから、Notionアカウントに新しいページを追加しましょう。

1. テンプレート https://www.notion.so/marketplace/templates/inventory-manager-database にアクセスし、「Add」をクリックします。
2. 数秒待つと、「Inventory Manager」という名前のコピーが左のサイドバーに表示されます。
3. 「Inventory Manager」をクリックして、新しいNotionデータベースを表示します。

### Notionページへのアクセスの許可

Notionに最初のページができたので、これをインテグレーションに追加します。

インテグレーションの設定に戻ります。上記のURLにアクセスするか、**「Settings」→「Connections」→「Develop or manage integrations」**をクリックします。続いて、Inventory Managerページへのアクセスを設定します。

1. インテグレーションの設定ページで「Access」タブをクリックし、「Select pages」をクリックします。
2. ページを検索するか、折りたたみメニュー「Private」を展開します。
3. 「Inventory Manager」を選択し、「Update Access」をクリックします。

### 認証キーの取得

「Configuration」タブに戻ると、「Capabilities」でインテグレーションの権限を確認できます。本テクニカルノートでは、デフォルト値のままにします。

同じタブの「Internal Integration Secret」には、伏せられたコードが表示されています。「Show」と「Copy」をクリックして、内部インテグレーションシークレットを取得します。例：

```text
ntn_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

> **注：**このコードを保存し、デモアプリで入力を求められたら入力してください。

このシークレットキーは、本テクニカルノートで紹介する連携に欠かせません。次の節で説明するとおり、認証のBearerトークンとして各リクエストのヘッダーで送信されるためです。

## Notion APIの基本概念

認証トークンを取得できたので、Notion APIにリクエストを送信できるようになりました。次の節では、Notionの基本概念と、4Dとの連携を例示するためのAPIエンドポイントをいくつか紹介します。

### ページとデータベース

ページとデータベースの概念は、Notionを使い始めたばかりのユーザーにとって紛らわしいかもしれません。ページはNotionの主要な作業スペースで、ユーザーはさまざまなグラフィカルオブジェクトを追加できます。Notionのページには、構造化された情報を保持するためのプロパティがあります。また、各ページには一意の識別子が付いています。

一方、Notionのデータベースはページの集まりで、開発者はページ内の構造化データを作成・操作できます。

4Dの用語でいえば、ページはデータベースに格納されたレコードで、プロパティはテーブルのフィールドにあたります。本テクニカルノートのユースケースでは、テーブル形式のグラフィカルオブジェクトで個々の商品アイテムを保持します。各アイテムは1つのページに対応し、それぞれが一意のIDで区別されます。

> **注：**Notion APIを呼び出すには、Notionのデータベースとページのidが必要です。idを取得するには、Notionでデータベースまたはページを開きます。右上の「Share」をクリックし、「Copy Link」をクリックします。コピーした内容をテキストエディターに貼り付けて、URLを確認します。

「Share」ボタンでコピーできるURLの例を3つ示します。

```text
1. https://www.notion.so/Smart-LED-Desk-Lamp-2454fd2ac9c581cd83c3c84786bbafc3?source=copy_link
2. https://www.notion.so/Inventory-Manager-2454fd2ac9c5805a8e75e52a02b08e31
3. https://www.notion.so/Inventory-Manager-2454fd2ac9c5805a8e75e52a02b08e31?p=2454fd2ac9c581cd83c3c84786bbafc3&pm=s
```

例1はNotionのページのURLです。URLには、そのページのidにあたる32桁の文字列が含まれています。

例2も同様ですが、こちらはデータベースのURLです。

例3は両者を組み合わせたもので、データベースのidに続いてページのidが表示されます。

本テクニカルノートでは、この方法でデータベースのidを取得します。このidはNotion APIにリクエストを送信するときに引数として渡され、「8-4-4-4-12」の形式で指定する必要があります。4Dでの例を示します。

```text
2454fd2a-c9c5-81dc-82bd-c1e22c6f0031
```

> **注：**このコードを保存し、デモアプリで入力を求められたら入力してください。

既存のページを更新するにはそのidが必要なため、ページのidも把握しておく必要があります。ただし、本テクニカルノートではこのidを自動的に取得します。このidは、Notionと4Dの間でデータのエントリーを同期するためにも使用されます。

## Storageによるセッションデータの管理

Storageオブジェクトは、アプリケーションのさまざまな部分でデータを管理・共有するための4Dの強力なツールです。Storageは共有オブジェクトで、設定値やユーザーの認証情報など、セッションの間保持する必要がある情報を簡単かつ効率的に格納できます。

デモアプリケーションでは、データベースの起動時に認証用のBearerトークンとデータベースのidの入力をユーザーに求め、アプリケーション全体で後から使えるようにStorageオブジェクトに格納します。これを示すコードは次のとおりです。

```4d
Use (Storage)
    If (Storage.notionConfig=Null)
        ALERT("Please enter your Notion API credentials.")
        $bearerToken:=Request("Enter Notion Bearer Token:")
        $databaseId:=Request("Enter Notion Database ID:")
        Storage.notionConfig:=New shared object
    End if
End use

Use (Storage.notionConfig)
    Storage.notionConfig.bearerToken:="Bearer "+$bearerToken
    Storage.notionConfig.databaseId:=$databaseId
End use
```

## 主なAPIエンドポイント

前述のとおり、本テクニカルノートの目的は、API呼び出しによって4DからNotionのデータベースに対してCRUD操作を実行することです。この節では、これらの操作を実現するための主なAPIエンドポイントを説明します。

### ヘッダー

Notion APIと正しく通信するには、すべてのリクエストに特定のヘッダーを含める必要があります。これらのヘッダーは、送信するデータの種類や必要な認証トークンなどの重要な情報を伝えます。

Content-Typeヘッダーは、リクエストボディの形式を指定します。Notion APIでは常にapplication/jsonで、データのペイロードがJSONオブジェクトであることを示します。Authorizationヘッダーには、Bearerを前に付けた内部インテグレーションシークレットが含まれ、Notionワークスペースに対するリクエストを認証します。最後に、Notion-Versionヘッダーは必須の引数で、アプリケーションが特定のバージョンのAPIと互換性を持つようにします。

Notion API用のヘッダーを持つ4Dオブジェクトの例を示します。

```4d
$headers:=New object
$headers.Accept:="application/json"
$headers["Content-Type"]:="application/json"
$headers.Authorization:="Bearer "+"<your Notion integration secret>"
$headers["Notion-Version"]:="2022-06-28"
```

### ページの作成

Notionで新しいページを作成するには、次のエンドポイントにあたる「Create a page」APIを使用します。

```text
https://api.notion.com/v1/pages
```

このエンドポイントは、親ページまたは親データベースの中に子ページを作成します。親のIDはparent属性で送信します。このエンドポイントには、リクエストで送信する必要がある一連の引数があります。4Dでの呼び出し例を示します。

```4d
$requestBody:=New object
$requestBody.parent:=New object("database_id"; $databaseId)
$requestBody.properties:=$properties
$dbRequest:=4D.HTTPRequest.new("https://api.notion.com/v1/pages"; {method: "POST"; headers: $headers; body: $requestBody})
```

このコードのとおり、リクエストではparentとpropertiesという2つのボディ引数を送信します。どちらもこのエンドポイントを使用する際に必須です。本テクニカルノートでは、propertiesを4Dフォームの入力フィールドと対応させています。

### ページの更新

Notionの既存のページを変更するには、「Update page properties」APIエンドポイントを使用します。これは、一意のIDで特定のページを対象とする**PATCH**リクエストです。

エンドポイントのURLは次のとおりです。{page_id}は更新するページのIDです。

```text
https://api.notion.com/v1/pages/{page_id}
```

PATCH呼び出しのリクエストボディには、変更するプロパティだけを含めます。NotionのAPIは部分的な更新を扱えるように設計されているため、ページのデータ全体を送信する必要はありません。そのため、更新処理がシンプルになります。

ページを更新する4Dコードの例を示します。

```4d
$dbRequest:=4D.HTTPRequest.new("https://api.notion.com/v1/pages/"+$pageId; {method: "PATCH"; headers: $headers; body: $requestBody})
```

### データベースの読み取り

Notionのデータベースからデータを取得するには、「Query a database」エンドポイントに**POST**リクエストを送信します。

```text
https://api.notion.com/v1/databases/{database_id}/query
```

このエンドポイントでは、指定したデータベース内のすべてのページ（レコード）を取得できます。

このエンドポイントのレスポンスにはオブジェクトのコレクションが含まれ、各オブジェクトがデータベース内の1ページを表します。各ページオブジェクトには、一意のIDと、そのページの構造化データをすべて保持するpropertiesオブジェクトが含まれます。このデータには、カテゴリー、商品名、在庫数など、Notionデータベースのすべてのプロパティが含まれます。

本テクニカルノートのユースケースでは、データベースを読み取り、これらのプロパティを4Dのコレクションにマッピングすることで、2つのプラットフォーム間でデータを同期します。次のコードのように、APIレスポンスからページのプロパティを解析し、4Dアプリケーションのリストボックスに表示します。

```4d
$item.category:=$page.properties.Category.select.name
$item.dateAdded:=$page.properties["Date Added"].date.start
$item.price:=$page.properties.Price.number
```

Notionからデータベースを読み取るときは、各ページオブジェクトのidプロパティを取得し、次のように4Dオブジェクトに格納します。

```4d
$item.id:=$page.id
```

この一意のIDは同期のキーとして機能するため、後で4Dアプリケーションからそのページを更新または削除するうえで欠かせません。

### ページの削除

Notion APIには、ページ専用の**DELETE**エンドポイントはありません。代わりに、ページはアーカイブすることで「削除」されます。これは、更新に使用したのと同じ「Update page properties」エンドポイントにPATCHリクエストを送信して行います。

ページをアーカイブするには、リクエストボディのarchivedプロパティをtrueに設定します。この操作でページはNotionの通常のビューから消えますが、アーカイブには残るため、必要に応じて後から復元できます。

4Dでページをアーカイブする例を示します。

```4d
$requestBody.archived:=True
$dbRequest:=4D.HTTPRequest.new("https://api.notion.com/v1/pages/"+$pageId; {method: "PATCH"; headers: $headers; body: $requestBody})
```

## 4DのデータとNotionのスキーマのマッピング

サンプルアプリケーションでは、4Dで在庫アイテムのコレクションを扱います。コレクションの各アイテムは、**category**、**dateAdded**、**price**、**productName**、**stockLevel**といったプロパティを持つオブジェクトです。下図のように、4Dのこの構造は、Notionの「Inventory Manager」データベースのプロパティスキーマと直接対応している必要があります。

![](fig-01)

### 4Dの変数とNotionのプロパティの対応付け

4Dの各データ型（テキスト、数値、日付など）は、Notionの対応するプロパティタイプにマッピングする必要があります。例：

- **productName**用の4Dのテキストフィールドは、NotionのTitle（タイトル）プロパティに対応します。
- **stockLevel**用の4Dの数値フィールドは、NotionのNumber（数値）プロパティに対応します。
- **dateAdded**用の4Dの日付フィールドは、NotionのDate（日付）プロパティに対応します。

このマッピングは双方向の同期に欠かせません。4Dで新しいアイテムを作成すると、そのデータはNotionが解釈できるJSONペイロードに変換されます。反対に、Notionから読み取るときは、返されたページのプロパティを解析し、対応する変数に代入します。

### エラー処理とログ

API連携には、堅牢なエラー処理が欠かせません。よくある問題には、認証エラー、スキーマの不一致、権限の問題などがあります。4Dでは、HTTPレスポンスのステータスコードが成功・失敗を判断する重要な指標になります。

- 一般的なAPIエラーへの対処

APIリクエストが成功すると、200〜299のHTTPステータスコードが返されます。4Dでは、次のような条件文で確認できます。

```4d
If (($dbRequest.response.status>=200) & ($dbRequest.response.status<300))
    // Successful response,
Else
    // use $dbRequest.response.statusText to get error text
End if
```

- **認証エラー**：Authorizationトークンが無効または期限切れの場合は、ステータスコード**401**が返されます。
- **スキーマの不一致**：リクエストボディに、Notionデータベースのスキーマと一致しないプロパティが含まれている場合、APIはステータスコード**400**を返します。
- **権限の問題**：特定のページやデータベースに対する読み取りまたは書き込みの権限がない場合は、ステータスコード**403**が返されます。

## サンプルデモ：業務アプリケーションのワークフロー

このサンプルのデスクトップアプリケーションは、Notionと同期する、4Dで構築した在庫管理システムです。4Dアプリケーションが倉庫の在庫を管理し、顧客対応の従業員がNotionデータベースで在庫を確認する、という実際の業務を模して設計されています。

### サンプルの説明：4Dによる在庫管理システム

4Dアプリケーションは、保管施設のバックエンドとして機能します。倉庫のスタッフが商品の在庫数を確認・変更するためのユーザーインターフェースを備えています。アプリケーションには、すべての商品が現在の在庫数とともに一覧表示され、SKU、価格、仕入先などの詳細も表示されます。

![](fig-02)

### 4DとNotionでの在庫の更新

同期処理は、4Dアプリケーション内の在庫更新イベントによって開始されます。新しい在庫が届くと、倉庫の従業員が4Dシステムで商品の在庫数を更新します。この操作により、APIリクエストが自動的にNotionに送信され、営業チームが使用するフロントエンドのシステムにデータが即座に反映されます。これにより手作業でのデータ入力がなくなり、人為的ミスのリスクが減ります。4Dでは、操作を実行するたびに**getNotionDatabase**メソッドを使用してリストボックスのデータを更新・同期します。

![](fig-03)

更新ボタンをクリックすると、在庫数を更新するために次のコードが4Dで実行されます。

```4d
$newStockValue:=100
$headers:=New object
$headers.Accept:="application/json"
$headers["Content-Type"]:="application/json"
//$headers.Authorization:="Bearer "+"<your Notion integration secret>"
$headers["Notion-Version"]:="2022-06-28"

Use (Storage)
    $headers.Authorization:=Storage.notionConfig.bearerToken
End use
$requestBody:=New object
$requestBody.properties:=New object
$requestBody.properties.StockLevel:=New object("number"; $newStockValue)
$requestBody.properties.Status:=New object("status"; New object("name"; "In Stock"))
$dbRequest:=4D.HTTPRequest.new("https://api.notion.com/v1/pages/"+$pageId; {method: "PATCH"; headers: $headers; body: $requestBody})
$dbRequest.wait(30)
```

## Qodly StudioのWebアプリ：4Dとのシームレスな連携

### Qodly StudioのWebアプリケーションの紹介

Qodly StudioのWebアプリケーションは、すっきりとしたモダンなユーザーインターフェースを持つ在庫管理システムです。このWebアプリは4Dのデスクトップデモの機能をそのまま再現したもので、Qodly Studioによるシームレスな連携と強力な機能を示しています。アプリケーションには、Total Items（総アイテム数）、Total Revenue（総売上）、Items Sold（販売数）、Low Stock Alert（在庫不足アラート）などの主要な指標が表示され、在庫状況を総合的に把握できます。

![](fig-04)

Qodly Studioを使い始め、デモアプリを試すための手順を示します。

- **前提条件の確認**：始める前に、ドキュメント https://developer.4d.com/docs/WebServer/qodly-studio を確認し、必要なコンポーネントがすべてそろっていることを確認してください。
- **Qodly Studioを開く**：4Dで「デザイン」メニューを開き、「Qodly Studio...」をクリックします。デフォルトのWebブラウザーでQodly Studioが開きます。
- **起動とプレビュー**：4D Webサーバーが起動していることを確認します。起動したら、Qodly Studio内の「Preview」ボタンをクリックします。

### 主な機能とメリット

#### 連携の容易さ

Qodly Studioの最も大きな利点の一つは、4D環境と簡単に連携できることです。手順で示したとおり、連携の手順は簡単です。この直接的なつながりにより、開発者は複雑な設定や準備なしに、既存の4Dのデータとビジネスロジックを活用できます。Webアプリケーションはブラウザーですぐにプレビューできるため、開発とテストのサイクルを短縮できます。

#### コードの再利用

Qodly Studioでは、4Dアプリケーションで使用しているのと同じバックエンドのビジネスロジックやデータモデルと連携するWebアプリケーションを構築できるため、コードの再利用が進みます。Qodly Studioは独自のスクリプト言語を使用しますが、その基盤となるアーキテクチャにより、4Dで定義したデータやルールにWebアプリからアクセスして利用できます。つまり、在庫を管理するために4Dで書いた関数やメソッドをQodlyアプリケーションから呼び出せるため、別のプラットフォーム向けに同じロジックを書き直す必要がありません。この方法は時間を節約できるだけでなく、アプリケーション間の一貫性も確保します。デモアプリケーションでは、Qodlyのメソッドは「Datastore」の「Classes」の下にあります。

![](fig-05)

#### 4Dとの互換性

Qodly Studioは、4Dと高い互換性を持つように設計されています。この相乗効果により、開発者は4DアプリケーションをWebへ簡単に拡張できます。在庫管理システムはこの互換性をよく表しています。在庫の追加、更新、削除といった操作はすべてWebインターフェースで行われますが、4Dアプリケーションで定義された対応するビジネスロジックとデータベース操作が実行されます。この双方向の通信により、データは常に同期され、Webアプリは中核となる4Dシステムの真の拡張となります。

## まとめ

Notion APIを介して4DとNotionを連携することで、2つの異なるプラットフォームを強力に結び付け、4Dの堅牢なアプリケーション開発機能とNotionの柔軟な共同ワークスペースを組み合わせることができます。本テクニカルノートの手順に従えば、開発者は4DをNotionと連携し、同じ原則でほかのAPI呼び出しも実行できます。在庫管理システムのユースケースは、4Dがサードパーティのアプリケーションと接続・同期できることを示しています。
